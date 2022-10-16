pragma solidity ^0.4.16;

contract Ownable {
    address public owner;

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function Ownable() public {
        owner = msg.sender;
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


contract Pausable is Ownable {
    bool public paused = false;

    event Pause();
    event Unpause();

    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    
    modifier whenPaused() {
        require(paused);
        _;
    }

    
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}


contract Register is Pausable {
    mapping(address => string) public registry;

    
    function addUser(string info) public whenNotPaused {
        registry[msg.sender] = info;
    }
   
    
    function getInfo(address ethAddress) public constant returns (string) {
        return registry[ethAddress];
    }
}