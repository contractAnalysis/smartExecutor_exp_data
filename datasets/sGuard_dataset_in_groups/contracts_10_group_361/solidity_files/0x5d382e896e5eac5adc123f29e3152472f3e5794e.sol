pragma solidity 0.5.16;

contract Proxiable {
    

    event CodeAddressUpdated(address newAddress);

    function _updateCodeAddress(address newAddress) internal {
        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { 
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }

        emit CodeAddressUpdated(newAddress);
    }

    function getLogicAddress() public view returns (address logicAddress) {
        assembly { 
            logicAddress := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
        }
    }

    function proxiableUUID() public pure returns (bytes32) {
        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
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



pragma solidity ^0.5.0;




contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
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

    uint256[50] private ______gap;
}



pragma solidity 0.5.16;


contract ERC1404 is IERC20 {
    
    
    
    
    
    
    function detectTransferRestriction (address from, address to, uint256 value) public view returns (uint8);

    
    
    
    
    function messageForTransferRestriction (uint8 restrictionCode) public view returns (string memory);
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



pragma solidity 0.5.16;


contract OwnerRole {
    using Roles for Roles.Role;

    event OwnerAdded(address indexed addedOwner, address indexed addedBy);
    event OwnerRemoved(address indexed removedOwner, address indexed removedBy);

    Roles.Role private _owners;

    modifier onlyOwner() {
        require(isOwner(msg.sender), "OwnerRole: caller does not have the Owner role");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return _owners.has(account);
    }

    function addOwner(address account) public onlyOwner {
        _addOwner(account);
    }

    function removeOwner(address account) public onlyOwner {
        require(msg.sender != account, "Owners cannot remove themselves as owner");
        _removeOwner(account);
    }

    function _addOwner(address account) internal {
        _owners.add(account);
        emit OwnerAdded(account, msg.sender);
    }

    function _removeOwner(address account) internal {
        _owners.remove(account);
        emit OwnerRemoved(account, msg.sender);
    }
}



pragma solidity 0.5.16;


contract WhitelisterRole is OwnerRole {

    event WhitelisterAdded(address indexed addedWhitelister, address indexed addedBy);
    event WhitelisterRemoved(address indexed removedWhitelister, address indexed removedBy);

    Roles.Role private _whitelisters;

    modifier onlyWhitelister() {
        require(isWhitelister(msg.sender), "WhitelisterRole: caller does not have the Whitelister role");
        _;
    }

    function isWhitelister(address account) public view returns (bool) {
        return _whitelisters.has(account);
    }

    function _addWhitelister(address account) internal {
        _whitelisters.add(account);
        emit WhitelisterAdded(account, msg.sender);
    }

    function _removeWhitelister(address account) internal {
        _whitelisters.remove(account);
        emit WhitelisterRemoved(account, msg.sender);
    }

    function addWhitelister(address account) public onlyOwner {
        _addWhitelister(account);
    }

    function removeWhitelister(address account) public onlyOwner {
        _removeWhitelister(account);
    }
}



pragma solidity 0.5.16;



contract Whitelistable is WhitelisterRole {
    
    bool public isWhitelistEnabled;

    
    uint8 constant NO_WHITELIST = 0;

    
    
    mapping (address => uint8) public addressWhitelists;

    
    
    mapping(uint8 => mapping (uint8 => bool)) public outboundWhitelistsEnabled;

    
    event AddressAddedToWhitelist(address indexed addedAddress, uint8 indexed whitelist, address indexed addedBy);
    event AddressRemovedFromWhitelist(address indexed removedAddress, uint8 indexed whitelist, address indexed removedBy);
    event OutboundWhitelistUpdated(
        address indexed updatedBy, uint8 indexed sourceWhitelist, uint8 indexed destinationWhitelist, bool from, bool to);
    event WhitelistEnabledUpdated(address indexed updatedBy, bool indexed enabled);

    function _setWhitelistEnabled(bool enabled) internal {
        isWhitelistEnabled = enabled;
        emit WhitelistEnabledUpdated(msg.sender, enabled);
    }

    
    function _addToWhitelist(address addressToAdd, uint8 whitelist) internal {
        
        require(whitelist != NO_WHITELIST, "Invalid whitelist ID supplied");

        
        uint8 previousWhitelist = addressWhitelists[addressToAdd];

        
        addressWhitelists[addressToAdd] = whitelist;

        
        if(previousWhitelist != NO_WHITELIST) {
            
            emit AddressRemovedFromWhitelist(addressToAdd, previousWhitelist, msg.sender);
        }

        
        emit AddressAddedToWhitelist(addressToAdd, whitelist, msg.sender);
    }

    
    function _removeFromWhitelist(address addressToRemove) internal {
        
        uint8 previousWhitelist = addressWhitelists[addressToRemove];

        
        addressWhitelists[addressToRemove] = NO_WHITELIST;

        
        emit AddressRemovedFromWhitelist(addressToRemove, previousWhitelist, msg.sender);
    }

    
    function _updateOutboundWhitelistEnabled(uint8 sourceWhitelist, uint8 destinationWhitelist, bool newEnabledValue) internal {
        
        bool oldEnabledValue = outboundWhitelistsEnabled[sourceWhitelist][destinationWhitelist];

        
        outboundWhitelistsEnabled[sourceWhitelist][destinationWhitelist] = newEnabledValue;

        
        emit OutboundWhitelistUpdated(msg.sender, sourceWhitelist, destinationWhitelist, oldEnabledValue, newEnabledValue);
    }

    
    function checkWhitelistAllowed(address sender, address receiver) public view returns (bool) {
        
        if(!isWhitelistEnabled){
            return true;
        }

        
        uint8 senderWhiteList = addressWhitelists[sender];
        uint8 receiverWhiteList = addressWhitelists[receiver];

        
        if(senderWhiteList == NO_WHITELIST || receiverWhiteList == NO_WHITELIST){
            return false;
        }

        
        return outboundWhitelistsEnabled[senderWhiteList][receiverWhiteList];
    }

    
    function setWhitelistEnabled(bool enabled) public onlyOwner {
        _setWhitelistEnabled(enabled);
    }

    
    function addToWhitelist(address addressToAdd, uint8 whitelist) public onlyWhitelister {
        _addToWhitelist(addressToAdd, whitelist);
    }

    
    function removeFromWhitelist(address addressToRemove) public onlyWhitelister {
        _removeFromWhitelist(addressToRemove);
    }

    
    function updateOutboundWhitelistEnabled(uint8 sourceWhitelist, uint8 destinationWhitelist, bool newEnabledValue) public onlyWhitelister {
        _updateOutboundWhitelistEnabled(sourceWhitelist, destinationWhitelist, newEnabledValue);
    }
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



pragma solidity ^0.5.0;






contract ERC20 is Initializable, Context, IERC20 {
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

    uint256[50] private ______gap;
}



pragma solidity 0.5.16;


contract MinterRole is OwnerRole {

    event MinterAdded(address indexed addedMinter, address indexed addedBy);
    event MinterRemoved(address indexed removedMinter, address indexed removedBy);

    Roles.Role private _minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account, msg.sender);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account, msg.sender);
    }

    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    function removeMinter(address account) public onlyOwner {
        _removeMinter(account);
    }

}



