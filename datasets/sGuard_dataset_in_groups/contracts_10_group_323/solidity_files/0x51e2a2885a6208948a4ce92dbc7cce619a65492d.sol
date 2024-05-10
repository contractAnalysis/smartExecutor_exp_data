pragma solidity ^0.5.0;

contract DigitalSecretary {

    uint256 public entityFilings; 

    mapping (uint256 => Entity) public entities; 
    
    event entityRegistered(uint256 fileNumber, uint256 filingDate, string entityName, uint8 entityKind);
    
    struct Entity {
        uint256 fileNumber; 
        uint256 filingDate; 
        string entityName; 
        uint8 entityKind; 
        uint8 entityType; 
        string registeredAgentdetails; 
        string filingDetails; 
        address registrant; 
    }
      
    
    enum Kind {
        CORP,
        LP,
        LLC,
        TRUST,
        PARTNERSHIP,
        UNPA
    }
    
    
    enum Type {
        GENERAL,
        BANK,
        CLOSED,
        DISC,
        PA,
        GP,
        RIC,
        LLP,
        NT,
        NP,
        STOCK
    }
    
    
    function registerEntity(
        string memory entityName,
        uint8 entityKind,
        uint8 entityType,
        string memory registeredAgentdetails,
        string memory filingDetails) public {
            
        Kind(entityKind);
        Type(entityType);
        
        uint256 fileNumber = entityFilings + 1; 
        uint256 filingDate = block.timestamp; 
        
        entityFilings = entityFilings + 1; 
            
        entities[fileNumber] = Entity(
            fileNumber,
            filingDate,
            entityName,
            entityKind,
            entityType,
            registeredAgentdetails,
            filingDetails,
            msg.sender);
            
            emit entityRegistered(fileNumber, filingDate, entityName, entityKind);
    }
    
    
    
    function updateEntityName(uint256 fileNumber, string memory newName) public {
        Entity storage entity = entities[fileNumber];
        require(msg.sender == entity.registrant);
        entity.entityName = newName; 
    }
    
    
    function updateRegisteredAgent(uint256 fileNumber, string memory registeredAgentdetails) public {
        Entity storage entity = entities[fileNumber];
        require(msg.sender == entity.registrant);
        entity.registeredAgentdetails = registeredAgentdetails; 
    }
    
    
    function convertEntityKind(uint256 fileNumber, uint8 newKind) public {
        Entity storage entity = entities[fileNumber];
        require(msg.sender == entity.registrant);
        entity.entityKind = newKind; 
    }
    
    
    function convertEntityType(uint256 fileNumber, uint8 newType) public {
        Entity storage entity = entities[fileNumber];
        require(msg.sender == entity.registrant);
        entity.entityType = newType; 
    }
}