pragma solidity ^0.5.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    
    constructor() public {
        owner = msg.sender;
    }


    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    
    modifier whenPaused() {
        require(paused);
        _;
    }

    
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}


contract Blacklistable is Pausable {

    address public blacklister;
    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed _account);
    event UnBlacklisted(address indexed _account);
    event BlacklisterChanged(address indexed newBlacklister);

    constructor() public {
        blacklister = msg.sender;
    }

    
    modifier onlyBlacklister() {
        require(msg.sender == blacklister);
        _;
    }

    
    modifier notBlacklisted(address _account) {
        require(blacklisted[_account] == false);
        _;
    }

    
    function isBlacklisted(address _account) public view returns (bool) {
        return blacklisted[_account];
    }

    
    function blacklist(address _account) public onlyBlacklister {
        blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    
    function unBlacklist(address _account) public onlyBlacklister {
        blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }

    function updateBlacklister(address _newBlacklister) public onlyOwner {
        require(_newBlacklister != address(0));
        blacklister = _newBlacklister;
        emit BlacklisterChanged(blacklister);
    }
}


contract StandardToken is IERC20, Pausable, Blacklistable {
    uint256 public totalSupply;

    using SafeMath for uint;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused notBlacklisted(_to) notBlacklisted(msg.sender) notBlacklisted(_from) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_spender) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_spender) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_spender) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function transfer(address _to, uint _value) whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_to) public returns (bool success) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}


contract BurnableToken is StandardToken {

  event Burn(address indexed burner, uint256 value);

  
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    
    

    balances[_who] = balances[_who].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract XBASE is BurnableToken {
    string public constant name = "Eterbase Utility Token";
    string public constant symbol = "XBASE";
    uint8 public constant decimals = 18;
    uint256 public constant initialSupply = 1000000 * 10 ** uint256(decimals);

    constructor () public {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
    }
}