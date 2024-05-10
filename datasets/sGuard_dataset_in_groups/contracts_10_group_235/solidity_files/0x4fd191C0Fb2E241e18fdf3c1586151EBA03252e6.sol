pragma solidity 0.5.0;

interface IBurnableEtherLegendsToken {        
    function burn(uint256 tokenId) external;
}



pragma solidity 0.5.0;

interface IMintableEtherLegendsToken {        
    function mintTokenOfType(address to, uint256 idOfTokenType) external;
}



pragma solidity 0.5.0;

interface ITokenDefinitionManager {        
    function getNumberOfTokenDefinitions() external view returns (uint256);
    function hasTokenDefinition(uint256 tokenTypeId) external view returns (bool);
    function getTokenTypeNameAtIndex(uint256 index) external view returns (string memory);
    function getTokenTypeName(uint256 tokenTypeId) external view returns (string memory);
    function getTokenTypeId(string calldata name) external view returns (uint256);
    function getCap(uint256 tokenTypeId) external view returns (uint256);
    function getAbbreviation(uint256 tokenTypeId) external view returns (string memory);
}



pragma solidity ^0.5.0;


interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.0;



contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) public view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) public view returns (address owner);

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}



pragma solidity ^0.5.0;



contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}



pragma solidity ^0.5.0;



contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}



pragma solidity ^0.5.0;





contract IERC721Full is IERC721, IERC721Enumerable, IERC721Metadata {
    
}



pragma solidity 0.5.0;





contract IEtherLegendsToken is IERC721Full, IMintableEtherLegendsToken, IBurnableEtherLegendsToken, ITokenDefinitionManager {
    function totalSupplyOfType(uint256 tokenTypeId) external view returns (uint256);
    function getTypeIdOfToken(uint256 tokenId) external view returns (uint256);
}



pragma solidity 0.5.0;

interface IBoosterPack {        
    function getNumberOfCards() external view returns (uint256);
    function getCardTypeIdAtIndex(uint256 index) external view returns (uint256);
    function getPricePerCard() external view returns (uint256);
}



pragma solidity ^0.5.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.5.0;


contract ReentrancyGuard {
    
    uint256 private _guardCounter;

    constructor () internal {
        
        
        _guardCounter = 1;
    }

    
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}



pragma solidity 0.5.0;






