// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
//require("@openzeppelin/contracts/token/ERC721/ERC721.sol");
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract OctaToken is ERC721 {

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds; 

    uint256 public constant MAX_SUPPLY = 12000;  
    uint256 public constant MINT_LIMIT_PER_TRANSACTION = 3;  
    uint256 public constant MAX_MINTS_PER_USER = 5;  
    uint256 public constant TRANSFER_FEE = 100 * 1e16;  
    address payable public owner; 

    uint256 public totalMinted;
    mapping(address => uint256) public userMints; 
    mapping(address => uint256[]) private _userMintedIds;  

    event Minted(address indexed user, uint256 quantity);

    modifier onlyAdmin() {
        require(msg.sender == owner, "Sorry! you are not admin"); 
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        owner = payable(msg.sender);  
    }
    
    function mint(uint256 _quantity) external payable {
        require(_quantity > 0 && _quantity <= MINT_LIMIT_PER_TRANSACTION, "quantity must be between 1 and 3");
        uint256 newTotalMinted = totalMinted + _quantity;
        require(newTotalMinted <= MAX_SUPPLY, "max supply done");
        require(userMints[msg.sender] + _quantity <= MAX_MINTS_PER_USER, "mint limit is already done");
        uint256 fee = _quantity * TRANSFER_FEE;
        require(msg.value >= fee, "insufficient feee");

        for (uint i = 0; i < _quantity; i++) {
            _tokenIds.increment();
            uint256 tokenId;
            unchecked {
                tokenId = _tokenIds.current();  
            }
            _safeMint(msg.sender, tokenId);  
            _userMintedIds[msg.sender].push(tokenId);  
        }

        totalMinted = newTotalMinted;  
        userMints[msg.sender] += _quantity;   
        payable(owner).transfer(fee);  
        emit Minted(msg.sender, _quantity);  
    }


}