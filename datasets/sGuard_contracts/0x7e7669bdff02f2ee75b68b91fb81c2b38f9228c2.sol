pragma solidity 0.4.24;


contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}



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



pragma solidity 0.4.24;

interface IBridgeValidators {
    function isValidator(address _validator) external view returns (bool);
    function requiredSignatures() external view returns (uint256);
    function owner() external view returns (address);
}



pragma solidity 0.4.24;

contract ValidatorStorage {
    bytes32 internal constant VALIDATOR_CONTRACT = 0x5a74bb7e202fb8e4bf311841c7d64ec19df195fee77d7e7ae749b27921b6ddfe; 
}



pragma solidity 0.4.24;




contract Validatable is EternalStorage, ValidatorStorage {
    function validatorContract() public view returns (IBridgeValidators) {
        return IBridgeValidators(addressStorage[VALIDATOR_CONTRACT]);
    }

    modifier onlyValidator() {
        require(validatorContract().isValidator(msg.sender));
        
        _;
    }

    function requiredSignatures() public view returns (uint256) {
        return validatorContract().requiredSignatures();
    }

}



pragma solidity 0.4.24;


library Message {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    function addressArrayContains(address[] array, address value) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    function parseMessage(bytes message)
        internal
        pure
        returns (address recipient, uint256 amount, bytes32 txHash, address contractAddress)
    {
        require(isMessageValid(message));
        assembly {
            recipient := mload(add(message, 20))
            amount := mload(add(message, 52))
            txHash := mload(add(message, 84))
            contractAddress := mload(add(message, 104))
        }
    }

    function isMessageValid(bytes _msg) internal pure returns (bool) {
        return _msg.length == requiredMessageLength();
    }

    function requiredMessageLength() internal pure returns (uint256) {
        return 104;
    }

    function recoverAddressFromSignedMessage(bytes signature, bytes message, bool isAMBMessage)
        internal
        pure
        returns (address)
    {
        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        bytes1 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        return ecrecover(hashMessage(message, isAMBMessage), uint8(v), r, s);
    }

    function hashMessage(bytes message, bool isAMBMessage) internal pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        if (isAMBMessage) {
            return keccak256(abi.encodePacked(prefix, uintToString(message.length), message));
        } else {
            string memory msgLength = "104";
            return keccak256(abi.encodePacked(prefix, msgLength, message));
        }
    }

    
    function hasEnoughValidSignatures(
        bytes _message,
        bytes _signatures,
        IBridgeValidators _validatorContract,
        bool isAMBMessage
    ) internal view {
        require(isAMBMessage || isMessageValid(_message));
        uint256 requiredSignatures = _validatorContract.requiredSignatures();
        uint256 amount;
        assembly {
            amount := and(mload(add(_signatures, 1)), 0xff)
        }
        require(amount >= requiredSignatures);
        bytes32 hash = hashMessage(_message, isAMBMessage);
        address[] memory encounteredAddresses = new address[](requiredSignatures);

        for (uint256 i = 0; i < requiredSignatures; i++) {
            uint8 v;
            bytes32 r;
            bytes32 s;
            uint256 posr = 33 + amount + 32 * i;
            uint256 poss = posr + 32 * amount;
            assembly {
                v := mload(add(_signatures, add(2, i)))
                r := mload(add(_signatures, posr))
                s := mload(add(_signatures, poss))
            }

            address recoveredAddress = ecrecover(hash, v, r, s);
            require(_validatorContract.isValidator(recoveredAddress));
            require(!addressArrayContains(encounteredAddresses, recoveredAddress));
            encounteredAddresses[i] = recoveredAddress;
        }
    }

    function uintToString(uint256 i) internal pure returns (string) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (i != 0) {
            bstr[k--] = bytes1(48 + (i % 10));
            i /= 10;
        }
        return string(bstr);
    }
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




