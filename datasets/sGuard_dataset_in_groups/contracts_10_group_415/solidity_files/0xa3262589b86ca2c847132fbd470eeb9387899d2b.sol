pragma solidity 0.5.11; 


interface CTokenInterface {
  function exchangeRateCurrent() external returns (uint256 exchangeRate);
}


interface ERC20Interface {
    function approve(address spender, uint256 amount) external returns (bool);
}



contract DharmaUSDCInitializer {
  event Accrue(uint256 dTokenExchangeRate, uint256 cTokenExchangeRate);

  
  struct AccrualIndex {
    uint112 dTokenExchangeRate;
    uint112 cTokenExchangeRate;
    uint32 block;
  }

  CTokenInterface internal constant _CUSDC = CTokenInterface(
    0x39AA39c021dfbaE8faC545936693aC917d5E7563 
  );

  ERC20Interface internal constant _USDC = ERC20Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 
  );

  uint256 internal constant _MAX_UINT_112 = 5192296858534827628530496329220095;

  
  AccrualIndex private _accrualIndex;

  
  function initialize() public {
    
    require(
      _USDC.approve(address(_CUSDC), uint256(-1)),
      "Initial cUSDC approval failed."
    );

    
    uint256 dTokenExchangeRate = 1e16;

    
    uint256 cTokenExchangeRate = _CUSDC.exchangeRateCurrent();

    
    AccrualIndex storage accrualIndex = _accrualIndex;
    accrualIndex.dTokenExchangeRate = uint112(dTokenExchangeRate);
    accrualIndex.cTokenExchangeRate = _safeUint112(cTokenExchangeRate);
    accrualIndex.block = uint32(block.number);
    emit Accrue(dTokenExchangeRate, cTokenExchangeRate);
  }

  
  function _safeUint112(uint256 input) internal pure returns (uint112 output) {
    require(input <= _MAX_UINT_112, "Overflow on conversion to uint112.");
    output = uint112(input);
  }
}