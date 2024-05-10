pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;

interface IDepositContractRegistry {
  function operatorOf(address owner, address operator) external returns (bool);
}


contract DepositContract {
  address public owner;
  address public parent;
  address public version;

  constructor(address _owner) public {
    parent = msg.sender;
    owner = _owner;
  }

  
  function() external payable { }

  
  function setVersion(address newVersion) external {
    require(msg.sender == parent);
    version = newVersion;
  }

  
  function perform(
    address addr, 
    string calldata signature, 
    bytes calldata encodedParams,
    uint value
  ) 
    external 
    returns (bytes memory) 
  {
    require(
      msg.sender == owner || 
      msg.sender == parent || 
      msg.sender == version ||
      IDepositContractRegistry(parent).operatorOf(address(this), msg.sender)
    , "NOT_PERMISSIBLE");

    if (bytes(signature).length == 0) {
      address(uint160(addr)).transfer(value); 
    } else {
      bytes4 functionSelector = bytes4(keccak256(bytes(signature)));
      bytes memory payload = abi.encodePacked(functionSelector, encodedParams);
      
      (bool success, bytes memory returnData) = addr.call.value(value)(payload);
      require(success, "OPERATION_REVERTED");

      return returnData;
    }
  }
}