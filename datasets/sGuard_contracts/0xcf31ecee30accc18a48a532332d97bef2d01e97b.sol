pragma solidity 0.5.11; 


interface DTokenInterface {
  
  event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
  event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

  
  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);
  function mintViaCToken(uint256 cTokensToSupply) external returns (uint256 dTokensMinted);
  function redeem(uint256 dTokensToBurn) external returns (uint256 underlyingReceived);
  function redeemToCToken(uint256 dTokensToBurn) external returns (uint256 cTokensReceived);
  function redeemUnderlying(uint256 underelyingToReceive) external returns (uint256 dTokensBurned);
  function redeemUnderlyingToCToken(uint256 underlyingToReceive) external returns (uint256 dTokensBurned);
  function transferUnderlying(address recipient, uint256 amount) external returns (bool);
  function transferUnderlyingFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function pullSurplus() external returns (uint256 cTokenSurplus);
  function accrueInterest() external;

  
  function totalSupplyUnderlying() external view returns (uint256);
  function balanceOfUnderlying(address account) external view returns (uint256 underlyingBalance);
  function getSurplus() external view returns (uint256 cTokenSurplus);
  function getSurplusUnderlying() external view returns (uint256 underlyingSurplus);
  function exchangeRateCurrent() external view returns (uint256 dTokenExchangeRate);
  function supplyRatePerBlock() external view returns (uint256 dTokenInterestRate);
  function getSpreadPerBlock() external view returns (uint256 rateSpread);
  function getVersion() external pure returns (uint256 version);
}


interface CTokenInterface {
  function mint(uint256 mintAmount) external returns (uint256 err);
  function redeem(uint256 redeemAmount) external returns (uint256 err);
  function redeemUnderlying(uint256 redeemAmount) external returns (uint256 err);
  function balanceOf(address account) external view returns (uint256 balance);
  function balanceOfUnderlying(address account) external returns (uint256 balance);
  function exchangeRateCurrent() external returns (uint256 exchangeRate);
  function transfer(address recipient, uint256 value) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 value) external returns (bool);
  
  function supplyRatePerBlock() external view returns (uint256 rate);
  function exchangeRateStored() external view returns (uint256 rate);
  function accrualBlockNumber() external view returns (uint256 blockNumber);
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


interface SpreadRegistryInterface {
  function getUSDCSpreadPerBlock() external view returns (uint256 usdcSpreadPerBlock);
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
}



