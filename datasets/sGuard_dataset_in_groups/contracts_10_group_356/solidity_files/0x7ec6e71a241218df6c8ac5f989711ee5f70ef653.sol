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




contract TrustedIssuersRegistry is ITrustedIssuersRegistry, Ownable {

    
    IClaimIssuer[] private trustedIssuers;

    
    mapping(address => uint[]) private trustedIssuerClaimTopics;

   
    function addTrustedIssuer(IClaimIssuer _trustedIssuer, uint[] calldata _claimTopics) external override onlyOwner {
        require(trustedIssuerClaimTopics[address(_trustedIssuer)].length == 0, "trusted Issuer already exists");
        require(_claimTopics.length > 0, "trusted claim topics cannot be empty");
        trustedIssuers.push(_trustedIssuer);
        trustedIssuerClaimTopics[address(_trustedIssuer)] = _claimTopics;
        emit TrustedIssuerAdded(_trustedIssuer, _claimTopics);
    }

   
    function removeTrustedIssuer(IClaimIssuer _trustedIssuer) external override onlyOwner {
        require(trustedIssuerClaimTopics[address(_trustedIssuer)].length != 0, "trusted Issuer doesn't exist");
        uint length = trustedIssuers.length;
        for (uint i = 0; i < length; i++) {
            if (trustedIssuers[i] == _trustedIssuer) {
                delete trustedIssuers[i];
                trustedIssuers[i] = trustedIssuers[length - 1];
                delete trustedIssuers[length - 1];
                trustedIssuers.pop();
                break;
            }
        }
        delete trustedIssuerClaimTopics[address(_trustedIssuer)];
        emit TrustedIssuerRemoved(_trustedIssuer);
    }

   
    function updateIssuerClaimTopics(IClaimIssuer _trustedIssuer, uint[] calldata _claimTopics) external override onlyOwner {
        require(trustedIssuerClaimTopics[address(_trustedIssuer)].length != 0, "trusted Issuer doesn't exist");
        require(_claimTopics.length > 0, "claim topics cannot be empty");
        trustedIssuerClaimTopics[address(_trustedIssuer)] = _claimTopics;
        emit ClaimTopicsUpdated(_trustedIssuer, _claimTopics);
    }

   
    function getTrustedIssuers() external override view returns (IClaimIssuer[] memory) {
        return trustedIssuers;
    }

   
    function isTrustedIssuer(address _issuer) external override view returns (bool) {
        uint length = trustedIssuers.length;
        for (uint i = 0; i < length; i++) {
            if (address(trustedIssuers[i]) == _issuer) {
                return true;
            }
        }
        return false;
    }

   
    function getTrustedIssuerClaimTopics(IClaimIssuer _trustedIssuer) external override view returns (uint[] memory) {
        require(trustedIssuerClaimTopics[address(_trustedIssuer)].length != 0, "trusted Issuer doesn't exist");
        return trustedIssuerClaimTopics[address(_trustedIssuer)];
    }

   
    function hasClaimTopic(address _issuer, uint _claimTopic) external override view returns (bool) {
        uint length = trustedIssuerClaimTopics[_issuer].length;
        uint[] memory claimTopics = trustedIssuerClaimTopics[_issuer];
        for (uint i = 0; i < length; i++) {
            if (claimTopics[i] == _claimTopic) {
                return true;
            }
        }
        return false;
    }

   
    function transferOwnershipOnIssuersRegistryContract(address _newOwner) external override onlyOwner {
        transferOwnership(_newOwner);
    }
}