pragma solidity 0.5.11;


interface DharmaSmartWalletInterface {
  enum ActionType {
    Cancel, SetUserSigningKey, Generic, GenericAtomicBatch, SAIWithdrawal,
    USDCWithdrawal, ETHWithdrawal, SetEscapeHatch, RemoveEscapeHatch,
    DisableEscapeHatch, DAIWithdrawal, _ELEVEN, _TWELVE, _THIRTEEN,
    _FOURTEEN, _FIFTEEN, _SIXTEEN, _SEVENTEEN, _EIGHTEEN, _NINETEEN, _TWENTY
  }
  function getVersion() external pure returns (uint256 version);
}


interface DharmaSmartWalletFactoryV1Interface {
  function newSmartWallet(
    address userSigningKey
  ) external returns (address wallet);
  
  function getNextSmartWallet(
    address userSigningKey
  ) external view returns (address wallet);
}

interface DharmaKeyRingFactoryV2Interface {
  function newKeyRing(
    address userSigningKey, address targetKeyRing
  ) external returns (address keyRing);

  function getNextKeyRing(
    address userSigningKey
  ) external view returns (address targetKeyRing);
}


interface DharmaKeyRegistryInterface {
  function getGlobalKey() external view returns (address key);
}


contract DharmaDeploymentHelperStaging {
  DharmaSmartWalletFactoryV1Interface internal constant _WALLET_FACTORY = (
    DharmaSmartWalletFactoryV1Interface(
      0x8D1e00b000e56d5BcB006F3a008Ca6003b9F0033
    )
  );
  
  DharmaKeyRingFactoryV2Interface internal constant _KEYRING_FACTORY = (
    DharmaKeyRingFactoryV2Interface(
      0x7d849544F5cb797AE84aDD18a15A6DE1f12Df5f9
    )
  );

  DharmaKeyRegistryInterface internal constant _KEY_REGISTRY = (
    DharmaKeyRegistryInterface(
      0x00000000006c7f32F0cD1eA4C1383558eb68802D
    )
  );
  
  address internal constant beacon = 0x0000000000b45D6593312ac9fdE193F3D0633644;

  
  function deployWalletAndCall(
    address userSigningKey, 
    address smartWallet,
    bytes calldata data
  ) external returns (bool ok, bytes memory returnData) {
    _deployNewSmartWalletIfNeeded(userSigningKey, smartWallet);
    (ok, returnData) = smartWallet.call(data);
  }

  
  
  function deployKeyRingAndWalletAndCall(
    address initialSigningKey, 
    address keyRing,
    address smartWallet,
    bytes calldata data
  ) external returns (bool ok, bytes memory returnData) {
    _deployNewKeyRingIfNeeded(initialSigningKey, keyRing);
    _deployNewSmartWalletIfNeeded(keyRing, smartWallet);
    (ok, returnData) = smartWallet.call(data);
  }
 
  
  
  
  
  
  
  
  function getInitialActionID(
    address smartWallet,
    address initialUserSigningKey, 
    DharmaSmartWalletInterface.ActionType actionType,
    uint256 minimumActionGas,
    bytes calldata arguments
  ) external view returns (bytes32 actionID) {
    actionID = keccak256(
      abi.encodePacked(
        smartWallet,
        _getVersion(),
        initialUserSigningKey,
        _KEY_REGISTRY.getGlobalKey(),
        uint256(0), 
        minimumActionGas,
        actionType,
        arguments
      )
    );
  }
 
  function _deployNewKeyRingIfNeeded(
    address initialSigningKey, address expectedKeyRing
  ) internal returns (address keyRing) {
    
    bytes32 size;
    assembly { size := extcodesize(expectedKeyRing) }
    if (size == 0) {
      require(
        _KEYRING_FACTORY.getNextKeyRing(initialSigningKey) == expectedKeyRing,
        "Key ring to be deployed does not match expected key ring."
      );
      keyRing = _KEYRING_FACTORY.newKeyRing(initialSigningKey, expectedKeyRing);
    } else {
      
      
      
      
      keyRing = expectedKeyRing;
    }
  } 
  
  function _deployNewSmartWalletIfNeeded(
    address userSigningKey, 
    address expectedSmartWallet
  ) internal returns (address smartWallet) {
    
    bytes32 size;
    assembly { size := extcodesize(expectedSmartWallet) }
    if (size == 0) {
      require(
        _WALLET_FACTORY.getNextSmartWallet(userSigningKey) == expectedSmartWallet,
        "Smart wallet to be deployed does not match expected smart wallet."
      );
      smartWallet = _WALLET_FACTORY.newSmartWallet(userSigningKey);
    } else {
      
      
      
      
      
      smartWallet = expectedSmartWallet;
    }
  }

  function _getVersion() internal view returns (uint256 version) {
    (, bytes memory data) = beacon.staticcall("");
    address implementation = abi.decode(data, (address));
    version = DharmaSmartWalletInterface(implementation).getVersion();
  }
}