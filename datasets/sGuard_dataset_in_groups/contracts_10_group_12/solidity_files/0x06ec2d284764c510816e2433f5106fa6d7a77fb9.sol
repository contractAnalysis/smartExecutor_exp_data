pragma solidity 0.5.13;





contract Proxy {
  
  function () payable external {
    _fallback();
  }

  
  function _implementation() internal view returns (address);

  
  function _delegate(address implementation) internal {
    assembly {
      
      
      
      calldatacopy(0, 0, calldatasize)

      
      
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      
      returndatacopy(0, 0, returndatasize)

      switch result
      
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  
  function _willFallback() internal {
  }

  
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}



pragma solidity ^0.5.0;


library ZOSLibAddress {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}



pragma solidity ^0.5.0;




contract BaseUpgradeabilityProxy is Proxy {
  
  event Upgraded(address indexed implementation);

  
  bytes32 internal constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

  
  function _implementation() internal view returns (address impl) {
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  
  function _setImplementation(address newImplementation) internal {
    require(ZOSLibAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}



pragma solidity ^0.5.0;



contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
  
  constructor(address _logic, bytes memory _data) public payable {
    assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}



pragma solidity ^0.5.0;



contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
  
  event AdminChanged(address previousAdmin, address newAdmin);

  
  bytes32 internal constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

  
  modifier ifAdmin() {
    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  
  function admin() external ifAdmin returns (address) {
    return _admin();
  }

  
  function implementation() external ifAdmin returns (address) {
    return _implementation();
  }

  
  function changeAdmin(address newAdmin) external ifAdmin {
    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  
  function upgradeTo(address newImplementation) external ifAdmin {
    _upgradeTo(newImplementation);
  }

  
  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  
  function _setAdmin(address newAdmin) internal {
    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  
  function _willFallback() internal {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}



pragma solidity ^0.5.0;



contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
  
  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));
    _setAdmin(_admin);
  }
}

contract GreenEnergy {

    address[] public allAddresses;
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	
      
   
	struct User {
	    bool whitelisted;
		uint256 balance;
		mapping(address => uint256) allowance;
	}
	

 
	struct Info {
		uint256 totalSupply;
		mapping(address => User) users;
		address admin;
		bool stopped;
	}
	
	Info private info;

	uint256 constant private initial_supply = 1e5;
	uint256 constant private new_address_supply = 1e5;
	uint256 constant private precision = 1e5; 
	uint8 constant public decimals = 3;
	
	

	
	
	
	string constant public name = "GreenEnergy";
	
	
	string constant public symbol = "GE";

	
	

	constructor() public {
	    info.stopped = false;
		info.admin = msg.sender;
		allAddresses.push(msg.sender);
		info.totalSupply = initial_supply;
		info.users[msg.sender].balance = initial_supply;
	}

	function totalSupply() public view returns (uint256) {
		return info.totalSupply;
	}

	function balanceOf(address _user) public view returns (uint256) {
		return info.users[_user].balance;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {
		return info.users[_user].allowance[_spender];
	}
	
	function approve(address _spender, uint256 _tokens) external returns (bool) {
		info.users[msg.sender].allowance[_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}



	function transfer(address _to, uint256 _tokens) external returns (bool) {
		_transfer(msg.sender, _to, _tokens);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {
		require(info.users[_from].allowance[msg.sender] >= _tokens);
		info.users[_from].allowance[msg.sender] -= _tokens;
		_transfer(_from, _to, _tokens);
		return true;
	}

	function isWhitelisted(address _user) public view returns (bool) {
		return info.users[_user].whitelisted;
	}
	
	function whitelist(address _user, bool _status) public {
		require(msg.sender == info.admin);
		info.users[_user].whitelisted = _status;
	}

	function stopped(bool _status) public {
		require(msg.sender == info.admin);
		info.stopped = _status;
	}



	function _transfer(address _from, address _to, uint256 _tokens) internal returns (uint256) {
	    
	     if(info.stopped){
            require(isWhitelisted(_from));
	    }
	    
		require(balanceOf(_from) >= _tokens);
	
	    bool isNewUser = info.users[_to].balance == 0;
	    
		info.users[_from].balance -= _tokens;
		uint256 _transferred = _tokens;
		info.users[_to].balance += _transferred;
		
		if(isNewUser && _tokens > 0){
		   allAddresses.push(_to);
	
		    uint256 i = 0;
            while (i < allAddresses.length) {
                uint256 addressBalance = info.users[allAddresses[i]].balance;
                uint256 supplyNow = info.totalSupply;
                uint256 dividends = (addressBalance * precision) / supplyNow;
                uint256 _toAdd = (dividends * new_address_supply) / precision;

                info.users[allAddresses[i]].balance += _toAdd;
                i += 1;
            }
            
            info.totalSupply = info.totalSupply + new_address_supply;
		}

		
		emit Transfer(_from, _to, _transferred);
				
		return _transferred;
	}
}