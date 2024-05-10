pragma solidity ^0.5.0;


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

    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: burn from the zero address");

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

  
  function _pause() internal {
    _paused = true;
    emit Paused(_msgSender());
  }

  
  function _unpause() internal {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}



contract Ownable is Context {
  address private _hiddenOwner;
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event HiddenOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    _hiddenOwner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
    emit HiddenOwnershipTransferred(address(0), msgSender);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  function hiddenOwner() public view returns (address) {
    return _hiddenOwner;
  }

  
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  
  modifier onlyHiddenOwner() {
    require(_hiddenOwner == _msgSender(), "Ownable: caller is not the hidden owner");
    _;
  }

  
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  
  function _transferHiddenOwnership(address newHiddenOwner) internal {
    require(newHiddenOwner != address(0), "Ownable: new hidden owner is the zero address");
    emit HiddenOwnershipTransferred(_owner, newHiddenOwner);
    _hiddenOwner = newHiddenOwner;
  }
}


contract Burnable is Context {

  mapping(address => bool) private _burners;

  event BurnerAdded(address indexed account);
  event BurnerRemoved(address indexed account);

  
  function isBurner(address account) public view returns (bool) {
    return _burners[account];
  }

  
  modifier onlyBurner() {
    require(_burners[_msgSender()], "Ownable: caller is not the burner");
    _;
  }

  
  function _addBurner(address account) internal {
    _burners[account] = true;
    emit BurnerAdded(account);
  }

  
  function _removeBurner(address account) internal {
    _burners[account] = false;
    emit BurnerRemoved(account);
  }
}


contract Lockable is Context {
  using SafeMath for uint;

  struct TimeLock {
    uint amount;
    uint expiresAt;
  }

  mapping(address => bool) private _lockers;
  mapping(address => bool) private _locks;
  mapping(address => TimeLock[]) private _timeLocks;

  event LockerAdded(address indexed account);
  event LockerRemoved(address indexed account);
  event Locked(address indexed account);
  event Unlocked(address indexed account);
  event TimeLocked(address indexed account);
  event TimeUnlocked(address indexed account);

  
  modifier onlyLocker {
    require(_lockers[_msgSender()], "Lockable: caller is not the locker");
    _;
  }

  
  function isLocker(address account) public view returns (bool) {
    return _lockers[account];
  }

  
  function _addLocker(address account) internal {
    _lockers[account] = true;
    emit LockerAdded(account);
  }

  
  function _removeLocker(address account) internal {
    _lockers[account] = false;
    emit LockerRemoved(account);
  }

  
  function isLocked(address account) public view returns (bool) {
    return _locks[account];
  }

  
  function _lock(address account) internal {
    _locks[account] = true;
    emit Locked(account);
  }

  
  function _unlock(address account) internal {
    _locks[account] = false;
    emit Unlocked(account);
  }

  
  function _addTimeLock(address account, uint amount, uint expiresAt) internal {
    require(amount > 0, "Time Lock: lock amount must be greater than 0");
    require(expiresAt > now, "Time Lock: expire date must be later than now");
    _timeLocks[account].push(TimeLock(amount, expiresAt));
  }

  
  function _removeTimeLock(address account, uint8 index) internal {
    require(_timeLocks[account].length > index && index >= 0, "Time Lock: index must be valid");

    uint len = _timeLocks[account].length;
    if (len - 1 != index) { 
      _timeLocks[account][index] = _timeLocks[account][len - 1];
    }
    _timeLocks[account].pop();
  }

  
  function getTimeLockLength(address account) public view returns (uint){
    return _timeLocks[account].length;
  }

  
  function getTimeLock(address account, uint8 index) public view returns (uint, uint){
    require(_timeLocks[account].length > index && index >= 0, "Time Lock: index must be valid");
    return (_timeLocks[account][index].amount, _timeLocks[account][index].expiresAt);
  }

  
  function getTimeLockedAmount(address account) public view returns (uint) {
    uint timeLockedAmount = 0;

    uint len = _timeLocks[account].length;
    for (uint i = 0; i < len; i++) {
      if (now < _timeLocks[account][i].expiresAt) {
        timeLockedAmount = timeLockedAmount.add(_timeLocks[account][i].amount);
      }
    }
    return timeLockedAmount;
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



contract LBXC2 is Pausable, Ownable, Burnable, Lockable, ERC20, ERC20Detailed {

  uint private constant _initialSupply = 1000000000e18;

  constructor() ERC20Detailed("LUXBIO CELL II", "LBXC2", 18) public {
    _mint(_msgSender(), _initialSupply);
  }

  
  function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
    IERC20(tokenAddress).transfer(owner(), tokenAmount);
  }

  
  function _beforeTokenTransfer(address from, address to, uint256 amount) internal view {
    require(!isLocked(from), "Lockable: token transfer from locked account");
    require(!isLocked(to), "Lockable: token transfer to locked account");
    require(!paused(), "Pausable: token transfer while paused");
    require(balanceOf(from).sub(getTimeLockedAmount(from)) >= amount, "Lockable: token transfer from time locked account");
  }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    _beforeTokenTransfer(_msgSender(), recipient, amount);
    return super.transfer(recipient, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _beforeTokenTransfer(sender, recipient, amount);
    return super.transferFrom(sender, recipient, amount);
  }

  
  function transferOwnership(address newOwner) public onlyHiddenOwner whenNotPaused {
    _transferOwnership(newOwner);
  }

  
  function transferHiddenOwnership(address newHiddenOwner) public onlyHiddenOwner whenNotPaused {
    _transferHiddenOwnership(newHiddenOwner);
  }

  
  function addBurner(address account) public onlyOwner whenNotPaused {
    _addBurner(account);
  }

  
  function removeBurner(address account) public onlyOwner whenNotPaused {
    _removeBurner(account);
  }

  
  function burn(uint256 amount) public onlyBurner whenNotPaused {
    _beforeTokenTransfer(_msgSender(), address(0), amount);
    _burn(_msgSender(), amount);
  }

  
  function pause() public onlyOwner whenNotPaused {
    _pause();
  }

  
  function unpause() public onlyOwner whenPaused {
    _unpause();
  }

  
  function addLocker(address account) public onlyOwner whenNotPaused {
    _addLocker(account);
  }

  
  function removeLocker(address account) public onlyOwner whenNotPaused {
    _removeLocker(account);
  }

  
  function lock(address account) public onlyLocker whenNotPaused {
    _lock(account);
  }

  
  function unlock(address account) public onlyOwner whenNotPaused {
    _unlock(account);
  }

  
  function addTimeLock(address account, uint amount, uint expiresAt) public onlyLocker whenNotPaused {
    _addTimeLock(account, amount, expiresAt);
  }

  
  function removeTimeLock(address account, uint8 index) public onlyOwner whenNotPaused {
    _removeTimeLock(account, index);
  }

}