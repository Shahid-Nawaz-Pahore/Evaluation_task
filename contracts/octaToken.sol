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
    bool public level1Open;  
    bool public level2Open;
    uint256 public totalMinted;
    mapping(address => uint256) public userMints; 
    mapping(address => uint256[]) private _userMintedIds;  

    event Minted(address indexed user, uint256 quantity);
    event LevelChanged(string levelState);
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

        function checkLevelStatus() internal {
        if (!level1Open && totalMinted >= 600) {
            level1Open = true;
            emit LevelChanged("Level 1 opened");
        }
        if (!level2Open && totalMinted >= 1200) {
            level2Open = true;
            emit LevelChanged("Level 2 opened");
        }
    }

    function openLevel(uint256 _level) external onlyAdmin {
        require(_level == 1 || _level == 2, "level number is just 1 and 2");
        if (_level == 1) {
            require(!level1Open, "level 1 is already open");
            require(totalMinted < 600, "cannot open Level 1 after 600 NFTs");
            level1Open = true;
            emit LevelChanged("level 1 opened");
        } else if (_level == 2) {
            require(!level2Open, "level 2 is already open");
            require(totalMinted >= 600 && totalMinted <= 1200, "cannot open Level 2 in this range");
            level2Open = true;
            emit LevelChanged("level 2 opened");
        }
    }

    function closeLevel(uint256 _level) external onlyAdmin {
        require(_level == 1 || _level == 2, "invalid level");
        if (_level == 1) {
            require(level1Open, "level 1 is already closed");
            level1Open = false;
            emit LevelChanged("level 1 closed");
        } else if (_level == 2) {
            require(level2Open, "level 2 is already closed");
            level2Open = false;
            emit LevelChanged("level 2 closed");
        }


    }





}