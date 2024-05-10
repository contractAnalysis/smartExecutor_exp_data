pragma solidity ^0.4.24;



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





pragma solidity ^0.4.24;

contract Ownable {

  address private _owner;

  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
  constructor() internal {
    setOwner(msg.sender);
    emit OwnershipTransferred(address(0), _owner);
  }

  
  function setOwner(address newOwner) internal {
    _owner = newOwner;
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner(), "onlyOwner: not owner");
    _;
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "transferOwnership: 0x0 invalid");
    require(newOwner != owner(), "transferOwnership: same address");
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
        require(msg.sender == blacklister, "not blacklister");
        _;
    }

    
    modifier notBlacklisted(address _account) {
        require(blacklisted[_account] == false, "notBlacklisted: is blacklisted");
        _;
    }

    
    function isBlacklisted(address _account) public view returns (bool) {
        return blacklisted[_account];
    }

    
    function blacklist(address _account) public onlyBlacklister {
        require(_account != address(0), "blacklist: 0x0 invalid");
        require(!isBlacklisted(_account), "blacklist: already blacklisted");
        blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    
    function unBlacklist(address _account) public onlyBlacklister {
        require(_account != address(0), "unBlacklist: 0x0 invalid");
        require(isBlacklisted(_account), "unBlacklist: not blacklisted");
        blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }

    function updateBlacklister(address _newBlacklister) public onlyOwner {
        require(_newBlacklister != address(0), "updateBlacklister: 0x0 invalid");
        require(_newBlacklister != blacklister, "updateBlacklister: same address");
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
    require(!paused, "whenNotPaused: contract paused");
    _;
  }

  
  modifier onlyPauser() {
    require(msg.sender == pauser, "pauser only");
    _;
  }

  
  function pause() public onlyPauser {
    paused = true;
    emit Pause();
  }

  
  function unpause() public onlyPauser {
    paused = false;
    emit Unpause();
  }

  
  function updatePauser(address _newPauser) public onlyOwner {
    require(_newPauser != address(0), "updatePauser: 0x0 invalid");
    require(_newPauser != pauser, "updatePauser: same address");
    pauser = _newPauser;
    emit PauserChanged(pauser);
  }

}





pragma solidity ^0.4.24;



contract ERC20Recovery {
  function balanceOf(address account) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}





pragma solidity ^0.4.24;







