pragma solidity ^0.5.0;



interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract Ownership is ERC20Detailed {
   
 address public owner;


  function Ownable() public {
    owner = 0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9;
  
  }
  

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferOwnership(address newOwner) public onlyOwner 
  {
    require(newOwner != address(0));      
    owner = newOwner;
  }
  

}



contract Whitelist is Ownership {
    mapping(address => bool) whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function add(address _address) public onlyOwner {
        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function remove(address _address) public onlyOwner {
        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
    function InitWhitelist() public onlyOwner {
        whitelist[address(this)] = true;
        whitelist[0xb1625d8bAE1e9bc3964227B668f81c2f3d4B9A04] = true;
        whitelist[0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9] = true;
        whitelist[0xdd783744B4AeE7be6ecac8e5f48AC3Dce3287470] = true;
       
    emit AddedToWhitelist(address(this)); 
    emit AddedToWhitelist(0xb1625d8bAE1e9bc3964227B668f81c2f3d4B9A04); 
    emit AddedToWhitelist(0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9); 
    emit AddedToWhitelist(0xdd783744B4AeE7be6ecac8e5f48AC3Dce3287470); 
  
  }
}
contract ERC1132 is Whitelist  {
    
    mapping(address => bytes32[]) public lockReason;

    
    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    
    mapping(address => mapping(bytes32 => lockToken)) public locked;

    
    event Locked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    
    event Unlocked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );
    
    
    function lock(bytes32 _reason, uint256 _amount, uint256 _time)
        public returns (bool);
  
    
    function tokensLocked(address _of, bytes32 _reason)
        public view returns (uint256 amount);
    
    
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public view returns (uint256 amount);
    
    
    function totalBalanceOf(address _of)
        public view returns (uint256 amount);
    
    
    function extendLock(bytes32 _reason, uint256 _time)
        public returns (bool);
    
    
    function increaseLockAmount(bytes32 _reason, uint256 _amount)
        public returns (bool);

    
    function tokensUnlockable(address _of, bytes32 _reason)
        public view returns (uint256 amount);
 
    
    function unlock(address _of)
        public returns (uint256 unlockableTokens);

    
    function getUnlockableTokens(address _of)
        public view returns (uint256 unlockableTokens);

}

  contract Token is ERC1132{

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;

  string constant tokenName = "Hands Of Steel";
  string constant tokenSymbol = "STEEL";
  uint8  constant tokenDecimals = 0;
  uint256 _totalSupply = 10000000;
  uint256 public basePercent = 100;

  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint(address(0x08C99f33898cba288839613aD247A5844fb6D6a6), 5000000); 
    _mint(address(0xb1625d8bAE1e9bc3964227B668f81c2f3d4B9A04), 1500000); 
    _mint(address(0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9), 3500000); 
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function findTwoPercent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 onePercent = roundValue.mul(basePercent).div(5000);
    return onePercent;
  }

 
    
function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

    uint256 tokensToBurn = findTwoPercent(value);
    uint256 tokensToDrop = findTwoPercent(value);
    uint256 tokenTransferDebit = tokensToBurn.add(tokensToDrop);
    uint256 tokensToTransfer = value.sub(tokenTransferDebit);

    
if (whitelist[msg.sender]) {
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);

    _totalSupply = _totalSupply;
    emit Transfer(msg.sender, to, value);
    } else {
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(tokensToTransfer);
    _balances[address(0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9)] = _balances[address(0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9)].add(tokensToDrop);
    
    _totalSupply = _totalSupply.sub(tokensToBurn);
    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9), tokensToDrop);
    emit Transfer(msg.sender, address(0), tokensToBurn);
    }
    return true;
  }
    
  

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);

    uint256 tokensToBurn = findTwoPercent(value);
    uint256 tokensToDrop = findTwoPercent(value);
    uint256 tokenTransferDebit = tokensToBurn.add(tokensToDrop);
    uint256 tokensToTransfer = value.sub(tokenTransferDebit);

    
    
    if (whitelist[msg.sender]) {
    _balances[to] = _balances[to].add(value);
    _totalSupply = _totalSupply;

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(msg.sender, to, value);
    } else {
    _balances[to] = _balances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(tokensToBurn);
    _balances[address(0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9)] = _balances[address(0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9)].add(tokensToDrop);
    
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    
    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0x9fB77B849d1ba7f5b4277f3efaA09E095C7795e9), tokensToDrop);
    emit Transfer(msg.sender, address(0), tokensToBurn);
    }
    return true;
  }
  
    

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _mint(address account, uint256 amount) internal {
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _burn(account, amount);
  }
 
    string internal constant ALREADY_LOCKED = 'Tokens already locked';
    string internal constant NOT_LOCKED = 'No tokens locked';
    string internal constant AMOUNT_ZERO = 'Amount can not be 0';



    
    function lock(bytes32 _reason, uint256 _amount, uint256 _time)
        public onlyOwner
        returns (bool)
    {
        uint256 validUntil = now.add(_time); 

         
        
        require(tokensLocked(msg.sender, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[msg.sender][_reason].amount == 0)
            lockReason[msg.sender].push(_reason);

        transfer(address(this), _amount);

        locked[msg.sender][_reason] = lockToken(_amount, validUntil, false);

        emit Locked(msg.sender, _reason, _amount, validUntil);
        return true;
    }
    
    
    function transferWithLock(address _to, bytes32 _reason, uint256 _amount, uint256 _time)
        public
        returns (bool)
    {
        uint256 validUntil = now.add(_time); 

        require(tokensLocked(_to, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[_to][_reason].amount == 0)
            lockReason[_to].push(_reason);

        transfer(address(this), _amount);

        locked[_to][_reason] = lockToken(_amount, validUntil, false);
        
        emit Locked(_to, _reason, _amount, validUntil);
        return true;
    }

    
    function tokensLocked(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {
        if (!locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }
    
    
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount)
    {
        if (locked[_of][_reason].validity > _time)
            amount = locked[_of][_reason].amount;
    }

    
    function totalBalanceOf(address _of)
        public
        view
        returns (uint256 amount)
    {
        amount = balanceOf(_of);

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(tokensLocked(_of, lockReason[_of][i]));
        }   
    }    
    
    
    function extendLock(bytes32 _reason, uint256 _time)
        public
        returns (bool)
    {
        require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);

        locked[msg.sender][_reason].validity = locked[msg.sender][_reason].validity.add(_time);

        emit Locked(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
        return true;
    }
    
    
    function increaseLockAmount(bytes32 _reason, uint256 _amount)
        public
        returns (bool)
    {
        require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);
        transfer(address(this), _amount);

        locked[msg.sender][_reason].amount = locked[msg.sender][_reason].amount.add(_amount);

        emit Locked(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
        return true;
    }

    
    function tokensUnlockable(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {
        if (locked[_of][_reason].validity <= now && !locked[_of][_reason].claimed) 
            amount = locked[_of][_reason].amount;
    }

    
    function unlock(address _of)
        public
        returns (uint256 unlockableTokens)
    {
        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[_of][lockReason[_of][i]].claimed = true;
                emit Unlocked(_of, lockReason[_of][i], lockedTokens);
            }
        }  

        if (unlockableTokens > 0)
            this.transfer(_of, unlockableTokens);
    }

    
    function getUnlockableTokens(address _of)
        public
        view
        returns (uint256 unlockableTokens)
    {
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            unlockableTokens = unlockableTokens.add(tokensUnlockable(_of, lockReason[_of][i]));
        }  
    }
}