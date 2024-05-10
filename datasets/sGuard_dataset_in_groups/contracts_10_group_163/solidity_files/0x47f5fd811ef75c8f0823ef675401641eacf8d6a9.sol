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

interface ICompliance {

    
    event TokenAgentAdded(address _agentAddress);

    
    event TokenAgentRemoved(address _agentAddress);

    
    event TokenBound(address _token);

    
    event TokenUnbound(address _token);

    
    function isTokenAgent(address _agentAddress) external view returns (bool);

    
    function isTokenBound(address _token) external view returns (bool);

    
    function addTokenAgent(address _agentAddress) external;

    
    function removeTokenAgent(address _agentAddress) external;

    
    function bindToken(address _token) external;

    
    function unbindToken(address _token) external;


   
    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool);

   
    function transferred(address _from, address _to, uint256 _amount) external;

   
    function created(address _to, uint256 _amount) external;

   
    function destroyed(address _from, uint256 _amount) external;

   
    function transferOwnershipOnComplianceContract(address newOwner) external;
}





pragma solidity 0.6.2;




contract LimitsDMAndCountryRestrictions is ICompliance, Ownable {

    
    event IdentityStorageAdded(address indexed _identityStorage);

    
    event AddedRestrictedCountry(uint16 _country);

    
    event RemovedRestrictedCountry(uint16 _country);

    
    event DailyLimitUpdated(uint _newDailyLimit);

    
    event MonthlyLimitUpdated(uint _newMonthlyLimit);

    
    IIdentityRegistryStorage public identityStorage;

    
    mapping(uint16 => bool) private _restrictedCountries;

    
    mapping(address => bool) private _tokenAgentsList;

    
    mapping(address => bool) private _tokensBound;

    
    uint256 public dailyLimit;

    
    uint256 public monthlyLimit;

    
    struct TransferCounter {
        uint256 dailyCount;
        uint256 monthlyCount;
        uint256 dailyTimer;
        uint256 monthlyTimer;
    }

    
    mapping(address => TransferCounter) usersCounters;

    
    modifier onlyToken() {
        require(isToken(), "error : this address is not a token bound to the compliance contract");
        _;
    }

    
    constructor (address _identityStorage, uint256 _dailyLimit, uint256 _monthlyLimit) public {
        identityStorage = IIdentityRegistryStorage(_identityStorage);
        emit IdentityStorageAdded(_identityStorage);
        dailyLimit = _dailyLimit;
        emit DailyLimitUpdated(_dailyLimit);
        monthlyLimit = _monthlyLimit;
        emit MonthlyLimitUpdated(_monthlyLimit);
    }

    
    function _isDayFinished(address _identity) internal view returns (bool) {
        return (usersCounters[_identity].dailyTimer <= block.timestamp);
    }

    
    function _isMonthFinished(address _identity) internal view returns (bool) {
        return (usersCounters[_identity].monthlyTimer <= block.timestamp);
    }

    
    function _resetDailyCooldown(address _identity) internal {
        if (_isDayFinished(_identity)) {
            usersCounters[_identity].dailyTimer = block.timestamp + 1 days;
            usersCounters[_identity].dailyCount = 0;
        }
    }

    
    function _resetMonthlyCooldown(address _identity) internal {
        if (_isMonthFinished(_identity)) {
            usersCounters[_identity].monthlyTimer = block.timestamp + 30 days;
            usersCounters[_identity].monthlyCount = 0;
        }
    }

    
    function _increaseCounters(address _userAddress, uint256 _value) internal {
        address identity = _getIdentity(_userAddress);
        _resetDailyCooldown(identity);
        _resetMonthlyCooldown(identity);
        if ((usersCounters[identity].dailyCount + _value) <= dailyLimit) {
            usersCounters[identity].dailyCount += _value;
        }
        if ((usersCounters[identity].monthlyCount + _value) <= monthlyLimit) {
            usersCounters[identity].monthlyCount += _value;
        }
    }

    
    function _getIdentity(address _userAddress) internal view returns (address) {
        return address(identityStorage.storedIdentity(_userAddress));
    }

    
    function isTokenAgent(address _agentAddress) public override view returns (bool) {
        return (_tokenAgentsList[_agentAddress]);
    }

    
    function isTokenBound(address _token) public override view returns (bool) {
        return (_tokensBound[_token]);
    }

    
    function isCountryRestricted(uint16 _country) public view returns (bool) {
        return (_restrictedCountries[_country]);
    }

    
    function addTokenAgent(address _agentAddress) external override onlyOwner {
        require(!_tokenAgentsList[_agentAddress], "This Agent is already registered");
        _tokenAgentsList[_agentAddress] = true;
        emit TokenAgentAdded(_agentAddress);
    }

    
    function removeTokenAgent(address _agentAddress) external override onlyOwner {
        require(_tokenAgentsList[_agentAddress], "This Agent is not registered yet");
        _tokenAgentsList[_agentAddress] = false;
        emit TokenAgentRemoved(_agentAddress);
    }

    
    function bindToken(address _token) external override onlyOwner {
        require(!_tokensBound[_token], "This token is already bound");
        _tokensBound[_token] = true;
        emit TokenBound(_token);
    }

    
    function unbindToken(address _token) external override onlyOwner {
        require(_tokensBound[_token], "This token is not bound yet");
        _tokensBound[_token] = false;
        emit TokenUnbound(_token);
    }

    
    function isToken() internal view returns (bool) {
        return isTokenBound(msg.sender);
    }

   
    function setDailyLimit(uint256 _newDailyLimit) external onlyOwner {
        dailyLimit = _newDailyLimit;
        emit DailyLimitUpdated(_newDailyLimit);
    }

   
    function setMonthlyLimit(uint256 _newMonthlyLimit) external onlyOwner {
        monthlyLimit = _newMonthlyLimit;
        emit MonthlyLimitUpdated(_newMonthlyLimit);
    }

   
    function setIdentityStorage(address _identityStorage) external onlyOwner {
        identityStorage = IIdentityRegistryStorage(_identityStorage);
        emit IdentityStorageAdded(_identityStorage);
    }

   
    function addCountryRestriction(uint16 _country) external onlyOwner {
        _restrictedCountries[_country] = true;
        emit AddedRestrictedCountry(_country);
    }

   
    function removeCountryRestriction(uint16 _country) external onlyOwner {
        _restrictedCountries[_country] = false;
        emit RemovedRestrictedCountry(_country);
    }

   
    function batchRestrictCountries(uint16[] calldata _countries) external onlyOwner {
        for (uint i = 0; i < _countries.length; i++) {
            _restrictedCountries[_countries[i]] = true;
            emit AddedRestrictedCountry(_countries[i]);
        }
    }

   
    function batchUnrestrictCountries(uint16[] calldata _countries) external onlyOwner {
        for (uint i = 0; i < _countries.length; i++) {
            _restrictedCountries[_countries[i]] = false;
            emit RemovedRestrictedCountry(_countries[i]);
        }
    }

   
    function transferred(address _from, address _to, uint256 _value) external onlyToken override {
        _increaseCounters(_from, _value);
    }

   
    function created(address _to, uint256 _value) external override {}

   
    function destroyed(address _from, uint256 _value) external override {}

   
    function canTransfer(address _from, address _to, uint256 _value) external view override returns (bool) {
        uint16 receiverCountry = identityStorage.storedInvestorCountry(_to);
        address senderIdentity = _getIdentity(_from);
        if (isCountryRestricted(receiverCountry)) {
            return false;
        }
        if (!isTokenAgent(_from)) {
            if (_value > dailyLimit) {
                return false;
            }
            if (!_isDayFinished(senderIdentity) &&
                ((usersCounters[senderIdentity].dailyCount + _value > dailyLimit)
                    || (usersCounters[senderIdentity].monthlyCount + _value > monthlyLimit))) {
                return false;
            }
            if (_isDayFinished(senderIdentity) && _value + usersCounters[senderIdentity].monthlyCount > monthlyLimit) {
                return(_isMonthFinished(senderIdentity));
            }
        }
        return true;
    }

   
    function transferOwnershipOnComplianceContract(address newOwner) external override onlyOwner {
        transferOwnership(newOwner);
    }
}