contract BoosterPack is IBoosterPack, Ownable, ReentrancyGuard {

  
  address public payee;

  
  address public funder;

  
  address public permittedDestroyer;

  
  uint256 public pricePerCard = 50 finney;

  uint256[] public cardTypeIds;
  uint16 private totalWeight;
  mapping (uint16 => uint256) private rollToCard;
  mapping (uint256 => uint256) private cardToElementeumReturned;
  bytes32 private lastHash;

  IEtherLegendsToken public etherLegendsToken;
  IERC20 public elementeumToken;

  constructor(address payeeWallet, address funderWallet) public 
    Ownable() 
    ReentrancyGuard() {
    payee = payeeWallet;
    funder = funderWallet;
    lastHash = keccak256(abi.encodePacked(block.number));
  }

  
  function () external payable {
    purchaseCards(msg.sender);
  }

  function destroyContract() external {
    require(msg.sender == permittedDestroyer, "caller is not the permitted destroyer - should be address of BoosterPackFactory");
    address payable payableOwner = address(uint160(owner()));
    selfdestruct(payableOwner);
  }

  function setEtherLegendsToken(address addr) external {
    _requireOnlyOwner();
    etherLegendsToken = IEtherLegendsToken(addr);
  }  

  function setElementeumERC20ContractAddress(address addr) external {
    _requireOnlyOwner();
    elementeumToken = IERC20(addr);
  }    

  function setPricePerCard(uint256 price) public {
    _requireOnlyOwner();
    pricePerCard = price;
  }

  function permitDestruction(address addr) external {
    _requireOnlyOwner();
    require(addr != address(0));
    permittedDestroyer = addr;
  }

  function setDropWeights(uint256[] calldata tokenTypeIds, uint8[] calldata weights, uint256[] calldata elementeumsReturned) external {
    _requireOnlyOwner();
    require(
      tokenTypeIds.length > 0 && 
      tokenTypeIds.length == weights.length && 
      tokenTypeIds.length == elementeumsReturned.length, 
      "array lengths are not the same");

    for(uint256 i = 0; i < tokenTypeIds.length; i++) {
      setDropWeight(tokenTypeIds[i], weights[i], elementeumsReturned[i]);
    }    
  }

  function setDropWeight(uint256 tokenTypeId, uint8 weight, uint256 elementeumReturned) public {
    _requireOnlyOwner();    
    require(etherLegendsToken.hasTokenDefinition(tokenTypeId), "card is not defined");
    totalWeight += weight;
    for(uint16 i = totalWeight - weight; i < totalWeight; i++) {
      rollToCard[i] = tokenTypeId;
    }
    cardToElementeumReturned[tokenTypeId] = elementeumReturned;
    cardTypeIds.push(tokenTypeId);
  }

  function getNumberOfCards() external view returns (uint256) {
    return cardTypeIds.length;
  }

  function getCardTypeIdAtIndex(uint256 index) external view returns (uint256) {
    require(index < cardTypeIds.length, "Index Out Of Range");
    return cardTypeIds[index];
  }

  function getPricePerCard() external view returns (uint256) {
    return pricePerCard;
  }

  function getCardTypeIds() external view returns (uint256[] memory) {
    return cardTypeIds;
  }  

  function purchaseCards(address beneficiary) public payable nonReentrant {
    require(msg.sender == tx.origin, "caller must be transaction origin (only human)");    
    require(msg.value >= pricePerCard, "purchase price not met");
    require(pricePerCard > 0, "price per card must be greater than 0");
    require(totalWeight > 0, "total weight must be greater than 0");

    uint256 numberOfCards = _min(msg.value / pricePerCard, (gasleft() - 100000) / 200000);
    uint256 totalElementeumToReturn = 0;
    bytes32 tempLastHash =  lastHash;    
    for(uint256 i = 0; i < numberOfCards; i++) {
        tempLastHash = keccak256(abi.encodePacked(block.number, tempLastHash, msg.sender, gasleft()));
        uint16 randNumber = uint16(uint256(tempLastHash) % (totalWeight));        
        uint256 cardType = rollToCard[randNumber];

        etherLegendsToken.mintTokenOfType(beneficiary, cardType);        
        totalElementeumToReturn += cardToElementeumReturned[cardType];                
    }

    lastHash = tempLastHash; 
    
    if(totalElementeumToReturn > 0) {
      uint256 elementeumThatCanBeReturned = _min(totalElementeumToReturn, _min(elementeumToken.allowance(funder, address(this)), elementeumToken.balanceOf(funder)));
      if(elementeumThatCanBeReturned > 0) {
        elementeumToken.transferFrom(funder, beneficiary, elementeumThatCanBeReturned);      
      }            
    }

    uint256 change = msg.value - (pricePerCard * numberOfCards); 
    address payable payableWallet = address(uint160(payee));
    payableWallet.transfer(pricePerCard  * numberOfCards);
    if(change > 0) {
      msg.sender.transfer(change);
    }
  }

  function _min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }  

  function _requireOnlyOwner() internal view {
    require(isOwner(), "Ownable: caller is not the owner");
  }
}



pragma solidity 0.5.0;

interface IBoosterPackFactory {        
    function getNumberOfBoosterPacks() external view returns (uint256);
    function getBoosterPackAddressAtIndex(uint256 index) external view returns (address);
    function getBoosterPackNameAtIndex(uint256 index) external view returns (string memory);
    function getBoosterPackContractAddresses() external view returns (address[] memory);
    function getAddressOfBoosterPack(string calldata packName) external view returns (address);
}



pragma solidity 0.5.0;




