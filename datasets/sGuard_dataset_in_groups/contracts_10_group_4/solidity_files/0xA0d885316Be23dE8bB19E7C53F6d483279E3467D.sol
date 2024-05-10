pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


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




library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}




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
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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




interface I_ExchangeWrapper {

    

    
    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256);

    
    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256);
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




interface I_PerpetualV1 {

    

    struct TradeArg {
        uint256 takerIndex;
        uint256 makerIndex;
        address trader;
        bytes data;
    }

    

    
    function trade(
        address[] calldata accounts,
        TradeArg[] calldata trades
    )
        external;

    
    function withdrawFinalSettlement()
        external;

    
    function deposit(
        address account,
        uint256 amount
    )
        external;

    
    function withdraw(
        address account,
        address destination,
        uint256 amount
    )
        external;

    
    function setLocalOperator(
        address operator,
        bool approved
    )
        external;

    

    
    function getAccountBalance(
        address account
    )
        external
        view
        returns (P1Types.Balance memory);

    
    function getAccountIndex(
        address account
    )
        external
        view
        returns (P1Types.Index memory);

    
    function getIsLocalOperator(
        address account,
        address operator
    )
        external
        view
        returns (bool);

    

    
    function getIsGlobalOperator(
        address operator
    )
        external
        view
        returns (bool);

    
    function getTokenContract()
        external
        view
        returns (address);

    
    function getOracleContract()
        external
        view
        returns (address);

    
    function getFunderContract()
        external
        view
        returns (address);

    
    function getGlobalIndex()
        external
        view
        returns (P1Types.Index memory);

    
    function getMinCollateral()
        external
        view
        returns (uint256);

    
    function getFinalSettlementEnabled()
        external
        view
        returns (bool);

    

    
    function hasAccountPermissions(
        address account,
        address operator
    )
        external
        view
        returns (bool);

    

    
    function getOraclePrice()
        external
        view
        returns (uint256);
}




contract P1CurrencyConverterProxy {
    using SafeERC20 for IERC20;

    

    event LogConvertedDeposit(
        address indexed account,
        address source,
        address perpetual,
        address exchangeWrapper,
        address tokenFrom,
        address tokenTo,
        uint256 tokenFromAmount,
        uint256 tokenToAmount
    );

    event LogConvertedWithdrawal(
        address indexed account,
        address destination,
        address perpetual,
        address exchangeWrapper,
        address tokenFrom,
        address tokenTo,
        uint256 tokenFromAmount,
        uint256 tokenToAmount
    );

    

    
    function approveMaximumOnPerpetual(
        address perpetual
    )
        external
    {
        IERC20 tokenContract = IERC20(I_PerpetualV1(perpetual).getTokenContract());

        
        tokenContract.safeApprove(perpetual, 0);

        
        tokenContract.safeApprove(perpetual, uint256(-1));
    }

    
    function deposit(
        address account,
        address perpetual,
        address exchangeWrapper,
        address tokenFrom,
        uint256 tokenFromAmount,
        bytes calldata data
    )
        external
        returns (uint256)
    {
        I_PerpetualV1 perpetualContract = I_PerpetualV1(perpetual);
        address tokenTo = perpetualContract.getTokenContract();
        address self = address(this);

        
        
        
        IERC20(tokenFrom).safeTransferFrom(
            msg.sender,
            exchangeWrapper,
            tokenFromAmount
        );

        
        I_ExchangeWrapper exchangeWrapperContract = I_ExchangeWrapper(exchangeWrapper);
        uint256 tokenToAmount = exchangeWrapperContract.exchange(
            msg.sender,
            self,
            tokenTo,
            tokenFrom,
            tokenFromAmount,
            data
        );

        
        IERC20(tokenTo).safeTransferFrom(
            exchangeWrapper,
            self,
            tokenToAmount
        );

        
        perpetualContract.deposit(
            account,
            tokenToAmount
        );

        
        emit LogConvertedDeposit(
            account,
            msg.sender,
            perpetual,
            exchangeWrapper,
            tokenFrom,
            tokenTo,
            tokenFromAmount,
            tokenToAmount
        );

        return tokenToAmount;
    }

    
    function withdraw(
        address account,
        address destination,
        address perpetual,
        address exchangeWrapper,
        address tokenTo,
        uint256 tokenFromAmount,
        bytes calldata data
    )
        external
        returns (uint256)
    {
        I_PerpetualV1 perpetualContract = I_PerpetualV1(perpetual);
        address tokenFrom = perpetualContract.getTokenContract();
        address self = address(this);

        
        require(
            account == msg.sender || perpetualContract.hasAccountPermissions(account, msg.sender),
            "msg.sender cannot operate the account"
        );

        
        perpetualContract.withdraw(
            account,
            exchangeWrapper,
            tokenFromAmount
        );

        
        I_ExchangeWrapper exchangeWrapperContract = I_ExchangeWrapper(exchangeWrapper);
        uint256 tokenToAmount = exchangeWrapperContract.exchange(
            msg.sender,
            self,
            tokenTo,
            tokenFrom,
            tokenFromAmount,
            data
        );

        
        IERC20(tokenTo).safeTransferFrom(
            exchangeWrapper,
            destination,
            tokenToAmount
        );

        
        emit LogConvertedWithdrawal(
            account,
            destination,
            perpetual,
            exchangeWrapper,
            tokenFrom,
            tokenTo,
            tokenFromAmount,
            tokenToAmount
        );

        return tokenToAmount;
    }
}