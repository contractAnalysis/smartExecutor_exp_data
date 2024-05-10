pragma solidity ^0.6.0;








contract Context {
    constructor () internal { }
    
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    
    function _msgData() internal view virtual returns (bytes memory) {
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








abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
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








contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal virtual {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}








library ExtendedMath {
    
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {
        if(a > b) return b;
        return a;
    }
}

contract Units is ERC20, ERC20Detailed {
    using SafeMath for uint;
    using ExtendedMath for uint;
    
    address public lastRewardTo;
    uint public lastRewardAmount;
    uint public lastRewardEthBlockNumber;
    
    uint public miningTarget;
    bytes32 public challengeNumber;
    
    uint public latestDifficultyPeriodStarted;
    uint public epochCount;
    uint public rewardEra;
    uint public currentMonthlyRate;
    
    uint[4] public bonusEraMonthlyRate;
    uint[4] public bonusEraLengthInMonths;
    uint[4] public maxSupplyForBonusEra;
    uint public lastBonusEra;
    uint public standardEraMonthlyRate;
    
    uint public _BLOCKS_PER_READJUSTMENT = 1024;
    uint public _MINIMUM_TARGET = 2**16; 
    uint public _MAXIMUM_TARGET = 2**255; 
    
    
    bool locked = false;
    mapping(bytes32 => bytes32) solutionForChallenge; 
    
    
    
    
    
    
    
    constructor() ERC20Detailed("Units", "UNTS", 18) public {
        if(locked) revert();
        locked = true;
        
        
        bonusEraMonthlyRate = [7111*10**4 * 10**uint(decimals()),
                               3556*10**4 * 10**uint(decimals()),
                               1778*10**4 * 10**uint(decimals()),
                               8889*10**3 * 10**uint(decimals())];
                               
        maxSupplyForBonusEra = [6133*10**5 * 10**uint(decimals()),
                                7200*10**5 * 10**uint(decimals()),
                                7733*10**5 * 10**uint(decimals()),
                                8000*10**5 * 10**uint(decimals())];
        
        standardEraMonthlyRate = 8889*10**2 * 10**uint(decimals());
        
        
        assert(bonusEraMonthlyRate.length == maxSupplyForBonusEra.length);
        
        
        rewardEra = 0;
        epochCount = 0;
        currentMonthlyRate = bonusEraMonthlyRate[rewardEra];
        miningTarget = _MAXIMUM_TARGET;
        latestDifficultyPeriodStarted = block.number;
        
        
        _startNewMiningEpoch();
    }
    
    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) {
        bytes32 digest = keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce));
        
        
        if (digest != challenge_digest) revert();
        
        if(uint256(digest) > miningTarget) revert();
        
        
        bytes32 solution = solutionForChallenge[challengeNumber];
        if(solution != 0x0) revert();
        
        solutionForChallenge[challengeNumber] = digest;
        
        
        uint reward_amount = getMiningReward();
        _mint(msg.sender, reward_amount);
        
        
        lastRewardTo = msg.sender;
        lastRewardAmount = reward_amount;
        lastRewardEthBlockNumber = block.number;
        
        
        _startNewMiningEpoch();
        
        return true;
    }
    
    function _startNewMiningEpoch() internal {
        
        if (rewardEra < bonusEraMonthlyRate.length) {
            
            if (totalSupply() >= maxSupplyForBonusEra[rewardEra]) {
                rewardEra = rewardEra + 1;
            }
            
            
            if (rewardEra < bonusEraMonthlyRate.length) {
                currentMonthlyRate = bonusEraMonthlyRate[rewardEra];
            } else {
                currentMonthlyRate = standardEraMonthlyRate;
            }
        }
        
        
        epochCount = epochCount.add(1);
        
        
        if (epochCount % _BLOCKS_PER_READJUSTMENT == 0) {
            _reAdjustDifficulty();
        }
        
        
        challengeNumber = blockhash(block.number - 1);
    }
        
    function _reAdjustDifficulty() internal {
        
        uint blocks_per_readjustment = _BLOCKS_PER_READJUSTMENT;
        uint targetEthBlocksPerDiffPeriod = blocks_per_readjustment.mul(2); 
        
        
        uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
        
        if (ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod) { 
            uint excess_block_pct = ((targetEthBlocksPerDiffPeriod.mul(100)).div(ethBlocksSinceLastDifficultyPeriod)).sub(100);
            uint excess_block_pct_extra = excess_block_pct.limitLessThan(1000); 
            
            miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra)); 
        } else { 
            uint shortage_block_pct = ethBlocksSinceLastDifficultyPeriod.mul(100).div(targetEthBlocksPerDiffPeriod);
            uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000);
            
            miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra)); 
        }
        
        latestDifficultyPeriodStarted = block.number;
        
        if(miningTarget < _MINIMUM_TARGET) {
            miningTarget = _MINIMUM_TARGET;
        }
        
        if(miningTarget < _MAXIMUM_TARGET) {
            miningTarget = _MAXIMUM_TARGET;
        }
    }
    
    function getChallengeNumber() public view returns (bytes32) {
        return challengeNumber;
    }
    
    function getMiningDifficulty() public view returns (uint) {
        return _MAXIMUM_TARGET.div(miningTarget);
    }
    
    function getMiningTarget() public view returns (uint) {
        return miningTarget;
    }
    
    function getMiningReward() public view returns (uint) {
        if(totalSupply() == 0) {
            return 4*10**8 * 10**uint(decimals());
        } else {
            uint award_per_block = currentMonthlyRate.div(2628*10**3).mul(20); 
            return award_per_block;
        }
    }
    
    function getRewardEra() public view returns (uint){
        return rewardEra;
    }
    
    function getCurrentMonthlyRate() public view returns (uint) {
        return currentMonthlyRate;
    }
    
    function getEpochCount() public view returns (uint) {
        return epochCount;
    }
    
    function getLatestDifficultyPeriodStarted() public view returns (uint) {
        return latestDifficultyPeriodStarted;
    }
    
    
    function getMintDigest(uint256 challenge_number, bytes32 nonce) public view returns (bytes32 digesttest) {
        bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
        return digest;
    }
}