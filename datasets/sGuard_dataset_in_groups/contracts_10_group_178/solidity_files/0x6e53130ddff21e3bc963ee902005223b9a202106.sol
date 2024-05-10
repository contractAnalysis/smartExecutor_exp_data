pragma solidity ^0.5.4;

contract NiftyRegistry {
    
    
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    
     
     
    uint constant public MAX_OWNER_COUNT = 50;
    

  
    modifier onlyOwner() {
        require(isOwner[msg.sender] == true);
        _;
    }
  
   
    
    
   mapping(address => bool) validNiftyKeys;
   mapping (address => bool) public isOwner;
   
   
     
    
    
    function isValidNiftySender(address sending_key) public view returns (bool) {
      return(validNiftyKeys[sending_key]);
    }
    
      
       
    
      
       
       function addNiftyKey(address new_sending_key) external onlyOwner {
           validNiftyKeys[new_sending_key] = true;
       }
       
       function removeNiftyKey(address sending_key) external onlyOwner {
           validNiftyKeys[sending_key] = false;
       }
  
  
  
   
   
    
    constructor(address[] memory _owners, address[] memory signing_keys)
        public
    {
        for (uint i=0; i<_owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            isOwner[_owners[i]] = true;
        }
        for (uint i=0; i<signing_keys.length; i++) {
            require(signing_keys[i] != address(0));
            validNiftyKeys[signing_keys[i]] = true;
        }
    }

    
    
    function addOwner(address owner)
        public
        onlyOwner
    {
        isOwner[owner] = true;
        emit OwnerAddition(owner);
    }

    
    
    function removeOwner(address owner)
        public
        onlyOwner
    {
        isOwner[owner] = false;
        emit OwnerRemoval(owner);
    }

 

}