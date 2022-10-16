pragma solidity 0.4.19;

contract Token {

    
    function totalSupply() constant returns (uint supply) {}

    
    
    function balanceOf(address _owner) constant returns (uint balance) {}

    
    
    
    
    function transfer(address _to, uint _value) returns (bool success) {}

    
    
    
    
    
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint _value) returns (bool success) {}

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Mint(address indexed _owner, uint _amount);
}

contract StandardToken is Token {

    function transfer(address _to, uint _value) public returns (bool) {
        
        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalSupply;
    address public owner;
}

contract ExtendToken is StandardToken {

    uint constant MAX_UINT = 2**256 - 1;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool)
    {
        uint allowance = allowed[_from][msg.sender];
        if (balances[_from] >= _value && allowance >= _value && balances[_to] + _value >= balances[_to] ) {
            balances[_to] += _value;
            balances[_from] -= _value;
            if (allowance < MAX_UINT) {
                allowed[_from][msg.sender] -= _value;
            }
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    
    function mint(uint256 _amount) onlyOwner public returns (bool) {
        totalSupply = totalSupply + _amount;
        balances[owner] = balances[owner] + _amount;
        Mint(owner, _amount);
        Transfer(address(0), owner, _amount);
        return true;
    }
}

contract AGCToken is ExtendToken {

    uint8 constant public decimals = 18;
    string constant public name = "AngelCity";
    string constant public symbol = "AGC";

    function AGCToken() public {
        totalSupply = 5000000000; 
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }
}