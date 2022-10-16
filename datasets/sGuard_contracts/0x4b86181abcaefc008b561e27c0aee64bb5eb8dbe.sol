pragma solidity ^0.4.24;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



pragma solidity ^0.4.24;




contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



pragma solidity ^0.4.24;




contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}



pragma solidity 0.4.24;

interface IAMB {
    function messageSender() external view returns (address);
    function maxGasPerTx() external view returns (uint256);
    function transactionHash() external view returns (bytes32);
    function messageId() external view returns (bytes32);
    function messageSourceChainId() external view returns (bytes32);
    function messageCallStatus(bytes32 _messageId) external view returns (bool);
    function failedMessageDataHash(bytes32 _messageId) external view returns (bytes32);
    function failedMessageReceiver(bytes32 _messageId) external view returns (address);
    function failedMessageSender(bytes32 _messageId) external view returns (address);
    function requireToPassMessage(address _contract, bytes _data, uint256 _gas) external returns (bytes32);
    function sourceChainId() external view returns (uint256);
    function destinationChainId() external view returns (uint256);
}



pragma solidity 0.4.24;


contract ERC677 is ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function transferAndCall(address, uint256, bytes) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool);
}

contract LegacyERC20 {
    function transfer(address _spender, uint256 _value) public; 
    function transferFrom(address _owner, address _spender, uint256 _value) public; 
}



pragma solidity ^0.4.24;



library SafeMath {

  
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}



pragma solidity 0.4.24;


contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}



pragma solidity 0.4.24;

interface IUpgradeabilityOwnerStorage {
    function upgradeabilityOwner() external view returns (address);
}



pragma solidity 0.4.24;




contract Ownable is EternalStorage {
    bytes4 internal constant UPGRADEABILITY_OWNER = 0x6fde8202; 

    
    event OwnershipTransferred(address previousOwner, address newOwner);

    
    modifier onlyOwner() {
        require(msg.sender == owner());
        
        _;
    }

    
    modifier onlyRelevantSender() {
        
        require(
            !address(this).call(abi.encodeWithSelector(UPGRADEABILITY_OWNER)) || 
                msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner() || 
                msg.sender == address(this) 
        );
        
        _;
    }

    bytes32 internal constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; 

    
    function owner() public view returns (address) {
        return addressStorage[OWNER];
    }

    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
    }
}



pragma solidity 0.4.24;




