pragma solidity ^0.5.0;



contract RevolutionFactory {

  address public owner = msg.sender;

  string [] public hashtags;

  mapping(string => Revolution) revolutions;


  function createRevolution(string memory _criteria, string memory _hashtag, uint _distributionBlockPeriod, uint _distributionAmount, bool _testingMode) public {
    
    if (address(revolutions[_hashtag]) == address(0)) {
      revolutions[_hashtag] = new Revolution(msg.sender, _criteria, _hashtag, _distributionBlockPeriod, _distributionAmount, _testingMode);
      hashtags.push(_hashtag);
    }
  }


  function getRevolution(string memory _hashtag) public view returns (Revolution) {
    return revolutions[_hashtag];
  }


  function lockRevolution(string memory _hashtag) public {
    

    
    require(msg.sender == owner);
    revolutions[_hashtag].lock();
  }
}


contract Revolution {

  address public owner;
  address public factory;
  
  
  
  string public criteria;
  
  
  
  string public hashtag;

  
  uint public distributionBlockPeriod;

  
  uint public distributionAmount;

  
  uint public lastDistributionBlockNumber;

  
  bool public testingMode;
  
  
  
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
    uint lastLotteryBlock;
    bool opened;
    bool matchesCriteria;
  }

  
  address payable [] public citizens;

  
  mapping (address => string) public names;

  
  mapping (address => Trial) private trials;

  
  uint public bastilleBalance;

  
  event RevolutionCreated(string indexed _hashtag);
  
  event TrialOpened(string indexed _eventName, address indexed _citizen);
  
  event TrialClosed(string indexed _eventName, address indexed _citizen, bool _matchesCriteria);
  
  event VoteReceived(string indexed _eventName, address indexed _from, address indexed _citizen, bool _vote, uint _amount);
  
  event Distribution(string indexed _eventName, address indexed _citizen, uint _distributionAmount);


  constructor(address _owner, string memory _criteria, string memory _hashtag, uint _distributionBlockPeriod, uint _distributionAmount, bool _testingMode) public {
    factory = msg.sender;
    owner = _owner;
    criteria = _criteria;
    hashtag = _hashtag;
    distributionBlockPeriod = _distributionBlockPeriod;
    distributionAmount = _distributionAmount;
    lastDistributionBlockNumber = block.number;
    testingMode = _testingMode;
    locked = false;
    emit RevolutionCreated(hashtag);
  }


  function lock() public {
    

    
    require(msg.sender == owner || msg.sender == factory);
    locked = true;

  }


  function vote(bool _vote, address payable _citizen) public payable {

    
    require(locked == false || bastilleBalance > 0);
    
    require(msg.value >= distributionAmount / 10);

    Trial storage trial = trials[_citizen];
    
    if (_vote != trial.matchesCriteria) {
      trial.opened = true;
    }
    if (trial.citizen == address(0x0) ) {
      
      emit TrialOpened('TrialOpened', _citizen);
      citizens.push(_citizen);
      trial.citizen = _citizen;
      trial.lastLotteryBlock = block.number;
    }

    
    JusticeScale storage scale = trial.sansculotteScale;
    if (_vote == false) {
      scale = trial.privilegedScale;
    }
    
    scale.voters.push(msg.sender);
    scale.votes[msg.sender] += msg.value;
    scale.amount+= msg.value;

    emit VoteReceived('VoteReceived', msg.sender, _citizen, _vote, msg.value);

    if(testingMode == false) {
      closeTrial(_citizen);
      distribute();
    }

  }


  function closeTrial(address payable _citizen) public {
    
    
    bool shouldClose = trialLottery(_citizen);
    if(shouldClose == false) {
      
      return;
    }
  
    
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
    emit TrialClosed('TrialClosed', _citizen, trial.matchesCriteria);

    
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


  function pseudoRandomNumber(uint _max) private view returns (uint) {
    
    
    uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp)));
    return randomHash % _max;
  }

  function trialLottery(address payable _citizen) private returns (bool) {

    if (testingMode == true) {
      
      return true;
    }
    
    
    
    
    
    uint probabilityPercent = 50;
    uint million = 1000000;
    uint threshold = million * probabilityPercent / 100;
    Trial storage trial = trials[_citizen];
    uint blocksSince = block.number - trial.lastLotteryBlock;
    if (blocksSince < distributionBlockPeriod) {
      threshold *= blocksSince / distributionBlockPeriod;
      
    }
    
    trial.lastLotteryBlock = block.number;
    if(pseudoRandomNumber(million) < threshold) {
      return true;
    }
    return false;

  }


  function distribute() public {

    
    if  (block.number - lastDistributionBlockNumber < distributionBlockPeriod) {
      return;
    }
    
    uint firstCitizen = pseudoRandomNumber(citizens.length);
    for (uint i = 0; i < citizens.length; i++) {
      uint citizenIndex = firstCitizen + i;
      if (citizenIndex >= citizens.length) {
        citizenIndex = citizenIndex - citizens.length;
      }
      address payable citizen = citizens[citizenIndex];
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


  function getScaleAmount(bool _vote, address _citizen) public view returns (uint) {

    Trial storage trial = trials[_citizen]; 
    if (_vote == true)
      return trial.sansculotteScale.amount;
    else
      return trial.privilegedScale.amount;

  }


  function trialStatus(address _citizen) public view returns(bool opened, bool matchesCriteria, uint sansculotteScale, uint privilegedScale, string memory name) {
  
    Trial memory trial = trials[_citizen];
    return (trial.opened, trial.matchesCriteria, trial.sansculotteScale.amount, trial.privilegedScale.amount, names[_citizen]);

  }


  function getName(address payable _citizen) public view returns (string memory name) {
    return names[_citizen];
  }


  function setName(address payable _citizen, string memory _name) public {
    require(msg.sender == _citizen);
    names[_citizen] = _name;
  }


  function voteAndSetName(bool _vote, address payable _citizen, string memory _name) public payable {
    vote(_vote, _citizen);
    setName(_citizen, _name);
  }

  function() payable external {

    require(locked == false);
    bastilleBalance += msg.value;

  }

}