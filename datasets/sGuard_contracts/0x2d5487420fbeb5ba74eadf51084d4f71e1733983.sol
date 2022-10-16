pragma solidity 0.5.12;





interface IERC721 {


  
  
  
  
  
  event Transfer(address indexed _from, address indexed _to, uint indexed _tokenId);

  
  
  
  
  event Approval(address indexed _owner, address indexed _approved, uint indexed _tokenId);

  
  
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  
  
  
  
  
  
  
  
  
  
  function transferFrom(address _from, address _to, uint _tokenId) external;

  
  
  
  
  
  
  function approve(address _approved, uint _tokenId) external payable;

  
  
  
  
  
  
  
  
  
  
  
  
  function safeTransferFrom(address _from, address _to, uint _tokenId, bytes calldata data) external;

  
  
  
  
  
  
  function safeTransferFrom(address _from, address _to, uint _tokenId) external;

  
  
  
  
  
  
  function setApprovalForAll(address _operator, bool _approved) external;

  
  
  
  
  
  function balanceOf(address _owner) external view returns (uint);

  
  
  
  
  
  function ownerOf(uint _tokenId) external view returns (address);

  
  
  
  
  function getApproved(uint _tokenId) external view returns (address);

  
  
  
  
  function isApprovedForAll(address _owner, address _operator) external view returns (bool);

  
  function name() external view returns (string memory _name);
}



pragma solidity 0.5.12;


interface IERC721Enumerable
{
  function totalSupply(
  ) external view
    returns (uint256);

  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  ) external view
    returns (uint256 _tokenId);

  function tokenByIndex(
    uint256 _index
  ) external view
    returns (uint256);
}



pragma solidity ^0.5.0;






