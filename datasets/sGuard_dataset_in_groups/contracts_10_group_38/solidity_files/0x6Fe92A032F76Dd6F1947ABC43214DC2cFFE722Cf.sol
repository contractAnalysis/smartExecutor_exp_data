pragma solidity ^0.6.4;


interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


library SafeMath {

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }
}


contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  address private _admin;

  address private _minter;

  
  function totalSupply() override public view returns (uint256) {
    return _totalSupply;
  }

  
  function balanceOf(address owner) override public view returns (uint256) {
    return _balances[owner];
  }

  
  function allowance(
    address owner,
    address spender
   )
    override
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  
  function transfer(address to, uint256 value) override public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  
  function approve(address spender, uint256 value) override public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    override
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  
  function mint(address to, uint256 amount) public {
    require(msg.sender == _minter);
    _mint(to, amount);
  }

  
  function burn(uint256 amount) public {
    _burn(msg.sender, amount);
  }

  function setMinter(address newMinter) public {
    require(msg.sender == _admin);
    _minter = newMinter;
  }

  function admin() public view returns (address) {
    return _admin;
  }

  function minter() public view returns (address) {
    return _minter;
  }

  
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: mint to the zero address");
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  
  function _burn(address account, uint256 amount) internal {
      require(account != address(0), "ERC20: burn from the zero address");
      _balances[account] = _balances[account].sub(amount);
      _totalSupply = _totalSupply.sub(amount);
      emit Transfer(account, address(0), amount);
  }
}

contract Token is ERC20 {
  string public constant name = "Inanomo Bounty Token";
  string public constant symbol = "IBTN";
  uint8 public constant decimals = 10;
}