contract BasicTokenBridge is EternalStorage, Ownable {
    using SafeMath for uint256;

    event DailyLimitChanged(uint256 newLimit);
    event ExecutionDailyLimitChanged(uint256 newLimit);

    bytes32 internal constant MIN_PER_TX = 0xbbb088c505d18e049d114c7c91f11724e69c55ad6c5397e2b929e68b41fa05d1; 
    bytes32 internal constant MAX_PER_TX = 0x0f8803acad17c63ee38bf2de71e1888bc7a079a6f73658e274b08018bea4e29c; 
    bytes32 internal constant DAILY_LIMIT = 0x4a6a899679f26b73530d8cf1001e83b6f7702e04b6fdb98f3c62dc7e47e041a5; 
    bytes32 internal constant EXECUTION_MAX_PER_TX = 0xc0ed44c192c86d1cc1ba51340b032c2766b4a2b0041031de13c46dd7104888d5; 
    bytes32 internal constant EXECUTION_DAILY_LIMIT = 0x21dbcab260e413c20dc13c28b7db95e2b423d1135f42bb8b7d5214a92270d237; 
    bytes32 internal constant DECIMAL_SHIFT = 0x1e8ecaafaddea96ed9ac6d2642dcdfe1bebe58a930b1085842d8fc122b371ee5; 

    function totalSpentPerDay(uint256 _day) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))];
    }

    function totalExecutedPerDay(uint256 _day) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))];
    }

    function dailyLimit() public view returns (uint256) {
        return uintStorage[DAILY_LIMIT];
    }

    function executionDailyLimit() public view returns (uint256) {
        return uintStorage[EXECUTION_DAILY_LIMIT];
    }

    function maxPerTx() public view returns (uint256) {
        return uintStorage[MAX_PER_TX];
    }

    function executionMaxPerTx() public view returns (uint256) {
        return uintStorage[EXECUTION_MAX_PER_TX];
    }

    function minPerTx() public view returns (uint256) {
        return uintStorage[MIN_PER_TX];
    }

    function decimalShift() public view returns (uint256) {
        return uintStorage[DECIMAL_SHIFT];
    }

    function withinLimit(uint256 _amount) public view returns (bool) {
        uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);
        return dailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();
    }

    function withinExecutionLimit(uint256 _amount) public view returns (bool) {
        uint256 nextLimit = totalExecutedPerDay(getCurrentDay()).add(_amount);
        return executionDailyLimit() >= nextLimit && _amount <= executionMaxPerTx();
    }

    function getCurrentDay() public view returns (uint256) {
        
        return now / 1 days;
    }

    function setTotalSpentPerDay(uint256 _day, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))] = _value;
    }

    function setTotalExecutedPerDay(uint256 _day, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))] = _value;
    }

    function setDailyLimit(uint256 _dailyLimit) external onlyOwner {
        require(_dailyLimit > maxPerTx() || _dailyLimit == 0);
        uintStorage[DAILY_LIMIT] = _dailyLimit;
        emit DailyLimitChanged(_dailyLimit);
    }

    function setExecutionDailyLimit(uint256 _dailyLimit) external onlyOwner {
        require(_dailyLimit > executionMaxPerTx() || _dailyLimit == 0);
        uintStorage[EXECUTION_DAILY_LIMIT] = _dailyLimit;
        emit ExecutionDailyLimitChanged(_dailyLimit);
    }

    function setExecutionMaxPerTx(uint256 _maxPerTx) external onlyOwner {
        require(_maxPerTx < executionDailyLimit());
        uintStorage[EXECUTION_MAX_PER_TX] = _maxPerTx;
    }

    function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {
        require(_maxPerTx == 0 || (_maxPerTx > minPerTx() && _maxPerTx < dailyLimit()));
        uintStorage[MAX_PER_TX] = _maxPerTx;
    }

    function setMinPerTx(uint256 _minPerTx) external onlyOwner {
        require(_minPerTx > 0 && _minPerTx < dailyLimit() && _minPerTx < maxPerTx());
        uintStorage[MIN_PER_TX] = _minPerTx;
    }
}



pragma solidity 0.4.24;


contract MessageRelay is EternalStorage {
    function relayedMessages(bytes32 _txHash) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))];
    }

    function setRelayedMessages(bytes32 _txHash, bool _status) internal {
        boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))] = _status;
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


