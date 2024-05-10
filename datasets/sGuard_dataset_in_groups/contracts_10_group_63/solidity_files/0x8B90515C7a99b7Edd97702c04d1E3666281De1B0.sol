pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;




library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}




contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}




contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




library BaseMath {
    using SafeMath for uint256;

    
    uint256 constant internal BASE = 10 ** 18;

    
    function base()
        internal
        pure
        returns (uint256)
    {
        return BASE;
    }

    
    function baseMul(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        return value.mul(baseValue).div(BASE);
    }

    
    function baseDivMul(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        return value.div(BASE).mul(baseValue);
    }

    
    function baseMulRoundUp(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        if (value == 0 || baseValue == 0) {
            return 0;
        }
        return value.mul(baseValue).sub(1).div(BASE).add(1);
    }

    
    function baseDiv(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        return value.mul(BASE).div(baseValue);
    }

    
    function baseReciprocal(
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        return baseDiv(BASE, baseValue);
    }
}




library Math {
    using SafeMath for uint256;

    

    
    function getFraction(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {
        return target.mul(numerator).div(denominator);
    }

    
    function getFractionRoundUp(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {
        if (target == 0 || numerator == 0) {
            
            return SafeMath.div(0, denominator);
        }
        return target.mul(numerator).sub(1).div(denominator).add(1);
    }

    
    function min(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    
    function max(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        return a > b ? a : b;
    }
}




library SafeCast {

    
    function toUint128(
        uint256 value
    )
        internal
        pure
        returns (uint128)
    {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    
    function toUint120(
        uint256 value
    )
        internal
        pure
        returns (uint120)
    {
        require(value < 2**120, "SafeCast: value doesn\'t fit in 120 bits");
        return uint120(value);
    }

    
    function toUint32(
        uint256 value
    )
        internal
        pure
        returns (uint32)
    {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }
}




library SignedMath {
    using SafeMath for uint256;

    

    struct Int {
        uint256 value;
        bool isPositive;
    }

    

    
    function add(
        Int memory sint,
        uint256 value
    )
        internal
        pure
        returns (Int memory)
    {
        if (sint.isPositive) {
            return Int({
                value: value.add(sint.value),
                isPositive: true
            });
        }
        if (sint.value < value) {
            return Int({
                value: value.sub(sint.value),
                isPositive: true
            });
        }
        return Int({
            value: sint.value.sub(value),
            isPositive: false
        });
    }

    
    function sub(
        Int memory sint,
        uint256 value
    )
        internal
        pure
        returns (Int memory)
    {
        if (!sint.isPositive) {
            return Int({
                value: value.add(sint.value),
                isPositive: false
            });
        }
        if (sint.value > value) {
            return Int({
                value: sint.value.sub(value),
                isPositive: true
            });
        }
        return Int({
            value: value.sub(sint.value),
            isPositive: false
        });
    }

    
    function signedAdd(
        Int memory augend,
        Int memory addend
    )
        internal
        pure
        returns (Int memory)
    {
        return addend.isPositive
            ? add(augend, addend.value)
            : sub(augend, addend.value);
    }

    
    function signedSub(
        Int memory minuend,
        Int memory subtrahend
    )
        internal
        pure
        returns (Int memory)
    {
        return subtrahend.isPositive
            ? sub(minuend, subtrahend.value)
            : add(minuend, subtrahend.value);
    }

    
    function gt(
        Int memory a,
        Int memory b
    )
        internal
        pure
        returns (bool)
    {
        if (a.isPositive) {
            if (b.isPositive) {
                return a.value > b.value;
            } else {
                
                return a.value != 0 || b.value != 0;
            }
        } else {
            if (b.isPositive) {
                return false;
            } else {
                return a.value < b.value;
            }
        }
    }

    
    function min(
        Int memory a,
        Int memory b
    )
        internal
        pure
        returns (Int memory)
    {
        return gt(b, a) ? a : b;
    }

    
    function max(
        Int memory a,
        Int memory b
    )
        internal
        pure
        returns (Int memory)
    {
        return gt(a, b) ? a : b;
    }
}




interface I_P1Funder {

    
    function getFunding(
        uint256 timeDelta
    )
        external
        view
        returns (bool, uint256);
}




library P1Types {
    

    
    struct Index {
        uint32 timestamp;
        bool isPositive;
        uint128 value;
    }

    
    struct Balance {
        bool marginIsPositive;
        bool positionIsPositive;
        uint120 margin;
        uint120 position;
    }

    
    struct Context {
        uint256 price;
        uint256 minCollateral;
        Index index;
    }

    
    struct TradeResult {
        uint256 marginAmount;
        uint256 positionAmount;
        bool isBuy; 
        bytes32 traderFlags;
    }
}




library P1IndexMath {

    

    uint256 private constant FLAG_IS_POSITIVE = 1 << (8 * 16);

    

    
    function toBytes32(
        P1Types.Index memory index
    )
        internal
        pure
        returns (bytes32)
    {
        uint256 result =
            index.value
            | (index.isPositive ? FLAG_IS_POSITIVE : 0)
            | (uint256(index.timestamp) << 136);
        return bytes32(result);
    }
}




contract P1FundingOracle is
    Ownable,
    I_P1Funder
{
    using BaseMath for uint256;
    using SafeCast for uint256;
    using SafeMath for uint128;
    using SafeMath for uint256;
    using P1IndexMath for P1Types.Index;
    using SignedMath for SignedMath.Int;

    

    uint256 private constant FLAG_IS_POSITIVE = 1 << 128;
    uint128 constant internal BASE = 10 ** 18;

    
    uint128 public constant MAX_ABS_VALUE = BASE * 75 / 10000 / (8 hours);
    uint128 public constant MAX_ABS_DIFF_PER_SECOND = MAX_ABS_VALUE * 2 / (45 minutes);

    

    event LogFundingRateUpdated(
        bytes32 fundingRate
    );

    event LogFundingRateProviderSet(
        address fundingRateProvider
    );

    

    
    P1Types.Index private _FUNDING_RATE_;

    
    address public _FUNDING_RATE_PROVIDER_;

    

    constructor(
        address fundingRateProvider
    )
        public
    {
        P1Types.Index memory fundingRate = P1Types.Index({
            timestamp: block.timestamp.toUint32(),
            isPositive: true,
            value: 0
        });
        _FUNDING_RATE_ = fundingRate;
        _FUNDING_RATE_PROVIDER_ = fundingRateProvider;

        emit LogFundingRateUpdated(fundingRate.toBytes32());
        emit LogFundingRateProviderSet(fundingRateProvider);
    }

    

    
    function setFundingRate(
        SignedMath.Int calldata newRate
    )
        external
        returns (P1Types.Index memory)
    {
        require(
            msg.sender == _FUNDING_RATE_PROVIDER_,
            "The funding rate can only be set by the funding rate provider"
        );

        SignedMath.Int memory boundedNewRate = _boundRate(newRate);
        P1Types.Index memory boundedNewRateWithTimestamp = P1Types.Index({
            timestamp: block.timestamp.toUint32(),
            isPositive: boundedNewRate.isPositive,
            value: boundedNewRate.value.toUint128()
        });
        _FUNDING_RATE_ = boundedNewRateWithTimestamp;

        emit LogFundingRateUpdated(boundedNewRateWithTimestamp.toBytes32());

        return boundedNewRateWithTimestamp;
    }

    
    function setFundingRateProvider(
        address newProvider
    )
        external
        onlyOwner
    {
        _FUNDING_RATE_PROVIDER_ = newProvider;
        emit LogFundingRateProviderSet(newProvider);
    }

    

    
    function getFunding(
        uint256 timeDelta
    )
        public
        view
        returns (bool, uint256)
    {
        
        
        P1Types.Index memory fundingRate = _FUNDING_RATE_;
        uint256 fundingAmount = uint256(fundingRate.value).mul(timeDelta);
        return (fundingRate.isPositive, fundingAmount);
    }

    

    
    function _boundRate(
        SignedMath.Int memory newRate
    )
        private
        view
        returns (SignedMath.Int memory)
    {
        
        P1Types.Index memory oldRateWithTimestamp = _FUNDING_RATE_;
        SignedMath.Int memory oldRate = SignedMath.Int({
            value: oldRateWithTimestamp.value,
            isPositive: oldRateWithTimestamp.isPositive
        });

        
        uint256 timeDelta = block.timestamp.sub(oldRateWithTimestamp.timestamp);
        uint256 maxDiff = MAX_ABS_DIFF_PER_SECOND.mul(timeDelta);

        
        if (newRate.gt(oldRate)) {
            SignedMath.Int memory upperBound = SignedMath.min(
                oldRate.add(maxDiff),
                SignedMath.Int({ value: MAX_ABS_VALUE, isPositive: true })
            );
            return SignedMath.min(
                newRate,
                upperBound
            );
        } else {
            SignedMath.Int memory lowerBound = SignedMath.max(
                oldRate.sub(maxDiff),
                SignedMath.Int({ value: MAX_ABS_VALUE, isPositive: false })
            );
            return SignedMath.max(
                newRate,
                lowerBound
            );
        }
    }
}