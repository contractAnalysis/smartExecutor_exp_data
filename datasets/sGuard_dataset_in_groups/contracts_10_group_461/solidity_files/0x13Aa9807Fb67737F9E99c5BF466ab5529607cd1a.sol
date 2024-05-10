pragma solidity ^0.6.0;


abstract contract DSProxyInterface {

    
    
    
    
    

    function execute(address _target, bytes memory _data) public virtual payable returns (bytes32);

    function setCache(address _cacheAddr) public virtual payable returns (bool);

    function owner() public virtual returns (address);
}


contract MCDMonitorProxy {

    uint public CHANGE_PERIOD;
    address public monitor;
    address public owner;
    address public newMonitor;
    uint public changeRequestedTimestamp;

    mapping(address => bool) public allowed;

    
    modifier onlyAllowed() {
        require(allowed[msg.sender] || msg.sender == owner);
        _;
    }

    modifier onlyMonitor() {
        require (msg.sender == monitor);
        _;
    }

    constructor(uint _changePeriod) public {
        owner = msg.sender;
        CHANGE_PERIOD = _changePeriod * 1 days;
    }

    
    
    function setMonitor(address _monitor) public onlyAllowed {
        require(monitor == address(0));
        monitor = _monitor;
    }

    
    
    
    
    function callExecute(address _owner, address _saverProxy, bytes memory _data) public onlyMonitor {
        
        DSProxyInterface(_owner).execute(_saverProxy, _data);
    }

    
    
    
    function changeMonitor(address _newMonitor) public onlyAllowed {
        changeRequestedTimestamp = now;
        newMonitor = _newMonitor;
    }

    
    function cancelMonitorChange() public onlyAllowed {
        changeRequestedTimestamp = 0;
        newMonitor = address(0);
    }

    
    function confirmNewMonitor() public onlyAllowed {
        require((changeRequestedTimestamp + CHANGE_PERIOD) < now);
        require(changeRequestedTimestamp != 0);
        require(newMonitor != address(0));

        monitor = newMonitor;
        newMonitor = address(0);
        changeRequestedTimestamp = 0;
    }

    
    
    function addAllowed(address _user) public onlyAllowed {
        allowed[_user] = true;
    }

    
    
    
    function removeAllowed(address _user) public onlyAllowed {
        allowed[_user] = false;
    }
}


contract Static {

    enum Method { Boost, Repay }
}

abstract contract ISubscriptions is Static {

    function canCall(Method _method, uint _cdpId) external virtual view returns(bool, uint);
    function getOwner(uint _cdpId) external virtual view returns(address);
    function ratioGoodAfter(Method _method, uint _cdpId) external virtual view returns(bool, uint);
    function getRatio(uint _cdpId) public view virtual returns (uint);
    function getSubscribedInfo(uint _cdpId) public virtual view returns(bool, uint128, uint128, uint128, uint128, address, uint coll, uint debt);
    function unsubscribeIfMoved(uint _cdpId) public virtual;
}

abstract contract Manager {
    function last(address) virtual public returns (uint);
    function cdpCan(address, uint, address) virtual public view returns (uint);
    function ilks(uint) virtual public view returns (bytes32);
    function owns(uint) virtual public view returns (address);
    function urns(uint) virtual public view returns (address);
    function vat() virtual public view returns (address);
    function open(bytes32, address) virtual public returns (uint);
    function give(uint, address) virtual public;
    function cdpAllow(uint, address, uint) virtual public;
    function urnAllow(address, uint) virtual public;
    function frob(uint, int, int) virtual public;
    function flux(uint, address, uint) virtual public;
    function move(uint, address, uint) virtual public;
    function exit(address, uint, address, uint) virtual public;
    function quit(uint, address) virtual public;
    function enter(address, uint) virtual public;
    function shift(uint, uint) virtual public;
}

contract AdminAuth {

    address public owner;
    address public admin;

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    
    
    function setAdminByOwner(address _admin) public {
        require(msg.sender == owner);
        require(admin == address(0));

        admin = _admin;
    }

    
    
    function setAdminByAdmin(address _admin) public {
        require(msg.sender == admin);

        admin = _admin;
    }

    
    
    function setOwnerByAdmin(address _owner) public {
        require(msg.sender == admin);

        owner = _owner;
    }
}

contract Auth is AdminAuth {

	bool public ALL_AUTHORIZED = false;

	mapping(address => bool) public authorized;

	modifier onlyAuthorized() {
        require(ALL_AUTHORIZED || authorized[msg.sender]);
        _;
    }

	constructor() public {
		authorized[msg.sender] = true;
	}

	function setAuthorized(address _user, bool _approved) public onlyOwner {
		authorized[_user] = _approved;
	}

	function setAllAuthorized(bool _authorized) public onlyOwner {
		ALL_AUTHORIZED = _authorized;
	}
}

abstract contract DSGuard {
    function canCall(address src_, address dst_, bytes4 sig) public view virtual returns (bool);

    function permit(bytes32 src, bytes32 dst, bytes32 sig) public virtual;

    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public virtual;

    function permit(address src, address dst, bytes32 sig) public virtual;

    function forbid(address src, address dst, bytes32 sig) public virtual;
}

