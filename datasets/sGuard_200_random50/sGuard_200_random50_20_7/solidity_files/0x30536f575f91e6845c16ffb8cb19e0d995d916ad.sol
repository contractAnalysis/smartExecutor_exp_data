pragma solidity 0.5.12;


library Roles {
  struct Role {
    mapping(address => bool) bearer;
  }

  
  function add(Role storage role, address account) internal {
    require(!has(role, account), 'Roles: account already has role');
    role.bearer[account] = true;
  }

  
  function remove(Role storage role, address account) internal {
    require(has(role, account), 'Roles: account does not have role');
    role.bearer[account] = false;
  }

  
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0), 'Roles: account is the zero address');
    return role.bearer[account];
  }
}



pragma solidity 0.5.12;


contract Initializable {
  
  bool private initialized;

  
  bool private initializing;

  
  modifier initializer() {
    require(
      initializing || isConstructor() || !initialized,
      'Contract instance has already been initialized'
    );

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
    
    
    
    
    
    uint256 cs;
    assembly {
      cs := extcodesize(address)
    } 
    return cs == 0;
  }

  
  uint256[50] private initializableGap;
}



pragma solidity 0.5.12;



contract Context is Initializable {
  
  
  constructor() internal {} 

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}



pragma solidity 0.5.12;


library SafeMath {
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  
  function sub(uint256 a, uint256 b, string memory errorMessage)
    internal
    pure
    returns (uint256)
  {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  
  function div(uint256 a, uint256 b, string memory errorMessage)
    internal
    pure
    returns (uint256)
  {
    
    require(b > 0, errorMessage);
    uint256 c = a / b;
    

    return c;
  }

  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  
  function mod(uint256 a, uint256 b, string memory errorMessage)
    internal
    pure
    returns (uint256)
  {
    require(b != 0, errorMessage);
    return a % b;
  }
}



pragma solidity 0.5.12;


interface IERC20 {
  
  function totalSupply() external view returns (uint256);

  
  function balanceOf(address account) external view returns (uint256);

  
  function transfer(address recipient, uint256 amount) external returns (bool);

  
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  
  function approve(address spender, uint256 amount) external returns (bool);

  
  function transferFrom(address sender, address recipient, uint256 amount)
    external
    returns (bool);

  
  event Transfer(address indexed from, address indexed to, uint256 value);

  
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity 0.5.12;





contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(_msgSender(), to, value);
        return true;
    }

    
    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool)
    {
        _transfer(from, to, value);
        _approve(
            from,
            _msgSender(),
            _allowances[from][_msgSender()].sub(value)
        );
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue)
        );
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount)
        internal
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    uint256[50] private erc20Gap;
}



pragma solidity 0.5.12;



contract ERC20Detailed is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    function initialize(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() external view returns (string memory) {
        return _name;
    }

    
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    uint256[50] private erc20DetailedGap;
}



pragma solidity 0.5.12;


contract Ownable is ERC20Detailed {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  
  function initialize(address sender) public initializer {
    _owner = sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  
  function owner() external view returns (address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner(), 'Ownable: caller is not the owner');
    _;
  }

  
  function isOwner() public view returns (bool) {
    return _msgSender() == _owner;
  }

  
  function transferOwnership(address newOwner) external onlyOwner {
    _transferOwnership(newOwner);
  }

  
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[50] private ownableGap;
}



pragma solidity 0.5.12;



contract Pausable is Ownable {
  
  event Paused(address account);

  
  event Unpaused(address account);

  bool private _paused;

  
  function initialize() public initializer {
    _paused = false;
  }

  
  function paused() external view returns (bool) {
    return _paused;
  }

  
  modifier whenNotPaused() {
    require(!_paused, 'Pausable: paused');
    _;
  }

  
  modifier whenPaused() {
    require(_paused, 'Pausable: not paused');
    _;
  }

  
  function pause() external onlyOwner whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  
  function unpause() external onlyOwner whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }

  uint256[50] private pausableGap;
}



pragma solidity 0.5.12;



contract AdminRole is Pausable {
  using Roles for Roles.Role;

  event AdminAdded(address indexed account);
  event AdminRemoved(address indexed account);

  Roles.Role private _admins;

  modifier onlyAdmin() {
    require(
      isAdmin(_msgSender()),
      'AdminRole: caller does not have the Admin role'
    );
    _;
  }

  function isAdmin(address account) public view returns (bool) {
    return _admins.has(account);
  }

  
  function addAdmin(address account) external onlyOwner {
    _addAdmin(account);
  }

  
  function removeAdmin(address account) external onlyOwner {
    _removeAdmin(account);
  }

  
  function renounceAdmin() external {
    _removeAdmin(_msgSender());
  }

  function _addAdmin(address account) internal {
    _admins.add(account);
    emit AdminAdded(account);
  }

  function _removeAdmin(address account) internal {
    _admins.remove(account);
    emit AdminRemoved(account);
  }

  uint256[50] private adminRoleGap;
}



pragma solidity 0.5.12;


