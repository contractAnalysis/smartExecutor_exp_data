pragma solidity 0.5.17;

contract Context { 
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

library SafeMath { 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }
}

library Address { 
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

interface IERC20 { 
    function balanceOf(address who) external view returns (uint256);
    
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

library SafeERC20 { 
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   function _callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: erc20 operation did not succeed");
        }
    }
}

interface IWETH { 
    function deposit() payable external;
    function transfer(address dst, uint wad) external returns (bool);
}

contract LexLocker is Context { 
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    
    address public judgeAccessToken;
    address public judgmentRewardToken;
    address payable public lexDAO;
    uint256 public judgeAccessBalance;
    uint256 public judgmentRate;
    uint256 public judgmentReward;

    
    address private locker = address(this);
    address public wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; 
    uint256 public lockerIndex;
    bytes32 public lexStamp;
    mapping(uint256 => Deposit) public deposits; 

    struct Deposit {  
        address client; 
        address provider;
        address token;
        uint8 locked;
        uint256 amount;
        uint256 cap;
        uint256 judgmentRate;
        uint256 released;
        uint256 termination;
        bytes32 details; 
    }
    	
    event DepositToken(address indexed client, address indexed provider, uint256 indexed index);  
    event Release(uint256 indexed index, uint256 indexed milestone); 
    event Withdraw(uint256 indexed index, uint256 indexed remainder);
    event Lock(address indexed sender, uint256 indexed index, bytes32 indexed details);
    event Resolve(address indexed resolver, uint256 indexed clientAward, uint256 indexed providerAward, uint256 index, bytes32 details); 
    event PayLexDAO(address indexed sender, uint256 indexed payment, bytes32 indexed details);
    event UpdateGovernance(address indexed _judgeAccessToken, address indexed _judgmentRewardToken, address indexed _lexDAO, uint256 _judgeAccessBalance, uint256 _judgmentRate, uint256 _judgmentReward, bytes32 _lexStamp);
    
    constructor(
        address _judgeAccessToken, 
        address _judgmentRewardToken, 
        address payable _lexDAO, 
        uint256 _judgeAccessBalance, 
        uint256 _judgmentRate,
        uint256 _judgmentReward,
        bytes32 _lexStamp) public { 
        judgeAccessToken = _judgeAccessToken;
        judgmentRewardToken = _judgmentRewardToken;
        lexDAO = _lexDAO;
        judgeAccessBalance = _judgeAccessBalance;
        judgmentRate = _judgmentRate;
        judgmentReward = _judgmentReward;
        lexStamp = _lexStamp;
    } 
    
    
    function depositToken( 
        address provider,
        address token,
        uint256 amount, 
        uint256 cap,
        uint256 milestones,
        uint256 termination,
        bytes32 details) payable external {
        require(amount.mul(milestones) == cap, "deposit milestones mismatch");
        
        if (token == wETH && msg.value > 0) {
            require(msg.value == cap, "insufficient ETH");
            IWETH(wETH).deposit();
            (bool success, ) = wETH.call.value(msg.value)("");
            require(success, "transfer failed");
            IWETH(wETH).transfer(locker, msg.value);
        } else {
            IERC20(token).safeTransferFrom(msg.sender, locker, cap);
        }

        uint256 index = lockerIndex+1;
        lockerIndex = lockerIndex+1;
        
        deposits[index] = Deposit( 
            _msgSender(), 
            provider,
            token,
            0,
            amount,
            cap,
            judgmentRate,
            0,
            termination,
            details);
        
        emit DepositToken(_msgSender(), provider, lockerIndex); 
    }

    function release(uint256 index) external { 
    	Deposit storage deposit = deposits[index];
	    
	    require(deposit.locked == 0, "deposit locked");
	    require(deposit.cap > deposit.released, "deposit released");
    	require(_msgSender() == deposit.client, "not deposit client"); 
        
        uint256 milestone = deposit.amount;  
        
        IERC20(deposit.token).safeTransfer(deposit.provider, milestone);
        
        deposit.released = deposit.released.add(milestone);
        
	    emit Release(index, milestone); 
    }
    
    function withdraw(uint256 index) external { 
    	Deposit storage deposit = deposits[index];
        
        require(deposit.locked == 0, "deposit locked");
        require(deposit.cap > deposit.released, "deposit released");
        require(now > deposit.termination, "termination time pending");
        
        uint256 remainder = deposit.cap.sub(deposit.released); 
        
        IERC20(deposit.token).safeTransfer(deposit.client, remainder);
        
        deposit.released = deposit.released.add(remainder); 
        
	    emit Withdraw(index, remainder); 
    }
    
    
    function lock(uint256 index, bytes32 details) external { 
        Deposit storage deposit = deposits[index]; 
        
        require(deposit.cap > deposit.released, "deposit released");
        require(now < deposit.termination, "termination time passed"); 
        require(_msgSender() == deposit.client || _msgSender() == deposit.provider, "not deposit party"); 
        
	    deposit.locked = 1; 
	    
	    emit Lock(_msgSender(), index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256 providerAward, bytes32 details) external { 
        Deposit storage deposit = deposits[index];
        
        uint256 remainder = deposit.cap.sub(deposit.released); 
	    uint256 resolutionFee = remainder.div(deposit.judgmentRate); 
	    
	    require(deposit.locked == 1, "deposit not locked"); 
	    require(deposit.cap > deposit.released, "cap released");
	    require(_msgSender() != deposit.client, "cannot be deposit party");
	    require(_msgSender() != deposit.provider, "cannot be deposit party");
	    require(clientAward.add(providerAward) == remainder.sub(resolutionFee), "resolution must match deposit"); 
	    require(IERC20(judgeAccessToken).balanceOf(_msgSender()) >= judgeAccessBalance, "judgeAccessToken insufficient");
        
        IERC20(deposit.token).safeTransfer(lexDAO, resolutionFee);
        IERC20(deposit.token).safeTransfer(deposit.client, clientAward);
        IERC20(deposit.token).safeTransfer(deposit.provider, providerAward);
	    IERC20(judgmentRewardToken).safeTransfer(_msgSender(), judgmentReward);
	    
	    deposit.released = deposit.released.add(remainder); 
	    
	    emit Resolve(_msgSender(), clientAward, providerAward, index, details);
    }
    
    
    function payLexDAO(bytes32 details) payable external { 
        (bool success, ) = lexDAO.call.value(msg.value)("");
        require(success, "transfer failed");
        
        emit PayLexDAO(_msgSender(), msg.value, details);
    }
    
    function updateGovernance(
        address _judgeAccessToken, 
        address _judgmentRewardToken,
        address payable _lexDAO,
        uint256 _judgeAccessBalance, 
        uint256 _judgmentRate, 
        uint256 _judgmentReward,
        bytes32 _lexStamp) external {
        require(_msgSender() == lexDAO, "caller not lexDAO");
        
        judgeAccessToken = _judgeAccessToken; 
        judgmentRewardToken = _judgmentRewardToken;
        lexDAO = _lexDAO;
        judgeAccessBalance = _judgeAccessBalance; 
        judgmentRate = _judgmentRate; 
        judgmentReward = _judgmentReward;
        lexStamp = _lexStamp;
        
        emit UpdateGovernance(_judgeAccessToken, _judgmentRewardToken, _lexDAO, _judgeAccessBalance, _judgmentRate, _judgmentReward, _lexStamp);
    }
}