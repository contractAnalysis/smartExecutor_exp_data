pragma solidity ^0.5.11;


contract IManager {
    event SetController(address controller);
    event ParameterUpdate(string param);

    function setController(address _controller) external;
}



pragma solidity ^0.5.11;



contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    
    constructor() public {
        owner = msg.sender;
    }

  
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}



pragma solidity ^0.5.11;




contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    
    modifier whenPaused() {
        require(paused);
        _;
    }

    
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}



pragma solidity ^0.5.11;



contract IController is Pausable {
    event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);

    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;
    function updateController(bytes32 _id, address _controller) external;
    function getContract(bytes32 _id) public view returns (address);
}



pragma solidity ^0.5.11;




contract Manager is IManager {
    
    IController public controller;

    
    modifier onlyController() {
        require(msg.sender == address(controller), "caller must be Controller");
        _;
    }

    
    modifier onlyControllerOwner() {
        require(msg.sender == controller.owner(), "caller must be Controller owner");
        _;
    }

    
    modifier whenSystemNotPaused() {
        require(!controller.paused(), "system is paused");
        _;
    }

    
    modifier whenSystemPaused() {
        require(controller.paused(), "system is not paused");
        _;
    }

    constructor(address _controller) public {
        controller = IController(_controller);
    }

    
    function setController(address _controller) external onlyController {
        controller = IController(_controller);

        emit SetController(_controller);
    }
}



pragma solidity ^0.5.11;




contract ManagerProxyTarget is Manager {
    
    bytes32 public targetContractId;
}



pragma solidity ^0.5.11;




contract ManagerProxy is ManagerProxyTarget {
    
    constructor(address _controller, bytes32 _targetContractId) public Manager(_controller) {
        targetContractId = _targetContractId;
    }

    
    function() external payable {
        address target = controller.getContract(targetContractId);
        require(
            target != address(0),
            "target contract must be registered"
        );

        assembly {
            
            let freeMemoryPtrPosition := 0x40
            
            let calldataMemoryOffset := mload(freeMemoryPtrPosition)
            
            mstore(freeMemoryPtrPosition, add(calldataMemoryOffset, calldatasize))
            
            calldatacopy(calldataMemoryOffset, 0x0, calldatasize)

            
            let ret := delegatecall(gas, target, calldataMemoryOffset, calldatasize, 0, 0)

            
            let returndataMemoryOffset := mload(freeMemoryPtrPosition)
            
            mstore(freeMemoryPtrPosition, add(returndataMemoryOffset, returndatasize))
            
            returndatacopy(returndataMemoryOffset, 0x0, returndatasize)

            switch ret
            case 0 {
                
                
                revert(returndataMemoryOffset, returndatasize)
            } default {
                
                return(returndataMemoryOffset, returndatasize)
            }
        }
    }
}