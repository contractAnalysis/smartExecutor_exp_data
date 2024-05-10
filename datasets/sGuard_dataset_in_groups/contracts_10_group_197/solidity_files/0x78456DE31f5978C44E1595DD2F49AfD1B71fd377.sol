pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;




interface I_Aggregator {

    

    
    function latestAnswer()
        external
        view
        returns (int256);
}




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




interface I_P1Oracle {

    
    function getPrice()
        external
        view
        returns (uint256);
}




contract P1ChainlinkOracle is
    I_P1Oracle
{
    using BaseMath for uint256;

    

    
    address public _ORACLE_;

    
    address public _READER_;

    
    uint256 public _ADJUSTMENT_;

    
    mapping (address => bytes32) public _MAPPING_;

    

    constructor(
        address oracle,
        address reader,
        uint96 adjustmentExponent
    )
        public
    {
        _ORACLE_ = oracle;
        _READER_ = reader;
        _ADJUSTMENT_ = 10 ** uint256(adjustmentExponent);

        bytes32 oracleAndAdjustment =
            bytes32(bytes20(oracle)) |
            bytes32(uint256(adjustmentExponent));
        _MAPPING_[reader] = oracleAndAdjustment;
    }

    

    
    function getPrice()
        external
        view
        returns (uint256)
    {
        bytes32 oracleAndExponent = _MAPPING_[msg.sender];
        require(
            oracleAndExponent != bytes32(0),
            "P1ChainlinkOracle: Sender not authorized to get price"
        );
        (address oracle, uint256 adjustment) = getOracleAndAdjustment(oracleAndExponent);
        int256 answer = I_Aggregator(oracle).latestAnswer();
        require(
            answer > 0,
            "P1ChainlinkOracle: Invalid answer from aggregator"
        );
        uint256 rawPrice = uint256(answer);
        return rawPrice.baseMul(adjustment);
    }

    function getOracleAndAdjustment(
        bytes32 oracleAndExponent
    )
        private
        pure
        returns (address, uint256)
    {
        address oracle = address(bytes20(oracleAndExponent));
        uint256 exponent = uint256(uint96(uint256(oracleAndExponent)));
        return (oracle, 10 ** exponent);
    }
}