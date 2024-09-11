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
    uint256 public constant TRANSFER_FEE = 100 wei;  
    address payable public owner; 

    uint256 public totalMinted;
    mapping(address => uint256) public userMints; 
    mapping(address => uint256[]) private _userMintedIds;  
    modifier onlyAdmin() {
        require(msg.sender == owner, "Sorry! you are not admin"); 
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        owner = payable(msg.sender);  
    }
    


}