contract FiatTokenV1 is Ownable, Pausable, Blacklistable {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    address public masterMinter;

    bool internal initialized;
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 internal totalSupply_ = 0;
    mapping(address => bool) internal minters;
    mapping(address => uint256) internal minterAllowed;

    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    
    modifier onlyMinters() {
        require(minters[msg.sender] == true, "minters only");
        _;
    }

    
    modifier onlyMasterMinter() {
        require(msg.sender == masterMinter, "master minter only");
        _;
    }

    
    function initialize(
        string _name,
        string _symbol,
        uint8 _decimals,
        address _masterMinter,
        address _pauser,
        address _blacklister,
        address _owner
    ) public {
        require(!initialized, "already initialized!");
        require(_masterMinter != address(0), "master minter can't be 0x0");
        require(_pauser != address(0), "pauser can't be 0x0");
        require(_blacklister != address(0), "blacklister can't be 0x0");
        require(_owner != address(0), "owner can't be 0x0");

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        masterMinter = _masterMinter;
        pauser = _pauser;
        blacklister = _blacklister;
        setOwner(_owner);
        initialized = true;
    }

    
    function mint(address _to, uint256 _amount)
        public
        whenNotPaused
        onlyMinters
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        returns (bool)
    {
        require(_to != address(0), "can't mint to 0x0");
        require(_amount > 0, "amount to mint has to be > 0");

        uint256 mintingAllowedAmount = minterAllowance(msg.sender);
        require(_amount <= mintingAllowedAmount, "minter allowance too low");

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
        if (minterAllowance(msg.sender) == 0) {
            minters[msg.sender] = false;
            emit MinterRemoved(msg.sender);
        }
        emit Mint(msg.sender, _to, _amount);
        emit Transfer(0x0, _to, _amount);
        return true;
    }

    
    function minterAllowance(address _minter) public view returns (uint256) {
        return minterAllowed[_minter];
    }

    
    function isMinter(address _address) public view returns (bool) {
        return minters[_address];
    }

    
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    
    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }

    
    function approve(address _spender, uint256 _amount)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_spender)
        returns (bool)
    {
        return _approve(_spender, _amount);
    }

    
    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_spender)
        returns (bool)
    {
        uint256 updatedAllowance = allowed[msg.sender][_spender].add(
            _addedValue
        );
        return _approve(_spender, updatedAllowance);
    }

    
    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_spender)
        returns (bool)
    {
        uint256 updatedAllowance = allowed[msg.sender][_spender].sub(
            _subtractedValue
        );
        return _approve(_spender, updatedAllowance);
    }

    
    function _approve(address _spender, uint256 _amount)
        internal
        returns (bool)
    {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    
    function transferFrom(address _from, address _to, uint256 _amount)
        public
        whenNotPaused
        notBlacklisted(_to)
        notBlacklisted(msg.sender)
        notBlacklisted(_from)
        returns (bool)
    {
        require(_to != address(0), "can't transfer to 0x0");
        require(_amount <= balances[_from], "insufficient balance");
        require(
            _amount <= allowed[_from][msg.sender],
            "token allowance is too low"
        );

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    
    function transfer(address _to, uint256 _amount)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        returns (bool)
    {
        require(_to != address(0), "can't transfer to 0x0");
        require(_amount <= balances[msg.sender], "insufficient balance");

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    
    function increaseMinterAllowance(address _minter, uint256 _increasedAmount)
        public
        onlyMasterMinter
    {
        require(_minter != address(0), "minter can't be 0x0");
        uint256 updatedAllowance = minterAllowance(_minter).add(
            _increasedAmount
        );
        minterAllowed[_minter] = updatedAllowance;
        minters[_minter] = true;
        emit MinterConfigured(_minter, updatedAllowance);
    }

    
    function decreaseMinterAllowance(address _minter, uint256 _decreasedAmount)
        public
        onlyMasterMinter
    {
        require(_minter != address(0), "minter can't be 0x0");
        require(minters[_minter], "not a minter");

        uint256 updatedAllowance = minterAllowance(_minter).sub(
            _decreasedAmount
        );
        minterAllowed[_minter] = updatedAllowance;
        if (minterAllowance(_minter) > 0) {
            emit MinterConfigured(_minter, updatedAllowance);
        } else {
            minters[_minter] = false;
            emit MinterRemoved(_minter);

        }
    }

    
    function burn(uint256 _amount)
        public
        whenNotPaused
        onlyMinters
        notBlacklisted(msg.sender)
    {
        uint256 balance = balances[msg.sender];
        require(_amount > 0, "burn amount has to be > 0");
        require(balance >= _amount, "balance in minter is < amount to burn");

        totalSupply_ = totalSupply_.sub(_amount);
        balances[msg.sender] = balance.sub(_amount);
        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }

    
    function lawEnforcementWipingBurn(address _from)
        public
        whenNotPaused
        onlyBlacklister
    {
        require(
            isBlacklisted(_from),
            "Can't wipe balances of a non blacklisted address"
        );
        uint256 balance = balances[_from];
        totalSupply_ = totalSupply_.sub(balance);
        balances[_from] = 0;
        emit Burn(_from, balance);
        emit Transfer(_from, address(0), balance);
    }

    
    function updateMasterMinter(address _newMasterMinter) public onlyOwner {
        require(_newMasterMinter != address(0), "master minter can't be 0x0");
        require(_newMasterMinter != masterMinter, "master minter is the same");
        masterMinter = _newMasterMinter;
        emit MasterMinterChanged(masterMinter);
    }

    
    function tokenFallback(address _from, uint256 _value, bytes _data)
        external
        pure
    {
        revert("reject EIP223 token transfers");
    }

    
    function reclaimToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "token can't be 0x0");
        ERC20Recovery token = ERC20Recovery(_tokenAddress);
        uint256 balance = token.balanceOf(this);
        require(token.transfer(owner(), balance), "reclaim token failed");
    }
}