pragma solidity 0.5.16;



contract Mintable is ERC20, MinterRole {
  event Mint(address indexed minter, address indexed to, uint256 amount);

  function _mint(address minter, address to, uint256 amount) internal returns (bool) {
      ERC20._mint(to, amount);
      emit Mint(minter, to, amount);
      return true;
  }

  
  function mint(address account, uint256 amount) public onlyMinter returns (bool) {
      return Mintable._mint(msg.sender, account, amount);
  }
}



pragma solidity 0.5.16;


contract BurnerRole is OwnerRole {

    event BurnerAdded(address indexed addedBurner, address indexed addedBy);
    event BurnerRemoved(address indexed removedBurner, address indexed removedBy);

    Roles.Role private _burners;

    modifier onlyBurner() {
        require(isBurner(msg.sender), "BurnerRole: caller does not have the Burner role");
        _;
    }

    function isBurner(address account) public view returns (bool) {
        return _burners.has(account);
    }

    function _addBurner(address account) internal {
        _burners.add(account);
        emit BurnerAdded(account, msg.sender);
    }

    function _removeBurner(address account) internal {
        _burners.remove(account);
        emit BurnerRemoved(account, msg.sender);
    }

    function addBurner(address account) public onlyOwner {
        _addBurner(account);
    }

    function removeBurner(address account) public onlyOwner {        
        _removeBurner(account);
    }

}



pragma solidity 0.5.16;



contract Burnable is ERC20, BurnerRole {
  event Burn(address indexed burner, address indexed from, uint256 amount);

  function _burn(address burner, address from, uint256 amount) internal returns (bool) {
      ERC20._burn(from, amount);
      emit Burn(burner, from, amount);
      return true;
  }

  
  function burn(address account, uint256 amount) public onlyBurner returns (bool) {
      return _burn(msg.sender, account, amount);
  }
}



pragma solidity 0.5.16;


