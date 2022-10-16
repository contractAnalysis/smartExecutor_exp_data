pragma solidity 0.5.17; 


pragma experimental ABIEncoderV2;


interface DharmaSmartWalletImplementationV1Interface {
  event CallSuccess(
    bytes32 actionID,
    bool rolledBack,
    uint256 nonce,
    address to,
    bytes data,
    bytes returnData
  );

  event CallFailure(
    bytes32 actionID,
    uint256 nonce,
    address to,
    bytes data,
    string revertReason
  );

  
  struct Call {
    address to;
    bytes data;
  }

  
  struct CallReturn {
    bool ok;
    bytes returnData;
  }

  function withdrawEther(
    uint256 amount,
    address payable recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok);

  function executeAction(
    address to,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData);

  function recover(address newUserSigningKey) external;

  function executeActionWithAtomicBatchCalls(
    Call[] calldata calls,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool[] memory ok, bytes[] memory returnData);

  function getNextGenericActionID(
    address to,
    bytes calldata data,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);

  function getGenericActionID(
    address to,
    bytes calldata data,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);

  function getNextGenericAtomicBatchActionID(
    Call[] calldata calls,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);

  function getGenericAtomicBatchActionID(
    Call[] calldata calls,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);
}


interface DharmaSmartWalletImplementationV3Interface {
  event Cancel(uint256 cancelledNonce);
  event EthWithdrawal(uint256 amount, address recipient);
}


interface DharmaSmartWalletImplementationV4Interface {
  event Escaped();

  function setEscapeHatch(
    address account,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external;

  function removeEscapeHatch(
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external;

  function permanentlyDisableEscapeHatch(
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external;

  function escape() external;
}


interface DharmaSmartWalletImplementationV7Interface {
  
  event NewUserSigningKey(address userSigningKey);

  
  event ExternalError(address indexed source, string revertReason);

  
  enum AssetType {
    DAI,
    USDC,
    ETH,
    SAI
  }

  
  enum ActionType {
    Cancel,
    SetUserSigningKey,
    Generic,
    GenericAtomicBatch,
    SAIWithdrawal,
    USDCWithdrawal,
    ETHWithdrawal,
    SetEscapeHatch,
    RemoveEscapeHatch,
    DisableEscapeHatch,
    DAIWithdrawal,
    SignatureVerification,
    TradeEthForDai,
    DAIBorrow,
    USDCBorrow
  }

  function initialize(address userSigningKey) external;

  function repayAndDeposit() external;

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

  function cancel(
    uint256 minimumActionGas,
    bytes calldata signature
  ) external;

  function setUserSigningKey(
    address userSigningKey,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external;

  function migrateSaiToDai() external;

  function migrateCSaiToDDai() external;

  function migrateCDaiToDDai() external;

  function migrateCUSDCToDUSDC() external;

  function getBalances() external view returns (
    uint256 daiBalance,
    uint256 usdcBalance,
    uint256 etherBalance,
    uint256 dDaiUnderlyingDaiBalance,
    uint256 dUsdcUnderlyingUsdcBalance,
    uint256 dEtherUnderlyingEtherBalance 
  );

  function getUserSigningKey() external view returns (address userSigningKey);

  function getNonce() external view returns (uint256 nonce);

  function getNextCustomActionID(
    ActionType action,
    uint256 amount,
    address recipient,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);

  function getCustomActionID(
    ActionType action,
    uint256 amount,
    address recipient,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);

  function getVersion() external pure returns (uint256 version);
}


interface DharmaSmartWalletImplementationV8Interface {
  function tradeEthForDaiAndMintDDai(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData);

  function getNextEthForDaiActionID(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);

  function getEthForDaiActionID(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);
}


interface ERC20Interface {
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);

  function balanceOf(address account) external view returns (uint256);
  function allowance(
    address owner, address spender
  ) external view returns (uint256);
}


interface ERC1271Interface {
  function isValidSignature(
    bytes calldata data, bytes calldata signature
  ) external view returns (bytes4 magicValue);
}


interface CTokenInterface {
  function redeem(uint256 redeemAmount) external returns (uint256 err);
  function transfer(address recipient, uint256 value) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);

  function balanceOf(address account) external view returns (uint256 balance);
  function allowance(address owner, address spender) external view returns (uint256);
}


interface DTokenInterface {
  
  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);
  function redeem(uint256 dTokensToBurn) external returns (uint256 underlyingReceived);
  function redeemUnderlying(uint256 underlyingToReceive) external returns (uint256 dTokensBurned);

  
  function mintViaCToken(uint256 cTokensToSupply) external returns (uint256 dTokensMinted);

  
  function balanceOfUnderlying(address account) external view returns (uint256 underlyingBalance);
}


interface USDCV1Interface {
  function isBlacklisted(address _account) external view returns (bool);
  function paused() external view returns (bool);
}


interface DharmaKeyRegistryInterface {
  function getKey() external view returns (address key);
}


interface DharmaEscapeHatchRegistryInterface {
  function setEscapeHatch(address newEscapeHatch) external;

  function removeEscapeHatch() external;

  function permanentlyDisableEscapeHatch() external;

  function getEscapeHatch() external view returns (
    bool exists, address escapeHatch
  );
}


interface TradeHelperInterface {
  function tradeEthForDai(
    uint256 daiExpected, address target, bytes calldata data
  ) external payable returns (uint256 daiReceived);
}


interface RevertReasonHelperInterface {
  function reason(uint256 code) external pure returns (string memory);
}


interface EtherizedInterface {
  function triggerEtherTransfer(
    address payable target, uint256 value
  ) external returns (bool success);
}


interface ConfigurationRegistryInterface {
  function get(bytes32 key) external view returns (bytes32 value);
}


library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }
}


library ECDSA {
  function recover(
    bytes32 hash, bytes memory signature
  ) internal pure returns (address) {
    if (signature.length != 65) {
      return (address(0));
    }

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      return address(0);
    }

    if (v != 27 && v != 28) {
      return address(0);
    }

    return ecrecover(hash, v, r, s);
  }

  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }
}


