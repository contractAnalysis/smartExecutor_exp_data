pragma solidity ^0.4.24;



contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  
  constructor() public {
    owner = msg.sender;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}




contract PermittedPools is Ownable {
  event NewPoolsEnabled(address newPools, bool enabled);
  
  mapping (address => bool) public permittedAddresses;

  
  constructor(address _address) public {
    _enableAddress(_address, true);
  }


  
  function addNewPoolAddress(address _newAddress) public onlyOwner {
    
    _enableAddress(_newAddress, true);
  }

  
  function disableAddress(address _newAddress) public onlyOwner {
    _enableAddress(_newAddress, false);
  }

  
  function _enableAddress(address _newAddress, bool _enabled) private {
    permittedAddresses[_newAddress] = _enabled;

    emit NewPoolsEnabled(_newAddress, _enabled);
  }
}