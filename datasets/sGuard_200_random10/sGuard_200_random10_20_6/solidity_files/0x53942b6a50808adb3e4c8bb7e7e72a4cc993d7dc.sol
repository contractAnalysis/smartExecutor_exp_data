pragma solidity ^0.5.0;


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



pragma solidity ^0.5.0;


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



pragma solidity ^0.5.0;



interface IPriceOracleGetter {
    
    function getAssetPrice(address _asset) external view returns (uint256);
}



pragma solidity ^0.5.0;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}



pragma solidity ^0.5.0;





library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.5.0;

library EthAddressLib {

    
    function ethAddress() internal pure returns(address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}



pragma solidity ^0.5.0;

library UintConstants {
    
    function maxUint() internal pure returns(uint256) {
        return uint256(-1);
    }

    
    function maxUintMinus1() internal pure returns(uint256) {
        return uint256(-1) - 1;
    }
}



pragma solidity ^0.5.0;





contract IExchangeAdapter {
    using SafeERC20 for IERC20;

    event Exchange(
        address indexed from,
        address indexed to,
        address indexed platform,
        uint256 fromAmount,
        uint256 toAmount
    );

    function approveExchange(IERC20[] calldata _tokens) external;

    function exchange(address _from, address _to, uint256 _amount, uint256 _maxSlippage) external returns(uint256);
}



pragma solidity ^0.5.0;


interface IKyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, IERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);
    function getExpectedRate(IERC20 src, IERC20 dest, uint srcQty)
        external view returns (uint expectedRate, uint slippageRate);
    function tradeWithHint(
        IERC20 src,
        uint srcAmount,
        IERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes calldata hint) external payable returns(uint);
}



pragma solidity ^0.5.0;













contract KyberAdapter is IExchangeAdapter {
    using SafeMath for uint256;

    uint256 public constant MAX_UINT = 2**256 - 1;

    uint256 public constant MAX_UINT_MINUS_ONE = (2 ** 256 - 1) - 1;

    
    uint256 public constant MIN_CONVERSION_RATE = 1;

    
    address public constant AAVE_PRICES_PROVIDER = 0x76B47460d7F7c5222cFb6b6A75615ab10895DDe4;

    address public constant KYBER_ETH_MOCK_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    
    IKyberNetworkProxyInterface public constant KYBER_PROXY = IKyberNetworkProxyInterface(
        0x9AAb3f75489902f3a48495025729a0AF77d4b11e
    );

    
    
    function approveExchange(IERC20[] calldata _tokens) external {
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (address(_tokens[i]) != EthAddressLib.ethAddress()) {
                _tokens[i].safeApprove(address(KYBER_PROXY), MAX_UINT_MINUS_ONE);
            }
        }
    }

    
    
    
    
    
    
    function exchange(address _from, address _to, uint256 _amount, uint256 _maxSlippage)
        external
        returns (uint256)
    {
        address _kyberFromRef = _from;
        uint256 value = 0;

        if (_from == EthAddressLib.ethAddress()) {
            value = _amount;
        }

        
        
        if (_from == 0x0000000000085d4780B73119b644AE5ecd22b376) {
            _kyberFromRef = 0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
        }

        uint256 _fromAssetPriceInWei = IPriceOracleGetter(AAVE_PRICES_PROVIDER).getAssetPrice(
            _from
        );
        uint256 _toAssetPriceInWei = IPriceOracleGetter(AAVE_PRICES_PROVIDER).getAssetPrice(_to);


        uint256 _amountReceived = KYBER_PROXY.tradeWithHint.value(value)(
            
            IERC20(_kyberFromRef),
            
            _amount,
            
            IERC20(_to),
            
            address(this),
            
            MAX_UINT,
            
            MIN_CONVERSION_RATE,
            
            0x0000000000000000000000000000000000000000,
            
            ""
        );


        require(
            (_toAssetPriceInWei.mul(_amountReceived).mul(100)).div(
                    _fromAssetPriceInWei.mul(_amount)
                ) >=
                (100 - _maxSlippage),
            "INVALID_SLIPPAGE"
        );

        emit Exchange(
            _from,
            _to,
            address(KYBER_PROXY),
            _amount,
            _amountReceived
        );
        return _amountReceived;
    }
}