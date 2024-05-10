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



contract IOneSplitView {
    
    uint256 public constant FLAG_UNISWAP = 0x01;
    uint256 public constant FLAG_KYBER = 0x02;
    uint256 public constant FLAG_KYBER_UNISWAP_RESERVE = 0x100000000; 
    uint256 public constant FLAG_KYBER_OASIS_RESERVE = 0x200000000; 
    uint256 public constant FLAG_KYBER_BANCOR_RESERVE = 0x400000000; 
    uint256 public constant FLAG_BANCOR = 0x04;
    uint256 public constant FLAG_OASIS = 0x08;
    uint256 public constant FLAG_COMPOUND = 0x10;
    uint256 public constant FLAG_FULCRUM = 0x20;
    uint256 public constant FLAG_CHAI = 0x40;
    uint256 public constant FLAG_AAVE = 0x80;
    uint256 public constant FLAG_SMART_TOKEN = 0x100;
    uint256 public constant FLAG_MULTI_PATH_ETH = 0x200; 
    uint256 public constant FLAG_BDAI = 0x400;
    uint256 public constant FLAG_IEARN = 0x800;

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 disableFlags 
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution 
        );
}


contract IOneSplit is IOneSplitView {
    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution, 
        uint256 disableFlags 
    ) public payable;

    function goodSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256 parts,
        uint256 disableFlags 
    ) public payable;
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




contract IExchangeAdapter {
    using SafeERC20 for IERC20;

    uint256 public constant MAX_UINT = uint256(-1);

    uint256 public constant MAX_UINT_MINUS_ONE = MAX_UINT - 1;

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









contract OneSplitAdapter is IExchangeAdapter {
    using SafeMath for uint256;

    
    address public oneSplit;

    
    
    
    
    uint256 public constant SPLIT_PARTS = 10;

    
    
    
    
    uint256 public constant MULTI_PATH_ETH_FLAG = 512;

    
    IPriceOracleGetter priceOracle;

    constructor(address _oneSplit, IPriceOracleGetter _priceOracle) public {
        oneSplit = _oneSplit;
        priceOracle = _priceOracle;
    }

    
    
    function approveExchange(IERC20[] calldata _tokens) external {
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (address(_tokens[i]) != EthAddressLib.ethAddress()) {
                _tokens[i].safeApprove(oneSplit, MAX_UINT_MINUS_ONE);
            }
        }
    }

    
    
    
    
    
    
    function exchange(address _from, address _to, uint256 _amount, uint256 _maxSlippage) external returns(uint256) {
        uint256 _value = (_from == EthAddressLib.ethAddress()) ? _amount : 0;

        uint256 _fromAssetPriceInWei = priceOracle.getAssetPrice(_from);
        uint256 _toAssetPriceInWei = priceOracle.getAssetPrice(_to);
        uint256 _toBalanceBefore = IERC20(_to).balanceOf(address(this));

        IOneSplit(oneSplit).goodSwap.value(_value)(
            IERC20(_from),
            IERC20(_to),
            _amount,
            0,
            SPLIT_PARTS,
            MULTI_PATH_ETH_FLAG
        );

        uint256 _toReceivedAmount = IERC20(_to).balanceOf(address(this)).sub(_toBalanceBefore);

        require(
            (_toAssetPriceInWei.mul(_toReceivedAmount).mul(100))
                .div(_fromAssetPriceInWei.mul(_amount)) >= (100 - _maxSlippage),
            "INVALID_SLIPPAGE"
        );

        emit Exchange(_from, _to, oneSplit, _amount, _toReceivedAmount);
        return _toReceivedAmount;
    }
}