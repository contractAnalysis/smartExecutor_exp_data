pragma solidity ^0.6.10;

contract RUSHtoken {
  
  string private _name;

  function name() public view returns (string memory) {
    return _name;
  }

  
  string private _symbol;

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  
  uint8 private _decimals;

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  
  uint256 private _totalSupply;

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  
  mapping (address => uint256) private _balances;

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  
  event Transfer(address indexed from, address indexed to, uint256 value);

  
  function transfer(address recipient, uint256 amount) public returns (bool) {
    
    require(recipient != address(0), "Transfer to the zero address");
    
    require(amount <= _balances[msg.sender], "Transfer amount exceeds balance");
    
    _balances[msg.sender] -= amount;
    
    uint256 newBalance = _balances[recipient] + amount;
    require(newBalance >= _balances[recipient], "Addition overflow");
    _balances[recipient] = newBalance;
    
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  
  mapping (address => mapping (address => uint256)) private _allowances;

  
  
  event Approval(address indexed owner, address indexed spender, uint256 value);

  
  function approve(address spender, uint256 amount) public returns (bool) {
    
    require(spender != address(0), "Approve to the zero address");
    
    _allowances[msg.sender][spender] = amount;
    
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    
    require(recipient != address(0), "Transfer to the zero address");
    
    require(amount <= _balances[sender], "Transfer amount exceeds balance");
    
    _balances[sender] -= amount;
    
    require(amount <= _allowances[sender][msg.sender], "Transfer amount exceeds allowance");
    
    _allowances[sender][msg.sender] -= amount;
    
    uint256 newBalance = _balances[recipient] + amount;
    require(newBalance >= _balances[recipient], "Addition overflow");
    _balances[recipient] = newBalance;
    
    emit Transfer(sender, recipient, amount);
    return true;
  }

  
  constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 total) public {
    require(bytes(tokenName).length > 0);
    require(bytes(tokenSymbol).length > 0);
    require(total > 0);

    _name = tokenName;
    _symbol = tokenSymbol;
    _decimals = tokenDecimals;
    _totalSupply = total * 10 ** uint256(_decimals);
    _balances[msg.sender] = _totalSupply;
  }
}