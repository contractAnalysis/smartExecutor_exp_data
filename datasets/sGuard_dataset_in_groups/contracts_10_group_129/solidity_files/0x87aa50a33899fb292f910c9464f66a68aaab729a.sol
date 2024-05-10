pragma solidity 0.5.11; 



interface DTokenInterface {
  
  event Mint(address minter, uint256 mintAmount, uint256 mintDTokens);
  event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemDTokens);
  event Accrue(uint256 dTokenExchangeRate, uint256 cTokenExchangeRate);
  event CollectSurplus(uint256 surplusAmount, uint256 surplusCTokens);

  
  struct AccrualIndex {
    uint112 dTokenExchangeRate;
    uint112 cTokenExchangeRate;
    uint32 block;
  }

  
  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);
  function redeem(uint256 dTokensToBurn) external returns (uint256 underlyingReceived);
  function redeemUnderlying(uint256 underelyingToReceive) external returns (uint256 dTokensBurned);
  function pullSurplus() external returns (uint256 cTokenSurplus);

  
  function mintViaCToken(uint256 cTokensToSupply) external returns (uint256 dTokensMinted);
  function redeemToCToken(uint256 dTokensToBurn) external returns (uint256 cTokensReceived);
  function redeemUnderlyingToCToken(uint256 underlyingToReceive) external returns (uint256 dTokensBurned);
  function accrueInterest() external;
  function transferUnderlying(
    address recipient, uint256 underlyingEquivalentAmount
  ) external returns (bool success);
  function transferUnderlyingFrom(
    address sender, address recipient, uint256 underlyingEquivalentAmount
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

  
  function getMetaTransactionMessageHash(
    bytes4 functionSelector, bytes calldata arguments, uint256 expiration, bytes32 salt
  ) external view returns (bytes32 digest, bool valid);
  function totalSupplyUnderlying() external view returns (uint256);
  function balanceOfUnderlying(address account) external view returns (uint256 underlyingBalance);
  function exchangeRateCurrent() external view returns (uint256 dTokenExchangeRate);
  function supplyRatePerBlock() external view returns (uint256 dTokenInterestRate);
  function accrualBlockNumber() external view returns (uint256 blockNumber);
  function getSurplus() external view returns (uint256 cTokenSurplus);
  function getSurplusUnderlying() external view returns (uint256 underlyingSurplus);
  function getSpreadPerBlock() external view returns (uint256 rateSpread);
  function getVersion() external pure returns (uint256 version);
  function getCToken() external pure returns (address cToken);
  function getUnderlying() external pure returns (address underlying);
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


interface ERC1271Interface {
  function isValidSignature(
    bytes calldata data, bytes calldata signature
  ) external view returns (bytes4 magicValue);
}


interface CTokenInterface {
  function mint(uint256 mintAmount) external returns (uint256 err);
  function redeem(uint256 redeemAmount) external returns (uint256 err);
  function redeemUnderlying(uint256 redeemAmount) external returns (uint256 err);
  function accrueInterest() external returns (uint256 err);
  function transfer(address recipient, uint256 value) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 value) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOfUnderlying(address account) external returns (uint256 balance);
  function exchangeRateCurrent() external returns (uint256 exchangeRate);

  function getCash() external view returns (uint256);
  function totalSupply() external view returns (uint256 supply);
  function totalBorrows() external view returns (uint256 borrows);
  function totalReserves() external view returns (uint256 reserves);
  function interestRateModel() external view returns (address model);
  function reserveFactorMantissa() external view returns (uint256 factor);
  function supplyRatePerBlock() external view returns (uint256 rate);
  function exchangeRateStored() external view returns (uint256 rate);
  function accrualBlockNumber() external view returns (uint256 blockNumber);
  function balanceOf(address account) external view returns (uint256 balance);
  function allowance(address owner, address spender) external view returns (uint256);
}


