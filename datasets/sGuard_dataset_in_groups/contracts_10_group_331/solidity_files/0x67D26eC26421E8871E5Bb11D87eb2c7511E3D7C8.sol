pragma solidity 0.4.24;



interface IBridgeValidators {
    function isValidator(address _validator) public view returns(bool);
    function requiredSignatures() public view returns(uint256);
    function owner() public view returns(address);
}




library SafeMath {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}




contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}




contract Ownable is EternalStorage {
    
    event OwnershipTransferred(address previousOwner, address newOwner);

    
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    
    function owner() public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("owner"))];
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;
    }
}



contract BridgeValidators is IBridgeValidators, EternalStorage, Ownable {
    using SafeMath for uint256;

    event ValidatorAdded (address indexed validator);
    event ValidatorRemoved (address indexed validator);
    event RequiredSignaturesChanged (uint256 requiredSignatures);

    function initialize(uint256 _requiredSignatures, address[] _initialValidators, address _owner)
      public returns(bool)
    {
        require(!isInitialized());
        require(_owner != address(0));
        setOwner(_owner);
        require(_requiredSignatures != 0);
        require(_initialValidators.length >= _requiredSignatures);
        for (uint256 i = 0; i < _initialValidators.length; i++) {
            require(_initialValidators[i] != address(0));
            assert(validators(_initialValidators[i]) != true);
            setValidatorCount(validatorCount().add(1));
            setValidator(_initialValidators[i], true);
            emit ValidatorAdded(_initialValidators[i]);
        }
        uintStorage[keccak256(abi.encodePacked("requiredSignatures"))] = _requiredSignatures;
        uintStorage[keccak256("deployedAtBlock")] = block.number;
        setInitialize(true);
        emit RequiredSignaturesChanged(_requiredSignatures);
        return isInitialized();
    }

    function addValidator(address _validator) external onlyOwner {
        require(_validator != address(0));
        require(!isValidator(_validator));
        setValidatorCount(validatorCount().add(1));
        setValidator(_validator, true);
        emit ValidatorAdded(_validator);
    }

    function removeValidator(address _validator) external onlyOwner {
        require(validatorCount() > requiredSignatures());
        require(isValidator(_validator));
        setValidator(_validator, false);
        setValidatorCount(validatorCount().sub(1));
        emit ValidatorRemoved(_validator);
    }

    function setRequiredSignatures(uint256 _requiredSignatures) external onlyOwner {
        require(validatorCount() >= _requiredSignatures);
        require(_requiredSignatures != 0);
        uintStorage[keccak256(abi.encodePacked("requiredSignatures"))] = _requiredSignatures;
        emit RequiredSignaturesChanged(_requiredSignatures);
    }

    function getBridgeValidatorsInterfacesVersion() public pure returns(uint64 major, uint64 minor, uint64 patch) {
        return (2, 0, 0);
    }

    function requiredSignatures() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("requiredSignatures"))];
    }

    function validatorCount() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("validatorCount"))];
    }

    function validators(address _validator) public view returns(bool) {
        return boolStorage[keccak256(abi.encodePacked("validators", _validator))];
    }

    function isValidator(address _validator) public view returns(bool) {
        return validators(_validator) == true;
    }

    function isInitialized() public view returns(bool) {
        return boolStorage[keccak256(abi.encodePacked("isInitialized"))];
    }

    function deployedAtBlock() public view returns(uint256) {
        return uintStorage[keccak256("deployedAtBlock")];
    }

    function setValidatorCount(uint256 _validatorCount) private {
        uintStorage[keccak256(abi.encodePacked("validatorCount"))] = _validatorCount;
    }

    function setValidator(address _validator, bool _status) private {
        boolStorage[keccak256(abi.encodePacked("validators", _validator))] = _status;
    }

    function setInitialize(bool _status) private {
        boolStorage[keccak256(abi.encodePacked("isInitialized"))] = _status;
    }
}