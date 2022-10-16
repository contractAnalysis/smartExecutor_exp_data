pragma solidity 0.5.11; 


interface CTokenInterface {
  function exchangeRateCurrent() external returns (uint256 exchangeRate);
}


interface ERC20Interface {
    function approve(address spender, uint256 amount) external returns (bool);
}



contract DharmaDaiInitializer {
  event Accrue(uint256 dTokenExchangeRate, uint256 cTokenExchangeRate);

  
  struct AccrualIndex {
    uint112 dTokenExchangeRate;
    uint112 cTokenExchangeRate;
    uint32 block;
  }

  CTokenInterface internal constant _CDAI = CTokenInterface(
    0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 
  );

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F 
  );

  uint256 internal constant _MAX_UINT_112 = 5192296858534827628530496329220095;

  
  AccrualIndex private _accrualIndex;

  
  function initialize() external {
    
    require(
      _DAI.approve(address(_CDAI), uint256(-1)), "Initial cDai approval failed."
    );

    
    uint256 dTokenExchangeRate = 1e28;

    
    uint256 cTokenExchangeRate = _CDAI.exchangeRateCurrent();

    
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