contract InitializableBridge is Initializable {
    bytes32 internal constant DEPLOYED_AT_BLOCK = 0xb120ceec05576ad0c710bc6e85f1768535e27554458f05dcbb5c65b8c7a749b0; 

    function deployedAtBlock() external view returns (uint256) {
        return uintStorage[DEPLOYED_AT_BLOCK];
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

contract Sacrifice {
    constructor(address _recipient) public payable {
        selfdestruct(_recipient);
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
        if (!_to.send(value)) {
            (new Sacrifice).value(value)(_to);
        }
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
        return (3, 0, 0);
    }

    
    function getBridgeMode() external pure returns (bytes4);
}



pragma solidity 0.4.24;








contract BasicBridge is InitializableBridge, Validatable, Ownable, Upgradeable, Claimable, VersionableBridge {
    event GasPriceChanged(uint256 gasPrice);
    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);

    bytes32 internal constant GAS_PRICE = 0x55b3774520b5993024893d303890baa4e84b1244a43c60034d1ced2d3cf2b04b; 
    bytes32 internal constant REQUIRED_BLOCK_CONFIRMATIONS = 0x916daedf6915000ff68ced2f0b6773fe6f2582237f92c3c95bb4d79407230071; 

    function setGasPrice(uint256 _gasPrice) external onlyOwner {
        require(_gasPrice > 0);
        uintStorage[GAS_PRICE] = _gasPrice;
        emit GasPriceChanged(_gasPrice);
    }

    function gasPrice() external view returns (uint256) {
        return uintStorage[GAS_PRICE];
    }

    function setRequiredBlockConfirmations(uint256 _blockConfirmations) external onlyOwner {
        require(_blockConfirmations > 0);
        uintStorage[REQUIRED_BLOCK_CONFIRMATIONS] = _blockConfirmations;
        emit RequiredBlockConfirmationChanged(_blockConfirmations);
    }

    function requiredBlockConfirmations() external view returns (uint256) {
        return uintStorage[REQUIRED_BLOCK_CONFIRMATIONS];
    }

    function claimTokens(address _token, address _to) public onlyIfUpgradeabilityOwner validAddress(_to) {
        claimValues(_token, _to);
    }
}



pragma solidity 0.4.24;










contract BasicForeignBridge is EternalStorage, Validatable, BasicBridge, BasicTokenBridge, MessageRelay {
    
    event RelayedMessage(address recipient, uint256 value, bytes32 transactionHash);
    event UserRequestForAffirmation(address recipient, uint256 value);

    
    function executeSignatures(bytes message, bytes signatures) external {
        Message.hasEnoughValidSignatures(message, signatures, validatorContract(), false);

        address recipient;
        uint256 amount;
        bytes32 txHash;
        address contractAddress;
        (recipient, amount, txHash, contractAddress) = Message.parseMessage(message);
        if (withinExecutionLimit(amount)) {
            require(contractAddress == address(this));
            require(!relayedMessages(txHash));
            setRelayedMessages(txHash, true);
            require(onExecuteMessage(recipient, amount, txHash));
            emit RelayedMessage(recipient, amount, txHash);
        } else {
            onFailedMessage(recipient, amount, txHash);
        }
    }

    
    function onExecuteMessage(address, uint256, bytes32) internal returns (bool);

    
    function onFailedMessage(address, uint256, bytes32) internal;
}



pragma solidity 0.4.24;




contract ERC20Bridge is BasicForeignBridge {
    bytes32 internal constant ERC20_TOKEN = 0x15d63b18dbc21bf4438b7972d80076747e1d93c4f87552fe498c90cbde51665e; 

    function erc20token() public view returns (ERC20) {
        return ERC20(addressStorage[ERC20_TOKEN]);
    }

    function setErc20token(address _token) internal {
        require(AddressUtils.isContract(_token));
        addressStorage[ERC20_TOKEN] = _token;
    }

    function _relayTokens(address _sender, address _receiver, uint256 _amount) internal {
        require(_receiver != address(0));
        require(_receiver != address(this));
        require(_amount > 0);
        require(withinLimit(_amount));
        setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(_amount));

        erc20token().transferFrom(_sender, address(this), _amount);
        emit UserRequestForAffirmation(_receiver, _amount);
    }

    function relayTokens(address _from, address _receiver, uint256 _amount) external {
        require(_from == msg.sender || _from == _receiver);
        _relayTokens(_from, _receiver, _amount);
    }

    function relayTokens(address _receiver, uint256 _amount) external {
        _relayTokens(msg.sender, _receiver, _amount);
    }
}