contract BasicMultiTokenBridge is EternalStorage, Ownable {
    using SafeMath for uint256;

    
    event DailyLimitChanged(address indexed token, uint256 newLimit);
    event ExecutionDailyLimitChanged(address indexed token, uint256 newLimit);

    
    function isTokenRegistered(address _token) public view returns (bool) {
        return minPerTx(_token) > 0;
    }

    
    function totalSpentPerDay(address _token, uint256 _day) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _token, _day))];
    }

    
    function totalExecutedPerDay(address _token, uint256 _day) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _token, _day))];
    }

    
    function dailyLimit(address _token) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))];
    }

    
    function executionDailyLimit(address _token) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))];
    }

    
    function maxPerTx(address _token) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("maxPerTx", _token))];
    }

    
    function executionMaxPerTx(address _token) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("executionMaxPerTx", _token))];
    }

    
    function minPerTx(address _token) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("minPerTx", _token))];
    }

    
    function withinLimit(address _token, uint256 _amount) public view returns (bool) {
        uint256 nextLimit = totalSpentPerDay(_token, getCurrentDay()).add(_amount);
        return
            dailyLimit(address(0)) > 0 &&
                dailyLimit(_token) >= nextLimit &&
                _amount <= maxPerTx(_token) &&
                _amount >= minPerTx(_token);
    }

    
    function withinExecutionLimit(address _token, uint256 _amount) public view returns (bool) {
        uint256 nextLimit = totalExecutedPerDay(_token, getCurrentDay()).add(_amount);
        return
            executionDailyLimit(address(0)) > 0 &&
                executionDailyLimit(_token) >= nextLimit &&
                _amount <= executionMaxPerTx(_token);
    }

    
    function getCurrentDay() public view returns (uint256) {
        
        return now / 1 days;
    }

    
    function setDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {
        require(isTokenRegistered(_token));
        require(_dailyLimit > maxPerTx(_token) || _dailyLimit == 0);
        uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))] = _dailyLimit;
        emit DailyLimitChanged(_token, _dailyLimit);
    }

    
    function setExecutionDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {
        require(isTokenRegistered(_token));
        require(_dailyLimit > executionMaxPerTx(_token) || _dailyLimit == 0);
        uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))] = _dailyLimit;
        emit ExecutionDailyLimitChanged(_token, _dailyLimit);
    }

    
    function setExecutionMaxPerTx(address _token, uint256 _maxPerTx) external onlyOwner {
        require(isTokenRegistered(_token));
        require(_maxPerTx == 0 || (_maxPerTx > 0 && _maxPerTx < executionDailyLimit(_token)));
        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx", _token))] = _maxPerTx;
    }

    
    function setMaxPerTx(address _token, uint256 _maxPerTx) external onlyOwner {
        require(isTokenRegistered(_token));
        require(_maxPerTx == 0 || (_maxPerTx > minPerTx(_token) && _maxPerTx < dailyLimit(_token)));
        uintStorage[keccak256(abi.encodePacked("maxPerTx", _token))] = _maxPerTx;
    }

    
    function setMinPerTx(address _token, uint256 _minPerTx) external onlyOwner {
        require(isTokenRegistered(_token));
        require(_minPerTx > 0 && _minPerTx < dailyLimit(_token) && _minPerTx < maxPerTx(_token));
        uintStorage[keccak256(abi.encodePacked("minPerTx", _token))] = _minPerTx;
    }

    
    function maxAvailablePerTx(address _token) public view returns (uint256) {
        uint256 _maxPerTx = maxPerTx(_token);
        uint256 _dailyLimit = dailyLimit(_token);
        uint256 _spent = totalSpentPerDay(_token, getCurrentDay());
        uint256 _remainingOutOfDaily = _dailyLimit > _spent ? _dailyLimit - _spent : 0;
        return _maxPerTx < _remainingOutOfDaily ? _maxPerTx : _remainingOutOfDaily;
    }

    
    function addTotalSpentPerDay(address _token, uint256 _day, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _token, _day))] = totalSpentPerDay(_token, _day).add(
            _value
        );
    }

    
    function addTotalExecutedPerDay(address _token, uint256 _day, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _token, _day))] = totalExecutedPerDay(
            _token,
            _day
        )
            .add(_value);
    }

    
    function _setLimits(address _token, uint256[3] _limits) internal {
        require(
            _limits[2] > 0 && 
                _limits[1] > _limits[2] && 
                _limits[0] > _limits[1] 
        );

        uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))] = _limits[0];
        uintStorage[keccak256(abi.encodePacked("maxPerTx", _token))] = _limits[1];
        uintStorage[keccak256(abi.encodePacked("minPerTx", _token))] = _limits[2];

        emit DailyLimitChanged(_token, _limits[0]);
    }

    
    function _setExecutionLimits(address _token, uint256[2] _limits) internal {
        require(_limits[1] < _limits[0]); 

        uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))] = _limits[0];
        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx", _token))] = _limits[1];

        emit ExecutionDailyLimitChanged(_token, _limits[0]);
    }

    
    function _initializeTokenBridgeLimits(address _token, uint256 _decimals) internal {
        uint256 factor;
        if (_decimals < 18) {
            factor = 10**(18 - _decimals);

            uint256 _minPerTx = minPerTx(address(0)).div(factor);
            uint256 _maxPerTx = maxPerTx(address(0)).div(factor);
            uint256 _dailyLimit = dailyLimit(address(0)).div(factor);
            uint256 _executionMaxPerTx = executionMaxPerTx(address(0)).div(factor);
            uint256 _executionDailyLimit = executionDailyLimit(address(0)).div(factor);

            
            
            
            if (_minPerTx == 0) {
                _minPerTx = 1;
                if (_maxPerTx <= _minPerTx) {
                    _maxPerTx = 100;
                    _executionMaxPerTx = 100;
                    if (_dailyLimit <= _maxPerTx || _executionDailyLimit <= _executionMaxPerTx) {
                        _dailyLimit = 10000;
                        _executionDailyLimit = 10000;
                    }
                }
            }
            _setLimits(_token, [_dailyLimit, _maxPerTx, _minPerTx]);
            _setExecutionLimits(_token, [_executionDailyLimit, _executionMaxPerTx]);
        } else {
            factor = 10**(_decimals - 18);
            _setLimits(
                _token,
                [dailyLimit(address(0)).mul(factor), maxPerTx(address(0)).mul(factor), minPerTx(address(0)).mul(factor)]
            );
            _setExecutionLimits(
                _token,
                [executionDailyLimit(address(0)).mul(factor), executionMaxPerTx(address(0)).mul(factor)]
            );
        }
    }
}



pragma solidity 0.4.24;


library Bytes {
    
    function bytesToBytes32(bytes _bytes) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(_bytes, 32))
        }
    }

    
    function bytesToAddress(bytes _bytes) internal pure returns (address addr) {
        assembly {
            addr := mload(add(_bytes, 20))
        }
    }
}



pragma solidity ^0.4.24;



library AddressUtils {

  
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
    
    
    
    
    
    
    
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}



pragma solidity 0.4.24;






contract BasicAMBMediator is Ownable {
    bytes32 internal constant BRIDGE_CONTRACT = 0x811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f; 
    bytes32 internal constant MEDIATOR_CONTRACT = 0x98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab9880; 
    bytes32 internal constant REQUEST_GAS_LIMIT = 0x2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be; 

    
    modifier onlyMediator {
        require(msg.sender == address(bridgeContract()));
        require(messageSender() == mediatorContractOnOtherSide());
        _;
    }

    
    function setBridgeContract(address _bridgeContract) external onlyOwner {
        _setBridgeContract(_bridgeContract);
    }

    
    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {
        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    
    function setRequestGasLimit(uint256 _requestGasLimit) external onlyOwner {
        _setRequestGasLimit(_requestGasLimit);
    }

    
    function bridgeContract() public view returns (IAMB) {
        return IAMB(addressStorage[BRIDGE_CONTRACT]);
    }

    
    function mediatorContractOnOtherSide() public view returns (address) {
        return addressStorage[MEDIATOR_CONTRACT];
    }

    
    function requestGasLimit() public view returns (uint256) {
        return uintStorage[REQUEST_GAS_LIMIT];
    }

    
    function _setBridgeContract(address _bridgeContract) internal {
        require(AddressUtils.isContract(_bridgeContract));
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    
    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {
        addressStorage[MEDIATOR_CONTRACT] = _mediatorContract;
    }

    
    function _setRequestGasLimit(uint256 _requestGasLimit) internal {
        require(_requestGasLimit <= maxGasPerTx());
        uintStorage[REQUEST_GAS_LIMIT] = _requestGasLimit;
    }

    
    function messageSender() internal view returns (address) {
        return bridgeContract().messageSender();
    }

    
    function messageId() internal view returns (bytes32) {
        return bridgeContract().messageId();
    }

    
    function maxGasPerTx() internal view returns (uint256) {
        return bridgeContract().maxGasPerTx();
    }
}



pragma solidity 0.4.24;


contract ChooseReceiverHelper {
    
    function chooseReceiver(address _from, bytes _data) internal view returns (address recipient) {
        recipient = _from;
        if (_data.length > 0) {
            require(_data.length == 20);
            recipient = Bytes.bytesToAddress(_data);
            require(recipient != address(0));
            require(recipient != bridgeContractOnOtherSide());
        }
    }

    
    function bridgeContractOnOtherSide() internal view returns (address);
}



pragma solidity 0.4.24;


contract TransferInfoStorage is EternalStorage {
    
    function setMessageValue(bytes32 _messageId, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("messageValue", _messageId))] = _value;
    }

    
    function messageValue(bytes32 _messageId) internal view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("messageValue", _messageId))];
    }

    
    function setMessageRecipient(bytes32 _messageId, address _recipient) internal {
        addressStorage[keccak256(abi.encodePacked("messageRecipient", _messageId))] = _recipient;
    }

    
    function messageRecipient(bytes32 _messageId) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("messageRecipient", _messageId))];
    }

    
    function setMessageFixed(bytes32 _messageId) internal {
        boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))] = true;
    }

    
    function messageFixed(bytes32 _messageId) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))];
    }
}



