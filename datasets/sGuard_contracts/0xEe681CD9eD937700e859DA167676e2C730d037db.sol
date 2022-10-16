pragma solidity ^0.5.0;


contract IAKAP {
    enum ClaimCase {RECLAIM, NEW, TRANSFER}
    enum NodeAttribute {EXPIRY, SEE_ALSO, SEE_ADDRESS, NODE_BODY, TOKEN_URI}

    event Claim(address indexed sender, uint indexed nodeId, uint indexed parentId, bytes label, ClaimCase claimCase);
    event AttributeChanged(address indexed sender, uint indexed nodeId, NodeAttribute attribute);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function hashOf(uint parentId, bytes memory label) public pure returns (uint id);

    
    function claim(uint parentId, bytes calldata label) external returns (uint status);

    
    function exists(uint nodeId) external view returns (bool);

    
    function isApprovedOrOwner(uint nodeId) external view returns (bool);

    
    function ownerOf(uint256 tokenId) public view returns (address);

    
    function parentOf(uint nodeId) external view returns (uint);

    
    function expiryOf(uint nodeId) external view returns (uint);

    
    function seeAlso(uint nodeId) external view returns (uint);

    
    function seeAddress(uint nodeId) external view returns (address);

    
    function nodeBody(uint nodeId) external view returns (bytes memory);

    
    function tokenURI(uint256 tokenId) external view returns (string memory);

    
    function expireNode(uint nodeId) external;

    
    function setSeeAlso(uint nodeId, uint value) external;

    
    function setSeeAddress(uint nodeId, address value) external;

    
    function setNodeBody(uint nodeId, bytes calldata value) external;

    
    function setTokenURI(uint nodeId, string calldata uri) external;

    
    function approve(address to, uint256 tokenId) public;

    
    function getApproved(uint256 tokenId) public view returns (address);

    
    function setApprovalForAll(address to, bool approved) public;

    
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    
    function transferFrom(address from, address to, uint256 tokenId) public;

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public;
}



pragma solidity ^0.5.0;


interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.0;



contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) public view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) public view returns (address owner);

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

















pragma solidity ^0.5.0;



contract IDomainManager {
    function akap() public view returns (IAKAP);

    function erc721() public view returns (IERC721);

    function domainParent() public view returns (uint);

    function domainLabel() public view returns (bytes memory);

    function domain() public view returns (uint);

    function setApprovalForAll(address to, bool approved) public;

    function claim(bytes memory label) public returns (uint status);

    function claim(uint parentId, bytes memory label) public returns (uint);

    function reclaim() public returns (uint);
}

















pragma solidity ^0.5.0;



contract AkaProxy {
    IDomainManager public dm;
    IAKAP public akap;
    uint public rootPtr;

    constructor(address _dmAddress, uint _rootPtr) public {
        dm = IDomainManager(_dmAddress);
        akap = dm.akap();
        rootPtr = _rootPtr;

        require(akap.exists(rootPtr), "AkaProxy: No root node");
    }

    function () payable external {
        address implementationAddress = akap.seeAddress(rootPtr);
        require(implementationAddress != address(0), "AkaProxy: No root node address");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, implementationAddress, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}