contract RevokerRole is OwnerRole {

    event RevokerAdded(address indexed addedRevoker, address indexed addedBy);
    event RevokerRemoved(address indexed removedRevoker, address indexed removedBy);

    Roles.Role private _revokers;

    modifier onlyRevoker() {
        require(isRevoker(msg.sender), "RevokerRole: caller does not have the Revoker role");
        _;
    }

    function isRevoker(address account) public view returns (bool) {
        return _revokers.has(account);
    }

    function _addRevoker(address account) internal {
        _revokers.add(account);
        emit RevokerAdded(account, msg.sender);
    }

    function _removeRevoker(address account) internal {
        _revokers.remove(account);
        emit RevokerRemoved(account, msg.sender);
    }

    function addRevoker(address account) public onlyOwner {
        _addRevoker(account);
    }

    function removeRevoker(address account) public onlyOwner {
        _removeRevoker(account);
    }
}



pragma solidity 0.5.16;



contract Revocable is ERC20, RevokerRole {

  event Revoke(address indexed revoker, address indexed from, uint256 amount);

  function _revoke(
    address _from,
    uint256 _amount
  )
    internal
    returns (bool)
  {
    ERC20._transfer(_from, msg.sender, _amount);
    emit Revoke(msg.sender, _from, _amount);
    return true;
  }

  
  function revoke(address from, uint256 amount) public onlyRevoker returns (bool) {
      return _revoke(from, amount);
  }
}



pragma solidity 0.5.16;


contract PauserRole is OwnerRole {

    event PauserAdded(address indexed addedPauser, address indexed addedBy);
    event PauserRemoved(address indexed removedPauser, address indexed removedBy);

    Roles.Role private _pausers;

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account, msg.sender);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account, msg.sender);
    }

    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    function removePauser(address account) public onlyOwner {
        _removePauser(account);
    }
}



pragma solidity 0.5.16;



contract Pausable is PauserRole {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    
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
        emit Paused(msg.sender);
    }

    
    function _unpause() internal {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    
    function pause() public onlyPauser whenNotPaused {
        Pausable._pause();
    }

    
    function unpause() public onlyPauser whenPaused {
        Pausable._unpause();
    }
}



pragma solidity 0.5.16;










contract TokenSoftToken is Proxiable, ERC20Detailed, ERC1404, OwnerRole, Whitelistable, Mintable, Burnable, Revocable, Pausable {

    
    uint8 public constant SUCCESS_CODE = 0;
    uint8 public constant FAILURE_NON_WHITELIST = 1;
    uint8 public constant FAILURE_PAUSED = 2;
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    string public constant FAILURE_NON_WHITELIST_MESSAGE = "The transfer was restricted due to white list configuration.";
    string public constant FAILURE_PAUSED_MESSAGE = "The transfer was restricted due to the contract being paused.";
    string public constant UNKNOWN_ERROR = "Unknown Error Code";


    
    function initialize (address owner, string memory name, string memory symbol, uint8 decimals, uint256 initialSupply, bool whitelistEnabled)
        public
        initializer
    {
        ERC20Detailed.initialize(name, symbol, decimals);
        Mintable._mint(msg.sender, owner, initialSupply);
        OwnerRole._addOwner(owner);
        Whitelistable._setWhitelistEnabled(whitelistEnabled);
    }

    
    function updateCodeAddress (address newAddress) public onlyOwner {
        Proxiable._updateCodeAddress(newAddress);
    }

    
    function detectTransferRestriction (address from, address to, uint256)
        public
        view
        returns (uint8)
    {
        
        if (Pausable.paused()) {
            return FAILURE_PAUSED;
        }

        
        if(OwnerRole.isOwner(from)) {
            return SUCCESS_CODE;
        }

        
        
        if(!checkWhitelistAllowed(from, to)) {
            return FAILURE_NON_WHITELIST;
        }

        
        return SUCCESS_CODE;
    }

    
    function messageForTransferRestriction (uint8 restrictionCode)
        public
        view
        returns (string memory)
    {
        if (restrictionCode == SUCCESS_CODE) {
            return SUCCESS_MESSAGE;
        }

        if (restrictionCode == FAILURE_NON_WHITELIST) {
            return FAILURE_NON_WHITELIST_MESSAGE;
        }

        if (restrictionCode == FAILURE_PAUSED) {
            return FAILURE_PAUSED_MESSAGE;
        }

        
        return UNKNOWN_ERROR;
    }

    
    modifier notRestricted (address from, address to, uint256 value) {
        uint8 restrictionCode = detectTransferRestriction(from, to, value);
        require(restrictionCode == SUCCESS_CODE, messageForTransferRestriction(restrictionCode));
        _;
    }

    
    function transfer (address to, uint256 value)
        public
        notRestricted(msg.sender, to, value)
        returns (bool success)
    {
        success = ERC20.transfer(to, value);
    }

    
    function transferFrom (address from, address to, uint256 value)
        public
        notRestricted(from, to, value)
        returns (bool success)
    {
        success = ERC20.transferFrom(from, to, value);
    }
}