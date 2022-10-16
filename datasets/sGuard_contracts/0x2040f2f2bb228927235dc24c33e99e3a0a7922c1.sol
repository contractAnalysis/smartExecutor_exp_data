pragma solidity 0.5.11;



contract DharmaTradeReserveStaging {
  
  address private constant _UPGRADE_BEACON = address(
    0x481B1a16E6675D33f8BBb3a6A58F5a9678649718
  );

  
  constructor(bytes memory initializationCalldata) public payable {
    
    (bool ok, ) = _implementation().delegatecall(initializationCalldata);

    
    if (!ok) {
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  }

  
  function () external payable {
    
    _delegate(_implementation());
  }

  
  function _implementation() private view returns (address implementation) {
    
    (bool ok, bytes memory returnData) = _UPGRADE_BEACON.staticcall("");

    
    require(ok, string(returnData));

    
    implementation = abi.decode(returnData, (address));
  }

  
  function _delegate(address implementation) private {
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