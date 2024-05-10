pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;


contract ReentrancyGuard {
    
    
    bool private _ENTERED_;

    modifier preventReentrant() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
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





interface IWETH {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function deposit() external payable;

    function withdraw(uint256 wad) external;
}






contract DODOEthProxy is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public _DODO_;
    address public _QUOTE_;
    address public _ETH_LP_TOKEN;
    address payable public _WETH_;

    

    event ProxySellEth(address indexed seller, uint256 payEth, uint256 receiveQuote);

    event ProxyBuyEth(address indexed buyer, uint256 receiveEth, uint256 payQuote);

    event ProxyDepositEth(address indexed lp, uint256 ethAmount);

    event ProxyWithdrawEth(address indexed lp, uint256 ethAmount);

    

    constructor(address dodo, address payable weth) public {
        _DODO_ = dodo;
        _WETH_ = weth;
        _QUOTE_ = IDODO(_DODO_)._QUOTE_TOKEN_();
        _ETH_LP_TOKEN = IDODO(_DODO_)._BASE_CAPITAL_TOKEN_();
        address _BASE_ = IDODO(_DODO_)._BASE_TOKEN_();
        require(_BASE_ == _WETH_);
        IERC20(_QUOTE_).approve(_DODO_, uint256(-1));
        IERC20(_BASE_).approve(_DODO_, uint256(-1));
    }

    fallback() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH_:)");
    }

    receive() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH_:)");
    }

    function sellEth(uint256 ethAmount, uint256 minReceiveTokenAmount)
        external
        payable
        preventReentrant
        returns (uint256 receiveTokenAmount)
    {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        IWETH(_WETH_).deposit{value: ethAmount}();
        receiveTokenAmount = IDODO(_DODO_).sellBaseToken(ethAmount, minReceiveTokenAmount, "");
        _transferOut(_QUOTE_, msg.sender, receiveTokenAmount);
        emit ProxySellEth(msg.sender, ethAmount, receiveTokenAmount);
        return receiveTokenAmount;
    }

    function buyEth(uint256 ethAmount, uint256 maxPayTokenAmount)
        external
        preventReentrant
        returns (uint256 payTokenAmount)
    {
        payTokenAmount = IDODO(_DODO_).buyBaseToken(
            ethAmount,
            maxPayTokenAmount,
            abi.encode(msg.sender)
        );
        IWETH(_WETH_).withdraw(ethAmount);
        msg.sender.transfer(ethAmount);
        emit ProxyBuyEth(msg.sender, ethAmount, payTokenAmount);
        return payTokenAmount;
    }

    function dodoCall(
        bool,
        uint256,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        require(msg.sender == _DODO_, "INVALID_DODO_CALL");
        _transferIn(_QUOTE_, abi.decode(data, (address)), quoteAmount);
    }

    function depositEth(uint256 ethAmount) external payable preventReentrant {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IDODO(_DODO_).depositBaseTo(msg.sender, ethAmount);
        emit ProxyDepositEth(msg.sender, ethAmount);
    }

    function withdrawEth(uint256 ethAmount)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        
        uint256 lpBalance = IERC20(_ETH_LP_TOKEN).balanceOf(msg.sender);
        IERC20(_ETH_LP_TOKEN).transferFrom(msg.sender, address(this), lpBalance);
        IDODO(_DODO_).withdrawBase(ethAmount);

        
        lpBalance = IERC20(_ETH_LP_TOKEN).balanceOf(address(this));
        IERC20(_ETH_LP_TOKEN).transfer(msg.sender, lpBalance);

        
        
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEth(msg.sender, wethAmount);
        return wethAmount;
    }

    function withdrawAllEth() external preventReentrant returns (uint256 withdrawAmount) {
        
        uint256 lpBalance = IERC20(_ETH_LP_TOKEN).balanceOf(msg.sender);
        IERC20(_ETH_LP_TOKEN).transferFrom(msg.sender, address(this), lpBalance);
        IDODO(_DODO_).withdrawAllBase();

        
        
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEth(msg.sender, wethAmount);
        return wethAmount;
    }

    

    function _transferIn(
        address tokenAddress,
        address from,
        uint256 amount
    ) internal {
        IERC20(tokenAddress).safeTransferFrom(from, address(this), amount);
    }

    function _transferOut(
        address tokenAddress,
        address to,
        uint256 amount
    ) internal {
        IERC20(tokenAddress).safeTransfer(to, amount);
    }
}