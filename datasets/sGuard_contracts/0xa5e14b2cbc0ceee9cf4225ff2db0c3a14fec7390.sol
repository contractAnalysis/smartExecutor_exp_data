pragma solidity ^0.4.18;




contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  
  function Ownable() public {
    owner = msg.sender;
  }


  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}




contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}




library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Pausable is Ownable {
    bool public isPaused;
    
    event Pause(address _owner, uint _timestamp);
    event Unpause(address _owner, uint _timestamp);
    
    modifier whenPaused {
        require(isPaused);
        _;
    }
    
    modifier whenNotPaused {
        require(!isPaused);
        _;
    }
    
    function pause() public onlyOwner whenNotPaused {
        isPaused = true;
        Pause(msg.sender, now);
    }
    
    function unpause() public onlyOwner whenPaused {
        isPaused = false;
        Unpause(msg.sender, now);
    }
}

contract Whitelist is Ownable {
    
    bool public whitelistToggle = false;
    
    mapping(address => bool) whitelistedAccounts;
    
    modifier onlyWhitelisted(address from, address to) {
        if(whitelistToggle){
            require(whitelistedAccounts[from]);
            require(whitelistedAccounts[to]);
        }
        _;
    }
    
    event Whitelisted(address account);
    event UnWhitelisted(address account);
    
    event ToggleWhitelist(address sender, uint timestamp);
    event UntoggleWhitelist(address sender, uint timestamp);
    
    function addWhitelist(address account) public onlyOwner returns(bool) {
        whitelistedAccounts[account] = true;
        Whitelisted(account);
    }
        
    function removeWhitelist(address account) public onlyOwner returns(bool) {
        whitelistedAccounts[account] = false;
        UnWhitelisted(account);
    }
    
    function toggle() external onlyOwner {
        whitelistToggle = true;
        ToggleWhitelist(msg.sender, now);
    }
    
    function untoggle() external onlyOwner {
        whitelistToggle = false;
        UntoggleWhitelist(msg.sender, now);
    }
    
    function isWhiteListed(address account) public view returns(bool){
        return whitelistedAccounts[account];
    }
    
}




contract BasicToken is ERC20Basic, Pausable, Whitelist {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) public whenNotPaused onlyWhitelisted(msg.sender, _to) returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}




contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused onlyWhitelisted(msg.sender, _to) returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract BTCE is StandardToken {
  using SafeMath for uint256;

  string public name;
  string public symbol;
  uint256 public decimals;
  
  mapping (address => bool) burners;
  uint256 public totalBurned;
  
  function BTCE() public {
     name = "BTCERC-20";
     symbol = "BTCE";
     decimals = 8;
     totalSupply = 2100000000000000;
     totalBurned = 0;
     
     balances[msg.sender] = 2100000000000000;
  }
  
  event Burned(address indexed owner, uint256 indexed value, uint256 indexed timestamp);
  event AssignedBurner(address indexed burner, uint256 indexed timestamp);
  
  function addBurner(address _burner) public onlyOwner returns (bool) {
      require(burners[_burner] == false);
      burners[_burner] = true;
      
      AssignedBurner(_burner, now);
  }
  
  function burn(uint256 _amount) public returns (bool) {
      require(burners[msg.sender] == true);
      require(balances[msg.sender] >= _amount);
      
      balances[msg.sender] = balances[msg.sender].sub(_amount);
      totalSupply = totalSupply.sub(_amount);
      totalBurned = totalBurned.add(_amount);
      
      Burned(msg.sender, _amount, now);
  }

}