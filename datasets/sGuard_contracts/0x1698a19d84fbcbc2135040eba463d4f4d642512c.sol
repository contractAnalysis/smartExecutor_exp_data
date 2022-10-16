pragma solidity ^0.4.18;

     

      contract ERC20 {
      
     function balanceOf(address _who )public view returns (uint256 balance);
      function transfer(address _to, uint256 _value) public;
         
    
    
}

contract HTLC_ERC20_Token {
          
  uint public timeLock = now + 200;     
  address owner = msg.sender;           
  bytes32 public sha256_hashed_secret =0x111ce3dd1183100bdd1d7ef96d3a43a44d4270abaae81dc7b5be744d3af75e04; 

  ERC20 Your_token= ERC20(0x22a39C2DD54b71aC884657bb3e37308ABe2D02E1);  
                                                        

  
  modifier onlyOwner{require(msg.sender == owner); _; }


  
    function claim(string _secret) public returns(bool result) {

       require(sha256_hashed_secret == sha256(_secret)); 
       require(msg.sender!=owner);                
       uint256 allbalance=Your_token.balanceOf(address(this));
       Your_token.transfer(msg.sender,allbalance);
       selfdestruct(owner);
       return true;
      
       }
    
    
    
       
        function refund() onlyOwner public returns(bool result) {
        require(now >= timeLock);
        uint256 allbalance=Your_token.balanceOf(address(this)); 
        Your_token.transfer(owner,allbalance);
        selfdestruct(owner);
     
        return true;
      
        }
     
    
}