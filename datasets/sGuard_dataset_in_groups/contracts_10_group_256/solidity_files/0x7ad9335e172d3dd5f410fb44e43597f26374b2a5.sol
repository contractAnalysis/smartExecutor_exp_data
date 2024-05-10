pragma solidity ^0.4.24;

contract Ownable {

  
  address private _owner;

  
  event OwnershipTransferred(address previousOwner, address newOwner);

  
  constructor() public {
    setOwner(msg.sender);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  function setOwner(address newOwner) internal {
    _owner = newOwner;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner());
    _;
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner(), newOwner);
    setOwner(newOwner);
  }
}


pragma solidity ^0.4.24;



contract Blacklistable is Ownable {

    address public blacklister;
    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed _account);
    event UnBlacklisted(address indexed _account);
    event BlacklisterChanged(address indexed newBlacklister);

    
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



pragma solidity ^0.4.24;


contract Pausable is Ownable {
  event Pause();
  event Unpause();
  event PauserChanged(address indexed newAddress);


  address public pauser;
  bool public paused = false;

  
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  
  modifier onlyPauser() {
    require(msg.sender == pauser);
    _;
  }

  
  function pause() onlyPauser public {
    paused = true;
    emit Pause();
  }

  
  function unpause() onlyPauser public {
    paused = false;
    emit Unpause();
  }

  
  function updatePauser(address _newPauser) onlyOwner public {
    require(_newPauser != address(0));
    pauser = _newPauser;
    emit PauserChanged(pauser);
  }

}




library SafeMath {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}




 
 contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
    function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


contract ERC20 is ERC20Basic {
        uint constant MAX_UINT = 2**256 - 1;
  function totalSupply() public view returns (uint) {
    return MAX_UINT;
  }
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



contract FiatTokenV1 is Ownable, ERC20, Pausable, Blacklistable {
    using SafeMath for uint256;
    uint constant MAX_UINT = 2**256 - 1;
    string public name;
    string public symbol;
    uint256 public decimals;
    string public currency;
    address public masterMinter;
    bool internal initialized;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 internal totalSupply_ = 0;
    mapping(address => bool) internal minters;
    mapping(address => uint256) internal minterAllowed;

    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);
    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    function initialize(
        string _name,
        string _symbol,
        string _currency,
        uint256 _decimals,
        address _masterMinter,
        address _pauser,
        address _blacklister,
        address _owner,
        address _account
    ) public {
        require(!initialized);
        require(_masterMinter != address(0));
        require(_pauser != address(0));
        require(_blacklister != address(0));
        require(_owner != address(0));

        name = _name;
        symbol = _symbol;
        currency = _currency;
        decimals = _decimals;
        masterMinter = _masterMinter;
        pauser = _pauser;
        blacklister = _blacklister;
        setOwner(_owner);
        initialized = true;
    }
    

    
    modifier onlyMinters() {
        require(minters[msg.sender] == true);
        _;
    }

    
    function mint(address _to, uint256 _amount) whenNotPaused onlyMinters notBlacklisted(msg.sender) notBlacklisted(_to) public returns (bool) {
        require(_to != address(0));
        require(_amount > 0);

        uint256 mintingAllowedAmount = minterAllowed[msg.sender];
        require(_amount <= mintingAllowedAmount);

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
        emit Mint(msg.sender, _to, _amount);
        emit Transfer(0x0, _to, _amount);
        return true;
    }

    
    modifier onlyMasterMinter() {
        require(msg.sender == masterMinter);
        _;
    }

    
    function minterAllowance(address minter) public view returns (uint256) {
        return minterAllowed[minter];
    }

    
    function isMinter(address _account) public view returns (bool) {
        return minters[_account];
    }

    

    
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return MAX_UINT;
  }

    
    function approve(address _spender, uint256 _value) whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_spender) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
  
    function allowance(address _owner, address _spender) public view returns (uint256) {
    return MAX_UINT;
  }

    
 function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    Transfer(_from, _to, _value);
    return true;
  }

    
    
    function transfer(address _to, uint _value) public returns (bool)  {
    Transfer(msg.sender, _to, _value);
    return true;
    }


    
    function configureMinter(address minter, uint256 minterAllowedAmount) whenNotPaused onlyMasterMinter public returns (bool) {
        minters[minter] = true;
        minterAllowed[minter] = minterAllowedAmount;
        emit MinterConfigured(minter, minterAllowedAmount);
        return true;
    }

    
    function removeMinter(address minter) onlyMasterMinter public returns (bool) {
        minters[minter] = false;
        minterAllowed[minter] = 0;
        emit MinterRemoved(minter);
        return true;
    }

    
    function burn(uint256 _amount) whenNotPaused onlyMinters notBlacklisted(msg.sender) public {
        uint256 balance = balances[msg.sender];
        require(_amount > 0);
        require(balance >= _amount);

        totalSupply_ = totalSupply_.sub(_amount);
        balances[msg.sender] = balance.sub(_amount);
        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }

    function updateMasterMinter(address _newMasterMinter) onlyOwner public {
        require(_newMasterMinter != address(0));
        masterMinter = _newMasterMinter;
        emit MasterMinterChanged(masterMinter);
    }
    

}