pragma solidity 0.4.24;







contract MultiTokenBridgeMediator is
    BasicAMBMediator,
    BasicMultiTokenBridge,
    TransferInfoStorage,
    ChooseReceiverHelper
{
    event FailedMessageFixed(bytes32 indexed messageId, address token, address recipient, uint256 value);
    event TokensBridged(address indexed token, address indexed recipient, uint256 value, bytes32 indexed messageId);

    
    function setMessageToken(bytes32 _messageId, address _token) internal {
        addressStorage[keccak256(abi.encodePacked("messageToken", _messageId))] = _token;
    }

    
    function messageToken(bytes32 _messageId) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("messageToken", _messageId))];
    }

    
    function _handleBridgedTokens(ERC677 _token, address _recipient, uint256 _value) internal {
        if (withinExecutionLimit(_token, _value)) {
            addTotalExecutedPerDay(_token, getCurrentDay(), _value);
            executeActionOnBridgedTokens(_token, _recipient, _value);
        } else {
            executeActionOnBridgedTokensOutOfLimit(_token, _recipient, _value);
        }
    }

    
    function requestFailedMessageFix(bytes32 _messageId) external {
        require(!bridgeContract().messageCallStatus(_messageId));
        require(bridgeContract().failedMessageReceiver(_messageId) == address(this));
        require(bridgeContract().failedMessageSender(_messageId) == mediatorContractOnOtherSide());

        bytes4 methodSelector = this.fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _messageId);
        bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());
    }

    
    function fixFailedMessage(bytes32 _messageId) public onlyMediator {
        require(!messageFixed(_messageId));

        address token = messageToken(_messageId);
        address recipient = messageRecipient(_messageId);
        uint256 value = messageValue(_messageId);
        setMessageFixed(_messageId);
        executeActionOnFixedTokens(token, recipient, value);
        emit FailedMessageFixed(_messageId, token, recipient, value);
    }

    
    function executeActionOnBridgedTokensOutOfLimit(address, address, uint256) internal {
        revert();
    }

    
    function executeActionOnBridgedTokens(address _token, address _recipient, uint256 _value) internal;

    
    function executeActionOnFixedTokens(address _token, address _recipient, uint256 _value) internal;
}



pragma solidity 0.4.24;