interface CUSDCInterestRateModelInterface {
  function getBorrowRate(
    uint256 cash, uint256 borrows, uint256 reserves
  ) external view returns (uint256 err, uint256 borrowRate);
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
        if (a == 0) return 0;
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



contract DharmaTokenOverrides {
  
  function _getCurrentCTokenRates() internal view returns (
    uint256 exchangeRate, uint256 supplyRate
  );

  
  function _getUnderlyingName() internal pure returns (string memory underlyingName);

  
  function _getUnderlying() internal pure returns (address underlying);

  
  function _getCTokenSymbol() internal pure returns (string memory cTokenSymbol);

  
  function _getCToken() internal pure returns (address cToken);

  
  function _getDTokenName() internal pure returns (string memory dTokenName);

  
  function _getDTokenSymbol() internal pure returns (string memory dTokenSymbol);

  
  function _getVault() internal pure returns (address vault);
}



contract DharmaTokenHelpers is DharmaTokenOverrides {
  using SafeMath for uint256;

  uint8 internal constant _DECIMALS = 8; 
  uint256 internal constant _SCALING_FACTOR = 1e18;
  uint256 internal constant _SCALING_FACTOR_MINUS_ONE = 999999999999999999;
  uint256 internal constant _HALF_OF_SCALING_FACTOR = 5e17;
  uint256 internal constant _COMPOUND_SUCCESS = 0;
  uint256 internal constant _MAX_UINT_112 = 5192296858534827628530496329220095;
  
  uint256 internal constant _MAX_UNMALLEABLE_S = (
    0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
  );
  

  
  function _checkCompoundInteraction(
    bytes4 functionSelector, bool ok, bytes memory data
  ) internal pure {
    CTokenInterface cToken;
    if (ok) {
      if (
        functionSelector == cToken.transfer.selector ||
        functionSelector == cToken.transferFrom.selector
      ) {
        require(
          abi.decode(data, (bool)), string(
            abi.encodePacked(
              "Compound ",
              _getCTokenSymbol(),
              " contract returned false on calling ",
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
                "Compound ",
                _getCTokenSymbol(),
                " contract returned error code ",
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
            "Compound ",
            _getCTokenSymbol(),
            " contract reverted while attempting to call ",
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
    CTokenInterface cToken;
    if (functionSelector == cToken.mint.selector) {
      functionName = "mint";
    } else if (functionSelector == cToken.redeem.selector) {
      functionName = "redeem";
    } else if (functionSelector == cToken.redeemUnderlying.selector) {
      functionName = "redeemUnderlying";
    } else if (functionSelector == cToken.transferFrom.selector) {
      functionName = "transferFrom";
    } else if (functionSelector == cToken.transfer.selector) {
      functionName = "transfer";
    } else if (functionSelector == cToken.accrueInterest.selector) {
      functionName = "accrueInterest";
    } else {
      functionName = "an unknown function";
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

  
  function _getTransferFailureMessage() internal pure returns (
    string memory message
  ) {
    message = string(
      abi.encodePacked(_getUnderlyingName(), " transfer failed.")
    );
  }

  
  function _safeUint112(uint256 input) internal pure returns (uint112 output) {
    require(input <= _MAX_UINT_112, "Overflow on conversion to uint112.");
    output = uint112(input);
  }

  
  function _fromUnderlying(
    uint256 underlying, uint256 exchangeRate, bool roundUp
  ) internal pure returns (uint256 amount) {
    if (roundUp) {
      amount = (
        (underlying.mul(_SCALING_FACTOR)).add(exchangeRate.sub(1))
      ).div(exchangeRate);
    } else {
      amount = (underlying.mul(_SCALING_FACTOR)).div(exchangeRate);
    }
  }

  
  function _toUnderlying(
    uint256 amount, uint256 exchangeRate, bool roundUp
  ) internal pure returns (uint256 underlying) {
    if (roundUp) {
      underlying = (
        (amount.mul(exchangeRate).add(_SCALING_FACTOR_MINUS_ONE)
      ) / _SCALING_FACTOR);
    } else {
      underlying = amount.mul(exchangeRate) / _SCALING_FACTOR;
    }
  }

  
  function _fromUnderlyingAndBack(
    uint256 underlying, uint256 exchangeRate, bool roundUpOne, bool roundUpTwo
  ) internal pure returns (uint256 amount, uint256 adjustedUnderlying) {
    amount = _fromUnderlying(underlying, exchangeRate, roundUpOne);
    adjustedUnderlying = _toUnderlying(amount, exchangeRate, roundUpTwo);
  }
}



contract DharmaTokenV0 is ERC20Interface, DTokenInterface, DharmaTokenHelpers {
  
  uint256 private constant _DTOKEN_VERSION = 0;

  
  AccrualIndex private _accrualIndex;

  
  uint256 private _totalSupply;

  
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  
  mapping (bytes32 => bool) private _executedMetaTxs;

  
  function mint(uint256) external returns (uint256) {
    
    revert("Minting is paused in V0.");
  }

  
  function mintViaCToken(uint256) external returns (uint256) {
    
    revert("Minting is paused in V0.");
  }

  
  function redeem(
    uint256 dTokensToBurn
  ) external returns (uint256 underlyingReceived) {
    
    ERC20Interface underlying = ERC20Interface(_getUnderlying());
    CTokenInterface cToken = CTokenInterface(_getCToken());

    
    (uint256 dTokenExchangeRate, uint256 cTokenExchangeRate) = _accrue(true);

    
    uint256 underlyingEquivalent = _toUnderlying(
      dTokensToBurn, dTokenExchangeRate, false
    );

    
    uint256 cTokenEquivalent;
    (cTokenEquivalent, underlyingReceived) = _fromUnderlyingAndBack(
      underlyingEquivalent, cTokenExchangeRate, false, false
    );

    
    _burn(msg.sender, underlyingReceived, dTokensToBurn);

    
    (bool ok, bytes memory data) = address(cToken).call(abi.encodeWithSelector(
      cToken.redeem.selector, cTokenEquivalent
    ));
    _checkCompoundInteraction(cToken.redeem.selector, ok, data);

    
    require(
      underlying.transfer(msg.sender, underlyingReceived),
      _getTransferFailureMessage()
    );
  }

  
  function redeemToCToken(
    uint256 dTokensToBurn
  ) external returns (uint256 cTokensReceived) {
    
    CTokenInterface cToken = CTokenInterface(_getCToken());

    
    (uint256 dTokenExchangeRate, uint256 cTokenExchangeRate) = _accrue(true);

    
    uint256 underlyingEquivalent = _toUnderlying(
      dTokensToBurn, dTokenExchangeRate, false
    );

    
    cTokensReceived = _fromUnderlying(
      underlyingEquivalent, cTokenExchangeRate, false
    );

    
    _burn(msg.sender, underlyingEquivalent, dTokensToBurn);

    
    (bool ok, bytes memory data) = address(cToken).call(abi.encodeWithSelector(
      cToken.transfer.selector, msg.sender, cTokensReceived
    ));
    _checkCompoundInteraction(cToken.transfer.selector, ok, data);
  }

  
  function redeemUnderlying(
    uint256 underlyingToReceive
  ) external returns (uint256 dTokensBurned) {
    
    ERC20Interface underlying = ERC20Interface(_getUnderlying());
    CTokenInterface cToken = CTokenInterface(_getCToken());

    
    (bool ok, bytes memory data) = address(cToken).call(abi.encodeWithSelector(
      cToken.redeemUnderlying.selector, underlyingToReceive
    ));
    _checkCompoundInteraction(cToken.redeemUnderlying.selector, ok, data);

    
    (uint256 dTokenExchangeRate, uint256 cTokenExchangeRate) = _accrue(false);

    
    (, uint256 underlyingEquivalent) = _fromUnderlyingAndBack(
      underlyingToReceive, cTokenExchangeRate, true, true 
    );

    
    dTokensBurned = _fromUnderlying(
      underlyingEquivalent, dTokenExchangeRate, true
    );

    
    _burn(msg.sender, underlyingToReceive, dTokensBurned);

    
    require(
      underlying.transfer(msg.sender, underlyingToReceive),
      _getTransferFailureMessage()
    );
  }

  
  function redeemUnderlyingToCToken(
    uint256 underlyingToReceive
  ) external returns (uint256 dTokensBurned) {
    
    CTokenInterface cToken = CTokenInterface(_getCToken());

    
    (uint256 dTokenExchangeRate, uint256 cTokenExchangeRate) = _accrue(true);

    
    (
      uint256 cTokensToReceive, uint256 underlyingEquivalent
    ) = _fromUnderlyingAndBack(
      underlyingToReceive, cTokenExchangeRate, false, true 
    );

    
    dTokensBurned = _fromUnderlying(
      underlyingEquivalent, dTokenExchangeRate, true
    );

    
    _burn(msg.sender, underlyingToReceive, dTokensBurned);

    
    (bool ok, bytes memory data) = address(cToken).call(abi.encodeWithSelector(
      cToken.transfer.selector, msg.sender, cTokensToReceive
    ));
    _checkCompoundInteraction(cToken.transfer.selector, ok, data);
  }

  
  function pullSurplus() external returns (uint256) {
    
    revert("Pulling surplus is paused in V0.");
  }

  
  function accrueInterest() external {
    
    _accrue(true);
  }

  
  function transfer(
    address recipient, uint256 amount
  ) external returns (bool success) {
    _transfer(msg.sender, recipient, amount);
    success = true;
  }

  
  function transferUnderlying(
    address recipient, uint256 underlyingEquivalentAmount
  ) external returns (bool success) {
    
    (uint256 dTokenExchangeRate, ) = _accrue(true);

    
    uint256 dTokenAmount = _fromUnderlying(
      underlyingEquivalentAmount, dTokenExchangeRate, true
    );

    
    _transfer(msg.sender, recipient, dTokenAmount);
    success = true;
  }

  
  function approve(
    address spender, uint256 value
  ) external returns (bool success) {
    _approve(msg.sender, spender, value);
    success = true;
  }

  
  function transferFrom(
    address sender, address recipient, uint256 amount
  ) external returns (bool success) {
    _transferFrom(sender, recipient, amount);
    success = true;
  }

  
  function transferUnderlyingFrom(
    address sender, address recipient, uint256 underlyingEquivalentAmount
  ) external returns (bool success) {
    
    (uint256 dTokenExchangeRate, ) = _accrue(true);

    
    uint256 dTokenAmount = _fromUnderlying(
      underlyingEquivalentAmount, dTokenExchangeRate, true
    );

    
    _transferFrom(sender, recipient, dTokenAmount);
    success = true;
  }

  
  function increaseAllowance(
    address spender, uint256 addedValue
  ) external returns (bool success) {
    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].add(addedValue)
    );
    success = true;
  }

  
  function decreaseAllowance(
    address spender, uint256 subtractedValue
  ) external returns (bool success) {
    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue)
    );
    success = true;
  }

  
  function modifyAllowanceViaMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external returns (bool success) {
    require(expiration == 0 || now <= expiration, "Meta-transaction expired.");

    
    bytes memory context = abi.encodePacked(
      address(this),
      
      this.modifyAllowanceViaMetaTransaction.selector,
      expiration,
      salt,
      abi.encode(owner, spender, value, increase)
    );
    bytes32 messageHash = keccak256(context);

    
    require(!_executedMetaTxs[messageHash], "Meta-transaction already used.");
    _executedMetaTxs[messageHash] = true;

    
    bytes32 digest = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
    );

    
    uint256 currentAllowance = _allowances[owner][spender];
    uint256 newAllowance = (
      increase ? currentAllowance.add(value) : currentAllowance.sub(value)
    );

    
    if (_isContract(owner)) {
      
      bytes memory data = abi.encode(digest, context);
      bytes4 magic = ERC1271Interface(owner).isValidSignature(data, signatures);
      require(magic == bytes4(0x20c13b0b), "Invalid signatures.");
    } else {
      
      _verifyRecover(owner, digest, signatures);
    }

    
    _approve(owner, spender, newAllowance);
    success = true;
  }

  
  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view returns (bytes32 messageHash, bool valid) {
    
    messageHash = keccak256(
      abi.encodePacked(
        address(this), functionSelector, expiration, salt, arguments
      )
    );

    
    valid = (
      !_executedMetaTxs[messageHash] && (expiration == 0 || now <= expiration)
    );
  }

  
  function totalSupply() external view returns (uint256 dTokenTotalSupply) {
    dTokenTotalSupply = _totalSupply;
  }

  
  function totalSupplyUnderlying() external view returns (
    uint256 dTokenTotalSupplyInUnderlying
  ) {
    (uint256 dTokenExchangeRate, ,) = _getExchangeRates(true);

    
    dTokenTotalSupplyInUnderlying = _toUnderlying(
      _totalSupply, dTokenExchangeRate, false
    );
  }

  
  function balanceOf(address account) external view returns (uint256 dTokens) {
    dTokens = _balances[account];
  }

  
  function balanceOfUnderlying(
    address account
  ) external view returns (uint256 underlyingBalance) {
    
    (uint256 dTokenExchangeRate, ,) = _getExchangeRates(true);

    
    underlyingBalance = _toUnderlying(
      _balances[account], dTokenExchangeRate, false
    );
  }

  
  function allowance(
    address owner, address spender
  ) external view returns (uint256 dTokenAllowance) {
    dTokenAllowance = _allowances[owner][spender];
  }

  
  function exchangeRateCurrent() external view returns (
    uint256 dTokenExchangeRate
  ) {
    
    (dTokenExchangeRate, ,) = _getExchangeRates(true);
  }

  
  function supplyRatePerBlock() external view returns (
    uint256 dTokenInterestRate
  ) {
    (dTokenInterestRate,) = _getRatePerBlock();
  }

  
  function accrualBlockNumber() external view returns (uint256 blockNumber) {
    blockNumber = _accrualIndex.block;
  }

  
  function getSurplus() external view returns (uint256 cTokenSurplus) {
    
    (, cTokenSurplus) = _getSurplus();
  }

  
  function getSurplusUnderlying() external view returns (
    uint256 underlyingSurplus
  ) {
    
    (underlyingSurplus, ) = _getSurplus();
  }

  
  function getSpreadPerBlock() external view returns (uint256 rateSpread) {
    (
      uint256 dTokenInterestRate, uint256 cTokenInterestRate
    ) = _getRatePerBlock();
    rateSpread = cTokenInterestRate.sub(dTokenInterestRate);
  }

  
  function name() external pure returns (string memory dTokenName) {
    dTokenName = _getDTokenName();
  }

  
  function symbol() external pure returns (string memory dTokenSymbol) {
    dTokenSymbol = _getDTokenSymbol();
  }

  
  function decimals() external pure returns (uint8 dTokenDecimals) {
    dTokenDecimals = _DECIMALS;
  }

  
  function getVersion() external pure returns (uint256 version) {
    version = _DTOKEN_VERSION;
  }

  
  function getCToken() external pure returns (address cToken) {
    cToken = _getCToken();
  }

  
  function getUnderlying() external pure returns (address underlying) {
    underlying = _getUnderlying();
  }

  
  function _accrue(bool compute) private returns (
    uint256 dTokenExchangeRate, uint256 cTokenExchangeRate
  ) {
    bool alreadyAccrued;
    (
      dTokenExchangeRate, cTokenExchangeRate, alreadyAccrued
    ) = _getExchangeRates(compute);

    if (!alreadyAccrued) {
      
      AccrualIndex storage accrualIndex = _accrualIndex;
      accrualIndex.dTokenExchangeRate = _safeUint112(dTokenExchangeRate);
      accrualIndex.cTokenExchangeRate = _safeUint112(cTokenExchangeRate);
      accrualIndex.block = uint32(block.number);
      emit Accrue(dTokenExchangeRate, cTokenExchangeRate);
    }
  }

  
  function _burn(address account, uint256 exchanged, uint256 amount) private {
    require(
      exchanged > 0 && amount > 0, "Redeem failed: insufficient funds supplied."
    );

    uint256 balancePriorToBurn = _balances[account];
    require(
      balancePriorToBurn >= amount, "Supplied amount exceeds account balance."
    );

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = balancePriorToBurn - amount; 

    emit Transfer(account, address(0), amount);
    emit Redeem(account, exchanged, amount);
  }

  
  function _transfer(
    address sender, address recipient, uint256 amount
  ) private {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "Insufficient funds.");

    _balances[sender] = senderBalance - amount; 
    _balances[recipient] = _balances[recipient].add(amount);

    emit Transfer(sender, recipient, amount);
  }

  
  function _transferFrom(
    address sender, address recipient, uint256 amount
  ) private {
    _transfer(sender, recipient, amount);
    uint256 callerAllowance = _allowances[sender][msg.sender];
    if (callerAllowance != uint256(-1)) {
      require(callerAllowance >= amount, "Insufficient allowance.");
      _approve(sender, msg.sender, callerAllowance - amount); 
    }
  }

  
  function _approve(address owner, address spender, uint256 value) private {
    require(owner != address(0), "ERC20: approve for the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  
  function _getExchangeRates(bool compute) private view returns (
    uint256 dTokenExchangeRate, uint256 cTokenExchangeRate, bool fullyAccrued
  ) {
    
    AccrualIndex memory accrualIndex = _accrualIndex;
    uint256 storedDTokenExchangeRate = uint256(accrualIndex.dTokenExchangeRate);
    uint256 storedCTokenExchangeRate = uint256(accrualIndex.cTokenExchangeRate);
    uint256 accrualBlock = uint256(accrualIndex.block);

    
    fullyAccrued = (accrualBlock == block.number);
    if (fullyAccrued) {
      dTokenExchangeRate = storedDTokenExchangeRate;
      cTokenExchangeRate = storedCTokenExchangeRate;
    } else {
      
      if (compute) {
        
        (cTokenExchangeRate,) = _getCurrentCTokenRates();
      } else {
        
        cTokenExchangeRate = CTokenInterface(_getCToken()).exchangeRateStored();
      }

      
      uint256 cTokenInterest = (
        (cTokenExchangeRate.mul(_SCALING_FACTOR)).div(storedCTokenExchangeRate)
      ).sub(_SCALING_FACTOR);

      
      dTokenExchangeRate = storedDTokenExchangeRate.mul(
        _SCALING_FACTOR.add(cTokenInterest.mul(9) / 10)
      ) / _SCALING_FACTOR;
    }
  }

  
  function _getSurplus() private view returns (
    uint256 underlyingSurplus, uint256 cTokenSurplus
  ) {
    
    CTokenInterface cToken = CTokenInterface(_getCToken());

    (
      uint256 dTokenExchangeRate, uint256 cTokenExchangeRate,
    ) = _getExchangeRates(true);

    
    uint256 dTokenUnderlying = _toUnderlying(
      _totalSupply, dTokenExchangeRate, true
    );

    
    uint256 cTokenUnderlying = _toUnderlying(
      cToken.balanceOf(address(this)), cTokenExchangeRate, false
    );

    
    underlyingSurplus = cTokenUnderlying > dTokenUnderlying
      ? cTokenUnderlying - dTokenUnderlying 
      : 0;

    
    cTokenSurplus = underlyingSurplus == 0
      ? 0
      : _fromUnderlying(underlyingSurplus, cTokenExchangeRate, false);
  }

  
  function _getRatePerBlock() private view returns (
    uint256 dTokenSupplyRate, uint256 cTokenSupplyRate
  ) {
    (, cTokenSupplyRate) = _getCurrentCTokenRates();
    dTokenSupplyRate = cTokenSupplyRate.mul(9) / 10;
  }

  
  function _isContract(address account) private view returns (bool isContract) {
    uint256 size;
    assembly { size := extcodesize(account) }
    isContract = size > 0;
  }

  
  function _verifyRecover(
    address account, bytes32 digest, bytes memory signature
  ) private pure {
    
    require(
      signature.length == 65,
      "Must supply a single 65-byte signature when owner is not a contract."
    );

    
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    require(
      uint256(s) <= _MAX_UNMALLEABLE_S,
      "Signature `s` value cannot be potentially malleable."
    );

    require(v == 27 || v == 28, "Signature `v` value not permitted.");

    require(account == ecrecover(digest, v, r, s), "Invalid signature.");
  }
}



contract DharmaUSDCImplementationV0 is DharmaTokenV0 {
  string internal constant _NAME = "Dharma USD Coin";
  string internal constant _SYMBOL = "dUSDC";
  string internal constant _UNDERLYING_NAME = "USD Coin";
  string internal constant _CTOKEN_SYMBOL = "cUSDC";

  CTokenInterface internal constant _CUSDC = CTokenInterface(
    0x39AA39c021dfbaE8faC545936693aC917d5E7563 
  );

  ERC20Interface internal constant _USDC = ERC20Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 
  );

  address internal constant _VAULT = 0x7e4A8391C728fEd9069B2962699AB416628B19Fa;

  uint256 internal constant _SCALING_FACTOR_SQUARED = 1e36;

  
  function _getCurrentCTokenRates() internal view returns (
    uint256 exchangeRate, uint256 supplyRate
  ) {
    
    uint256 blockDelta = block.number.sub(_CUSDC.accrualBlockNumber());

    
    if (blockDelta == 0) return (
      _CUSDC.exchangeRateStored(), _CUSDC.supplyRatePerBlock()
    );

    
    uint256 cash = _USDC.balanceOf(address(_CUSDC));

    
    CUSDCInterestRateModelInterface interestRateModel = (
      CUSDCInterestRateModelInterface(_CUSDC.interestRateModel())
    );

    
    uint256 borrows = _CUSDC.totalBorrows();
    uint256 reserves = _CUSDC.totalReserves();
    uint256 reserveFactor = _CUSDC.reserveFactorMantissa();

    
    (uint256 err, uint256 borrowRate) = interestRateModel.getBorrowRate(
      cash, borrows, reserves
    );
    require(
      err == _COMPOUND_SUCCESS, "Interest Rate Model borrow rate check failed."
    );

    uint256 interest = borrowRate.mul(blockDelta).mul(borrows) / _SCALING_FACTOR;

    
    borrows = borrows.add(interest);
    reserves = reserves.add(reserveFactor.mul(interest) / _SCALING_FACTOR);

    
    uint256 underlying = (cash.add(borrows)).sub(reserves);

    
    exchangeRate = (underlying.mul(_SCALING_FACTOR)).div(_CUSDC.totalSupply());

    
    uint256 borrowsPer = (
      borrows.mul(_SCALING_FACTOR_SQUARED)
    ).div(underlying);

    
    supplyRate = (
      interest.mul(_SCALING_FACTOR.sub(reserveFactor)).mul(borrowsPer)
    ) / _SCALING_FACTOR_SQUARED;
  }

  
  function _getUnderlyingName() internal pure returns (string memory underlyingName) {
    underlyingName = _UNDERLYING_NAME;
  }

  
  function _getUnderlying() internal pure returns (address underlying) {
    underlying = address(_USDC);
  }

  
  function _getCTokenSymbol() internal pure returns (string memory cTokenSymbol) {
    cTokenSymbol = _CTOKEN_SYMBOL;
  }

  
  function _getCToken() internal pure returns (address cToken) {
    cToken = address(_CUSDC);
  }

  
  function _getDTokenName() internal pure returns (string memory dTokenName) {
    dTokenName = _NAME;
  }

  
  function _getDTokenSymbol() internal pure returns (string memory dTokenSymbol) {
    dTokenSymbol = _SYMBOL;
  }

  
  function _getVault() internal pure returns (address vault) {
    vault = _VAULT;
  }
}