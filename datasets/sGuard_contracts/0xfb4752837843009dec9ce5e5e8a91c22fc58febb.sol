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

interface IAMPLG {
    function totalSupply() external view returns (uint256);
    function rebaseGold(uint256 epoch, int256 supplyDelta) external returns (uint256);
}

interface IOracle {
    function getData() external view returns (uint256, bool);
}

interface IGoldOracle {
    function getGoldPrice() external view returns (uint256, bool);
    function getMarketPrice() external view returns (uint256, bool);
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


contract AMPLGGoldPolicy is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 goldPrice,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    IAMPLG public amplg;

    
    IGoldOracle public goldOracle;

    
    
    
    
    uint256 public deviationThreshold;

    
    
    
    uint256 public rebaseLag;

    
    uint256 public minRebaseTimeIntervalSec;

    
    uint256 public lastRebaseTimestampSec;

    
    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

    
    
    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    constructor() public {
        deviationThreshold = 5 * 10 ** (DECIMALS-2);

        rebaseLag = 6;
        minRebaseTimeIntervalSec = 12 hours;
        lastRebaseTimestampSec = 0;
        epoch = 0;
    }

    
     
    function canRebase() public view returns (bool) {
        return (lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);
    }

         
    function rebase() external {

        require(canRebase(), "AMPLG Error: Insufficient time has passed since last rebase.");

        require(tx.origin == msg.sender);

        lastRebaseTimestampSec = now;

        epoch = epoch.add(1);
        
        (uint256 curGoldPrice, uint256 marketPrice, int256 targetRate, int256 supplyDelta) = getRebaseValues();

        uint256 supplyAfterRebase = amplg.rebaseGold(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        
        emit LogRebase(epoch, marketPrice, curGoldPrice, supplyDelta, now);
    }
    
       
    function getRebaseValues() public view returns (uint256, uint256, int256, int256) {
        uint256 curGoldPrice;
        bool goldValid;
        (curGoldPrice, goldValid) = goldOracle.getGoldPrice();

        require(goldValid);
        
        uint256 marketPrice;
        bool marketValid;
        (marketPrice, marketValid) = goldOracle.getMarketPrice();
        
        require(marketValid);
        
        int256 goldPriceSigned = curGoldPrice.toInt256Safe();
        int256 marketPriceSigned = marketPrice.toInt256Safe();
        
        int256 rate = marketPriceSigned.sub(goldPriceSigned);
              
        if (marketPrice > MAX_RATE) {
            marketPrice = MAX_RATE;
        }

        int256 supplyDelta = computeSupplyDelta(marketPrice, curGoldPrice);

        if (supplyDelta > 0 && amplg.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(amplg.totalSupply())).toInt256Safe();
        }

       return (curGoldPrice, marketPrice, rate, supplyDelta);
    }


    
    function computeSupplyDelta(uint256 marketPrice, uint256 curGoldPrice)
        internal
        view
        returns (int256)
    {
        if (withinDeviationThreshold(marketPrice, curGoldPrice)) {
            return 0;
        }
        
        
        int256 goldPrice = curGoldPrice.toInt256Safe();
        int256 marketPrice = marketPrice.toInt256Safe();
        
        int256 delta = marketPrice.sub(goldPrice);
        int256 lagSpawn = marketPrice.mul(rebaseLag.toInt256Safe());
        
        return amplg.totalSupply().toInt256Safe()
            .mul(delta).div(lagSpawn);

    }

    
    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyOwner
    {
        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }


    
    function setRebaseTimingParameter(uint256 minRebaseTimeIntervalSec_)
        external
        onlyOwner
    {
        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
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
    
    
    function setAMPLG(IAMPLG amplg_)
        external
        onlyOwner
    {
        require(amplg == IAMPLG(0)); 
        amplg = amplg_;    
    }

    
    function setGoldOracle(IGoldOracle _goldOracle)
        external
        onlyOwner
    {
        goldOracle = _goldOracle;
    }
    
}