contract Initializable is EternalStorage {
    bytes32 internal constant INITIALIZED = 0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba; 

    function setInitialize() internal {
        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {
        return boolStorage[INITIALIZED];
    }
}



pragma solidity 0.4.24;


contract ReentrancyGuard is EternalStorage {
    bytes32 internal constant LOCK = 0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92; 

    function lock() internal returns (bool) {
        return boolStorage[LOCK];
    }

    function setLock(bool _lock) internal {
        boolStorage[LOCK] = _lock;
    }
}



pragma solidity 0.4.24;


contract Upgradeable {
    
    modifier onlyIfUpgradeabilityOwner() {
        require(msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner());
        
        _;
    }
}



pragma solidity 0.4.24;

contract Sacrifice {
    constructor(address _recipient) public payable {
        selfdestruct(_recipient);
    }
}



pragma solidity 0.4.24;



library Address {
    
    function safeSendValue(address _receiver, uint256 _value) internal {
        if (!_receiver.send(_value)) {
            (new Sacrifice).value(_value)(_receiver);
        }
    }
}



pragma solidity 0.4.24;



contract Claimable {
    bytes4 internal constant TRANSFER = 0xa9059cbb; 

    modifier validAddress(address _to) {
        require(_to != address(0));
        
        _;
    }

    function claimValues(address _token, address _to) internal {
        if (_token == address(0)) {
            claimNativeCoins(_to);
        } else {
            claimErc20Tokens(_token, _to);
        }
    }

    function claimNativeCoins(address _to) internal {
        uint256 value = address(this).balance;
        Address.safeSendValue(_to, value);
    }

    function claimErc20Tokens(address _token, address _to) internal {
        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        safeTransfer(_token, _to, balance);
    }

    function safeTransfer(address _token, address _to, uint256 _value) internal {
        bytes memory returnData;
        bool returnDataResult;
        bytes memory callData = abi.encodeWithSelector(TRANSFER, _to, _value);
        assembly {
            let result := call(gas, _token, 0x0, add(callData, 0x20), mload(callData), 0, 32)
            returnData := mload(0)
            returnDataResult := mload(0)

            switch result
                case 0 {
                    revert(0, 0)
                }
        }

        
        if (returnData.length > 0) {
            require(returnDataResult);
        }
    }
}



pragma solidity 0.4.24;

contract VersionableBridge {
    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {
        return (5, 1, 0);
    }

    
    function getBridgeMode() external pure returns (bytes4);
}



pragma solidity 0.4.24;










contract BasicMultiAMBErc20ToErc677 is
    Initializable,
    ReentrancyGuard,
    Upgradeable,
    Claimable,
    VersionableBridge,
    MultiTokenBridgeMediator
{
    
    function bridgeContractOnOtherSide() internal view returns (address) {
        return mediatorContractOnOtherSide();
    }

    
    function relayTokens(ERC677 token, address _receiver, uint256 _value) external {
        _relayTokens(token, _receiver, _value);
    }

    
    function relayTokens(ERC677 token, uint256 _value) external {
        _relayTokens(token, msg.sender, _value);
    }

    
    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {
        return (1, 1, 0);
    }

    
    function getBridgeMode() external pure returns (bytes4 _data) {
        return 0xb1516c26; 
    }

    
    function claimTokens(address _token, address _to) external onlyIfUpgradeabilityOwner validAddress(_to) {
        require(_token == address(0) || !isTokenRegistered(_token)); 
        claimValues(_token, _to);
    }

    
    function onTokenTransfer(address _from, uint256 _value, bytes _data) public returns (bool);

    
    function _relayTokens(ERC677 token, address _receiver, uint256 _value) internal;

    
    function bridgeSpecificActionsOnTokenTransfer(ERC677 _token, address _from, uint256 _value, bytes _data) internal;
}



pragma solidity 0.4.24;


contract Proxy {
    
    
    function implementation() public view returns (address);

    
    function() public payable {
        
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
            
            let ptr := mload(0x40)
            
            calldatacopy(ptr, 0, calldatasize)
            
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            
            
            mstore(0x40, add(ptr, returndatasize))
            
            returndatacopy(ptr, 0, returndatasize)

            
            switch result
                case 0 {
                    revert(ptr, returndatasize)
                }
                default {
                    return(ptr, returndatasize)
                }
        }
    }
}



pragma solidity 0.4.24;


interface IPermittableTokenVersion {
    function version() external pure returns (string);
}


contract TokenProxy is Proxy {
    
    string internal name;
    string internal symbol;
    uint8 internal decimals;
    mapping(address => uint256) internal balances;
    uint256 internal totalSupply;
    mapping(address => mapping(address => uint256)) internal allowed;
    address internal owner;
    bool internal mintingFinished;
    address internal bridgeContractAddr;
    
    bytes32 internal DOMAIN_SEPARATOR;
    
    mapping(address => uint256) internal nonces;
    mapping(address => mapping(address => uint256)) internal expirations;

    
    constructor(address _tokenImage, string memory _name, string memory _symbol, uint8 _decimals, uint256 _chainId)
        public
    {
        string memory version = IPermittableTokenVersion(_tokenImage).version();

        assembly {
            
            
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _tokenImage)
        }
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender; 
        bridgeContractAddr = msg.sender;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(_name)),
                keccak256(bytes(version)),
                _chainId,
                address(this)
            )
        );
    }

    
    function implementation() public view returns (address impl) {
        assembly {
            impl := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
    }
}



pragma solidity 0.4.24;




contract BaseRewardAddressList is EternalStorage {
    using SafeMath for uint256;

    address public constant F_ADDR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    uint256 internal constant MAX_REWARD_ADDRESSES = 50;
    bytes32 internal constant REWARD_ADDRESS_COUNT = 0xabc77c82721ced73eef2645facebe8c30249e6ac372cce6eb9d1fed31bd6648f; 

    event RewardAddressAdded(address indexed addr);
    event RewardAddressRemoved(address indexed addr);

    
    function rewardAddressList() external view returns (address[]) {
        address[] memory list = new address[](rewardAddressCount());
        uint256 counter = 0;
        address nextAddr = getNextRewardAddress(F_ADDR);

        while (nextAddr != F_ADDR) {
            require(nextAddr != address(0));

            list[counter] = nextAddr;
            nextAddr = getNextRewardAddress(nextAddr);
            counter++;
        }

        return list;
    }

    
    function rewardAddressCount() public view returns (uint256) {
        return uintStorage[REWARD_ADDRESS_COUNT];
    }

    
    function isRewardAddress(address _addr) public view returns (bool) {
        return _addr != F_ADDR && getNextRewardAddress(_addr) != address(0);
    }

    
    function getNextRewardAddress(address _address) public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("rewardAddressList", _address))];
    }

    
    function _addRewardAddress(address _addr) internal {
        require(_addr != address(0) && _addr != F_ADDR);
        require(!isRewardAddress(_addr));

        address nextAddr = getNextRewardAddress(F_ADDR);

        require(nextAddr != address(0));

        _setNextRewardAddress(_addr, nextAddr);
        _setNextRewardAddress(F_ADDR, _addr);
        _setRewardAddressCount(rewardAddressCount().add(1));
    }

    
    function _removeRewardAddress(address _addr) internal {
        require(isRewardAddress(_addr));
        address nextAddr = getNextRewardAddress(_addr);
        address index = F_ADDR;
        address next = getNextRewardAddress(index);

        while (next != _addr) {
            require(next != address(0));
            index = next;
            next = getNextRewardAddress(index);
            require(next != F_ADDR);
        }

        _setNextRewardAddress(index, nextAddr);
        delete addressStorage[keccak256(abi.encodePacked("rewardAddressList", _addr))];
        _setRewardAddressCount(rewardAddressCount().sub(1));
    }

    
    function _setRewardAddressList(address[] _rewardAddresses) internal {
        require(_rewardAddresses.length > 0);

        _setNextRewardAddress(F_ADDR, _rewardAddresses[0]);

        for (uint256 i = 0; i < _rewardAddresses.length; i++) {
            require(_rewardAddresses[i] != address(0) && _rewardAddresses[i] != F_ADDR);
            require(!isRewardAddress(_rewardAddresses[i]));

            if (i == _rewardAddresses.length - 1) {
                _setNextRewardAddress(_rewardAddresses[i], F_ADDR);
            } else {
                _setNextRewardAddress(_rewardAddresses[i], _rewardAddresses[i + 1]);
            }

            emit RewardAddressAdded(_rewardAddresses[i]);
        }

        _setRewardAddressCount(_rewardAddresses.length);
    }

    
    function _setRewardAddressCount(uint256 _rewardAddressCount) internal {
        require(_rewardAddressCount <= MAX_REWARD_ADDRESSES);
        uintStorage[REWARD_ADDRESS_COUNT] = _rewardAddressCount;
    }

    
    function _setNextRewardAddress(address _prevAddr, address _addr) internal {
        addressStorage[keccak256(abi.encodePacked("rewardAddressList", _prevAddr))] = _addr;
    }
}