contract IPublicLock is IERC721Enumerable, IERC721 {





  
  
  event Destroy(
    uint balance,
    address indexed owner
  );

  event Disable();

  event Withdrawal(
    address indexed sender,
    address indexed tokenAddress,
    address indexed beneficiary,
    uint amount
  );

  event CancelKey(
    uint indexed tokenId,
    address indexed owner,
    address indexed sendTo,
    uint refund
  );

  event RefundPenaltyChanged(
    uint freeTrialLength,
    uint refundPenaltyBasisPoints
  );

  event PriceChanged(
    uint oldKeyPrice,
    uint keyPrice
  );

  event ExpireKey(uint indexed tokenId);

  event NewLockSymbol(
    string symbol
  );

  event TransferFeeChanged(
    uint transferFeeBasisPoints
  );

  
  event NonceChanged(
    address indexed keyOwner,
    uint nextAvailableNonce
  );
  

  

  
  function publicLockVersion() public pure returns (uint);

  
  function getBalance(
    address _tokenAddress,
    address _account
  ) external view
    returns (uint);

  
  function disableLock() external;

  
  function destroyLock() external;

  
  function withdraw(
    address _tokenAddress,
    uint _amount
  ) external;

  
  function updateKeyPrice( uint _keyPrice ) external;

  
  function updateBeneficiary( address _beneficiary ) external;

  
  function expireKeyFor( address _owner ) external;

    
  function getHasValidKey(
    address _owner
  ) external view returns (bool);

  
  function getTokenIdFor(
    address _account
  ) external view returns (uint);

  
  function getOwnersByPage(
    uint _page,
    uint _pageSize
  ) external view returns (address[] memory);

  
  function isKeyOwner(
    uint _tokenId,
    address _owner
  ) external view returns (bool);

  
  function keyExpirationTimestampFor(
    address _owner
  ) external view returns (uint timestamp);

  
  function numberOfOwners() external view returns (uint);

  
  function updateLockName(
    string calldata _lockName
  ) external;

  
  function updateLockSymbol(
    string calldata _lockSymbol
  ) external;

  
  function symbol()
    external view
    returns(string memory);

    
  function setBaseTokenURI(
    string calldata _baseTokenURI
  ) external;

  
  function tokenURI(
    uint256 _tokenId
  ) external view returns(string memory);

  
  function grantKeys(
    address[] calldata _recipients,
    uint[] calldata _expirationTimestamps
  ) external;

  
  function purchase(
    uint256 _value,
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external payable;

  
  function updateTransferFee(
    uint _transferFeeBasisPoints
  ) external;

  
  function getTransferFee(
    address _owner,
    uint _time
  ) external view returns (uint);

  
  function fullRefund(
    address _keyOwner,
    uint amount
  ) external;

  
  function cancelAndRefund() external;

  
  function cancelAndRefundFor(
    address _keyOwner,
    bytes calldata _signature
  ) external;

  
  function invalidateOffchainApproval(
    uint _nextAvailableNonce
  ) external;

  
  function updateRefundPenalty(
    uint _freeTrialLength,
    uint _refundPenaltyBasisPoints
  ) external;

  
  function getCancelAndRefundValueFor(
    address _owner
  ) external view returns (uint refund);

  function keyOwnerToNonce(address ) external view returns (uint256 );

  
  function getCancelAndRefundApprovalHash(
    address _keyOwner,
    address _txSender
  ) external view returns (bytes32 approvalHash);

  
  

  function beneficiary() external view returns (address );

  function erc1820() external view returns (address );

  function expirationDuration() external view returns (uint256 );

  function freeTrialLength() external view returns (uint256 );

  function isAlive() external view returns (bool );

  function keyCancelInterfaceId() external view returns (bytes32 );

  function keySoldInterfaceId() external view returns (bytes32 );

  function keyPrice() external view returns (uint256 );

  function maxNumberOfKeys() external view returns (uint256 );

  function owners(uint256 ) external view returns (address );

  function refundPenaltyBasisPoints() external view returns (uint256 );

  function tokenAddress() external view returns (address );

  function transferFeeBasisPoints() external view returns (uint256 );

  function unlockProtocol() external view returns (address );

  function BASIS_POINTS_DEN() external view returns (uint256 );
  

  
  function shareKey(
    address _to,
    uint _tokenId,
    uint _timeShared
  ) external;

  
  function name() external view returns (string memory _name);
  

  
  function owner() external view returns (address );

  function isOwner() external view returns (bool );

  function renounceOwnership() external;

  function transferOwnership(address newOwner) external;
  

  
  function supportsInterface(bytes4 interfaceId) external view returns (bool );
  

}



pragma solidity >=0.4.24 <0.6.0;



contract Initializable {

  
  bool private initialized;

  
  bool private initializing;

  
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
    
    
    
    
    
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}



pragma solidity ^0.5.0;



contract Context is Initializable {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.5.0;




contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function initialize(address sender) public initializer {
        _owner = sender;
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
        return _msgSender() == _owner;
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

    uint256[50] private ______gap;
}



pragma solidity ^0.5.0;


interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.0;




contract ERC165 is Initializable, IERC165 {
    
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    
    mapping(bytes4 => bool) private _supportedInterfaces;

    function initialize() public initializer {
        
        
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[50] private ______gap;
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



pragma solidity ^0.5.5;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}



pragma solidity ^0.5.0;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.5.0;





library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity 0.5.12;






contract MixinFunds
{
  using Address for address payable;
  using SafeERC20 for IERC20;

  
  address public tokenAddress;

  function initialize(
    address _tokenAddress
  ) public
  {
    tokenAddress = _tokenAddress;
    require(
      _tokenAddress == address(0) || IERC20(_tokenAddress).totalSupply() > 0,
      'INVALID_TOKEN'
    );
  }

  
  function getBalance(
    address _tokenAddress,
    address _account
  ) public view
    returns (uint)
  {
    if(_tokenAddress == address(0)) {
      return _account.balance;
    } else {
      return IERC20(_tokenAddress).balanceOf(_account);
    }
  }

  
  function _chargeAtLeast(
    uint _price
  ) internal returns (uint)
  {
    if(_price > 0) {
      if(tokenAddress == address(0)) {
        require(msg.value >= _price, 'NOT_ENOUGH_FUNDS');
        return msg.value;
      } else {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), _price);
        return _price;
      }
    }
  }

  
  function _transfer(
    address _tokenAddress,
    address _to,
    uint _amount
  ) internal
  {
    if(_amount > 0) {
      if(_tokenAddress == address(0)) {
        
        address(uint160(_to)).sendValue(_amount);
      } else {
        IERC20 token = IERC20(_tokenAddress);
        token.safeTransfer(_to, _amount);
      }
    }
  }
}



pragma solidity 0.5.12;





contract MixinDisableAndDestroy is
  IERC721,
  Ownable,
  MixinFunds
{
  
  bool public isAlive;

  event Destroy(
    uint balance,
    address indexed owner
  );

  event Disable();

  function initialize(
  ) public
  {
    isAlive = true;
  }

  
  modifier onlyIfAlive() {
    require(isAlive, 'LOCK_DEPRECATED');
    _;
  }

  
  function disableLock()
    external
    onlyOwner
    onlyIfAlive
  {
    emit Disable();
    isAlive = false;
  }

  
  function destroyLock()
    external
    onlyOwner
  {
    require(isAlive == false, 'DISABLE_FIRST');

    emit Destroy(address(this).balance, msg.sender);

    
    _transfer(tokenAddress, msg.sender, getBalance(tokenAddress, address(this)));
    selfdestruct(msg.sender);

    
    
  }

}



pragma solidity 0.5.12;




interface IUnlock {


  
  event NewLock(
    address indexed lockOwner,
    address indexed newLockAddress
  );

  event ConfigUnlock(
    address publicLockAddress,
    string globalTokenSymbol,
    string globalTokenURI
  );

  event ResetTrackedValue(
    uint grossNetworkProduct,
    uint totalDiscountGranted
  );

  
  function initialize(address _owner) external;

  
  function createLock(
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName,
    bytes12 _salt
  ) external;

    
  function recordKeyPurchase(
    uint _value,
    address _referrer 
  )
    external;

    
  function recordConsumedDiscount(
    uint _discount,
    uint _tokens 
  )
    external;

    
  function computeAvailableDiscountFor(
    address _purchaser, 
    uint _keyPrice 
  )
    external
    view
    returns (uint discount, uint tokens);

  
  function globalBaseTokenURI()
    external
    view
    returns (string memory);

  
  function globalTokenSymbol()
    external
    view
    returns (string memory);

  
  function configUnlock(
    address _publicLockAddress,
    string calldata _symbol,
    string calldata _URI
  )
    external;

  
  function resetTrackedValue(
    uint _grossNetworkProduct,
    uint _totalDiscountGranted
  ) external;
}



pragma solidity 0.5.12;







contract MixinLockCore is
  Ownable,
  MixinFunds,
  MixinDisableAndDestroy
{
  event PriceChanged(
    uint oldKeyPrice,
    uint keyPrice
  );

  event Withdrawal(
    address indexed sender,
    address indexed tokenAddress,
    address indexed beneficiary,
    uint amount
  );

  
  
  IUnlock public unlockProtocol;

  
  
  
  uint public expirationDuration;

  
  
  uint public keyPrice;

  
  uint public maxNumberOfKeys;

  
  uint public totalSupply;

  
  address public beneficiary;

  
  uint public constant BASIS_POINTS_DEN = 10000;

  
  modifier notSoldOut() {
    require(maxNumberOfKeys > totalSupply, 'LOCK_SOLD_OUT');
    _;
  }

  modifier onlyOwnerOrBeneficiary()
  {
    require(
      msg.sender == owner() || msg.sender == beneficiary,
      'ONLY_LOCK_OWNER_OR_BENEFICIARY'
    );
    _;
  }

  function initialize(
    address _beneficiary,
    uint _expirationDuration,
    uint _keyPrice,
    uint _maxNumberOfKeys
  ) internal
  {
    require(_expirationDuration <= 100 * 365 * 24 * 60 * 60, 'MAX_EXPIRATION_100_YEARS');
    unlockProtocol = IUnlock(msg.sender); 
    beneficiary = _beneficiary;
    expirationDuration = _expirationDuration;
    keyPrice = _keyPrice;
    maxNumberOfKeys = _maxNumberOfKeys;
  }

  
  function publicLockVersion(
  ) public pure
    returns (uint)
  {
    return 5;
  }

  
  function withdraw(
    address _tokenAddress,
    uint _amount
  ) external
    onlyOwnerOrBeneficiary
  {
    uint balance = getBalance(_tokenAddress, address(this));
    uint amount;
    if(_amount == 0 || _amount > balance)
    {
      require(balance > 0, 'NOT_ENOUGH_FUNDS');
      amount = balance;
    }
    else
    {
      amount = _amount;
    }

    emit Withdrawal(msg.sender, _tokenAddress, beneficiary, amount);
    
    _transfer(_tokenAddress, beneficiary, amount);
  }

  
  function updateKeyPrice(
    uint _keyPrice
  )
    external
    onlyOwner
    onlyIfAlive
  {
    uint oldKeyPrice = keyPrice;
    keyPrice = _keyPrice;
    emit PriceChanged(oldKeyPrice, keyPrice);
  }

  
  function updateBeneficiary(
    address _beneficiary
  ) external
    onlyOwnerOrBeneficiary
  {
    require(_beneficiary != address(0), 'INVALID_ADDRESS');
    beneficiary = _beneficiary;
  }
}



pragma solidity 0.5.12;





contract MixinKeys is
  Ownable,
  MixinLockCore
{
  
  struct Key {
    uint tokenId;
    uint expirationTimestamp;
  }

  
  event ExpireKey(uint indexed tokenId);

  
  
  
  
  mapping (address => Key) internal keyByOwner;

  
  
  
  
  mapping (uint => address) public ownerOf;

  
  
  address[] public owners;

  
  modifier ownsOrHasOwnedKey(
    address _owner
  ) {
    require(
      keyByOwner[_owner].expirationTimestamp > 0, 'HAS_NEVER_OWNED_KEY'
    );
    _;
  }

  
  modifier hasValidKey(
    address _owner
  ) {
    require(
      getHasValidKey(_owner), 'KEY_NOT_VALID'
    );
    _;
  }

  
  modifier isKey(
    uint _tokenId
  ) {
    require(
      ownerOf[_tokenId] != address(0), 'NO_SUCH_KEY'
    );
    _;
  }

  
  modifier onlyKeyOwner(
    uint _tokenId
  ) {
    require(
      isKeyOwner(_tokenId, msg.sender), 'ONLY_KEY_OWNER'
    );
    _;
  }

  
  function expireKeyFor(
    address _owner
  )
    public
    onlyOwner
    hasValidKey(_owner)
  {
    Key storage key = keyByOwner[_owner];
    key.expirationTimestamp = block.timestamp; 
    emit ExpireKey(key.tokenId);
  }

  
  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint)
  {
    require(_owner != address(0), 'INVALID_ADDRESS');
    return getHasValidKey(_owner) ? 1 : 0;
  }

  
  function getHasValidKey(
    address _owner
  )
    public
    view
    returns (bool)
  {
    return keyByOwner[_owner].expirationTimestamp > block.timestamp;
  }

  
  function getTokenIdFor(
    address _account
  )
    public view
    hasValidKey(_account)
    returns (uint)
  {
    return keyByOwner[_account].tokenId;
  }

 
  function getOwnersByPage(uint _page, uint _pageSize)
    public
    view
    returns (address[] memory)
  {
    require(owners.length > 0, 'NO_OUTSTANDING_KEYS');
    uint pageSize = _pageSize;
    uint _startIndex = _page * pageSize;
    uint endOfPageIndex;

    if (_startIndex + pageSize > owners.length) {
      endOfPageIndex = owners.length;
      pageSize = owners.length - _startIndex;
    } else {
      endOfPageIndex = (_startIndex + pageSize);
    }

    
    address[] memory ownersByPage = new address[](pageSize);
    uint pageIndex = 0;

    
    for (uint i = _startIndex; i < endOfPageIndex; i++) {
      ownersByPage[pageIndex] = owners[i];
      pageIndex++;
    }

    return ownersByPage;
  }

  
  function isKeyOwner(
    uint _tokenId,
    address _owner
  ) public view
    returns (bool)
  {
    return ownerOf[_tokenId] == _owner;
  }

  
  function keyExpirationTimestampFor(
    address _owner
  )
    public view
    ownsOrHasOwnedKey(_owner)
    returns (uint timestamp)
  {
    return keyByOwner[_owner].expirationTimestamp;
  }

  
  function numberOfOwners()
    public
    view
    returns (uint)
  {
    return owners.length;
  }

  
  function _assignNewTokenId(
    Key storage _key
  ) internal
  {
    if (_key.tokenId == 0) {
      
      
      totalSupply++;
      
      _key.tokenId = totalSupply;
    }
  }

  
  function _recordOwner(
    address _owner,
    uint _tokenId
  ) internal
  {
    if (ownerOf[_tokenId] != _owner) {
      
      owners.push(_owner);
      
      ownerOf[_tokenId] = _owner;
    }
  }
}



