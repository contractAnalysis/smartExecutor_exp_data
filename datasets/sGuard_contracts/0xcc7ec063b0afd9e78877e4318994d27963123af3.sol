pragma solidity 0.5.11; 



contract DharmaUSDCStaging {
  
  address private constant _UPGRADE_BEACON = address(
    0xe9DDDA6C56bFD31725D118E7F13a3eb4f3A82226
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