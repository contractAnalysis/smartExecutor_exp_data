pragma solidity ^0.6.0;


interface IOracle {
    function getData() external view returns (uint256, bool);
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}




library Babylonian {
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        
    }
}


library FixedPoint {
    
    
    struct uq112x112 {
        uint224 _x;
    }

    
    
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = uint(1) << RESOLUTION;
    uint private constant Q224 = Q112 << RESOLUTION;

    
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    
    
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    
    
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    
    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');
        return uq112x112(uint224(Q224 / self._x));
    }

    
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

library UniswapV2Library {
    using SafeMath for uint;

    
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' 
            ))));
    }

    
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
    
}


library UniswapV2OracleLibrary {
    using FixedPoint for *;

    
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            
            
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}



contract RebasedPriceOracle is IOracle {
    using FixedPoint for *;

    uint private ethRebPrice0CumulativeLast;
    uint private ethRebPrice1CumulativeLast;
    uint32 private ethRebBlockTimestampLast;
    
    uint private usdcEthPrice0CumulativeLast;
    uint private usdcEthPrice1CumulativeLast;    
    uint32 private usdcEthBlockTimestampLast;
    
    uint public lastUpdateTimestamp;
    uint public lastAnswer;
    
    uint public constant MIN_PERIOD = 2 hours; 
    uint public constant UPDATE_LAG = 10 minutes; 
    
    address private constant _weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private _reb = 0xE6279E1c65DD41b30bA3760DCaC3CD8bbb4420D6;
    address private _usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IUniswapV2Pair private constant _eth_reb = IUniswapV2Pair(0xa89004aA11CF28B34E125c63FBc56213fb663F70);
    IUniswapV2Pair private constant _usdc_eth = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);

    constructor() public {
        
        uint112 _dummy1;
        uint112 _dummy2;
        
        ethRebPrice0CumulativeLast = _eth_reb.price0CumulativeLast();
        ethRebPrice1CumulativeLast = _eth_reb.price1CumulativeLast();
        
        (_dummy1, _dummy2, ethRebBlockTimestampLast) = _eth_reb.getReserves();
        
        usdcEthPrice0CumulativeLast = _usdc_eth.price0CumulativeLast();
        usdcEthPrice1CumulativeLast = _usdc_eth.price1CumulativeLast();
        
        (_dummy1, _dummy2, usdcEthBlockTimestampLast) = _usdc_eth.getReserves();
    }

    
    function getRebEthRate() internal view returns (uint256, uint256, uint32, uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 _blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(_eth_reb));
            
        FixedPoint.uq112x112 memory rebEthAverage = FixedPoint.uq112x112(uint224(1e9 * (price1Cumulative - ethRebPrice1CumulativeLast) / (_blockTimestamp - ethRebBlockTimestampLast)));
        
        return (price0Cumulative, price1Cumulative, _blockTimestamp, rebEthAverage.mul(1).decode144());
    }
    
    
    function getUsdcEthRate() internal view returns  (uint256, uint256, uint32, uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 _blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(_usdc_eth));
            
        FixedPoint.uq112x112 memory usdcEthAverage = FixedPoint.uq112x112(uint224(1e6 * (price0Cumulative - usdcEthPrice0CumulativeLast) / (_blockTimestamp - usdcEthBlockTimestampLast)));
            
        return (price0Cumulative, price1Cumulative, _blockTimestamp, usdcEthAverage.mul(1).decode144());
    }

    
   function update() external {
       
        uint timeStamp = block.timestamp;
        uint timeElapsed = timeStamp - lastUpdateTimestamp;
        
        require(timeElapsed > MIN_PERIOD,"Update frequency is too high");
        
        lastUpdateTimestamp = timeStamp;
          
        uint rebEthAverage;
        uint usdcEthAverage;
        
        (ethRebPrice0CumulativeLast, ethRebPrice1CumulativeLast, ethRebBlockTimestampLast, rebEthAverage) = getRebEthRate();
        (usdcEthPrice0CumulativeLast, usdcEthPrice1CumulativeLast, usdcEthBlockTimestampLast, usdcEthAverage) = getUsdcEthRate();
        
        lastAnswer = (rebEthAverage * 1e18) / usdcEthAverage;
    }

    
    function getData() external view override returns (uint256, bool) {
        
        if (block.timestamp < lastUpdateTimestamp + UPDATE_LAG) {
            return (lastAnswer, true);
        }
        
        uint _price0CumulativeLast;
        uint _price1CumulativeLast;
        uint32 _blockTimestampLast;
        
        uint rebEthAverage;

        (_price0CumulativeLast, _price1CumulativeLast, _blockTimestampLast, rebEthAverage) = getRebEthRate();
        
        uint usdcEthAverage;
        
         (_price0CumulativeLast, _price1CumulativeLast, _blockTimestampLast, usdcEthAverage) = getUsdcEthRate();
         
        uint answer = (rebEthAverage * 1e18) / usdcEthAverage;
        
        return (answer, true);
    }
}