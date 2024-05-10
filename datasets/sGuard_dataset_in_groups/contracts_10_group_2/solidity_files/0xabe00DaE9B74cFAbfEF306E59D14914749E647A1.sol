pragma solidity 0.6.2;


library Create2 {
    
    function deploy(bytes32 salt, bytes memory bytecode) internal returns (address) {
        address addr;
        
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    
    function computeAddress(bytes32 salt, bytes memory bytecode) internal view returns (address) {
        return computeAddress(salt, bytecode, address(this));
    }

    
    function computeAddress(bytes32 salt, bytes memory bytecode, address deployer) internal pure returns (address) {
        return computeAddress(salt, keccak256(bytecode), deployer);
    }

    
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(bytes20(_data << 96));
    }
}


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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public virtual onlyOwner {
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



contract Deployer is Ownable {
    event Deployed(address deployedAddress);

    
    function deploy(
        bytes calldata _initCode, 
        bytes32 _salt
    ) external onlyOwner returns(address) {
        address deployedAddress = Create2.deploy(_salt, _initCode);
        emit Deployed(deployedAddress);
        return deployedAddress;
    }

    
    function deployAndCall(
        bytes calldata _initCode, 
        bytes32 _salt,
        bytes calldata _call
    ) external onlyOwner returns(address) {
        address deployedAddress = Create2.deploy(_salt, _initCode);
        (bool success, ) = deployedAddress.call(_call);
        require(success, "Call after deployment failed.");
        emit Deployed(deployedAddress);
        return deployedAddress;
    }

    
    function computeAddress(
        bytes calldata _initCode, 
        bytes32 _salt
    ) external view returns(address) {
        return Create2.computeAddress(_salt, _initCode);
    }

    
    function computeAddressFor(
        bytes calldata _initCode, 
        bytes32 _salt,
        address _deployer
    ) external pure returns(address) {
        return Create2.computeAddress(_salt, _initCode, _deployer);
    }
}