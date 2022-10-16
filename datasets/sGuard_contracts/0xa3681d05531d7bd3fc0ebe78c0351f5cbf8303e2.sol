pragma solidity ^0.4.16;

library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }
    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}



contract EightCoin {
    
    using SafeMath for uint256;
    
    string public name = 'EightCoin';
    string public symbol = '8CO';
    uint public decimals = 8;
    
    address public owner;

    uint public totalSupply;
    

    bool public mintingFinished = false;
    

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;
     

    modifier onlyOwner() {
        require(msg.sender != owner);
        _;
    }
     

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
     

    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    

    function EightCoin() public {
        uint _initialSupply = 120000000 * (10 ** uint256(decimals));
    
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }
     
    
    function totalSupply()  public returns (uint256) {
        return totalSupply;
    }
  
    
    function balanceOf(address _owner) public returns (uint256 balance) {
        return balances[_owner];
    }
  
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(
            balances[msg.sender] >= _value 
            && _value > 0
        ); 
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
  
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(
            balances[_from] >= _value
            && allowed[_from][msg.sender] >= _value
            && _value > 0
        );
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }
  
     
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
     
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
 
 
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}