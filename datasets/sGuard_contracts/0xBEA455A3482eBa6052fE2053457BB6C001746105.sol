pragma solidity 0.5.11; 



contract DharmaDaiStaging {
  
  address private constant _UPGRADE_BEACON = address(
    0x3D362791FdA48491bddc20C4cF147fEf688Ad56e
  );

  
  function () external payable {
    
    (bool ok, bytes memory returnData) = _UPGRADE_BEACON.staticcall("");

    
    if (!ok) {
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    
    address implementation = abi.decode(returnData, (address));

    assembly {
      
      
      
      calldatacopy(0, 0, calldatasize)

      
      
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      
      returndatacopy(0, 0, returndatasize)

      switch result
      
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }
}