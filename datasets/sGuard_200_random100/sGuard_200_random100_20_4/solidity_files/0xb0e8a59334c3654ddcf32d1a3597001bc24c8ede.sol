pragma solidity ^0.6.2;


interface IERC734 {
    
    struct Key {
        uint256[] purposes;
        uint256 keyType;
        bytes32 key;
    }

    
    event Approved(uint256 indexed executionId, bool approved);

    
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    
    event KeysRequiredChanged(uint256 purpose, uint256 number);


    
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) external returns (bool success);

    
    function approve(uint256 _id, bool _approve) external returns (bool success);

    
    function execute(address _to, uint256 _value, bytes calldata _data) external payable returns (uint256 executionId);

    
    function getKey(bytes32 _key) external view returns (uint256[] memory purposes, uint256 keyType, bytes32 key);

    
    function getKeyPurposes(bytes32 _key) external view returns(uint256[] memory _purposes);

    
    function getKeysByPurpose(uint256 _purpose) external view returns (bytes32[] memory keys);

    
    function keyHasPurpose(bytes32 _key, uint256 _purpose) external view returns (bool exists);

    
    function removeKey(bytes32 _key, uint256 _purpose) external returns (bool success);
}



pragma solidity ^0.6.2;


interface IERC735 {

    
    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    
    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer;
        bytes signature;
        bytes data;
        string uri;
    }

    
    function getClaim(bytes32 _claimId) external view returns(uint256 topic, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);

    
    function getClaimIdsByTopic(uint256 _topic) external view returns(bytes32[] memory claimIds);

    
    function addClaim(uint256 _topic, uint256 _scheme, address issuer, bytes calldata _signature, bytes calldata _data, string calldata _uri) external returns (bytes32 claimRequestId);

    
    function removeClaim(bytes32 _claimId) external returns (bool success);
}



pragma solidity ^0.6.2;



interface IIdentity is IERC734, IERC735 {}



pragma solidity ^0.6.2;


interface IClaimIssuer is IIdentity {
    function revokeClaim(bytes32 _claimId, address _identity) external returns(bool);
    function getRecoveredAddress(bytes calldata sig, bytes32 dataHash) external pure returns (address);
    function isClaimRevoked(bytes calldata _sig) external view returns (bool);
    function isClaimValid(IIdentity _identity, uint256 claimTopic, bytes calldata sig, bytes calldata data) external view returns (bool);
}





pragma solidity 0.6.2;

interface IClaimTopicsRegistry {

   
    event ClaimTopicAdded(uint256 indexed claimTopic);

   
    event ClaimTopicRemoved(uint256 indexed claimTopic);

   
    function addClaimTopic(uint256 _claimTopic) external;

   
    function removeClaimTopic(uint256 _claimTopic) external;

   
    function getClaimTopics() external view returns (uint256[] memory);

   
    function transferOwnershipOnClaimTopicsRegistryContract(address _newOwner) external;
}





pragma solidity 0.6.2;


interface ITrustedIssuersRegistry {

   
    event TrustedIssuerAdded(IClaimIssuer indexed trustedIssuer, uint[] claimTopics);

   
    event TrustedIssuerRemoved(IClaimIssuer indexed trustedIssuer);

   
    event ClaimTopicsUpdated(IClaimIssuer indexed trustedIssuer, uint[] claimTopics);

   
    function addTrustedIssuer(IClaimIssuer _trustedIssuer, uint[] calldata _claimTopics) external;

   
    function removeTrustedIssuer(IClaimIssuer _trustedIssuer) external;

   
    function updateIssuerClaimTopics(IClaimIssuer _trustedIssuer, uint[] calldata _claimTopics) external;

   
    function getTrustedIssuers() external view returns (IClaimIssuer[] memory);

   
    function isTrustedIssuer(address _issuer) external view returns(bool);

   
    function getTrustedIssuerClaimTopics(IClaimIssuer _trustedIssuer) external view returns(uint[] memory);

   
    function hasClaimTopic(address _issuer, uint _claimTopic) external view returns(bool);

   
    function transferOwnershipOnIssuersRegistryContract(address _newOwner) external;
}





pragma solidity 0.6.2;


