pragma solidity ^0.5.15;








contract ERC20Interface {
    
    function totalSupply() public view returns (uint256 totalsupply);

    
    function balanceOf(address _owner) public view returns (uint256 balance);

    
    function transfer(address _to, uint256 _value)
        public
        returns (bool success);

    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success);

    
    
    
    function approve(address _spender, uint256 _value)
        public
        returns (bool success);

    
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining);

    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}



pragma solidity ^0.5.15;



contract CustomToken is ERC20Interface {
    string public constant symbol = "ZEN";
    string public constant name = "ZenGo Token";
    uint8 public constant decimals = 18;
    uint256 _initialSupply = 1000000 * 1 ether;
    uint256 _totalSupply;

    uint256 _revertAmount = 0.001 * 1 ether;
    uint256 _falseAmount = 0.002 * 1 ether;
    uint256 _noTransferAmount = 0.003 * 1 ether;

    uint256 multiplier = 10000000000;

    event Amount(uint256 amount);

    
    address public owner;

    
    mapping(address => uint256) balances;

    
    mapping(address => mapping(address => uint256)) allowed;

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Action can only be performed by owner");
        _;
    }

    
    constructor() public {
        owner = msg.sender;
        _totalSupply = _initialSupply;
        balances[owner] = _initialSupply;
    }

    function() external payable {
        emit Amount(msg.value);
        if (
            !(msg.value == 10000000000 ||
                msg.value == 20000000000 ||
                msg.value == 30000000000)
        ) {
            revert("Illegal mint sum");
        }
        if (msg.value == 10000000000) {
            _totalSupply += 100 * 1 ether;
            balances[msg.sender] += 100 * 1 ether;
        }
        if (msg.value == 20000000000) {
            _totalSupply += 10000 * 1 ether;
            balances[msg.sender] += 10000 * 1 ether;
        }
        if (msg.value == 30000000000) {
            _totalSupply += 1000000 * 1 ether;
            balances[msg.sender] += 1000000 * 1 ether;
        }
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    
    function transfer(address _to, uint256 _amount)
        public
        returns (bool success)
    {
        require(
            msg.sender != address(0),
            "ERC20: transfer from the zero address"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");
        
        require(_amount != _revertAmount, "Trasfer of illegal amount");
        
        if (_amount == _falseAmount) {
            return false;
        }
        if (_amount == _noTransferAmount) {
            
            return true;
        }
        if (
            balances[msg.sender] >= _amount &&
            _amount > 0 &&
            balances[_to] + _amount > balances[_to]
        ) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    
    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        if (
            balances[_from] >= _amount &&
            allowed[_from][msg.sender] >= _amount &&
            _amount > 0 &&
            balances[_to] + _amount > balances[_to]
        ) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    
    
    function approve(address _spender, uint256 _amount)
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    
    function mint(uint256 _amount) public {
        _totalSupply += _amount;
        balances[msg.sender] += _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    
    function mint(uint256 _amount, address reciever) public {
        _totalSupply += _amount;
        balances[reciever] += _amount;
        emit Transfer(address(0), reciever, _amount);
    }
}