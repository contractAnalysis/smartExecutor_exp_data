pragma solidity 0.5.14;


contract Context {
    
    
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract LexDAORole is Context {
    using Roles for Roles.Role;

    event LexDAOAdded(address indexed account);
    event LexDAORemoved(address indexed account);

    Roles.Role private _lexDAOs;

    modifier onlyLexDAO() {
        require(isLexDAO(_msgSender()), "LexDAORole: caller does not have the LexDAO role");
        _;
    }
    
    function isLexDAO(address account) public view returns (bool) {
        return _lexDAOs.has(account);
    }

    function addLexDAO(address account) public onlyLexDAO {
        _addLexDAO(account);
    }

    function renounceLexDAO() public {
        _removeLexDAO(_msgSender());
    }

    function _addLexDAO(address account) internal {
        _lexDAOs.add(account);
        emit LexDAOAdded(account);
    }

    function _removeLexDAO(address account) internal {
        _lexDAOs.remove(account);
        emit LexDAORemoved(account);
    }
}

contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


contract Pausable is PauserRole {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    
    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }
}


contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


contract ERC20Burnable is Context, ERC20 {
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}


contract ERC20Mintable is MinterRole, ERC20 {
    
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}


contract ERC20Capped is ERC20Mintable {
    uint256 private _cap;

    
    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }
}


contract ERC20Pausable is Pausable, ERC20 {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}


contract LexToken is LexDAORole, ERC20Detailed, ERC20Burnable, ERC20Capped, ERC20Pausable {
    
    string public stamp;

    constructor (
        string memory name, 
        string memory symbol, 
        string memory _stamp, 
        uint8 decimals,
        uint256 cap,
        uint256 initialSupply, 
        address owner,
        address _lexDAO) public 
        ERC20Detailed(name, symbol, decimals)
        ERC20Capped(cap) {
        stamp = _stamp;
		_mint(owner, initialSupply);
        _addMinter(owner);
        _addPauser(owner);
        _addLexDAO(_lexDAO);
    }
    
    function lexDAOtransfer(address from, address to, uint256 amount) public onlyLexDAO returns (bool) {
        _transfer(from, to, amount); 
        return true;
    }
    
    function lexDAOmint(address account, uint256 amount) public onlyLexDAO returns (bool) {
        _mint(account, amount); 
        return true;
    }    
    
    function lexDAOburn(address account, uint256 amount) public onlyLexDAO returns (bool) {
        _burn(account, amount); 
        return true;
    }
}


contract LexTokenFactory {
    
    uint8 public version = 1;
    
    
    string public stamp;
    uint256 public factoryFee;
    address payable public manager;
    address payable public _lexDAO; 
    
    LexToken private LT;
    
    address[] public tokens; 
    
    event LexTokenDeployed(address indexed LT, address indexed owner);
    event LexDAOPaid(uint256 indexed payment, string indexed details);
    event LexDAOTransferred(address indexed newLexDAO);
    
    constructor (string memory _stamp, uint256 _factoryFee, address payable _manager, address payable lexDAO) public 
	{
        stamp = _stamp;
        factoryFee = _factoryFee;
        manager = _manager;
        _lexDAO = lexDAO;
	}
    
    function newLexToken( 
        string memory name, 
		string memory symbol,
		string memory _stamp,
		uint8 decimals,
		uint256 cap,
		uint256 initialSupply,
		address owner) public payable {
		require(_lexDAO != address(0));
		require(msg.value == factoryFee);
       
        LT = new LexToken(
            name, 
            symbol, 
            _stamp,
            decimals,
            cap,
            initialSupply,
            owner,
            _lexDAO);
        
        tokens.push(address(LT));
        
        address(manager).transfer(msg.value);
        
        emit LexTokenDeployed(address(LT), owner);
    }
    
    function getLexTokenCount() public view returns (uint256 LexTokenCount) {
        return tokens.length;
    }
    
    
    function newFactoryFee(uint256 weiAmount) public {
        require(msg.sender == manager);
        factoryFee = weiAmount;
    }
    
    function transferManager(address payable newManager) public {
        require(msg.sender == manager);
        manager = newManager;
    }
    
    
    function payLexDAO(string memory details) public payable { 
        _lexDAO.transfer(msg.value);
        
        emit LexDAOPaid(msg.value, details);
    }
    
    function transferLexDAO(address payable newLexDAO) public {
        require(msg.sender == _lexDAO);
        _lexDAO = newLexDAO;
        
        emit LexDAOTransferred(newLexDAO);
    }
}