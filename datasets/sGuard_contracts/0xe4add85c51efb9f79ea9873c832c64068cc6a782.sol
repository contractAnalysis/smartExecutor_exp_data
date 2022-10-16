pragma solidity 0.6.12;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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
        
        
        

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract Prestaking is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    
    IERC20 private _token;
    
    
    struct Staker {
        uint    startTime;
        uint    endTime;
        uint256 amount;
        uint256 accumulatedReward;
        uint    cooldownTime;
        bool    active;
        uint256 pendingReward;
    }
    
    mapping(address => Staker) public stakersMap;
    address[] public allStakers;
    uint256 public minimumStake;
    uint256 public maximumStake;
    uint256 public dailyReward;
    uint256 public stakingPool;
    uint public cap;
    
    uint private lastUpdated;

    bool public active;
    
    modifier onlyStaker() {
        Staker storage staker = stakersMap[msg.sender];
        require(staker.startTime.add(1 days) <= block.timestamp && staker.startTime != 0, "No stake is active for sender address");
        _;
    }

    modifier onlyActive() {
        require(active);
        _;
    }
    
    constructor(IERC20 token, uint256 min, uint256 max, uint256 reward, uint userCap, uint timestamp) public {
        _token = token;
        minimumStake = min;
        maximumStake = max;
        dailyReward = reward;
        lastUpdated = timestamp;
        cap = userCap;
        active = true;
    }
    
    
    receive() external payable {
        revert();
    }
    
    
    function updateMinimumStake(uint256 amount) external onlyOwner {
        require(amount <= maximumStake, "Given amount exceeds current maximum stake");
        minimumStake = amount;
    }
    
    
    function updateMaximumStake(uint256 amount) external onlyOwner {
        require(amount >= minimumStake, "Given amount is less than current minimum stake");
        maximumStake = amount;
    }

    
    function updateDailyReward(uint256 amount) external onlyOwner {
        dailyReward = amount;
    }

    
    function updateDistribution() external {
        distributeRewards();
    }

    
    function toggleActive() external onlyOwner {
        active = !active;
    }

    
    function adjustCap(uint newCap) external onlyOwner {
        cap = newCap;
    }

    
    function stakersAmount() external view returns (uint) {
        return allStakers.length;
    }
    
    
    function stake() external onlyActive {
        
        require(allStakers.length < cap, "Too many stakers active");

        
        Staker storage staker = stakersMap[msg.sender];
        require(staker.amount == 0, "Address already known");
        
        
        uint256 balance = _token.allowance(msg.sender, address(this));
        require(balance != 0, "No tokens have been approved for this contract");
        require(balance >= minimumStake, "Insufficient tokens approved for this contract");

        if (balance > maximumStake) {
            balance = maximumStake;
        }
        
        
        allStakers.push(msg.sender);
        staker.amount = balance;
        staker.startTime = block.timestamp;
        
        
        _token.safeTransferFrom(msg.sender, address(this), balance);
    }
    
    
    function startWithdrawReward() external onlyStaker onlyActive {
        Staker storage staker = stakersMap[msg.sender];
        require(staker.cooldownTime == 0, "A withdrawal call has already been triggered");
        require(staker.endTime == 0, "Stake already withdrawn");
        distributeRewards();
        
        staker.cooldownTime = block.timestamp;
        staker.pendingReward = staker.accumulatedReward;
        staker.accumulatedReward = 0;
    }
    
    
    function withdrawReward() external onlyStaker {
        Staker storage staker = stakersMap[msg.sender];
        require(staker.cooldownTime != 0, "The withdrawal cooldown has not been triggered");

        if (block.timestamp.sub(staker.cooldownTime) >= 7 days) {
            uint256 reward = staker.pendingReward;
            staker.cooldownTime = 0;
            staker.pendingReward = 0;
            _token.safeTransfer(msg.sender, reward);
        }
    }
    
    
    function startWithdrawStake() external onlyStaker {
        Staker storage staker = stakersMap[msg.sender];
        require(staker.startTime.add(30 days) <= block.timestamp, "Stakes can only be withdrawn 30 days after initial lock up");
        require(staker.endTime == 0, "Stake already withdrawn");
        require(staker.cooldownTime == 0, "A withdrawal call has been triggered - please wait for it to complete before withdrawing your stake");

        
        
        distributeRewards();

        staker.endTime = block.timestamp;
        stakingPool = stakingPool.sub(staker.amount);
    }
    
    
    function withdrawStake() external onlyStaker {
        Staker storage staker = stakersMap[msg.sender];
        require(staker.endTime != 0, "Stake withdrawal call was not yet initiated");
        
        if (block.timestamp.sub(staker.endTime) >= 7 days) {
            removeUser(staker, msg.sender);
        }
    }
    
    
    function distributeRewards() internal {
        while ((block.timestamp.sub(lastUpdated)) > 1 days) {
            lastUpdated = lastUpdated.add(1 days);

            
            updateStakingPool();
            
            if (!active) {
                continue;
            }

            
            for (uint i = 0; i < allStakers.length; i++) {
                Staker storage staker = stakersMap[allStakers[i]];
                
                
                
                if (!staker.active || staker.endTime != 0) {
                    continue;
                }
                
                
                
                uint256 reward = staker.amount.mul(10000).mul(dailyReward).div(stakingPool).div(10000);
                staker.accumulatedReward = staker.accumulatedReward.add(reward);
            }
        }
    }

    
    function returnStake(address _staker) external onlyOwner {
        Staker storage staker = stakersMap[_staker];
        require(staker.amount > 0, "This person is not staking");

        
        
        staker.accumulatedReward = staker.accumulatedReward.add(staker.pendingReward);
        removeUser(staker, _staker);
    }

    
    function updateStakingPool() internal {
        uint256 counter = 0;
        for (uint i = 0; i < allStakers.length; i++) {
            Staker storage staker = stakersMap[allStakers[i]];

            
            if (!staker.active && lastUpdated.sub(staker.startTime) >= 1 days) {
                staker.active = true;
                counter = counter.add(staker.amount);
            }
        }
        
        stakingPool = stakingPool.add(counter);
    }

    
    function removeUser(Staker storage staker, address sender) internal {
        uint256 balance = staker.amount.add(staker.accumulatedReward);
        delete stakersMap[sender];
        
        
        for (uint i = 0; i < allStakers.length; i++) {
            if (allStakers[i] == sender) {
                allStakers[i] = allStakers[allStakers.length-1];
                delete allStakers[allStakers.length-1];
            }
        }
        _token.safeTransfer(sender, balance);
    }
}