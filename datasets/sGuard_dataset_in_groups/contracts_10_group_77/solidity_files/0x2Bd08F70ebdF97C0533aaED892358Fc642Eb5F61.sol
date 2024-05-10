pragma solidity ^0.5.0;


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



pragma solidity ^0.5.0;


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



pragma solidity 0.5.0;


contract IStaking {
    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    function stake(uint256 amount, bytes calldata data) external;
    function stakeFor(address user, uint256 amount, bytes calldata data) external;
    function unstake(uint256 amount, bytes calldata data) external;
    function totalStakedFor(address addr) public view returns (uint256);
    function totalStaked() public view returns (uint256);
    function token() external view returns (address);

    
    function supportsHistory() external pure returns (bool) {
        return false;
    }
}



pragma solidity 0.5.0;




contract TokenPool is Ownable {
    IERC20 public token;

    constructor(IERC20 _token) public {
        token = _token;
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function transfer(address to, uint256 value) external onlyOwner returns (bool) {
        return token.transfer(to, value);
    }
}



pragma solidity 0.5.0;




contract MinePool is Ownable {
    IERC20 public shareToken;
    IERC20 public dollarToken;

    constructor(IERC20 _shareToken, IERC20 _dollarToken) public {
        shareToken = _shareToken;
        dollarToken = _dollarToken;
    }

    function shareBalance() public view returns (uint256) {
        return shareToken.balanceOf(address(this));
    }

    function shareTransfer(address to, uint256 value) external onlyOwner returns (bool) {
        return shareToken.transfer(to, value);
    }

    function dollarBalance() public view returns (uint256) {
        return dollarToken.balanceOf(address(this));
    }

    function dollarTransfer(address to, uint256 value) external onlyOwner returns (bool) {
        return dollarToken.transfer(to, value);
    }
}



pragma solidity 0.5.0;








contract SeigniorageMining is IStaking, Ownable {
    using SafeMath for uint256;

    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);
    
    event TokensClaimed(address indexed user, uint256 amount);
    event DollarsClaimed(address indexed user, uint256 amount);

    event TokensLocked(uint256 amount, uint256 durationSec, uint256 total);
    
    event TokensUnlocked(uint256 amount, uint256 total);
    event DollarsUnlocked(uint256 amount, uint256 total);

    TokenPool private _stakingPool;
    MinePool private _unlockedPool;
    MinePool private _lockedPool;

    
    
    
    uint256 public totalLockedShares = 0;
    uint256 public totalStakingShares = 0;
    uint256 private _totalStakingShareSeconds = 0;
    uint256 private _lastAccountingTimestampSec = now;
    uint256 private _maxUnlockSchedules = 0;
    uint256 private _initialSharesPerToken = 0;

    
    
    
    
    struct Stake {
        uint256 stakingShares;
        uint256 timestampSec;
    }

    
    
    struct UserTotals {
        uint256 stakingShares;
        uint256 stakingShareSeconds;
        uint256 lastAccountingTimestampSec;
    }

    
    mapping(address => UserTotals) private _userTotals;

    
    mapping(address => Stake[]) private _userStakes;

    
    
    
    struct UnlockSchedule {
        uint256 initialLockedShares;
        uint256 unlockedShares;
        uint256 lastUnlockTimestampSec;
        uint256 startAtSec;
        uint256 endAtSec;
        uint256 durationSec;
    }

    UnlockSchedule[] public unlockSchedules;

    
    constructor(IERC20 stakingToken, IERC20 shareToken, IERC20 dollarToken, uint256 maxUnlockSchedules,
            uint256 initialSharesPerToken) public {
        require(initialSharesPerToken > 0, 'SeigniorageMining: initialSharesPerToken is zero');

        _stakingPool = new TokenPool(stakingToken);
        _unlockedPool = new MinePool(shareToken, dollarToken);
        _lockedPool = new MinePool(shareToken, dollarToken);
        _maxUnlockSchedules = maxUnlockSchedules;
        _initialSharesPerToken = initialSharesPerToken;
    }

    
    function getStakingToken() public view returns (IERC20) {
        return _stakingPool.token();
    }

    
    function getDistributionToken() public view returns (IERC20) {
        assert(_unlockedPool.shareToken() == _lockedPool.shareToken());
        return _unlockedPool.shareToken();
    }

    
    function stake(uint256 amount, bytes calldata data) external {
        _stakeFor(msg.sender, msg.sender, amount);
    }

    
    function stakeFor(address user, uint256 amount, bytes calldata data) external {
        _stakeFor(msg.sender, user, amount);
    }

    
    function _stakeFor(address staker, address beneficiary, uint256 amount) private {
        require(amount > 0, 'SeigniorageMining: stake amount is zero');
        require(beneficiary != address(0), 'SeigniorageMining: beneficiary is zero address');
        require(totalStakingShares == 0 || totalStaked() > 0,
                'SeigniorageMining: Invalid state. Staking shares exist, but no staking tokens do');

        uint256 mintedStakingShares = (totalStakingShares > 0)
            ? totalStakingShares.mul(amount).div(totalStaked())
            : amount.mul(_initialSharesPerToken);
        require(mintedStakingShares > 0, 'SeigniorageMining: Stake amount is too small');

        updateAccounting();

        
        UserTotals storage totals = _userTotals[beneficiary];
        totals.stakingShares = totals.stakingShares.add(mintedStakingShares);
        totals.lastAccountingTimestampSec = now;

        Stake memory newStake = Stake(mintedStakingShares, now);
        _userStakes[beneficiary].push(newStake);

        
        totalStakingShares = totalStakingShares.add(mintedStakingShares);
        
        

        
        require(_stakingPool.token().transferFrom(staker, address(_stakingPool), amount),
            'SeigniorageMining: transfer into staking pool failed');

        emit Staked(beneficiary, amount, totalStakedFor(beneficiary), "");
    }

    /**
     * @dev Unstakes a certain amount of previously deposited tokens. User also receives their
     * alotted number of distribution tokens.
     * @param amount Number of deposit tokens to unstake / withdraw.
     * @param data Not used.
     */
    function unstake(uint256 amount, bytes calldata data) external {
        _unstake(amount);
    }

    /**
     * @param amount Number of deposit tokens to unstake / withdraw.
     * @return The total number of distribution tokens that would be rewarded.
     */
    function unstakeQuery(uint256 amount) public returns (uint256, uint256) {
        return _unstake(amount);
    }

    /**
     * @dev Unstakes a certain amount of previously deposited tokens. User also receives their
     * alotted number of distribution tokens.
     * @param amount Number of deposit tokens to unstake / withdraw.
     * @return The total number of distribution tokens rewarded.
     */
    function _unstake(uint256 amount) private returns (uint256, uint256) {
        updateAccounting();

        // checks
        require(amount > 0, 'SeigniorageMining: unstake amount is zero');
        require(totalStakedFor(msg.sender) >= amount,
            'SeigniorageMining: unstake amount is greater than total user stakes');
        uint256 stakingSharesToBurn = totalStakingShares.mul(amount).div(totalStaked());
        require(stakingSharesToBurn > 0, 'SeigniorageMining: Unable to unstake amount this small');

        // 1. User Accounting
        UserTotals storage totals = _userTotals[msg.sender];
        Stake[] storage accountStakes = _userStakes[msg.sender];

        // Redeem from most recent stake and go backwards in time.
        uint256 stakingShareSecondsToBurn = 0;
        uint256 sharesLeftToBurn = stakingSharesToBurn;
        uint256 rewardAmount = 0;
        uint256 rewardDollarAmount = 0;
        while (sharesLeftToBurn > 0) {
            Stake storage lastStake = accountStakes[accountStakes.length - 1];
            uint256 stakeTimeSec = now.sub(lastStake.timestampSec);
            uint256 newStakingShareSecondsToBurn = 0;
            if (lastStake.stakingShares <= sharesLeftToBurn) {
                // fully redeem a past stake
                newStakingShareSecondsToBurn = lastStake.stakingShares.mul(stakeTimeSec);
                rewardAmount = computeNewReward(rewardAmount, newStakingShareSecondsToBurn);
                rewardDollarAmount = computeNewDollarReward(rewardDollarAmount, newStakingShareSecondsToBurn);
                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(newStakingShareSecondsToBurn);
                sharesLeftToBurn = sharesLeftToBurn.sub(lastStake.stakingShares);
                accountStakes.length--;
            } else {
                // partially redeem a past stake
                newStakingShareSecondsToBurn = sharesLeftToBurn.mul(stakeTimeSec);
                rewardAmount = computeNewReward(rewardAmount, newStakingShareSecondsToBurn);
                rewardDollarAmount = computeNewDollarReward(rewardDollarAmount, newStakingShareSecondsToBurn);
                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(newStakingShareSecondsToBurn);
                lastStake.stakingShares = lastStake.stakingShares.sub(sharesLeftToBurn);
                sharesLeftToBurn = 0;
            }
        }
        totals.stakingShareSeconds = totals.stakingShareSeconds.sub(stakingShareSecondsToBurn);
        totals.stakingShares = totals.stakingShares.sub(stakingSharesToBurn);
        // Already set in updateAccounting
        // totals.lastAccountingTimestampSec = now;

        // 2. Global Accounting
        _totalStakingShareSeconds = _totalStakingShareSeconds.sub(stakingShareSecondsToBurn);
        totalStakingShares = totalStakingShares.sub(stakingSharesToBurn);
        // Already set in updateAccounting
        // _lastAccountingTimestampSec = now;

        // interactions
        require(_stakingPool.transfer(msg.sender, amount),
            'SeigniorageMining: transfer out of staking pool failed');
        require(_unlockedPool.shareTransfer(msg.sender, rewardAmount),
            'SeigniorageMining: shareTransfer out of unlocked pool failed');
        require(_unlockedPool.dollarTransfer(msg.sender, rewardDollarAmount),
            'SeigniorageMining: dollarTransfer out of unlocked pool failed');

        emit Unstaked(msg.sender, amount, totalStakedFor(msg.sender), "");
        emit TokensClaimed(msg.sender, rewardAmount);
        emit DollarsClaimed(msg.sender, rewardDollarAmount);

        require(totalStakingShares == 0 || totalStaked() > 0,
                "SeigniorageMining: Error unstaking. Staking shares exist, but no staking tokens do");
        return (rewardAmount, rewardDollarAmount);
    }

    
    function computeNewReward(uint256 currentRewardTokens,
                                uint256 stakingShareSeconds) private view returns (uint256) {

        uint256 newRewardTokens =
            totalUnlocked()
            .mul(stakingShareSeconds)
            .div(_totalStakingShareSeconds);

        return currentRewardTokens.add(newRewardTokens);
    }

    function computeNewDollarReward(uint256 currentRewardTokens,
                                uint256 stakingShareSeconds) private view returns (uint256) {

        uint256 newRewardTokens =
            totalUnlockedDollars()
            .mul(stakingShareSeconds)
            .div(_totalStakingShareSeconds);

        return currentRewardTokens.add(newRewardTokens);
    }

    
    function totalStakedFor(address addr) public view returns (uint256) {
        return totalStakingShares > 0 ?
            totalStaked().mul(_userTotals[addr].stakingShares).div(totalStakingShares) : 0;
    }

    
    function totalStaked() public view returns (uint256) {
        return _stakingPool.balance();
    }

    
    function token() external view returns (address) {
        return address(getStakingToken());
    }

    function totalUserShareRewards(address user) external view returns (uint256) {
        UserTotals storage totals = _userTotals[user];

        return (_totalStakingShareSeconds > 0)
            ? totalUnlocked().mul(totals.stakingShareSeconds).div(_totalStakingShareSeconds)
            : 0;
    }

    function totalUserDollarRewards(address user) external view returns (uint256) {
        UserTotals storage totals = _userTotals[user];

        return (_totalStakingShareSeconds > 0)
            ? totalLockedDollars().mul(totals.stakingShareSeconds).div(_totalStakingShareSeconds)
            : 0;
    }

    function totalUserDollarRewardsFixed(address user) external view returns (uint256) {
        UserTotals storage totals = _userTotals[user];

        return (_totalStakingShareSeconds > 0)
            ? totalUnlockedDollars().mul(totals.stakingShareSeconds).div(_totalStakingShareSeconds)
            : 0;
    }

    
    function updateAccounting() public returns (
        uint256, uint256, uint256, uint256, uint256, uint256, uint256) {

        unlockTokens();

        
        uint256 newStakingShareSeconds =
            now
            .sub(_lastAccountingTimestampSec)
            .mul(totalStakingShares);
        _totalStakingShareSeconds = _totalStakingShareSeconds.add(newStakingShareSeconds);
        _lastAccountingTimestampSec = now;

        
        UserTotals storage totals = _userTotals[msg.sender];
        uint256 newUserStakingShareSeconds =
            now
            .sub(totals.lastAccountingTimestampSec)
            .mul(totals.stakingShares);
        totals.stakingShareSeconds =
            totals.stakingShareSeconds
            .add(newUserStakingShareSeconds);
        totals.lastAccountingTimestampSec = now;

        uint256 totalUserShareRewards = (_totalStakingShareSeconds > 0)
            ? totalUnlocked().mul(totals.stakingShareSeconds).div(_totalStakingShareSeconds)
            : 0;
    
        uint256 totalUserDollarRewards = (_totalStakingShareSeconds > 0)
            ? totalLockedDollars().mul(totals.stakingShareSeconds).div(_totalStakingShareSeconds)
            : 0;

        return (
            totalLocked(),
            totalUnlocked(),
            totals.stakingShareSeconds,
            _totalStakingShareSeconds,
            totalUserShareRewards,
            totalUserDollarRewards,
            now
        );
    }

    
    function totalLocked() public view returns (uint256) {
        return _lockedPool.shareBalance();
    }

    
    function totalUnlocked() public view returns (uint256) {
        return _unlockedPool.shareBalance();
    }

    
    function totalLockedDollars() public view returns (uint256) {
        return _lockedPool.dollarBalance();
    }

    
    function totalUnlockedDollars() public view returns (uint256) {
        return _unlockedPool.dollarBalance();
    }

    
    function unlockScheduleCount() public view returns (uint256) {
        return unlockSchedules.length;
    }

    function changeStakingToken(IERC20 stakingToken) external onlyOwner {
        _stakingPool = new TokenPool(stakingToken);
    }

    
    function lockTokens(uint256 amount, uint256 startTimeSec, uint256 durationSec) external onlyOwner {
        require(unlockSchedules.length < _maxUnlockSchedules,
            'SeigniorageMining: reached maximum unlock schedules');

        
        updateAccounting();

        uint256 lockedTokens = totalLocked();
        uint256 mintedLockedShares = (lockedTokens > 0)
            ? totalLockedShares.mul(amount).div(lockedTokens)
            : amount.mul(_initialSharesPerToken);

        UnlockSchedule memory schedule;
        schedule.initialLockedShares = mintedLockedShares;
        schedule.lastUnlockTimestampSec = now;
        schedule.startAtSec = startTimeSec;
        schedule.endAtSec = startTimeSec.add(durationSec);
        schedule.durationSec = durationSec;
        unlockSchedules.push(schedule);

        totalLockedShares = totalLockedShares.add(mintedLockedShares);

        require(_lockedPool.shareToken().transferFrom(msg.sender, address(_lockedPool), amount),
            'SeigniorageMining: transfer into locked pool failed');
        emit TokensLocked(amount, durationSec, totalLocked());
    }

    
    function unlockTokens() public returns (uint256) {
        uint256 unlockedShareTokens = 0;
        uint256 lockedShareTokens = totalLocked();

        uint256 unlockedDollars = 0;
        uint256 lockedDollars = totalLockedDollars();

        if (totalLockedShares == 0) {
            unlockedShareTokens = lockedShareTokens;
            unlockedDollars = lockedDollars;
        } else {
            uint256 unlockedShares = 0;
            for (uint256 s = 0; s < unlockSchedules.length; s++) {
                unlockedShares = unlockedShares.add(unlockScheduleShares(s));
            }
            unlockedShareTokens = unlockedShares.mul(lockedShareTokens).div(totalLockedShares);
            unlockedDollars = unlockedShares.mul(lockedDollars).div(totalLockedShares);
            totalLockedShares = totalLockedShares.sub(unlockedShares);
        }

        if (unlockedShareTokens > 0) {
            require(_lockedPool.shareTransfer(address(_unlockedPool), unlockedShareTokens),
                'SeigniorageMining: shareTransfer out of locked pool failed');
            require(_lockedPool.dollarTransfer(address(_unlockedPool), unlockedDollars),
                'SeigniorageMining: dollarTransfer out of locked pool failed');

            emit TokensUnlocked(unlockedShareTokens, totalLocked());
            emit DollarsUnlocked(unlockedDollars, totalLocked());
        }

        return unlockedShareTokens;
    }

    
    function unlockScheduleShares(uint256 s) private returns (uint256) {
        UnlockSchedule storage schedule = unlockSchedules[s];

        if(schedule.unlockedShares >= schedule.initialLockedShares) {
            return 0;
        }

        uint256 sharesToUnlock = 0;
        if (now < schedule.startAtSec) {
            
        } else if (now >= schedule.endAtSec) { 
            sharesToUnlock = (schedule.initialLockedShares.sub(schedule.unlockedShares));
            schedule.lastUnlockTimestampSec = schedule.endAtSec;
        } else {
            sharesToUnlock = now.sub(schedule.lastUnlockTimestampSec)
                .mul(schedule.initialLockedShares)
                .div(schedule.durationSec);
            schedule.lastUnlockTimestampSec = now;
        }

        schedule.unlockedShares = schedule.unlockedShares.add(sharesToUnlock);
        return sharesToUnlock;
    }
}