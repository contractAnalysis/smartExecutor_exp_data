pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;



contract WETH9 {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() external payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}




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




contract P1Proxy {
    using SafeERC20 for IERC20;

    
    function approveMaximumOnPerpetual(
        address perpetual
    )
        external
    {
        IERC20 tokenContract = IERC20(I_PerpetualV1(perpetual).getTokenContract());

        
        tokenContract.safeApprove(perpetual, 0);

        
        tokenContract.safeApprove(perpetual, uint256(-1));
    }
}




contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = uint256(int256(-1));

    uint256 private _STATUS_;

    constructor () internal {
        _STATUS_ = NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_STATUS_ != ENTERED, "ReentrancyGuard: reentrant call");
        _STATUS_ = ENTERED;
        _;
        _STATUS_ = NOT_ENTERED;
    }
}




contract P1WethProxy is
    P1Proxy,
    ReentrancyGuard
{
    

    WETH9 public _WETH_;

    

    constructor (
        address payable weth
    )
        public
    {
        _WETH_ = WETH9(weth);
    }

    

    
    function ()
        external
        payable
    {
        require(
            msg.sender == address(_WETH_),
            "Cannot receive ETH"
        );
    }

    
    function depositEth(
        address perpetual,
        address account
    )
        external
        payable
        nonReentrant
    {
        WETH9 weth = _WETH_;
        address marginToken = I_PerpetualV1(perpetual).getTokenContract();
        require(
            marginToken == address(weth),
            "The perpetual does not use WETH for margin deposits"
        );

        
        weth.deposit.value(msg.value)();

        
        uint256 amount = weth.balanceOf(address(this));
        I_PerpetualV1(perpetual).deposit(account, amount);
    }

    
    function withdrawEth(
        address perpetual,
        address account,
        address payable destination,
        uint256 amount
    )
        external
        nonReentrant
    {
        WETH9 weth = _WETH_;
        address marginToken = I_PerpetualV1(perpetual).getTokenContract();
        require(
            marginToken == address(weth),
            "The perpetual does not use WETH for margin deposits"
        );

        require(
            
            msg.sender == account ||
                I_PerpetualV1(perpetual).hasAccountPermissions(account, msg.sender),
            "Sender does not have withdraw permissions for the account"
        );

        
        I_PerpetualV1(perpetual).withdraw(account, address(this), amount);

        
        uint256 balance = weth.balanceOf(address(this));
        weth.withdraw(balance);
        destination.transfer(balance);
    }
}