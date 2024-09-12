// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
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
    struct Level {
        bool isOpen;
        uint256 maxMinted;
        string name;
    }
    Level public level1 = Level({
        isOpen: false,
        maxMinted: 600,
        name: "Level 1"
    });
    Level public level2 = Level({
        isOpen: false,
        maxMinted: 1200,
        name: "Level 2"
    });
    mapping(address => uint256) public userMints;
    mapping(address => uint256[]) private _userMintedIds;
    event Minted(address indexed user, uint256 quantity);
    event LevelChanged(string levelName, bool isOpen);

    modifier onlyAdmin() {
        require(msg.sender == owner, "Sorry! you are not admin");
        _;
    }
    constructor() ERC721("OCTA Token", "OT") {
        owner = payable(msg.sender);
    }
    function mint(uint256 _quantity) external payable {
        require(_quantity > 0 && _quantity <= MINT_LIMIT_PER_TRANSACTION, "quantity must be between 1 and 3");
        uint256 newTotalMinted = totalMinted + _quantity;
        require(newTotalMinted <= MAX_SUPPLY, "max supply exceed");
        require(userMints[msg.sender] + _quantity <= MAX_MINTS_PER_USER, "mint limit is exceed");
        
        uint256 fee = _quantity * TRANSFER_FEE;
        require(msg.value >= fee, "insufficient fee");

        for (uint256 i = 0; i < _quantity; i++) {
            _tokenIds.increment();
            uint256 tokenId = _tokenIds.current();
            _safeMint(msg.sender, tokenId);
            _userMintedIds[msg.sender].push(tokenId);
        }
        totalMinted = newTotalMinted;
        userMints[msg.sender] += _quantity;
        payable(owner).transfer(fee);
        _checkAndOpenLevels();
        emit Minted(msg.sender, _quantity);
    }
    function openLevel(uint256 _level) external onlyAdmin {
        require(_level == 1 || _level == 2, "invalid level number");
        Level storage level = _level == 1 ? level1 : level2;
        require(!level.isOpen, "level is already open");
        require(totalMinted < level.maxMinted, "cannot open level after max NFTs minted");
        level.isOpen = true;
        emit LevelChanged(level.name, true);
    }
    function closeLevel(uint256 _level) external onlyAdmin {
        require(_level == 1 || _level == 2, "invalid level number");
        Level storage level = _level == 1 ? level1 : level2;
        require(level.isOpen, "level is already closed");
        level.isOpen = false;
        emit LevelChanged(level.name, false);
    }
    function viewMintedIds() external view returns (uint256[] memory ids) {
        return _userMintedIds[msg.sender];
    }
    function viewUserTotalMints() external view returns (uint256) {
        return userMints[msg.sender];
    }
    function _checkAndOpenLevels() internal {
        if (!level1.isOpen && totalMinted >= 600) {
            level1.isOpen = true;
            emit LevelChanged(level1.name, true);
        }
        if (!level2.isOpen && totalMinted >= 1200) {
            level2.isOpen = true;
            emit LevelChanged(level2.name, true);
        }
    }
}