pragma solidity 0.4.24;


contract IBurnableMintableERC677Token is ERC677 {
    function mint(address _to, uint256 _amount) public returns (bool);
    function burn(uint256 _value) public;
    function claimTokens(address _token, address _to) public;
}



pragma solidity 0.4.24;







contract HomeFeeManagerMultiAMBErc20ToErc677 is BaseRewardAddressList, Ownable, BasicMultiTokenBridge {
    using SafeMath for uint256;

    event FeeUpdated(bytes32 feeType, address indexed token, uint256 fee);
    event FeeDistributed(uint256 fee, address indexed token, bytes32 indexed messageId);

    
    uint256 internal constant MAX_FEE = 1 ether;
    bytes32 public constant HOME_TO_FOREIGN_FEE = 0x741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26; 
    bytes32 public constant FOREIGN_TO_HOME_FEE = 0x03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f12625; 

    
    modifier validFee(uint256 _fee) {
        require(_fee < MAX_FEE);
        
        _;
    }

    
    modifier validFeeType(bytes32 _feeType) {
        require(_feeType == HOME_TO_FOREIGN_FEE || _feeType == FOREIGN_TO_HOME_FEE);
        
        _;
    }

    
    function addRewardAddress(address _addr) external onlyOwner {
        _addRewardAddress(_addr);
    }

    
    function removeRewardAddress(address _addr) external onlyOwner {
        _removeRewardAddress(_addr);
    }

    
    function setFee(bytes32 _feeType, address _token, uint256 _fee) external onlyOwner {
        _setFee(_feeType, _token, _fee);
    }

    
    function getFee(bytes32 _feeType, address _token) public view validFeeType(_feeType) returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked(_feeType, _token))];
    }

    
    function calculateFee(bytes32 _feeType, address _token, uint256 _value) public view returns (uint256) {
        uint256 _fee = getFee(_feeType, _token);
        return _value.mul(_fee).div(MAX_FEE);
    }

    
    function _setFee(bytes32 _feeType, address _token, uint256 _fee) internal validFeeType(_feeType) validFee(_fee) {
        require(isTokenRegistered(_token));
        uintStorage[keccak256(abi.encodePacked(_feeType, _token))] = _fee;
        emit FeeUpdated(_feeType, _token, _fee);
    }

    
    function random(uint256 _count) internal view returns (uint256) {
        return uint256(blockhash(block.number.sub(1))) % _count;
    }

    
    function _distributeFee(bytes32 _feeType, address _token, uint256 _value) internal returns (uint256) {
        uint256 numOfAccounts = rewardAddressCount();
        uint256 _fee = calculateFee(_feeType, _token, _value);
        if (numOfAccounts == 0 || _fee == 0) {
            return 0;
        }
        uint256 feePerAccount = _fee.div(numOfAccounts);
        uint256 randomAccountIndex;
        uint256 diff = _fee.sub(feePerAccount.mul(numOfAccounts));
        if (diff > 0) {
            randomAccountIndex = random(numOfAccounts);
        }

        address nextAddr = getNextRewardAddress(F_ADDR);
        require(nextAddr != F_ADDR && nextAddr != address(0));

        uint256 i = 0;
        while (nextAddr != F_ADDR) {
            uint256 feeToDistribute = feePerAccount;
            if (diff > 0 && randomAccountIndex == i) {
                feeToDistribute = feeToDistribute.add(diff);
            }

            if (_feeType == HOME_TO_FOREIGN_FEE) {
                ERC677(_token).transfer(nextAddr, feeToDistribute);
            } else {
                IBurnableMintableERC677Token(_token).mint(nextAddr, feeToDistribute);
            }

            nextAddr = getNextRewardAddress(nextAddr);
            require(nextAddr != address(0));
            i = i + 1;
        }
        return _fee;
    }
}



pragma solidity 0.4.24;