contract StateManager is AdminRole {
  event WhitelistedAdded(address indexed account);
  event WhitelistedRemoved(address indexed account);

  event BlockedAdded(address indexed account);
  event BlockedRemoved(address indexed account);

  event BlacklistedAdded(address indexed account);

  enum States { None, Whitelisted, Blacklisted, Blocked }
  mapping(address => uint256) internal addressState;

  modifier notBlocked() {
    require(!isBlocked(_msgSender()), "Blocked: caller is not blocked ");
    _;
  }
  modifier notBlacklisted() {
    require(
      !isBlacklisted(_msgSender()),
      "Blacklisted: caller is not blacklisted"
    );
    _;
  }

  function isWhitelisted(address account) public view returns (bool) {
    return addressState[account] == uint256(States.Whitelisted);
  }

  function isBlocked(address account) public view returns (bool) {
    return addressState[account] == uint256(States.Blocked);
  }

  function isBlacklisted(address account) public view returns (bool) {
    return addressState[account] == uint256(States.Blacklisted);
  }

  function addWhitelisted(address account) external onlyAdmin whenNotPaused {
    require(!isWhitelisted(account), "Whitelisted: already whitelisted");
    require(!isBlocked(account), "Whitelisted: cannot add Blocked accounts");
    require(
      !isBlacklisted(account),
      "Whitelisted: cannot add Blacklisted accounts"
    );
    _addWhitelisted(account);
  }

  function addBlocked(address account) external onlyAdmin {
    require(!isBlocked(account), "Blocked: already blocked");
    require(
      !isBlacklisted(account),
      "Blocked: cannot add Blacklisted accounts"
    );
    _addBlocked(account);
  }

  function addBlacklisted(address account) external onlyAdmin {
    require(!isBlacklisted(account), "Blacklisted: already Blacklisted");
    _addBlacklisted(account);
  }

  function removeWhitelisted(address account) external onlyAdmin whenNotPaused {
    _removeWhitelisted(account);
  }

  function removeBlocked(address account) external onlyAdmin whenNotPaused {
    _removeBlocked(account);
  }

  function renounceWhitelisted() external whenNotPaused {
    _removeWhitelisted(_msgSender());
  }

  function _addWhitelisted(address account) internal {
    addressState[account] = uint256(States.Whitelisted);
    emit WhitelistedAdded(account);
  }
  function _addBlocked(address account) internal {
    addressState[account] = uint256(States.Blocked);
    emit BlockedAdded(account);
  }

  function _addBlacklisted(address account) internal {
    addressState[account] = uint256(States.Blacklisted);
    emit BlacklistedAdded(account);
  }

  function _removeWhitelisted(address account) internal {
    delete addressState[account];
    emit WhitelistedRemoved(account);
  }

  function _removeBlocked(address account) internal {
    delete addressState[account];
    emit BlockedRemoved(account);
  }

  uint256[50] private stateManagerGap;
}



pragma solidity 0.5.12;



contract ERC20Pausable is StateManager {
    function transfer(address to, uint256 value)
        public
        whenNotPaused
        notBlacklisted
        notBlocked
        returns (bool)
    {
        require(!isBlacklisted(to), "Cannot send to Blacklisted Address");
        require(!isBlocked(to), "Cannot send to blocked Address");
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        whenNotPaused
        notBlacklisted
        notBlocked
        returns (bool)
    {
        require(!isBlacklisted(to), "Cannot send to Blacklisted Address");
        require(!isBlocked(to), "Cannot send to blocked Address");
        require(!isBlacklisted(from), "Cannot send from Blacklisted Address");
        require(!isBlocked(from), "Cannot send from blocked Address");
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value)
        public
        whenNotPaused
        notBlacklisted
        notBlocked
        returns (bool)
    {
        require(!isBlacklisted(spender), "Cannot send to Blacklisted Address");
        require(!isBlocked(spender), "Cannot send to blocked Address");
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        whenNotPaused
        notBlacklisted
        notBlocked
        returns (bool)
    {
        require(!isBlacklisted(spender), "Cannot send to Blacklisted Address");
        require(!isBlocked(spender), "Cannot send to blocked Address");
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        whenNotPaused
        notBlacklisted
        notBlocked
        returns (bool)
    {
        require(!isBlacklisted(spender), "Cannot send to Blacklisted Address");
        require(!isBlocked(spender), "Cannot send to blocked Address");
        return super.decreaseAllowance(spender, subtractedValue);
    }

    uint256[50] private erc20PausableGap;
}



pragma solidity 0.5.12;


contract QCAD is ERC20Pausable {
  function initialize(
    string calldata name,
    string calldata symbol,
    uint8 decimals,
    address[] calldata admins
  ) external initializer {
    ERC20Detailed.initialize(name, symbol, decimals);
    Ownable.initialize(_msgSender());
    Pausable.initialize();

    for (uint256 i = 0; i < admins.length; ++i) {
      _addAdmin(admins[i]);
    }
  }

  function mint(address account, uint256 amount)
    external
    onlyAdmin
    whenNotPaused
    returns (bool)
  {
    require(isWhitelisted(account), "minting to non-whitelisted address");
    _mint(account, amount);
    return true;
  }

  function burn(uint256 amount)
    external
    onlyAdmin
    whenNotPaused
    returns (bool)
  {
    _burn(address(this), amount);
    return true;
  }
}