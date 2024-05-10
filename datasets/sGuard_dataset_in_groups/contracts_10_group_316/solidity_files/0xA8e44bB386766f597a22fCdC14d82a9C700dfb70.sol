pragma solidity ^0.6.1;

contract hashelot_dayrings{ 

    address payable private owner;

    address payable [] public stackPlayers;

    uint public stackValue; 
    uint public stackTime;  
    uint public stackWait; 
    uint public stackSoFar; 

    constructor() public{ 
        owner = msg.sender;
        stackSoFar = 0;
        stackWait = 5748;
    }

    modifier OwnerOnly{
        if(msg.sender == owner){
            _;
        }
    }

    function dustStack() OwnerOnly public payable{
        require (block.number > stackTime+stackWait, "Unable to dust: there is an ongoing bet.");
        
        if (stackPlayers.length >= 1){
          closeBet();
        }
        uint _balance = address(this).balance;
        if(_balance > 0){ 
          owner.transfer(_balance);
        }
    }

    function closeBet() public payable {
        uint _block = block.number;
        
        require (_block > stackTime+stackWait && stackPlayers.length >= 1, "Bet closing error: no bet to claim.");
        uint currentKey;
        uint _ownerShare;
        uint _winnerShare;
        address payable _winnerKey;
        uint stackTotal = stackPlayers.length*stackValue;
        
        _ownerShare = stackTotal/100*2;
        
        _winnerShare = stackTotal-_ownerShare;

        

        currentKey = uint(keccak256(abi.encodePacked(blockhash(stackTime+stackWait+1), stackPlayers[0])));
        _winnerKey = stackPlayers[0];

        for (uint k = 1; k < stackPlayers.length; k++){
          if(uint(keccak256(abi.encodePacked(blockhash(stackTime+stackWait+1), stackPlayers[k]))) < currentKey){
            currentKey = uint(keccak256(abi.encodePacked(blockhash(stackTime+stackWait+1), stackPlayers[k])));
            _winnerKey = stackPlayers[k];
          }
        }  

        
        owner.transfer(_ownerShare);

        
        _winnerKey.transfer(_winnerShare);
        stackSoFar = stackSoFar+_winnerShare; 
        stackValue = 0;
        stackTime = 0;
        delete stackPlayers; 
    }

    function checkBalance() public view returns (uint){
        return address(this).balance;
    }

    function checkPlayers() public view returns (uint){
        return stackPlayers.length;
    }

    function depositStack() public payable{
        require (msg.value >= 1 finney, "Deposit error: not enough cash."); 

        uint _block = block.number;

        
        if (_block > stackTime+stackWait) { 

          
          if (stackPlayers.length >= 1){
            closeBet();
          }

          stackValue = msg.value; 
          stackTime = _block; 
          stackPlayers.push(msg.sender);

        }else{ 

          
          bool alreadyIn = false;
          for (uint k = 0; k < stackPlayers.length; k++){
            if (stackPlayers[k] == msg.sender){
              alreadyIn = true;
            }
          }

          if (alreadyIn){ 
            msg.sender.transfer(msg.value);
          }else{ 
            
            if (msg.value >= stackValue) {
              uint playerChange = msg.value-stackValue;
              if (playerChange > 0) {
                msg.sender.transfer(playerChange);
              }
              stackPlayers.push(msg.sender); 
            }else{ 
              msg.sender.transfer(msg.value);
            }
          }
        }
    }
}