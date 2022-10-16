pragma solidity ^0.6.0;

contract Governance {
    using SafeMath for uint;

    
    
    uint public governanceExpiry      = 7 days;    
    uint public governanceSwitchDelay = 1 days;    
    uint public voteQuorum            = 25;        
    uint public votePass              = 50;        
    uint public minGovToken           = 1;         
    uint public voteDecimal           = 100;       
    
    
    address public previousGovernance;    
    address public GovernanceTokenAddress = 0x3DA1095F0b571f00B4D9A4B2A78AD8D13416886b;    
    
    function executeGovernanceActions() public {                
        require(msg.sender == previousGovernance, "!PrevGov");  
    }

    

    address public nextGovernance;            
    uint    public nextGovernanceExecution;   
    address [] public proposedGovernanceList; 
    bool    public GovernanceSwitchExecuted;  
    
    
    mapping (address => mapping (address => uint)) public voteYes;  
    mapping (address => mapping (address => uint)) public voteNo;   

    mapping (address => uint) public voteYesTotal;     
    mapping (address => uint) public voteNoTotal;      
    mapping (address => uint) public dateIntroduced;   
    mapping (address => bool) public tokenLocked;      

    function proposeNewGovernance(address newGovernanceContract) external {
        require(tokenLocked[msg.sender] == false, "Locked");
        require(GovernanceToken(GovernanceTokenAddress).balanceOf(msg.sender).mul(voteDecimal).div( GovernanceToken(GovernanceTokenAddress).totalSupply() ) > minGovToken, "<InsufGovTok" );
        require(Governance(newGovernanceContract).previousGovernance() == address(this), "WrongGovAddr");
        require(dateIntroduced[newGovernanceContract] == 0, "AlreadyProposed");
        tokenLocked[msg.sender] = true;
        proposedGovernanceList.push(newGovernanceContract);
        dateIntroduced[newGovernanceContract] = now;
    }
    
    function clearExistingVotesForProposal(address newGovernanceContract) internal {
        voteYesTotal[newGovernanceContract] = voteYesTotal[newGovernanceContract].sub( voteYes[newGovernanceContract][msg.sender] );
        voteNoTotal [newGovernanceContract] = voteNoTotal [newGovernanceContract].sub( voteNo [newGovernanceContract][msg.sender] );
        voteYes[newGovernanceContract][msg.sender] = 0;
        voteNo [newGovernanceContract][msg.sender] = 0;
    }
    
    function voteYesForProposal(address newGovernanceContract) external {
        require(dateIntroduced[newGovernanceContract].add(governanceExpiry) > now , "ProposalExpired");
        require( nextGovernance == address(0), "AlreadyQueued");
        tokenLocked[msg.sender] = true;
        clearExistingVotesForProposal(newGovernanceContract);
        voteYes[newGovernanceContract][msg.sender] = GovernanceToken(GovernanceTokenAddress).balanceOf(msg.sender);
        voteYesTotal[newGovernanceContract] = voteYesTotal[newGovernanceContract].add( GovernanceToken(GovernanceTokenAddress).balanceOf(msg.sender) );
    }
    
    function voteNoForProposal(address newGovernanceContract) external {
        require(dateIntroduced[newGovernanceContract].add(governanceExpiry) > now , "ProposalExpired");
        require( nextGovernance == address(0), "AlreadyQueued");
        tokenLocked[msg.sender] = true;
        clearExistingVotesForProposal(newGovernanceContract);
        voteNo[newGovernanceContract][msg.sender] = GovernanceToken(GovernanceTokenAddress).balanceOf(msg.sender);
        voteNoTotal[newGovernanceContract] = voteNoTotal[newGovernanceContract].add( GovernanceToken(GovernanceTokenAddress).balanceOf(msg.sender) );
    }
    
    function queueGovernance(address newGovernanceContract) external {
        require( voteYesTotal[newGovernanceContract].add(voteNoTotal[newGovernanceContract]).mul(voteDecimal).div( GovernanceToken(GovernanceTokenAddress).totalSupply() ) > voteQuorum, "<Quorum" );
        require( voteYesTotal[newGovernanceContract].mul(voteDecimal).div( voteYesTotal[newGovernanceContract].add(voteNoTotal[newGovernanceContract]) ) > votePass, "<Pass" );
        require( nextGovernance == address(0), "AlreadyQueued");
        nextGovernance = newGovernanceContract;
        nextGovernanceExecution = now.add(governanceSwitchDelay);
    }  
    
    function executeGovernance() external {
        require( nextGovernance != address(0) , "!Queued");
        require( now > nextGovernanceExecution, "!NotYet");
        require( GovernanceSwitchExecuted == false, "AlrExec");
        GovernanceToken(GovernanceTokenAddress).setGovernance(nextGovernance);
        Governance(nextGovernance).executeGovernanceActions();
        GovernanceSwitchExecuted = true;
    }
}


library SafeMath {
  function div(uint a, uint b) internal pure returns (uint) {
      require(b > 0, "SafeMath: division by zero");
      return a / b;
  }
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) return 0;
    uint c = a * b;
    require (c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a, "SafeMath: subtraction underflow");
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
}

interface GovernanceToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function mint(address tgtAdd, uint amount) external;
    function revoke(address tgtAdd, uint amount) external;
    function setGovernance(address newGovernanceAddress) external;
}