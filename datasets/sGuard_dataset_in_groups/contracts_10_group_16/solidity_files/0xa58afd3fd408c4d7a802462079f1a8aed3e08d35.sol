pragma solidity 0.5.11; 


interface DharmaSmartWalletFactoryV1Interface {
  
  event SmartWalletDeployed(address wallet, address userSigningKey);

  function newSmartWallet(
    address userSigningKey
  ) external returns (address wallet);
  
  function getNextSmartWallet(
    address userSigningKey
  ) external view returns (address wallet);
}


interface DharmaSmartWalletInitializer {
  function initialize(address userSigningKey) external;
}



contract UpgradeBeaconProxyV1Prototype {
  
  address private constant _UPGRADE_BEACON = address(
    0x5BF07ceDF1296B1C11966832c3e75895ad6E1E2a
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
 * @title DharmaSmartWalletFactoryV1Prototype
 * @author 0age
 * @notice This contract deploys new Dharma Smart Wallet instances as "Upgrade
 * Beacon" proxies that reference a shared implementation contract specified by
 * the Dharma Upgrade Beacon contract.
 */
contract DharmaSmartWalletFactoryV1Prototype is DharmaSmartWalletFactoryV1Interface {
  
  DharmaSmartWalletInitializer private _INITIALIZER;

  
  function newSmartWallet(
    address userSigningKey
  ) external returns (address wallet) {
    
    bytes memory initializationCalldata = abi.encodeWithSelector(
      _INITIALIZER.initialize.selector,
      userSigningKey
    );
    
    
    wallet = _deployUpgradeBeaconProxyInstance(initializationCalldata);

    
    emit SmartWalletDeployed(wallet, userSigningKey);
  }

  
  function getNextSmartWallet(
    address userSigningKey
  ) external view returns (address wallet) {
    
    bytes memory initializationCalldata = abi.encodeWithSelector(
      _INITIALIZER.initialize.selector,
      userSigningKey
    );
    
    
    wallet = _computeNextAddress(initializationCalldata);
  }

  
  function _deployUpgradeBeaconProxyInstance(
    bytes memory initializationCalldata
  ) private returns (address upgradeBeaconProxyInstance) {
    
    bytes memory initCode = abi.encodePacked(
      type(UpgradeBeaconProxyV1Prototype).creationCode,
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

  
  function _computeNextAddress(
    bytes memory initializationCalldata
  ) private view returns (address target) {
    
    bytes memory initCode = abi.encodePacked(
      type(UpgradeBeaconProxyV1Prototype).creationCode,
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
}