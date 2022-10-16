pragma solidity 0.6.2;

interface IClaimTopicsRegistry {

   
    event ClaimTopicAdded(uint256 indexed claimTopic);

   
    event ClaimTopicRemoved(uint256 indexed claimTopic);

   
    function addClaimTopic(uint256 _claimTopic) external;

   
    function removeClaimTopic(uint256 _claimTopic) external;

   
    function getClaimTopics() external view returns (uint256[] memory);

   
    function transferOwnershipOnClaimTopicsRegistryContract(address _newOwner) external;
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



contract ClaimTopicsRegistry is IClaimTopicsRegistry, Ownable {

    
    uint256[] private claimTopics;

   
    function addClaimTopic(uint256 _claimTopic) external override onlyOwner {
        uint length = claimTopics.length;
        for (uint i = 0; i < length; i++) {
            require(claimTopics[i] != _claimTopic, "claimTopic already exists");
        }
        claimTopics.push(_claimTopic);
        emit ClaimTopicAdded(_claimTopic);
    }

   
    function removeClaimTopic(uint256 _claimTopic) external override onlyOwner {
        uint length = claimTopics.length;
        for (uint i = 0; i < length; i++) {
            if (claimTopics[i] == _claimTopic) {
                delete claimTopics[i];
                claimTopics[i] = claimTopics[length - 1];
                delete claimTopics[length - 1];
                claimTopics.pop();
                emit ClaimTopicRemoved(_claimTopic);
                break;
            }
        }
    }

   
    function getClaimTopics() external override view returns (uint256[] memory) {
        return claimTopics;
    }

   
    function transferOwnershipOnClaimTopicsRegistryContract(address _newOwner) external override onlyOwner {
        transferOwnership(_newOwner);
    }
}