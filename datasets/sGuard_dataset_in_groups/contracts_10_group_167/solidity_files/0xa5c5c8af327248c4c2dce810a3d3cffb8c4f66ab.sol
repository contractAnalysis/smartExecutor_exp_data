pragma solidity 0.5.17;


contract Context {
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

contract GovernorRole is Context {
    using Roles for Roles.Role;

    event GovernorAdded(address indexed account);
    event GovernorRemoved(address indexed account);

    Roles.Role private _governors;

    modifier onlyGovernor() {
        require(isGovernor(_msgSender()), "GovernorRole: caller does not have the governor role");
        _;
    }
    
    function isGovernor(address account) public view returns (bool) {
        return _governors.has(account);
    }

    function addGovernor(address account) public onlyGovernor {
        _addGovernor(account);
    }

    function renounceGovernor() public {
        _removeGovernor(_msgSender());
    }

    function _addGovernor(address account) internal {
        _governors.add(account);
        emit GovernorAdded(account);
    }

    function _removeGovernor(address account) internal {
        _governors.remove(account);
        emit GovernorRemoved(account);
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

contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
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
        emit Paused(_msgSender());
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }
}


contract ERC20Burnable is ERC20 {
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    
    function burnFrom(address account, uint256 amount) public {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


contract ERC20Capped is ERC20 {
    uint256 private _cap;

    
    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { 
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
    }
}


contract ERC20Mintable is MinterRole, ERC20 {
    
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}


contract ERC20Pausable is Pausable, ERC20 {
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}


contract LexToken is GovernorRole, ERC20Burnable, ERC20Capped, ERC20Mintable, ERC20Pausable {
    address payable public owner;
    uint256 public ethPurchaseRate;
    bytes32 public stamp;
    bool public forSale;
    bool public governed;
    
    event GovernedSlashStake(bytes32 indexed details);
    event GovernedTransfer(bytes32 indexed details);
    event RedeemLexToken(address indexed sender, uint256 indexed amount, bytes32 indexed details);
    event UpdateGovernance(bytes32 indexed details, bool indexed governed);
    event UpdateLexTokenOwner(address indexed owner, bytes32 indexed details);
    event UpdateLexTokenPurchaseRate(uint256 indexed ethPurchaseRate, bytes32 indexed details);
    event UpdateLexTokenSale(uint256 indexed saleAmount, bytes32 indexed details, bool indexed forSale);
    event UpdateLexTokenStamp(bytes32 indexed stamp);

    constructor (
        string memory name, 
        string memory symbol,  
        uint8 decimals,
        uint256 cap,
        uint256 _ethPurchaseRate, 
        uint256 initialOwnerAmount, 
        uint256 initialSaleAmount,
        address _governor,
        address payable _owner,
	    bytes32 _stamp,
	    bool _forSale,
        bool _governed
    ) public ERC20(name, symbol) ERC20Capped(cap) {
        ethPurchaseRate = _ethPurchaseRate;
        owner = _owner;
	    stamp = _stamp;
	    forSale = _forSale;
        governed = _governed;

	    _addGovernor(_governor);
        _addMinter(owner);
        _addPauser(owner);
        _mint(owner, initialOwnerAmount);
        _mint(address(this), initialSaleAmount);
        _setupDecimals(decimals);
    }
    
    
    function() external payable { 
        require(forSale == true, "not for sale");  
        uint256 purchaseAmount = msg.value.mul(ethPurchaseRate);
        _transfer(address(this), _msgSender(), purchaseAmount);
        (bool success, ) = owner.call.value(msg.value)(""); 
        require(success, "transfer failed");
    }

    function redeemLexToken(uint256 amount, bytes32 details) external { 
        require(amount > 0, "amount insufficient");
        burn(amount);
        emit RedeemLexToken(_msgSender(), amount, details);
    }

    
    modifier onlyOwner() {
        require(_msgSender() == owner, "not owner");
        _;
    }
    
    function stake() payable external onlyGoverned onlyOwner {}
    
    function updateGovernance(bytes32 details, bool _governed) external onlyOwner {
        governed = _governed; 
        emit UpdateGovernance(details, governed);
    }
    
    function updateLexTokenOwner(address payable _owner, bytes32 details) external onlyOwner {
        owner = _owner; 
        emit UpdateLexTokenOwner(owner, details);
    }
    
    function updateLexTokenPurchaseRate(uint256 _ethPurchaseRate, bytes32 details) external onlyOwner {
        ethPurchaseRate = _ethPurchaseRate; 
        emit UpdateLexTokenPurchaseRate(ethPurchaseRate, details);
    }
    
    function updateLexTokenSale(uint256 saleAmount, bytes32 details, bool _forSale) external onlyOwner {
        forSale = _forSale; 
        _mint(address(this), saleAmount);
        emit UpdateLexTokenSale(saleAmount, details, forSale);
    }
    
    function updateLexTokenStamp(bytes32 _stamp) external onlyOwner {
        stamp = _stamp; 
        emit UpdateLexTokenStamp(stamp);
    }

    
    modifier onlyGoverned() {
        require(governed == true, "lexToken not under governance");
        _;
    }

    function governedSlashStake(address payable to, uint256 amount, bytes32 details) external onlyGoverned onlyGovernor {
        (bool success, ) = to.call.value(amount)(""); // governance directs slashed stake
        require(success, "transfer failed");
        emit GovernedSlashStake(details);
    }

    function governedStamp(bytes32 _stamp) external onlyGoverned onlyGovernor {
        stamp = _stamp; 
        emit UpdateLexTokenStamp(stamp);
    }
    
    function governedTransfer(address from, address to, uint256 amount, bytes32 details) external onlyGoverned onlyGovernor {
        _transfer(from, to, amount); 
        emit GovernedTransfer(details);
    }
}