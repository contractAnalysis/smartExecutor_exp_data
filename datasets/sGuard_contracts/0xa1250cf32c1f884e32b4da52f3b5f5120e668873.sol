pragma solidity 0.5.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
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
    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
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

contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}

contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

interface IERC20 {
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}

interface IUniswapV2Pair {
    function token0() external pure returns (address);

    function token1() external pure returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

    
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    
    function skim(address to) external;
}

interface IUniswapV2ZapIn {
    function ZapIn(
        address _toWhomToIssue,
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount,
        uint256 _minPoolTokens
    ) external payable returns (uint256);
}

interface IUniswapV2ZapOut {
    function ZapOut(
        address _ToTokenContractAddress,
        address _FromUniPoolAddress,
        uint256 _IncomingLP,
        uint256 _minTokensRec
    ) external payable returns (uint256);
}

interface IBalancerZapInGen {
    function EasyZapIn(
        address _FromTokenContractAddress,
        address _ToBalancerPoolAddress,
        uint256 _amount,
        uint256 _minPoolTokens
    ) external payable returns (uint256 tokensBought);
}

interface IBalancerUnZap {
    function EasyZapOut(
        address _ToTokenContractAddress,
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT,
        uint256 _minTokensRec
    ) external payable returns (uint256);
}

interface IBPool {
    function isBound(address t) external view returns (bool);
}

contract Balancer_UniswapV2_Pipe_V1_2 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    bool public stopped = false;
    
    IUniswapV2Factory private constant UniSwapV2FactoryAddress = IUniswapV2Factory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );
    
    IBalancerUnZap public balancerZapOut;
    IUniswapV2ZapIn public uniswapV2ZapIn;
    IBalancerZapInGen public balancerZapIn;
    IUniswapV2ZapOut public uniswapV2ZapOut;
    
    constructor (
        address _balancerZapIn,
        address _balancerZapOut,
        address _uniswapV2ZapIn,
        address _uniswapV2ZapOut
    ) public {
        balancerZapOut = IBalancerUnZap(_balancerZapOut);
        uniswapV2ZapIn = IUniswapV2ZapIn(_uniswapV2ZapIn);
        balancerZapIn = IBalancerZapInGen(_balancerZapIn);
        uniswapV2ZapOut = IUniswapV2ZapOut(_uniswapV2ZapOut);
    }
    
    
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function PipeBalancerUniV2(
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT,
        address _toUniswapPoolAddress,
        address _toWhomToIssue,
        uint256 _minUniV2Tokens
    ) public nonReentrant stopInEmergency returns(uint256){
        
        IERC20(_FromBalancerPoolAddress).transferFrom(
            msg.sender,
            address(this),
            _IncomingBPT
        );
        
        IERC20(_FromBalancerPoolAddress).approve(
            address(balancerZapOut),
            _IncomingBPT
        );
        
        
        address token0 = IUniswapV2Pair(_toUniswapPoolAddress).token0();
        address token1 = IUniswapV2Pair(_toUniswapPoolAddress).token1();

        address zapOutToToken = address(0);
        if(IBPool(_FromBalancerPoolAddress).isBound(token0)) {
            zapOutToToken=token0;
        } else if(IBPool(_FromBalancerPoolAddress).isBound(token1)) {
            zapOutToToken=token1;
        }

        
        uint zappedOutAmt = balancerZapOut.EasyZapOut(
            zapOutToToken,
            _FromBalancerPoolAddress,
            _IncomingBPT,
            0
        );
        
        uint LPTBought;
        if(zapOutToToken == address(0)) {
            
            LPTBought = uniswapV2ZapIn.ZapIn.value(zappedOutAmt)(
                _toWhomToIssue,
                address(0),
                token0,
                token1,
                0,
                _minUniV2Tokens
            );
        } else {
            IERC20(zapOutToToken).approve(
                address(uniswapV2ZapIn),
                IERC20(zapOutToToken).balanceOf(address(this))
            );
            LPTBought = uniswapV2ZapIn.ZapIn.value(0)(
                _toWhomToIssue,
                zapOutToToken,
                token0,
                token1,
                zappedOutAmt,
                _minUniV2Tokens
            );
        }

        return LPTBought;
    }

    function PipeUniV2Balancer(
        address _FromUniswapPoolAddress,
        uint256 _IncomingLPT,
        address _ToBalancerPoolAddress,
        address _toWhomToIssue,
        uint256 _minBPTokens
    ) public nonReentrant stopInEmergency returns(uint256){
        
        
        IERC20(_FromUniswapPoolAddress).transferFrom(
            msg.sender,
            address(this),
            _IncomingLPT
        ); 
        
        
        IERC20(_FromUniswapPoolAddress).approve(
            address(uniswapV2ZapOut),
            _IncomingLPT
        );
        
        
        address token0 = IUniswapV2Pair(_FromUniswapPoolAddress).token0();
        address token1 = IUniswapV2Pair(_FromUniswapPoolAddress).token1();
        
        address zapOutToToken = address(0);
        if(IBPool(_ToBalancerPoolAddress).isBound(token0)) {
            zapOutToToken=token0;
        } else if(IBPool(_ToBalancerPoolAddress).isBound(token1)) {
            zapOutToToken=token1;
        }
        
        
        uint tokensRec = uniswapV2ZapOut.ZapOut(
            zapOutToToken,
            _FromUniswapPoolAddress,
            _IncomingLPT,
            0
        );
        
        
        uint BPTBought;
        if(zapOutToToken == address(0)) {
            
            BPTBought = balancerZapIn.EasyZapIn.value(tokensRec)(
                address(0),
                _ToBalancerPoolAddress,
                0,
                _minBPTokens
            );
        } else {
            IERC20(zapOutToToken).approve(
                address(balancerZapIn),
                tokensRec
            );
            BPTBought = balancerZapIn.EasyZapIn.value(0)(
                zapOutToToken,
                _ToBalancerPoolAddress,
                tokensRec,
                _minBPTokens
            );
        }
        
        IERC20(_ToBalancerPoolAddress).transfer(
            _toWhomToIssue,
            BPTBought
        );
        
        return BPTBought;
    }
    
    
    
    function() external payable {}
    
    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner(), qty);
    }

    
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

}