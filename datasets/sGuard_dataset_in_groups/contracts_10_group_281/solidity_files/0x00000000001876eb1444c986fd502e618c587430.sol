pragma solidity 0.5.11; 



contract DharmaDai {
  
  address private constant _UPGRADE_BEACON = address(
    0x0000000000ccCf289727C20269911159a7bf9eBd
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