pragma solidity ^0.6.0;

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


contract Context {
    
    
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;
    address private _admin;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AdminSelected(address indexed previousAdmin, address indexed newAdmin);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        _admin = address(0);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }
    
    
    function admin() public view returns (address) {
        return _admin;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    
    modifier onlyAdmin() {
        require(_admin == _msgSender(), "Ownable: caller is not the admin");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    
    
    function rejectAdmin() public virtual onlyAdmin {
        emit AdminSelected(_admin, address(0));
        _admin = address(0);
    }
    
    
    function selectAdmin(address newAdmin) public virtual onlyOwner {
        emit AdminSelected(_admin, newAdmin);
        _admin = newAdmin;
    }
    
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


contract Pausable is Context {
    
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

    
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


abstract contract ERC20Pausable is Ownable, Pausable, ERC20 {
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    
    
    function pause() public virtual onlyAdmin {
        _pause();
    }
    
    
    function unpause() public virtual onlyAdmin {
        _unpause();
    }
    
}


abstract contract ERC20Burnable is Ownable, ERC20 {
    
    function burn(address from, uint256 amount) public virtual onlyAdmin {
        _burn(from, amount);
    }
}


contract Freezable {
    mapping (address => bool) private _freezelist;
        
    event Freeze(address user);
    
    event Unfreeze(address user);
        
    
    function _freeze(address user) internal virtual {
        require(_freezelist[user] == false, "User already freezed");
        _freezelist[user] = true;
        emit Freeze(user);
    }
    
    
    function _unfreeze(address user) internal virtual {
        require(_freezelist[user] == true, "User already freezed");
        _freezelist[user] = false;
        emit Unfreeze(user);
    }
    
    
    function freezed(address user) public view returns (bool) {
        return _freezelist[user];
    }
}


abstract contract ERC20Freezable is Ownable, Freezable, ERC20  {
    
    function freeze(address user) public virtual onlyAdmin {
        _freeze(user);
    }
    
    
    function unfreeze(address user) public virtual onlyAdmin {
        _unfreeze(user);
    }
    
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!freezed(from), "ERC20Freezable: sender freezed");
        require(!freezed(to), "ERC20Freezable: receiver freezed");
    }
}


contract FumbiStable is Ownable, ERC20Pausable, ERC20Burnable, ERC20Freezable {
    
    constructor(string memory name, string memory symbol) public ERC20(name, symbol){
        _mint(0x0796fC991D6691fe1f343F10dF0E98104023186c, 1 ether / 1 wei);
    }
    
    
    function mint(address to, uint256 amount) public onlyAdmin {
        _mint(to, amount);
    }
    
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable, ERC20Freezable) {
        super._beforeTokenTransfer(from, to, amount);
    }
    
    fallback() external {
        revert();
    }
}