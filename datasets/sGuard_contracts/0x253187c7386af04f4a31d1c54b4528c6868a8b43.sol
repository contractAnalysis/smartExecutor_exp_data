pragma solidity 0.5.16;


contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
        newOwner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyNewOwner() {
        require(msg.sender != address(0));
        require(msg.sender == newOwner);
        _;
    }
    
    function isOwner(address account) public view returns (bool) {
        if( account == owner ){
            return true;
        }
        else {
            return false;
        }
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() public onlyNewOwner {
        emit OwnershipTransferred(owner, newOwner);        
        owner = newOwner;
        newOwner = address(0);
    }
}


contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () public {
        _paused = false;
    }    

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    
    modifier whenPaused() {
        require(_paused);
        _;
    }

    
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}


contract Mintable {
    using SafeMath for uint;

    function addMinter(address minter) external returns (bool success);
    function removeMinter(address minter) external returns (bool success);
    function mint(address to, uint amount) external returns (bool success);    
}


contract OffchainIssuable {
    using SafeMath for uint;

    
    function setMinWithdrawAmount(uint amount) external returns (bool success);

    
    function getMinWithdrawAmount() external view returns (uint amount);

    
    function amountRedeemOf(address _owner) external view returns (uint amount);

    
    function amountWithdrawOf(address _owner) external view returns (uint amount);

    
    function redeem(address to, uint amount) external returns (bool success);

    
    function withdraw(address pool, uint amount) external returns (bool success);
}


interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}


contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
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


contract DexToken is ERC20, ERC20Detailed, Mintable, OffchainIssuable, Ownable, Pausable {
    using SafeMath for uint;

    bool internal _isIssuable;
    uint private _min_withdraw_amount = 100;

    mapping (address => uint) private _amountMinted;
    mapping (address => uint) private _amountRedeem;

    event Freeze(address indexed account);
    event Unfreeze(address indexed account);

    mapping (address => bool) public minters;
    mapping (address => bool) public frozenAccount;

    modifier notFrozen(address _account) {
        require(!frozenAccount[_account]);
        _;
    }

    constructor () public ERC20Detailed("Dextoken Governance", "DEXG", 18) {
        _isIssuable = true;
    }

    function transfer(address to, uint value) public notFrozen(msg.sender) whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }   

    function transferFrom(address from, address to, uint value) public notFrozen(from) whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    
    function suspendIssuance() external onlyOwner {
        _isIssuable = false;
    }

    
    function resumeIssuance() external onlyOwner {
        _isIssuable = true;
    }

    
    function isIssuable() external view returns (bool success) {
        return _isIssuable;
    }

    
    function freezeAccount(address account) external onlyOwner returns (bool) {
        require(!frozenAccount[account], "ERC20: account frozen");
        frozenAccount[account] = true;
        emit Freeze(account);
        return true;
    }

    
    function unfreezeAccount(address account) external onlyOwner returns (bool) {
        require(frozenAccount[account], "ERC20: account not frozen");
        frozenAccount[account] = false;
        emit Unfreeze(account);
        return true;
    }

    
    function addMinter(address minter) external onlyOwner returns (bool success) {
        minters[minter] = true;
        return true;
    }

    function removeMinter(address minter) external onlyOwner returns (bool success) {
        minters[minter] = false;
        return true;
    }

    
    function setMinWithdrawAmount(uint amount) external onlyOwner returns (bool success) {
        require(amount > 0, "ERC20: amount invalid");
        _min_withdraw_amount = amount;
        return true;
    }

    
    function getMinWithdrawAmount() external view returns (uint amount) {
        return _min_withdraw_amount;
    }

    
    function amountRedeemOf(address _owner) external view returns (uint amount) {
        return _amountRedeem[_owner];
    }

    
    function amountWithdrawOf(address _owner) external view returns (uint amount) {
        return _amountMinted[_owner];
    }

    
    function redeem(address pool, uint amount) external returns (bool success) {
        require(minters[msg.sender], "!minter");    
        require(_isIssuable == true, "ERC20: token not issuable");
        require(amount > 0, "ERC20: amount invalid");

        
        _amountRedeem[pool].sub(amount, "ERC20: transfer amount exceeds redeem");

        
        
        _amountMinted[pool].add(amount);
        _mint(pool, amount);
        return true;
    }

    
    function withdraw(address pool, uint amount) external returns (bool success) {
        require(minters[pool], "!minter");    
        require(_isIssuable == true, "ERC20: not issuable");

        
        require(amount > 0, "ERC20: redeem must greater than zero");        
        require(amount <= _amountRedeem[msg.sender], "ERC20: redeem not enough balance");
        require(amount >= _min_withdraw_amount, "ERC20: redeem too small");

        
        _amountRedeem[msg.sender].sub(amount, "ERC20: redeem exceeds balance");

        
        _amountMinted[msg.sender].add(amount);

        _transfer(pool, msg.sender, amount);
        
        emit Transfer(pool, msg.sender, amount);
        return true;               
    }

    
    function mint(address account, uint amount) external returns (bool success) {
        require(minters[msg.sender], "!minter");    
        _amountRedeem[account].add(amount);
        return true;
    }

    
    function burn(address account, uint amount) external onlyOwner returns (bool success) {
        _burn(account, amount);
        return true;
    }    
}