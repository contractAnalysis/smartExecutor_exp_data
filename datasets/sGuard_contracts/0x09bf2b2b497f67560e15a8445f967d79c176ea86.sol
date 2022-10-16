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





contract IdentityRegistryStorage is IIdentityRegistryStorage, AgentRole {

    
    struct Identity {
        IIdentity identityContract;
        uint16 investorCountry;
    }

    
    mapping(address => Identity) private identities;

    
    address[] private identityRegistries;

   
    function linkedIdentityRegistries() external override view returns (address[] memory){
        return identityRegistries;
    }

   
    function storedIdentity(address _userAddress) external override view returns (IIdentity){
        return identities[_userAddress].identityContract;
    }

   
    function storedInvestorCountry(address _userAddress) external override view returns (uint16){
        return identities[_userAddress].investorCountry;
    }

   
    function addIdentityToStorage(address _userAddress, IIdentity _identity, uint16 _country) external override onlyAgent {
        require(address(_identity) != address(0), "contract address can't be a zero address");
        require(address(identities[_userAddress].identityContract) == address(0), "identity contract already exists, please use update");
        identities[_userAddress].identityContract = _identity;
        identities[_userAddress].investorCountry = _country;
        emit IdentityStored(_userAddress, _identity);
    }

   
    function modifyStoredIdentity(address _userAddress, IIdentity _identity) external override onlyAgent {
        require(address(identities[_userAddress].identityContract) != address(0), "this user has no identity registered");
        require(address(_identity) != address(0), "contract address can't be a zero address");
        IIdentity oldIdentity = identities[_userAddress].identityContract;
        identities[_userAddress].identityContract = _identity;
        emit IdentityModified(oldIdentity, _identity);
    }

   
    function modifyStoredInvestorCountry(address _userAddress, uint16 _country) external override onlyAgent {
        require(address(identities[_userAddress].identityContract) != address(0), "this user has no identity registered");
        identities[_userAddress].investorCountry = _country;
        emit CountryModified(_userAddress, _country);
    }

   
    function removeIdentityFromStorage(address _userAddress) external override onlyAgent {
        require(address(identities[_userAddress].identityContract) != address(0), "you haven't registered an identity yet");
        delete identities[_userAddress];
        emit IdentityUnstored(_userAddress, identities[_userAddress].identityContract);
    }

   
    function transferOwnershipOnIdentityRegistryStorage(address _newOwner) external override onlyOwner {
        transferOwnership(_newOwner);
    }

    
    function bindIdentityRegistry(address _identityRegistry) external override {
        addAgent(_identityRegistry);
        identityRegistries.push(_identityRegistry);
        emit IdentityRegistryBound(_identityRegistry);
    }

    
    function unbindIdentityRegistry(address _identityRegistry) external override {
        require(identityRegistries.length > 0, "identity registry is not stored");
        uint length = identityRegistries.length;
        for (uint i = 0; i < length; i++) {
            if (identityRegistries[i] == _identityRegistry) {
                delete identityRegistries[i];
                identityRegistries[i] = identityRegistries[length - 1];
                delete identityRegistries[length - 1];
                identityRegistries.pop();
                break;
            }
        }
        removeAgent(_identityRegistry);
        emit IdentityRegistryUnbound(_identityRegistry);
    }
}