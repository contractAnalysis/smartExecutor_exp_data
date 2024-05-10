pragma solidity 0.5.11; 


interface DharmaReserveManagerV2Interface {
  event RoleModified(Role indexed role, address account);
  event RolePaused(Role indexed role);
  event RoleUnpaused(Role indexed role);

  enum Role {
    DEPOSIT_MANAGER,
    ADJUSTER,
    PAUSER
  }

  struct RoleStatus {
    address account;
    bool paused;
  }

  function finalizeDaiDeposit(
    address smartWallet, address initialUserSigningKey, uint256 daiAmount
  ) external;

  function finalizeDharmaDaiDeposit(
    address smartWallet, address initialUserSigningKey, uint256 dDaiAmount
  ) external;

  function mint(uint256 daiAmount) external returns (uint256 dDaiMinted);
  
  function redeem(uint256 dDaiAmount) external returns (uint256 daiReceived);
  
  function tradeDDaiForUSDC(
    uint256 daiEquivalentAmount,
    uint256 quotedDaiToUSDCExchangeRate
  ) external returns (uint256 usdcReceived);
  
  function tradeUSDCForDDai(
    uint256 usdcAmount,
    uint256 quotedUSDCToDaiExchangeRate
  ) external returns (uint256 dDaiMinted);

  function withdrawUSDC(address recipient, uint256 usdcAmount) external;

  function withdrawDai(address recipient, uint256 daiAmount) external;

  function withdrawDharmaDai(address recipient, uint256 dDaiAmount) external;

  function withdraw(
    ERC20Interface token, address recipient, uint256 amount
  ) external returns (bool success);

  function call(
    address payable target, uint256 amount, bytes calldata data
  ) external returns (bool ok, bytes memory returnData);
  
  function setLimit(uint256 daiAmount) external;

  function setRole(Role role, address account) external;

  function removeRole(Role role) external;

  function pause(Role role) external;

  function unpause(Role role) external;

  function isPaused(Role role) external view returns (bool paused);

  function isRole(Role role) external view returns (bool hasRole);

  function isDharmaSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) external view returns (bool dharmaSmartWallet);

  function getDepositManager() external view returns (address operator);

  function getAdjuster() external view returns (address recoverer);

  function getPauser() external view returns (address pauser);
  
  function getReserves() external view returns (
    uint256 dai, uint256 dDai, uint256 dDaiUnderlying
  );
  
  function getLimit() external view returns (
    uint256 daiAmount, uint256 dDaiAmount
  );
}

interface ERC20Interface {
  function balanceOf(address) external view returns (uint256);
  function approve(address, uint256) external returns (bool);
  function transfer(address, uint256) external returns (bool);
}

interface DTokenInterface {
  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);
  function redeem(uint256 dTokensToBurn) external returns (uint256 underlyingReceived);
  function redeemUnderlying(uint256 underlyingToReceive) external returns (uint256 dTokensBurned);
  function balanceOf(address) external view returns (uint256);
  function balanceOfUnderlying(address) external view returns (uint256);
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function exchangeRateCurrent() external view returns (uint256);
}