contract HomeMultiAMBErc20ToErc677 is BasicMultiAMBErc20ToErc677, HomeFeeManagerMultiAMBErc20ToErc677 {
    bytes32 internal constant TOKEN_IMAGE_CONTRACT = 0x20b8ca26cc94f39fab299954184cf3a9bd04f69543e4f454fab299f015b8130f; 

    event NewTokenRegistered(address indexed foreignToken, address indexed homeToken);

    
    function initialize(
        address _bridgeContract,
        address _mediatorContract,
        uint256[3] _dailyLimitMaxPerTxMinPerTxArray, 
        uint256[2] _executionDailyLimitExecutionMaxPerTxArray, 
        uint256 _requestGasLimit,
        address _owner,
        address _tokenImage,
        address[] _rewardAddreses,
        uint256[2] _fees 
    ) external onlyRelevantSender returns (bool) {
        require(!isInitialized());
        require(_owner != address(0));

        _setBridgeContract(_bridgeContract);
        _setMediatorContractOnOtherSide(_mediatorContract);
        _setLimits(address(0), _dailyLimitMaxPerTxMinPerTxArray);
        _setExecutionLimits(address(0), _executionDailyLimitExecutionMaxPerTxArray);
        _setRequestGasLimit(_requestGasLimit);
        setOwner(_owner);
        _setTokenImage(_tokenImage);
        if (_rewardAddreses.length > 0) {
            _setRewardAddressList(_rewardAddreses);
        }
        _setFee(HOME_TO_FOREIGN_FEE, address(0), _fees[0]);
        _setFee(FOREIGN_TO_HOME_FEE, address(0), _fees[1]);

        setInitialize();

        return isInitialized();
    }

    
    function setTokenImage(address _tokenImage) external onlyOwner {
        _setTokenImage(_tokenImage);
    }

    
    function tokenImage() public view returns (address) {
        return addressStorage[TOKEN_IMAGE_CONTRACT];
    }

    
    function deployAndHandleBridgedTokens(
        address _token,
        string _name,
        string _symbol,
        uint8 _decimals,
        address _recipient,
        uint256 _value
    ) external onlyMediator {
        string memory name = _name;
        string memory symbol = _symbol;
        if (bytes(name).length == 0) {
            name = symbol;
        } else if (bytes(symbol).length == 0) {
            symbol = name;
        }
        name = string(abi.encodePacked(name, " on xDai"));
        address homeToken = new TokenProxy(tokenImage(), name, symbol, _decimals, bridgeContract().sourceChainId());
        _setTokenAddressPair(_token, homeToken);
        _initializeTokenBridgeLimits(homeToken, _decimals);
        _setFee(HOME_TO_FOREIGN_FEE, homeToken, getFee(HOME_TO_FOREIGN_FEE, address(0)));
        _setFee(FOREIGN_TO_HOME_FEE, homeToken, getFee(FOREIGN_TO_HOME_FEE, address(0)));
        _handleBridgedTokens(ERC677(homeToken), _recipient, _value);

        emit NewTokenRegistered(_token, homeToken);
    }

    
    function handleBridgedTokens(ERC677 _token, address _recipient, uint256 _value) external onlyMediator {
        ERC677 homeToken = ERC677(homeTokenAddress(_token));
        require(isTokenRegistered(homeToken));
        _handleBridgedTokens(homeToken, _recipient, _value);
    }

    
    function onTokenTransfer(address _from, uint256 _value, bytes _data) public returns (bool) {
        
        if (!lock()) {
            ERC677 token = ERC677(msg.sender);
            
            
            
            require(withinLimit(token, _value));
            addTotalSpentPerDay(token, getCurrentDay(), _value);
            bridgeSpecificActionsOnTokenTransfer(token, _from, _value, _data);
        }
        return true;
    }

    
    function _relayTokens(ERC677 token, address _receiver, uint256 _value) internal {
        
        
        
        require(!lock());
        address to = address(this);
        
        
        
        require(withinLimit(token, _value));
        addTotalSpentPerDay(token, getCurrentDay(), _value);

        setLock(true);
        token.transferFrom(msg.sender, to, _value);
        setLock(false);
        bridgeSpecificActionsOnTokenTransfer(token, msg.sender, _value, abi.encodePacked(_receiver));
    }

    
    function executeActionOnBridgedTokens(address _token, address _recipient, uint256 _value) internal {
        bytes32 _messageId = messageId();
        uint256 valueToMint = _value;
        uint256 fee = _distributeFee(FOREIGN_TO_HOME_FEE, _token, valueToMint);
        if (fee > 0) {
            emit FeeDistributed(fee, _token, _messageId);
            valueToMint = valueToMint.sub(fee);
        }
        IBurnableMintableERC677Token(_token).mint(_recipient, valueToMint);
        emit TokensBridged(_token, _recipient, valueToMint, _messageId);
    }

    
    function executeActionOnFixedTokens(address _token, address _recipient, uint256 _value) internal {
        IBurnableMintableERC677Token(_token).mint(_recipient, _value);
    }

    
    function homeTokenAddress(address _foreignToken) public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("homeTokenAddress", _foreignToken))];
    }

    
    function foreignTokenAddress(address _homeToken) public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("foreignTokenAddress", _homeToken))];
    }

    
    function _setTokenAddressPair(address _foreignToken, address _homeToken) internal {
        addressStorage[keccak256(abi.encodePacked("homeTokenAddress", _foreignToken))] = _homeToken;
        addressStorage[keccak256(abi.encodePacked("foreignTokenAddress", _homeToken))] = _foreignToken;
    }

    
    function _setTokenImage(address _tokenImage) internal {
        require(AddressUtils.isContract(_tokenImage));
        addressStorage[TOKEN_IMAGE_CONTRACT] = _tokenImage;
    }

    
    function bridgeSpecificActionsOnTokenTransfer(ERC677 _token, address _from, uint256 _value, bytes _data) internal {
        if (!lock()) {
            bytes32 _messageId = messageId();
            uint256 valueToBridge = _value;
            uint256 fee = _distributeFee(HOME_TO_FOREIGN_FEE, _token, valueToBridge);
            if (fee > 0) {
                emit FeeDistributed(fee, _token, _messageId);
                valueToBridge = valueToBridge.sub(fee);
            }
            IBurnableMintableERC677Token(_token).burn(valueToBridge);
            passMessage(_token, _from, chooseReceiver(_from, _data), valueToBridge);
        }
    }

    
    function passMessage(ERC677 _token, address _from, address _receiver, uint256 _value) internal {
        bytes4 methodSelector = this.handleBridgedTokens.selector;
        address foreignToken = foreignTokenAddress(_token);
        bytes memory data = abi.encodeWithSelector(methodSelector, foreignToken, _receiver, _value);

        bytes32 _messageId = bridgeContract().requireToPassMessage(
            mediatorContractOnOtherSide(),
            data,
            requestGasLimit()
        );

        setMessageToken(_messageId, _token);
        setMessageValue(_messageId, _value);
        setMessageRecipient(_messageId, _from);
    }
}