contract Etherized is EtherizedInterface {
  address private constant _ETHERIZER = address(
    0x723B51b72Ae89A3d0c2a2760f0458307a1Baa191 
  );
  
  function triggerEtherTransfer(
    address payable target, uint256 amount
  ) external returns (bool success) {
    require(msg.sender == _ETHERIZER, "Etherized: only callable by Etherizer");
    (success, ) = target.call.value(amount)("");
    if (!success) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }
}


/**
 * @title DharmaSmartWalletImplementationV10 (staging version)
 * @author 0age
 * @notice The V10 implementation for the Dharma smart wallet is a non-custodial,
 * meta-transaction-enabled wallet with helper functions to facilitate lending
 * funds through Dharma Dai and Dharma USD Coin (which in turn use CompoundV2),
 * and with an added security backstop provided by Dharma Labs prior to making
 * withdrawals. It adds support for Dharma Dai and Dharma USD Coin - they employ
 * the respective cTokens as backing tokens and mint and redeem them internally
 * as interest-bearing collateral. This implementation also contains methods to
 * support account recovery, escape hatch functionality, and generic actions,
 * including in an atomic batch. The smart wallet instances utilizing this
 * implementation are deployed through the Dharma Smart Wallet Factory via
 * `CREATE2`, which allows for their address to be known ahead of time, and any
 * Dai or USDC that has already been sent into that address will automatically
 * be deposited into the respective Dharma Token upon deployment of the new
 * smart wallet instance. V10 allows for deactivation of automatic USDC deposits
 * into cUSDC and deprecates Sai-related functionality.
 */
