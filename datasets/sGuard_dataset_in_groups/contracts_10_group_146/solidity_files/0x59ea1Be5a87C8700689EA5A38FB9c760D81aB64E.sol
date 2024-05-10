pragma solidity ^0.6.12;


library SafeMath {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;
    

    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    
    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a * b;

        
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    
    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        
        require(b != -1 || a != MIN_INT256);

        
        return a / b;
    }

    
    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    
    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    
    function abs(int256 a)
        internal
        pure
        returns (int256)
    {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}


library UInt256Lib {

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    
    function toInt256Safe(uint256 a)
        internal
        pure
        returns (int256)
    {
        require(a <= MAX_INT256);
        return int256(a);
    }
}


interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

interface IRebased {
    function totalSupply() external view returns (uint256);
    function rebase(uint256 epoch, int256 supplyDelta) external returns (uint256);
}

interface IOracle {
    function getData() external view returns (uint256, bool);
}


contract Ownable {
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  
  constructor() public {
    _owner = msg.sender;
  }

  
  function owner() public view returns(address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract MonetaryPolicy is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 cpi,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    IRebased public rebased;

    
    IOracle public cpiOracle;

    
    IOracle public marketOracle;

    
    uint256 private baseCpi;

    
    
    
    
    uint256 public deviationThreshold;

    
    
    
    uint256 public rebaseLag;

    
    uint256 public minRebaseTimeIntervalSec;

    
    uint256 public lastRebaseTimestampSec;

    
    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

    
    
    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    constructor(uint256 baseCpi_) public {
        deviationThreshold = 5 * 10 ** (DECIMALS-2);

        rebaseLag = 20;
        minRebaseTimeIntervalSec = 12 hours;
        lastRebaseTimestampSec = 0;
        epoch = 0;
        
        baseCpi = baseCpi_;
    }

    
     
    function canRebase() public view returns (bool) {
        
        return (lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);
    }

    
     
    function rebase() external {

        require(canRebase(), "Insufficient time has passed since last rebase");
        lastRebaseTimestampSec = now;

        epoch = epoch.add(1);
        
        (uint256 cpi, uint256 exchangeRate, uint256 targetRate, int256 supplyDelta) = getRebaseValues();

        uint256 supplyAfterRebase = rebased.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        
        emit LogRebase(epoch, exchangeRate, cpi, supplyDelta, now);
    }
    
        
    
    function getRebaseValues() public view returns (uint256, uint256, uint256, int256) {
        uint256 cpi;
        bool cpiValid;
        (cpi, cpiValid) = cpiOracle.getData();
        
        require(cpiValid);

        uint256 targetRate = cpi.mul(10 ** DECIMALS).div(baseCpi);

        uint256 exchangeRate;
        bool rateValid;
        
        (exchangeRate, rateValid) = marketOracle.getData();
        
        require(rateValid);

        if (exchangeRate > MAX_RATE) {
            exchangeRate = MAX_RATE;
        }

        int256 supplyDelta = computeSupplyDelta(exchangeRate, targetRate);

        
        supplyDelta = supplyDelta.div(rebaseLag.toInt256Safe());

        if (supplyDelta > 0 && rebased.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(rebased.totalSupply())).toInt256Safe();
        }

       return (cpi, exchangeRate, targetRate, supplyDelta);
    }


    
    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        internal
        view
        returns (int256)
    {
        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

        
        int256 targetRateSigned = targetRate.toInt256Safe();
        return rebased.totalSupply().toInt256Safe()
            .mul(rate.toInt256Safe().sub(targetRateSigned))
            .div(targetRateSigned);
    }

    
    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        internal
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** DECIMALS);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }
    
    
    function setRebased(IRebased rebased_)
        external
        onlyOwner
    {
        require(rebased == IRebased(0)); 
        rebased = rebased_;    
    }
    
    
    function setCpiOracle(IOracle cpiOracle_)
        external
        onlyOwner
    {
        cpiOracle = cpiOracle_;
    }

    
    function setMarketOracle(IOracle marketOracle_)
        external
        onlyOwner
    {
        marketOracle = marketOracle_;
    }

}