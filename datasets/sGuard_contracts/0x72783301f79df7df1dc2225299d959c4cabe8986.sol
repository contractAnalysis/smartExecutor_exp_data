pragma solidity 0.4.24;

contract SafeMath {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(
            c / a == b,
            "UINT256_OVERFLOW"
        );
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(
            b <= a,
            "UINT256_UNDERFLOW"
        );
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(
            c >= a,
            "UINT256_OVERFLOW"
        );
        return c;
    }

    function max64(uint64 a, uint64 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }
}


contract IOwnable {

    function transferOwnership(address newOwner)
        public;
}

contract Ownable is
    IOwnable
{
    address public owner;

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "ONLY_CONTRACT_OWNER"
        );
        _;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract IERC20Token {

    
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    
    
    
    
    function transfer(address _to, uint256 _value)
        external
        returns (bool);

    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool);
    
    
    
    
    
    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    
    
    function totalSupply()
        external
        view
        returns (uint256);
    
    
    
    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    
    
    
    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}


contract ERC20Token is
    IERC20Token
{
    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 internal _totalSupply;

    
    
    
    
    function transfer(address _to, uint256 _value)
        external
        returns (bool)
    {
        require(
            balances[msg.sender] >= _value,
            "ERC20_INSUFFICIENT_BALANCE"
        );
        require(
            balances[_to] + _value >= balances[_to],
            "UINT256_OVERFLOW"
        );

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(
            msg.sender,
            _to,
            _value
        );

        return true;
    }

    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool)
    {
        require(
            balances[_from] >= _value,
            "ERC20_INSUFFICIENT_BALANCE"
        );
        require(
            allowed[_from][msg.sender] >= _value,
            "ERC20_INSUFFICIENT_ALLOWANCE"
        );
        require(
            balances[_to] + _value >= balances[_to],
            "UINT256_OVERFLOW"
        );

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
    
        emit Transfer(
            _from,
            _to,
            _value
        );
    
        return true;
    }

    
    
    
    
    function approve(address _spender, uint256 _value)
        external
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(
            msg.sender,
            _spender,
            _value
        );
        return true;
    }

    
    
    function totalSupply()
        external
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    
    
    
    function balanceOf(address _owner)
        external
        view
        returns (uint256)
    {
        return balances[_owner];
    }

    
    
    
    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
}

contract UnlimitedAllowanceERC20Token is
    ERC20Token
{
    uint256 constant internal MAX_UINT = 2**256 - 1;

    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool)
    {
        uint256 allowance = allowed[_from][msg.sender];
        require(
            balances[_from] >= _value,
            "ERC20_INSUFFICIENT_BALANCE"
        );
        require(
            allowance >= _value,
            "ERC20_INSUFFICIENT_ALLOWANCE"
        );
        require(
            balances[_to] + _value >= balances[_to],
            "UINT256_OVERFLOW"
        );

        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT) {
            allowed[_from][msg.sender] -= _value;
        }

        emit Transfer(
            _from,
            _to,
            _value
        );

        return true;
    }
}

contract MintableERC20Token is 
    SafeMath,
    UnlimitedAllowanceERC20Token
{
    
    
    
    function _mint(address _to, uint256 _value)
        internal
    {
        balances[_to] = safeAdd(_value, balances[_to]);
        _totalSupply = safeAdd(_totalSupply, _value);

        emit Transfer(
            address(0),
            _to,
            _value
        );
    }

    
    
    
    function _burn(address _owner, uint256 _value)
        internal
    {
        balances[_owner] = safeSub(balances[_owner], _value);
        _totalSupply = safeSub(_totalSupply, _value);

        emit Transfer(
            _owner,
            address(0),
            _value
        );
    }
}

contract DummyERC20Token is 
    Ownable,
    MintableERC20Token
{
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public constant MAX_MINT_AMOUNT = 100000000000000000000000;

    constructor (
        string _name,
        string _symbol,
        uint256 _decimals,
        uint256 _totalSupply
    )
        public
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
    }

    
    
    
    function setBalance(address _target, uint256 _value)
        external
        onlyOwner
    {
        uint256 currBalance = balances[_target];
        if (_value < currBalance) {
            _totalSupply = safeSub(_totalSupply, safeSub(currBalance, _value));
        } else {
            _totalSupply = safeAdd(_totalSupply, safeSub(_value, currBalance));
        }
        balances[_target] = _value;
    }

    
    
    function mint(uint256 _value)
        external
    {
        require(
            _value <= MAX_MINT_AMOUNT,
            "VALUE_TOO_LARGE"
        );

        _mint(msg.sender, _value);
    }
}