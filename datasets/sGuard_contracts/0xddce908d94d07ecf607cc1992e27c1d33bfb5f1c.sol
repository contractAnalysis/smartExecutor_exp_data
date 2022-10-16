pragma solidity 0.5.11; 


interface DTokenInterface {
  event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
  event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);

  function redeem(uint256 dTokenToBurn) external returns (uint256 underlyingReceived);

  function redeemUnderlying(uint256 underelyingToReceive) external returns (uint256 dTokensBurned);

  function pullSurplus() external returns (uint256 cTokenSurplus);

  function accrueInterest() external;

  function balanceOfUnderlying(address account) external returns (uint256 underlyingBalance);

  function getSurplus() external returns (uint256 cDaiSurplus);

  function exchangeRateCurrent() external returns (uint256 dTokenExchangeRate);

  function supplyRatePerBlock() external view returns (uint256 dTokenInterestRate);

  function getSpreadPerBlock() external view returns (uint256 rateSpread);

  function getVersion() external pure returns (uint256 version);
}


interface CTokenInterface {
  function mint(uint256 mintAmount) external returns (uint256 err);

  function redeem(uint256 redeemAmount) external returns (uint256 err);

  function redeemUnderlying(uint256 redeemAmount) external returns (uint256 err);

  function balanceOf(address account) external returns (uint256 balance);

  function balanceOfUnderlying(address account) external returns (uint256 balance);

  function exchangeRateCurrent() external returns (uint256 exchangeRate);

  function transfer(address recipient, uint256 value) external returns (bool);

  function supplyRatePerBlock() external view returns (uint256 rate);
}


interface ERC20Interface {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}


library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}



