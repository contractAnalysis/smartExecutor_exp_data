pragma solidity 0.4.24;

interface IBridgeValidators {
    function isValidator(address _validator) external view returns (bool);
    function requiredSignatures() external view returns (uint256);
    function owner() external view returns (address);
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



pragma solidity 0.4.24;

library ArbitraryMessage {
    
    function unpackData(bytes _data)
        internal
        pure
        returns (
            bytes32 messageId,
            address sender,
            address executor,
            uint32 gasLimit,
            bytes1 dataType,
            uint256[2] chainIds,
            uint256 gasPrice,
            bytes memory data
        )
    {
        
        uint256 srcdataptr = 32 + 20 + 20 + 4 + 1 + 1 + 1;
        uint256 datasize;

        assembly {
            messageId := mload(add(_data, 32)) 
            sender := and(mload(add(_data, 52)), 0xffffffffffffffffffffffffffffffffffffffff) 

            
            let blob := mload(add(_data, 84))

            
            executor := shr(96, blob)
            gasLimit := and(shr(64, blob), 0xffffffff)

            
            let chainIdLength := byte(24, blob)

            dataType := and(shl(208, blob), 0xFF00000000000000000000000000000000000000000000000000000000000000)
            switch dataType
                case 0x0000000000000000000000000000000000000000000000000000000000000000 {
                    gasPrice := 0
                }
                case 0x0100000000000000000000000000000000000000000000000000000000000000 {
                    gasPrice := mload(add(_data, 111)) 
                    srcdataptr := add(srcdataptr, 32)
                }
                case 0x0200000000000000000000000000000000000000000000000000000000000000 {
                    gasPrice := 0
                    srcdataptr := add(srcdataptr, 1)
                }

            

            
            
            let mask := sub(shl(shl(3, chainIdLength), 1), 1)

            
            srcdataptr := add(srcdataptr, chainIdLength)

            
            mstore(chainIds, and(mload(add(_data, srcdataptr)), mask))

            

            
            chainIdLength := byte(25, blob)

            
            
            mask := sub(shl(shl(3, chainIdLength), 1), 1)

            
            srcdataptr := add(srcdataptr, chainIdLength)

            
            mstore(add(chainIds, 32), and(mload(add(_data, srcdataptr)), mask))

            

            
            datasize := sub(mload(_data), srcdataptr)
        }

        data = new bytes(datasize);
        assembly {
            
            srcdataptr := add(srcdataptr, 36)

            
            calldatacopy(add(data, 32), add(calldataload(4), srcdataptr), datasize)
        }
    }
}



pragma solidity 0.4.24;

interface IUpgradeabilityOwnerStorage {
    function upgradeabilityOwner() external view returns (address);
}



pragma solidity 0.4.24;


contract Upgradeable {
    
    modifier onlyIfUpgradeabilityOwner() {
        require(msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner());
        
        _;
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
        return (5, 0, 0);
    }

    
    function getBridgeMode() external pure returns (bytes4);
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



contract DecimalShiftBridge is EternalStorage {
    using SafeMath for uint256;

    bytes32 internal constant DECIMAL_SHIFT = 0x1e8ecaafaddea96ed9ac6d2642dcdfe1bebe58a930b1085842d8fc122b371ee5; 

    
    function _setDecimalShift(int256 _shift) internal {
        
        require(_shift > -77 && _shift < 77);
        uintStorage[DECIMAL_SHIFT] = uint256(_shift);
    }

    
    function decimalShift() public view returns (int256) {
        return int256(uintStorage[DECIMAL_SHIFT]);
    }

    
    function _unshiftValue(uint256 _value) internal view returns (uint256) {
        return _shiftUint(_value, -decimalShift());
    }

    
    function _shiftValue(uint256 _value) internal view returns (uint256) {
        return _shiftUint(_value, decimalShift());
    }

    
    function _shiftUint(uint256 _value, int256 _shift) private pure returns (uint256) {
        if (_shift == 0) {
            return _value;
        }
        if (_shift > 0) {
            return _value.mul(10**uint256(_shift));
        }
        return _value.div(10**uint256(-_shift));
    }
}



pragma solidity 0.4.24;









contract BasicBridge is
    InitializableBridge,
    Validatable,
    Ownable,
    Upgradeable,
    Claimable,
    VersionableBridge,
    DecimalShiftBridge
{
    event GasPriceChanged(uint256 gasPrice);
    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);

    bytes32 internal constant GAS_PRICE = 0x55b3774520b5993024893d303890baa4e84b1244a43c60034d1ced2d3cf2b04b; 
    bytes32 internal constant REQUIRED_BLOCK_CONFIRMATIONS = 0x916daedf6915000ff68ced2f0b6773fe6f2582237f92c3c95bb4d79407230071; 

    
    function setGasPrice(uint256 _gasPrice) external onlyOwner {
        _setGasPrice(_gasPrice);
    }

    function gasPrice() external view returns (uint256) {
        return uintStorage[GAS_PRICE];
    }

    function setRequiredBlockConfirmations(uint256 _blockConfirmations) external onlyOwner {
        _setRequiredBlockConfirmations(_blockConfirmations);
    }

    function _setRequiredBlockConfirmations(uint256 _blockConfirmations) internal {
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

    
    function _setGasPrice(uint256 _gasPrice) internal {
        uintStorage[GAS_PRICE] = _gasPrice;
        emit GasPriceChanged(_gasPrice);
    }
}



pragma solidity 0.4.24;


contract VersionableAMB is VersionableBridge {
    
    
    
    
    
    
    
    bytes32 internal constant MESSAGE_PACKING_VERSION = 0x00050000 << 224;

    
    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {
        return (5, 3, 0);
    }
}



pragma solidity 0.4.24;



contract BasicAMB is BasicBridge, VersionableAMB {
    bytes32 internal constant MAX_GAS_PER_TX = 0x2670ecc91ec356e32067fd27b36614132d727b84a1e03e08f412a4f2cf075974; 
    bytes32 internal constant NONCE = 0x7ab1577440dd7bedf920cb6de2f9fc6bf7ba98c78c85a3fa1f8311aac95e1759; 
    bytes32 internal constant SOURCE_CHAIN_ID = 0x67d6f42a1ed69c62022f2d160ddc6f2f0acd37ad1db0c24f4702d7d3343a4add; 
    bytes32 internal constant SOURCE_CHAIN_ID_LENGTH = 0xe504ae1fd6471eea80f18b8532a61a9bb91fba4f5b837f80a1cfb6752350af44; 
    bytes32 internal constant DESTINATION_CHAIN_ID = 0xbbd454018e72a3f6c02bbd785bacc49e46292744f3f6761276723823aa332320; 
    bytes32 internal constant DESTINATION_CHAIN_ID_LENGTH = 0xfb792ae4ad11102b93f26a51b3749c2b3667f8b561566a4806d4989692811594; 

    
    function initialize(
        uint256 _sourceChainId,
        uint256 _destinationChainId,
        address _validatorContract,
        uint256 _maxGasPerTx,
        uint256 _gasPrice,
        uint256 _requiredBlockConfirmations,
        address _owner
    ) external onlyRelevantSender returns (bool) {
        require(!isInitialized());
        require(AddressUtils.isContract(_validatorContract));

        _setChainIds(_sourceChainId, _destinationChainId);
        addressStorage[VALIDATOR_CONTRACT] = _validatorContract;
        uintStorage[DEPLOYED_AT_BLOCK] = block.number;
        uintStorage[MAX_GAS_PER_TX] = _maxGasPerTx;
        _setGasPrice(_gasPrice);
        _setRequiredBlockConfirmations(_requiredBlockConfirmations);
        setOwner(_owner);
        setInitialize();

        return isInitialized();
    }

    function getBridgeMode() external pure returns (bytes4 _data) {
        return 0x2544fbb9; 
    }

    function maxGasPerTx() public view returns (uint256) {
        return uintStorage[MAX_GAS_PER_TX];
    }

    function setMaxGasPerTx(uint256 _maxGasPerTx) external onlyOwner {
        uintStorage[MAX_GAS_PER_TX] = _maxGasPerTx;
    }

    
    function sourceChainId() public view returns (uint256) {
        return uintStorage[SOURCE_CHAIN_ID];
    }

    
    function destinationChainId() public view returns (uint256) {
        return uintStorage[DESTINATION_CHAIN_ID];
    }

    
    function setChainIds(uint256 _sourceChainId, uint256 _destinationChainId) external onlyOwner {
        _setChainIds(_sourceChainId, _destinationChainId);
    }

    
    function _nonce() internal view returns (uint64) {
        return uint64(uintStorage[NONCE]);
    }

    
    function _setNonce(uint64 _nonce) internal {
        uintStorage[NONCE] = uint256(_nonce);
    }

    
    function _setChainIds(uint256 _sourceChainId, uint256 _destinationChainId) internal {
        require(_sourceChainId > 0 && _destinationChainId > 0);
        require(_sourceChainId != _destinationChainId);
        uint256 sourceChainIdLength = 0;
        uint256 destinationChainIdLength = 0;
        uint256 mask = 0xff;

        for (uint256 i = 1; sourceChainIdLength == 0 || destinationChainIdLength == 0; i++) {
            if (sourceChainIdLength == 0 && _sourceChainId & mask == _sourceChainId) {
                sourceChainIdLength = i;
            }
            if (destinationChainIdLength == 0 && _destinationChainId & mask == _destinationChainId) {
                destinationChainIdLength = i;
            }
            mask = (mask << 8) | 0xff;
        }

        uintStorage[SOURCE_CHAIN_ID] = _sourceChainId;
        uintStorage[SOURCE_CHAIN_ID_LENGTH] = sourceChainIdLength;
        uintStorage[DESTINATION_CHAIN_ID] = _destinationChainId;
        uintStorage[DESTINATION_CHAIN_ID_LENGTH] = destinationChainIdLength;
    }

    
    function _sourceChainIdLength() internal view returns (uint256) {
        return uintStorage[SOURCE_CHAIN_ID_LENGTH];
    }

    
    function _destinationChainIdLength() internal view returns (uint256) {
        return uintStorage[DESTINATION_CHAIN_ID_LENGTH];
    }

    
    function _isMessageVersionValid(bytes32 _messageId) internal returns (bool) {
        return
            _messageId & 0xffffffff00000000000000000000000000000000000000000000000000000000 == MESSAGE_PACKING_VERSION;
    }

    
    function _isDestinationChainIdValid(uint256 _chainId) internal returns (bool res) {
        return _chainId == sourceChainId();
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



pragma solidity 0.4.24;



contract MessageProcessor is EternalStorage {
    bytes32 internal constant MESSAGE_SENDER = 0x7b58b2a669d8e0992eae9eaef641092c0f686fd31070e7236865557fa1571b5b; 
    bytes32 internal constant MESSAGE_ID = 0xe34bb2103dc34f2c144cc216c132d6ffb55dac57575c22e089161bbe65083304; 
    bytes32 internal constant MESSAGE_SOURCE_CHAIN_ID = 0x7f0fcd9e49860f055dd0c1682d635d309ecb5e3011654c716d9eb59a7ddec7d2; 

    
    function messageCallStatus(bytes32 _messageId) external view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("messageCallStatus", _messageId))];
    }

    
    function setMessageCallStatus(bytes32 _messageId, bool _status) internal {
        boolStorage[keccak256(abi.encodePacked("messageCallStatus", _messageId))] = _status;
    }

    
    function failedMessageDataHash(bytes32 _messageId) external view returns (bytes32) {
        return bytes32(uintStorage[keccak256(abi.encodePacked("failedMessageDataHash", _messageId))]);
    }

    
    function setFailedMessageDataHash(bytes32 _messageId, bytes data) internal {
        uintStorage[keccak256(abi.encodePacked("failedMessageDataHash", _messageId))] = uint256(keccak256(data));
    }

    
    function failedMessageReceiver(bytes32 _messageId) external view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("failedMessageReceiver", _messageId))];
    }

    
    function setFailedMessageReceiver(bytes32 _messageId, address _receiver) internal {
        addressStorage[keccak256(abi.encodePacked("failedMessageReceiver", _messageId))] = _receiver;
    }

    
    function failedMessageSender(bytes32 _messageId) external view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("failedMessageSender", _messageId))];
    }

    
    function setFailedMessageSender(bytes32 _messageId, address _sender) internal {
        addressStorage[keccak256(abi.encodePacked("failedMessageSender", _messageId))] = _sender;
    }

    
    function messageSender() external view returns (address) {
        return addressStorage[MESSAGE_SENDER];
    }

    
    function setMessageSender(address _sender) internal {
        addressStorage[MESSAGE_SENDER] = _sender;
    }

    
    function messageId() public view returns (bytes32) {
        return bytes32(uintStorage[MESSAGE_ID]);
    }

    
    function transactionHash() external view returns (bytes32) {
        return messageId();
    }

    
    function setMessageId(bytes32 _messageId) internal {
        uintStorage[MESSAGE_ID] = uint256(_messageId);
    }

    
    function messageSourceChainId() external view returns (uint256) {
        return uintStorage[MESSAGE_SOURCE_CHAIN_ID];
    }

    
    function setMessageSourceChainId(uint256 _sourceChainId) internal returns (uint256) {
        uintStorage[MESSAGE_SOURCE_CHAIN_ID] = _sourceChainId;
    }

    
    function processMessage(
        address _sender,
        address _executor,
        bytes32 _messageId,
        uint256 _gasLimit,
        bytes1, 
        uint256, 
        uint256 _sourceChainId,
        bytes memory _data
    ) internal {
        bool status = _passMessage(_sender, _executor, _data, _gasLimit, _messageId, _sourceChainId);

        setMessageCallStatus(_messageId, status);
        if (!status) {
            setFailedMessageDataHash(_messageId, _data);
            setFailedMessageReceiver(_messageId, _executor);
            setFailedMessageSender(_messageId, _sender);
        }
        emitEventOnMessageProcessed(_sender, _executor, _messageId, status);
    }

    
    function _passMessage(
        address _sender,
        address _contract,
        bytes _data,
        uint256 _gas,
        bytes32 _messageId,
        uint256 _sourceChainId
    ) internal returns (bool) {
        setMessageSender(_sender);
        setMessageId(_messageId);
        setMessageSourceChainId(_sourceChainId);
        bool status = _contract.call.gas(_gas)(_data);
        setMessageSender(address(0));
        setMessageId(bytes32(0));
        setMessageSourceChainId(0);
        return status;
    }

    
    function emitEventOnMessageProcessed(address sender, address executor, bytes32 messageId, bool status) internal;
}



