pragma solidity 0.5.11; 


interface DharmaEscapeHatchRegistryInterface {
  
  event EscapeHatchModified(
    address indexed smartWallet, address oldEscapeHatch, address newEscapeHatch
  );

  
  event EscapeHatchDisabled(address smartWallet);

  
  
  struct EscapeHatch {
    address escapeHatch;
    bool disabled;
  }

  function setEscapeHatch(address newEscapeHatch) external;

  function removeEscapeHatch() external;

  function permanentlyDisableEscapeHatch() external;

  function getEscapeHatch() external view returns (
    bool exists, address escapeHatch
  );

  function getEscapeHatchForSmartWallet(
    address smartWallet
  ) external view returns (bool exists, address escapeHatch);

  function hasDisabledEscapeHatchForSmartWallet(
    address smartWallet
  ) external view returns (bool disabled);
}



contract DharmaEscapeHatchRegistry is DharmaEscapeHatchRegistryInterface {
  
  mapping(address => EscapeHatch) private _escapeHatches;

  
  function () external {
    
    address escapeHatch = _escapeHatches[msg.sender].escapeHatch;

    
    assembly {
      
      mstore(0, escapeHatch)

      
      return(0, 32)
    }
  }

  
  function setEscapeHatch(address escapeHatch) external {
    
    require(escapeHatch != address(0), "Must supply an escape hatch address.");

    
    _modifyEscapeHatch(escapeHatch, false);
  }

  
  function removeEscapeHatch() external {
    
    _modifyEscapeHatch(address(0), false);
  }

  
  function permanentlyDisableEscapeHatch() external {
    
    _modifyEscapeHatch(address(0), true);
  }

   
  function getEscapeHatch() external view returns (
    bool exists, address escapeHatch
  ) {
    escapeHatch = _escapeHatches[msg.sender].escapeHatch;
    exists = escapeHatch != address(0);
  }

   
  function getEscapeHatchForSmartWallet(
    address smartWallet
  ) external view returns (bool exists, address escapeHatch) {
    
    require(smartWallet != address(0), "Must supply a smart wallet address.");

    escapeHatch = _escapeHatches[smartWallet].escapeHatch;
    exists = escapeHatch != address(0);
  }

   
  function hasDisabledEscapeHatchForSmartWallet(
    address smartWallet
  ) external view returns (bool disabled) {
    
    require(smartWallet != address(0), "Must supply a smart wallet address.");

    disabled = _escapeHatches[smartWallet].disabled;
  }

  
  function _modifyEscapeHatch(address escapeHatch, bool disable) internal {
    
    EscapeHatch storage escape = _escapeHatches[msg.sender];

    
    require(!escape.disabled, "Escape hatch has been disabled by this account.");

    
    if (escape.escapeHatch != escapeHatch) {
      
      emit EscapeHatchModified(msg.sender, escape.escapeHatch, escapeHatch);
    }

    
    if (disable) {
      
      emit EscapeHatchDisabled(msg.sender);
    }

    
    escape.escapeHatch = escapeHatch;
    escape.disabled = disable;
  }
}