pragma solidity 0.4.24;


library TokenReader {
    
    function readName(address _token) internal view returns (string) {
        uint256 ptr;
        uint256 size;
        assembly {
            ptr := mload(0x40)
            mstore(ptr, 0x06fdde0300000000000000000000000000000000000000000000000000000000) 
            if iszero(staticcall(gas, _token, ptr, 4, ptr, 32)) {
                mstore(ptr, 0xa3f4df7e00000000000000000000000000000000000000000000000000000000) 
                staticcall(gas, _token, ptr, 4, ptr, 32)
                pop
            }

            mstore(0x40, add(ptr, returndatasize))

            switch gt(returndatasize, 32)
                case 1 {
                    returndatacopy(mload(0x40), 32, 32) 
                    size := mload(mload(0x40))
                }
                default {
                    size := returndatasize 
                }
        }
        string memory res = new string(size);
        assembly {
            if gt(returndatasize, 32) {
                
                returndatacopy(add(res, 32), 64, size)
                jump(exit)
            }
            
            if gt(returndatasize, 0) {
                let i := 0
                ptr := mload(ptr) 
                mstore(add(res, 32), ptr) 

                for { } gt(ptr, 0) { i := add(i, 1) } { 
                    ptr := shl(8, ptr) 
                }
                mstore(res, i) 
            }
            exit:
            
        }
        return res;
    }

    
    function readSymbol(address _token) internal view returns (string) {
        uint256 ptr;
        uint256 size;
        assembly {
            ptr := mload(0x40)
            mstore(ptr, 0x95d89b4100000000000000000000000000000000000000000000000000000000) 
            if iszero(staticcall(gas, _token, ptr, 4, ptr, 32)) {
                mstore(ptr, 0xf76f8d7800000000000000000000000000000000000000000000000000000000) 
                staticcall(gas, _token, ptr, 4, ptr, 32)
                pop
            }

            mstore(0x40, add(ptr, returndatasize))

            switch gt(returndatasize, 32)
                case 1 {
                    returndatacopy(mload(0x40), 32, 32) 
                    size := mload(mload(0x40))
                }
                default {
                    size := returndatasize 
                }
        }
        string memory res = new string(size);
        assembly {
            if gt(returndatasize, 32) {
                
                returndatacopy(add(res, 32), 64, size)
                jump(exit)
            }
            
            if gt(returndatasize, 0) {
                let i := 0
                ptr := mload(ptr) 
                mstore(add(res, 32), ptr) 

                for { } gt(ptr, 0) { i := add(i, 1) } { 
                    ptr := shl(8, ptr) 
                }
                mstore(res, i) 
            }
            exit:
            
        }
        return res;
    }

    
    function readDecimals(address _token) internal view returns (uint256) {
        uint256 decimals;
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 32))
            mstore(ptr, 0x313ce56700000000000000000000000000000000000000000000000000000000) 
            if iszero(staticcall(gas, _token, ptr, 4, ptr, 32)) {
                mstore(ptr, 0x2e0f262500000000000000000000000000000000000000000000000000000000) 
                if iszero(staticcall(gas, _token, ptr, 4, ptr, 32)) {
                    mstore(ptr, 0)
                }
            }
            decimals := mload(ptr)
        }
        return decimals;
    }
}



pragma solidity 0.4.24;