pragma solidity 0.4.24;






contract MessageDelivery is BasicAMB, MessageProcessor {
    using SafeMath for uint256;

    
    function requireToPassMessage(address _contract, bytes _data, uint256 _gas) public returns (bytes32) {
        
        require(messageId() == bytes32(0));

        require(_gas >= getMinimumGasUsage(_data) && _gas <= maxGasPerTx());

        bytes32 _messageId;
        bytes memory header = _packHeader(_contract, _gas);
        _setNonce(_nonce() + 1);

        assembly {
            _messageId := mload(add(header, 32))
        }

        bytes memory eventData = abi.encodePacked(header, _data);

        emitEventOnMessageRequest(_messageId, eventData);
        return _messageId;
    }

    
    function getMinimumGasUsage(bytes _data) public pure returns (uint256 gas) {
        
        
        
        return _data.length.mul(16);
    }

    
    function _packHeader(address _contract, uint256 _gas) internal view returns (bytes memory header) {
        uint256 srcChainId = sourceChainId();
        uint256 srcChainIdLength = _sourceChainIdLength();
        uint256 dstChainId = destinationChainId();
        uint256 dstChainIdLength = _destinationChainIdLength();

        bytes32 mVer = MESSAGE_PACKING_VERSION;
        uint256 nonce = _nonce();

        
        bytes32 bridgeId = keccak256(abi.encodePacked(srcChainId, address(this))) &
            0x00000000ffffffffffffffffffffffffffffffffffffffff0000000000000000;
        
        header = new bytes(79 + srcChainIdLength + dstChainIdLength);

        
        
        assembly {
            let ptr := add(header, mload(header)) 
            mstore(ptr, dstChainId)
            mstore(sub(ptr, dstChainIdLength), srcChainId)

            mstore(add(header, 79), 0x00)
            mstore(add(header, 78), dstChainIdLength)
            mstore(add(header, 77), srcChainIdLength)
            mstore(add(header, 76), _gas)
            mstore(add(header, 72), _contract)
            mstore(add(header, 52), caller)

            mstore(add(header, 32), or(mVer, or(bridgeId, nonce)))
        }
    }

    
    function emitEventOnMessageRequest(bytes32 messageId, bytes encodedData) internal;
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






contract BasicForeignAMB is BasicAMB, MessageRelay, MessageDelivery {
    
    function executeSignatures(bytes _data, bytes _signatures) external {
        Message.hasEnoughValidSignatures(_data, _signatures, validatorContract(), true);

        bytes32 messageId;
        address sender;
        address executor;
        uint32 gasLimit;
        bytes1 dataType;
        uint256[2] memory chainIds;
        uint256 gasPrice;
        bytes memory data;

        (messageId, sender, executor, gasLimit, dataType, chainIds, gasPrice, data) = ArbitraryMessage.unpackData(
            _data
        );
        require(_isMessageVersionValid(messageId));
        require(_isDestinationChainIdValid(chainIds[1]));
        require(!relayedMessages(messageId));
        setRelayedMessages(messageId, true);
        processMessage(sender, executor, messageId, gasLimit, dataType, gasPrice, chainIds[0], data);
    }

    
    function _setGasPrice(uint256 _gasPrice) internal {
        require(_gasPrice > 0);
        super._setGasPrice(_gasPrice);
    }
}



pragma solidity 0.4.24;


contract ForeignAMB is BasicForeignAMB {
    event UserRequestForAffirmation(bytes32 indexed messageId, bytes encodedData);
    event RelayedMessage(address indexed sender, address indexed executor, bytes32 indexed messageId, bool status);

    function emitEventOnMessageRequest(bytes32 messageId, bytes encodedData) internal {
        emit UserRequestForAffirmation(messageId, encodedData);
    }

    function emitEventOnMessageProcessed(address sender, address executor, bytes32 messageId, bool status) internal {
        emit RelayedMessage(sender, executor, messageId, status);
    }
}