abstract contract DSGuardFactory {
    function newGuard() public virtual returns (DSGuard guard);
}

abstract contract DSAuthority {
    function canCall(address src, address dst, bytes4 sig) public virtual view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority public authority;
    address public owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract ProxyPermission {
    address public constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;

    
    
    function givePermission(address _contractAddr) public {
        address currAuthority = address(DSAuth(address(this)).authority());
        DSGuard guard = DSGuard(currAuthority);

        if (currAuthority == address(0)) {
            guard = DSGuardFactory(FACTORY_ADDRESS).newGuard();
            DSAuth(address(this)).setAuthority(DSAuthority(address(guard)));
        }

        guard.permit(_contractAddr, address(this), bytes4(keccak256("execute(address,bytes)")));
    }

    
    
    function removePermission(address _contractAddr) public {
        address currAuthority = address(DSAuth(address(this)).authority());
        
        
        if (currAuthority == address(0)) {
            return;
        }

        DSGuard guard = DSGuard(currAuthority);
        guard.forbid(_contractAddr, address(this), bytes4(keccak256("execute(address,bytes)")));
    }
}

contract SubscriptionsMigration is Auth {

	
	address public proxyPermission;


	address public monitorProxyAddress = 0x93Efcf86b6a7a33aE961A7Ec6C741F49bce11DA7;
	
	MCDMonitorProxy public monitorProxyContract = MCDMonitorProxy(monitorProxyAddress);
	
	ISubscriptions public subscriptionsContract = ISubscriptions(0x83152CAA0d344a2Fd428769529e2d490A88f4393);
	
	address public subscriptionsProxyV2address = 0xd6f2125bF7FE2bc793dE7685EA7DEd8bff3917DD;
	
	address public subscriptionsV2address = 0xC45d4f6B6bf41b6EdAA58B01c4298B8d9078269a;
	
	address public subscriptionsV1address = 0x83152CAA0d344a2Fd428769529e2d490A88f4393;
	
	address public subscriptionsProxyV1address = 0xA5D33b02dBfFB3A9eF26ec21F15c43BdB53EB455;
	
	Manager public manager = Manager(0x5ef30b9986345249bc32d8928B7ee64DE9435E39);

	constructor(address _proxyPermission) public {
		proxyPermission = _proxyPermission;
	}

	function migrate(uint[] memory _cdps) public onlyAuthorized {

		for (uint i=0; i<_cdps.length; i++) {
			if (_cdps[i] == 0) continue;

			bool sub;
			uint minRatio;
			uint maxRatio;
			uint optimalRepay;
			uint optimalBoost;
			address cdpOwner;
			uint collateral;

			
			(sub, minRatio, maxRatio, optimalRepay, optimalBoost, cdpOwner, collateral,) = subscriptionsContract.getSubscribedInfo(_cdps[i]);

			
			if (cdpOwner != _getOwner(_cdps[i])) {
				continue;
			} 

			
			if (sub && collateral > 0) {
				monitorProxyContract.callExecute(cdpOwner, subscriptionsProxyV2address, abi.encodeWithSignature("migrate(uint256,uint128,uint128,uint128,uint128,bool,bool,address)", _cdps[i], minRatio, maxRatio, optimalBoost, optimalRepay, true, true, subscriptionsV2address));
			} else {
				
				if (sub) {
					_unsubscribe(_cdps[i], cdpOwner);
				}
			}

			
		}
	}

	function removeAuthority(address[] memory _users) public onlyAuthorized {

		for (uint i=0; i<_users.length; i++) {
			_removeAuthority(_users[i]);
		}
	}

	function _unsubscribe(uint _cdpId, address _cdpOwner) internal onlyAuthorized {
		address currAuthority = address(DSAuth(_cdpOwner).authority());
		
		if (currAuthority == address(0)) return;
        DSGuard guard = DSGuard(currAuthority);

        
        if (!guard.canCall(monitorProxyAddress, _cdpOwner, bytes4(keccak256("execute(address,bytes)")))) return;

        
		monitorProxyContract.callExecute(_cdpOwner, subscriptionsProxyV1address, abi.encodeWithSignature("unsubscribe(uint256,address)", _cdpId, subscriptionsV1address));
	}

	function _removeAuthority(address _cdpOwner) internal onlyAuthorized {

		address currAuthority = address(DSAuth(_cdpOwner).authority());
		
		if (currAuthority == address(0)) return;
        DSGuard guard = DSGuard(currAuthority);

        
        if (!guard.canCall(monitorProxyAddress, _cdpOwner, bytes4(keccak256("execute(address,bytes)")))) return;

		monitorProxyContract.callExecute(_cdpOwner, proxyPermission, abi.encodeWithSignature("removePermission(address)", monitorProxyAddress));
	}

	
    
    function _getOwner(uint _cdpId) internal view returns(address) {
        return manager.owns(_cdpId);
    }
}