interface IIdentityRegistryStorage {

   
    event IdentityStored(address indexed investorAddress, IIdentity indexed identity);

   
    event IdentityUnstored(address indexed investorAddress, IIdentity indexed identity);

   
    event IdentityModified(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);

   
    event CountryModified(address indexed investorAddress, uint16 indexed country);

   
    event IdentityRegistryBound(address indexed identityRegistry);

   
    event IdentityRegistryUnbound(address indexed identityRegistry);

   
    function linkedIdentityRegistries() external view returns (address[] memory);

   
    function storedIdentity(address _userAddress) external view returns (IIdentity);

   
    function storedInvestorCountry(address _userAddress) external view returns (uint16);

   
    function addIdentityToStorage(address _userAddress, IIdentity _identity, uint16 _country) external;

   
    function removeIdentityFromStorage(address _userAddress) external;

   
    function modifyStoredInvestorCountry(address _userAddress, uint16 _country) external;

   
    function modifyStoredIdentity(address _userAddress, IIdentity _identity) external;

   
    function transferOwnershipOnIdentityRegistryStorage(address _newOwner) external;

   
    function bindIdentityRegistry(address _identityRegistry) external;

   
    function unbindIdentityRegistry(address _identityRegistry) external;
}





pragma solidity 0.6.2;






interface IIdentityRegistry {

   
    event ClaimTopicsRegistrySet(address indexed claimTopicsRegistry);

   
    event IdentityStorageSet(address indexed identityStorage);

   
    event TrustedIssuersRegistrySet(address indexed trustedIssuersRegistry);

   
    event IdentityRegistered(address indexed investorAddress, IIdentity indexed identity);

   
    event IdentityRemoved(address indexed investorAddress, IIdentity indexed identity);

   
    event IdentityUpdated(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);

   
    event CountryUpdated(address indexed investorAddress, uint16 indexed country);

   
    function registerIdentity(address _userAddress, IIdentity _identity, uint16 _country) external;

   
    function deleteIdentity(address _userAddress) external;

   
    function setIdentityRegistryStorage(address _identityRegistryStorage) external;

   
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;

   
    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external;

   
    function updateCountry(address _userAddress, uint16 _country) external;

   
    function updateIdentity(address _userAddress, IIdentity _identity) external;

   
    function batchRegisterIdentity(address[] calldata _userAddresses, IIdentity[] calldata _identities, uint16[] calldata _countries) external;

   
    function contains(address _userAddress) external view returns (bool);

   
    function isVerified(address _userAddress) external view returns (bool);

   
    function identity(address _userAddress) external view returns (IIdentity);

   
    function investorCountry(address _userAddress) external view returns (uint16);

   
    function identityStorage() external view returns (IIdentityRegistryStorage);

   
    function issuersRegistry() external view returns (ITrustedIssuersRegistry);

   
    function topicsRegistry() external view returns (IClaimTopicsRegistry);

   
    function transferOwnershipOnIdentityRegistryContract(address _newOwner) external;

   
    function addAgentOnIdentityRegistryContract(address _agent) external;

   
    function removeAgentOnIdentityRegistryContract(address _agent) external;
}



pragma solidity 0.6.2;


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





pragma solidity ^0.6.0;


