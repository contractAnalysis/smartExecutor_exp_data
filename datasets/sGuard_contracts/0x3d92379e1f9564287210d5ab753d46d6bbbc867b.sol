pragma solidity ^0.6.0;

contract Ownable {
    address public owner;
    address public pendingOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    constructor(address owner_) public {
        owner = owner_;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner = newOwner;
    }

    
    function claimOwnership() public {
        require(msg.sender == pendingOwner, "onlyPendingOwner");
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}



pragma solidity ^0.6.0;


contract NetworkParameters is Ownable {
    uint public minControlLayerVersion;
    uint public minMessageLayerVersion;
    string public minNetworkReferenceCodeVersion;
    address public tokenAddress;

    constructor(address owner, uint minControlLayerVersion_, uint minMessageLayerVersion_, string memory minNetworkReferenceCodeVersion_, address tokenAddress_) public Ownable(owner) {
        minControlLayerVersion = minControlLayerVersion_;
        minMessageLayerVersion = minMessageLayerVersion_;
        minNetworkReferenceCodeVersion = minNetworkReferenceCodeVersion_;
        tokenAddress = tokenAddress_;
    }

    function setMinControlLayerVersion(uint version) public onlyOwner {
        minControlLayerVersion = version;
    }

    function setMinMessageLayerVersion(uint version) public onlyOwner {
        minControlLayerVersion = version;
    }

    function setMinNetworkReferenceCodeVersion(string memory version) public onlyOwner {
        minNetworkReferenceCodeVersion = version;
    }

    function setTokenAddress(address tokenAddress_) public onlyOwner {
        tokenAddress = tokenAddress_;
    }
}