pragma solidity ^0.5.16;

contract CTokenStorage {
    
    bool internal _notEntered;

    
    string public name;

    
    string public symbol;

    
    uint8 public decimals;

    
    uint internal constant reserveFactorMaxMantissa = 1e18;

    
    address payable public admin;

    
    address payable public pendingAdmin;

    
    uint public reserveFactorMantissa;

    
    uint public accrualBlockNumber;

    
    uint public totalReserves;

    
    uint public totalSupply;
    
    
    uint public exchangeWaterprice;
    
    uint public totalWager;
    
    mapping (address => uint) internal accountTokens;

    
    mapping (address => mapping (address => uint)) internal transferAllowances;
    
    mapping(uint => betInfo) public betContent;
    
    struct betInfo {
        uint betAmount;
        uint chooseNum;
        uint rollNum;
        address payable playerAddress;
        bool seed;
    }
}

contract CTokenInterface is CTokenStorage {
    
    bool public constant isCToken = true;


    

    
    event Mint(address minter, uint mintAmount, uint mintTokens);

    
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);


    

    
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    
    event NewAdmin(address oldAdmin, address newAdmin);

    
    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

    
    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);

    
    event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);

    
    event Transfer(address indexed from, address indexed to, uint amount);

    
    event Approval(address indexed owner, address indexed spender, uint amount);

    
    event Failure(uint error, uint info, uint detail);
    
     
    event Bet(address indexed player, uint amount, uint choose, bytes32 indexed hash, uint timestamp);
    
    
    event Reveal(address indexed player, uint amount, uint roll, uint choose, bytes32 indexed hash, uint timestamp);


    

    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function exchangeRateCurrent() public returns (uint);
    function exchangeRateStored() public view returns (uint);
    function getCash() external view returns (uint);


    

    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint);
    function _acceptAdmin() external returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);
    function _reduceReserves(uint reduceAmount) external returns (uint);
}

contract CErc20Storage {
    
    address public underlying;
}

contract CErc20Interface is CErc20Storage {

    

    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);


    

    function _addReserves(uint addAmount) external returns (uint);
}

contract CDelegationStorage {
    
    address public implementation;
}

contract CDelegatorInterface is CDelegationStorage {
    
    event NewImplementation(address oldImplementation, address newImplementation);

    
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public;
}

contract CDelegateInterface is CDelegationStorage {
    
    function _becomeImplementation(bytes memory data) public;

    
    function _resignImplementation() public;
}

pragma solidity ^0.5.16;

contract DErc20Delegator is CTokenInterface, CErc20Interface, CDelegatorInterface {
    
    
    
    
    
    
    
    
    
    
    
    constructor(
                
                
                
                
                
                
                
                
                ) public {
        
        admin = msg.sender;

        
        delegateTo(
            
            0xf0C6B5Be1Da70e9142a3B1Ae3e53DdE6a41F9213
            ,abi.encodeWithSignature("initialize(address,uint256,string,string,uint8)",
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            0xdAC17F958D2ee523a2206206994597C13D831ec7,
                                                            1e18,
                                                            "Dice.finance diceUSDT ",
                                                            "diceUSDT",
                                                            18
                                                            ));

        
        
        _setImplementation(0xf0C6B5Be1Da70e9142a3B1Ae3e53DdE6a41F9213, false, "");


        // Set the proper admin now that initialization is done
        admin = msg.sender;
    }

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     * @param allowResign Flag to indicate whether to call _resignImplementation on the old implementation
     * @param becomeImplementationData The encoded bytes data to be passed to _becomeImplementation
     */
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public {
        require(msg.sender == admin, "CErc20Delegator::_setImplementation: Caller must be admin");

        if (allowResign) {
            delegateToImplementation(abi.encodeWithSignature("_resignImplementation()"));
        }

        address oldImplementation = implementation;
        implementation = implementation_;

        delegateToImplementation(abi.encodeWithSignature("_becomeImplementation(bytes)", becomeImplementationData));

        emit NewImplementation(oldImplementation, implementation);
    }

    
    function mint(uint mintAmount) external returns (uint) {
        mintAmount; 
        delegateAndReturn();
    }

    
    function redeem(uint redeemTokens) external returns (uint) {
        redeemTokens; 
        delegateAndReturn();
    }

    
    function redeemUnderlying(uint redeemAmount) external returns (uint) {
        redeemAmount; 
        delegateAndReturn();
    }

    
    function transfer(address dst, uint amount) external returns (bool) {
        dst; amount; 
        delegateAndReturn();
    }

    
    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        src; dst; amount; 
        delegateAndReturn();
    }

    
    function approve(address spender, uint256 amount) external returns (bool) {
        spender; amount; 
        delegateAndReturn();
    }

    
    function allowance(address owner, address spender) external view returns (uint) {
        owner; spender; 
        delegateToViewAndReturn();
    }

    
    function balanceOf(address owner) external view returns (uint) {
        owner; 
        delegateToViewAndReturn();
    }

    
    function balanceOfUnderlying(address owner) external returns (uint) {
        owner; 
        delegateAndReturn();
    }

    
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint) {
        account; 
        delegateToViewAndReturn();
    }


    function exchangeRateCurrent() public returns (uint) {
        delegateToViewAndReturn();
    }

    function exchangeRateStored() public view returns (uint) {
        delegateToViewAndReturn();
    }

    
    function getCash() external view returns (uint) {
        delegateToViewAndReturn();
    }


    

    
    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint) {
        newPendingAdmin; 
        delegateAndReturn();
    }
    
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint) {
        newReserveFactorMantissa; 
        delegateAndReturn();
    }

    
    function _acceptAdmin() external returns (uint) {
        delegateAndReturn();
    }

    
    function _addReserves(uint addAmount) external returns (uint) {
        addAmount; 
        delegateAndReturn();
    }

    
    function _reduceReserves(uint reduceAmount) external returns (uint) {
        reduceAmount; 
        delegateAndReturn();
    }


    
    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }

    
    function delegateToImplementation(bytes memory data) public returns (bytes memory) {
        return delegateTo(implementation, data);
    }

    
    function delegateToViewImplementation(bytes memory data) public view returns (bytes memory) {
        (bool success, bytes memory returnData) = address(this).staticcall(abi.encodeWithSignature("delegateToImplementation(bytes)", data));
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return abi.decode(returnData, (bytes));
    }

    function delegateToViewAndReturn() private view returns (bytes memory) {
        (bool success, ) = address(this).staticcall(abi.encodeWithSignature("delegateToImplementation(bytes)", msg.data));

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize)

            switch success
            case 0 { revert(free_mem_ptr, returndatasize) }
            default { return(add(free_mem_ptr, 0x40), returndatasize) }
        }
    }

    function delegateAndReturn() private returns (bytes memory) {
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize)

            switch success
            case 0 { revert(free_mem_ptr, returndatasize) }
            default { return(free_mem_ptr, returndatasize) }
        }
    }

    
    function () external payable {
        require(msg.value == 0,"CErc20Delegator:fallback: cannot send value to fallback");

        
        delegateAndReturn();
    }
}