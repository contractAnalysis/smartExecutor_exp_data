pragma solidity 0.5.7;


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

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = _msgSender();
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

contract COLToken is Ownable, ERC20 {
    using SafeMath for uint256;

    string public constant name    = "COL";
    string public constant symbol  = "COL";
    uint8 public constant decimals = 18;

    
    uint256 public constant teamSupply     =  40000000000; 
    uint256 public constant lockDropSupply =  20000000000; 
    uint256 public constant stakingSupply  = 140000000000; 

    LockDrop public lockDropContract;
    address public teamMultisig;
    address public stakingMultisig;

    constructor(address teamMultisig_, address stakingMultisig_) public {
        teamMultisig = teamMultisig_;
        stakingMultisig = stakingMultisig_;

        _mint(teamMultisig, teamSupply * 10**uint256(decimals));
        _mint(stakingMultisig, stakingSupply * 10**uint256(decimals));
    }

    function beginLockDrop() external onlyOwner {
        require(address(lockDropContract) == address(0), "Can't do 2 lock drops");
        lockDropContract = new LockDrop(COLToken(this), lockDropSupply * 10**uint256(decimals));
        _mint(address(lockDropContract), lockDropSupply * 10**uint256(decimals));
    }
}

contract LockDrop {
    using SafeMath for uint256;

    uint256 public lockDeadline;
    uint256 public dropStartTimeStamp;
    uint256 totalAmountOfTokenDrop;
    uint256 totalLockedWei;

    COLToken lockingToken;

    struct LockerInfo {
        uint256 lockedAmount;
        uint256 lockTimestamp;
    }
    mapping (address => LockerInfo) public locks;

    event NewLock(address who, uint256 amount);
    event ClaimedETH(address who, uint256 amount);

    constructor(COLToken token, uint256 dropCap) public {
        lockingToken = token;
        totalAmountOfTokenDrop = dropCap;

        lockDeadline = now + 7 days;
        dropStartTimeStamp = lockDeadline + 7 days;
    }

    function lock() external payable {
        require(now < lockDeadline, "Locking action period is expired");
        require(msg.value > 0, "You should stake gt 0 amount of ETH");

        if (locks[msg.sender].lockTimestamp == 0) {
            locks[msg.sender].lockTimestamp = now;
        }
        locks[msg.sender].lockedAmount = locks[msg.sender].lockedAmount.add(msg.value);
        totalLockedWei = totalLockedWei.add(msg.value);

        emit NewLock(msg.sender, msg.value);
    }

    function claim(uint256 amount) external {
        require(hasAmountToClaim(msg.sender), "You don't have ETH or tokens to claim");

        if (now < dropStartTimeStamp) {
            claimETH(msg.sender, amount);
        } else {
            claimTokensAndETH(msg.sender);
        }
    }

    function hasAmountToClaim(address claimer) internal view returns (bool) {
        if (locks[claimer].lockedAmount == 0) {
            return false;
        }
        return true;
    }

    function claimETH(address payable claimer, uint256 amount) internal {
        require(amount > 0, "Claiming amount should be gt 0");

        
        LockerInfo storage lI = locks[claimer];
        if (now >= lI.lockTimestamp + 7 days) {
            lI.lockedAmount = lI.lockedAmount.sub(amount, "Locked less then wanted to be claimed");
            totalLockedWei = totalLockedWei.sub(amount);

            claimer.transfer(amount);

            emit ClaimedETH(claimer, amount);
        } else {
            revert("Lock period hasn't expired yet");
        }
    }

    function claimTokensAndETH(address payable claimer) internal {
        
        LockerInfo storage lI = locks[claimer];
        uint256 tokensForClaimer = totalAmountOfTokenDrop.mul(lI.lockedAmount).div(totalLockedWei);
        uint256 ETHForClaimer = lI.lockedAmount;
        lI.lockedAmount = 0;

        require(lockingToken.transfer(claimer, tokensForClaimer), "Token transfer failed");
        claimer.transfer(ETHForClaimer);

        emit ClaimedETH(claimer, ETHForClaimer);
    }
}