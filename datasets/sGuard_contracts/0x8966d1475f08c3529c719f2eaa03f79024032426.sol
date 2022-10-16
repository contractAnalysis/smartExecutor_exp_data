pragma solidity ^0.4.24;




contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  
  constructor() public {
    owner = msg.sender;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}




contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  
  modifier whenPaused() {
    require(paused);
    _;
  }

  
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}




contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}




library SafeMath {

  
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}




contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}




contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}




contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}




contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}




contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}




contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}




contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    
    

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}




contract StandardBurnableToken is BurnableToken, StandardToken {

  
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
    
    
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}




contract MaraCoin is MintableToken, PausableToken, StandardBurnableToken, DetailedERC20 {
    event EnabledWhitelist();
    event DisabledWhitelist();
    event ChangedWhitelistManager(address indexed whitelistManager);
    event AddedRecipientToWhitelist(address indexed recipient);
    event AddedSenderToWhitelist(address indexed sender);
    event RemovedRecipientFromWhitelist(address indexed recipient);
    event RemovedSenderFromWhitelist(address indexed sender);

    
    bool public whitelist = true;

    
    address public whitelistManager;

    
    mapping(address => bool) public whitelistedRecipients;

    
    mapping(address => bool) public whitelistedSenders;

    
    constructor(address initialAccount, uint256 initialBalance)
        DetailedERC20("MaraCoin", "MARA", 18)
        public
    {
        totalSupply_ = initialBalance;
        balances[initialAccount] = initialBalance;
        emit Transfer(address(0), initialAccount, initialBalance);
    }

    
    modifier onlyWhitelistManager() {
        require(msg.sender == whitelistManager);
        _;
    }

    
    function enableWhitelist() external onlyOwner {
        require(
            !whitelist,
            'Whitelist is already enabled'
        );

        whitelist = true;
        emit EnabledWhitelist();
    }
    
    
    function disableWhitelist() external onlyOwner {
        require(
            whitelist,
            'Whitelist is already disabled'
        );

        whitelist = false;
        emit DisabledWhitelist();
    }

    
    function changeWhitelistManager(address _whitelistManager) external onlyOwner
    {
        require(_whitelistManager != address(0));

        whitelistManager = _whitelistManager;

        emit ChangedWhitelistManager(whitelistManager);
    }

    
    function addRecipientToWhitelist(address _recipient) external onlyWhitelistManager
    {
        require(
            !whitelistedRecipients[_recipient],
            'Recipient already whitelisted'
        );

        whitelistedRecipients[_recipient] = true;

        emit AddedRecipientToWhitelist(_recipient);
    }

    
    function addSenderToWhitelist(address _sender) external onlyWhitelistManager
    {
        require(
            !whitelistedSenders[_sender],
            'Sender already whitelisted'
        );

        whitelistedSenders[_sender] = true;

        emit AddedSenderToWhitelist(_sender);
    }

    
    function removeRecipientFromWhitelist(address _recipient) external onlyWhitelistManager
    {
        require(
            whitelistedRecipients[_recipient],
            'Recipient not whitelisted'
        );

        whitelistedRecipients[_recipient] = false;

        emit RemovedRecipientFromWhitelist(_recipient);
    }

    
    function removeSenderFromWhitelist(address _sender) external onlyWhitelistManager
    {
        require(
            whitelistedSenders[_sender],
            'Sender not whitelisted'
        );

        whitelistedSenders[_sender] = false;

        emit RemovedSenderFromWhitelist(_sender);
    }

    
    function transfer(address _to, uint256 _value) public returns (bool)
    {
        if (whitelist) {
            require (
                whitelistedSenders[msg.sender]
                || whitelistedRecipients[_to]
                || msg.sender == owner
                || _to == owner,
                'Sender or recipient not whitelisted'
            );
        }
        return super.transfer(_to, _value);
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
    {
        if (whitelist) {
            require (
                whitelistedSenders[_from]
                || whitelistedRecipients[_to]
                || _from == owner
                || _to == owner,
                'Sender or recipient not whitelisted'
            );
        }

        return super.transferFrom(_from, _to, _value);
    }
}