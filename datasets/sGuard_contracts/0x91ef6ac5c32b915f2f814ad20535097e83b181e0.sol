pragma solidity ^0.5.12;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity 0.5.12;



interface TokenConverter {
    function convertFrom(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _fromAmount,
        uint256 _minReceive
    ) external payable returns (uint256 _received);

    function convertTo(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _toAmount,
        uint256 _maxSpend
    ) external payable returns (uint256 _spend);

    function getPriceConvertFrom(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _fromAmount
    ) external view returns (uint256 _receive);

    function getPriceConvertTo(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _toAmount
    ) external view returns (uint256 _spend);
}



pragma solidity 0.5.12;


contract UniswapExchange {
    
    function tokenAddress() external view returns (address token);
    
    function factoryAddress() external view returns (address factory);
    
    function addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 minEth, uint256 minTokens, uint256 deadline) external returns (uint256, uint256);
    
    function getEthToTokenInputPrice(uint256 ethSold) external view returns (uint256 tokensBought);
    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);
    function getTokenToEthInputPrice(uint256 tokensSold) external view returns (uint256 ethBought);
    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);
    
    function ethToTokenSwapInput(uint256 minTokens, uint256 deadline) external payable returns (uint256  tokensBought);
    function ethToTokenTransferInput(uint256 minTokens, uint256 deadline, address recipient) external payable returns (uint256  tokensBought);
    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline) external payable returns (uint256  ethSold);
    function ethToTokenTransferOutput(uint256 tokensBought, uint256 deadline, address recipient) external payable returns (uint256  ethSold);
    
    function tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint256 deadline) external returns (uint256  ethBought);
    function tokenToEthTransferInput(uint256 tokensSold, uint256 minTokens, uint256 deadline, address recipient) external returns (uint256  ethBought);
    function tokenToEthSwapOutput(uint256 ethBought, uint256 maxTokens, uint256 deadline) external returns (uint256  tokensSold);
    function tokenToEthTransferOutput(uint256 ethBought, uint256 maxTokens, uint256 deadline, address recipient) external returns (uint256  tokensSold);
    
    function tokenToTokenSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address tokenAddr) external returns (uint256  tokensBought);
    function tokenToTokenTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address recipient, address tokenAddr) external returns (uint256  tokensBought);
    function tokenToTokenSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address tokenAddr) external returns (uint256  tokensSold);
    function tokenToTokenTransferOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address recipient, address tokenAddr) external returns (uint256  tokensSold);
    
    function tokenToExchangeSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address exchangeAddr) external returns (uint256  tokensBought);
    function tokenToExchangeTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address recipient, address exchangeAddr) external returns (uint256  tokensBought);
    function tokenToExchangeSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address exchangeAddr) external returns (uint256  tokensSold);
    function tokenToExchangeTransferOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address recipient, address exchangeAddr) external returns (uint256  tokensSold);
    
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    
    function setup(address tokenAddr) external;
}



pragma solidity 0.5.12;





contract UniswapFactory {
    
    address public exchangeTemplate;
    uint256 public tokenCount;
    
    function createExchange(IERC20 token) external returns (UniswapExchange exchange);
    
    function getExchange(IERC20 token) external view returns (UniswapExchange exchange);
    function getToken(address exchange) external view returns (IERC20 token);
    function getTokenWithId(uint256 tokenId) external view returns (IERC20 token);
    
    function initializeFactory(address template) external;
}



pragma solidity ^0.5.12;




library SafeERC20 {
    
    function safeTransfer(IERC20 _token, address _to, uint256 _value) internal returns (bool) {
        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            
            return false;
        }

        (bool success,) = address(_token).call(
            abi.encodeWithSignature("transfer(address,uint256)", _to, _value)
        );

        if (!success || prevBalance - _value != _token.balanceOf(address(this))) {
            
            return false;
        }

        return true;
    }

    
    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool)
    {
        uint256 prevBalance = _token.balanceOf(_from);

        if (prevBalance < _value) {
            
            return false;
        }

        if (_token.allowance(_from, address(this)) < _value) {
            
            return false;
        }

        (bool success,) = address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _value)
        );

        if (!success || prevBalance - _value != _token.balanceOf(_from)) {
            
            return false;
        }

        return true;
    }

   
    function safeApprove(IERC20 _token, address _spender, uint256 _value) internal returns (bool) {
        (bool success,) = address(_token).call(
            abi.encodeWithSignature("approve(address,uint256)",_spender, _value)
        );

        if (!success && _token.allowance(address(this), _spender) != _value) {
            
            return false;
        }

        return true;
    }

   
    function clearApprove(IERC20 _token, address _spender) internal returns (bool) {
        bool success = safeApprove(_token, _spender, 0);

        if (!success) {
            success = safeApprove(_token, _spender, 1);
        }

        return success;
    }
}



pragma solidity ^0.5.12;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



pragma solidity ^0.5.12;





library SafeExchange {
    using SafeMath for uint256;

    modifier swaps(uint256 _value, IERC20 _token) {
        uint256 nextBalance = _token.balanceOf(address(this)).add(_value);
        _;
        require(
            _token.balanceOf(address(this)) >= nextBalance,
            "Balance validation failed after swap."
        );
    }

    function swapTokens(
        UniswapExchange _exchange,
        uint256 _outValue,
        uint256 _inValue,
        uint256 _ethValue,
        uint256 _deadline,
        IERC20 _outToken
    ) internal swaps(_outValue, _outToken) {
        _exchange.tokenToTokenSwapOutput(
            _outValue,
            _inValue,
            _ethValue,
            _deadline,
            address(_outToken)
        );
    }

    function swapEther(
        UniswapExchange _exchange,
        uint256 _outValue,
        uint256 _ethValue,
        uint256 _deadline,
        IERC20 _outToken
    ) internal swaps(_outValue, _outToken) {
        _exchange.ethToTokenSwapOutput.value(_ethValue)(_outValue, _deadline);
    }
}



