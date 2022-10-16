pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;


contract Ownable {
    address public _OWNER_;
    address public _NEW_OWNER_;

    

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    

    constructor() internal {
        _OWNER_ = msg.sender;
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() external {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}





interface IDODO {
    function init(
        address owner,
        address supervisor,
        address maintainer,
        address baseToken,
        address quoteToken,
        address oracle,
        uint256 lpFeeRate,
        uint256 mtFeeRate,
        uint256 k,
        uint256 gasPriceLimit
    ) external;

    function transferOwnership(address newOwner) external;

    function claimOwnership() external;

    function sellBaseToken(
        uint256 amount,
        uint256 minReceiveQuote,
        bytes calldata data
    ) external returns (uint256);

    function buyBaseToken(
        uint256 amount,
        uint256 maxPayQuote,
        bytes calldata data
    ) external returns (uint256);

    function querySellBaseToken(uint256 amount) external view returns (uint256 receiveQuote);

    function queryBuyBaseToken(uint256 amount) external view returns (uint256 payQuote);

    function depositBaseTo(address to, uint256 amount) external returns (uint256);

    function withdrawBase(uint256 amount) external returns (uint256);

    function withdrawAllBase() external returns (uint256);

    function depositQuoteTo(address to, uint256 amount) external returns (uint256);

    function withdrawQuote(uint256 amount) external returns (uint256);

    function withdrawAllQuote() external returns (uint256);

    function _BASE_CAPITAL_TOKEN_() external returns (address);

    function _QUOTE_CAPITAL_TOKEN_() external returns (address);

    function _BASE_TOKEN_() external returns (address);

    function _QUOTE_TOKEN_() external returns (address);
}






interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}






library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}






library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

contract UniswapArbitrageur {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public _UNISWAP_;
    address public _DODO_;
    address public _BASE_;
    address public _QUOTE_;

    bool public _REVERSE_; 

    constructor(address _uniswap, address _dodo) public {
        _UNISWAP_ = _uniswap;
        _DODO_ = _dodo;

        _BASE_ = IDODO(_DODO_)._BASE_TOKEN_();
        _QUOTE_ = IDODO(_DODO_)._QUOTE_TOKEN_();

        address token0 = IUniswapV2Pair(_UNISWAP_).token0();
        address token1 = IUniswapV2Pair(_UNISWAP_).token1();

        if (token0 == _BASE_ && token1 == _QUOTE_) {
            _REVERSE_ = false;
        } else if (token0 == _QUOTE_ && token1 == _BASE_) {
            _REVERSE_ = true;
        } else {
            require(true, "DODO_UNISWAP_NOT_MATCH");
        }

        IERC20(_BASE_).approve(_DODO_, uint256(-1));
        IERC20(_QUOTE_).approve(_DODO_, uint256(-1));
    }

    function executeBuyArbitrage(uint256 baseAmount) external returns (uint256 quoteProfit) {
        IDODO(_DODO_).buyBaseToken(baseAmount, uint256(-1), "0xd");
        quoteProfit = IERC20(_QUOTE_).balanceOf(address(this));
        IERC20(_QUOTE_).transfer(msg.sender, quoteProfit);
        return quoteProfit;
    }

    function executeSellArbitrage(uint256 baseAmount) external returns (uint256 baseProfit) {
        IDODO(_DODO_).sellBaseToken(baseAmount, 0, "0xd");
        baseProfit = IERC20(_BASE_).balanceOf(address(this));
        IERC20(_BASE_).transfer(msg.sender, baseProfit);
        return baseProfit;
    }

    function dodoCall(
        bool isDODOBuy,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata
    ) external {
        require(msg.sender == _DODO_, "WRONG_DODO");
        if (_REVERSE_) {
            _inverseArbitrage(isDODOBuy, baseAmount, quoteAmount);
        } else {
            _arbitrage(isDODOBuy, baseAmount, quoteAmount);
        }
    }

    function _inverseArbitrage(
        bool isDODOBuy,
        uint256 baseAmount,
        uint256 quoteAmount
    ) internal {
        (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(_UNISWAP_).getReserves();
        uint256 token0Balance = uint256(_reserve0);
        uint256 token1Balance = uint256(_reserve1);
        uint256 token0Amount;
        uint256 token1Amount;
        if (isDODOBuy) {
            IERC20(_BASE_).transfer(_UNISWAP_, baseAmount);
            
            uint256 newToken0Balance = token0Balance.mul(token1Balance).div(
                token1Balance.add(baseAmount)
            );
            token0Amount = token0Balance.sub(newToken0Balance).mul(9969).div(10000); 
            require(token0Amount > quoteAmount, "NOT_PROFITABLE");
            IUniswapV2Pair(_UNISWAP_).swap(token0Amount, token1Amount, address(this), "");
        } else {
            IERC20(_QUOTE_).transfer(_UNISWAP_, quoteAmount);
            // transfer token0 into uniswap
            uint256 newToken1Balance = token0Balance.mul(token1Balance).div(
                token0Balance.add(quoteAmount)
            );
            token1Amount = token1Balance.sub(newToken1Balance).mul(9969).div(10000); // mul 0.9969
            require(token1Amount > baseAmount, "NOT_PROFITABLE");
            IUniswapV2Pair(_UNISWAP_).swap(token0Amount, token1Amount, address(this), "");
        }
    }

    function _arbitrage(
        bool isDODOBuy,
        uint256 baseAmount,
        uint256 quoteAmount
    ) internal {
        (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(_UNISWAP_).getReserves();
        uint256 token0Balance = uint256(_reserve0);
        uint256 token1Balance = uint256(_reserve1);
        uint256 token0Amount;
        uint256 token1Amount;
        if (isDODOBuy) {
            IERC20(_BASE_).transfer(_UNISWAP_, baseAmount);
            // transfer token0 into uniswap
            uint256 newToken1Balance = token1Balance.mul(token0Balance).div(
                token0Balance.add(baseAmount)
            );
            token1Amount = token1Balance.sub(newToken1Balance).mul(9969).div(10000); // mul 0.9969
            require(token1Amount > quoteAmount, "NOT_PROFITABLE");
            IUniswapV2Pair(_UNISWAP_).swap(token0Amount, token1Amount, address(this), "");
        } else {
            IERC20(_QUOTE_).transfer(_UNISWAP_, quoteAmount);
            // transfer token1 into uniswap
            uint256 newToken0Balance = token1Balance.mul(token0Balance).div(
                token1Balance.add(quoteAmount)
            );
            token0Amount = token0Balance.sub(newToken0Balance).mul(9969).div(10000); // mul 0.9969
            require(token0Amount > baseAmount, "NOT_PROFITABLE");
            IUniswapV2Pair(_UNISWAP_).swap(token0Amount, token1Amount, address(this), "");
        }
    }

    function retrieve(address token, uint256 amount) external {
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}