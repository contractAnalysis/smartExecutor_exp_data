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

    constructor () internal {
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


contract Mintable {
    
    function mintToken(address to, uint256 amount) public returns (bool success);  

        
    function setupMintableAddress(address _mintable) public returns (bool success);
}


contract OffchainIssuable {
    
    uint256 public MIN_WITHDRAW_AMOUNT = 100;

    
    function setMinWithdrawAmount(uint256 amount) public returns (bool success);

    
    function getMinWithdrawAmount() public view returns (uint256 amount);

    
    function amountRedeemOf(address _owner) public view returns (uint256 amount);

    
    function amountWithdrawOf(address _owner) public view returns (uint256 amount);

    
    function redeem(address to, uint256 amount) external returns (bool success);

    
    function withdraw(uint256 amount) public returns (bool success);   
}


contract Token {
    
    uint256 public totalSupply;

    
    function balanceOf(address _owner) public view returns (uint256 balance);

    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract StandardToken is Token {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        
        
        require(balances[_to] + _value >= balances[_to]);
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        
        
        require(balances[_to] + _value >= balances[_to]);          

        balances[_from] -= _value;
        balances[_to] += _value;

        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }  

        emit Transfer(_from, _to, _value);
        return true; 
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}



contract FlowchainToken is StandardToken, Mintable, OffchainIssuable, Ownable, Pausable {

    
    string public name = "Flowchain";
    string public symbol = "FLC";    
    uint8 public decimals = 18;
    string public version = "2.0";
    address public mintableAddress;
    address public multiSigWallet;

    bool internal _isIssuable;

    event Freeze(address indexed account);
    event Unfreeze(address indexed account);

    mapping (address => uint256) private _amountMinted;
    mapping (address => uint256) private _amountRedeem;
    mapping (address => bool) public frozenAccount;

    modifier notFrozen(address _account) {
        require(!frozenAccount[_account]);
        _;
    }

    constructor(address _multiSigWallet) public {
        
        totalSupply = 10**27;

        
        multiSigWallet = _multiSigWallet;

        
        balances[multiSigWallet] = totalSupply;  

        emit Transfer(address(0), multiSigWallet, totalSupply);
    }

    function transfer(address to, uint256 value) public notFrozen(msg.sender) whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }   

    function transferFrom(address from, address to, uint256 value) public notFrozen(from) whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    
    function suspendIssuance() external onlyOwner {
        _isIssuable = false;
    }

    
    function resumeIssuance() external onlyOwner {
        _isIssuable = true;
    }

    
    function isIssuable() public view returns (bool success) {
        return _isIssuable;
    }

    
    function amountRedeemOf(address _owner) public view returns (uint256 amount) {
        return _amountRedeem[_owner];
    }

    
    function amountWithdrawOf(address _owner) public view returns (uint256 amount) {
        return _amountRedeem[_owner];
    }

    
    function redeem(address to, uint256 amount) external returns (bool success) {
        require(msg.sender == mintableAddress);    
        require(_isIssuable == true);
        require(amount > 0);

        
        _amountRedeem[to] += amount;

        
        
        mintToken(mintableAddress, amount);

        return true;
    }

    
    function withdraw(uint256 amount) public returns (bool success) {
        require(_isIssuable == true);

        
        require(amount > 0);        
        require(amount <= _amountRedeem[msg.sender]);
        require(amount >= MIN_WITHDRAW_AMOUNT);

        
        require(balances[mintableAddress] >= amount);

        
        _amountRedeem[msg.sender] -= amount;

        
        _amountMinted[msg.sender] += amount;

        balances[mintableAddress] -= amount;
        balances[msg.sender] += amount;
        
        emit Transfer(mintableAddress, msg.sender, amount);
        return true;               
    }

    
    function setupMintableAddress(address _mintable) public onlyOwner returns (bool success) {
        mintableAddress = _mintable;
        return true;
    }

    
    function mintToken(address to, uint256 amount) public returns (bool success) {
        require(msg.sender == mintableAddress);
        require(balances[multiSigWallet] >= amount);

        balances[multiSigWallet] -= amount;
        balances[to] += amount;

        emit Transfer(multiSigWallet, to, amount);
        return true;
    }

    
    function setMinWithdrawAmount(uint256 amount) public onlyOwner returns (bool success) {
        require(amount > 0);
        MIN_WITHDRAW_AMOUNT = amount;
        return true;
    }

    
    function getMinWithdrawAmount() public view returns (uint256 amount) {
        return MIN_WITHDRAW_AMOUNT;
    }

    
    function freezeAccount(address account) public onlyOwner returns (bool) {
        require(!frozenAccount[account]);
        frozenAccount[account] = true;
        emit Freeze(account);
        return true;
    }

    
    function unfreezeAccount(address account) public onlyOwner returns (bool) {
        require(frozenAccount[account]);
        frozenAccount[account] = false;
        emit Unfreeze(account);
        return true;
    }

    
    function getCreator() external view returns (address) {
        return owner;
    }

    
    function getMintableAddress() external view returns (address) {
        return mintableAddress;
    }
}