pragma solidity ^0.6.8;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface ENS {
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
    function owner(bytes32 node) external view returns (address);
}

contract Certification is Ownable {
    ENS ens;
    
    bytes32 node = 0x94dbba951baaab08bb17e607f270ebe323bf4f90dc7ee482add342d350de44e8;
    mapping(address => bool) certified;
    mapping(address => bytes32) public registration;

    constructor(address _ens) public {
        ens = ENS(_ens);
    }

    function certify(address _addr) public onlyOwner {
        certified[_addr] = true;
    }

    function isCertified(address _addr) public view returns(bool) {
        return certified[_addr];
    }

    function revoke(address _addr) public onlyOwner {
        certified[_addr] = false;
        _unregisterSubnode();
    }

    function register(string memory name) public {
        require(isCertified(msg.sender), "msg.sender must be certified!");
        bytes32 label = keccak256(abi.encodePacked(name));
        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        
        require(ens.owner(subnode) == address(0x0), "this subnode is already registered to another address!");
        _unregisterSubnode();
        
        registration[msg.sender] = label;
        ens.setSubnodeOwner(node, label, msg.sender);
    }

    function _unregisterSubnode() private {
        if(registration[msg.sender] != 0) {
            ens.setSubnodeOwner(node, registration[msg.sender], address(0x0));
        }
    }
}