pragma solidity 0.4.24;


contract OtherSideBridgeStorage is EternalStorage {
    bytes32 internal constant BRIDGE_CONTRACT = 0x71483949fe7a14d16644d63320f24d10cf1d60abecc30cc677a340e82b699dd2; 

    function _setBridgeContractOnOtherSide(address _bridgeContract) internal {
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    function bridgeContractOnOtherSide() internal view returns (address) {
        return addressStorage[BRIDGE_CONTRACT];
    }
}



pragma solidity 0.4.24;

interface IScdMcdMigration {
    function swapSaiToDai(uint256 wad) external;
    function daiJoin() external returns (address);
}

interface IDaiAdapter {
    function dai() public returns (address);
}

interface ISaiTop {
    function caged() public returns (uint256);
}



pragma solidity 0.4.24;

interface IPot {
    function chi() external view returns (uint256);
    function rho() external view returns (uint256);
    function drip() external returns (uint256);
}



pragma solidity 0.4.24;



interface IChai {
    function pot() external view returns (IPot);
    function daiToken() external view returns (ERC20);
    function balanceOf(address) external view returns (uint256);
    function dai(address) external view returns (uint256);
    function join(address, uint256) external;
    function draw(address, uint256) external;
    function exit(address, uint256) external;
    function transfer(address, uint256) external;
}



pragma solidity 0.4.24;

contract ERC677Receiver {
    function onTokenTransfer(address _from, uint256 _value, bytes _data) external returns (bool);
}



pragma solidity 0.4.24;

contract TokenSwapper {
    
    event TokensSwapped(address indexed from, address indexed to, uint256 value);
}



pragma solidity 0.4.24;








contract ChaiConnector is Ownable, ERC20Bridge, TokenSwapper {
    using SafeMath for uint256;

    
    event PaidInterest(address to, uint256 value);

    bytes32 internal constant CHAI_TOKEN_ENABLED = 0x2ae87563606f93f71ad2adf4d62661ccdfb63f3f508f94700934d5877fb92278; 
    bytes32 internal constant INTEREST_RECEIVER = 0xd88509eb1a8da5d5a2fc7b9bad1c72874c9818c788e81d0bc46b29bfaa83adf6; 
    bytes32 internal constant INTEREST_COLLECTION_PERIOD = 0x68a6a652d193e5d6439c4309583048050a11a4cfb263a220f4cd798c61c3ad6e; 
    bytes32 internal constant LAST_TIME_INTEREST_PAID = 0xcabd46177a706f95f4bb3e2c2ba45ac4aa1eac9c545425a19c62ab6de4aeea26; 
    bytes32 internal constant INVESTED_AMOUNT = 0xb6afb3323c9d7dc0e9dab5d34c3a1d1ae7739d2224c048d4ee7675d3c759dd1b; 
    bytes32 internal constant MIN_DAI_TOKEN_BALANCE = 0xce70e1dac97909c26a87aa4ada3d490673a153b3a75b22ea3364c4c7df7c551f; 
    bytes4 internal constant ON_TOKEN_TRANSFER = 0xa4c0ed36; 

    uint256 internal constant ONE = 10**27;

    
    modifier chaiTokenEnabled {
        require(isChaiTokenEnabled());
        
        _;
    }

    
    function rdivup(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mul(ONE).add(y.sub(1)) / y;
    }

    
    function isChaiTokenEnabled() public view returns (bool) {
        return boolStorage[CHAI_TOKEN_ENABLED];
    }

    
    function chaiToken() public view returns (IChai) {
        return IChai(0x06AF07097C9Eeb7fD685c692751D5C66dB49c215);
    }

    
    function initializeChaiToken() public onlyOwner {
        require(!isChaiTokenEnabled());
        require(address(chaiToken().daiToken()) == address(erc20token()));
        boolStorage[CHAI_TOKEN_ENABLED] = true;
        uintStorage[MIN_DAI_TOKEN_BALANCE] = 100 ether;
        uintStorage[INTEREST_COLLECTION_PERIOD] = 1 weeks;
    }

    
    function initializeChaiToken(address _interestReceiver) external {
        require(_interestReceiver != address(0));
        
        initializeChaiToken();
        addressStorage[INTEREST_RECEIVER] = _interestReceiver;
    }

    
    function setMinDaiTokenBalance(uint256 _minBalance) external onlyOwner {
        uintStorage[MIN_DAI_TOKEN_BALANCE] = _minBalance;
    }

    
    function minDaiTokenBalance() public view returns (uint256) {
        return uintStorage[MIN_DAI_TOKEN_BALANCE];
    }

    
    function removeChaiToken() external onlyOwner chaiTokenEnabled {
        _convertChaiToDai(investedAmountInDai());
        _payInterest();
        delete boolStorage[CHAI_TOKEN_ENABLED];
    }

    
    function interestReceiver() public view returns (ERC677Receiver) {
        return ERC677Receiver(addressStorage[INTEREST_RECEIVER]);
    }

    
    function setInterestReceiver(address receiver) external onlyOwner {
        
        
        
        
        
        
        require(receiver != address(this));

        addressStorage[INTEREST_RECEIVER] = receiver;
    }

    
    function lastInterestPayment() public view returns (uint256) {
        return uintStorage[LAST_TIME_INTEREST_PAID];
    }

    
    function interestCollectionPeriod() public view returns (uint256) {
        return uintStorage[INTEREST_COLLECTION_PERIOD];
    }

    
    function setInterestCollectionPeriod(uint256 period) external onlyOwner {
        uintStorage[INTEREST_COLLECTION_PERIOD] = period;
    }

    
    function payInterest() external chaiTokenEnabled {
        if (
            
            lastInterestPayment() + interestCollectionPeriod() < now ||
            IUpgradeabilityOwnerStorage(this).upgradeabilityOwner() == msg.sender
        ) {
            _payInterest();
        }
    }

    
    function _payInterest() internal {
        address receiver = address(interestReceiver());
        require(receiver != address(0));

        
        
        

        
        uintStorage[LAST_TIME_INTEREST_PAID] = now;

        uint256 interest = chaiBalance().sub(investedAmountInChai());
        
        
        chaiToken().transfer(receiver, interest);

        receiver.call(abi.encodeWithSelector(ON_TOKEN_TRANSFER, address(this), interest, ""));

        // Additional constant to tolerate the DAI balance deposited to the Chai token is not needed here, since we allow to withdraw only extra part of chai balance,
        // which is not necessary to cover 100% dai balance.
        // It is guaranteed that the withdrawal of interest won't left the bridge balance uncovered.
        require(dsrBalance() >= investedAmountInDai());

        emit PaidInterest(receiver, interest);
    }

    /**
    * @dev Evaluates bridge balance for tokens, holded in DSR
    * @return Balance in dai, truncated
    */
    function dsrBalance() public view returns (uint256) {
        return chaiToken().dai(address(this));
    }

    /**
    * @dev Evaluates bridge balance in Chai tokens
    * @return Balance in chai, exact
    */
    function chaiBalance() public view returns (uint256) {
        return chaiToken().balanceOf(address(this));
    }

    /**
    * @dev Evaluates bridge balance in Dai tokens
    * @return Balance in Dai
    */
    function daiBalance() internal view returns (uint256) {
        return erc20token().balanceOf(address(this));
    }

    /**
    * @dev Evaluates exact current invested amount, in DAI
    * @return Value in DAI
    */
    function investedAmountInDai() public view returns (uint256) {
        return uintStorage[INVESTED_AMOUNT];
    }

    /**
    * @dev Updates current invested amount, in DAI
    * @return Value in DAI
    */
    function setInvestedAmountInDai(uint256 amount) internal {
        uintStorage[INVESTED_AMOUNT] = amount;
    }

    /**
    * @dev Evaluates amount of chai tokens that is sufficent to cover 100% of the invested DAI
    * @return Amount in chai, ceiled
    */
    function investedAmountInChai() internal returns (uint256) {
        IPot pot = chaiToken().pot();
        // solhint-disable-next-line not-rely-on-time
        uint256 chi = (now > pot.rho()) ? pot.drip() : pot.chi();
        return rdivup(investedAmountInDai(), chi);
    }

    /**
    * @dev Checks if DAI balance is high enough to be partially converted to Chai
    * Twice limit is used in order to decrease frequency of convertDaiToChai calls,
    * In case of high bridge utilization in DAI => xDAI direction,
    * convertDaiToChai() will be called as soon as DAI balance reaches 2 * limit,
    * limit DAI will be left as a buffer for future operations.
    * @return true if convertDaiToChai() call is needed to be performed by the oracle
    */
    function isDaiNeedsToBeInvested() public view returns (bool) {
        // chai token needs to be initialized, DAI balance should be at least twice greater than minDaiTokenBalance
        return isChaiTokenEnabled() && daiBalance() > 2 * minDaiTokenBalance();
    }

    /**
    * @dev Converts all DAI into Chai tokens, keeping minDaiTokenBalance() DAI as a buffer
    */
    function convertDaiToChai() public chaiTokenEnabled {
        // there is not need to consider overflow when performing a + operation,
        // since both values are controlled by the bridge and can't take extremely high values
        uint256 amount = daiBalance().sub(minDaiTokenBalance());

        require(amount > 0); // revert and save gas if there is nothing to convert

        uint256 newInvestedAmountInDai = investedAmountInDai() + amount;
        setInvestedAmountInDai(newInvestedAmountInDai);
        erc20token().approve(chaiToken(), amount);
        chaiToken().join(address(this), amount);

        // When evaluating the amount of DAI kept in Chai using dsrBalance(), there are some fixed point truncations.
        // The dependency between invested amount of DAI - value and returned value of dsrBalance() - res is the following:
        // res = floor(floor(value / K) * K)), where K is the fixed-point coefficient
        // from MakerDAO Pot contract (K = pot.chi() / 10**27).
        // This can lead up to losses of ceil(K) DAI in this balance evaluation.
        // The constant is needed here for making sure that everything works fine, and this error is small enough
        // The 10000 constant is considered to be small enough when decimals = 18, however,
        // it is not recommended to use it for smaller values of decimals, since it won't be negligible anymore
        require(dsrBalance() + 10000 >= newInvestedAmountInDai);

        emit TokensSwapped(erc20token(), chaiToken(), amount);
    }

    /**
    * @dev Redeems DAI from Chai, the total redeemed amount will be at least equal to specified amount
    * @param amount Amount of DAI to redeem
    */
    function _convertChaiToDai(uint256 amount) internal {
        if (amount == 0) return;

        uint256 invested = investedAmountInDai();
        uint256 initialDaiBalance = daiBalance();

        // onExecuteMessage can call a convert operation with argument greater than the current invested amount,
        // in this case bridge should withdraw all invested funds
        uint256 withdrawal = amount >= invested ? invested : amount;

        chaiToken().draw(address(this), withdrawal);
        uint256 redeemed = daiBalance() - initialDaiBalance;

        // Make sure that at least withdrawal amount was withdrawn
        require(redeemed >= withdrawal);

        uint256 newInvested = invested > redeemed ? invested - redeemed : 0;
        setInvestedAmountInDai(newInvested);

        // see comment in convertDaiToChai() for similar statement
        require(dsrBalance() + 10000 >= newInvested);

        emit TokensSwapped(chaiToken(), erc20token(), redeemed);
    }
}

// File: contracts/upgradeable_contracts/erc20_to_native/ForeignBridgeErcToNative.sol

pragma solidity 0.4.24;






contract ForeignBridgeErcToNative is BasicForeignBridge, ERC20Bridge, OtherSideBridgeStorage, ChaiConnector {
    bytes32 internal constant MIN_HDTOKEN_BALANCE = 0x48649cf195feb695632309f41e61252b09f537943654bde13eb7bb1bca06964e; // keccak256(abi.encodePacked("minHDTokenBalance"))
    bytes32 internal constant LOCKED_SAI_FIXED = 0xbeb8b2ece34b32b36c9cc00744143b61b2c23f93adcc3ce78d38937229423051; 
    bytes4 internal constant SWAP_TOKENS = 0x73d00224; 

    function initialize(
        address _validatorContract,
        address _erc20token,
        uint256 _requiredBlockConfirmations,
        uint256 _gasPrice,
        uint256[] _dailyLimitMaxPerTxMinPerTxArray, 
        uint256[] _homeDailyLimitHomeMaxPerTxArray, 
        address _owner,
        uint256 _decimalShift,
        address _bridgeOnOtherSide
    ) external onlyRelevantSender returns (bool) {
        require(!isInitialized());
        require(AddressUtils.isContract(_validatorContract));
        require(_requiredBlockConfirmations != 0);
        require(_gasPrice > 0);
        require(
            _dailyLimitMaxPerTxMinPerTxArray[2] > 0 && 
                _dailyLimitMaxPerTxMinPerTxArray[1] > _dailyLimitMaxPerTxMinPerTxArray[2] && 
                _dailyLimitMaxPerTxMinPerTxArray[0] > _dailyLimitMaxPerTxMinPerTxArray[1] 
        );
        require(_homeDailyLimitHomeMaxPerTxArray[1] < _homeDailyLimitHomeMaxPerTxArray[0]); 
        require(_owner != address(0));
        require(_bridgeOnOtherSide != address(0));

        addressStorage[VALIDATOR_CONTRACT] = _validatorContract;
        setErc20token(_erc20token);
        uintStorage[DEPLOYED_AT_BLOCK] = block.number;
        uintStorage[REQUIRED_BLOCK_CONFIRMATIONS] = _requiredBlockConfirmations;
        uintStorage[GAS_PRICE] = _gasPrice;
        uintStorage[DAILY_LIMIT] = _dailyLimitMaxPerTxMinPerTxArray[0];
        uintStorage[MAX_PER_TX] = _dailyLimitMaxPerTxMinPerTxArray[1];
        uintStorage[MIN_PER_TX] = _dailyLimitMaxPerTxMinPerTxArray[2];
        uintStorage[EXECUTION_DAILY_LIMIT] = _homeDailyLimitHomeMaxPerTxArray[0];
        uintStorage[EXECUTION_MAX_PER_TX] = _homeDailyLimitHomeMaxPerTxArray[1];
        uintStorage[DECIMAL_SHIFT] = _decimalShift;
        setOwner(_owner);
        _setBridgeContractOnOtherSide(_bridgeOnOtherSide);
        setInitialize();

        emit RequiredBlockConfirmationChanged(_requiredBlockConfirmations);
        emit GasPriceChanged(_gasPrice);
        emit DailyLimitChanged(_dailyLimitMaxPerTxMinPerTxArray[0]);
        emit ExecutionDailyLimitChanged(_homeDailyLimitHomeMaxPerTxArray[0]);

        return isInitialized();
    }

    function getBridgeMode() external pure returns (bytes4 _data) {
        return 0x18762d46; 
    }

    function fixLockedSai(address _receiver) external {
        require(msg.sender == address(this));
        require(!boolStorage[LOCKED_SAI_FIXED]);
        boolStorage[LOCKED_SAI_FIXED] = true;
        setInvestedAmountInDai(investedAmountInDai() + 49938645266079271041);
        claimValues(halfDuplexErc20token(), _receiver);
    }
    
    function claimTokens(address _token, address _to) public {
        require(_token != address(erc20token()));
        
        require(_token != address(chaiToken()) || !isChaiTokenEnabled());
        if (_token == address(halfDuplexErc20token())) {
            
            
            require(!isTokenSwapAllowed(now));
        }
        super.claimTokens(_token, _to);
    }

    function onExecuteMessage(
        address _recipient,
        uint256 _amount,
        bytes32 
    ) internal returns (bool) {
        setTotalExecutedPerDay(getCurrentDay(), totalExecutedPerDay(getCurrentDay()).add(_amount));
        uint256 amount = _amount.div(10**decimalShift());

        uint256 currentBalance = tokenBalance(erc20token());

        
        
        
        
        if (currentBalance < amount) {
            _convertChaiToDai(amount.sub(currentBalance).add(minDaiTokenBalance()));
        }

        bool res = erc20token().transfer(_recipient, amount);

        if (tokenBalance(halfDuplexErc20token()) > 0) {
            address(this).call(abi.encodeWithSelector(SWAP_TOKENS));
        }

        return res;
    }

    function onFailedMessage(address, uint256, bytes32) internal {
        revert();
    }

    function saiTopContract() internal pure returns (ISaiTop) {
        return ISaiTop(0x9b0ccf7C8994E19F39b2B4CF708e0A7DF65fA8a3);
    }

    function isTokenSwapAllowed(
        uint256 
    ) public pure returns (bool) {
        return false;
    }

    function halfDuplexErc20token() public pure returns (ERC20) {
        return ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    }

    function setMinHDTokenBalance(uint256 _minBalance) external onlyOwner {
        uintStorage[MIN_HDTOKEN_BALANCE] = _minBalance;
    }

    function minHDTokenBalance() public view returns (uint256) {
        return uintStorage[MIN_HDTOKEN_BALANCE];
    }

    function isHDTokenBalanceAboveMinBalance() public view returns (bool) {
        if (tokenBalance(halfDuplexErc20token()) > minHDTokenBalance()) {
            return true;
        }
        return false;
    }

    function tokenBalance(ERC20 _token) internal view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function migrationContract() internal pure returns (IScdMcdMigration) {
        return IScdMcdMigration(0xc73e0383F3Aff3215E6f04B0331D58CeCf0Ab849);
    }

    function swapTokens() public {
        
        require(isTokenSwapAllowed(now));

        IScdMcdMigration mcdMigrationContract = migrationContract();
        ERC20 hdToken = halfDuplexErc20token();
        ERC20 fdToken = erc20token();

        uint256 curHDTokenBalance = tokenBalance(hdToken);
        require(curHDTokenBalance > 0);

        uint256 curFDTokenBalance = tokenBalance(fdToken);

        require(hdToken.approve(mcdMigrationContract, curHDTokenBalance));
        mcdMigrationContract.swapSaiToDai(curHDTokenBalance);

        require(tokenBalance(fdToken).sub(curFDTokenBalance) == curHDTokenBalance);

        emit TokensSwapped(hdToken, fdToken, curHDTokenBalance);
    }

    function relayTokens(address _receiver, uint256 _amount) external {
        _relayTokens(msg.sender, _receiver, _amount, erc20token());
    }

    function relayTokens(address _sender, address _receiver, uint256 _amount) external {
        relayTokens(_sender, _receiver, _amount, erc20token());
    }

    function relayTokens(address _from, address _receiver, uint256 _amount, address _token) public {
        require(_from == msg.sender || _from == _receiver);
        _relayTokens(_from, _receiver, _amount, _token);
    }

    function relayTokens(address _receiver, uint256 _amount, address _token) external {
        _relayTokens(msg.sender, _receiver, _amount, _token);
    }

    function _relayTokens(address _sender, address _receiver, uint256 _amount, address _token) internal {
        require(_receiver != bridgeContractOnOtherSide());
        require(_receiver != address(0));
        require(_receiver != address(this));
        require(_amount > 0);
        require(withinLimit(_amount));

        ERC20 tokenToOperate = ERC20(_token);
        ERC20 hdToken = halfDuplexErc20token();
        ERC20 fdToken = erc20token();

        if (tokenToOperate == ERC20(0x0)) {
            tokenToOperate = fdToken;
        }

        require(tokenToOperate == fdToken || tokenToOperate == hdToken);

        setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(_amount));

        tokenToOperate.transferFrom(_sender, address(this), _amount);
        emit UserRequestForAffirmation(_receiver, _amount);

        if (tokenToOperate == hdToken) {
            swapTokens();
        }
        if (isDaiNeedsToBeInvested()) {
            convertDaiToChai();
        }
    }
}