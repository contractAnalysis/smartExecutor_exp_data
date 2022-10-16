pragma solidity ^0.5.0;

contract CrowdsaleToken {
    
    string public constant name = 'Rocketclock';
    string public constant symbol = 'RCLK';
    
    address payable owner;
    address payable contractaddress;
    uint256 public constant totalSupply = 1000;

    
    mapping (address => uint256) public balanceOf;
    

    
    event Transfer(address payable indexed from, address payable indexed to, uint256 value);
    

    modifier onlyOwner() {
        
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    
    constructor() public{
        contractaddress = address(this);
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        

    }

    
    
    function _transfer(address payable _from, address payable _to, uint256 _value) internal {
    
        require (_to != address(0x0));                               
        require (balanceOf[_from] > _value);                
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                            
        emit Transfer(_from, _to, _value);
    }

    
    
    
    function transfer(address payable _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);
        return true;

    }

    
    function () external payable onlyOwner{}


    function getBalance(address addr) public view returns(uint256) {
  		return balanceOf[addr];
  	}

    function getEtherBalance() public view returns(uint256) {
  		
      return address(this).balance;
  	}

    function getOwner() public view returns(address) {
      return owner;
    }

}

contract CrowdSale {
    address payable public beneficiary;
    address payable public crowdsaleAddress;
    
    address payable public tokenAddress;
    address payable public owner;
    uint public fundingGoal;
    uint public amountRaised;
    uint public tokensSold;
    uint public deadline;
    uint public initiation;
    
    
    uint256 public constant price = 250 finney;
    uint public constant amount = 1;

    CrowdsaleToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    modifier onlyOwner() {
        
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    
    constructor(
        address payable ifSuccessfulSendTo,
        address payable addressOfTokenUsedAsReward
    )public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = 100 * 1 ether;
        deadline = now + 60 * 1 days;
        initiation = now;
        crowdsaleAddress = address(this);
        tokenAddress = addressOfTokenUsedAsReward;
        tokenReward = CrowdsaleToken(addressOfTokenUsedAsReward);
        owner = msg.sender;
    }

    

    function () external payable {

        
        if(msg.sender != owner){

          require(!crowdsaleClosed);
          if (now <= deadline){

            if(msg.value >= price){
              balanceOf[msg.sender] += msg.value;
              tokensSold += amount;
              amountRaised += msg.value;
              tokenReward.transfer(msg.sender, amount);
              emit FundTransfer(msg.sender, amount, true);
            }
            else{
              
              amountRaised += msg.value;
            }
          }
          else{
            revert();
          }

        }



    }

    function depositFunds() public payable
    {
      require(!crowdsaleClosed);
      if (now <= deadline){

        if(msg.value >= price){
          balanceOf[msg.sender] += msg.value;
          tokensSold += amount;
          amountRaised += msg.value;
          tokenReward.transfer(msg.sender, amount);
          emit FundTransfer(msg.sender, amount, true);
        }
        else{
          
          amountRaised += msg.value;
        }
      }
      else{
        revert();
      }

    }

    modifier afterDeadline() { if (now >= deadline) _; }
    modifier goalReached() { if (amountRaised >= fundingGoal) _; }

    
    function checkGoalReached() public afterDeadline returns(bool) {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
        return crowdsaleClosed;
    }


    
    function safeWithdrawal() public afterDeadline {
        if (!fundingGoalReached) {
            uint returnamount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            
            if (returnamount >= price) {
                if (msg.sender.send(returnamount)) {
                    emit FundTransfer(msg.sender, returnamount, false);
                } else {
                    balanceOf[msg.sender] = returnamount;
                }
            }
        }

    }

    function crowdfundWithdrawal() public afterDeadline onlyOwner {
        if (fundingGoalReached && beneficiary == msg.sender) {

          if (beneficiary.send(amountRaised)) {
              emit FundTransfer(beneficiary, amountRaised, false);
          }

        }

    }

    
    function closeDeadline() public goalReached onlyOwner {
      deadline = now;
    }

    function getcrowdsaleClosed() public view returns(bool) {
      return crowdsaleClosed;
    }

    function getfundingGoalReached() public view returns(bool) {
      return fundingGoalReached;
    }
}