contract Context {
    
    
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity 0.6.2;



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() external view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





pragma solidity 0.6.2;



contract AgentRole is Ownable {
    using Roles for Roles.Role;

    event AgentAdded(address indexed _agent);
    event AgentRemoved(address indexed _agent);

    Roles.Role private _agents;

    modifier onlyAgent() {
        require(isAgent(msg.sender), "AgentRole: caller does not have the Agent role");
        _;
    }

    function isAgent(address _agent) public view returns (bool) {
        return _agents.has(_agent);
    }

    function addAgent(address _agent) public onlyOwner {
        _agents.add(_agent);
        emit AgentAdded(_agent);
    }

    function removeAgent(address _agent) public onlyOwner {
        _agents.remove(_agent);
        emit AgentRemoved(_agent);
    }
}





pragma solidity 0.6.2;









contract IdentityRegistry is IIdentityRegistry, AgentRole {


    
    IClaimTopicsRegistry private tokenTopicsRegistry;

    
    ITrustedIssuersRegistry private tokenIssuersRegistry;

    
    IIdentityRegistryStorage private tokenIdentityStorage;

   
    constructor (
        address _trustedIssuersRegistry,
        address _claimTopicsRegistry,
        address _identityStorage
    ) public {
        tokenTopicsRegistry = IClaimTopicsRegistry(_claimTopicsRegistry);
        tokenIssuersRegistry = ITrustedIssuersRegistry(_trustedIssuersRegistry);
        tokenIdentityStorage = IIdentityRegistryStorage(_identityStorage);
        emit ClaimTopicsRegistrySet(_claimTopicsRegistry);
        emit TrustedIssuersRegistrySet(_trustedIssuersRegistry);
        emit IdentityStorageSet(_identityStorage);
    }

   
    function identity(address _userAddress) public override view returns (IIdentity){
        return tokenIdentityStorage.storedIdentity(_userAddress);
    }

   
    function investorCountry(address _userAddress) external override view returns (uint16){
        return tokenIdentityStorage.storedInvestorCountry(_userAddress);
    }

   
    function issuersRegistry() external override view returns (ITrustedIssuersRegistry){
        return tokenIssuersRegistry;
    }

   
    function topicsRegistry() external override view returns (IClaimTopicsRegistry){
        return tokenTopicsRegistry;
    }

    
    function identityStorage() external override view returns (IIdentityRegistryStorage){
        return tokenIdentityStorage;
    }

   
    function registerIdentity(address _userAddress, IIdentity _identity, uint16 _country) public override onlyAgent {
        tokenIdentityStorage.addIdentityToStorage(_userAddress, _identity, _country);
        emit IdentityRegistered(_userAddress, _identity);
    }

   
    function batchRegisterIdentity(address[] calldata _userAddresses, IIdentity[] calldata _identities, uint16[] calldata _countries) external override {
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            registerIdentity(_userAddresses[i], _identities[i], _countries[i]);
        }
    }

   
    function updateIdentity(address _userAddress, IIdentity _identity) external override onlyAgent {
        IIdentity oldIdentity = identity(_userAddress);
        tokenIdentityStorage.modifyStoredIdentity(_userAddress, _identity);
        emit IdentityUpdated(oldIdentity, _identity);
    }


   
    function updateCountry(address _userAddress, uint16 _country) external override onlyAgent {
        tokenIdentityStorage.modifyStoredInvestorCountry(_userAddress, _country);
        emit CountryUpdated(_userAddress, _country);
    }

   
    function deleteIdentity(address _userAddress) external override onlyAgent {
        tokenIdentityStorage.removeIdentityFromStorage(_userAddress);
        emit IdentityRemoved(_userAddress, identity(_userAddress));
    }

   
    function isVerified(address _userAddress) external override view returns (bool) {
        if (address(identity(_userAddress)) == address(0)) {
            return false;
        }
        uint256[] memory requiredClaimTopics = tokenTopicsRegistry.getClaimTopics();
        if (requiredClaimTopics.length == 0) {
            return true;
        }
        uint256 foundClaimTopic;
        uint256 scheme;
        address issuer;
        bytes memory sig;
        bytes memory data;
        uint256 claimTopic;
        for (claimTopic = 0; claimTopic < requiredClaimTopics.length; claimTopic++) {
            bytes32[] memory claimIds = identity(_userAddress).getClaimIdsByTopic(requiredClaimTopics[claimTopic]);
            if (claimIds.length == 0) {
                return false;
            }
            for (uint j = 0; j < claimIds.length; j++) {
                (foundClaimTopic, scheme, issuer, sig, data,) = identity(_userAddress).getClaim(claimIds[j]);
                if (!tokenIssuersRegistry.isTrustedIssuer(issuer) && j == (claimIds.length - 1)) {
                    return false;
                }
                if (!tokenIssuersRegistry.hasClaimTopic(issuer, requiredClaimTopics[claimTopic]) && j == (claimIds.length - 1)) {
                    return false;
                }
                if (!IClaimIssuer(issuer).isClaimValid(identity(_userAddress), requiredClaimTopics[claimTopic], sig, data) && j == (claimIds.length - 1)) {
                    return false;
                }
            }
        }
        return true;
    }

   
    function setIdentityRegistryStorage(address _identityRegistryStorage) external override onlyOwner {
        tokenIdentityStorage = IIdentityRegistryStorage(_identityRegistryStorage);
        emit IdentityStorageSet(_identityRegistryStorage);
    }

   
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external override onlyOwner {
        tokenTopicsRegistry = IClaimTopicsRegistry(_claimTopicsRegistry);
        emit ClaimTopicsRegistrySet(_claimTopicsRegistry);
    }

   
    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external override onlyOwner {
        tokenIssuersRegistry = ITrustedIssuersRegistry(_trustedIssuersRegistry);
        emit TrustedIssuersRegistrySet(_trustedIssuersRegistry);
    }

   
    function contains(address _userAddress) external override view returns (bool){
        if (address(identity(_userAddress)) == address(0)) {
            return false;
        }
        return true;
    }

   
    function transferOwnershipOnIdentityRegistryContract(address _newOwner) external override onlyOwner {
        transferOwnership(_newOwner);
    }

   
    function addAgentOnIdentityRegistryContract(address _agent) external override {
        addAgent(_agent);
    }

   
    function removeAgentOnIdentityRegistryContract(address _agent) external override {
        removeAgent(_agent);
    }
}