contract BoosterPackFactory is IBoosterPackFactory, Ownable {
  
  address[] public boosterPackContracts;
  address public etherLegendsTokenAddress;
  address public elementeumTokenAddress;

  mapping (address => uint256) private boosterPackIndexMap;
  mapping (string => address) private boosterPackNameToAddressLookup;    
  mapping (address => string) private boosterPackAddressToNameLookup;      

  constructor() public 
    Ownable()
  {

  }    

  function() external payable {
    revert("Use of the fallback function is not permitted.");
  }

  function destroyContract() external {
    _requireOnlyOwner();
    require(boosterPackContracts.length == 0, "Cannot destroy the factory until all booster packs have been destroyed using destroyBoosterPack function.");
    address payable payableOwner = address(uint160(owner()));
    selfdestruct(payableOwner);
  }

  function createBoosterPack(uint256 pricePerCard, string calldata packName, address payeeWallet, address funderWallet) external {
    _requireOnlyOwner();
    require(bytes(packName).length < 32, "pack name may not exceed 31 characters");
    BoosterPack pack = new BoosterPack(payeeWallet, funderWallet);
    address packAddress = address(pack);    
    boosterPackIndexMap[packAddress] = boosterPackContracts.length;
    boosterPackNameToAddressLookup[packName] = packAddress;
    boosterPackAddressToNameLookup[packAddress] = packName;
    boosterPackContracts.push(packAddress);
    pack.setEtherLegendsToken(etherLegendsTokenAddress);
    pack.setElementeumERC20ContractAddress(elementeumTokenAddress);
    pack.setPricePerCard(pricePerCard);
    pack.permitDestruction(address(this));
    pack.transferOwnership(msg.sender);
  } 

  function destroyBoosterPack(address payable packAddress) public {
    _requireOnlyOwner();
    require(packAddress != address(0));

    uint256 indexOfBoosterPack = boosterPackIndexMap[packAddress];
    
    string memory packName = getNameOfBoosterPack(packAddress);
    bytes memory tempEmptyStringTest = bytes(packName);
    require(tempEmptyStringTest.length != 0, "Attempted to destroy a booster pack that does not exist.");
    
    BoosterPack pack = BoosterPack(packAddress);
    pack.destroyContract();

    address priorLastPackAddress = boosterPackContracts[boosterPackContracts.length - 1];
    boosterPackContracts[indexOfBoosterPack] = boosterPackContracts[boosterPackContracts.length - 1];
    boosterPackIndexMap[priorLastPackAddress] = indexOfBoosterPack;
    delete boosterPackContracts[boosterPackContracts.length - 1];
    boosterPackContracts.length--;
    boosterPackNameToAddressLookup[packName] = address(0);
    boosterPackAddressToNameLookup[packAddress] = "";        
    delete boosterPackIndexMap[packAddress];
  }

  function getNumberOfBoosterPacks() external view returns (uint256) {
    return boosterPackContracts.length;
  }

  function getBoosterPackAddressAtIndex(uint256 index) external view returns (address) {
    require(index < boosterPackContracts.length, "Index Out Of Range");
    return boosterPackContracts[index];
  }

  function getBoosterPackNameAtIndex(uint256 index) external view returns (string memory) {
    require(index < boosterPackContracts.length, "Index Out Of Range");
    return boosterPackAddressToNameLookup[boosterPackContracts[index]];
  }
    
  function getBoosterPackContractAddresses() external view returns (address[] memory) {
    return boosterPackContracts;
  }  

  function getAddressOfBoosterPack(string calldata packName) external view returns (address) {
    return boosterPackNameToAddressLookup[packName];
  }

  function getNameOfBoosterPack(address packAddress) public view returns (string memory) {
    return boosterPackAddressToNameLookup[packAddress];
  }

  function setEtherLegendsToken(address addr) external {
    _requireOnlyOwner();
    etherLegendsTokenAddress = addr;
  }    

  function setElementeumERC20ContractAddress(address addr) external {
    _requireOnlyOwner();
    elementeumTokenAddress = addr;
  }    

  function _requireOnlyOwner() internal view {
    require(isOwner(), "Ownable: caller is not the owner");
  }
}