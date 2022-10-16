pragma solidity 0.5.11; 


interface DharmaKeyRingFactoryV2Interface {
  
  event KeyRingDeployed(address keyRing, address userSigningKey);

  function newKeyRing(
    address userSigningKey, address targetKeyRing
  ) external returns (address keyRing);

  function newKeyRingAndAdditionalKey(
    address userSigningKey,
    address targetKeyRing,
    address additionalSigningKey,
    bytes calldata signature
  ) external returns (address keyRing);

  function newKeyRingAndDaiWithdrawal(
    address userSigningKey,
    address targetKeyRing,
    address smartWallet,
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (address keyRing, bool withdrawalSuccess);

  function newKeyRingAndUSDCWithdrawal(
    address userSigningKey,
    address targetKeyRing,
    address smartWallet,
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (address keyRing, bool withdrawalSuccess);

  function getNextKeyRing(
    address userSigningKey
  ) external view returns (address targetKeyRing);

  function getFirstKeyRingAdminActionID(
    address keyRing, address additionalUserSigningKey
  ) external view returns (bytes32 adminActionID);
}


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

  function getVersion() external view returns (uint256 version);
}


interface DharmaSmartWalletImplementationV0Interface {
  function withdrawDai(
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok);

  function withdrawUSDC(
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok);
}


interface DharmaKeyRingInitializer {
  function initialize(
    uint128 adminThreshold,
    uint128 executorThreshold,
    address[] calldata keys,
    uint8[] calldata keyTypes
  ) external;
}



contract KeyRingUpgradeBeaconProxyV1 {
  
  address private constant _KEY_RING_UPGRADE_BEACON = address(
    0x0000000000BDA2152794ac8c76B2dc86cbA57cad
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
    
    (bool ok, bytes memory returnData) = _KEY_RING_UPGRADE_BEACON.staticcall("");
    
    // Revert and pass along revert message if call to upgrade beacon reverts.
    require(ok, string(returnData));

    // Set the implementation to the address returned from the upgrade beacon.
    implementation = abi.decode(returnData, (address));
  }

  /**
   * @notice Private function that delegates execution to an implementation
   * contract. This is a low level function that doesn't return to its internal
   * call site. It will return whatever is returned by the implementation to the
   * external caller, reverting and returning the revert data if implementation
   * reverts.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) private {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize)

      // Delegatecall to the implementation, supplying calldata and gas.
      // Out and outsize are set to zero - instead, use the return buffer.
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      // Copy the returned data from the return buffer.
      returndatacopy(0, 0, returndatasize)

      switch result
      // Delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }
}


/**
 * @title DharmaKeyRingFactoryV2
 * @author 0age
 * @notice This contract deploys new Dharma Key Ring instances as "Upgrade
 * Beacon" proxies that reference a shared implementation contract specified by
 * the Dharma Key Ring Upgrade Beacon contract. It also supplies methods for
 * performing additional operations post-deployment, including setting a second
 * signing key on the keyring and making a withdrawal from the associated smart
 * wallet. Note that the batch operations may fail, or be applied to the wrong
 * keyring, if another caller frontruns them by deploying a keyring to the
 * intended address first. If this becomes an issue, a future version of this
 * factory can remedy this by passing the target deployment address as an
 * additional argument and checking for existence of a contract at that address.
 * This factory builds on V1 by additionally including a helper function for
 * deriving adminActionIDs for keyrings that have not yet been deployed in order
 * to support creation of the signature parameter provided as part of calls to
 * `newKeyRingAndAdditionalKey`.
 */
contract DharmaKeyRingFactoryV2 is DharmaKeyRingFactoryV2Interface {
  
  bytes4 private constant _INITIALIZE_SELECTOR = bytes4(0x30fc201f);

  
  address private constant _KEY_RING_UPGRADE_BEACON = address(
    0x0000000000BDA2152794ac8c76B2dc86cbA57cad
  );

  
  constructor() public {
    DharmaKeyRingInitializer initializer;
    require(
      initializer.initialize.selector == _INITIALIZE_SELECTOR,
      "Incorrect initializer selector supplied."
    );
  }

  
  function newKeyRing(
    address userSigningKey, address targetKeyRing
  ) external returns (address keyRing) {
    
    keyRing = _deployNewKeyRingIfNeeded(userSigningKey, targetKeyRing);
  }

  
  function newKeyRingAndAdditionalKey(
    address userSigningKey,
    address targetKeyRing,
    address additionalSigningKey,
    bytes calldata signature
  ) external returns (address keyRing) {
    
    keyRing = _deployNewKeyRingIfNeeded(userSigningKey, targetKeyRing);

    
    DharmaKeyRingImplementationV0Interface(keyRing).takeAdminAction(
      DharmaKeyRingImplementationV0Interface.AdminActionType.AddDualKey,
      uint160(additionalSigningKey),
      signature
    );
  }

  
  function newKeyRingAndDaiWithdrawal(
    address userSigningKey,
    address targetKeyRing,
    address smartWallet,
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (address keyRing, bool withdrawalSuccess) {
    
    keyRing = _deployNewKeyRingIfNeeded(userSigningKey, targetKeyRing);

    
    withdrawalSuccess = DharmaSmartWalletImplementationV0Interface(
      smartWallet
    ).withdrawDai(
      amount, recipient, minimumActionGas, userSignature, dharmaSignature
    );
  }

  
  function newKeyRingAndUSDCWithdrawal(
    address userSigningKey,
    address targetKeyRing,
    address smartWallet,
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (address keyRing, bool withdrawalSuccess) {
    
    keyRing = _deployNewKeyRingIfNeeded(userSigningKey, targetKeyRing);

    
    withdrawalSuccess = DharmaSmartWalletImplementationV0Interface(
      smartWallet
    ).withdrawUSDC(
      amount, recipient, minimumActionGas, userSignature, dharmaSignature
    );
  }

  
  function getNextKeyRing(
    address userSigningKey
  ) external view returns (address targetKeyRing) {
    
    require(userSigningKey != address(0), "No user signing key supplied.");

    
    bytes memory initializationCalldata = _constructInitializationCalldata(
      userSigningKey
    );

    
    targetKeyRing = _computeNextAddress(initializationCalldata);
  }

  
  function getFirstKeyRingAdminActionID(
    address keyRing, address additionalUserSigningKey
  ) external view returns (bytes32 adminActionID) {
    adminActionID = keccak256(
      abi.encodePacked(
        keyRing, _getKeyRingVersion(), uint256(0), additionalUserSigningKey
      )
    );
  }

  
  function _deployNewKeyRingIfNeeded(
    address userSigningKey, address expectedKeyRing
  ) internal returns (address keyRing) {
    
    uint256 size;
    assembly { size := extcodesize(expectedKeyRing) }
    if (size == 0) {
      
      bytes memory initializationCalldata = _constructInitializationCalldata(
        userSigningKey
      );

      
      keyRing = _deployUpgradeBeaconProxyInstance(initializationCalldata);

      
      emit KeyRingDeployed(keyRing, userSigningKey);
    } else {
      
      
      
      
      
      
      keyRing = expectedKeyRing;
    }
  }

  
  function _deployUpgradeBeaconProxyInstance(
    bytes memory initializationCalldata
  ) private returns (address upgradeBeaconProxyInstance) {
    
    bytes memory initCode = abi.encodePacked(
      type(KeyRingUpgradeBeaconProxyV1).creationCode,
      abi.encode(initializationCalldata)
    );

    
    (uint256 salt, ) = _getSaltAndTarget(initCode);

    
    assembly {
      let encoded_data := add(0x20, initCode) 
      let encoded_size := mload(initCode)     
      upgradeBeaconProxyInstance := create2(  
        callvalue,                            
        encoded_data,                         
        encoded_size,                         
        salt                                  
      )

      
      if iszero(upgradeBeaconProxyInstance) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  }

  function _constructInitializationCalldata(
    address userSigningKey
  ) private pure returns (bytes memory initializationCalldata) {
    address[] memory keys = new address[](1);
    keys[0] = userSigningKey;

    uint8[] memory keyTypes = new uint8[](1);
    keyTypes[0] = uint8(3); 

    
    initializationCalldata = abi.encodeWithSelector(
      _INITIALIZE_SELECTOR, 1, 1, keys, keyTypes
    );
  }

  
  function _computeNextAddress(
    bytes memory initializationCalldata
  ) private view returns (address target) {
    
    bytes memory initCode = abi.encodePacked(
      type(KeyRingUpgradeBeaconProxyV1).creationCode,
      abi.encode(initializationCalldata)
    );

    
    (, target) = _getSaltAndTarget(initCode);
  }

  
  function _getSaltAndTarget(
    bytes memory initCode
  ) private view returns (uint256 nonce, address target) {
    
    bytes32 initCodeHash = keccak256(initCode);

    
    nonce = 0;

    
    uint256 codeSize;

    
    while (true) {
      target = address(            
        uint160(                   
          uint256(                 
            keccak256(             
              abi.encodePacked(    
                bytes1(0xff),      
                address(this),     
                nonce,              
                initCodeHash       
              )
            )
          )
        )
      );

      
      assembly { codeSize := extcodesize(target) }

      
      if (codeSize == 0) {
        break;
      }

      
      nonce++;
    }
  }

  
  function _getKeyRingVersion() private view returns (uint256 version) {
    
    (bool ok, bytes memory data) = _KEY_RING_UPGRADE_BEACON.staticcall("");

    // Revert if underlying staticcall reverts, passing along revert message.
    require(ok, string(data));

    // Ensure that the data returned from the beacon is the correct length.
    require(data.length == 32, "Return data must be exactly 32 bytes.");

    
    address implementation = abi.decode(data, (address));

    
    version = DharmaKeyRingImplementationV0Interface(
      implementation
    ).getVersion();
  }
}