contract DharmaUSDCPrototype1 is ERC20Interface, DTokenInterface {
  using SafeMath for uint256;

  uint256 internal constant _DHARMA_USDC_VERSION = 0;

  string internal constant _NAME = "Dharma USD Coin (Prototype 1)";
  string internal constant _SYMBOL = "dUSDC-p1";
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

  SpreadRegistryInterface internal constant _SPREAD = SpreadRegistryInterface(
    0xA143fD004B3c26f8FAeDeb9224eC03585e63d041
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
    
    require(
      _USDC.transferFrom(msg.sender, address(this), usdcToSupply),
      "USDC transfer failed."
    );

    
    (bool ok, bytes memory data) = address(_CUSDC).call(abi.encodeWithSelector(
      _CUSDC.mint.selector, usdcToSupply
    ));

    _checkCompoundInteraction(_CUSDC.mint.selector, ok, data);

    
    dUSDCMinted = (usdcToSupply.mul(_SCALING_FACTOR)).div(_dUSDCExchangeRate);

    
    _mint(msg.sender, usdcToSupply, dUSDCMinted);
  }

  
  function mintViaCToken(
    uint256 cUSDCToSupply
  ) external accrues returns (uint256 dUSDCMinted) {
    
    (bool ok, bytes memory data) = address(_CUSDC).call(abi.encodeWithSelector(
      _CUSDC.transferFrom.selector, msg.sender, address(this), cUSDCToSupply
    ));

    _checkCompoundInteraction(_CUSDC.transferFrom.selector, ok, data);

    
    uint256 usdcEquivalent = cUSDCToSupply.mul(_cUSDCExchangeRate) / _SCALING_FACTOR;

    
    dUSDCMinted = (usdcEquivalent.mul(_SCALING_FACTOR)).div(_dUSDCExchangeRate);

    
    _mint(msg.sender, usdcEquivalent, dUSDCMinted);
  }

  
  function redeem(
    uint256 dUSDCToBurn
  ) external accrues returns (uint256 usdcReceived) {
    
    usdcReceived = dUSDCToBurn.mul(_dUSDCExchangeRate) / _SCALING_FACTOR;

    
    _burn(msg.sender, usdcReceived, dUSDCToBurn);

    
    (bool ok, bytes memory data) = address(_CUSDC).call(abi.encodeWithSelector(
      _CUSDC.redeemUnderlying.selector, usdcReceived
    ));

    _checkCompoundInteraction(_CUSDC.redeemUnderlying.selector, ok, data);

    
    require(_USDC.transfer(msg.sender, usdcReceived), "USDC transfer failed.");
  }

  
  function redeemToCToken(
    uint256 dUSDCToBurn
  ) external accrues returns (uint256 cUSDCReceived) {
    
    uint256 usdcEquivalent = dUSDCToBurn.mul(_dUSDCExchangeRate) / _SCALING_FACTOR;

    
    cUSDCReceived = (usdcEquivalent.mul(_SCALING_FACTOR)).div(_cUSDCExchangeRate);

    
    _burn(msg.sender, usdcEquivalent, dUSDCToBurn);

    
    (bool ok, bytes memory data) = address(_CUSDC).call(abi.encodeWithSelector(
      _CUSDC.transfer.selector, msg.sender, cUSDCReceived
    ));

    _checkCompoundInteraction(_CUSDC.transfer.selector, ok, data);
  }

  
  function redeemUnderlying(
    uint256 usdcToReceive
  ) external accrues returns (uint256 dUSDCBurned) {
    
    dUSDCBurned = (usdcToReceive.mul(_SCALING_FACTOR)).div(_dUSDCExchangeRate);

    
    _burn(msg.sender, usdcToReceive, dUSDCBurned);

    
    (bool ok, bytes memory data) = address(_CUSDC).call(abi.encodeWithSelector(
      _CUSDC.redeemUnderlying.selector, usdcToReceive
    ));

    _checkCompoundInteraction(_CUSDC.redeemUnderlying.selector, ok, data);

    
    require(_USDC.transfer(msg.sender, usdcToReceive), "USDC transfer failed.");
  }

  
  function redeemUnderlyingToCToken(
    uint256 usdcToReceive
  ) external accrues returns (uint256 dUSDCBurned) {
    
    dUSDCBurned = (usdcToReceive.mul(_SCALING_FACTOR)).div(_dUSDCExchangeRate);

    
    _burn(msg.sender, usdcToReceive, dUSDCBurned);

    
    uint256 cUSDCToReceive = usdcToReceive.mul(_SCALING_FACTOR).div(_cUSDCExchangeRate);

    
    (bool ok, bytes memory data) = address(_CUSDC).call(abi.encodeWithSelector(
      _CUSDC.transfer.selector, msg.sender, cUSDCToReceive
    ));

    _checkCompoundInteraction(_CUSDC.transfer.selector, ok, data);
  }

  
  function pullSurplus() external accrues returns (uint256 cUSDCSurplus) {
    
    (, cUSDCSurplus) = _getSurplus();

    
    (bool ok, bytes memory data) = address(_CUSDC).call(abi.encodeWithSelector(
      _CUSDC.transfer.selector, _VAULT, cUSDCSurplus
    ));

    _checkCompoundInteraction(_CUSDC.transfer.selector, ok, data);
  }

  
  function accrueInterest() external accrues {
    
  }

  
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  
  function transferUnderlying(
    address recipient, uint256 amount
  ) external accrues returns (bool) {
    
    uint256 dUSDCAmount = (amount.mul(_SCALING_FACTOR)).div(_dUSDCExchangeRate);

    _transfer(msg.sender, recipient, dUSDCAmount);
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

  
  function transferUnderlyingFrom(
    address sender, address recipient, uint256 amount
  ) external accrues returns (bool) {
    
    uint256 dUSDCAmount = (amount.mul(_SCALING_FACTOR)).div(_dUSDCExchangeRate);

    _transfer(sender, recipient, dUSDCAmount);
    uint256 allowance = _allowances[sender][msg.sender];
    if (allowance != uint256(-1)) {
      _approve(sender, msg.sender, allowance.sub(dUSDCAmount));
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

  
  function getSurplus() external view returns (uint256 cUSDCSurplus) {
    
    (, cUSDCSurplus) = _getSurplus();
  }

  
  function getSurplusUnderlying() external view returns (uint256 usdcSurplus) {
    
    (usdcSurplus, ) = _getSurplus();
  }

  
  function accrualBlockNumber() external view returns (uint256 blockNumber) {
    blockNumber = _blockLastUpdated;
  }

  
  function exchangeRateCurrent() external view returns (uint256 dUSDCExchangeRate) {
    
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

  
  function totalSupplyUnderlying() external view returns (uint256) {
    (uint256 dUSDCExchangeRate,,) = _getAccruedInterest();

    
    return _totalSupply.mul(dUSDCExchangeRate) / _SCALING_FACTOR;
  }

  
  function balanceOf(address account) external view returns (uint256 dUSDC) {
    dUSDC = _balances[account];
  }

  
  function balanceOfUnderlying(
    address account
  ) external view returns (uint256 usdcBalance) {
    
    (uint256 dUSDCExchangeRate,,) = _getAccruedInterest();

    
    usdcBalance = _balances[account].mul(dUSDCExchangeRate) / _SCALING_FACTOR;
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

  
  function _getAccruedInterest() internal view returns (
    uint256 dUSDCExchangeRate, uint256 cUSDCExchangeRate, bool fullyAccrued
  ) {
    
    uint256 blockDelta = block.number - _blockLastUpdated;
    fullyAccrued = (blockDelta == 0);

    
    if (fullyAccrued) {
      dUSDCExchangeRate = _dUSDCExchangeRate;
      cUSDCExchangeRate = _cUSDCExchangeRate;
    } else {
      
      cUSDCExchangeRate = _getCurrentExchangeRate();
      uint256 cUSDCInterestRate = (
        (cUSDCExchangeRate.mul(_SCALING_FACTOR)).div(_cUSDCExchangeRate)
      );

      
      uint256 spreadInterestRate = _pow(
        _SPREAD.getUSDCSpreadPerBlock().add(_SCALING_FACTOR), blockDelta
      );

      
      dUSDCExchangeRate = spreadInterestRate >= cUSDCInterestRate
        ? _dUSDCExchangeRate
        : _dUSDCExchangeRate.mul(
          _SCALING_FACTOR.add(cUSDCInterestRate - spreadInterestRate)
        ) / _SCALING_FACTOR;
    }
  }

  
  function _getCurrentExchangeRate() internal view returns (uint256 exchangeRate) {
    uint256 storedExchangeRate = _CUSDC.exchangeRateStored();
    uint256 blockDelta = block.number.sub(_CUSDC.accrualBlockNumber());

    if (blockDelta == 0) return storedExchangeRate;

    exchangeRate = blockDelta == 0 ? storedExchangeRate : storedExchangeRate.add(
      storedExchangeRate.mul(
        _CUSDC.supplyRatePerBlock().mul(blockDelta)
      ) / _SCALING_FACTOR
    );
  }

  
  function _getSurplus() internal view returns (
    uint256 usdcSurplus, uint256 cUSDCSurplus
  ) {
    (uint256 dUSDCExchangeRate, uint256 cUSDCExchangeRate,) = _getAccruedInterest();

    
    uint256 dUSDCUnderlying = (
      _totalSupply.mul(dUSDCExchangeRate) / _SCALING_FACTOR
    ).add(1);

    
    usdcSurplus = (
      _CUSDC.balanceOf(address(this)).mul(cUSDCExchangeRate) / _SCALING_FACTOR
    ).sub(dUSDCUnderlying);

    
    cUSDCSurplus = (usdcSurplus.mul(_SCALING_FACTOR)).div(cUSDCExchangeRate);
  }

  
  function _getRatePerBlock() internal view returns (
    uint256 dUSDCSupplyRate, uint256 cUSDCSupplyRate
  ) {
    uint256 spread = _SPREAD.getUSDCSpreadPerBlock();
    cUSDCSupplyRate = _CUSDC.supplyRatePerBlock();
    dUSDCSupplyRate = (spread < cUSDCSupplyRate ? cUSDCSupplyRate - spread : 0);
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

  
  function _checkCompoundInteraction(
    bytes4 functionSelector, bool ok, bytes memory data
  ) internal pure {
    
    if (ok) {
      if (
        functionSelector == _CUSDC.transfer.selector ||
        functionSelector == _CUSDC.transferFrom.selector
      ) {
        require(
          abi.decode(data, (bool)),
          string(
            abi.encodePacked(
              "Compound cUSDC contract returned false on calling ",
              _getFunctionName(functionSelector),
              "."
            )
          )
        );
      } else {
        uint256 compoundError = abi.decode(data, (uint256)); 
        if (compoundError != _COMPOUND_SUCCESS) {
          revert(
            string(
              abi.encodePacked(
                "Compound cUSDC contract returned error code ",
                uint8((compoundError / 10) + 48),
                uint8((compoundError % 10) + 48),
                " on calling ",
                _getFunctionName(functionSelector),
                "."
              )
            )
          );
        }
      }
    } else {
      revert(
        string(
          abi.encodePacked(
            "Compound cUSDC contract reverted while attempting to call ",
            _getFunctionName(functionSelector),
            ": ",
            _decodeRevertReason(data)
          )
        )
      );
    }
  }

  
  function _getFunctionName(
    bytes4 functionSelector
  ) internal pure returns (string memory functionName) {
    if (functionSelector == _CUSDC.mint.selector) {
      functionName = 'mint';
    } else if (functionSelector == _CUSDC.redeemUnderlying.selector) {
      functionName = 'redeemUnderlying';
    } else if (functionSelector == _CUSDC.transferFrom.selector) {
      functionName = 'transferFrom';
    } else if (functionSelector == _CUSDC.transfer.selector) {
      functionName = 'transfer';
    } else {
      functionName = 'an unknown function';
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
      
      revertReason = "(no revert reason)";
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