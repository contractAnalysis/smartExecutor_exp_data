pragma solidity ^0.5.0;


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



pragma solidity >=0.4.24 <0.7.0;



contract Initializable {

  
  bool private initialized;

  
  bool private initializing;

  
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
    
    
    
    
    
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}



pragma solidity ^0.5.0;



contract Context is Initializable {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.5.0;


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



pragma solidity ^0.5.0;




contract PauserRole is Initializable, Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {
        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}



pragma solidity ^0.5.0;





contract Pausable is Initializable, Context, PauserRole {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    
    function initialize(address sender) public initializer {
        PauserRole.initialize(sender);

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

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[50] private ______gap;
}



pragma solidity ^0.5.0;




contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}



pragma solidity ^0.5.0;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}





pragma solidity ^0.5.0;




contract Recoverable is Ownable {

  function initialize(address sender) public initializer {
    super.initialize(sender);
  }

  
  
  function recoverTokens(IERC20 token) public onlyOwner {
    require(token.transfer(owner(), tokensToBeReturned(token)), "Transfer failed");
  }

  
  
  
  function tokensToBeReturned(IERC20 token) public view returns (uint) {
    return token.balanceOf(address(this));
  }

  
  uint256[50] private ______gap;
}



pragma solidity ^0.5.0;










contract TokenSwap is Initializable, ReentrancyGuard, Pausable, Ownable, Recoverable {

  
  IERC20 public oldToken;

  
  IERC20 public newToken;

  
  address public burnDestination;

  
  address public signerAddress;

  
  uint public totalSwapped;

  
  event Swapped(address indexed owner, uint amount);

  
  event LegacyBurn(uint amount);

  
  event SignerUpdated(address addr);

  
  function initialize(address owner, address signer, address _oldToken, address _newToken, address _burnDestination)
    public initializer {

    
    

    
    Ownable.initialize(_msgSender());
    setSignerAddress(signer);

    Pausable.initialize(owner);
    _transferOwnership(owner);

    _setBurnDestination(_burnDestination);

    oldToken = IERC20(_oldToken);
    newToken = IERC20(_newToken);
    require(oldToken.totalSupply() == newToken.totalSupply(), "Cannot create swap, old and new token supply differ");

  }

  function _swap(address whom, uint amount) internal nonReentrant {
    
    address swapper = address(this);
    
    
    totalSwapped += amount;
    require(oldToken.transferFrom(whom, swapper, amount), "Could not retrieve old tokens");
    require(newToken.transferFrom(owner(), whom, amount), "Could not send new tokens");
  }

  
  function _checkSenderSignature(address sender, uint8 v, bytes32 r, bytes32 s) internal view {
      
      bytes memory packed = abi.encodePacked(sender);
      bytes32 hashResult = keccak256(packed);
      require(ecrecover(hashResult, v, r, s) == signerAddress, "Address was not properly signed by whitelisting server");
  }

  
  function swapTokensForSender(uint amount, uint8 v, bytes32 r, bytes32 s) public whenNotPaused {
    _checkSenderSignature(msg.sender, v, r, s);
    address swapper = address(this);
    require(oldToken.allowance(msg.sender, swapper) >= amount, "You need to first approve() enough tokens to swap for this contract");
    require(oldToken.balanceOf(msg.sender) >= amount, "You do not have enough tokens to swap");
    _swap(msg.sender, amount);

    emit Swapped(msg.sender, amount);
  }

  
  function getTokensLeftToSwap() public view returns(uint) {
    return newToken.allowance(owner(), address(this));
  }

  
  function burn(uint amount) public onlyOwner {
    require(oldToken.transfer(burnDestination, amount), "Could not send tokens to burn");
    emit LegacyBurn(amount);
  }

  
  function _setBurnDestination(address _destination) internal {
    burnDestination = _destination;
  }

  
  function setSignerAddress(address _signerAddress) public onlyOwner {
    signerAddress = _signerAddress;
    emit SignerUpdated(signerAddress);
  }

}