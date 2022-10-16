pragma solidity 0.6.11;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


library Strings {
    
    function toString(uint256 value) internal pure returns (string memory) {
        
        

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
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


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));  
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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




contract ContextUpgradeSafe is Initializable {
    
    

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer { }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }

    uint256[50] private __gap;
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



contract ERC20UpgradeSafe is ContextUpgradeSafe, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    

    function __ERC20_init(string memory name, string memory symbol, uint8 decimals) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol, decimals);
    }


    function __ERC20_init_unchained(string memory name, string memory symbol, uint8 decimals) internal initializer {
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


    function addBalance(address account, uint256 amount) internal returns (bool) {
         _balances[account] = _balances[account].add(amount);
        return true;
    }

    function subtractBalance(address account, uint256 amount) internal returns (bool) {
        _balances[account] = _balances[account].sub(amount);
        return true;
    }

    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}



contract PausableUpgradeSafe is ContextUpgradeSafe {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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

    
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}



contract OwnableUpgradeSafe is ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}


contract NexxoTokensUpgrade1 is Initializable, PausableUpgradeSafe, OwnableUpgradeSafe, ERC20UpgradeSafe {

        
        	uint private _initalCapacity;
            address payable _ownerWallet;
			uint256 private _totalEthInWei;
			uint256 private _unitsOneEthCanBuy;

			uint256 private _maxEthCapToBuyToken;
			
        

         
            struct EntityStruct {
             address walletAddress;
             uint indexPointer; 
            }

            mapping (address => EntityStruct) private blockedAddressStructs;
            address[] private blockedAddressList;            
         


	    
        
       

        function __NexxoTokensUpgrade1_init(string memory name, string memory symbol, address payable ownerAccount, uint256 totalSupply, uint256 unitsOneEthCanBuy, uint8 decimals, uint256 maxEthCapToBuyToken) public initializer {
             __Ownable_init();
             __ERC20_init(name,symbol,decimals);
             __NexxoTokensUpgrade1_init_unchained(ownerAccount, totalSupply, unitsOneEthCanBuy, maxEthCapToBuyToken);
        }
        

        function __NexxoTokensUpgrade1_init_unchained(address payable ownerAccount, uint256 totalSupply, uint256 unitsOneEthCanBuy,uint256 maxEthCapToBuyToken) internal initializer {
		    _initalCapacity = totalSupply;
            _ownerWallet = ownerAccount;
			_unitsOneEthCanBuy = unitsOneEthCanBuy;
			_maxEthCapToBuyToken = maxEthCapToBuyToken;
            _mint(ownerAccount, totalSupply);
        }


      receive() external payable whenNotPaused {
        require(!isBlocked(_msgSender()), "_msgSender() is blocked.");
        require(msg.value < maxEthCapToBuyToken(),"Ether worth is greater than maxEthCapToBuyToken.");

        updateTotalEthInWei(totalEthInWei() + msg.value);
        uint256 amount = msg.value * unitsOneEthCanBuy();
        require(balanceOf(ownerWallet()) >= amount, "Custom-Token : amount more than balance");

        subtractBalance(ownerWallet(), amount);
        addBalance(_msgSender(),amount);

        emit Transfer(ownerWallet(), _msgSender(), amount); 
        ownerWallet().transfer(msg.value);   
    }


    function updateTotalEthInWei(uint256 ethInWei) internal returns (bool) {
		_totalEthInWei = ethInWei;
		return true;
	}

	function initalCapacity() public view returns (uint) {
		return _initalCapacity;
	}

	function unitsOneEthCanBuy() public view returns (uint256) {
		return _unitsOneEthCanBuy;
	}

	function totalEthInWei() public view returns (uint256) {
		return _totalEthInWei;
	}

	function ownerWallet() public view returns (address payable) {
		return _ownerWallet;
	}

	function maxEthCapToBuyToken() public view returns (uint256) {
		return _maxEthCapToBuyToken;
	}

	function setMaxEthCapToBuyToken(uint256 newEthCapToBuy) public onlyOwner returns (bool)  {
	    require(newEthCapToBuy > 0, "Must be greater than zero.");
    	_maxEthCapToBuyToken = newEthCapToBuy;
    	return true;
    }

    function transferFrom(address from, address to, uint tokens) public  override whenNotPaused returns (bool success)  {
        require(!isBlocked(from), "from-address is blocked.");
        require(!isBlocked(to), "to-address is blocked.");

        return super.transferFrom(from, to, tokens);
    }

    function transfer(address to, uint tokens) public override whenNotPaused returns (bool success) {
        require(!isBlocked(to), "to-address is blocked.");
        require(!isBlocked(_msgSender()), "_msgSender() is blocked.");

        return super.transfer(to, tokens);
    }

    function burn(uint256 amount) public onlyOwner{
        super._burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public onlyOwner {
        super._burn(account, amount);
    }

    function pause() public whenNotPaused onlyOwner {
        super._pause();
    }

    function unpause() public whenPaused onlyOwner{
         super._unpause();
    }


  

         function isBlocked(address walletAddress) internal view returns (bool isExists){
           if(blockedAddressList.length == 0) return false;
            return (blockedAddressList[blockedAddressStructs[walletAddress].indexPointer] == walletAddress);
         }

         function getBlockedAddressCount() public onlyOwner view returns(uint blockedWalletAddressCount) {
           return blockedAddressList.length;
         }

         function getBlockedAddressList() public onlyOwner view returns(address [] memory) {
           return blockedAddressList;
         }

       function blockWalletAddress(address walletAddress) public onlyOwner returns(bool success) {
         require(!isBlocked(walletAddress), "walletAddress is already blocked.");

         blockedAddressStructs[walletAddress].walletAddress = walletAddress;
         blockedAddressList.push(walletAddress);
         blockedAddressStructs[walletAddress].indexPointer = blockedAddressList.length - 1;
         return true;
       }

      function unblockWalletAddress(address walletAddress) public onlyOwner returns(bool success) {
          require(isBlocked(walletAddress), "walletAddress is not blocked yet.");
          require((blockedAddressList.length != 0), "blockedAddressList is empty.");

         uint rowToDelete = blockedAddressStructs[walletAddress].indexPointer;
         address keyToMove   = blockedAddressList[blockedAddressList.length-1];
         blockedAddressList[rowToDelete] = keyToMove;

         blockedAddressStructs[keyToMove].indexPointer = rowToDelete;
         blockedAddressList.pop();
         return true;
       }

   

 }