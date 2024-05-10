pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract Token {

    
    function totalSupply() constant returns (uint256 supply) {}

    
    
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success) {}

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        
        
        
        
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }


    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;
    address public owner;
}



contract ERC20Token is StandardToken {

    function () {
        
        throw;
    }

    

    
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       
    string public telegram = 'https://t.me/iCareInvest';
    string public facebook = 'https://facebook.com/iCareInvest';
    string public website = 'http://icareinvest.com.vn';
    string public instroduce = "Open-ended fund iCare Investment Stock is an open-ended fund that invests in the stock market, according to a set strategy. A product of long-term assets, capturing the growth of Vietnam's stock market. The Fund's assets are independently managed and supervised at Vietnam Depository Bank and Vietnam Securities Commission.";
    address public owner;







    function ERC20Token(
        ) {
        balances[msg.sender] = 10000000 * (uint256(10) ** 1);               
        totalSupply = 10000000 * (uint256(10) ** 1);                        
        name = "iCare Investment Stock";                                   
        decimals = 1;                            
        symbol = "IIS";                            
        owner = msg.sender;
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}