contract ForeignMultiAMBErc20ToErc677 is BasicMultiAMBErc20ToErc677 {
    
    function initialize(
        address _bridgeContract,
        address _mediatorContract,
        uint256[3] _dailyLimitMaxPerTxMinPerTxArray, 
        uint256[2] _executionDailyLimitExecutionMaxPerTxArray, 
        uint256 _requestGasLimit,
        address _owner
    ) external onlyRelevantSender returns (bool) {
        require(!isInitialized());
        require(_owner != address(0));

        _setBridgeContract(_bridgeContract);
        _setMediatorContractOnOtherSide(_mediatorContract);
        _setLimits(address(0), _dailyLimitMaxPerTxMinPerTxArray);
        _setExecutionLimits(address(0), _executionDailyLimitExecutionMaxPerTxArray);
        _setRequestGasLimit(_requestGasLimit);
        setOwner(_owner);

        setInitialize();

        return isInitialized();
    }

    
    function executeActionOnBridgedTokens(address _token, address _recipient, uint256 _value) internal {
        bytes32 _messageId = messageId();
        LegacyERC20(_token).transfer(_recipient, _value);
        _setMediatorBalance(_token, mediatorBalance(_token).sub(_value));
        emit TokensBridged(_token, _recipient, _value, _messageId);
    }

    
    function onTokenTransfer(address _from, uint256 _value, bytes _data) public returns (bool) {
        if (!lock()) {
            ERC677 token = ERC677(msg.sender);
            bridgeSpecificActionsOnTokenTransfer(token, _from, _value, _data);
        }
        return true;
    }

    
    function handleBridgedTokens(ERC677 _token, address _recipient, uint256 _value) external onlyMediator {
        require(isTokenRegistered(_token));
        _handleBridgedTokens(_token, _recipient, _value);
    }

    
    function _relayTokens(ERC677 token, address _receiver, uint256 _value) internal {
        
        
        
        require(!lock());
        address to = address(this);

        setLock(true);
        LegacyERC20(token).transferFrom(msg.sender, to, _value);
        setLock(false);
        bridgeSpecificActionsOnTokenTransfer(token, msg.sender, _value, abi.encodePacked(_receiver));
    }

    
    function bridgeSpecificActionsOnTokenTransfer(ERC677 _token, address _from, uint256 _value, bytes _data) internal {
        if (lock()) return;

        bool isKnownToken = isTokenRegistered(_token);
        if (!isKnownToken) {
            string memory name = TokenReader.readName(_token);
            string memory symbol = TokenReader.readSymbol(_token);
            uint8 decimals = uint8(TokenReader.readDecimals(_token));

            require(bytes(name).length > 0 || bytes(symbol).length > 0);

            _initializeTokenBridgeLimits(_token, decimals);
        }

        require(withinLimit(_token, _value));
        addTotalSpentPerDay(_token, getCurrentDay(), _value);

        bytes memory data;
        address receiver = chooseReceiver(_from, _data);

        if (isKnownToken) {
            data = abi.encodeWithSelector(this.handleBridgedTokens.selector, _token, receiver, _value);
        } else {
            data = abi.encodeWithSelector(
                HomeMultiAMBErc20ToErc677(this).deployAndHandleBridgedTokens.selector,
                _token,
                name,
                symbol,
                decimals,
                receiver,
                _value
            );
        }

        _setMediatorBalance(_token, mediatorBalance(_token).add(_value));

        bytes32 _messageId = bridgeContract().requireToPassMessage(
            mediatorContractOnOtherSide(),
            data,
            requestGasLimit()
        );

        setMessageToken(_messageId, _token);
        setMessageValue(_messageId, _value);
        setMessageRecipient(_messageId, _from);

        if (!isKnownToken) {
            _setTokenRegistrationMessageId(_token, _messageId);
        }
    }

    
    function fixFailedMessage(bytes32 _messageId) public {
        super.fixFailedMessage(_messageId);
        address token = messageToken(_messageId);
        if (_messageId == tokenRegistrationMessageId(token)) {
            delete uintStorage[keccak256(abi.encodePacked("dailyLimit", token))];
            delete uintStorage[keccak256(abi.encodePacked("maxPerTx", token))];
            delete uintStorage[keccak256(abi.encodePacked("minPerTx", token))];
            delete uintStorage[keccak256(abi.encodePacked("executionDailyLimit", token))];
            delete uintStorage[keccak256(abi.encodePacked("executionMaxPerTx", token))];
            _setTokenRegistrationMessageId(token, bytes32(0));
        }
    }

    
    function executeActionOnFixedTokens(address _token, address _recipient, uint256 _value) internal {
        _setMediatorBalance(_token, mediatorBalance(_token).sub(_value));
        LegacyERC20(_token).transfer(_recipient, _value);
    }

    
    function fixMediatorBalance(address _token, address _receiver) public onlyIfUpgradeabilityOwner {
        require(isTokenRegistered(_token));
        uint256 balance = ERC677(_token).balanceOf(address(this));
        uint256 expectedBalance = mediatorBalance(_token);
        require(balance > expectedBalance);
        uint256 diff = balance - expectedBalance;
        uint256 available = maxAvailablePerTx(_token);
        require(available > 0);
        if (diff > available) {
            diff = available;
        }
        addTotalSpentPerDay(_token, getCurrentDay(), diff);
        _setMediatorBalance(_token, expectedBalance.add(diff));

        bytes memory data = abi.encodeWithSelector(this.handleBridgedTokens.selector, _token, _receiver, diff);

        bytes32 _messageId = bridgeContract().requireToPassMessage(
            mediatorContractOnOtherSide(),
            data,
            requestGasLimit()
        );

        setMessageToken(_messageId, _token);
        setMessageValue(_messageId, diff);
        setMessageRecipient(_messageId, _receiver);
    }

    
    function mediatorBalance(address _token) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("mediatorBalance", _token))];
    }

    
    function tokenRegistrationMessageId(address _token) public view returns (bytes32) {
        return bytes32(uintStorage[keccak256(abi.encodePacked("tokenRegistrationMessageId", _token))]);
    }

    
    function _setMediatorBalance(address _token, uint256 _balance) internal {
        uintStorage[keccak256(abi.encodePacked("mediatorBalance", _token))] = _balance;
    }

    
    function _setTokenRegistrationMessageId(address _token, bytes32 _messageId) internal {
        uintStorage[keccak256(abi.encodePacked("tokenRegistrationMessageId", _token))] = uint256(_messageId);
    }
}