contract DharmaSmartWalletImplementationV10Staging is
  DharmaSmartWalletImplementationV1Interface,
  DharmaSmartWalletImplementationV3Interface,
  DharmaSmartWalletImplementationV4Interface,
  DharmaSmartWalletImplementationV7Interface,
  DharmaSmartWalletImplementationV8Interface,
  ERC1271Interface,
  Etherized {
  using Address for address;
  using ECDSA for bytes32;
  // WARNING: DO NOT REMOVE OR REORDER STORAGE WHEN WRITING NEW IMPLEMENTATIONS!

  // The user signing key associated with this account is in storage slot 0.
  // It is the core differentiator when it comes to the account in question.
  address private _userSigningKey;

  // The nonce associated with this account is in storage slot 1. Every time a
  // signature is submitted, it must have the appropriate nonce, and once it has
  // been accepted the nonce will be incremented.
  uint256 private _nonce;

  // The self-call context flag is in storage slot 2. Some protected functions
  // may only be called externally from calls originating from other methods on
  // this contract, which enables appropriate exception handling on reverts.
  // Any storage should only be set immediately preceding a self-call and should
  // be cleared upon entering the protected function being called.
  bytes4 internal _selfCallContext;

  // END STORAGE DECLARATIONS - DO NOT REMOVE OR REORDER STORAGE ABOVE HERE!

  // The smart wallet version will be used when constructing valid signatures.
  uint256 internal constant _DHARMA_SMART_WALLET_VERSION = 1010;

  // DharmaKeyRegistryV2Staging holds a public key to verify meta-transactions.
  DharmaKeyRegistryInterface internal constant _DHARMA_KEY_REGISTRY = (
    DharmaKeyRegistryInterface(0x00000000006c7f32F0cD1eA4C1383558eb68802D)
  );
  // Account recovery uses a hard-coded staging version of the recovery manager.
  address internal constant _ACCOUNT_RECOVERY_MANAGER = address(
    0x2a7E7718b755F9868E6B64DD18C6886707DD9c10
  );

  // Users can designate an "escape hatch" account with the ability to sweep all
  
  DharmaEscapeHatchRegistryInterface internal constant _ESCAPE_HATCH_REGISTRY = (
    DharmaEscapeHatchRegistryInterface(0x00000000005280B515004B998a944630B6C663f8)
  );

  
  DTokenInterface internal constant _DDAI = DTokenInterface(
    0x00000000001876eB1444c986fD502e618c587430 
  );

  DTokenInterface internal constant _DUSDC = DTokenInterface(
    0x00000000008943c65cAf789FFFCF953bE156f6f8 
  );

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F 
  );

  ERC20Interface internal constant _USDC = ERC20Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 
  );

  CTokenInterface internal constant _CDAI = CTokenInterface(
    0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 
  );

  CTokenInterface internal constant _CUSDC = CTokenInterface(
    0x39AA39c021dfbaE8faC545936693aC917d5E7563 
  );
  
  
  TradeHelperInterface internal constant _TRADE_HELPER = TradeHelperInterface(
    0x421816CDFe2073945173c0c35799ec21261fB399
  );

  
  RevertReasonHelperInterface internal constant _REVERT_REASON_HELPER = (
    RevertReasonHelperInterface(0x9C0ccB765D3f5035f8b5Dd30fE375d5F4997D8E4)
  );
  
  ConfigurationRegistryInterface internal constant _CONFIG_REGISTRY = (
    ConfigurationRegistryInterface(0xC5C0ead7Df3CeFC45c8F4592E3a0f1500949E75D)
  );
  
  bytes32 internal constant _ENABLE_USDC_MINTING_KEY = bytes32(
    0x596746115f08448433597980d42b4541c0197187d07ffad9c7f66a471c49dbba
  ); 

  
  uint256 internal constant _COMPOUND_SUCCESS = 0;

  
  bytes4 internal constant _ERC_1271_MAGIC_VALUE = bytes4(0x20c13b0b);

  
  uint256 private constant _JUST_UNDER_ONE_1000th_DAI = 999999999999999;
  uint256 private constant _JUST_UNDER_ONE_1000th_USDC = 999;

  
  uint256 private constant _ETH_TRANSFER_GAS = 4999;
  
  constructor() public {
    assert(
      _ENABLE_USDC_MINTING_KEY == keccak256(
        bytes("allowAvailableUSDCToBeUsedToMintCUSDC")
      )
    );
  }

  
  function () external payable {}

  
  function initialize(address userSigningKey) external {
    
    assembly { if extcodesize(address) { revert(0, 0) } }

    
    _setUserSigningKey(userSigningKey);

    
    if (_setFullApproval(AssetType.DAI)) {
      
      uint256 daiBalance = _DAI.balanceOf(address(this));

      
      _depositDharmaToken(AssetType.DAI, daiBalance);
    }

    
    if (_setFullApproval(AssetType.USDC)) {
      
      uint256 usdcBalance = _USDC.balanceOf(address(this));

      
      _depositDharmaToken(AssetType.USDC, usdcBalance);
    }
  }

  
  function repayAndDeposit() external {
    
    uint256 daiBalance = _DAI.balanceOf(address(this));

    
    if (daiBalance > 0) {
      uint256 daiAllowance = _DAI.allowance(address(this), address(_DDAI));
      
      if (daiAllowance < daiBalance) {
        if (_setFullApproval(AssetType.DAI)) {
          
          _depositDharmaToken(AssetType.DAI, daiBalance);
        }
      
      } else {
        
        _depositDharmaToken(AssetType.DAI, daiBalance);
      }
    }

    
    uint256 usdcBalance = _USDC.balanceOf(address(this));

    
    if (usdcBalance > 0) {
      uint256 usdcAllowance = _USDC.allowance(address(this), address(_DUSDC));
      
      if (usdcAllowance < usdcBalance) {
        if (_setFullApproval(AssetType.USDC)) {
          
          _depositDharmaToken(AssetType.USDC, usdcBalance);
        }
      
      } else {
        
        _depositDharmaToken(AssetType.USDC, usdcBalance);
      }
    }
  }

  
  function withdrawDai(
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok) {
    
    _validateActionAndIncrementNonce(
      ActionType.DAIWithdrawal,
      abi.encode(amount, recipient),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    if (amount <= _JUST_UNDER_ONE_1000th_DAI) {
      revert(_revertReason(0));
    }

    
    if (recipient == address(0)) {
      revert(_revertReason(1));
    }

    
    _selfCallContext = this.withdrawDai.selector;

    
    
    
    
    
    bytes memory returnData;
    (ok, returnData) = address(this).call(abi.encodeWithSelector(
      this._withdrawDaiAtomic.selector, amount, recipient
    ));

    
    if (!ok) {
      emit ExternalError(address(_DAI), _revertReason(2));
    } else {
      
      ok = abi.decode(returnData, (bool));
    }
  }

  
  function _withdrawDaiAtomic(
    uint256 amount,
    address recipient
  ) external returns (bool success) {
    
    _enforceSelfCallFrom(this.withdrawDai.selector);

    
    bool maxWithdraw = (amount == uint256(-1));
    if (maxWithdraw) {
      
      _withdrawMaxFromDharmaToken(AssetType.DAI);

      
      require(_transferMax(_DAI, recipient, false));
      success = true;
    } else {
      
      if (_withdrawFromDharmaToken(AssetType.DAI, amount)) {
        
        require(_DAI.transfer(recipient, amount));
        success = true;
      }
    }
  }

  
  function withdrawUSDC(
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok) {
    
    _validateActionAndIncrementNonce(
      ActionType.USDCWithdrawal,
      abi.encode(amount, recipient),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    if (amount <= _JUST_UNDER_ONE_1000th_USDC) {
      revert(_revertReason(3));
    }

    
    if (recipient == address(0)) {
      revert(_revertReason(1));
    }

    
    _selfCallContext = this.withdrawUSDC.selector;

    
    
    
    
    
    bytes memory returnData;
    (ok, returnData) = address(this).call(abi.encodeWithSelector(
      this._withdrawUSDCAtomic.selector, amount, recipient
    ));
    if (!ok) {
      
      _diagnoseAndEmitUSDCSpecificError(_USDC.transfer.selector);
    } else {
      
      ok = abi.decode(returnData, (bool));
    }
  }

  
  function _withdrawUSDCAtomic(
    uint256 amount,
    address recipient
  ) external returns (bool success) {
    
    _enforceSelfCallFrom(this.withdrawUSDC.selector);

    
    bool maxWithdraw = (amount == uint256(-1));
    if (maxWithdraw) {
      
      _withdrawMaxFromDharmaToken(AssetType.USDC);

      
      require(_transferMax(_USDC, recipient, false));
      success = true;
    } else {
      
      if (_withdrawFromDharmaToken(AssetType.USDC, amount)) {
        
        require(_USDC.transfer(recipient, amount));
        success = true;
      }
    }
  }

  
  function withdrawEther(
    uint256 amount,
    address payable recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok) {
    
    _validateActionAndIncrementNonce(
      ActionType.ETHWithdrawal,
      abi.encode(amount, recipient),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    if (amount == 0) {
      revert(_revertReason(4));
    }

    
    if (recipient == address(0)) {
      revert(_revertReason(1));
    }

    
    ok = _transferETH(recipient, amount);
  }

  
  function cancel(
    uint256 minimumActionGas,
    bytes calldata signature
  ) external {
    
    uint256 nonceToCancel = _nonce;

    
    _validateActionAndIncrementNonce(
      ActionType.Cancel,
      abi.encode(),
      minimumActionGas,
      signature,
      signature
    );

    
    emit Cancel(nonceToCancel);
  }

  
  function executeAction(
    address to,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData) {
    
    _ensureValidGenericCallTarget(to);

    
    (bytes32 actionID, uint256 nonce) = _validateActionAndIncrementNonce(
      ActionType.Generic,
      abi.encode(to, data),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    
    
    

    
    (ok, returnData) = to.call(data);

    
    if (ok) {
      
      
      emit CallSuccess(actionID, false, nonce, to, data, returnData);
    } else {
      
      
      emit CallFailure(actionID, nonce, to, data, string(returnData));
    }
  }

  
  function setUserSigningKey(
    address userSigningKey,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external {
    
    _validateActionAndIncrementNonce(
      ActionType.SetUserSigningKey,
      abi.encode(userSigningKey),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    _setUserSigningKey(userSigningKey);
  }

  
  function setEscapeHatch(
    address account,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external {
    
    _validateActionAndIncrementNonce(
      ActionType.SetEscapeHatch,
      abi.encode(account),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    if (account == address(0)) {
      revert(_revertReason(5));
    }

    
    _ESCAPE_HATCH_REGISTRY.setEscapeHatch(account);
  }

  
  function removeEscapeHatch(
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external {
    
    _validateActionAndIncrementNonce(
      ActionType.RemoveEscapeHatch,
      abi.encode(),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    _ESCAPE_HATCH_REGISTRY.removeEscapeHatch();
  }

  
  function permanentlyDisableEscapeHatch(
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external {
    
    _validateActionAndIncrementNonce(
      ActionType.DisableEscapeHatch,
      abi.encode(),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    _ESCAPE_HATCH_REGISTRY.permanentlyDisableEscapeHatch();
  }

  
  function tradeEthForDaiAndMintDDai(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData) {
    
    _validateActionAndIncrementNonce(
      ActionType.TradeEthForDai,
      abi.encode(ethToSupply, minimumDaiReceived, target, data),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    
    if (minimumDaiReceived <= _JUST_UNDER_ONE_1000th_DAI) {
      revert(_revertReason(31));
    }

    
    _selfCallContext = this.tradeEthForDaiAndMintDDai.selector;

    
    
    
    
    bytes memory returnData;
    (ok, returnData) = address(this).call(abi.encodeWithSelector(
      this._tradeEthForDaiAndMintDDaiAtomic.selector,
      ethToSupply, minimumDaiReceived, target, data
    ));

    
    if (!ok) {
      emit ExternalError(
        address(_TRADE_HELPER), _decodeRevertReason(returnData)
      );
    }
  }
  
  function _tradeEthForDaiAndMintDDaiAtomic(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data
  ) external returns (bool ok, bytes memory returnData) {
    
    _enforceSelfCallFrom(this.tradeEthForDaiAndMintDDai.selector);
    
    
    uint256 daiReceived = _TRADE_HELPER.tradeEthForDai.value(ethToSupply)(
      minimumDaiReceived, target, data
    );
    
    
    if (daiReceived < minimumDaiReceived) {
      revert(_revertReason(32));
    }
    
    
    _depositDharmaToken(AssetType.DAI, daiReceived);
  }

  
  function escape() external {
    
    (bool exists, address escapeHatch) = _ESCAPE_HATCH_REGISTRY.getEscapeHatch();

    
    if (!exists) {
      revert(_revertReason(6));
    }

    
    if (msg.sender != escapeHatch) {
      revert(_revertReason(7));
    }

    
    _withdrawMaxFromDharmaToken(AssetType.DAI);

    
    _withdrawMaxFromDharmaToken(AssetType.USDC);

    
    _transferMax(_DAI, msg.sender, true);

    
    _transferMax(_USDC, msg.sender, true);

    
    _transferMax(ERC20Interface(address(_CDAI)), msg.sender, true);

    
    _transferMax(ERC20Interface(address(_CUSDC)), msg.sender, true);

    
    _transferMax(ERC20Interface(address(_DDAI)), msg.sender, true);

    
    _transferMax(ERC20Interface(address(_DUSDC)), msg.sender, true);

    
    uint256 balance = address(this).balance;
    if (balance > 0) {
      
      _transferETH(msg.sender, balance);
    }

    
    emit Escaped();
  }

  
  function recover(address newUserSigningKey) external {
    
    if (msg.sender != _ACCOUNT_RECOVERY_MANAGER) {
      revert(_revertReason(8));
    }

    
    _nonce++;

    
    _setUserSigningKey(newUserSigningKey);
  }

  
  function migrateSaiToDai() external {
    revert();
  }

  
  function migrateCSaiToDDai() external {
    revert();
  }

  
  function migrateCDaiToDDai() external {
     _migrateCTokenToDToken(AssetType.DAI);
  }

  
  function migrateCUSDCToDUSDC() external {
     _migrateCTokenToDToken(AssetType.USDC);
  }

  
  function getBalances() external view returns (
    uint256 daiBalance,
    uint256 usdcBalance,
    uint256 etherBalance,
    uint256 dDaiUnderlyingDaiBalance,
    uint256 dUsdcUnderlyingUsdcBalance,
    uint256 dEtherUnderlyingEtherBalance 
  ) {
    daiBalance = _DAI.balanceOf(address(this));
    usdcBalance = _USDC.balanceOf(address(this));
    etherBalance = address(this).balance;
    dDaiUnderlyingDaiBalance = _DDAI.balanceOfUnderlying(address(this));
    dUsdcUnderlyingUsdcBalance = _DUSDC.balanceOfUnderlying(address(this));
  }

  
  function getUserSigningKey() external view returns (address userSigningKey) {
    userSigningKey = _userSigningKey;
  }

  
  function getNonce() external view returns (uint256 nonce) {
    nonce = _nonce;
  }

  
  function getNextCustomActionID(
    ActionType action,
    uint256 amount,
    address recipient,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {
    
    actionID = _getActionID(
      action,
      _validateCustomActionTypeAndGetArguments(action, amount, recipient),
      _nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  
  function getCustomActionID(
    ActionType action,
    uint256 amount,
    address recipient,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {
    
    actionID = _getActionID(
      action,
      _validateCustomActionTypeAndGetArguments(action, amount, recipient),
      nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  
  function getNextGenericActionID(
    address to,
    bytes calldata data,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {
    
    actionID = _getActionID(
      ActionType.Generic,
      abi.encode(to, data),
      _nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  
  function getGenericActionID(
    address to,
    bytes calldata data,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {
    
    actionID = _getActionID(
      ActionType.Generic,
      abi.encode(to, data),
      nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  
  function getNextEthForDaiActionID(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {
    
    actionID = _getActionID(
      ActionType.TradeEthForDai,
      abi.encode(ethToSupply, minimumDaiReceived, target, data),
      _nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

   
  function getEthForDaiActionID(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {
    
    actionID = _getActionID(
      ActionType.TradeEthForDai,
      abi.encode(ethToSupply, minimumDaiReceived, target, data),
      nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  
  function isValidSignature(
    bytes calldata data, bytes calldata signatures
  ) external view returns (bytes4 magicValue) {
    
    bytes32 digest;
    bytes memory context;

    if (data.length == 32) {
      digest = abi.decode(data, (bytes32));
    } else {
      if (data.length < 64) {
        revert(_revertReason(30));
      }
      (digest, context) = abi.decode(data, (bytes32, bytes));
    }

    
    if (signatures.length != 130) {
      revert(_revertReason(11));
    }
    bytes memory signaturesInMemory = signatures;
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      r := mload(add(signaturesInMemory, 0x20))
      s := mload(add(signaturesInMemory, 0x40))
      v := byte(0, mload(add(signaturesInMemory, 0x60)))
    }
    bytes memory dharmaSignature = abi.encodePacked(r, s, v);

    assembly {
      r := mload(add(signaturesInMemory, 0x61))
      s := mload(add(signaturesInMemory, 0x81))
      v := byte(0, mload(add(signaturesInMemory, 0xa1)))
    }
    bytes memory userSignature = abi.encodePacked(r, s, v);

    
    if (
      !_validateUserSignature(
        digest,
        ActionType.SignatureVerification,
        context,
        _userSigningKey,
        userSignature
      )
    ) {
      revert(_revertReason(12));
    }

    
    if (_getDharmaSigningKey() != digest.recover(dharmaSignature)) {
      revert(_revertReason(13));
    }

    
    magicValue = _ERC_1271_MAGIC_VALUE;
  }

   
  function getImplementation() external view returns (address implementation) {
    (bool ok, bytes memory returnData) = address(
      0x0000000000b45D6593312ac9fdE193F3D0633644
    ).staticcall("");
    require(ok && returnData.length == 32, "Invalid implementation.");
    implementation = abi.decode(returnData, (address));
  }

  /**
   * @notice Pure function for getting the current Dharma Smart Wallet version.
   * @return The current Dharma Smart Wallet version.
   */
  function getVersion() external pure returns (uint256 version) {
    version = _DHARMA_SMART_WALLET_VERSION;
  }

  /**
   * @notice Perform a series of generic calls to other contracts. If any call
   * fails during execution, the preceding calls will be rolled back, but their
   * original return data will still be accessible. Calls that would otherwise
   * occur after the failed call will not be executed. Note that accounts with
   * no code may not be specified, nor may the smart wallet itself or the escape
   * hatch registry. In order to increment the nonce and invalidate the
   * signatures, a call to this function with valid targets, signatutes, and gas
   * will always succeed. To determine whether each call made as part of the
   * action was successful or not, either the corresponding return value or the
   * corresponding `CallSuccess` or `CallFailure` event can be used - note that
   * even calls that return a success status will have been rolled back unless
   * all of the calls returned a success status. Finally, note that this
   * function must currently be implemented as a public function (instead of as
   * an external one) due to an ABIEncoderV2 `UnimplementedFeatureError`.
   * @param calls Call[] A struct containing the target and calldata to provide
   * when making each call.
   * @param minimumActionGas uint256 The minimum amount of gas that must be
   * provided to this call - be aware that additional gas must still be included
   * to account for the cost of overhead incurred up until the start of this
   * function call.
   * @param userSignature bytes A signature that resolves to the public key
   * set for this account in storage slot zero, `_userSigningKey`. If the user
   * signing key is not a contract, ecrecover will be used; otherwise, ERC1271
   * will be used. A unique hash returned from `getCustomActionID` is prefixed
   * and hashed to create the message hash for the signature.
   * @param dharmaSignature bytes A signature that resolves to the public key
   * returned for this account from the Dharma Key Registry. A unique hash
   * returned from `getCustomActionID` is prefixed and hashed to create the
   * signed message.
   * @return An array of structs signifying the status of each call, as well as
   * any data returned from that call. Calls that are not executed will return
   * empty data.
   */
  function executeActionWithAtomicBatchCalls(
    Call[] memory calls,
    uint256 minimumActionGas,
    bytes memory userSignature,
    bytes memory dharmaSignature
  ) public returns (bool[] memory ok, bytes[] memory returnData) {
    // Ensure that each `to` address is a contract and is not this contract.
    for (uint256 i = 0; i < calls.length; i++) {
      _ensureValidGenericCallTarget(calls[i].to);
    }

    // Ensure caller and/or supplied signatures are valid and increment nonce.
    (bytes32 actionID, uint256 nonce) = _validateActionAndIncrementNonce(
      ActionType.GenericAtomicBatch,
      abi.encode(calls),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    // Note: from this point on, there are no reverts (apart from out-of-gas or
    // call-depth-exceeded) originating from this contract. However, one of the
    // calls may revert, in which case the function will return `false`, along
    // with the revert reason encoded as bytes, and fire an CallFailure event.

    // Specify length of returned values in order to work with them in memory.
    ok = new bool[](calls.length);
    returnData = new bytes[](calls.length);

    // Set self-call context to call _executeActionWithAtomicBatchCallsAtomic.
    _selfCallContext = this.executeActionWithAtomicBatchCalls.selector;

    // Make the atomic self-call - if any call fails, calls that preceded it
    // will be rolled back and calls that follow it will not be made.
    (bool externalOk, bytes memory rawCallResults) = address(this).call(
      abi.encodeWithSelector(
        this._executeActionWithAtomicBatchCallsAtomic.selector, calls
      )
    );

    // Parse data returned from self-call into each call result and store / log.
    CallReturn[] memory callResults = abi.decode(rawCallResults, (CallReturn[]));
    for (uint256 i = 0; i < callResults.length; i++) {
      Call memory currentCall = calls[i];

      // Set the status and the return data / revert reason from the call.
      ok[i] = callResults[i].ok;
      returnData[i] = callResults[i].returnData;

      // Emit CallSuccess or CallFailure event based on the outcome of the call.
      if (callResults[i].ok) {
        // Note: while the call succeeded, the action may still have "failed".
        emit CallSuccess(
          actionID,
          !externalOk, 
          nonce,
          currentCall.to,
          currentCall.data,
          callResults[i].returnData
        );
      } else {
        
        
        emit CallFailure(
          actionID,
          nonce,
          currentCall.to,
          currentCall.data,
          string(callResults[i].returnData)
        );

        
        break;
      }
    }
  }

  
  function _executeActionWithAtomicBatchCallsAtomic(
    Call[] memory calls
  ) public returns (CallReturn[] memory callResults) {
    
    _enforceSelfCallFrom(this.executeActionWithAtomicBatchCalls.selector);

    bool rollBack = false;
    callResults = new CallReturn[](calls.length);

    for (uint256 i = 0; i < calls.length; i++) {
      
      (bool ok, bytes memory returnData) = calls[i].to.call(calls[i].data);
      callResults[i] = CallReturn({ok: ok, returnData: returnData});
      if (!ok) {
        
        rollBack = true;
        break;
      }
    }

    if (rollBack) {
      
      bytes memory callResultsBytes = abi.encode(callResults);
      assembly { revert(add(32, callResultsBytes), mload(callResultsBytes)) }
    }
  }

  
  function getNextGenericAtomicBatchActionID(
    Call[] memory calls,
    uint256 minimumActionGas
  ) public view returns (bytes32 actionID) {
    
    actionID = _getActionID(
      ActionType.GenericAtomicBatch,
      abi.encode(calls),
      _nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  
  function getGenericAtomicBatchActionID(
    Call[] memory calls,
    uint256 nonce,
    uint256 minimumActionGas
  ) public view returns (bytes32 actionID) {
    
    actionID = _getActionID(
      ActionType.GenericAtomicBatch,
      abi.encode(calls),
      nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  
  function _setUserSigningKey(address userSigningKey) internal {
    
    if (userSigningKey == address(0)) {
      revert(_revertReason(14));
    }

    _userSigningKey = userSigningKey;
    emit NewUserSigningKey(userSigningKey);
  }

  
  function _setFullApproval(AssetType asset) internal returns (bool ok) {
    
    address token;
    address dToken;
    if (asset == AssetType.DAI) {
      token = address(_DAI);
      dToken = address(_DDAI);
    } else {
      token = address(_USDC);
      dToken = address(_DUSDC);
    }

    
    (ok, ) = address(token).call(abi.encodeWithSelector(
      
      _DAI.approve.selector, dToken, uint256(-1)
    ));

    
    if (!ok) {
      if (asset == AssetType.DAI) {
        emit ExternalError(address(_DAI), _revertReason(17));
      } else {
        
        _diagnoseAndEmitUSDCSpecificError(_USDC.approve.selector);
      }
    }
  }

  
  function _depositDharmaToken(AssetType asset, uint256 balance) internal {
    
    if (
      asset == AssetType.DAI && balance > _JUST_UNDER_ONE_1000th_DAI ||
      asset == AssetType.USDC && (
        balance > _JUST_UNDER_ONE_1000th_USDC &&
        uint256(_CONFIG_REGISTRY.get(_ENABLE_USDC_MINTING_KEY)) != 0
      )
    ) {
      
      address dToken = asset == AssetType.DAI ? address(_DDAI) : address(_DUSDC);

      
      (bool ok, bytes memory data) = dToken.call(abi.encodeWithSelector(
        
        _DDAI.mint.selector, balance
      ));

      
      _checkDharmaTokenInteractionAndLogAnyErrors(
        asset, _DDAI.mint.selector, ok, data
      );
    }
  }

  
  function _withdrawFromDharmaToken(
    AssetType asset, uint256 balance
  ) internal returns (bool success) {
    
    address dToken = asset == AssetType.DAI ? address(_DDAI) : address(_DUSDC);

    
    (bool ok, bytes memory data) = dToken.call(abi.encodeWithSelector(
      
      _DDAI.redeemUnderlying.selector, balance
    ));

    
    success = _checkDharmaTokenInteractionAndLogAnyErrors(
      asset, _DDAI.redeemUnderlying.selector, ok, data
    );
  }

  
  function _withdrawMaxFromDharmaToken(AssetType asset) internal {
    
    address dToken = asset == AssetType.DAI ? address(_DDAI) : address(_DUSDC);

    
    ERC20Interface dTokenBalance;
    (bool ok, bytes memory data) = dToken.call(abi.encodeWithSelector(
      dTokenBalance.balanceOf.selector, address(this)
    ));

    uint256 redeemAmount = 0;
    if (ok && data.length == 32) {
      redeemAmount = abi.decode(data, (uint256));
    } else {
      
      _checkDharmaTokenInteractionAndLogAnyErrors(
        asset, dTokenBalance.balanceOf.selector, ok, data
      );
    }

    
    if (redeemAmount > 0) {
      
      (ok, data) = dToken.call(abi.encodeWithSelector(
        
        _DDAI.redeem.selector, redeemAmount
      ));

      
      _checkDharmaTokenInteractionAndLogAnyErrors(
        asset, _DDAI.redeem.selector, ok, data
      );
    }
  }

  
  function _transferMax(
    ERC20Interface token, address recipient, bool suppressRevert
  ) internal returns (bool success) {
    
    uint256 balance = 0;
    bool balanceCheckWorked = true;
    if (!suppressRevert) {
      balance = token.balanceOf(address(this));
    } else {
      
      (bool ok, bytes memory data) = address(token).call.gas(gasleft() / 2)(
        abi.encodeWithSelector(token.balanceOf.selector, address(this))
      );

      if (ok && data.length == 32) {
        balance = abi.decode(data, (uint256));
      } else {
        
        balanceCheckWorked = false;
      }
    }

    
    if (balance > 0) {
      if (!suppressRevert) {
        
        success = token.transfer(recipient, balance);
      } else {
        
        (success, ) = address(token).call.gas(gasleft() / 2)(
          abi.encodeWithSelector(token.transfer.selector, recipient, balance)
        );
      }
    } else {
      
      success = balanceCheckWorked;
    }
  }

  
  function _transferETH(
    address payable recipient, uint256 amount
  ) internal returns (bool success) {
    
    (success, ) = recipient.call.gas(_ETH_TRANSFER_GAS).value(amount)("");
    if (!success) {
      emit ExternalError(recipient, _revertReason(18));
    } else {
      emit EthWithdrawal(amount, recipient);
    }
  }

  /**
   * @notice Internal function for validating supplied gas (if specified),
   * retrieving the signer's public key from the Dharma Key Registry, deriving
   * the action ID, validating the provided caller and/or signatures using that
   * action ID, and incrementing the nonce. This function serves as the
   * entrypoint for all protected "actions" on the smart wallet, and is the only
   * area where these functions should revert (other than due to out-of-gas
   * errors, which can be guarded against by supplying a minimum action gas
   * requirement).
   * @param action uint8 The type of action, designated by it's index. Valid
   * actions in V8 include Cancel (0), SetUserSigningKey (1), Generic (2),
   * GenericAtomicBatch (3), DAIWithdrawal (10), USDCWithdrawal (5),
   * ETHWithdrawal (6), SetEscapeHatch (7), RemoveEscapeHatch (8), and
   * DisableEscapeHatch (9).
   * @param arguments bytes ABI-encoded arguments for the action.
   * @param minimumActionGas uint256 The minimum amount of gas that must be
   * provided to this call - be aware that additional gas must still be included
   * to account for the cost of overhead incurred up until the start of this
   * function call.
   * @param userSignature bytes A signature that resolves to the public key
   * set for this account in storage slot zero, `_userSigningKey`. If the user
   * signing key is not a contract, ecrecover will be used; otherwise, ERC1271
   * will be used. A unique hash returned from `getCustomActionID` is prefixed
   * and hashed to create the message hash for the signature.
   * @param dharmaSignature bytes A signature that resolves to the public key
   * returned for this account from the Dharma Key Registry. A unique hash
   * returned from `getCustomActionID` is prefixed and hashed to create the
   * signed message.
   * @return The nonce of the current action (prior to incrementing it).
   */
  function _validateActionAndIncrementNonce(
    ActionType action,
    bytes memory arguments,
    uint256 minimumActionGas,
    bytes memory userSignature,
    bytes memory dharmaSignature
  ) internal returns (bytes32 actionID, uint256 actionNonce) {
    
    
    
    
    
    
    if (minimumActionGas != 0) {
      if (gasleft() < minimumActionGas) {
        revert(_revertReason(19));
      }
    }

    
    actionNonce = _nonce;

    
    address userSigningKey = _userSigningKey;

    
    address dharmaSigningKey = _getDharmaSigningKey();

    
    actionID = _getActionID(
      action,
      arguments,
      actionNonce,
      minimumActionGas,
      userSigningKey,
      dharmaSigningKey
    );

    
    bytes32 messageHash = actionID.toEthSignedMessageHash();

    
    if (action != ActionType.Cancel) {
      
      if (msg.sender != userSigningKey) {
        if (
          !_validateUserSignature(
            messageHash, action, arguments, userSigningKey, userSignature
          )
        ) {
          revert(_revertReason(20));
        }
      }

      
      if (msg.sender != dharmaSigningKey) {
        if (dharmaSigningKey != messageHash.recover(dharmaSignature)) {
          revert(_revertReason(21));
        }
      }
    } else {
      
      if (msg.sender != userSigningKey && msg.sender != dharmaSigningKey) {
        if (
          dharmaSigningKey != messageHash.recover(dharmaSignature) &&
          !_validateUserSignature(
            messageHash, action, arguments, userSigningKey, userSignature
          )
        ) {
          revert(_revertReason(22));
        }
      }
    }

    
    _nonce++;
  }

  
  function _migrateCTokenToDToken(AssetType token) internal {
    CTokenInterface cToken;
    DTokenInterface dToken;

    if (token == AssetType.DAI) {
      cToken = _CDAI;
      dToken = _DDAI;
    } else {
      cToken = _CUSDC;
      dToken = _DUSDC;
    }

    
    uint256 balance = cToken.balanceOf(address(this));

    
    if (balance > 0) {    
      
      if (cToken.allowance(address(this), address(dToken)) < balance) {
        if (!cToken.approve(address(dToken), uint256(-1))) {
          revert(_revertReason(23));
        }
      }
      
      
      if (dToken.mintViaCToken(balance) == 0) {
        revert(_revertReason(24));
      }
    }
  }

  
  function _checkDharmaTokenInteractionAndLogAnyErrors(
    AssetType asset,
    bytes4 functionSelector,
    bool ok,
    bytes memory data
  ) internal returns (bool success) {
    
    if (ok) {
      if (data.length == 32) {
        uint256 amount = abi.decode(data, (uint256));
        if (amount > 0) {
          success = true;
        } else {
          
          (address account, string memory name, string memory functionName) = (
            _getDharmaTokenDetails(asset, functionSelector)
          );

          emit ExternalError(
            account,
            string(
              abi.encodePacked(
                name,
                " gave no tokens calling ",
                functionName,
                "."
              )
            )
          );         
        }
      } else {
        
        (address account, string memory name, string memory functionName) = (
          _getDharmaTokenDetails(asset, functionSelector)
        );

        emit ExternalError(
          account,
          string(
            abi.encodePacked(
              name,
              " gave bad data calling ",
              functionName,
              "."
            )
          )
        );        
      }
      
    } else {
      
      (address account, string memory name, string memory functionName) = (
        _getDharmaTokenDetails(asset, functionSelector)
      );

      
      string memory revertReason = _decodeRevertReason(data);

      emit ExternalError(
        account,
        string(
          abi.encodePacked(
            name,
            " reverted calling ",
            functionName,
            ": ",
            revertReason
          )
        )
      );
    }
  }

  
  function _diagnoseAndEmitUSDCSpecificError(bytes4 functionSelector) internal {
    
    string memory functionName;
    if (functionSelector == _USDC.transfer.selector) {
      functionName = "transfer";
    } else {
      functionName = "approve";
    }
    
    USDCV1Interface usdcNaughty = USDCV1Interface(address(_USDC));

    
    if (usdcNaughty.isBlacklisted(address(this))) {
      emit ExternalError(
        address(_USDC),
        string(
          abi.encodePacked(
            functionName, " failed - USDC has blacklisted this user."
          )
        )
      );
    } else { 
      if (usdcNaughty.paused()) {
        emit ExternalError(
          address(_USDC),
          string(
            abi.encodePacked(
              functionName, " failed - USDC contract is currently paused."
            )
          )
        );
      } else {
        emit ExternalError(
          address(_USDC),
          string(
            abi.encodePacked(
              "USDC contract reverted on ", functionName, "."
            )
          )
        );
      }
    }
  }

  
  function _enforceSelfCallFrom(bytes4 selfCallContext) internal {
    
    if (msg.sender != address(this) || _selfCallContext != selfCallContext) {
      revert(_revertReason(25));
    }

    
    delete _selfCallContext;
  }

  
  function _validateUserSignature(
    bytes32 messageHash,
    ActionType action,
    bytes memory arguments,
    address userSigningKey,
    bytes memory userSignature
  ) internal view returns (bool valid) {
    if (!userSigningKey.isContract()) {
      valid = userSigningKey == messageHash.recover(userSignature);
    } else {
      bytes memory data = abi.encode(messageHash, action, arguments);
      valid = (
        ERC1271Interface(userSigningKey).isValidSignature(
          data, userSignature
        ) == _ERC_1271_MAGIC_VALUE
      );
    }
  }

  
  function _getDharmaSigningKey() internal view returns (
    address dharmaSigningKey
  ) {
    dharmaSigningKey = _DHARMA_KEY_REGISTRY.getKey();
  }

  
  function _getActionID(
    ActionType action,
    bytes memory arguments,
    uint256 nonce,
    uint256 minimumActionGas,
    address userSigningKey,
    address dharmaSigningKey
  ) internal view returns (bytes32 actionID) {
    
    actionID = keccak256(
      abi.encodePacked(
        address(this),
        _DHARMA_SMART_WALLET_VERSION,
        userSigningKey,
        dharmaSigningKey,
        nonce,
        minimumActionGas,
        action,
        arguments
      )
    );
  }

  
  function _getDharmaTokenDetails(
    AssetType asset,
    bytes4 functionSelector
  ) internal pure returns (
    address account,
    string memory name,
    string memory functionName
  ) {
    if (asset == AssetType.DAI) {
      account = address(_DDAI);
      name = "Dharma Dai";
    } else {
      account = address(_DUSDC);
      name = "Dharma USD Coin";
    }

    
    if (functionSelector == _DDAI.mint.selector) {
      functionName = "mint";
    } else {
      if (functionSelector == ERC20Interface(account).balanceOf.selector) {
        functionName = "balanceOf";
      } else {
        functionName = string(abi.encodePacked(
          "redeem",
          functionSelector == _DDAI.redeem.selector ? "" : "Underlying"
        ));
      }
    }
  }

  
  function _ensureValidGenericCallTarget(address to) internal view {
    if (!to.isContract()) {
      revert(_revertReason(26));
    }
    
    if (to == address(this)) {
      revert(_revertReason(27));
    }

    if (to == address(_ESCAPE_HATCH_REGISTRY)) {
      revert(_revertReason(28));
    }
  }

  
  function _validateCustomActionTypeAndGetArguments(
    ActionType action, uint256 amount, address recipient
  ) internal pure returns (bytes memory arguments) {
    
    bool validActionType = (
      action == ActionType.Cancel ||
      action == ActionType.SetUserSigningKey ||
      action == ActionType.DAIWithdrawal ||
      action == ActionType.USDCWithdrawal ||
      action == ActionType.ETHWithdrawal ||
      action == ActionType.SetEscapeHatch ||
      action == ActionType.RemoveEscapeHatch ||
      action == ActionType.DisableEscapeHatch
    );
    if (!validActionType) {
      revert(_revertReason(29));
    }

    
    if (
      action == ActionType.Cancel ||
      action == ActionType.RemoveEscapeHatch ||
      action == ActionType.DisableEscapeHatch
    ) {
      
      arguments = abi.encode();
    } else if (
      action == ActionType.SetUserSigningKey ||
      action == ActionType.SetEscapeHatch
    ) {
      
      arguments = abi.encode(recipient);
    } else {
      
      arguments = abi.encode(amount, recipient);
    }
  }

  
  function _decodeRevertReason(
    bytes memory revertData
  ) internal pure returns (string memory revertReason) {
    
    if (
      revertData.length > 68 && 
      revertData[0] == byte(0x08) &&
      revertData[1] == byte(0xc3) &&
      revertData[2] == byte(0x79) &&
      revertData[3] == byte(0xa0)
    ) {
      
      bytes memory revertReasonBytes = new bytes(revertData.length - 4);
      for (uint256 i = 4; i < revertData.length; i++) {
        revertReasonBytes[i - 4] = revertData[i];
      }

      
      revertReason = abi.decode(revertReasonBytes, (string));
    } else {
      
      revertReason = _revertReason(uint256(-1));
    }
  }

  
  function _revertReason(
    uint256 code
  ) internal pure returns (string memory reason) {
    reason = _REVERT_REASON_HELPER.reason(code);
  }
}