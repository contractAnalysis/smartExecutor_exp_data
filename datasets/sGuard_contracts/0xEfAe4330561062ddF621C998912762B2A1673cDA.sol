pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

interface IPriceOracle {
    
    function getPrice(
        address asset
    )
        external
        view
        returns (uint256);
}

library SafeMath {

    
    function mul(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    
    function div(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    
    function sub(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function sub(
        int256 a,
        uint256 b
    )
        internal
        pure
        returns (int256)
    {
        require(b <= 2**255-1, "INT256_SUB_ERROR");
        int256 c = a - int256(b);
        require(c <= a, "INT256_SUB_ERROR");
        return c;
    }

    
    function add(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function add(
        int256 a,
        uint256 b
    )
        internal
        pure
        returns (int256)
    {
        require(b <= 2**255 - 1, "INT256_ADD_ERROR");
        int256 c = a + int256(b);
        require(c >= a, "INT256_ADD_ERROR");
        return c;
    }

    
    function mod(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        require(b != 0, "MOD_ERROR");
        return a % b;
    }

    
    function isRoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 multiple
    )
        internal
        pure
        returns (bool)
    {
        
        return mul(mod(mul(numerator, multiple), denominator), 1000) >= mul(numerator, multiple);
    }

    
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 multiple
    )
        internal
        pure
        returns (uint256)
    {
        require(!isRoundingError(numerator, denominator, multiple), "ROUNDING_ERROR");
        
        return div(mul(numerator, multiple), denominator);
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
}

contract PriceOracleProxy {
    using SafeMath for uint256;

    address public asset;
    uint256 public decimal;
    address public sourceOracleAddress;
    address public sourceAssetAddress;
    uint256 public sourceAssetDecimal;

    constructor (
        address _asset,
        uint256 _decimal,
        address _sourceOracleAddress,
        address _sourceAssetAddress,
        uint256 _sourceAssetDecimal
    )
        public
    {
        asset = _asset;
        decimal = _decimal;
        sourceOracleAddress = _sourceOracleAddress;
        sourceAssetAddress = _sourceAssetAddress;
        sourceAssetDecimal = _sourceAssetDecimal;
    }

    function _getPrice()
        internal
        view
        returns (uint256)
    {
        uint256 price = IPriceOracle(sourceOracleAddress).getPrice(sourceAssetAddress);

        if (decimal >= sourceAssetDecimal) {
            price = price.div(10 ** (decimal - sourceAssetDecimal));
        } else {
            price = price.mul(10 ** (sourceAssetDecimal - decimal));
        }

        return price;
    }

    function getPrice(
        address _asset
    )
        external
        view
        returns (uint256)
    {
        require(_asset == asset, "ASSET_NOT_MATCH");
        return _getPrice();
    }

    function getCurrentPrice()
        external
        view
        returns (uint256)
    {
        return _getPrice();
    }
}