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



contract DharmaDaiPrototype0 is ERC20Interface, DTokenInterface {
  using SafeMath for uint256;

  uint256 internal constant _DHARMA_DAI_VERSION = 0;

  
  
  uint256 internal constant _RATE_PER_BLOCK = 1000000023782344094;

  string internal constant _NAME = "Dharma Dai (Prototype 0)";
  string internal constant _SYMBOL = "dDai-p0";
  uint8 internal constant _DECIMALS = 8; 

  uint256 internal constant _SCALING_FACTOR = 1e18;
  uint256 internal constant _HALF_OF_SCALING_FACTOR = 5e17;
  uint256 internal constant _COMPOUND_SUCCESS = 0;

  CTokenInterface internal constant _CDAI = CTokenInterface(
    0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 
  );

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F 
  );

  
  address internal constant _VAULT = 0x7e4A8391C728fEd9069B2962699AB416628B19Fa;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;

  
  uint256 private _blockLastUpdated;
  uint256 private _dDaiExchangeRate;
  uint256 private _cDaiExchangeRate;

  constructor() public {
    
    require(_DAI.approve(address(_CDAI), uint256(-1)));

    _blockLastUpdated = block.number;
    _dDaiExchangeRate = 1e28; 
    _cDaiExchangeRate = _CDAI.exchangeRateCurrent();
  }

  
  function mint(
    uint256 daiToSupply
  ) external accrues returns (uint256 dDaiMinted) {
    
    dDaiMinted = daiToSupply.mul(_SCALING_FACTOR).div(_dDaiExchangeRate);

    
    require(
      _DAI.transferFrom(msg.sender, address(this), daiToSupply),
      "Dai transfer failed."
    );

    
    require(_CDAI.mint(daiToSupply) == _COMPOUND_SUCCESS, "cDai mint failed.");

    
    _mint(msg.sender, daiToSupply, dDaiMinted);
  }

  
  function redeem(
    uint256 dDaiToBurn
  ) external accrues returns (uint256 daiReceived) {
    
    daiReceived = dDaiToBurn.mul(_dDaiExchangeRate) / _SCALING_FACTOR;

    
    _burn(msg.sender, daiReceived, dDaiToBurn);

    
    require(
      _CDAI.redeemUnderlying(daiReceived) == _COMPOUND_SUCCESS,
      "cDai redeem failed."
    );

    
    require(_DAI.transfer(msg.sender, daiReceived), "Dai transfer failed.");
  }

  
  function redeemUnderlying(
    uint256 daiToReceive
  ) external accrues returns (uint256 dDaiBurned) {
    
    dDaiBurned = daiToReceive.mul(_SCALING_FACTOR).div(_dDaiExchangeRate);

    
    _burn(msg.sender, daiToReceive, dDaiBurned);

    
    require(
      _CDAI.redeemUnderlying(daiToReceive) == _COMPOUND_SUCCESS,
      "cDai redeem failed."
    );

    
    require(_DAI.transfer(msg.sender, daiToReceive), "Dai transfer failed.");
  }

  
  function pullSurplus() external accrues returns (uint256 cDaiSurplus) {
    
    cDaiSurplus = _getSurplus();

    
    require(_CDAI.transfer(_VAULT, cDaiSurplus), "cDai transfer failed.");
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
  ) external returns (uint256 daiBalance) {
    
    (uint256 dDaiExchangeRate,,) = _getAccruedInterest();

    
    daiBalance = _balances[account].mul(dDaiExchangeRate) / _SCALING_FACTOR;
  }

  
  function getSurplus() external accrues returns (uint256 cDaiSurplus) {
    
    cDaiSurplus = _getSurplus();
  }

  
  function exchangeRateCurrent() external returns (uint256 dDaiExchangeRate) {
    
    (dDaiExchangeRate,,) = _getAccruedInterest();
  }

  
  function supplyRatePerBlock() external view returns (uint256 dDaiInterestRate) {
    (dDaiInterestRate,) = _getRatePerBlock();
  }

  
  function getSpreadPerBlock() external view returns (uint256 rateSpread) {
    (uint256 dDaiInterestRate, uint256 cDaiInterestRate) = _getRatePerBlock();
    rateSpread = cDaiInterestRate - dDaiInterestRate;
  }

  
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  
  function balanceOf(address account) external view returns (uint256 dDai) {
    dDai = _balances[account];
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
    version = _DHARMA_DAI_VERSION;
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
    uint256 dDaiExchangeRate, uint256 cDaiExchangeRate, bool fullyAccrued
  ) {
    
    uint256 blocksToAccrueInterest = block.number - _blockLastUpdated;
    fullyAccrued = (blocksToAccrueInterest == 0);

    
    if (fullyAccrued) {
      dDaiExchangeRate = _dDaiExchangeRate;
      cDaiExchangeRate = _cDaiExchangeRate;
    } else {
      
      uint256 defaultInterest = _pow(_RATE_PER_BLOCK, blocksToAccrueInterest);

      
      cDaiExchangeRate = _CDAI.exchangeRateCurrent();

      
      uint256 cDaiInterest = (
        cDaiExchangeRate.mul(_SCALING_FACTOR).div(_cDaiExchangeRate)
      );

      
      dDaiExchangeRate = _dDaiExchangeRate.mul(
        defaultInterest > cDaiInterest ? cDaiInterest : defaultInterest
      ) / _SCALING_FACTOR;
    }
  }

  
  function _getSurplus() internal  returns (uint256 cDaiSurplus) {
    
    uint256 dDaiUnderlying = (
      _totalSupply.mul(_dDaiExchangeRate) / _SCALING_FACTOR
    ).add(1);

    
    uint256 daiSurplus = (
      _CDAI.balanceOfUnderlying(address(this)).sub(dDaiUnderlying)
    );

    
    cDaiSurplus = daiSurplus.mul(_SCALING_FACTOR).div(_cDaiExchangeRate);
  }

  
  function _getRatePerBlock() internal view returns (
    uint256 dDaiSupplyRate, uint256 cDaiSupplyRate
  ) {
    uint256 defaultSupplyRate = _RATE_PER_BLOCK.sub(_SCALING_FACTOR);
    cDaiSupplyRate = _CDAI.supplyRatePerBlock(); 
    dDaiSupplyRate = (
      defaultSupplyRate < cDaiSupplyRate ? defaultSupplyRate : cDaiSupplyRate
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
      uint256 dDaiExchangeRate, uint256 cDaiExchangeRate, bool fullyAccrued
    ) = _getAccruedInterest();

    if (!fullyAccrued) {
      
      _blockLastUpdated = block.number;
      _dDaiExchangeRate = dDaiExchangeRate;
      _cDaiExchangeRate = cDaiExchangeRate;
    }

    _;
  }
}