contract DharmaUSDCPrototype0 is ERC20Interface, DTokenInterface {
  using SafeMath for uint256;

  uint256 internal constant _DHARMA_USDC_VERSION = 0;

  
  
  uint256 internal constant _RATE_PER_BLOCK = 1000000019025875275;

  string internal constant _NAME = "Dharma USD Coin (Prototype 0)";
  string internal constant _SYMBOL = "dUSDC-p0";
  uint8 internal constant _DECIMALS = 8; 

  uint256 internal constant _SCALING_FACTOR = 1e18;
  uint256 internal constant _HALF_OF_SCALING_FACTOR = 5e17;
  uint256 internal constant _COMPOUND_SUCCESS = 0;

  CTokenInterface internal constant _CUSDC = CTokenInterface(
    0x39AA39c021dfbaE8faC545936693aC917d5E7563 
  );

  ERC20Interface internal constant _USDC = ERC20Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 
  );

  
  address internal constant _VAULT = 0x7e4A8391C728fEd9069B2962699AB416628B19Fa;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;

  
  uint256 private _blockLastUpdated;
  uint256 private _dUSDCExchangeRate;
  uint256 private _cUSDCExchangeRate;

  constructor() public {
    
    require(_USDC.approve(address(_CUSDC), uint256(-1)));

    _blockLastUpdated = block.number;
    _dUSDCExchangeRate = 1e16; 
    _cUSDCExchangeRate = _CUSDC.exchangeRateCurrent();
  }

  
  function mint(
    uint256 usdcToSupply
  ) external accrues returns (uint256 dUSDCMinted) {
    
    dUSDCMinted = usdcToSupply.mul(_SCALING_FACTOR).div(_dUSDCExchangeRate);

    
    require(
      _USDC.transferFrom(msg.sender, address(this), usdcToSupply),
      "USDC transfer failed."
    );

    
    require(_CUSDC.mint(usdcToSupply) == _COMPOUND_SUCCESS, "cUSDC mint failed.");

    
    _mint(msg.sender, usdcToSupply, dUSDCMinted);
  }

  
  function redeem(
    uint256 dUSDCToBurn
  ) external accrues returns (uint256 usdcReceived) {
    
    usdcReceived = dUSDCToBurn.mul(_dUSDCExchangeRate) / _SCALING_FACTOR;

    
    _burn(msg.sender, usdcReceived, dUSDCToBurn);

    
    require(
      _CUSDC.redeemUnderlying(usdcReceived) == _COMPOUND_SUCCESS,
      "cUSDC redeem failed."
    );

    
    require(_USDC.transfer(msg.sender, usdcReceived), "USDC transfer failed.");
  }

  
  function redeemUnderlying(
    uint256 usdcToReceive
  ) external accrues returns (uint256 dUSDCBurned) {
    
    dUSDCBurned = usdcToReceive.mul(_SCALING_FACTOR).div(_dUSDCExchangeRate);

    
    _burn(msg.sender, usdcToReceive, dUSDCBurned);

    
    require(
      _CUSDC.redeemUnderlying(usdcToReceive) == _COMPOUND_SUCCESS,
      "cUSDC redeem failed."
    );

    
    require(_USDC.transfer(msg.sender, usdcToReceive), "USDC transfer failed.");
  }

  
  function pullSurplus() external accrues returns (uint256 cUSDCSurplus) {
    
    cUSDCSurplus = _getSurplus();

    
    require(_CUSDC.transfer(_VAULT, cUSDCSurplus), "cUSDC transfer failed.");
  }

  
  function accrueInterest() external accrues {
    
  }

  
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  
  function approve(address spender, uint256 value) external returns (bool) {
    _approve(msg.sender, spender, value);
    return true;
  }

  
  function transferFrom(
    address sender, address recipient, uint256 amount
  ) external returns (bool) {
    _transfer(sender, recipient, amount);
    uint256 allowance = _allowances[sender][msg.sender];
    if (allowance != uint256(-1)) {
      _approve(sender, msg.sender, allowance.sub(amount));
    }
    return true;
  }

  
  function increaseAllowance(
    address spender, uint256 addedValue
  ) external returns (bool) {
    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].add(addedValue)
    );
    return true;
  }

  
  function decreaseAllowance(
    address spender, uint256 subtractedValue
  ) external returns (bool) {
    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue)
    );
    return true;
  }

  
  function balanceOfUnderlying(
    address account
  ) external returns (uint256 usdcBalance) {
    
    (uint256 dUSDCExchangeRate,,) = _getAccruedInterest();

    
    usdcBalance = _balances[account].mul(dUSDCExchangeRate) / _SCALING_FACTOR;
  }

  
  function getSurplus() external accrues returns (uint256 cUSDCSurplus) {
    
    cUSDCSurplus = _getSurplus();
  }

  
  function exchangeRateCurrent() external returns (uint256 dUSDCExchangeRate) {
    
    (dUSDCExchangeRate,,) = _getAccruedInterest();
  }

  
  function supplyRatePerBlock() external view returns (uint256 dUSDCInterestRate) {
    (dUSDCInterestRate,) = _getRatePerBlock();
  }

  
  function getSpreadPerBlock() external view returns (uint256 rateSpread) {
    (uint256 dUSDCInterestRate, uint256 cUSDCInterestRate) = _getRatePerBlock();
    rateSpread = cUSDCInterestRate - dUSDCInterestRate;
  }

  
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  
  function balanceOf(address account) external view returns (uint256 dUSDC) {
    dUSDC = _balances[account];
  }

  
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function name() external pure returns (string memory) {
    return _NAME;
  }

  
  function symbol() external pure returns (string memory) {
    return _SYMBOL;
  }

  
  function decimals() external pure returns (uint8) {
    return _DECIMALS;
  }

  
  function getVersion() external pure returns (uint256 version) {
    version = _DHARMA_USDC_VERSION;
  }

  
  function _mint(address account, uint256 exchanged, uint256 amount) internal {
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);

    emit Mint(account, exchanged, amount);
    emit Transfer(address(0), account, amount);
  }

  
  function _burn(address account, uint256 exchanged, uint256 amount) internal {
    uint256 balancePriorToBurn = _balances[account];
    require(
      balancePriorToBurn >= amount, "Supplied amount exceeds account balance."
    );

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = balancePriorToBurn - amount; 

    emit Transfer(account, address(0), amount);
    emit Redeem(account, exchanged, amount);
  }

  
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  
  function _approve(address owner, address spender, uint256 value) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  
  function _getAccruedInterest() internal  returns (
    uint256 dUSDCExchangeRate, uint256 cUSDCExchangeRate, bool fullyAccrued
  ) {
    
    uint256 blocksToAccrueInterest = block.number - _blockLastUpdated;
    fullyAccrued = (blocksToAccrueInterest == 0);

    
    if (fullyAccrued) {
      dUSDCExchangeRate = _dUSDCExchangeRate;
      cUSDCExchangeRate = _cUSDCExchangeRate;
    } else {
      
      uint256 defaultInterest = _pow(_RATE_PER_BLOCK, blocksToAccrueInterest);

      
      cUSDCExchangeRate = _CUSDC.exchangeRateCurrent();

      
      uint256 cUSDCInterest = (
        cUSDCExchangeRate.mul(_SCALING_FACTOR).div(_cUSDCExchangeRate)
      );

      
      dUSDCExchangeRate = _dUSDCExchangeRate.mul(
        defaultInterest > cUSDCInterest ? cUSDCInterest : defaultInterest
      ) / _SCALING_FACTOR;
    }
  }

  
  function _getSurplus() internal  returns (uint256 cUSDCSurplus) {
    
    uint256 dUSDCUnderlying = (
      _totalSupply.mul(_dUSDCExchangeRate) / _SCALING_FACTOR
    ).add(1);

    
    uint256 usdcSurplus = (
      _CUSDC.balanceOfUnderlying(address(this)).sub(dUSDCUnderlying)
    );

    
    cUSDCSurplus = usdcSurplus.mul(_SCALING_FACTOR).div(_cUSDCExchangeRate);
  }

  
  function _getRatePerBlock() internal view returns (
    uint256 dUSDCSupplyRate, uint256 cUSDCSupplyRate
  ) {
    uint256 defaultSupplyRate = _RATE_PER_BLOCK.sub(_SCALING_FACTOR);
    cUSDCSupplyRate = _CUSDC.supplyRatePerBlock(); 
    dUSDCSupplyRate = (
      defaultSupplyRate < cUSDCSupplyRate ? defaultSupplyRate : cUSDCSupplyRate
    );
  }

  
  function _pow(uint256 floatIn, uint256 power) internal pure returns (uint256 floatOut) {
    floatOut = power % 2 != 0 ? floatIn : _SCALING_FACTOR;

    for (power /= 2; power != 0; power /= 2) {
      floatIn = (floatIn.mul(floatIn)).add(_HALF_OF_SCALING_FACTOR) / _SCALING_FACTOR;

      if (power % 2 != 0) {
        floatOut = (floatIn.mul(floatOut)).add(_HALF_OF_SCALING_FACTOR) / _SCALING_FACTOR;
      }
    }
  }

  
  modifier accrues() {
    (
      uint256 dUSDCExchangeRate, uint256 cUSDCExchangeRate, bool fullyAccrued
    ) = _getAccruedInterest();

    if (!fullyAccrued) {
      
      _blockLastUpdated = block.number;
      _dUSDCExchangeRate = dUSDCExchangeRate;
      _cUSDCExchangeRate = cUSDCExchangeRate;
    }

    _;
  }
}