interface TradeHelperInterface {
  function tradeUSDCForDDai(uint256 amountUSDC, uint256 quotedExchangeRate) external returns (uint256 dDaiMinted);
  function tradeDDaiForUSDC(uint256 amountDai, uint256 quotedExchangeRate) external returns (uint256 usdcReceived);
  function getExchangeRateAndExpectedDai(uint256 usdc) external view returns (uint256 exchangeRate, uint256 exchangeRateUnderlying, uint256 dai);
  function getExchangeRateAndExpectedUSDC(uint256 dai) external view returns (uint256 exchangeRate, uint256 exchangeRateUnderlying, uint256 usdc);
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



contract DharmaReserveManagerV2 is DharmaReserveManagerV2Interface, TwoStepOwnable {
  using SafeMath for uint256;

  
  mapping(uint256 => RoleStatus) private _roles;
  
  
  uint256 private _limit;

  
  ERC20Interface internal constant _USDC = ERC20Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 
  );

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F 
  );

  DTokenInterface internal constant _DDAI = DTokenInterface(
    0x00000000001876eB1444c986fD502e618c587430
  );
  
  TradeHelperInterface internal constant _TRADE_HELPER = TradeHelperInterface(
    0xb5f23a203F02D2e595BBC96F5a499814CD8cA186
  );

  
  bytes21 internal constant _CREATE2_HEADER = bytes21(
    0xfffc00c80b0000007f73004edb00094cad80626d8d 
  );
  
  
  bytes internal constant _WALLET_CREATION_CODE_HEADER = hex"60806040526040516104423803806104428339818101604052602081101561002657600080fd5b810190808051604051939291908464010000000082111561004657600080fd5b90830190602082018581111561005b57600080fd5b825164010000000081118282018810171561007557600080fd5b82525081516020918201929091019080838360005b838110156100a257818101518382015260200161008a565b50505050905090810190601f1680156100cf5780820380516001836020036101000a031916815260200191505b5060405250505060006100e661019e60201b60201c565b6001600160a01b0316826040518082805190602001908083835b6020831061011f5780518252601f199092019160209182019101610100565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855af49150503d806000811461017f576040519150601f19603f3d011682016040523d82523d6000602084013e610184565b606091505b5050905080610197573d6000803e3d6000fd5b50506102be565b60405160009081906060906e26750c571ce882b17016557279adaa9083818181855afa9150503d80600081146101f0576040519150601f19603f3d011682016040523d82523d6000602084013e6101f5565b606091505b509150915081819061029f576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825283818151815260200191508051906020019080838360005b8381101561026457818101518382015260200161024c565b50505050905090810190601f1680156102915780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b508080602001905160208110156102b557600080fd5b50519392505050565b610175806102cd6000396000f3fe608060405261001461000f610016565b61011c565b005b60405160009081906060906e26750c571ce882b17016557279adaa9083818181855afa9150503d8060008114610068576040519150601f19603f3d011682016040523d82523d6000602084013e61006d565b606091505b50915091508181906100fd5760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b838110156100c25781810151838201526020016100aa565b50505050905090810190601f1680156100ef5780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b5080806020019051602081101561011357600080fd5b50519392505050565b3660008037600080366000845af43d6000803e80801561013b573d6000f35b3d6000fdfea265627a7a7231582020202020202055706772616465426561636f6e50726f7879563120202020202064736f6c634300050b003200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000024c4d66de8000000000000000000000000";
  bytes28 internal constant _WALLET_CREATION_CODE_FOOTER = bytes28(
    0x00000000000000000000000000000000000000000000000000000000
  );

  
  constructor() public {
    
    require(_DAI.approve(address(_DDAI), uint256(-1)));
    
    
    require(_USDC.approve(address(_TRADE_HELPER), uint256(-1)));
  
    
    require(_DDAI.approve(address(_TRADE_HELPER), uint256(-1)));  
    
    
    _limit = 300 * 1e18;
  }

  
  function finalizeDaiDeposit(
    address smartWallet, address initialUserSigningKey, uint256 daiAmount
  ) external onlyOwnerOr(Role.DEPOSIT_MANAGER) {
    
    require(
      _isSmartWallet(smartWallet, initialUserSigningKey),
      "Could not resolve smart wallet using provided signing key."
    );
    
    
    require(daiAmount < _limit, "Transfer size exceeds the limit.");
    
    
    require(_DAI.transfer(smartWallet, daiAmount), "Dai transfer failed.");
  }

  
  function finalizeDharmaDaiDeposit(
    address smartWallet, address initialUserSigningKey, uint256 dDaiAmount
  ) external onlyOwnerOr(Role.DEPOSIT_MANAGER) {
    
    require(
      _isSmartWallet(smartWallet, initialUserSigningKey),
      "Could not resolve smart wallet using provided signing key."
    );
    
    
    uint256 exchangeRate = _DDAI.exchangeRateCurrent();

    
    require(exchangeRate != 0, "Could not retrieve dDai exchange rate.");
    
    
    uint256 daiEquivalent = (dDaiAmount.mul(exchangeRate)) / 1e18;
    
    
    require(daiEquivalent < _limit, "Transfer size exceeds the limit.");

    
    require(_DDAI.transfer(smartWallet, dDaiAmount), "dDai transfer failed.");
  }

  
  function mint(
    uint256 daiAmount
  ) external onlyOwnerOr(Role.ADJUSTER) returns (uint256 dDaiMinted) {
    
    dDaiMinted = _DDAI.mint(daiAmount);
  }

   
  function redeem(
    uint256 dDaiAmount
  ) external onlyOwnerOr(Role.ADJUSTER) returns (uint256 daiReceived) {
    
    daiReceived = _DDAI.redeem(dDaiAmount);
  }
  
   
  function tradeUSDCForDDai(
    uint256 usdcAmount,
    uint256 quotedUSDCToDaiExchangeRate
  ) external onlyOwnerOr(Role.ADJUSTER) returns (uint256 dDaiMinted) {
    dDaiMinted = _TRADE_HELPER.tradeUSDCForDDai(
       usdcAmount, quotedUSDCToDaiExchangeRate
    );
  }

   
  function tradeDDaiForUSDC(
    uint256 daiEquivalentAmount,
    uint256 quotedDaiToUSDCExchangeRate
  ) external onlyOwnerOr(Role.ADJUSTER) returns (uint256 usdcReceived) {
    usdcReceived = _TRADE_HELPER.tradeDDaiForUSDC(
       daiEquivalentAmount, quotedDaiToUSDCExchangeRate
    );
  }

  
  function withdrawUSDC(
    address recipient, uint256 usdcAmount
  ) external onlyOwner {
    
    require(_USDC.transfer(recipient, usdcAmount), "USDC transfer failed.");
  }

  
  function withdrawDai(
    address recipient, uint256 daiAmount
  ) external onlyOwner {
    
    require(_DAI.transfer(recipient, daiAmount), "Dai transfer failed.");
  }

  
  function withdrawDharmaDai(
    address recipient, uint256 dDaiAmount
  ) external onlyOwner {
    
    require(_DDAI.transfer(recipient, dDaiAmount), "dDai transfer failed.");
  }

  
  function withdraw(
    ERC20Interface token, address recipient, uint256 amount
  ) external onlyOwner returns (bool success) {
    
    success = token.transfer(recipient, amount);
  }

  
  function call(
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

  
  function isDharmaSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) external view returns (bool dharmaSmartWallet) {
    dharmaSmartWallet = _isSmartWallet(smartWallet, initialUserSigningKey);
  }

  
  function getDepositManager() external view returns (address depositManager) {
    depositManager = _roles[uint256(Role.DEPOSIT_MANAGER)].account;
  }

  
  function getAdjuster() external view returns (address adjuster) {
    adjuster = _roles[uint256(Role.ADJUSTER)].account;
  }

  
  function getPauser() external view returns (address pauser) {
    pauser = _roles[uint256(Role.PAUSER)].account;
  }

   
  function getReserves() external view returns (
    uint256 dai, uint256 dDai, uint256 dDaiUnderlying
  ) {
    dai = _DAI.balanceOf(address(this));
    dDai = _DDAI.balanceOf(address(this));
    dDaiUnderlying = _DDAI.balanceOfUnderlying(address(this));
  }

    
  function getLimit() external view returns (
    uint256 daiAmount, uint256 dDaiAmount
  ) {
    daiAmount = _limit;
    dDaiAmount = (daiAmount.mul(1e18)).div(_DDAI.exchangeRateCurrent());   
  }

  
  function _setRole(Role role, address account) internal {
    RoleStatus storage storedRoleStatus = _roles[uint256(role)];

    if (account != storedRoleStatus.account) {
      storedRoleStatus.account = account;
      emit RoleModified(role, account);
    }
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