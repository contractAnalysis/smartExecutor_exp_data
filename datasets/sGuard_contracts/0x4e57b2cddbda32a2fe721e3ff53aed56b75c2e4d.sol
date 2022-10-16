pragma solidity 0.5.16;


contract FundRaiser {
  using SafeMath for uint256;
  
  struct Request {
    string description;
    uint256 value;
    address payable recipient;
    bool completed;
    uint256 numberOfVoters;
    mapping(address => bool) voters;
  }

  
  uint256 public deadline;  
  uint256 public initialPaymentDeadline; 
  uint256 public goal;  
  uint256 public minimumContribution;  
  address public owner;  
  uint256 public totalContributors;  
  uint256 public totalRequests;  
  uint256 public amountRaised;  
  uint256 public amountPaidOut;  
  uint256 public requestCountMax = 100;  

  Request[] public requests;

  mapping(address => uint256) public contributions;

  event Contribution(address indexed from, uint256 value);  
  event Refund(address indexed to, uint256 value);  
  event RequestCreated(address indexed from, uint256 requestId, string description, uint256 value, address recipient);  
  event Vote(address indexed from, uint256 requestId);  
  event PaymentReleased(address indexed from, uint256 requestId, uint256 value, address recipient);  
  event OwnerChanged(address indexed from, address to);  

  
  constructor(uint256 _duration, uint256 _initialPaymentDuration, uint256 _goal, uint256 _minimumContribution) public {
    deadline = block.number + _duration;
    initialPaymentDeadline = block.number + _duration + _initialPaymentDuration;
    goal = _goal;
    minimumContribution = _minimumContribution;
    owner = msg.sender;
  }

  
  modifier onlyOwner {
    require(msg.sender == owner, "Caller is not the contract owner");
    _;
  }

  
  

  
  function changeOwner(address _newOwner) external onlyOwner returns (bool) {
    require(_newOwner != address(0), "Invalid Owner change to address zero");
    owner = _newOwner;
    emit OwnerChanged(msg.sender, _newOwner);
    return true;
  }

  
  function contribute() external payable returns (bool) {
    require(msg.value >= minimumContribution, "Minimum Contribution level not met");
    require(block.number <= deadline, "Deadline is passed");

    
    if(contributions[msg.sender] == 0) {
      totalContributors = totalContributors.add(1);
    }
    contributions[msg.sender] = contributions[msg.sender].add(msg.value);
    amountRaised = amountRaised.add(msg.value);
    emit Contribution(msg.sender, msg.value);
    return true;
  }

  
  function getRefund() external returns (bool) {
    require(contributions[msg.sender] > 0, "No contribution to return");
    require(block.number > deadline, "Deadline not reached");
    require(amountPaidOut == 0, "Payments have already been made");
    if (amountRaised >= goal) {
      require(block.number > initialPaymentDeadline, "Initial Payment Deadline not reached");
    }
    uint256 amountToRefund = contributions[msg.sender];
    contributions[msg.sender] = 0;
    totalContributors = totalContributors.sub(1);
    
    for (uint x = 0; (x < totalRequests && x < requestCountMax); x++) {
      Request storage thisRequest = requests[x];
      if (thisRequest.voters[msg.sender] == true) {
        thisRequest.voters[msg.sender] = false;
        thisRequest.numberOfVoters = thisRequest.numberOfVoters.sub(1);
      }
    }
    msg.sender.transfer(amountToRefund);
    emit Refund(msg.sender, amountToRefund);
    return true;
  }

  
  function createRequest(string calldata _description, uint256 _value, address payable _recipient) external onlyOwner returns (bool) {
    require(_value > 0, "Spending request value cannot be zero");
    require(amountRaised >= goal, "Amount Raised is less than Goal");
    require(_value <= address(this).balance, "Spending request value greater than amount available");
    require(_recipient != address(0), "Invalid Recipient of address zero");
    require(totalRequests < requestCountMax, "Spending Request Count limit reached");

    Request memory newRequest = Request({
      description: _description,
      value: _value,
      recipient: _recipient,
      completed: false,
      numberOfVoters: 0
    });
    requests.push(newRequest);
    totalRequests = totalRequests.add(1);
    emit RequestCreated(msg.sender, totalRequests.sub(1), _description, _value, _recipient);
    return true;
  }

  
  function voteForRequest(uint256 _index) external returns (bool) {
    require(totalRequests > _index, "Spending request does not exist");

    Request storage thisRequest = requests[_index];
    
    require(thisRequest.completed == false, "Request already completed");
    require(contributions[msg.sender] > 0, "No contribution from Caller");
    require(thisRequest.voters[msg.sender] == false, "Caller already voted");

    thisRequest.voters[msg.sender] = true;
    thisRequest.numberOfVoters = thisRequest.numberOfVoters.add(1);
    emit Vote(msg.sender, _index);
    return true;
  }

  
  function hasVoted(uint256 _index, address _account) external view returns (bool) {
    require(totalRequests > _index, "Spending request does not exist");
    Request storage thisRequest = requests[_index];
    return thisRequest.voters[_account];
  }

  
  function releasePayment(uint256 _index) external onlyOwner returns (bool) {
    require(totalRequests > _index, "Spending request does not exist");

    Request storage thisRequest = requests[_index];

    require(thisRequest.completed == false, "Request already completed");
    require(thisRequest.numberOfVoters > totalContributors / 2, "Less than a majority voted");
    require(thisRequest.value <= address(this).balance, "Spending request value greater than amount available");

    amountPaidOut = amountPaidOut.add(thisRequest.value);
    thisRequest.completed = true;
    thisRequest.recipient.transfer(thisRequest.value);
    emit PaymentReleased(msg.sender, _index, thisRequest.value, thisRequest.recipient);
    return true;
  }

  
   
}


library SafeMath {
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;
    return c;
  }
}