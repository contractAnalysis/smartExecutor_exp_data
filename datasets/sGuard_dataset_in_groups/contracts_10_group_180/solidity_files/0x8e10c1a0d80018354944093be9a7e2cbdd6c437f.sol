pragma solidity ^0.4.22;




library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;

        return c;
    }

    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }

    function plus(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }
}




contract ERC20Token {
    uint256 public totalSupply;  
    
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}




contract StandardToken is ERC20Token {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint256 public decimals;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    
    constructor(string _name, string _symbol, uint256 _decimals) internal {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    
    function balanceOf(address _address) public view returns (uint256 balance) {
        return balances[_address];
    }

    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    
    function transfer(address _to, uint256 _value) public returns (bool) {
        executeTransfer(msg.sender, _to, _value);

        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender], "Insufficient allowance");

        allowed[_from][msg.sender] = allowed[_from][msg.sender].minus(_value);
        executeTransfer(_from, _to, _value);

        return true;
    }

    
    function executeTransfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid transfer to address zero");
        require(_value <= balances[_from], "Insufficient account balance");

        balances[_from] = balances[_from].minus(_value);
        balances[_to] = balances[_to].plus(_value);

        emit Transfer(_from, _to, _value);
    }
}






contract BurnableToken is StandardToken {
    
    event Burn(address indexed _from, uint256 _value);

    
    function burn(uint256 _value) public {
        require(_value != 0, "The amount of tokens is zero");

        address burner = msg.sender;
        require(_value <= balances[burner], "Insufficient account balance");

        balances[burner] = balances[burner].minus(_value);
        totalSupply = totalSupply.minus(_value);

        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
}





contract MintableToken is StandardToken {
    
    address public minter;

    
    modifier onlyMinter() {
        require(msg.sender == minter, "Only the owner address can mint");
        _;
    }

    
    constructor(address _minter) internal {
        minter = _minter;
    }

    
    function mint(address _to, uint256 _value) public onlyMinter {
        totalSupply = totalSupply.plus(_value);
        balances[_to] = balances[_to].plus(_value);

        emit Transfer(0x0, _to, _value);
    }


}




contract StandardMintableToken is MintableToken, BurnableToken {
    constructor(address _minter, string _name, string _symbol, uint256 _decimals)
        StandardToken(_name, _symbol, _decimals)
        MintableToken(_minter)
        
        public
    {
    mint(msg.sender, _decimals);
    }
}