pragma solidity ^0.5.12;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
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



pragma solidity 0.5.12;















contract UniswapConverter is TokenConverter, Ownable {
    using SafeMath for uint256;
    using SafeExchange for UniswapExchange;
    using SafeERC20 for IERC20;

    
    IERC20 constant internal ETH_TOKEN_ADDRESS = IERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    
    
    UniswapFactory public factory;

    constructor (address _uniswapFactory) public {
        factory = UniswapFactory(_uniswapFactory);
    }

    function convertFrom(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _fromAmount,
        uint256 _minReceive
    ) external payable returns (uint256 _received) {
        _pull(_fromToken, _fromAmount);

        UniswapFactory _factory = factory;

        if (_fromToken == ETH_TOKEN_ADDRESS) {
            
            
            _received = _factory.getExchange(_toToken).ethToTokenTransferInput.value(
                _fromAmount
            )(
                1,
                uint(-1),
                msg.sender
            );
        } else if (_toToken == ETH_TOKEN_ADDRESS) {
            
            UniswapExchange exchange = _factory.getExchange(_fromToken);
            
            
            _approveOnlyOnce(_fromToken, address(exchange), _fromAmount);
            _received = exchange.tokenToEthTransferInput(
                _fromAmount,
                1,
                uint(-1),
                msg.sender
            );
        } else {
            
            UniswapExchange exchange = _factory.getExchange(_fromToken);
            
            
            _approveOnlyOnce(_fromToken, address(exchange), _fromAmount);
            _received = exchange.tokenToTokenTransferInput(
                _fromAmount,
                1,
                1,
                uint(-1),
                msg.sender,
                address(_toToken)
            );
        }

        require(_received >= _minReceive, "_received is not enought");
    }

    function convertTo(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _toAmount,
        uint256 _maxSpend
    ) external payable returns (uint256 _spent) {
        _pull(_fromToken, _maxSpend);

        UniswapFactory _factory = factory;

        if (_fromToken == ETH_TOKEN_ADDRESS) {
            
            
            _spent = _factory.getExchange(_toToken).ethToTokenTransferOutput.value(
                _maxSpend
            )(
                _toAmount,
                uint(-1),
                msg.sender
            );
        } else if (_toToken == ETH_TOKEN_ADDRESS) {
            
            UniswapExchange exchange = _factory.getExchange(_fromToken);
            
            
            _approveOnlyOnce(_fromToken, address(exchange), _maxSpend);
            _spent = exchange.tokenToEthTransferOutput(
                _toAmount,
                _maxSpend,
                uint(-1),
                msg.sender
            );
        } else {
            
            UniswapExchange exchange = _factory.getExchange(_fromToken);
            
            
            _approveOnlyOnce(_fromToken, address(exchange), _maxSpend);
            _spent = exchange.tokenToTokenTransferOutput(
                _toAmount,
                _maxSpend,
                uint(-1),
                uint(-1),
                msg.sender,
                address(_toToken)
            );
        }

        require(_spent <= _maxSpend, "_maxSpend exceed");
        if (_spent < _maxSpend) {
            _transfer(_fromToken, msg.sender, _maxSpend - _spent);
        }
    }

    function getPriceConvertFrom(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _fromAmount
    ) external view returns (uint256 _receive) {
        UniswapFactory _factory = factory;

        if (_fromToken == ETH_TOKEN_ADDRESS) {
            
            _receive = _factory.getExchange(_toToken).getEthToTokenInputPrice(_fromAmount);
        } else if (_toToken == ETH_TOKEN_ADDRESS) {
            
            _receive = _factory.getExchange(_fromToken).getTokenToEthInputPrice(_fromAmount);
        } else {
            
            
            uint256 ethBought = _factory.getExchange(_fromToken).getTokenToEthInputPrice(_fromAmount);
            _receive = _factory.getExchange(_toToken).getEthToTokenInputPrice(ethBought);
        }
    }

    function getPriceConvertTo(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _toAmount
    ) external view returns (uint256 _spend) {
        UniswapFactory _factory = factory;

        if (_fromToken == ETH_TOKEN_ADDRESS) {
            
            _spend = _factory.getExchange(_toToken).getEthToTokenOutputPrice(_toAmount);
        } else if (_toToken == ETH_TOKEN_ADDRESS) {
            
            _spend = _factory.getExchange(_fromToken).getTokenToEthOutputPrice(_toAmount);
        } else {
            
            
            uint256 ethSpend = _factory.getExchange(_toToken).getEthToTokenOutputPrice(_toAmount);
            _spend = _factory.getExchange(_fromToken).getTokenToEthOutputPrice(ethSpend);
        }
    }

    function _pull(
        IERC20 _token,
        uint256 _amount
    ) private {
        if (_token == ETH_TOKEN_ADDRESS) {
            require(msg.value == _amount, "sent eth is not enought");
        } else {
            require(msg.value == 0, "method is not payable");
            require(_token.transferFrom(msg.sender, address(this), _amount), "error pulling tokens");
        }
    }

    function _transfer(
        IERC20 _token,
        address payable _to,
        uint256 _amount
    ) private {
        if (_token == ETH_TOKEN_ADDRESS) {
            _to.transfer(_amount);
        } else {
            require(_token.transfer(_to, _amount), "error sending tokens");
        }
    }

    function _approveOnlyOnce(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) private {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            if (allowance != 0) {
                _token.clearApprove(_spender);
            }

            _token.approve(_spender, uint(-1));
        }
    }

    function() external payable {}
}