pragma solidity 0.5.12;






contract MixinApproval is
  IERC721,
  MixinDisableAndDestroy,
  MixinKeys
{
  
  
  
  
  
  
  
  mapping (uint => address) private approved;

  
  
  
  mapping (address => mapping (address => bool)) private ownerToOperatorApproved;

  
  
  
  modifier onlyKeyOwnerOrApproved(
    uint _tokenId
  ) {
    require(
      isKeyOwner(_tokenId, msg.sender) ||
        _isApproved(_tokenId, msg.sender) ||
        isApprovedForAll(ownerOf[_tokenId], msg.sender),
      'ONLY_KEY_OWNER_OR_APPROVED');
    _;
  }

  
  function approve(
    address _approved,
    uint _tokenId
  )
    external
    payable
    onlyIfAlive
    onlyKeyOwnerOrApproved(_tokenId)
  {
    require(msg.sender != _approved, 'APPROVE_SELF');

    approved[_tokenId] = _approved;
    emit Approval(ownerOf[_tokenId], _approved, _tokenId);
  }

  
  function setApprovalForAll(
    address _to,
    bool _approved
  ) external
    onlyIfAlive
  {
    require(_to != msg.sender, 'APPROVE_SELF');
    ownerToOperatorApproved[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  
  function getApproved(
    uint _tokenId
  ) external view
    returns (address)
  {
    address approvedRecipient = approved[_tokenId];
    require(approvedRecipient != address(0), 'NONE_APPROVED');
    return approvedRecipient;
  }

  
  function isApprovedForAll(
    address _owner,
    address _operator
  ) public view
    returns (bool)
  {
    return ownerToOperatorApproved[_owner][_operator];
  }

  
  function _isApproved(
    uint _tokenId,
    address _user
  ) internal view
    returns (bool)
  {
    return approved[_tokenId] == _user;
  }

  
  function _clearApproval(
    uint256 _tokenId
  ) internal
  {
    if (approved[_tokenId] != address(0)) {
      approved[_tokenId] = address(0);
    }
  }
}



pragma solidity 0.5.12;







contract MixinERC721Enumerable is
  IERC721Enumerable,
  ERC165,
  MixinLockCore, 
  MixinKeys
{
  function initialize() public
  {
    
    _registerInterface(0x780e9d63);
  }

  
  
  
  
  
  function tokenByIndex(
    uint256 _index
  ) external view
    returns (uint256)
  {
    require(_index < totalSupply, 'OUT_OF_RANGE');
    return _index;
  }

  
  
  
  
  
  
  
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  ) external view
    returns (uint256)
  {
    require(_index == 0, 'ONLY_ONE_KEY_PER_OWNER');
    return getTokenIdFor(_owner);
  }
}



pragma solidity 0.5.12;


interface IUnlockEventHooks {
  
  function keySold(
    address from,
    address to,
    address referrer,
    uint256 pricePaid,
    bytes calldata data
  ) external;

  
  function keyCancel(
    address operator,
    address to,
    uint256 refund
  ) external;
}



pragma solidity ^0.5.0;


interface IERC1820Registry {
    
    function setManager(address account, address newManager) external;

    
    function getManager(address account) external view returns (address);

    
    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;

    
    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);

    
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}



