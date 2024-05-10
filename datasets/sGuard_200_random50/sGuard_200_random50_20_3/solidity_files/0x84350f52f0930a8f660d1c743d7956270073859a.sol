pragma solidity 0.5.0;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, 'only owner can make this call');
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }
}


contract EquableToken is Owned {
    
    using SafeMath for uint256;
    
    string public name = "EquableToken";
    string public symbol = "EQB";
    uint8 public decimals = 8;
    uint public _totalSupply;
    
    
    constructor(uint _initialSupply) public {
        _totalSupply = _initialSupply * 10 ** uint(decimals);
        balances[0xe921c6a0Ee46685F8D7FC47272ACc4a39Cadee8f] = _totalSupply;
        emit Transfer(address(0x0), 0xe921c6a0Ee46685F8D7FC47272ACc4a39Cadee8f, _totalSupply);
    }
    
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    
    
    event Burn(address indexed from, uint value);                                                                                          
    
    
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
  
    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }
    
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balances[_from] >= _value);
        require(balances[_to].add(_value) >= balances[_to]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }
    
    
    function transfer(address _to, uint _value) public returns(bool success){
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }
    
    
    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    
    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }
    
    
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
    
    
    function mint(address _account, uint _amount) public onlyOwner {
        require(_account != address(0x0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(_amount);
        balances[_account] = balances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }
    
    
    function burn(uint _value) public onlyOwner returns (bool success) {
        require(balances[msg.sender] >= _value);   
        balances[msg.sender] = balances[msg.sender].sub(_value);
        _totalSupply = _totalSupply.sub(_value);                      
        emit Burn(msg.sender, _value);
        return true;
    }
}