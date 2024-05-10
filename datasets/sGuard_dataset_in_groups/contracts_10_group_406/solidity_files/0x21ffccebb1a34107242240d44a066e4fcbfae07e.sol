pragma solidity ^0.5.0;


library Math {
    
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}



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


contract Context {
    
    
    constructor () internal {}
    

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



pragma solidity ^0.5.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;

    function burn(uint amount) external;

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract YFVDevRewards is Ownable {
    using SafeMath for uint256;

    IERC20 public yfv = IERC20(0x45f24BaEef268BB6d63AEe5129015d69702BCDfa);
    IERC20 public vUSD = IERC20(0x1B8E12F839BD4e73A47adDF76cF7F0097d74c14C);
    IERC20 public vETH = IERC20(0x76A034e76Aa835363056dd418611E4f81870f16e);

    uint256 public vUSD_REWARD_FRACTION_RATE = 21000000000; 
    uint256 public vETH_REWARD_FRACTION_RATE = 21000000000000; 

    uint256 public constant DURATION = 50 weeks;
    uint256 public constant TOTAL_REWARD = 1470000 ether;

    uint256 public constant REWARD_RATE = TOTAL_REWARD / DURATION;

    uint256 public totalClaimedRewards = 0;
    uint256 public starttime = 1597759200; 
    uint256 public endtime = starttime + DURATION;

    event RewardPaid(uint256 reward);
    event RewardBurn(uint256 reward);

    function totalReleasedRewards() public view returns (uint256) {
        if (block.timestamp <= starttime) return 0;
        else if (block.timestamp >= endtime) return TOTAL_REWARD;
        return REWARD_RATE.mul(block.timestamp - starttime);
    }

    function claimableRewards() public view returns (uint256) {
        return totalReleasedRewards().sub(totalClaimedRewards);
    }

    function claimRewards() public onlyOwner {
        uint256 reward = claimableRewards();
        require(reward > 0, "There is nothing to claim");
        totalClaimedRewards = totalClaimedRewards.add(reward);
        yfv.mint(msg.sender, reward);
        vUSD.mint(msg.sender, reward.div(vUSD_REWARD_FRACTION_RATE));
        vETH.mint(msg.sender, reward.div(vETH_REWARD_FRACTION_RATE));
        emit RewardPaid(reward);
    }

    function burnRewards(uint256 amount) public onlyOwner {
        uint256 reward = claimableRewards();
        require(reward >= amount, "There is not enough reward to burn");
        totalClaimedRewards = totalClaimedRewards.add(amount);
        yfv.mint(address(this), amount);
        yfv.burn(amount);
        emit RewardBurn(amount);
    }
}