pragma solidity 0.5.12;






contract MixinEventHooks is
  MixinLockCore
{
  IERC1820Registry public constant erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  
  bytes32 public constant keySoldInterfaceId = 0x4d99da10ff5120f726d35edd8dbd417bbe55d90453b8432acd284e650ee2c6f0;

  
  bytes32 public constant keyCancelInterfaceId = 0xd6342b4bfdf66164985c9f5fe235f643a035ee12f507d7bd0f8c89e07e790f68;

  
  function _onKeySold(
    address _to,
    address _referrer,
    uint256 _pricePaid,
    bytes memory _data
  ) internal
  {
    address implementer = erc1820.getInterfaceImplementer(beneficiary, keySoldInterfaceId);
    if(implementer != address(0))
    {
      IUnlockEventHooks(implementer).keySold(msg.sender, _to, _referrer, _pricePaid, _data);
    }
  }

  
  function _onKeyCancel(
    address _to,
    uint256 _refund
  ) internal
  {
    address implementer = erc1820.getInterfaceImplementer(beneficiary, keyCancelInterfaceId);
    if(implementer != address(0))
    {
      IUnlockEventHooks(implementer).keyCancel(msg.sender, _to, _refund);
    }
  }
}



pragma solidity 0.5.12;






contract MixinGrantKeys is
  IERC721,
  Ownable,
  MixinKeys
{
  
  function grantKeys(
    address[] calldata _recipients,
    uint[] calldata _expirationTimestamps
  ) external
    onlyOwner
  {
    for(uint i = 0; i < _recipients.length; i++) {
      address recipient = _recipients[i];
      uint expirationTimestamp = _expirationTimestamps[i];

      require(recipient != address(0), 'INVALID_ADDRESS');

      Key storage toKey = keyByOwner[recipient];
      require(expirationTimestamp > toKey.expirationTimestamp, 'ALREADY_OWNS_KEY');

      _assignNewTokenId(toKey);
      _recordOwner(recipient, toKey.tokenId);
      toKey.expirationTimestamp = expirationTimestamp;

      
      emit Transfer(
        address(0), 
        recipient,
        toKey.tokenId
      );
    }
  }
}



