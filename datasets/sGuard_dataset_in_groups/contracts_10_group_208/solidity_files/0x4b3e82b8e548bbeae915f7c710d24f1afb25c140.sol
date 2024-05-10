pragma solidity 0.5.16;



interface IWhitelist
{
  
  function detectTransferRestriction(
    address from,
    address to,
    uint value
  ) external view
    returns (uint8);

  
  function messageForTransferRestriction(
    uint8 restrictionCode
  ) external pure
    returns (string memory);

  
  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external;
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


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



pragma solidity ^0.5.0;









contract OperatorRole is Initializable, Context, Ownable
{
  using Roles for Roles.Role;

  event OperatorAdded(address indexed account);
  event OperatorRemoved(address indexed account);

  Roles.Role private _operators;

  function _initializeOperatorRole() internal
  {
    _addOperator(msg.sender);
  }

  modifier onlyOperator()
  {
    require(isOperator(msg.sender), "OperatorRole: caller does not have the Operator role");
    _;
  }

  function isOperator(address account) public view returns (bool)
  {
    return _operators.has(account);
  }

  function addOperator(address account) public onlyOwner
  {
    _addOperator(account);
  }

  function removeOperator(address account) public onlyOwner
  {
    _removeOperator(account);
  }

  function renounceOperator() public
  {
    _removeOperator(msg.sender);
  }

  function _addOperator(address account) internal
  {
    _operators.add(account);
    emit OperatorAdded(account);
  }

  function _removeOperator(address account) internal
  {
    _operators.remove(account);
    emit OperatorRemoved(account);
  }

  uint256[50] private ______gap;
}



pragma solidity 0.5.16;







contract Whitelist is IWhitelist, Ownable, OperatorRole
{
  using SafeMath for uint;

  
  uint8 constant private STATUS_SUCCESS = 0;
  uint8 constant private STATUS_ERROR_JURISDICTION_FLOW = 1;
  uint8 constant private STATUS_ERROR_LOCKUP = 2;
  uint8 constant private STATUS_ERROR_USER_UNKNOWN = 3;

  event ConfigWhitelist(
    uint _startDate,
    uint _lockupGranularity,
    address indexed _operator
  );
  event UpdateJurisdictionFlow(
    uint indexed _fromJurisdictionId,
    uint indexed _toJurisdictionId,
    uint _lockupLength,
    address indexed _operator
  );
  event ApproveNewUser(
    address indexed _trader,
    uint indexed _jurisdictionId,
    address indexed _operator
  );
  event AddApprovedUserWallet(
    address indexed _userId,
    address indexed _newWallet,
    address indexed _operator
  );
  event RevokeUserWallet(
    address indexed _wallet,
    address indexed _operator
  );
  event UpdateJurisdictionForUserId(
    address indexed _userId,
    uint indexed _jurisdictionId,
    address indexed _operator
  );
  event AddLockup(
    address indexed _userId,
    uint _lockupExpirationDate,
    uint _numberOfTokensLocked,
    address indexed _operator
  );
  event UnlockTokens(
    address indexed _userId,
    uint _tokensUnlocked,
    address indexed _operator
  );

  
  IERC20 public callingContract;

  
  uint public startDate;

  
  uint public lockupGranularity;

  
  mapping(uint => mapping(uint => uint)) internal jurisdictionFlows;

  
  mapping(address => address) public authorizedWalletToUserId;

  
  struct UserInfo
  {
    
    uint jurisdictionId;
    
    uint totalTokensLocked;
    
    uint startIndex;
    
    uint endIndex;
  }

  
  mapping(address => UserInfo) internal authorizedUserIdInfo;

  
  struct Lockup
  {
    
    uint lockupExpirationDate;
    
    uint numberOfTokensLocked;
  }

  
  mapping(address => mapping(uint => Lockup)) internal userIdLockups;

  
  function getJurisdictionFlow(
    uint _fromJurisdictionId,
    uint _toJurisdictionId
  ) external view
    returns (uint lockupLength)
  {
    return jurisdictionFlows[_fromJurisdictionId][_toJurisdictionId];
  }

  
  function getAuthorizedUserIdInfo(
    address _userId
  ) external view
    returns (
      uint jurisdictionId,
      uint totalTokensLocked,
      uint startIndex,
      uint endIndex
    )
  {
    UserInfo memory info = authorizedUserIdInfo[_userId];
    return (info.jurisdictionId, info.totalTokensLocked, info.startIndex, info.endIndex);
  }

  
  function getUserIdLockup(
    address _userId,
    uint _lockupIndex
  ) external view
    returns (uint lockupExpirationDate, uint numberOfTokensLocked)
  {
    Lockup memory lockup = userIdLockups[_userId][_lockupIndex];
    return (lockup.lockupExpirationDate, lockup.numberOfTokensLocked);
  }

  
  function getLockedTokenCount(
    address _userId
  ) external view
    returns (uint lockedTokens)
  {
    UserInfo memory info = authorizedUserIdInfo[_userId];
    lockedTokens = info.totalTokensLocked;
    uint endIndex = info.endIndex;
    for(uint i = info.startIndex; i < endIndex; i++)
    {
      Lockup memory lockup = userIdLockups[_userId][i];
      if(lockup.lockupExpirationDate > now)
      {
        
        break;
      }
      
      lockedTokens -= lockup.numberOfTokensLocked;
    }
  }

  
  function detectTransferRestriction(
    address _from,
    address _to,
    uint 
  ) external view
    returns(uint8 status)
  {
    address fromUserId = authorizedWalletToUserId[_from];
    address toUserId = authorizedWalletToUserId[_to];
    if(
      (fromUserId == address(0) && _from != address(0)) ||
      (toUserId == address(0) && _to != address(0))
    )
    {
      return STATUS_ERROR_USER_UNKNOWN;
    }
    if(fromUserId != toUserId)
    {
      uint fromJurisdictionId = authorizedUserIdInfo[fromUserId].jurisdictionId;
      uint toJurisdictionId = authorizedUserIdInfo[toUserId].jurisdictionId;
      if(jurisdictionFlows[fromJurisdictionId][toJurisdictionId] == 0)
      {
        return STATUS_ERROR_JURISDICTION_FLOW;
      }
    }

    return STATUS_SUCCESS;
  }

  function messageForTransferRestriction(
    uint8 _restrictionCode
  ) external pure
    returns (string memory)
  {
    if(_restrictionCode == STATUS_SUCCESS)
    {
      return "SUCCESS";
    }
    if(_restrictionCode == STATUS_ERROR_JURISDICTION_FLOW)
    {
      return "DENIED: JURISDICTION_FLOW";
    }
    if(_restrictionCode == STATUS_ERROR_LOCKUP)
    {
      return "DENIED: LOCKUP";
    }
    if(_restrictionCode == STATUS_ERROR_USER_UNKNOWN)
    {
      return "DENIED: USER_UNKNOWN";
    }
    return "DENIED: UNKNOWN_ERROR";
  }

  
  function initialize(
    address _callingContract
  ) public
  {
    Ownable.initialize(msg.sender);
    _initializeOperatorRole();
    callingContract = IERC20(_callingContract);
  }

  
  function configWhitelist(
    uint _startDate,
    uint _lockupGranularity
  ) external
    onlyOwner()
  {
    startDate = _startDate;
    lockupGranularity = _lockupGranularity;
    emit ConfigWhitelist(_startDate, _lockupGranularity, msg.sender);
  }

  
  function updateJurisdictionFlows(
    uint[] calldata _fromJurisdictionIds,
    uint[] calldata _toJurisdictionIds,
    uint[] calldata _lockupLengths
  ) external
    onlyOwner()
  {
    uint count = _fromJurisdictionIds.length;
    for(uint i = 0; i < count; i++)
    {
      uint fromJurisdictionId = _fromJurisdictionIds[i];
      uint toJurisdictionId = _toJurisdictionIds[i];
      require(fromJurisdictionId > 0 && toJurisdictionId > 0, "INVALID_JURISDICTION_ID");
      jurisdictionFlows[fromJurisdictionId][toJurisdictionId] = _lockupLengths[i];
      emit UpdateJurisdictionFlow(
        fromJurisdictionId,
        toJurisdictionId,
        _lockupLengths[i],
        msg.sender
      );
    }
  }

  
  function approveNewUsers(
    address[] calldata _traders,
    uint[] calldata _jurisdictionIds
  ) external
    onlyOperator()
  {
    uint length = _traders.length;
    for(uint i = 0; i < length; i++)
    {
      address trader = _traders[i];
      require(authorizedWalletToUserId[trader] == address(0), "USER_WALLET_ALREADY_ADDED");
      require(authorizedUserIdInfo[trader].jurisdictionId == 0, "USER_ID_ALREADY_ADDED");
      uint jurisdictionId = _jurisdictionIds[i];
      require(jurisdictionId != 0, "INVALID_JURISDICTION_ID");

      authorizedWalletToUserId[trader] = trader;
      authorizedUserIdInfo[trader].jurisdictionId = jurisdictionId;
      emit ApproveNewUser(trader, jurisdictionId, msg.sender);
    }
  }

  
  function addApprovedUserWallets(
    address[] calldata _userIds,
    address[] calldata _newWallets
  ) external
    onlyOperator()
  {
    uint length = _userIds.length;
    for(uint i = 0; i < length; i++)
    {
      address userId = _userIds[i];
      require(authorizedUserIdInfo[userId].jurisdictionId != 0, "USER_ID_UNKNOWN");
      address newWallet = _newWallets[i];
      require(authorizedWalletToUserId[newWallet] == address(0), "WALLET_ALREADY_ADDED");

      authorizedWalletToUserId[newWallet] = userId;
      emit AddApprovedUserWallet(userId, newWallet, msg.sender);
    }
  }

  
  function revokeUserWallets(
    address[] calldata _wallets
  ) external
    onlyOperator()
  {
    uint length = _wallets.length;
    for(uint i = 0; i < length; i++)
    {
      address wallet = _wallets[i];
      require(authorizedWalletToUserId[wallet] != address(0), "WALLET_NOT_FOUND");

      authorizedWalletToUserId[wallet] = address(0);
      emit RevokeUserWallet(wallet, msg.sender);
    }
  }

  
  function updateJurisdictionsForUserIds(
    address[] calldata _userIds,
    uint[] calldata _jurisdictionIds
  ) external
    onlyOperator()
  {
    uint length = _userIds.length;
    for(uint i = 0; i < length; i++)
    {
      address userId = _userIds[i];
      require(authorizedUserIdInfo[userId].jurisdictionId != 0, "USER_ID_UNKNOWN");
      uint jurisdictionId = _jurisdictionIds[i];
      require(jurisdictionId != 0, "INVALID_JURISDICTION_ID");

      authorizedUserIdInfo[userId].jurisdictionId = jurisdictionId;
      emit UpdateJurisdictionForUserId(userId, jurisdictionId, msg.sender);
    }
  }

  
  function _addLockup(
    address _userId,
    uint _lockupExpirationDate,
    uint _numberOfTokensLocked
  ) internal
  {
    if(_numberOfTokensLocked == 0 || _lockupExpirationDate <= now)
    {
      
      return;
    }
    emit AddLockup(_userId, _lockupExpirationDate, _numberOfTokensLocked, msg.sender);
    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId != 0, "USER_ID_UNKNOWN");
    info.totalTokensLocked = info.totalTokensLocked.add(_numberOfTokensLocked);
    if(info.endIndex > 0)
    {
      Lockup storage lockup = userIdLockups[_userId][info.endIndex - 1];
      if(lockup.lockupExpirationDate + lockupGranularity >= _lockupExpirationDate)
      {
        
        
        lockup.numberOfTokensLocked += _numberOfTokensLocked;
        return;
      }
    }
    
    userIdLockups[_userId][info.endIndex] = Lockup(_lockupExpirationDate, _numberOfTokensLocked);
    info.endIndex++;
  }

  
  function addLockups(
    address[] calldata _userIds,
    uint[] calldata _lockupExpirationDates,
    uint[] calldata _numberOfTokensLocked
  ) external
    onlyOperator()
  {
    uint length = _userIds.length;
    for(uint i = 0; i < length; i++)
    {
      _addLockup(
        _userIds[i],
        _lockupExpirationDates[i],
        _numberOfTokensLocked[i]
      );
    }
  }

  
  function _processLockup(
    UserInfo storage info,
    address _userId,
    bool _ignoreExpiration
  ) internal
    returns (bool isDone)
  {
    if(info.startIndex >= info.endIndex)
    {
      
      return true;
    }
    Lockup storage lockup = userIdLockups[_userId][info.startIndex];
    if(lockup.lockupExpirationDate > now && !_ignoreExpiration)
    {
      
      return true;
    }
    emit UnlockTokens(_userId, lockup.numberOfTokensLocked, msg.sender);
    info.totalTokensLocked -= lockup.numberOfTokensLocked;
    info.startIndex++;
    
    lockup.numberOfTokensLocked = 0;
    lockup.lockupExpirationDate = 0;
    
    return false;
  }

  
  function processLockups(
    address _userId,
    uint _maxCount
  ) external
  {
    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId > 0, "USER_ID_UNKNOWN");
    for(uint i = 0; i < _maxCount; i++)
    {
      if(_processLockup(info, _userId, false))
      {
        break;
      }
    }
  }

  
  function forceUnlock(
    address _userId,
    uint _maxCount
  ) external
    onlyOperator()
  {
    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId > 0, "USER_ID_UNKNOWN");
    for(uint i = 0; i < _maxCount; i++)
    {
      if(_processLockup(info, _userId, true))
      {
        break;
      }
    }
  }

  
  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external
  {
    require(address(callingContract) == msg.sender, "CALL_VIA_CONTRACT_ONLY");

    if(_to == address(0) && !_isSell)
    {
      
      
      
      return;
    }

    address fromUserId = authorizedWalletToUserId[_from];
    require(fromUserId != address(0) || _from == address(0), "FROM_USER_UNKNOWN");
    address toUserId = authorizedWalletToUserId[_to];
    require(toUserId != address(0) || _to == address(0), "TO_USER_UNKNOWN");

    
    if(fromUserId != toUserId)
    {
      uint fromJurisdictionId = authorizedUserIdInfo[fromUserId].jurisdictionId;
      uint toJurisdictionId = authorizedUserIdInfo[toUserId].jurisdictionId;
      uint lockupLength = jurisdictionFlows[fromJurisdictionId][toJurisdictionId];
      require(lockupLength > 0, "DENIED: JURISDICTION_FLOW");

      
      
      if(lockupLength > 1 && _to != address(0))
      {
        
        uint lockupExpirationDate = now + lockupLength;
        _addLockup(toUserId, lockupExpirationDate, _value);
      }

      if(_from == address(0))
      {
        
        require(now >= startDate, "WAIT_FOR_START_DATE");
      }
      else
      {
        
        UserInfo storage info = authorizedUserIdInfo[fromUserId];
        while(true)
        {
          if(_processLockup(info, fromUserId, false))
          {
            break;
          }
        }
        uint balance = callingContract.balanceOf(_from);
        
        
        require(
          balance >= _value,
          "INSUFFICIENT_BALANCE"
        );
        require(
          balance >= info.totalTokensLocked.add(_value),
          "INSUFFICIENT_TRANSFERABLE_BALANCE"
        );
      }
    }
  }
}