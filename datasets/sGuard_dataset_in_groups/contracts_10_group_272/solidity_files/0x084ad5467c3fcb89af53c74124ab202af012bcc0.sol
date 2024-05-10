pragma solidity 0.5.11;


interface DharmaKeyRingImplementationV0Interface {
  enum AdminActionType {
    AddStandardKey,
    RemoveStandardKey,
    SetStandardThreshold,
    AddAdminKey,
    RemoveAdminKey,
    SetAdminThreshold,
    AddDualKey,
    RemoveDualKey,
    SetDualThreshold
  }

  function takeAdminAction(
    AdminActionType adminActionType, uint160 argument, bytes calldata signatures
  ) external;
}



contract DharmaLocksmithV0 {
  
  function setAdditionalKey(
    address keyRing, address newUserSigningKey, bytes calldata signature
  ) external {
    
    require(keyRing != address(0), "No key ring supplied.");

    
    DharmaKeyRingImplementationV0Interface(keyRing).takeAdminAction(
      DharmaKeyRingImplementationV0Interface.AdminActionType.AddDualKey,
      uint160(newUserSigningKey),
      signature
    );
  }
}