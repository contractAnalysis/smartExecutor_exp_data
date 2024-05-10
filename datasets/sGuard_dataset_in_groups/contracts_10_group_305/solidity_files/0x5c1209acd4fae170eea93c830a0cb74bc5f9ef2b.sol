pragma solidity ^0.6.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}



pragma solidity ^0.6.0;



abstract contract ERC20Detailed is IERC20 {
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



pragma solidity ^0.6.0;


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



pragma solidity ^0.6.0;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SM:28");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SM:43");
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
        require(c / a == b, "SM:82");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SM:99");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SM:144");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.0;




contract ERC20 is Context {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function __totalSupply() internal view returns (uint256) {
        return _totalSupply;
    }

    function __balanceOf(address account) internal view returns (uint256) {
        return _balances[account];
    }

    function __transfer(address recipient, uint256 amount) internal returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function __allowance(address owner, address spender) internal view returns (uint256) {
        return _allowances[owner][spender];
    }

    function __approve(address spender, uint256 amount) internal returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function __transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20:40"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20:44");
        require(recipient != address(0), "ERC20:46");
        _balances[sender] = _balances[sender].sub(amount, "ERC20:50");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20:56");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20:66");
        require(spender != address(0), "ERC20:67");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.6.0;

contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed currentOwner,
        address indexed newOwner
    );

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(
            msg.sender == _owner,
            "Ownable : Function called by unauthorized user."
        );
        _;
    }

    function owner() external view returns (address ownerAddress) {
        ownerAddress = _owner;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
        returns (bool success)
    {
        require(newOwner != address(0), "Ownable/transferOwnership : cannot transfer ownership to zero address");
        success = _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal returns (bool success) {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        success = true;
    }
}



pragma solidity ^0.6.0;

contract UserManager {
    struct AddressSet {
        mapping(address => bool) flags;
    }

    AddressSet internal lockedUsers = AddressSet();

    function _insertLockUser(address value)
          internal
          returns (bool)
      {
          if (lockedUsers.flags[value])
              return false; 
          lockedUsers.flags[value] = true;
          return true;
      }

      function _removeLockUser(address value)
          internal
          returns (bool)
      {
          if (!lockedUsers.flags[value])
              return false; 
          lockedUsers.flags[value] = false;
          return true;
      }

      function _containsLockUser(address value)
          internal
          view
          returns (bool)
      {
          return lockedUsers.flags[value];
      }

    modifier isAllowedUser(address user) {
        require(_containsLockUser(user) == false, "sender is locked user");    
        _;
    }
}



pragma solidity ^0.6.0;





contract CojamToken is IERC20, ERC20, ERC20Detailed, Ownable, UserManager {

    event LockUser(address user);
    event UnlockUser(address user);

    constructor() ERC20Detailed("Cojam", "CT", 18) public {
        uint256 initialSupply = 5000000000 * (10 ** 18);

        _owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    
    function isLock(address target) external view returns(bool) {
        return _containsLockUser(target);
    }

    
    function lock(address[] memory targets) public onlyOwner returns(bool[] memory) {
        bool[] memory results = new bool[](targets.length);

        for(uint256 ii=0; ii<targets.length; ii++){
            require(_owner != targets[ii], "can not lock owner");     
            results[ii] = _insertLockUser(targets[ii]);
            emit LockUser(targets[ii]);
        }

        return results;
    }

    
    function unlock(address[] memory targets) public onlyOwner returns(bool[] memory) {
        bool[] memory results = new bool[](targets.length);

        for(uint256 ii=0; ii<targets.length; ii++){
            require(_owner != targets[ii], "can not unlock owner");     
            results[ii] = _removeLockUser(targets[ii]);
            emit UnlockUser(targets[ii]);
        }

        return results;
    }
    
    function transfer(address recipient, uint256 amount) external override isAllowedUser(msg.sender) returns (bool){
        return __transfer(recipient, amount);
    }

    function totalSupply() external override view returns (uint256){
        return __totalSupply();
    }

    function balanceOf(address account) external override view returns (uint256){
        return __balanceOf(account);
    }

    function allowance(address owner, address spender) external view override returns (uint256){
        return __allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) external override isAllowedUser(msg.sender) returns (bool){
        return __approve(spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override isAllowedUser(sender) returns (bool){
        return __transferFrom(sender, recipient, amount);
    }
}