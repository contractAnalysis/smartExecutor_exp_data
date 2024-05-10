pragma solidity 0.5.11; 



contract DharmaUpgradeBeaconPrototypeSmartWallet {
  
  address private _implementation;

  
  address private constant _CONTROLLER = address(
    0x00000000003284ACb9aDEb78A2dDe0A8499932b9
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