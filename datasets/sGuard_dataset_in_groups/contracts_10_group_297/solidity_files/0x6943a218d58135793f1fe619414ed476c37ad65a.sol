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



contract Ownable is EternalStorage {
    
    event OwnershipTransferred(address previousOwner, address newOwner);

    
    modifier onlyOwner() {
        require(msg.sender == owner());
        
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



pragma solidity 0.4.24;




contract BaseBridgeValidators is InitializableBridge, Ownable {
    using SafeMath for uint256;

    address public constant F_ADDR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    uint256 internal constant MAX_VALIDATORS = 100;
    bytes32 internal constant REQUIRED_SIGNATURES = 0xd18ea17c351d6834a0e568067fb71804d2a588d5e26d60f792b1c724b1bd53b1; 
    bytes32 internal constant VALIDATOR_COUNT = 0x8656d603d9f985c3483946a92789d52202f49736384ba131cb92f62c4c1aa082; 

    event ValidatorAdded(address indexed validator);
    event ValidatorRemoved(address indexed validator);
    event RequiredSignaturesChanged(uint256 requiredSignatures);

    function setRequiredSignatures(uint256 _requiredSignatures) external onlyOwner {
        require(validatorCount() >= _requiredSignatures);
        require(_requiredSignatures != 0);
        uintStorage[REQUIRED_SIGNATURES] = _requiredSignatures;
        emit RequiredSignaturesChanged(_requiredSignatures);
    }

    function getBridgeValidatorsInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {
        return (2, 3, 0);
    }

    function validatorList() external view returns (address[]) {
        address[] memory list = new address[](validatorCount());
        uint256 counter = 0;
        address nextValidator = getNextValidator(F_ADDR);
        require(nextValidator != address(0));

        while (nextValidator != F_ADDR) {
            list[counter] = nextValidator;
            nextValidator = getNextValidator(nextValidator);
            counter++;

            require(nextValidator != address(0));
        }

        return list;
    }

    function _addValidator(address _validator) internal {
        require(_validator != address(0) && _validator != F_ADDR);
        require(!isValidator(_validator));

        address firstValidator = getNextValidator(F_ADDR);
        require(firstValidator != address(0));
        setNextValidator(_validator, firstValidator);
        setNextValidator(F_ADDR, _validator);
        setValidatorCount(validatorCount().add(1));
    }

    function _removeValidator(address _validator) internal {
        require(validatorCount() > requiredSignatures());
        require(isValidator(_validator));
        address validatorsNext = getNextValidator(_validator);
        address index = F_ADDR;
        address next = getNextValidator(index);
        require(next != address(0));

        while (next != _validator) {
            index = next;
            next = getNextValidator(index);

            require(next != F_ADDR && next != address(0));
        }

        setNextValidator(index, validatorsNext);
        deleteItemFromAddressStorage("validatorsList", _validator);
        setValidatorCount(validatorCount().sub(1));
    }

    function requiredSignatures() public view returns (uint256) {
        return uintStorage[REQUIRED_SIGNATURES];
    }

    function validatorCount() public view returns (uint256) {
        return uintStorage[VALIDATOR_COUNT];
    }

    function isValidator(address _validator) public view returns (bool) {
        return _validator != F_ADDR && getNextValidator(_validator) != address(0);
    }

    function getNextValidator(address _address) public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("validatorsList", _address))];
    }

    function deleteItemFromAddressStorage(string _mapName, address _address) internal {
        delete addressStorage[keccak256(abi.encodePacked(_mapName, _address))];
    }

    function setValidatorCount(uint256 _validatorCount) internal {
        uintStorage[VALIDATOR_COUNT] = _validatorCount;
    }

    function setNextValidator(address _prevValidator, address _validator) internal {
        addressStorage[keccak256(abi.encodePacked("validatorsList", _prevValidator))] = _validator;
    }

    function isValidatorDuty(address _validator) external view returns (bool) {
        uint256 counter = 0;
        address next = getNextValidator(F_ADDR);
        require(next != address(0));

        while (next != F_ADDR) {
            if (next == _validator) {
                return (block.number % validatorCount() == counter);
            }

            next = getNextValidator(next);
            counter++;

            require(next != address(0));
        }

        return false;
    }
}



pragma solidity 0.4.24;


contract BridgeValidators is BaseBridgeValidators {
    function initialize(uint256 _requiredSignatures, address[] _initialValidators, address _owner)
        external
        returns (bool)
    {
        require(!isInitialized());
        require(_owner != address(0));
        setOwner(_owner);
        require(_requiredSignatures != 0);
        require(_initialValidators.length >= _requiredSignatures);
        require(_initialValidators.length <= MAX_VALIDATORS);

        for (uint256 i = 0; i < _initialValidators.length; i++) {
            require(_initialValidators[i] != address(0) && _initialValidators[i] != F_ADDR);
            require(!isValidator(_initialValidators[i]));

            if (i == 0) {
                setNextValidator(F_ADDR, _initialValidators[i]);
                if (_initialValidators.length == 1) {
                    setNextValidator(_initialValidators[i], F_ADDR);
                }
            } else if (i == _initialValidators.length - 1) {
                setNextValidator(_initialValidators[i - 1], _initialValidators[i]);
                setNextValidator(_initialValidators[i], F_ADDR);
            } else {
                setNextValidator(_initialValidators[i - 1], _initialValidators[i]);
            }

            emit ValidatorAdded(_initialValidators[i]);
        }

        setValidatorCount(_initialValidators.length);
        uintStorage[REQUIRED_SIGNATURES] = _requiredSignatures;
        uintStorage[DEPLOYED_AT_BLOCK] = block.number;
        setInitialize();
        emit RequiredSignaturesChanged(_requiredSignatures);

        return isInitialized();
    }

    function addValidator(address _validator) external onlyOwner {
        _addValidator(_validator);
        emit ValidatorAdded(_validator);
    }

    function removeValidator(address _validator) external onlyOwner {
        _removeValidator(_validator);
        emit ValidatorRemoved(_validator);
    }

    function upgradeToV230() public {
        bytes32 upgradeStorage = 0x2e8a0420c66b3c19df2ac1cd4ffadb5637da547c6fd49388c7fe28dc8c13a8dd; 
        require(!boolStorage[upgradeStorage]);
        address validator1 = 0x9ad83402C19Af24F76afa1930a2B2EEC2F47A8C5;
        address validator2 = 0x4D1c96B9A49C4469A0b720a22b74b034EDdFe051;
        address validator3 = 0x491FC792e78CDadd7D31446Bb7bDDef876a69AD6;
        address validator4 = 0xc073C8E5ED9Aa11CF6776C69b3e13b259Ba9F506;

        setNextValidator(F_ADDR, validator1);
        setNextValidator(validator1, validator2);
        setNextValidator(validator2, validator3);
        setNextValidator(validator3, validator4);
        setNextValidator(validator4, F_ADDR);
        boolStorage[upgradeStorage] = true;
    }
}