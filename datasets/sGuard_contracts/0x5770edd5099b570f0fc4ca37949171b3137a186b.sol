pragma solidity 0.5.11; 


interface DharmaTransferFacilitatorInterface {
  event RoleModified(Role indexed role, address account);
  event RolePaused(Role indexed role);
  event RoleUnpaused(Role indexed role);

  enum Role {
    TRANSFERRER,
    PAUSER
  }

  struct RoleStatus {
    address account;
    bool paused;
  }

  function enactDDaiTransfer(
    address senderSmartWallet,
    address recipientInitialSigningKey, 
    address recipientSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external;

  function deploySenderWalletAndEnactDDaiTransfer(
    address senderInitialSigningKey, 
    address senderSmartWallet,
    address recipientInitialSigningKey, 
    address recipientSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external;

  function deploySenderKeyRingAndEnactDDaiTransfer(
    address senderInitialKeyRingSigningKey, 
    address senderKeyRing, 
    address senderSmartWallet,
    address recipientInitialSigningKey, 
    address recipientSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external;
  
  function deploySenderKeyRingAndWalletAndEnactDDaiTransfer(
    address senderInitialKeyRingSigningKey, 
    address senderKeyRing, 
    address senderSmartWallet,
    address recipientInitialSigningKey, 
    address recipientSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external;

  function withdraw(
    ERC20Interface token, address recipient, uint256 amount
  ) external returns (bool success);

  function callGeneric(
    address payable target, uint256 amount, bytes calldata data
  ) external returns (bool ok, bytes memory returnData);
  
  function setLimit(uint256 daiAmount) external;

  function setRole(Role role, address account) external;

  function removeRole(Role role) external;

  function pause(Role role) external;

  function unpause(Role role) external;

  function isPaused(Role role) external view returns (bool paused);

  function isRole(Role role) external view returns (bool hasRole);

  function getTransferrer() external view returns (address transferrer);

  function getPauser() external view returns (address pauser);
  
  function getLimit() external view returns (
    uint256 daiAmount, uint256 dDaiAmount
  );

  function isDharmaSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) external pure returns (bool dharmaSmartWallet);
}


interface ERC20Interface {
  function balanceOf(address) external view returns (uint256);
  function approve(address, uint256) external returns (bool);
  function transfer(address, uint256) external returns (bool);
}


interface DTokenInterface {
  function transferFrom(
    address sender, address recipient, uint256 amount
  ) external returns (bool success);
  function modifyAllowanceViaMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external returns (bool success);
  function approve(address, uint256) external returns (bool);

  function exchangeRateCurrent() external view returns (uint256);
  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view returns (bytes32 digest, bool valid);
  function allowance(address, address) external view returns (uint256);
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


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }
}



contract TwoStepOwnable {
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  address private _owner;

  address private _newPotentialOwner;

  
  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
  }

  
  function transferOwnership(address newOwner) external onlyOwner {
    require(
      newOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  
  function cancelOwnershipTransfer() external onlyOwner {
    delete _newPotentialOwner;
  }

  
  function acceptOwnership() external {
    require(
      msg.sender == _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }

  
  function owner() external view returns (address) {
    return _owner;
  }

  
  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }
}



contract DharmaTransferFacilitatorV2 is
  DharmaTransferFacilitatorInterface, TwoStepOwnable {
  using SafeMath for uint256;

  
  mapping(uint256 => RoleStatus) private _roles;
  
  
  uint256 private _limit;

  
  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F 
  );

  DTokenInterface internal constant _DDAI = DTokenInterface(
    0x00000000001876eB1444c986fD502e618c587430
  );

  
  bytes21 internal constant _CREATE2_HEADER = bytes21(
    0xfffc00c80b0000007f73004edb00094cad80626d8d 
  );
  
  
  bytes internal constant _WALLET_CREATION_CODE_HEADER = hex"60806040526040516104423803806104428339818101604052602081101561002657600080fd5b810190808051604051939291908464010000000082111561004657600080fd5b90830190602082018581111561005b57600080fd5b825164010000000081118282018810171561007557600080fd5b82525081516020918201929091019080838360005b838110156100a257818101518382015260200161008a565b50505050905090810190601f1680156100cf5780820380516001836020036101000a031916815260200191505b5060405250505060006100e661019e60201b60201c565b6001600160a01b0316826040518082805190602001908083835b6020831061011f5780518252601f199092019160209182019101610100565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855af49150503d806000811461017f576040519150601f19603f3d011682016040523d82523d6000602084013e610184565b606091505b5050905080610197573d6000803e3d6000fd5b50506102be565b60405160009081906060906e26750c571ce882b17016557279adaa9083818181855afa9150503d80600081146101f0576040519150601f19603f3d011682016040523d82523d6000602084013e6101f5565b606091505b509150915081819061029f576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825283818151815260200191508051906020019080838360005b8381101561026457818101518382015260200161024c565b50505050905090810190601f1680156102915780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b508080602001905160208110156102b557600080fd5b50519392505050565b610175806102cd6000396000f3fe608060405261001461000f610016565b61011c565b005b60405160009081906060906e26750c571ce882b17016557279adaa9083818181855afa9150503d8060008114610068576040519150601f19603f3d011682016040523d82523d6000602084013e61006d565b606091505b50915091508181906100fd5760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b838110156100c25781810151838201526020016100aa565b50505050905090810190601f1680156100ef5780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b5080806020019051602081101561011357600080fd5b50519392505050565b3660008037600080366000845af43d6000803e80801561013b573d6000f35b3d6000fdfea265627a7a7231582020202020202055706772616465426561636f6e50726f7879563120202020202064736f6c634300050b003200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000024c4d66de8000000000000000000000000";
  bytes28 internal constant _WALLET_CREATION_CODE_FOOTER = bytes28(
    0x00000000000000000000000000000000000000000000000000000000
  );

  DharmaSmartWalletFactoryV1Interface internal constant _WALLET_FACTORY = (
    DharmaSmartWalletFactoryV1Interface(
      0xfc00C80b0000007F73004edB00094caD80626d8D
    )
  );
  
  DharmaKeyRingFactoryV2Interface internal constant _KEYRING_FACTORY = (
    DharmaKeyRingFactoryV2Interface(
      0x2484000059004afB720000dc738434fA6200F49D
    )
  );

  
  bytes32 internal constant _SMART_WALLET_INSTANCE_RUNTIME_HASH = bytes32(
    0xe25d4f154acb2394ee6c18d64fb5635959ba063d57f83091ec9cf34be16224d7
  );

  
  bytes32 internal constant _KEY_RING_INSTANCE_RUNTIME_HASH = bytes32(
    0xb15b24278e79e856d35b262e76ff7d3a759b17e625ff72adde4116805af59648
  );

  
  constructor() public {    
    
    _limit = 300 * 1e18;
  }

  
  function enactDDaiTransfer(
    address senderSmartWallet,
    address recipientInitialSigningKey, 
    address recipientSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external onlyOwnerOr(Role.TRANSFERRER) {
    
    require(
      _isSmartWallet(recipientSmartWallet, recipientInitialSigningKey),
      "Could not resolve receiver's smart wallet using provided signing key."
    );

    
    _tryApprovalViaMetaTransaction(
      senderSmartWallet, value, expiration, salt, signatures
    );

    
    bool ok = _DDAI.transferFrom(senderSmartWallet, recipientSmartWallet, value);
    require(ok, "Dharma Dai transfer failed.");
  }
  
  
  function deploySenderWalletAndEnactDDaiTransfer(
    address senderInitialSigningKey, 
    address senderSmartWallet,
    address recipientInitialSigningKey, 
    address recipientSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external onlyOwnerOr(Role.TRANSFERRER) {
    
    _enforceRecipientAndValue(
      recipientSmartWallet, recipientInitialSigningKey, value
    );

    
    _deployNewSmartWalletIfNeeded(senderInitialSigningKey, senderSmartWallet);

    
    _tryApprovalViaMetaTransaction(
      senderSmartWallet, value, expiration, salt, signatures
    );

    
    bool ok = _DDAI.transferFrom(senderSmartWallet, recipientSmartWallet, value);
    require(ok, "Dharma Dai transfer failed.");
  }

  
  function deploySenderKeyRingAndEnactDDaiTransfer(
    address senderInitialKeyRingSigningKey, 
    address senderKeyRing, 
    address senderSmartWallet,
    address recipientInitialSigningKey, 
    address recipientSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external onlyOwnerOr(Role.TRANSFERRER) {
    
    _enforceRecipientAndValue(
      recipientSmartWallet, recipientInitialSigningKey, value
    );

    
    _deployNewKeyRingIfNeeded(senderInitialKeyRingSigningKey, senderKeyRing);

    
    _tryApprovalViaMetaTransaction(
      senderSmartWallet, value, expiration, salt, signatures
    );

    
    bool ok = _DDAI.transferFrom(senderSmartWallet, recipientSmartWallet, value);
    require(ok, "Dharma Dai transfer failed.");
  }

  
  function deploySenderKeyRingAndWalletAndEnactDDaiTransfer(
    address senderInitialKeyRingSigningKey, 
    address senderKeyRing, 
    address senderSmartWallet,
    address recipientInitialSigningKey, 
    address recipientSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external onlyOwnerOr(Role.TRANSFERRER) {
    
    _enforceRecipientAndValue(
      recipientSmartWallet, recipientInitialSigningKey, value
    );

    
    _deployNewKeyRingIfNeeded(senderInitialKeyRingSigningKey, senderKeyRing);

    
    _deployNewSmartWalletIfNeeded(senderKeyRing, senderSmartWallet);

    
    _tryApprovalViaMetaTransaction(
      senderSmartWallet, value, expiration, salt, signatures
    );

    
    bool ok = _DDAI.transferFrom(senderSmartWallet, recipientSmartWallet, value);
    require(ok, "Dharma Dai transfer failed.");
  }

  
  function withdraw(
    ERC20Interface token, address recipient, uint256 amount
  ) external onlyOwner returns (bool success) {
    
    success = token.transfer(recipient, amount);
  }

  
  function callGeneric(
    address payable target, uint256 amount, bytes calldata data
  ) external onlyOwner returns (bool ok, bytes memory returnData) {
    
    (ok, returnData) = target.call.value(amount)(data);
  }

  
  function setLimit(uint256 daiAmount) external onlyOwner {
    
    _limit = daiAmount;
  }

  
  function pause(Role role) external onlyOwnerOr(Role.PAUSER) {
    RoleStatus storage storedRoleStatus = _roles[uint256(role)];
    require(!storedRoleStatus.paused, "Role in question is already paused.");
    storedRoleStatus.paused = true;
    emit RolePaused(role);
  }

  
  function unpause(Role role) external onlyOwner {
    RoleStatus storage storedRoleStatus = _roles[uint256(role)];
    require(storedRoleStatus.paused, "Role in question is already unpaused.");
    storedRoleStatus.paused = false;
    emit RoleUnpaused(role);
  }

  
  function setRole(Role role, address account) external onlyOwner {
    require(account != address(0), "Must supply an account.");
    _setRole(role, account);
  }

  
  function removeRole(Role role) external onlyOwner {
    _setRole(role, address(0));
  }

  
  function isPaused(Role role) external view returns (bool paused) {
    paused = _isPaused(role);
  }

  
  function isRole(Role role) external view returns (bool hasRole) {
    hasRole = _isRole(role);
  }

  
  function getTransferrer() external view returns (address transferrer) {
    transferrer = _roles[uint256(Role.TRANSFERRER)].account;
  }

  
  function getPauser() external view returns (address pauser) {
    pauser = _roles[uint256(Role.PAUSER)].account;
  }

    
  function getLimit() external view returns (
    uint256 daiAmount, uint256 dDaiAmount
  ) {
    daiAmount = _limit;
    dDaiAmount = (daiAmount.mul(1e18)).div(_DDAI.exchangeRateCurrent());   
  }

  
  function isDharmaSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) external pure returns (bool dharmaSmartWallet) {
    dharmaSmartWallet = _isSmartWallet(smartWallet, initialUserSigningKey);
  }

  
  function _setRole(Role role, address account) internal {
    RoleStatus storage storedRoleStatus = _roles[uint256(role)];

    if (account != storedRoleStatus.account) {
      storedRoleStatus.account = account;
      emit RoleModified(role, account);
    }
  }

    function _tryApprovalViaMetaTransaction(
    address senderSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes memory signatures
  ) internal {
    
    (bool ok, bytes memory returnData) = address(_DDAI).call(
      abi.encodeWithSelector(
        _DDAI.modifyAllowanceViaMetaTransaction.selector,
        senderSmartWallet,
        address(this),
        value,
        true, 
        expiration,
        salt,
        signatures
      )
    );

    
    if (!ok) {
      
      (, bool valid) = _DDAI.getMetaTransactionMessageHash(
        _DDAI.modifyAllowanceViaMetaTransaction.selector,
        abi.encode(senderSmartWallet, address(this), value, true),
        expiration,
        salt
      );

      
      if (valid) {
        assembly { revert(add(32, returnData), mload(returnData)) }
      }

      
      uint256 allowance = _DDAI.allowance(senderSmartWallet, address(this));

      
      if (allowance < value) {
        assembly { revert(add(32, returnData), mload(returnData)) }
      }
    }
  }
 
    
  function _deployNewKeyRingIfNeeded(
    address initialSigningKey, address expectedKeyRing
  ) internal returns (address keyRing) {
    
    bytes32 hash;
    assembly { hash := extcodehash(expectedKeyRing) }
    if (hash != _KEY_RING_INSTANCE_RUNTIME_HASH) {
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
    
    bytes32 hash;
    assembly { hash := extcodehash(expectedSmartWallet) }
    if (hash != _SMART_WALLET_INSTANCE_RUNTIME_HASH) {
      require(
        _WALLET_FACTORY.getNextSmartWallet(userSigningKey) == expectedSmartWallet,
        "Smart wallet to be deployed does not match expected smart wallet."
      );
      smartWallet = _WALLET_FACTORY.newSmartWallet(userSigningKey);
    } else {
      
      
      
      
      
      smartWallet = expectedSmartWallet;
    }
  }

  
  function _enforceRecipientAndValue(
    address recipient, address recipientInitialSigningKey, uint256 dDaiAmount
  ) internal view {
    
    require(
      _isSmartWallet(recipient, recipientInitialSigningKey),
      "Could not resolve smart wallet using provided signing key."
    );
    
    
    uint256 exchangeRate = _DDAI.exchangeRateCurrent();

    
    require(exchangeRate != 0, "Could not retrieve dDai exchange rate.");
    
    
    uint256 daiEquivalent = (dDaiAmount.mul(exchangeRate)) / 1e18;
    
    
    require(daiEquivalent < _limit, "Transfer size exceeds the limit.");
  }

  
  function _isRole(Role role) internal view returns (bool hasRole) {
    hasRole = msg.sender == _roles[uint256(role)].account;
  }

  
  function _isPaused(Role role) internal view returns (bool paused) {
    paused = _roles[uint256(role)].paused;
  }

  
  function _isSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) internal pure returns (bool) {
    
    bytes32 initCodeHash = keccak256(
      abi.encodePacked(
        _WALLET_CREATION_CODE_HEADER,
        initialUserSigningKey,
        _WALLET_CREATION_CODE_FOOTER
      )
    );

    
    address target;
    for (uint256 nonce = 0; nonce < 10; nonce++) {
      target = address(          
        uint160(                 
          uint256(               
            keccak256(           
              abi.encodePacked(  
                _CREATE2_HEADER, 
                nonce,           
                initCodeHash     
              )
            )
          )
        )
      );

      
      if (target == smartWallet) {
        return true;
      }

      
      nonce++;
    }

    
    return false;
  }

  
  modifier onlyOwnerOr(Role role) {
    if (!isOwner()) {
      require(_isRole(role), "Caller does not have a required role.");
      require(!_isPaused(role), "Role in question is currently paused.");
    }
    _;
  }
}