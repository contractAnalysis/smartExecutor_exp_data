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

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract LexLocker is Context { 
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    
    address public judge;
    address public judgment;
    address payable public lexDAO;
    uint256 public judgeBalance;
    uint256 public judgmentReward;

    
    address private locker = address(this);
    uint8 public version = 1;
    uint256 public depositFee;
    uint256 public lxl; 
    string public emoji = "⚖️🔐⚔️";
    mapping (uint256 => Deposit) public deposit; 

    struct Deposit {  
        address client; 
        address provider;
        address token;
        uint256 amount;
        uint256 index;
        uint256 termination;
        string details; 
        bool locked; 
        bool released;
    }
    	
    
    event LexDAOpaid(address indexed sender, uint256 indexed payment, string indexed details);
    event Locked(address indexed sender, uint256 indexed index, string indexed details);
    event Registered(address indexed client, address indexed provider, uint256 indexed index);  
    event Released(uint256 indexed index); 
    event Resolved(address indexed resolver, uint256 indexed index, string indexed details); 
    
    constructor (
        address _judge, 
        address _judgment, 
        address payable _lexDAO, 
        uint256 _depositFee, 
        uint256 _judgeBalance, 
        uint256 _judgmentReward) public { 
        judge = _judge;
        judgment = _judgment;
        lexDAO = _lexDAO;
        depositFee = _depositFee;
        judgeBalance = _judgeBalance;
        judgmentReward = _judgmentReward;
    } 
    
    
    function depositToken( 
        address provider,
        address token,
        uint256 amount, 
        uint256 termination,
        string memory details) payable public {
        require(termination >= now, "termination set before deploy");
        require(msg.value == depositFee, "deposit fee not attached");

        uint256 index = lxl.add(1); 
	    lxl = lxl.add(1);
                
            deposit[index] = Deposit( 
                _msgSender(), 
                provider,
                token,
                amount,
                index,
                termination,
                details, 
                false, 
                false);
        
        lexDAO.transfer(msg.value); 
        IERC20(token).safeTransferFrom(_msgSender(), locker, amount); 
        
        emit Registered(_msgSender(), provider, index); 
    }

    function release(uint256 index) public { 
    	Deposit storage depos = deposit[index];
	    
	    require(depos.locked == false, "deposit already locked"); 
	    require(depos.released == false, "deposit already released"); 
    	require(_msgSender() == depos.client, "caller not deposit client"); 

        IERC20(depos.token).safeTransfer(depos.provider, depos.amount);
        
        depos.released = true; 
        
	    emit Released(index); 
    }
    
    function withdraw(uint256 index) public { 
    	Deposit storage depos = deposit[index];
        
        require(depos.locked == false, "deposit already locked"); 
        require(depos.released == false, "deposit already released"); 
    	require(now >= depos.termination, "deposit time not terminated");
        
        IERC20(depos.token).safeTransfer(depos.client, depos.amount);
        
        depos.released = true; 
        
	    emit Released(index); 
    }
    
    
    function lock(uint256 index, string memory details) public { 
        Deposit storage depos = deposit[index]; 
        
        require(depos.released == false, "deposit already released"); 
        require(now <= depos.termination, "deposit time already terminated"); 
        require(_msgSender() == depos.client || _msgSender() == depos.provider, "caller not deposit party"); 

	    depos.locked = true; 
	    
	    emit Locked(_msgSender(), index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256 providerAward, string memory details) public { 
        Deposit storage depos = deposit[index];
	    
	    require(depos.locked == true, "deposit not locked"); 
	    require(depos.released == false, "deposit already released");
	    require(_msgSender() != depos.client, "resolver cannot be deposit party");
	    require(_msgSender() != depos.provider, "resolver cannot be deposit party");
	    require(clientAward.add(providerAward) == depos.amount, "resolution awards must equal deposit amount");
	    require(IERC20(judge).balanceOf(_msgSender()) >= judgeBalance, "judge token balance insufficient to resolve");
        
        IERC20(depos.token).safeTransfer(depos.client, clientAward);
        IERC20(depos.token).safeTransfer(depos.provider, providerAward);

	    depos.released = true; 
	    
	    IERC20(judgment).safeTransfer(_msgSender(), judgmentReward);
	    
	    emit Resolved(_msgSender(), index, details);
    }
    
    
    modifier onlyLexDAO () {
        require(_msgSender() == lexDAO, "caller not lexDAO");
        _;
    }
    
    function payLexDAO(string memory details) payable public { 
        lexDAO.transfer(msg.value);
        emit LexDAOpaid(_msgSender(), msg.value, details);
    }
    
    function updateDepositFee(uint256 _depositFee) public onlyLexDAO {
        depositFee = _depositFee;
    }
    
    function updateJudge(address _judge) public onlyLexDAO { 
        judge = _judge;
    }
    
    function updateJudgeBalance(uint256 _judgeBalance) public onlyLexDAO {
        judgeBalance = _judgeBalance;
    }
    
    function updateJudgment(address _judgment) public onlyLexDAO { 
        judgment = _judgment;
    }
    
    function updateJudgmentReward(uint256 _judgmentReward) public onlyLexDAO {
        judgmentReward = _judgmentReward;
    }

    function updateLexDAO(address payable _lexDAO) public onlyLexDAO {
        lexDAO = _lexDAO;
    }
}