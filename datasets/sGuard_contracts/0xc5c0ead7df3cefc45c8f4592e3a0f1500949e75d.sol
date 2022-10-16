pragma solidity 0.6.10;


interface ConfigurationRegistryInterface {
  event ConfigurationModified(bytes32 indexed key, bytes32 value);
  function set(bytes32 key, bytes32 value) external;
  function get(bytes32 key) external view returns (bytes32 value);
  function getKey(
    string calldata stringToHash
  ) external pure returns (bytes32 key);
}



contract TwoStepOwnable {
  address private _owner;

  address private _newPotentialOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  
  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }

  
  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    require(
      newOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  
  function cancelOwnershipTransfer() public onlyOwner {
    delete _newPotentialOwner;
  }

  
  function acceptOwnership() public {
    require(
      msg.sender == _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }
}


contract ConfigurationRegistry is
  ConfigurationRegistryInterface, TwoStepOwnable {
  mapping(bytes32 => bytes32) private _values;
    
  function set(bytes32 key, bytes32 value) external override onlyOwner {
    _values[key] = value;
    emit ConfigurationModified(key, value);
  }
    
  function get(
    bytes32 key
  ) external view override returns (bytes32 value) {
    value = _values[key];
  }
  
  function getKey(
    string calldata stringToHash
  ) external pure override returns (bytes32 key) {
    key = keccak256(bytes(stringToHash));
  }
}