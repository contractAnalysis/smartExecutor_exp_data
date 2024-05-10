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