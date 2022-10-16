pragma solidity 0.5.11;


interface DharmaSmartWalletFactoryV1Interface {
  function getNextSmartWallet(
    address userSigningKey
  ) external view returns (address wallet);
}


interface DharmaKeyRingFactoryV1Interface {
   function getNextKeyRing(
    address userSigningKey
  ) external view returns (address keyRing);
}


interface DharmaSmartWalletImplementationV0Interface {
  function getUserSigningKey() external view returns (address userSigningKey);
}



contract FactoryFactFinder {
  DharmaSmartWalletFactoryV1Interface private constant _smartWalletFactory = (
    DharmaSmartWalletFactoryV1Interface(
      0xfc00C80b0000007F73004edB00094caD80626d8D
    )
  );

  DharmaKeyRingFactoryV1Interface private constant _keyRingFactory = (
    DharmaKeyRingFactoryV1Interface(
      0x00DD005247B300f700cFdfF89C00e2aCC94c7b00
    )
  );

  
  function getNextKeyRingAndSmartWallet(
    address userSigningKey
  ) external view returns (address keyRing, address smartWallet) {
    
    require(userSigningKey != address(0), "No user signing key supplied.");

    
    keyRing = _keyRingFactory.getNextKeyRing(userSigningKey);
    
    
    smartWallet = _smartWalletFactory.getNextSmartWallet(keyRing);
  }

  
  function getDeploymentStatuses(
    address smartWallet
  ) external view returns (
    bool smartWalletDeployed,
    bool keyRingDeployed,
    address keyRing
  ) {
    
    require(smartWallet != address(0), "No smart wallet supplied.");

    
    smartWalletDeployed = _hasContractCode(smartWallet);
    
    
    if (smartWalletDeployed) {
      keyRing = DharmaSmartWalletImplementationV0Interface(
        smartWallet
      ).getUserSigningKey();

      keyRingDeployed = _hasContractCode(keyRing);
    }
  }

  
  function hasContractCode(address target) external view returns (bool) {
    return _hasContractCode(target);
  }

  
  function _hasContractCode(address target) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(target) }
    return size > 0;
  }  
}