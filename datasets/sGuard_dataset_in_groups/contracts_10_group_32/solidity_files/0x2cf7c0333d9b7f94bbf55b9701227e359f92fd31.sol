pragma solidity 0.5.11; 



contract DharmaTradeReserveUpgradeBeacon {
  
  address private _implementation;

  
  address private constant _CONTROLLER = address(
    0x48030C8236C20DC09C60B4C39d17AFD3c2882e0D
  );

  
  function () external {
    
    if (msg.sender != _CONTROLLER) {
      
      assembly {
        mstore(0, sload(0))
        return(0, 32)
      }
    } else {
      
      assembly { sstore(0, calldataload(0)) }
    }
  }
}