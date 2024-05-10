pragma solidity ^0.5.0;

contract Revolution {

  address public owner = msg.sender;
  
  
  
  string public criteria;

  
  uint public distributionBlockPeriod;

  
  uint public distributionAmount;

  
  uint lastDistributionBlockNumber;

  
  bool public withLottery;

  
  bool public withDistribution;
  
  
  
  bool public locked;

  
  
  struct JusticeScale {
    address payable [] voters;
    mapping (address => uint) votes;
    uint amount;
  }

  
  struct Trial {
    address payable citizen;
    JusticeScale sansculotteScale;
    JusticeScale privilegedScale;
    uint lastClosingAttemptBlock;
    bool opened;
    bool matchesCriteria;
  }

  
  address payable [] public citizens;
  
  mapping (address => Trial) private trials;

  
  uint public bastilleBalance;

  
  event TrialOpened(string indexed _eventName, address indexed _citizen);
  
  event TrialClosed(string indexed _eventName, address indexed _citizen);
  
  event VoteReceived(string indexed _eventName, address _from, address indexed _citizen, bool _vote, uint indexed _amount);
  
  event Distribution(string indexed _eventName, address indexed _citizen, uint _distributionAmount);


  constructor(string memory _criteria, uint _distributionBlockPeriod, uint _distributionAmount, bool _withLottery, bool _withDistribution) public{
    criteria = _criteria;
    distributionBlockPeriod = _distributionBlockPeriod;
    distributionAmount = _distributionAmount;
    lastDistributionBlockNumber = block.number;
    withLottery = _withLottery;
    withDistribution = _withDistribution;
    locked = false;
  }

  function lock() public {
    
    
    require(msg.sender == owner);
    locked = true;
  }

  function vote(bool _vote, address payable _citizen) public payable {
    require(locked == false || bastilleBalance > 0);
    Trial storage trial = trials[_citizen];
    trial.opened = true;
    if (trial.citizen == address(0x0) ) {
      
      emit TrialOpened('TrialOpened', _citizen);
      citizens.push(_citizen);
      trial.citizen = _citizen;
    }

    JusticeScale storage scale = trial.sansculotteScale;
    if (_vote == false) {
      scale = trial.privilegedScale;
    }
    scale.voters.push(msg.sender);
    scale.votes[msg.sender] += msg.value;
    scale.amount+= msg.value;

    emit VoteReceived('VoteReceived', msg.sender, _citizen, _vote, msg.value);

    if(withLottery == true
      && block.number > trial.lastClosingAttemptBlock + distributionBlockPeriod/3) {
      
      trial.lastClosingAttemptBlock = block.number;
      
      if(closingLottery() == true) {
        emit TrialClosed('TrialClosed', _citizen);
        closeTrial(_citizen);
      }
    }

    if(withDistribution == true) {
      distribute();
    }
  }

  function closeTrial(address payable _citizen) public {
    Trial storage trial = trials[_citizen];
    
    trial.opened = false;
    
    
    JusticeScale storage winnerScale = trial.privilegedScale;
    JusticeScale storage loserScale = trial.sansculotteScale;
    trial.matchesCriteria = false;
    
    if (trial.sansculotteScale.amount > trial.privilegedScale.amount) {
      winnerScale = trial.sansculotteScale;
      loserScale = trial.privilegedScale;
      trial.matchesCriteria = true;
    }

    
    uint bastilleVote = winnerScale.amount - loserScale.amount;

    
    
    
    
    
    
    
    
    
    
    uint remainingRewardCakes = loserScale.amount;
    for (uint i = 0; i < winnerScale.voters.length; i++) {
      address payable voter = winnerScale.voters[i];
      
      
      uint winningCakes = winnerScale.votes[voter];
      
      winnerScale.votes[voter]=0;
      
      voter.send(winningCakes);
      
      
      
      
      uint rewardCakes = loserScale.amount * winningCakes / ( winnerScale.amount + bastilleVote );
      
      
      voter.send(rewardCakes);
      remainingRewardCakes -= rewardCakes;
    }
   
    
    bastilleBalance += remainingRewardCakes;

    
    winnerScale.amount = 0;

    
    for (uint i = 0; i < loserScale.voters.length; i++) {
      address payable voter = loserScale.voters[i];
      loserScale.votes[voter]=0;
    }
    loserScale.amount = 0;

  }

  function distribute() public {
    
    if  (block.number - lastDistributionBlockNumber < distributionBlockPeriod) {
      return;
    }
    
    for (uint i = 0; i < citizens.length; i++) {
      address payable citizen = citizens[i];
      Trial memory trial = trials[citizen];
      
      
      
      if (trial.opened == false &&
          trial.matchesCriteria == true ) {
        uint distributed = 0;
        if (bastilleBalance >= distributionAmount) {
          distributed = distributionAmount;
        } else {
          if (locked == true) {
            distributed = bastilleBalance;
          }
        }
        
        if (distributed > 0) {
          if (citizen.send(distributed)) {
            bastilleBalance -= distributed;
            emit Distribution('Distribution', citizen, distributed);
          } else {
            
            emit Distribution('Distribution', citizen, 0);
          }
        }
      }
    }
    
    lastDistributionBlockNumber = block.number;
  }

  function getScaleAmount(bool _vote, address _citizen) public view returns (uint){
    Trial storage trial = trials[_citizen]; 
    if (_vote == true)
      return trial.sansculotteScale.amount;
    else
      return trial.privilegedScale.amount;
  }

  function closingLottery() private view returns (bool) {
    
    uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp)));
    uint res = randomHash % 10;
    if(res < 4) {
      return true;
    }
    return false;
  }

  function trialStatus(address _citizen) public view returns(bool opened, bool matchesCriteria, uint sansculotteScale, uint privilegedScale) {
    Trial memory trial = trials[_citizen];
    return (trial.opened, trial.matchesCriteria, trial.sansculotteScale.amount, trial.privilegedScale.amount);
  }

  function() payable external {
    require(locked == false);
    bastilleBalance += msg.value;
  }
}