pragma solidity 0.5.16;


contract ModuleKeys {

    
    bytes32 internal constant KEY_GOVERNANCE = 0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    
    bytes32 internal constant KEY_STAKING = 0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    
    bytes32 internal constant KEY_PROXY_ADMIN = 0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    
    bytes32 internal constant KEY_ORACLE_HUB = 0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    
    bytes32 internal constant KEY_MANAGER = 0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    
    bytes32 internal constant KEY_RECOLLATERALISER = 0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    
    bytes32 internal constant KEY_META_TOKEN = 0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    
    bytes32 internal constant KEY_SAVINGS_MANAGER = 0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
}


interface INexus {
    function governor() external view returns (address);
    function getModule(bytes32 key) external view returns (address);

    function proposeModule(bytes32 _key, address _addr) external;
    function cancelProposedModule(bytes32 _key) external;
    function acceptProposedModule(bytes32 _key) external;
    function acceptProposedModules(bytes32[] calldata _keys) external;

    function requestLockModule(bytes32 _key) external;
    function cancelLockModule(bytes32 _key) external;
    function lockModule(bytes32 _key) external;
}


contract Module is ModuleKeys {

    INexus public nexus;

    
    constructor(address _nexus) internal {
        require(_nexus != address(0), "Nexus is zero address");
        nexus = INexus(_nexus);
    }

    
    modifier onlyGovernor() {
        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    
    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    
    modifier onlyProxyAdmin() {
        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    
    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    
    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    
    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    
    function _staking() internal view returns (address) {
        return nexus.getModule(KEY_STAKING);
    }

    
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    
    function _metaToken() internal view returns (address) {
        return nexus.getModule(KEY_META_TOKEN);
    }

    
    function _oracleHub() internal view returns (address) {
        return nexus.getModule(KEY_ORACLE_HUB);
    }

    
    function _manager() internal view returns (address) {
        return nexus.getModule(KEY_MANAGER);
    }

    
    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    
    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
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


library OpenZeppelinUpgradesAddress {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


contract BaseUpgradeabilityProxy is Proxy {
  
  event Upgraded(address indexed implementation);

  
  bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  
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
    require(OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}


contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
  
  constructor(address _logic, bytes memory _data) public payable {
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}


contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
  
  event AdminChanged(address previousAdmin, address newAdmin);

  

  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  
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


contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
  
  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(_admin);
  }
}


contract DelayedProxyAdmin is Module {
    using SafeMath for uint256;

    event UpgradeProposed(address indexed proxy, address implementation, bytes data);
    event UpgradeCancelled(address indexed proxy);
    event Upgraded(address indexed proxy, address oldImpl, address newImpl, bytes data);

    
    struct Request{
        address implementation; 
        bytes data;             
        uint256 timestamp;      
    }

    
    uint256 public constant UPGRADE_DELAY = 1 weeks;

    
    mapping(address => Request) public requests;

    
    constructor(address _nexus) public Module(_nexus) {}

    
    function proposeUpgrade(
        address _proxy,
        address _implementation,
        bytes calldata _data
    )
        external
        onlyGovernor
    {
        require(_proxy != address(0), "Proxy address is zero");
        require(_implementation != address(0), "Implementation address is zero");
        require(requests[_proxy].implementation == address(0), "Upgrade already proposed");
        validateProxy(_proxy, _implementation);

        Request storage request = requests[_proxy];
        request.implementation = _implementation;
        request.data = _data;
        request.timestamp = now;

        emit UpgradeProposed(_proxy, _implementation, _data);
    }

    
    function cancelUpgrade(address _proxy) external onlyGovernor {
        require(_proxy != address(0), "Proxy address is zero");
        require(requests[_proxy].implementation != address(0), "No request found");
        delete requests[_proxy];
        emit UpgradeCancelled(_proxy);
    }

    
    function acceptUpgradeRequest(address payable _proxy) external payable onlyGovernor {
        
        require(_proxy != address(0), "Proxy address is zero");
        Request memory request = requests[_proxy];
        require(_isDelayOver(request.timestamp), "Delay not over");

        address newImpl = request.implementation;
        bytes memory data = request.data;

        address oldImpl = getProxyImplementation(_proxy);

        
        delete requests[_proxy];

        if(data.length == 0) {
            require(msg.value == 0, "msg.value should be zero");
            AdminUpgradeabilityProxy(_proxy).upgradeTo(newImpl);
        } else {
            AdminUpgradeabilityProxy(_proxy).upgradeToAndCall.value(msg.value)(newImpl, data);
        }

        emit Upgraded(_proxy, oldImpl, newImpl, data);
    }

    
    function _isDelayOver(uint256 _timestamp) private view returns (bool) {
        if(_timestamp > 0 && now >= _timestamp.add(UPGRADE_DELAY))
            return true;
        return false;
    }

    
    function validateProxy(address _proxy, address _newImpl) internal view {
        
        address currentImpl = getProxyImplementation(_proxy);

        
        require(_newImpl != currentImpl, "Implementation must be different");

        
        address admin = getProxyAdmin(_proxy);
        require(admin == address(this), "Proxy admin not matched");
    }

    
    function getProxyAdmin(address _proxy) public view returns (address) {
        
        
        (bool success, bytes memory returndata) = _proxy.staticcall(hex"f851a440");
        require(success, "Call failed");
        return abi.decode(returndata, (address));
    }

    
    function getProxyImplementation(address _proxy) public view returns (address) {
        
        
        (bool success, bytes memory returndata) = _proxy.staticcall(hex"5c60da1b");
        require(success, "Call failed");
        return abi.decode(returndata, (address));
    }

    
    
    
    
    
    
}