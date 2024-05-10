pragma solidity 0.6.11;









interface TRA {
  function approve(address spender, uint256 amount) external returns (bool);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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

contract Staking {
  
  
  using SafeMath for uint256;

  mapping (address => uint256) public _StakeAmounts;
  mapping (address => uint256) public _AccoutNonce;
  mapping (address => bytes32[]) public _Hashes;
  mapping (address => mapping(bytes32 => uint256)) public _HashToTime;
  mapping (address => mapping(bytes32 => uint256)) public _HashToAmount;
  
  uint256 public _interestRate = 15;
  address public _owner;
  address public _TRAAddress;

  TRA public _TRAContract;

  
  constructor() public {
    _owner = msg.sender;
    _TRAAddress = address(0);
    _TRAContract = TRA(_TRAAddress);

  }
  event log(address owner,uint256 amount);
  
  function SetTRAAddress(address TRAAddress) public {
    require(msg.sender == _owner,"Only owners can change the TRA address");
    _TRAAddress = TRAAddress;
    _TRAContract = TRA(_TRAAddress);
  }

  
  
  function Stake(uint256 amount) public returns(bytes32) {
    _StakeAmounts[msg.sender] = _StakeAmounts[msg.sender].add(amount);
    
    uint256 nonce = _AccoutNonce[msg.sender];
    
    bytes32 stakingHash = keccak256(abi.encode(msg.sender,nonce,amount));
    
    bytes32[] storage hashList = _Hashes[msg.sender];
    hashList.push(stakingHash);
    
    
    _HashToTime[msg.sender][stakingHash] = block.timestamp;
    _HashToAmount[msg.sender][stakingHash] = amount;
    _AccoutNonce[msg.sender] = _AccoutNonce[msg.sender].add(1);
    _TRAContract.transferFrom(msg.sender,address(this),amount);
    return stakingHash;
  }

  
  function GetStakes(address account) public view returns (bytes32[] memory) {
    bytes32[] memory hashList = _Hashes[account];
    return hashList;
  }

  
  
  function UnstakeAll() public {
    uint256 _totalStaked = _StakeAmounts[msg.sender];
    _StakeAmounts[msg.sender] = 0;
    uint256 interest = CalculateInterest(msg.sender);
    
    
    delete _Hashes[msg.sender];

    
    _TRAContract.transfer(msg.sender,_totalStaked.add(interest));
  }

  function GetStakingBalance(address owner) public view returns (uint256) {
    return _StakeAmounts[owner];
  }

  function CalculateInterestForStake(address owner,bytes32 stakeHash) public view returns(uint256) {
    mapping(bytes32 => uint256) storage times = _HashToTime[owner];
    mapping(bytes32 => uint256) storage amounts = _HashToAmount[owner];
    
    uint256 timeStaked = times[stakeHash];
    uint256 amountStaked = amounts[stakeHash];
    uint256 timeElapsed = block.timestamp.sub(timeStaked);
    uint256 numerator = amountStaked.mul(_interestRate).mul(timeElapsed);
    uint256 denominator = 100 * 31556952;
    uint256 interestEarned = numerator / denominator;
    return interestEarned;
  }

  function CalculateInterest(address owner) public view returns(uint256) {
    
    bytes32[] storage hashList = _Hashes[owner];
    mapping(bytes32 => uint256) storage times = _HashToTime[owner];
    mapping(bytes32 => uint256) storage amounts = _HashToAmount[owner];
    uint256 interest = 0;
    for(uint256 i = 0;i<hashList.length;i++) {
      
      uint256 timeStaked = times[hashList[i]];
      uint256 amountStaked = amounts[hashList[i]];
      uint256 timeElapsed = block.timestamp.sub(timeStaked);
      uint256 numerator = amountStaked.mul(_interestRate).mul(timeElapsed);
      uint256 denominator = 100 * 31556952;
      uint256 interestEarned = numerator / denominator;
      interest = interest.add(interestEarned);
    }
    return interest;
  }
}