pragma solidity 0.5.12;





library UnlockUtils {

  function strConcat(
    string memory _a,
    string memory _b,
    string memory _c,
    string memory _d
  ) internal pure
    returns (string memory _concatenatedString)
  {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    string memory abcd = new string(_ba.length + _bb.length + _bc.length + _bd.length);
    bytes memory babcd = bytes(abcd);
    uint k = 0;
    uint i = 0;
    for (i = 0; i < _ba.length; i++) {
      babcd[k++] = _ba[i];
    }
    for (i = 0; i < _bb.length; i++) {
      babcd[k++] = _bb[i];
    }
    for (i = 0; i < _bc.length; i++) {
      babcd[k++] = _bc[i];
    }
    for (i = 0; i < _bd.length; i++) {
      babcd[k++] = _bd[i];
    }
    return string(babcd);
  }

  function uint2Str(
    uint _i
  ) internal pure
    returns (string memory _uintAsString)
  {
    
    uint c = _i;
    if (_i == 0) {
      return '0';
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (c != 0) {
      bstr[k--] = byte(uint8(48 + c % 10));
      c /= 10;
    }
    return string(bstr);
  }

  function address2Str(
    address _addr
  ) internal pure
    returns(string memory)
  {
    bytes32 value = bytes32(uint256(_addr));
    bytes memory alphabet = '0123456789abcdef';
    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint i = 0; i < 20; i++) {
      str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
      str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
    return string(str);
  }
}



pragma solidity 0.5.12;








contract MixinLockMetadata is
  IERC721,
  ERC165,
  Ownable,
  MixinLockCore,
  MixinKeys
{
  using UnlockUtils for uint;
  using UnlockUtils for address;
  using UnlockUtils for string;

  
  string public name;

  
  string private lockSymbol;

  
  string private baseTokenURI;

  event NewLockSymbol(
    string symbol
  );

  function initialize(
    string memory _lockName
  ) internal
  {
    ERC165.initialize();
    name = _lockName;
    
    
    _registerInterface(0x5b5e139f);
  }

  
  function updateLockName(
    string calldata _lockName
  ) external
    onlyOwner
  {
    name = _lockName;
  }

  
  function updateLockSymbol(
    string calldata _lockSymbol
  ) external
    onlyOwner
  {
    lockSymbol = _lockSymbol;
    emit NewLockSymbol(_lockSymbol);
  }

  
  function symbol()
    external view
    returns(string memory)
  {
    if(bytes(lockSymbol).length == 0) {
      return unlockProtocol.globalTokenSymbol();
    } else {
      return lockSymbol;
    }
  }

  
  function setBaseTokenURI(
    string calldata _baseTokenURI
  ) external
    onlyOwner
  {
    baseTokenURI = _baseTokenURI;
  }

  
  function tokenURI(
    uint256 _tokenId
  ) external
    view
    isKey(_tokenId)
    returns(string memory)
  {
    string memory URI;
    if(bytes(baseTokenURI).length == 0) {
      URI = unlockProtocol.globalBaseTokenURI();
    } else {
      URI = baseTokenURI;
    }

    return URI.strConcat(
      address(this).address2Str(),
      '/',
      _tokenId.uint2Str()
    );
  }
}



pragma solidity 0.5.12;









contract MixinPurchase is
  MixinFunds,
  MixinDisableAndDestroy,
  MixinLockCore,
  MixinKeys,
  MixinEventHooks
{
  using SafeMath for uint;

  
  function purchase(
    uint256 _value,
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external payable
    onlyIfAlive
    notSoldOut
  {
    require(_recipient != address(0), 'INVALID_ADDRESS');

    
    Key storage toKey = keyByOwner[_recipient];

    if (toKey.tokenId == 0) {
      
      _assignNewTokenId(toKey);
      _recordOwner(_recipient, toKey.tokenId);
    }

    if (toKey.expirationTimestamp >= block.timestamp) {
      
      toKey.expirationTimestamp = toKey.expirationTimestamp.add(expirationDuration);
    } else {
      
      
      toKey.expirationTimestamp = block.timestamp + expirationDuration;
    }

    
    uint discount;
    uint tokens;
    uint inMemoryKeyPrice = keyPrice;
    (discount, tokens) = unlockProtocol.computeAvailableDiscountFor(_recipient, inMemoryKeyPrice);

    if (discount > inMemoryKeyPrice) {
      inMemoryKeyPrice = 0;
    } else {
      
      inMemoryKeyPrice -= discount;
    }

    if (discount > 0) {
      unlockProtocol.recordConsumedDiscount(discount, tokens);
    }

    unlockProtocol.recordKeyPurchase(inMemoryKeyPrice, getHasValidKey(_referrer) ? _referrer : address(0));

    
    emit Transfer(
      address(0), 
      _recipient,
      toKey.tokenId
    );

    
    if(tokenAddress != address(0)) {
      require(_value >= inMemoryKeyPrice, 'INSUFFICIENT_VALUE');
      inMemoryKeyPrice = _value;
    }
    
    uint pricePaid = _chargeAtLeast(inMemoryKeyPrice);

    
    _onKeySold(_recipient, _referrer, pricePaid, _data);
  }
}



pragma solidity ^0.5.0;


library ECDSA {
    
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        
        if (signature.length != 65) {
            return (address(0));
        }

        
        bytes32 r;
        bytes32 s;
        uint8 v;

        
        
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        
        
        
        
        
        
        
        
        
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        
        return ecrecover(hash, v, r, s);
    }

    
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        
        
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}



pragma solidity 0.5.12;



contract MixinSignatures
{
  
  event NonceChanged(
    address indexed keyOwner,
    uint nextAvailableNonce
  );

  
  mapping(address => uint) public keyOwnerToNonce;

  
  
  modifier consumeOffchainApproval(
    bytes32 _hash,
    bytes memory _signature,
    address _keyOwner
  )
  {
    require(
      ECDSA.recover(
        ECDSA.toEthSignedMessageHash(_hash),
        _signature
      ) == _keyOwner, 'INVALID_SIGNATURE'
    );
    keyOwnerToNonce[_keyOwner]++;
    emit NonceChanged(_keyOwner, keyOwnerToNonce[_keyOwner]);
    _;
  }

  
  function invalidateOffchainApproval(
    uint _nextAvailableNonce
  ) external
  {
    require(_nextAvailableNonce > keyOwnerToNonce[msg.sender], 'NONCE_ALREADY_USED');
    keyOwnerToNonce[msg.sender] = _nextAvailableNonce;
    emit NonceChanged(msg.sender, _nextAvailableNonce);
  }
}



pragma solidity 0.5.12;









contract MixinRefunds is
  Ownable,
  MixinSignatures,
  MixinFunds,
  MixinLockCore,
  MixinKeys,
  MixinEventHooks
{
  using SafeMath for uint;

  
  
  uint public refundPenaltyBasisPoints;

  uint public freeTrialLength;

  event CancelKey(
    uint indexed tokenId,
    address indexed owner,
    address indexed sendTo,
    uint refund
  );

  event RefundPenaltyChanged(
    uint freeTrialLength,
    uint refundPenaltyBasisPoints
  );

  function initialize() public
  {
    
    refundPenaltyBasisPoints = 1000;
  }

  
  function fullRefund(address _keyOwner, uint amount)
    external
    onlyOwner
    hasValidKey(_keyOwner)
  {
    _cancelAndRefund(_keyOwner, amount);
  }

  
  function cancelAndRefund()
    external
  {
    uint refund = _getCancelAndRefundValue(msg.sender);

    _cancelAndRefund(msg.sender, refund);
  }

  
  function cancelAndRefundFor(
    address _keyOwner,
    bytes calldata _signature
  ) external
    consumeOffchainApproval(getCancelAndRefundApprovalHash(_keyOwner, msg.sender), _signature, _keyOwner)
  {
    uint refund = _getCancelAndRefundValue(_keyOwner);

    _cancelAndRefund(_keyOwner, refund);
  }

  
  function updateRefundPenalty(
    uint _freeTrialLength,
    uint _refundPenaltyBasisPoints
  )
    external
    onlyOwner
  {
    emit RefundPenaltyChanged(
      _freeTrialLength,
      _refundPenaltyBasisPoints
    );

    freeTrialLength = _freeTrialLength;
    refundPenaltyBasisPoints = _refundPenaltyBasisPoints;
  }

  
  function getCancelAndRefundValueFor(
    address _owner
  )
    external view
    returns (uint refund)
  {
    return _getCancelAndRefundValue(_owner);
  }

  
  function getCancelAndRefundApprovalHash(
    address _keyOwner,
    address _txSender
  ) public view
    returns (bytes32 approvalHash)
  {
    return keccak256(
      abi.encodePacked(
        
        address(this),
        
        keyOwnerToNonce[_keyOwner],
        
        _txSender
      )
    );
  }

  
  function _cancelAndRefund(
    address _keyOwner,
    uint refund
  ) internal
  {
    Key storage key = keyByOwner[_keyOwner];

    emit CancelKey(key.tokenId, _keyOwner, msg.sender, refund);
    
    
    key.expirationTimestamp = block.timestamp;

    if (refund > 0) {
      
      _transfer(tokenAddress, _keyOwner, refund);
    }

    _onKeyCancel(_keyOwner, refund);
  }

  
  function _getCancelAndRefundValue(
    address _owner
  )
    private view
    hasValidKey(_owner)
    returns (uint refund)
  {
    Key storage key = keyByOwner[_owner];
    
    uint timeRemaining = key.expirationTimestamp - block.timestamp;
    if(timeRemaining + freeTrialLength >= expirationDuration) {
      refund = keyPrice;
    } else {
      
      refund = keyPrice.mul(timeRemaining) / expirationDuration;
    }

    
    if(freeTrialLength == 0 || timeRemaining + freeTrialLength < expirationDuration)
    {
      uint penalty = keyPrice.mul(refundPenaltyBasisPoints) / BASIS_POINTS_DEN;
      if (refund > penalty) {
        
        refund -= penalty;
      } else {
        refund = 0;
      }
    }
  }
}



pragma solidity ^0.5.0;


contract IERC721Receiver {
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}



pragma solidity 0.5.12;











contract MixinTransfer is
  MixinFunds,
  MixinLockCore,
  MixinKeys,
  MixinApproval
{
  using SafeMath for uint;
  using Address for address;

  event TransferFeeChanged(
    uint transferFeeBasisPoints
  );

  event TimestampChanged(
    uint indexed _tokenId,
    uint _amount,
    bool _timeAdded
  );

  
  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

  
  
  
  uint public transferFeeBasisPoints;

  
  function shareKey(
    address _to,
    uint _tokenId,
    uint _timeShared
  ) public
    onlyIfAlive
    onlyKeyOwnerOrApproved(_tokenId)
  {
    require(transferFeeBasisPoints < BASIS_POINTS_DEN, 'KEY_TRANSFERS_DISABLED');
    require(_to != address(0), 'INVALID_ADDRESS');
    address keyOwner = ownerOf[_tokenId];
    require(getHasValidKey(keyOwner), 'KEY_NOT_VALID');
    Key storage fromKey = keyByOwner[keyOwner];
    Key storage toKey = keyByOwner[_to];
    uint iDTo = toKey.tokenId;
    uint time;
    
    uint timeRemaining = fromKey.expirationTimestamp - block.timestamp;
    
    uint fee = getTransferFee(keyOwner, _timeShared);
    uint timePlusFee = _timeShared.add(fee);

    
    if(timePlusFee < timeRemaining) {
      
      time = _timeShared;
      
      _timeMachine(_tokenId, timePlusFee, false);
    } else {
      
      fee = getTransferFee(keyOwner, timeRemaining);
      time = timeRemaining - fee;
      fromKey.expirationTimestamp = block.timestamp; 
      emit ExpireKey(_tokenId);
    }

    if (toKey.tokenId == 0) {
      _assignNewTokenId(toKey);
      _recordOwner(_to, iDTo);
      emit Transfer(
        address(0), 
        _to,
        iDTo
      );
    }
    
    _timeMachine(iDTo, time, true);
    
    emit Transfer(
      keyOwner,
      _to,
      iDTo
    );

    require(_checkOnERC721Received(keyOwner, _to, _tokenId, ''), 'NON_COMPLIANT_ERC721_RECEIVER');
  }

  function transferFrom(
    address _from,
    address _recipient,
    uint _tokenId
  )
    public
    onlyIfAlive
    hasValidKey(_from)
    onlyKeyOwnerOrApproved(_tokenId)
  {
    require(transferFeeBasisPoints < BASIS_POINTS_DEN, 'KEY_TRANSFERS_DISABLED');
    require(_recipient != address(0), 'INVALID_ADDRESS');
    uint fee = getTransferFee(_from, 0);

    Key storage fromKey = keyByOwner[_from];
    Key storage toKey = keyByOwner[_recipient];
    uint id = fromKey.tokenId;

    uint previousExpiration = toKey.expirationTimestamp;
    
    _timeMachine(id, fee, false);

    if (toKey.tokenId == 0) {
      toKey.tokenId = fromKey.tokenId;
      _recordOwner(_recipient, toKey.tokenId);
    }

    if (previousExpiration <= block.timestamp) {
      
      
      
      toKey.expirationTimestamp = fromKey.expirationTimestamp;
      toKey.tokenId = fromKey.tokenId;
      _recordOwner(_recipient, _tokenId);
    } else {
      
      
      toKey.expirationTimestamp = fromKey
        .expirationTimestamp.add(previousExpiration - block.timestamp);
    }

    
    fromKey.expirationTimestamp = block.timestamp;

    
    fromKey.tokenId = 0;

    
    _clearApproval(_tokenId);

    
    emit Transfer(
      _from,
      _recipient,
      _tokenId
    );
  }

  
  function safeTransferFrom(
    address _from,
    address _to,
    uint _tokenId
  )
    external
  {
    safeTransferFrom(_from, _to, _tokenId, '');
  }

  /**
  * @notice Transfers the ownership of an NFT from one address to another address.
  * When transfer is complete, this functions
  *  checks if `_to` is a smart contract (code size > 0). If so, it calls
  *  `onERC721Received` on `_to` and throws if the return value is not
  *  `bytes4(keccak256('onERC721Received(address,address,uint,bytes)'))`.
  * @param _from The current owner of the NFT
  * @param _to The new owner
  * @param _tokenId The NFT to transfer
  * @param _data Additional data with no specified format, sent in call to `_to`
  */
  function safeTransferFrom(
    address _from,
    address _to,
    uint _tokenId,
    bytes memory _data
  )
    public
    onlyIfAlive
    onlyKeyOwnerOrApproved(_tokenId)
    hasValidKey(ownerOf[_tokenId])
  {
    transferFrom(_from, _to, _tokenId);
    require(_checkOnERC721Received(_from, _to, _tokenId, _data), 'NON_COMPLIANT_ERC721_RECEIVER');

  }

  
  function updateTransferFee(
    uint _transferFeeBasisPoints
  )
    external
    onlyOwner
  {
    emit TransferFeeChanged(
      _transferFeeBasisPoints
    );
    transferFeeBasisPoints = _transferFeeBasisPoints;
  }

  
  function getTransferFee(
    address _owner,
    uint _time
  )
    public view
    hasValidKey(_owner)
    returns (uint)
  {
    Key storage key = keyByOwner[_owner];
    uint timeToTransfer;
    uint fee;
    
    
    if(_time == 0) {
      timeToTransfer = key.expirationTimestamp - block.timestamp;
    } else {
      timeToTransfer = _time;
    }
    fee = timeToTransfer.mul(transferFeeBasisPoints) / BASIS_POINTS_DEN;
    return fee;
  }

  
  function _timeMachine(
    uint _tokenId,
    uint256 _deltaT,
    bool _addTime
  ) internal
  {
    address tokenOwner = ownerOf[_tokenId];
    require(tokenOwner != address(0), 'NON_EXISTENT_KEY');
    Key storage key = keyByOwner[tokenOwner];
    uint formerTimestamp = key.expirationTimestamp;
    bool validKey = getHasValidKey(tokenOwner);
    if(_addTime) {
      if(validKey) {
        key.expirationTimestamp = formerTimestamp.add(_deltaT);
      } else {
        key.expirationTimestamp = block.timestamp.add(_deltaT);
      }
    } else {
      key.expirationTimestamp = formerTimestamp.sub(_deltaT);
    }
    emit TimestampChanged(_tokenId, _deltaT, _addTime);
  }

  
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  )
    internal
    returns (bool)
  {
    if (!to.isContract()) {
      return true;
    }
    bytes4 retval = IERC721Receiver(to).onERC721Received(
      msg.sender, from, tokenId, _data);
    return (retval == _ERC721_RECEIVED);
  }

}



pragma solidity 0.5.12;





















contract PublicLock is
  IERC721Enumerable,
  IERC721,
  IPublicLock,
  Initializable,
  ERC165,
  Ownable,
  MixinSignatures,
  MixinFunds,
  MixinDisableAndDestroy,
  MixinLockCore,
  MixinKeys,
  MixinLockMetadata,
  MixinERC721Enumerable,
  MixinEventHooks,
  MixinGrantKeys,
  MixinPurchase,
  MixinApproval,
  MixinTransfer,
  MixinRefunds
{
  function initialize(
    address _owner,
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string memory _lockName
  ) public
    initializer()
  {
    Ownable.initialize(_owner);
    MixinFunds.initialize(_tokenAddress);
    MixinDisableAndDestroy.initialize();
    MixinLockCore.initialize(_owner, _expirationDuration, _keyPrice, _maxNumberOfKeys);
    MixinLockMetadata.initialize(_lockName);
    MixinERC721Enumerable.initialize();
    MixinRefunds.initialize();
    
    
    _registerInterface(0x80ac58cd);
  }
}