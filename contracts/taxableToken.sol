// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

   contract TaxableToken is ERC20 {
    uint256 public taxPercentage; 
    address payable public taxWallet; 
    address public  owner;
    AggregatorV3Interface internal priceFeed; 

    event TaxPaid(address from, uint256 ethAmount);
    modifier onlyOwner{
        require(msg.sender==owner, "Only owner can call this function");
        _;
    }
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        uint256 _taxPercentage,
        address payable _taxWallet
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply * 10 ** decimals());
        taxPercentage = _taxPercentage;
        taxWallet = _taxWallet;
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); // Sepolia ETH/USD
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 tax = calculateTax(amount);
        uint256 amountAfterTax = amount - tax;

        require(payTax(tax), "Tax not paid");
        _transfer(_msgSender(), recipient, amountAfterTax);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 tax = calculateTax(amount);
        uint256 amountAfterTax = amount - tax;

        require(payTax(tax), "Tax not paid");
        _transfer(sender, recipient, amountAfterTax);
        _approve(sender, _msgSender(), allowance(sender, _msgSender()) - amount);
        return true;
    }

    function calculateTax(uint256 amount) internal view returns (uint256) {
        return (amount * taxPercentage) / 100;
    }

    function payTax(uint256 tokenTaxAmount) internal returns (bool) {
        uint256 taxInEth = convertTokenToEth(tokenTaxAmount);
        require(msg.value >= taxInEth, "Insufficient ETH for tax");

        (bool sent, ) = taxWallet.call{value: taxInEth}("");
        require(sent, "Failed to send tax to tax wallet");

        emit TaxPaid(_msgSender(), taxInEth);
        return true;
    }

    function convertTokenToEth(uint256 tokenAmount) internal view returns (uint256) {
        (, int256 price, , ,) = priceFeed.latestRoundData();
        uint256 ethPrice = uint256(price) * 1e10; // Convert to 18 decimals
        return (tokenAmount * 1e18) / ethPrice;
    }

    function setTaxPercentage(uint256 newTaxPercentage) external onlyOwner {
        taxPercentage = newTaxPercentage;
    }

    function setTaxWallet(address payable newTaxWallet) external onlyOwner {
        taxWallet = newTaxWallet;
    }

    receive() external payable {}
}
