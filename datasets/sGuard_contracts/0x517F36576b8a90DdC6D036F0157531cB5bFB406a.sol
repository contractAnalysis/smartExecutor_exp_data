pragma solidity ^0.4.24;


library UnstructuredStorage {
    function getStorageBool(bytes32 position) internal view returns (bool data) {
        assembly { data := sload(position) }
    }

    function getStorageAddress(bytes32 position) internal view returns (address data) {
        assembly { data := sload(position) }
    }

    function getStorageBytes32(bytes32 position) internal view returns (bytes32 data) {
        assembly { data := sload(position) }
    }

    function getStorageUint256(bytes32 position) internal view returns (uint256 data) {
        assembly { data := sload(position) }
    }

    function setStorageBool(bytes32 position, bool data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageAddress(bytes32 position, address data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageBytes32(bytes32 position, bytes32 data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageUint256(bytes32 position, uint256 data) internal {
        assembly { sstore(position, data) }
    }
}





pragma solidity ^0.4.24;


interface IACL {
    function initialize(address permissionsCreator) external;

    
    
    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);
}





pragma solidity ^0.4.24;


interface IVaultRecoverable {
    event RecoverToVault(address indexed vault, address indexed token, uint256 amount);

    function transferToVault(address token) external;

    function allowRecoverability(address token) external view returns (bool);
    function getRecoveryVault() external view returns (address);
}





pragma solidity ^0.4.24;




interface IKernelEvents {
    event SetApp(bytes32 indexed namespace, bytes32 indexed appId, address app);
}



contract IKernel is IKernelEvents, IVaultRecoverable {
    function acl() public view returns (IACL);
    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);

    function setApp(bytes32 namespace, bytes32 appId, address app) public;
    function getApp(bytes32 namespace, bytes32 appId) public view returns (address);
}





pragma solidity ^0.4.24;




contract AppStorage {
    using UnstructuredStorage for bytes32;

    
    bytes32 internal constant KERNEL_POSITION = 0x4172f0f7d2289153072b0a6ca36959e0cbe2efc3afe50fc81636caa96338137b;
    bytes32 internal constant APP_ID_POSITION = 0xd625496217aa6a3453eecb9c3489dc5a53e6c67b444329ea2b2cbc9ff547639b;

    function kernel() public view returns (IKernel) {
        return IKernel(KERNEL_POSITION.getStorageAddress());
    }

    function appId() public view returns (bytes32) {
        return APP_ID_POSITION.getStorageBytes32();
    }

    function setKernel(IKernel _kernel) internal {
        KERNEL_POSITION.setStorageAddress(address(_kernel));
    }

    function setAppId(bytes32 _appId) internal {
        APP_ID_POSITION.setStorageBytes32(_appId);
    }
}





pragma solidity ^0.4.24;


contract ACLSyntaxSugar {
    function arr() internal pure returns (uint256[]) {
        return new uint256[](0);
    }

    function arr(bytes32 _a) internal pure returns (uint256[] r) {
        return arr(uint256(_a));
    }

    function arr(bytes32 _a, bytes32 _b) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a) internal pure returns (uint256[] r) {
        return arr(uint256(_a));
    }

    function arr(address _a, address _b) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {
        return arr(uint256(_a), _b, _c);
    }

    function arr(address _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {
        return arr(uint256(_a), _b, _c, _d);
    }

    function arr(address _a, uint256 _b) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a, address _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b), _c, _d, _e);
    }

    function arr(address _a, address _b, address _c) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b), uint256(_c));
    }

    function arr(address _a, address _b, uint256 _c) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b), uint256(_c));
    }

    function arr(uint256 _a) internal pure returns (uint256[] r) {
        r = new uint256[](1);
        r[0] = _a;
    }

    function arr(uint256 _a, uint256 _b) internal pure returns (uint256[] r) {
        r = new uint256[](2);
        r[0] = _a;
        r[1] = _b;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {
        r = new uint256[](3);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {
        r = new uint256[](4);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
        r[3] = _d;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {
        r = new uint256[](5);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
        r[3] = _d;
        r[4] = _e;
    }
}


contract ACLHelpers {
    function decodeParamOp(uint256 _x) internal pure returns (uint8 b) {
        return uint8(_x >> (8 * 30));
    }

    function decodeParamId(uint256 _x) internal pure returns (uint8 b) {
        return uint8(_x >> (8 * 31));
    }

    function decodeParamsList(uint256 _x) internal pure returns (uint32 a, uint32 b, uint32 c) {
        a = uint32(_x);
        b = uint32(_x >> (8 * 4));
        c = uint32(_x >> (8 * 8));
    }
}



pragma solidity ^0.4.24;


library Uint256Helpers {
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {
        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}





pragma solidity ^0.4.24;



contract TimeHelpers {
    using Uint256Helpers for uint256;

    
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    
    function getBlockNumber64() internal view returns (uint64) {
        return getBlockNumber().toUint64();
    }

    
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp; 
    }

    
    function getTimestamp64() internal view returns (uint64) {
        return getTimestamp().toUint64();
    }
}





pragma solidity ^0.4.24;




contract Initializable is TimeHelpers {
    using UnstructuredStorage for bytes32;

    
    bytes32 internal constant INITIALIZATION_BLOCK_POSITION = 0xebb05b386a8d34882b8711d156f463690983dc47815980fb82aeeff1aa43579e;

    string private constant ERROR_ALREADY_INITIALIZED = "INIT_ALREADY_INITIALIZED";
    string private constant ERROR_NOT_INITIALIZED = "INIT_NOT_INITIALIZED";

    modifier onlyInit {
        require(getInitializationBlock() == 0, ERROR_ALREADY_INITIALIZED);
        _;
    }

    modifier isInitialized {
        require(hasInitialized(), ERROR_NOT_INITIALIZED);
        _;
    }

    
    function getInitializationBlock() public view returns (uint256) {
        return INITIALIZATION_BLOCK_POSITION.getStorageUint256();
    }

    
    function hasInitialized() public view returns (bool) {
        uint256 initializationBlock = getInitializationBlock();
        return initializationBlock != 0 && getBlockNumber() >= initializationBlock;
    }

    
    function initialized() internal onlyInit {
        INITIALIZATION_BLOCK_POSITION.setStorageUint256(getBlockNumber());
    }

    
    function initializedAt(uint256 _blockNumber) internal onlyInit {
        INITIALIZATION_BLOCK_POSITION.setStorageUint256(_blockNumber);
    }
}





pragma solidity ^0.4.24;



contract Petrifiable is Initializable {
    
    uint256 internal constant PETRIFIED_BLOCK = uint256(-1);

    function isPetrified() public view returns (bool) {
        return getInitializationBlock() == PETRIFIED_BLOCK;
    }

    
    function petrify() internal onlyInit {
        initializedAt(PETRIFIED_BLOCK);
    }
}





pragma solidity ^0.4.24;



contract Autopetrified is Petrifiable {
    constructor() public {
        
        
        petrify();
    }
}



pragma solidity ^0.4.24;


library ConversionHelpers {
    string private constant ERROR_IMPROPER_LENGTH = "CONVERSION_IMPROPER_LENGTH";

    function dangerouslyCastUintArrayToBytes(uint256[] memory _input) internal pure returns (bytes memory output) {
        
        
        
        uint256 byteLength = _input.length * 32;
        assembly {
            output := _input
            mstore(output, byteLength)
        }
    }

    function dangerouslyCastBytesToUintArray(bytes memory _input) internal pure returns (uint256[] memory output) {
        
        
        
        uint256 intsLength = _input.length / 32;
        require(_input.length == intsLength * 32, ERROR_IMPROPER_LENGTH);

        assembly {
            output := _input
            mstore(output, intsLength)
        }
    }
}





pragma solidity ^0.4.24;



contract ReentrancyGuard {
    using UnstructuredStorage for bytes32;

    
    bytes32 private constant REENTRANCY_MUTEX_POSITION = 0xe855346402235fdd185c890e68d2c4ecad599b88587635ee285bce2fda58dacb;

    string private constant ERROR_REENTRANT = "REENTRANCY_REENTRANT_CALL";

    modifier nonReentrant() {
        
        require(!REENTRANCY_MUTEX_POSITION.getStorageBool(), ERROR_REENTRANT);

        
        REENTRANCY_MUTEX_POSITION.setStorageBool(true);

        
        _;

        
        REENTRANCY_MUTEX_POSITION.setStorageBool(false);
    }
}





pragma solidity ^0.4.24;



contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender)
        public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value)
        public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}





pragma solidity ^0.4.24;




contract EtherTokenConstant {
    address internal constant ETH = address(0);
}





pragma solidity ^0.4.24;


contract IsContract {
    
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}






pragma solidity ^0.4.24;



library SafeERC20 {
    
    
    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    string private constant ERROR_TOKEN_BALANCE_REVERTED = "SAFE_ERC_20_BALANCE_REVERTED";
    string private constant ERROR_TOKEN_ALLOWANCE_REVERTED = "SAFE_ERC_20_ALLOWANCE_REVERTED";

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata)
        private
        returns (bool)
    {
        bool ret;
        assembly {
            let ptr := mload(0x40)    

            let success := call(
                gas,                  
                _addr,                
                0,                    
                add(_calldata, 0x20), 
                mload(_calldata),     
                ptr,                  
                0x20                  
            )

            if gt(success, 0) {
                
                switch returndatasize

                
                case 0 {
                    ret := 1
                }

                
                case 0x20 {
                    
                    
                    ret := eq(mload(ptr), 1)
                }

                
                default { }
            }
        }
        return ret;
    }

    function staticInvoke(address _addr, bytes memory _calldata)
        private
        view
        returns (bool, uint256)
    {
        bool success;
        uint256 ret;
        assembly {
            let ptr := mload(0x40)    

            success := staticcall(
                gas,                  
                _addr,                
                add(_calldata, 0x20), 
                mload(_calldata),     
                ptr,                  
                0x20                  
            )

            if gt(success, 0) {
                ret := mload(ptr)
            }
        }
        return (success, ret);
    }

    
    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {
        bytes memory transferCallData = abi.encodeWithSelector(
            TRANSFER_SELECTOR,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(_token, transferCallData);
    }

    
    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {
        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(_token, transferFromCallData);
    }

    
    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {
        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(_token, approveCallData);
    }

    
    function staticBalanceOf(ERC20 _token, address _owner) internal view returns (uint256) {
        bytes memory balanceOfCallData = abi.encodeWithSelector(
            _token.balanceOf.selector,
            _owner
        );

        (bool success, uint256 tokenBalance) = staticInvoke(_token, balanceOfCallData);
        require(success, ERROR_TOKEN_BALANCE_REVERTED);

        return tokenBalance;
    }

    
    function staticAllowance(ERC20 _token, address _owner, address _spender) internal view returns (uint256) {
        bytes memory allowanceCallData = abi.encodeWithSelector(
            _token.allowance.selector,
            _owner,
            _spender
        );

        (bool success, uint256 allowance) = staticInvoke(_token, allowanceCallData);
        require(success, ERROR_TOKEN_ALLOWANCE_REVERTED);

        return allowance;
    }
}





pragma solidity ^0.4.24;







contract VaultRecoverable is IVaultRecoverable, EtherTokenConstant, IsContract {
    using SafeERC20 for ERC20;

    string private constant ERROR_DISALLOWED = "RECOVER_DISALLOWED";
    string private constant ERROR_VAULT_NOT_CONTRACT = "RECOVER_VAULT_NOT_CONTRACT";
    string private constant ERROR_TOKEN_TRANSFER_FAILED = "RECOVER_TOKEN_TRANSFER_FAILED";

    
    function transferToVault(address _token) external {
        require(allowRecoverability(_token), ERROR_DISALLOWED);
        address vault = getRecoveryVault();
        require(isContract(vault), ERROR_VAULT_NOT_CONTRACT);

        uint256 balance;
        if (_token == ETH) {
            balance = address(this).balance;
            vault.transfer(balance);
        } else {
            ERC20 token = ERC20(_token);
            balance = token.staticBalanceOf(this);
            require(token.safeTransfer(vault, balance), ERROR_TOKEN_TRANSFER_FAILED);
        }

        emit RecoverToVault(vault, _token, balance);
    }

    
    function allowRecoverability(address token) public view returns (bool) {
        return true;
    }

    
    function getRecoveryVault() public view returns (address);
}





pragma solidity ^0.4.24;


interface IEVMScriptExecutor {
    function execScript(bytes script, bytes input, address[] blacklist) external returns (bytes);
    function executorType() external pure returns (bytes32);
}





pragma solidity ^0.4.24;



contract EVMScriptRegistryConstants {
    
    bytes32 internal constant EVMSCRIPT_REGISTRY_APP_ID = 0xddbcfd564f642ab5627cf68b9b7d374fb4f8a36e941a75d89c87998cef03bd61;
}


interface IEVMScriptRegistry {
    function addScriptExecutor(IEVMScriptExecutor executor) external returns (uint id);
    function disableScriptExecutor(uint256 executorId) external;

    
    
    function getScriptExecutor(bytes script) public view returns (IEVMScriptExecutor);
}





pragma solidity ^0.4.24;


contract KernelAppIds {
    
    bytes32 internal constant KERNEL_CORE_APP_ID = 0x3b4bf6bf3ad5000ecf0f989d5befde585c6860fea3e574a4fab4c49d1c177d9c;
    bytes32 internal constant KERNEL_DEFAULT_ACL_APP_ID = 0xe3262375f45a6e2026b7e7b18c2b807434f2508fe1a2a3dfb493c7df8f4aad6a;
    bytes32 internal constant KERNEL_DEFAULT_VAULT_APP_ID = 0x7e852e0fcfce6551c13800f1e7476f982525c2b5277ba14b24339c68416336d1;
}


contract KernelNamespaceConstants {
    
    bytes32 internal constant KERNEL_CORE_NAMESPACE = 0xc681a85306374a5ab27f0bbc385296a54bcd314a1948b6cf61c4ea1bc44bb9f8;
    bytes32 internal constant KERNEL_APP_BASES_NAMESPACE = 0xf1f3eb40f5bc1ad1344716ced8b8a0431d840b5783aea1fd01786bc26f35ac0f;
    bytes32 internal constant KERNEL_APP_ADDR_NAMESPACE = 0xd6f028ca0e8edb4a8c9757ca4fdccab25fa1e0317da1188108f7d2dee14902fb;
}





pragma solidity ^0.4.24;







contract EVMScriptRunner is AppStorage, Initializable, EVMScriptRegistryConstants, KernelNamespaceConstants {
    string private constant ERROR_EXECUTOR_UNAVAILABLE = "EVMRUN_EXECUTOR_UNAVAILABLE";
    string private constant ERROR_PROTECTED_STATE_MODIFIED = "EVMRUN_PROTECTED_STATE_MODIFIED";

    

    event ScriptResult(address indexed executor, bytes script, bytes input, bytes returnData);

    function getEVMScriptExecutor(bytes _script) public view returns (IEVMScriptExecutor) {
        return IEVMScriptExecutor(getEVMScriptRegistry().getScriptExecutor(_script));
    }

    function getEVMScriptRegistry() public view returns (IEVMScriptRegistry) {
        address registryAddr = kernel().getApp(KERNEL_APP_ADDR_NAMESPACE, EVMSCRIPT_REGISTRY_APP_ID);
        return IEVMScriptRegistry(registryAddr);
    }

    function runScript(bytes _script, bytes _input, address[] _blacklist)
        internal
        isInitialized
        protectState
        returns (bytes)
    {
        IEVMScriptExecutor executor = getEVMScriptExecutor(_script);
        require(address(executor) != address(0), ERROR_EXECUTOR_UNAVAILABLE);

        bytes4 sig = executor.execScript.selector;
        bytes memory data = abi.encodeWithSelector(sig, _script, _input, _blacklist);

        bytes memory output;
        assembly {
            let success := delegatecall(
                gas,                
                executor,           
                add(data, 0x20),    
                mload(data),        
                0,                  
                0                   
            )

            output := mload(0x40) 

            switch success
            case 0 {
                
                returndatacopy(output, 0, returndatasize)
                revert(output, returndatasize)
            }
            default {
                switch gt(returndatasize, 0x3f)
                case 0 {
                    
                    
                    
                    
                    mstore(output, 0x08c379a000000000000000000000000000000000000000000000000000000000)         
                    mstore(add(output, 0x04), 0x0000000000000000000000000000000000000000000000000000000000000020) 
                    mstore(add(output, 0x24), 0x000000000000000000000000000000000000000000000000000000000000001e) 
                    mstore(add(output, 0x44), 0x45564d52554e5f4558454355544f525f494e56414c49445f52455455524e0000) 

                    revert(output, 100) 
                }
                default {
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    let copysize := sub(returndatasize, 0x20)
                    returndatacopy(output, 0x20, copysize)

                    mstore(0x40, add(output, copysize)) 
                }
            }
        }

        emit ScriptResult(address(executor), _script, _input, output);

        return output;
    }

    modifier protectState {
        address preKernel = address(kernel());
        bytes32 preAppId = appId();
        _; 
        require(address(kernel()) == preKernel, ERROR_PROTECTED_STATE_MODIFIED);
        require(appId() == preAppId, ERROR_PROTECTED_STATE_MODIFIED);
    }
}





pragma solidity ^0.4.24;














contract AragonApp is AppStorage, Autopetrified, VaultRecoverable, ReentrancyGuard, EVMScriptRunner, ACLSyntaxSugar {
    string private constant ERROR_AUTH_FAILED = "APP_AUTH_FAILED";

    modifier auth(bytes32 _role) {
        require(canPerform(msg.sender, _role, new uint256[](0)), ERROR_AUTH_FAILED);
        _;
    }

    modifier authP(bytes32 _role, uint256[] _params) {
        require(canPerform(msg.sender, _role, _params), ERROR_AUTH_FAILED);
        _;
    }

    
    function canPerform(address _sender, bytes32 _role, uint256[] _params) public view returns (bool) {
        if (!hasInitialized()) {
            return false;
        }

        IKernel linkedKernel = kernel();
        if (address(linkedKernel) == address(0)) {
            return false;
        }

        return linkedKernel.hasPermission(
            _sender,
            address(this),
            _role,
            ConversionHelpers.dangerouslyCastUintArrayToBytes(_params)
        );
    }

    
    function getRecoveryVault() public view returns (address) {
        
        return kernel().getRecoveryVault(); 
    }
}



pragma solidity ^0.4.24;




interface ITokenController {
    
    
    
    function proxyPayment(address _owner) external payable returns(bool);

    
    
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) external returns(bool);

    
    
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) external returns(bool);
}



pragma solidity ^0.4.24;












contract Controlled {
    
    
    modifier onlyController {
        require(msg.sender == controller);
        _;
    }

    address public controller;

    function Controlled()  public { controller = msg.sender;}

    
    
    function changeController(address _newController) onlyController  public {
        controller = _newController;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 _amount,
        address _token,
        bytes _data
    ) public;
}




contract MiniMeToken is Controlled {

    string public name;                
    uint8 public decimals;             
    string public symbol;              
    string public version = "MMT_0.1"; 


    
    
    
    struct Checkpoint {

        
        uint128 fromBlock;

        
        uint128 value;
    }

    
    
    MiniMeToken public parentToken;

    
    
    uint public parentSnapShotBlock;

    
    uint public creationBlock;

    
    
    
    mapping (address => Checkpoint[]) balances;

    
    mapping (address => mapping (address => uint256)) allowed;

    
    Checkpoint[] totalSupplyHistory;

    
    bool public transfersEnabled;

    
    MiniMeTokenFactory public tokenFactory;





    
    
    
    
    
    
    
    
    
    
    
    
    
    function MiniMeToken(
        MiniMeTokenFactory _tokenFactory,
        MiniMeToken _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    )  public
    {
        tokenFactory = _tokenFactory;
        name = _tokenName;                                 
        decimals = _decimalUnits;                          
        symbol = _tokenSymbol;                             
        parentToken = _parentToken;
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }






    
    
    
    
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {

        
        
        
        
        if (msg.sender != controller) {
            require(transfersEnabled);

            
            if (allowed[_from][msg.sender] < _amount)
                return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    
    
    
    
    
    
    function doTransfer(address _from, address _to, uint _amount) internal returns(bool) {
        if (_amount == 0) {
            return true;
        }
        require(parentSnapShotBlock < block.number);
        
        require((_to != 0) && (_to != address(this)));
        
        
        var previousBalanceFrom = balanceOfAt(_from, block.number);
        if (previousBalanceFrom < _amount) {
            return false;
        }
        
        if (isContract(controller)) {
            
            require(ITokenController(controller).onTransfer(_from, _to, _amount) == true);
        }
        
        
        updateValueAtNow(balances[_from], previousBalanceFrom - _amount);
        
        
        var previousBalanceTo = balanceOfAt(_to, block.number);
        require(previousBalanceTo + _amount >= previousBalanceTo); 
        updateValueAtNow(balances[_to], previousBalanceTo + _amount);
        
        Transfer(_from, _to, _amount);
        return true;
    }

    
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    
    
    
    
    
    
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

        
        
        
        
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        
        if (isContract(controller)) {
            
            require(ITokenController(controller).onApprove(msg.sender, _spender, _amount) == true);
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    
    
    
    
    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    
    
    
    
    
    
    function approveAndCall(ApproveAndCallFallBack _spender, uint256 _amount, bytes _extraData) public returns (bool success) {
        require(approve(_spender, _amount));

        _spender.receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    
    
    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }






    
    
    
    
    function balanceOfAt(address _owner, uint _blockNumber) public constant returns (uint) {

        
        
        
        
        
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                
                return 0;
            }

        
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    
    
    
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

        
        
        
        
        
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }





    
    
    
    
    
    
    
    
    
    
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
    ) public returns(MiniMeToken)
    {
        uint256 snapshot = _snapshotBlock == 0 ? block.number - 1 : _snapshotBlock;

        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            snapshot,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
        );

        cloneToken.changeController(msg.sender);

        
        NewCloneToken(address(cloneToken), snapshot);
        return cloneToken;
    }





    
    
    
    
    function generateTokens(address _owner, uint _amount) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); 
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); 
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroyTokens(address _owner, uint _amount) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }






    
    
    function enableTransfers(bool _transfersEnabled) onlyController public {
        transfersEnabled = _transfersEnabled;
    }





    
    
    
    
    function getValueAt(Checkpoint[] storage checkpoints, uint _block) constant internal returns (uint) {
        if (checkpoints.length == 0)
            return 0;

        
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock)
            return 0;

        
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    
    
    
    
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length - 1];
            oldCheckPoint.value = uint128(_value);
        }
    }

    
    
    
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0)
            return false;

        assembly {
            size := extcodesize(_addr)
        }

        return size>0;
    }

    
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    
    
    
    function () external payable {
        require(isContract(controller));
        
        require(ITokenController(controller).proxyPayment.value(msg.value)(msg.sender) == true);
    }





    
    
    
    
    function claimTokens(address _token) onlyController public {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }




    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}









contract MiniMeTokenFactory {

    
    
    
    
    
    
    
    
    
    
    function createCloneToken(
        MiniMeToken _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken)
    {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
        );

        newToken.changeController(msg.sender);
        return newToken;
    }
}






pragma solidity ^0.4.24;



library SafeMath {
    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        
        
        
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0, ERROR_DIV_ZERO); 
        uint256 c = _a / _b;
        

        return c;
    }

    
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}







pragma solidity ^0.4.24;



library SafeMath64 {
    string private constant ERROR_ADD_OVERFLOW = "MATH64_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH64_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH64_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH64_DIV_ZERO";

    
    function mul(uint64 _a, uint64 _b) internal pure returns (uint64) {
        uint256 c = uint256(_a) * uint256(_b);
        require(c < 0x010000000000000000, ERROR_MUL_OVERFLOW); 

        return uint64(c);
    }

    
    function div(uint64 _a, uint64 _b) internal pure returns (uint64) {
        require(_b > 0, ERROR_DIV_ZERO); 
        uint64 c = _a / _b;
        

        return c;
    }

    
    function sub(uint64 _a, uint64 _b) internal pure returns (uint64) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint64 c = _a - _b;

        return c;
    }

    
    function add(uint64 _a, uint64 _b) internal pure returns (uint64) {
        uint64 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    
    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}





pragma solidity ^0.4.18;


library ScriptHelpers {
    
    
    
    

    function abiEncode(bytes _a, bytes _b, address[] _c) public pure returns (bytes d) {
        return encode(_a, _b, _c);
    }

    function encode(bytes memory _a, bytes memory _b, address[] memory _c) internal pure returns (bytes memory d) {
        
        uint256 aPosition = 0x60;
        uint256 bPosition = aPosition + 32 * abiLength(_a);
        uint256 cPosition = bPosition + 32 * abiLength(_b);
        uint256 length = cPosition + 32 * abiLength(_c);

        d = new bytes(length);
        assembly {
            
            mstore(add(d, 0x20), aPosition)
            mstore(add(d, 0x40), bPosition)
            mstore(add(d, 0x60), cPosition)
        }

        
        copy(d, getPtr(_a), aPosition, _a.length);
        copy(d, getPtr(_b), bPosition, _b.length);
        copy(d, getPtr(_c), cPosition, _c.length * 32); 
    }

    function abiLength(bytes memory _a) internal pure returns (uint256) {
        
        
        return 1 + (_a.length / 32) + (_a.length % 32 > 0 ? 1 : 0);
    }

    function abiLength(address[] _a) internal pure returns (uint256) {
        
        return 1 + _a.length;
    }

    function copy(bytes _d, uint256 _src, uint256 _pos, uint256 _length) internal pure {
        uint dest;
        assembly {
            dest := add(add(_d, 0x20), _pos)
        }
        memcpy(dest, _src, _length);
    }

    function getPtr(bytes memory _x) internal pure returns (uint256 ptr) {
        assembly {
            ptr := _x
        }
    }

    function getPtr(address[] memory _x) internal pure returns (uint256 ptr) {
        assembly {
            ptr := _x
        }
    }

    function getSpecId(bytes _script) internal pure returns (uint32) {
        return uint32At(_script, 0);
    }

    function uint256At(bytes _data, uint256 _location) internal pure returns (uint256 result) {
        assembly {
            result := mload(add(_data, add(0x20, _location)))
        }
    }

    function bytes32At(bytes _data, uint256 _location) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(_data, add(0x20, _location)))
        }
    }

    function addressAt(bytes _data, uint256 _location) internal pure returns (address result) {
        uint256 word = uint256At(_data, _location);

        assembly {
            result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000),
            0x1000000000000000000000000)
        }
    }

    function uint32At(bytes _data, uint256 _location) internal pure returns (uint32 result) {
        uint256 word = uint256At(_data, _location);

        assembly {
            result := div(and(word, 0xffffffff00000000000000000000000000000000000000000000000000000000),
            0x100000000000000000000000000000000000000000000000000000000)
        }
    }

    function locationOf(bytes _data, uint256 _location) internal pure returns (uint256 result) {
        assembly {
            result := add(_data, add(0x20, _location))
        }
    }

    function toBytes(bytes4 _sig) internal pure returns (bytes) {
        bytes memory payload = new bytes(4);
        assembly { mstore(add(payload, 0x20), _sig) }
        return payload;
    }

    function memcpy(uint _dest, uint _src, uint _len) internal pure {
        uint256 src = _src;
        uint256 dest = _dest;
        uint256 len = _len;

        
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }
}





pragma solidity ^0.4.24;


interface IForwarder {
    function isForwarder() external pure returns (bool);

    
    
    function canForward(address sender, bytes evmCallScript) public view returns (bool);

    
    
    function forward(bytes evmCallScript) public;
}





pragma solidity ^0.4.24;











contract ADynamicForwarder is IForwarder {
    using ScriptHelpers for bytes;
    using SafeMath for uint256;
    using SafeMath64 for uint64;

    uint256 constant public OPTION_ADDR_PARAM_LOC = 1;
    uint256 constant public OPTION_SUPPORT_PARAM_LOC = 2;
    uint256 constant public INDICIES_PARAM_LOC = 3;
    uint256 constant public OPTION_INFO_PARAM_LOC = 4;
    uint256 constant public DESCRIPTION_PARAM_LOC = 5;
    uint256 constant public EX_ID1_PARAM_LOC = 6;
    uint256 constant public EX_ID2_PARAM_LOC = 7;
    uint256 constant public TOTAL_DYNAMIC_PARAMS = 7;

    struct Action {
        uint256 externalId;
        string description;
        uint256 infoStringLength;
        bytes executionScript;
        bool executed;
        bytes32[] optionKeys;
        mapping (bytes32 => OptionState) options;
    }

    struct OptionState {
        bool added;
        string metadata;
        uint8 keyArrayIndex;
        uint256 actionSupport;
        bytes32 externalId1;
        bytes32 externalId2;
    }

    mapping (bytes32 => address ) optionAddresses;
    mapping (uint256 => Action) actions;
    uint256 actionsLength = 0;

    event AddOption(uint256 actionId, address optionAddress, uint256 optionQty);
    event OptionQty(uint256 qty);
    event Address(address currentOption);
    event OrigScript(bytes script);

    
    function getOption(uint256 _actionId, uint256 _optionIndex) 
    external view returns(address optionAddress, uint256 actionSupport, string metadata, bytes32 externalId1, bytes32 externalId2)
    {
        Action storage actionInstance = actions[_actionId];
        OptionState storage option = actionInstance.options[actionInstance.optionKeys[_optionIndex]];
        optionAddress = optionAddresses[actionInstance.optionKeys[_optionIndex]];
        actionSupport = option.actionSupport;
        metadata = option.metadata;
        externalId1 = option.externalId1;
        externalId2 = option.externalId2;
    }

    
    function getOptionLength(uint256 _actionId) public view returns
    ( uint totalOptions ) { 
        totalOptions = actions[_actionId].optionKeys.length;
    }

    
    function addOption(uint256 _actionId, string _metadata, address _description, bytes32 eId1, bytes32 eId2)
    internal
    {
        
        Action storage actionInstance = actions[_actionId];
        bytes32[] storage keys = actionInstance.optionKeys;
        bytes32 cKey = keccak256(abi.encodePacked(_description));
        OptionState storage option = actionInstance.options[cKey];
        
        require(option.added == false); 
        
        require(keys.length < uint8(-1)); 
        
        option.added = true;
        option.keyArrayIndex = uint8(keys.length);
        option.metadata = _metadata;
        option.externalId1 = eId1;
        option.externalId2 = eId2;
        
        optionAddresses[cKey] = _description;
        keys.push(cKey);
        actionInstance.infoStringLength += bytes(_metadata).length;
        emit AddOption(_actionId, optionAddresses[cKey], actionInstance.optionKeys.length);
    }

    function addDynamicElements(
        bytes script,
        uint256 offset,
        uint256 numberOfOptions,
        uint256 strLength,
        uint256 desLength
    ) internal pure returns(bytes)
    {
        uint256 secondDynamicElementLocation = 32 + offset + (numberOfOptions * 32);
        uint256 thirdDynamicElementLocation = secondDynamicElementLocation + 32 + (numberOfOptions * 32);
        uint256 fourthDynamicElementLocation = thirdDynamicElementLocation + 32 + (numberOfOptions * 32);
        uint256 fifthDynamicElementLocation = fourthDynamicElementLocation + (strLength / 32) * 32 + (strLength % 32 == 0 ? 32 : 64);
        uint256 sixthDynamicElementLocation = fifthDynamicElementLocation + (desLength / 32) * 32 + (desLength % 32 == 0 ? 32 : 64);
        uint256 seventhDynamicElementLocation = sixthDynamicElementLocation + 32 + (numberOfOptions * 32);

        assembly {
            mstore(add(script, 96), secondDynamicElementLocation)
            mstore(add(script, 128), thirdDynamicElementLocation)
            mstore(add(script, 160), fourthDynamicElementLocation)
            mstore(add(script, 192), fifthDynamicElementLocation)
            mstore(add(script, 224), sixthDynamicElementLocation)
            mstore(add(script, 256), seventhDynamicElementLocation)
        }

        return script;
    }

    function _goToParamOffset(uint256 _paramNum, bytes _executionScript) internal pure returns(uint256 paramOffset) {
        
        paramOffset = _executionScript.uint256At(0x20 + (0x20 * (_paramNum - 1) )) + 0x20;

    }

    function substring(
        bytes strBytes,
        uint startIndex,
        uint endIndex
    ) internal pure returns (string)
    {
        
        
        bytes memory result = new bytes(endIndex-startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    function _iterateExtraction(uint256 _actionId, bytes _executionScript, uint256 _currentOffset, uint256 _optionLength) internal {
        uint256 currentOffset = _currentOffset;
        address currentOption;
        string memory info;
        uint256 infoEnd;
        bytes32 externalId1;
        bytes32 externalId2;
        uint256 idOffset;
        uint256 infoStart = _goToParamOffset(OPTION_INFO_PARAM_LOC,_executionScript) + 0x20;
        
        emit OptionQty(_optionLength);
        for (uint256 i = 0 ; i < _optionLength; i++) {
            currentOption = _executionScript.addressAt(currentOffset + 0x0C);
            emit Address(currentOption);
            
            infoEnd = infoStart + _executionScript.uint256At(currentOffset + (0x20 * 2 * (_optionLength + 1) ));
            info = substring(_executionScript, infoStart, infoEnd);
            
            
            currentOffset = currentOffset + 0x20;
            
            infoStart = infoEnd;
            
            idOffset = _goToParamOffset(EX_ID1_PARAM_LOC, _executionScript) + 0x20 * (i + 1);
            externalId1 = bytes32(_executionScript.uint256At(idOffset));
            idOffset = _goToParamOffset(EX_ID2_PARAM_LOC, _executionScript) + 0x20 * (i + 1);
            externalId2 = bytes32(_executionScript.uint256At(idOffset));

            addOption(_actionId, info, currentOption, externalId1, externalId2);
        }
    }

    
    function _extractOptions(bytes _executionScript, uint256 _actionId) internal {
        Action storage actionInstance = actions[_actionId];
        
        
        uint256 calldataLength = uint256(_executionScript.uint32At(0x4 + 0x14));
        
        uint256 startOffset = 0x04 + 0x14 + 0x04;
        
        
        
        
        
        uint256 firstParamOffset = _goToParamOffset(OPTION_ADDR_PARAM_LOC, _executionScript);
        uint256 fifthParamOffset = _goToParamOffset(DESCRIPTION_PARAM_LOC, _executionScript);
        uint256 currentOffset = firstParamOffset;
        
        
        require(startOffset + calldataLength == _executionScript.length); 
        
        
        uint256 optionLength = _executionScript.uint256At(currentOffset);
        currentOffset = currentOffset + 0x20;
        
        
        _iterateExtraction(_actionId, _executionScript, currentOffset, optionLength);
        uint256 descriptionStart = fifthParamOffset + 0x20;
        uint256 descriptionEnd = descriptionStart + (_executionScript.uint256At(fifthParamOffset));
        actionInstance.description = substring(_executionScript, descriptionStart, descriptionEnd);
        
        
        
        
        
        
        
        
    }

    function addAddressesAndActions(
        uint256 _actionId,
        bytes script,
        uint256 numberOfOptions,
        uint256 dynamicOffset
        ) internal view returns(uint256 offset)
        {
                
        offset = 64 + dynamicOffset;

        assembly { 
            mstore(add(script, offset), numberOfOptions)
        }

        offset += 32;

        
        for (uint256 i = 0; i < numberOfOptions; i++) {
            bytes32 canKey = actions[_actionId].optionKeys[i];
            uint256 optionData = uint256(optionAddresses[canKey]);
            assembly {
                mstore(add(script, offset), optionData)
            }
            offset += 32;
        }

        assembly { 
            mstore(add(script, offset), numberOfOptions)
        }

        offset += 32;

        
        for (i = 0; i < numberOfOptions; i++) {
            uint256 supportsData = actions[_actionId].options[actions[_actionId].optionKeys[i]].actionSupport;

            assembly { 
                mstore(add(script, offset), supportsData)
            }
            offset += 32;
        }
        return offset;
    }

    function addInfoString(
        uint256 _actionId,
        bytes script,
        uint256 numberOfOptions,
        uint256 _offset)
        internal view returns (uint256 newOffset)
    {
        Action storage actionInstance = actions[_actionId];
        uint256 infoStringLength = actionInstance.infoStringLength;
        bytes memory infoString = new bytes(infoStringLength);
        bytes memory optionMetaData;
        uint256 metaDataLength;
        uint256 strOffset = 0;
        newOffset = _offset;
        
        assembly { 
            mstore(add(script, newOffset), numberOfOptions)
        }
        
        newOffset += 32;

        for (uint256 i = 0; i < numberOfOptions; i++) {
            bytes32 canKey = actionInstance.optionKeys[i];
            optionMetaData = bytes(actionInstance.options[canKey].metadata);
            infoString.copy(optionMetaData.getPtr() + 32, strOffset, optionMetaData.length);
            strOffset += optionMetaData.length;
            metaDataLength = optionMetaData.length;

            assembly { 
                mstore(add(script, newOffset), metaDataLength)
            }

            newOffset += 32;
        }

        assembly { 
                mstore(add(script, newOffset), infoStringLength)
        }


        script.copy(infoString.getPtr() + 32, newOffset, infoStringLength);

        newOffset += (infoStringLength / 32) * 32 + (infoStringLength % 32 == 0 ? 0 : 32);
    }

    function addExternalIds(
        uint256 _actionId,
        bytes script,
        uint256 numberOfOptions,
        uint256 _offset
        ) internal view returns(uint256 offset)
        {
        offset = _offset;
        assembly { 
            mstore(add(script, offset), numberOfOptions)
        }

        offset += 32;

        
        for (uint256 i = 0; i < numberOfOptions; i++) {
            
            bytes32 externalId1 = actions[_actionId].options[actions[_actionId].optionKeys[i]].externalId1;
            assembly {
                mstore(add(script, offset), externalId1)
            }
            offset += 32;

        }

        assembly { 
            mstore(add(script, offset), numberOfOptions)
        }

        offset += 32;

        
        for (i = 0; i < numberOfOptions; i++) {
            bytes32 externalId2 = actions[_actionId].options[actions[_actionId].optionKeys[i]].externalId2;

            assembly { 
                mstore(add(script, offset), externalId2)
            }
            offset += 32;

        }
        return offset;
    }

    function memcpyshort(uint _dest, uint _src, uint _len) internal pure {
        uint256 src = _src;
        uint256 dest = _dest;
        uint256 len = _len;

        
        
        
        uint mask = 256 ** (32 - len) - 1;
        assembly { 
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function encodeInput(uint256 _actionId) internal returns(bytes) {
        Action storage action = actions[_actionId];
        uint256 optionsLength = action.optionKeys.length;

        
        bytes memory origExecScript = new bytes(32);
        
        origExecScript = action.executionScript;
        
        
        
        uint256 dynamicOffset = origExecScript.uint256At(32);
        
        
        
        
        
        
        uint256 infoStrLength = action.infoStringLength;
        uint256 desStrLength = bytes(action.description).length;
        
        
        
        
        
        
        
        uint256 callDataLength = 228 + dynamicOffset + optionsLength * 160;
        
        
        callDataLength += (infoStrLength / 32) * 32 + (infoStrLength % 32 == 0 ? 0 : 32);
        callDataLength += (desStrLength / 32) * 32 + (desStrLength % 32 == 0 ? 0 : 32);
        
        bytes memory callDataLengthMem = new bytes(32);
        
        assembly { 
            mstore(add(callDataLengthMem, 32), callDataLength)
        }
        
        
        
        
        bytes memory script = new bytes(callDataLength + 28);
        
        
        script.copy(origExecScript.getPtr() + 32,0, 96); 
        
        memcpyshort((script.getPtr() + 56), callDataLengthMem.getPtr() + 60, 4);
        
        addDynamicElements(script, dynamicOffset, optionsLength, infoStrLength, desStrLength);
        
        script.copy(origExecScript.getPtr() + 288, 256, dynamicOffset - 224); 
        
        
        uint256 offset = addAddressesAndActions(_actionId, script, optionsLength, dynamicOffset);

        offset = _goToParamOffset(INDICIES_PARAM_LOC, script) + 0x20;
        
        
        offset = addInfoString(_actionId, script, optionsLength, offset);
        
        offset = _goToParamOffset(DESCRIPTION_PARAM_LOC, script) + 0x20;
        assembly { 
                mstore(add(script, offset), desStrLength)
        }
        script.copy(bytes(action.description).getPtr() + 32, offset, desStrLength);
        
        offset = _goToParamOffset(EX_ID1_PARAM_LOC, script) + 0x20;
        addExternalIds(_actionId, script, optionsLength, offset);
        emit OrigScript(origExecScript);
        return script;
    }

    function parseScript(bytes _executionScript) internal returns(uint256 actionId) {
        actionId = actionsLength++;
        Action storage actionInstance = actions[actionId];
        actionInstance.executionScript = _executionScript;
        actionInstance.infoStringLength = 0;
        
        require(_executionScript.uint32At(0x0) == 1); 
        if (_executionScript.length != 4) {
            _extractOptions(_executionScript, actionId);
        }
        
        actionInstance.externalId = _goToParamOffset(TOTAL_DYNAMIC_PARAMS + 1, _executionScript) - 0x20;
        emit OrigScript(_executionScript);
    }
}





pragma solidity 0.4.24;








contract DotVoting is ADynamicForwarder, AragonApp {

    MiniMeToken public token;
    uint256 public globalCandidateSupportPct;
    uint256 public globalMinQuorum;
    uint64 public voteTime;
    uint256 voteLength;

    uint256 constant public PCT_BASE = 10 ** 18; 


    
    bytes32 constant public ROLE_ADD_CANDIDATES = 0xa71d8ae250b03a7b4831d7ee658104bf1ee3193c61256a07e2008fdfb75c5fa9;
    
    bytes32 constant public ROLE_CREATE_VOTES = 0x59036cbdc6597a5655363d74de8211c9fcba4dd9204c466ef593666e56a6e574;
    
    bytes32 constant public ROLE_MODIFY_QUORUM = 0xaa42a0cff9103a0165dffb0f5652f3a480d3fb6edf2c364f5e2110629719a5a7;
    
    bytes32 constant public ROLE_MODIFY_CANDIDATE_SUPPORT = 0xbd671bb523f136ed8ffc557fe00fbb016a7f9f856a4b550bb6366d356dcb8c74;

    string private constant ERROR_CAN_VOTE = "ERROR_CAN_VOTE";
    string private constant ERROR_MIN_QUORUM = "ERROR_MIN_QUORUM";
    string private constant ERROR_VOTE_LENGTH = "ERROR_VOTE_LENGTH";

    struct Vote {
        string metadata;
        address creator;
        uint64 startDate;
        uint256 snapshotBlock;
        uint256 candidateSupportPct;
        uint256 minQuorum;
        uint256 totalVoters;
        uint256 totalParticipation;
        mapping (address => uint256[]) voters;
        uint256 actionId;
    }

    mapping (uint256 => Vote) votes;

    event StartVote(uint256 indexed voteId);
    event CastVote(uint256 indexed voteId);
    event UpdateCandidateSupport(string indexed candidateKey, uint256 support);
    event ExecuteVote(uint256 indexed voteId);
    event ExecutionScript(bytes script, uint256 data);
    
    event ExternalContract(uint256 indexed voteId, address addr, bytes32 funcSig);
    event AddCandidate(uint256 voteId, address candidate, uint length);
    event Metadata(string metadata);
    event Location(uint256 currentLocation);
    event Address(address candidate);
    event CandidateQty(uint256 numberOfCandidates);
    event UpdateQuorum(uint256 quorum);
    event UpdateMinimumSupport(uint256 minSupport);





   
    function initialize(
        MiniMeToken _token,
        uint256 _minQuorum,
        uint256 _candidateSupportPct,
        uint64 _voteTime
    ) external onlyInit
    {
        initialized();
        require(_minQuorum > 0, ERROR_MIN_QUORUM);
        require(_minQuorum <= PCT_BASE, ERROR_MIN_QUORUM);
        require(_minQuorum >= _candidateSupportPct, ERROR_MIN_QUORUM);
        token = _token;
        globalMinQuorum = _minQuorum;
        globalCandidateSupportPct = _candidateSupportPct;
        voteTime = _voteTime;
        voteLength = 1;
    }






    
    function newVote(bytes _executionScript, string _metadata)
        external auth(ROLE_CREATE_VOTES) returns (uint256 voteId)
    {
        voteId = _newVote(_executionScript, _metadata);
    }

    
    function vote(uint256 _voteId, uint256[] _supports)  external isInitialized {
        require(canVote(_voteId, msg.sender), ERROR_CAN_VOTE);
        _vote(_voteId, _supports, msg.sender);
    }

    
    function executeVote(uint256 _voteId) external isInitialized {
        require(canExecute(_voteId), ERROR_CAN_VOTE);
        _executeVote(_voteId);
    }

    
    function getCandidate(uint256 _voteId, uint256 _candidateIndex)
    external view isInitialized returns(address candidateAddress, uint256 voteSupport, string metadata, bytes32 externalId1, bytes32 externalId2)
    {
        require(_voteId < voteLength, ERROR_VOTE_LENGTH); 
        uint256 actionId = votes[_voteId].actionId;
        Action storage action = actions[actionId];
        uint256 candidateLength = action.optionKeys.length;
        require(_candidateIndex < candidateLength); 
        OptionState storage candidate = action.options[action.optionKeys[_candidateIndex]];
        candidateAddress = optionAddresses[action.optionKeys[_candidateIndex]];
        voteSupport = candidate.actionSupport;
        metadata = candidate.metadata;
        externalId1 = candidate.externalId1;
        externalId2 = candidate.externalId2;
    }

    
    function setglobalCandidateSupportPct(uint256 _globalCandidateSupportPct)
    external auth(ROLE_MODIFY_CANDIDATE_SUPPORT)
    {
        require(globalMinQuorum >= _globalCandidateSupportPct); 
        globalCandidateSupportPct = _globalCandidateSupportPct;
        emit UpdateMinimumSupport(globalCandidateSupportPct);
    }

    
    function setGlobalQuorum(uint256 _minQuorum)
    external auth(ROLE_MODIFY_QUORUM)
    {
        require(_minQuorum > 0); 
        require(_minQuorum <= PCT_BASE); 
        require(_minQuorum >= globalCandidateSupportPct); 
        globalMinQuorum = _minQuorum;
        emit UpdateQuorum(globalMinQuorum);
    }

    
    function addCandidate(uint256 _voteId, string _metadata, address _description, bytes32 _eId1, bytes32 _eId2)
    public auth(ROLE_ADD_CANDIDATES)
    {
        Vote storage voteInstance = votes[_voteId];
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        require(_isVoteOpen(voteInstance)); 
        addOption(votes[_voteId].actionId, _metadata, _description, _eId1, _eId2);
    }





    
    function isForwarder() public pure returns (bool) {
        return true;
    }

    
    function canForward(address _sender, bytes ) public view returns (bool) {
        return canPerform(_sender, ROLE_CREATE_VOTES, arr());
    }

    

        
    function forward(bytes _evmScript) public { 
        require(canForward(msg.sender, _evmScript)); 
        _newVote(_evmScript, "");
    }

///////////////////////
// View state functions
///////////////////////

    /**
    * @notice `canVote` is used to check whether an address is elligible to
    *         cast a dot vote in a given dot vote action.
    * @param _voteId The ID of the Vote on which the vote would be cast.
    * @param _voter The address of the entity trying to vote
    * @return True is `_voter` has a vote token balance and vote is open
    */
    function canVote(uint256 _voteId, address _voter) public view isInitialized returns (bool) {
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        Vote storage voteInstance = votes[_voteId];
        return _isVoteOpen(voteInstance) && token.balanceOfAt(_voter, voteInstance.snapshotBlock) > 0;
    }

    /**
    * @notice `canExecute` is used to check that the participation has been met
    *         and the vote has reached it's end before the execute function is
    *         called.
    * @param _voteId id for vote structure this 'ballot action' is connected to
    * @return True if the vote is elligible for execution.
    */
    function canExecute(uint256 _voteId) public view isInitialized returns (bool) {
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        Vote storage voteInstance = votes[_voteId];
        Action storage action = actions[voteInstance.actionId];
        if (action.executed)
            return false;
         // vote ended?
        if (_isVoteOpen(voteInstance))
          return false;
         // has minimum participation threshold been reached?
        if (!_isValuePct(voteInstance.totalParticipation, voteInstance.totalVoters, voteInstance.minQuorum))
            return false;
        return true;
    }

    /**
    * @notice `getVote` splits all of the data elements out of a vote
    *         struct and returns the individual values.
    * @param _voteId The ID of the Vote struct in the `votes` array
    */
    function getVote(uint256 _voteId) public view isInitialized returns
    (
        bool open,
        address creator,
        uint64 startDate,
        uint256 snapshotBlock,
        uint256 candidateSupport,
        uint256 totalVoters,
        uint256 totalParticipation,
        uint256 externalId,
        bytes executionScript, // script,
        bool executed,
        string voteDescription
    ) { // solium-disable-line lbrace
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        Vote storage voteInstance = votes[_voteId];
        Action memory action = actions[voteInstance.actionId];
        open = _isVoteOpen(voteInstance);
        creator = voteInstance.creator;
        startDate = voteInstance.startDate;
        snapshotBlock = voteInstance.snapshotBlock;
        candidateSupport = voteInstance.candidateSupportPct;
        totalVoters = voteInstance.totalVoters;
        totalParticipation = voteInstance.totalParticipation;
        executionScript = action.executionScript;
        executed = action.executed;
        externalId = action.externalId;
        voteDescription = action.description;
    }

        /**
    * @notice `getCandidateLength` returns the total number of voting options for
    *         a given dot vote.
    * @param _voteId The ID of the Vote struct in the `votes` array
    */
    function getCandidateLength(uint256 _voteId) public view isInitialized returns
    ( uint totalCandidates ) { // solium-disable-line lbrace
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        uint256 actionId = votes[_voteId].actionId;
        totalCandidates = actions[actionId].optionKeys.length;
    }

    /**
    * @notice `getVoteMetadata` returns the vote metadata for a given dot vote.
    * @param _voteId The ID of the Vote struct in the `votes` array
    */
    function getVoteMetadata(uint256 _voteId) public view isInitialized returns (string) {
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        return votes[_voteId].metadata;
    }

    /**
    * @notice `getVoterState` returns the voting power for a given voter.
    * @param _voteId The ID of the Vote struct in the `votes` array.
    * @param _voter The voter whose weights will be returned
    */
    function getVoterState(uint256 _voteId, address _voter) public view isInitialized returns (uint256[]) {
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        return votes[_voteId].voters[_voter];
    }

///////////////////////
// Internal functions
///////////////////////

    /**
    * @notice `_newVote` starts a new vote and adds it to the votes array.
    *         votes are not started with a vote from the caller, as candidates
    *         and candidate weights need to be supplied.
    * @param _executionScript The script that will be executed when
    *        this vote closes. Script is of the following form:
    *            [ specId (uint32: 4 bytes) ] many calls with this structure ->
    *            [ to (address: 20 bytes) ]
    *            [calldataLength (uint32: 4 bytes) ]
    *            [ function hash (uint32: 4 bytes) ]
    *            [ calldata (calldataLength bytes) ]
    *        In order to work with a dot vote the execution script must contain
    *        Arrays as its first six parameters. Non-string array lengths must all equal candidateLength
    *        The first Array is generally a list of identifiers (address)
    *        The second array will be composed of support value (uint256).
    *        The third array will be end index for each candidates Information within the infoString (optional uint256)
    *        The fourth array is a string of concatenated candidate information, the infoString (optional string)
    *        The fifth array is used for description params (optional string)
    *        The sixth array is an array of identification keys (optional uint256)
    *        The seventh array is a second array of identification keys, usually mapping to a second level (optional uint256)
    *        The eigth parameter is used as the identifier for this vote. (uint256)
    *        See ExecutionTarget.sol in the test folder for an example  forwarded function (setSignal)
    * @param _metadata The metadata or vote information attached to the vote.
    * @return voteId The ID(or index) of this vote in the votes array.
    */
    function _newVote(bytes _executionScript, string _metadata) internal
    isInitialized returns (uint256 voteId)
    {
        require(_executionScript.uint32At(0x0) == 1); // solium-disable-line error-reason
        uint256 actionId = parseScript(_executionScript);
        voteId = voteLength++;
        Vote storage voteInstance = votes[voteId];
        voteInstance.creator = msg.sender;
        voteInstance.metadata = _metadata;
        voteInstance.actionId = actionId;
        voteInstance.startDate = uint64(block.timestamp); // solium-disable-line security/no-block-members
        voteInstance.snapshotBlock = getBlockNumber() - 1; // avoid double voting in this very block
        voteInstance.totalVoters = token.totalSupplyAt(voteInstance.snapshotBlock);
        voteInstance.candidateSupportPct = globalCandidateSupportPct;
        voteInstance.minQuorum = globalMinQuorum;
        // First Static Parameter in script parsed for the externalId
        emit ExternalContract(voteId, _executionScript.addressAt(0x4),_executionScript.bytes32At(0x0));
        emit StartVote(voteId);
        emit ExecutionScript(_executionScript, 0);
    }

    /**
    * @dev `_vote` is the internal function that allows a token holder to
    *         caste a vote on the current options.
    * @param _voteId id for vote structure this 'ballot action' is connected to
    * @param _supports Array of support weights in order of their order in
    *        `votes[_voteId].candidateKeys`, sum of all supports must be less
    *        than `token.balance[msg.sender]`.
    * @param _voter The address of the entity "casting" this vote action.
    */
    function _vote(
        uint256 _voteId,
        uint256[] _supports,
        address _voter
    ) internal
    {
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        Vote storage voteInstance = votes[_voteId];
        Action storage action = actions[voteInstance.actionId];

        
        
        uint256 voterStake = token.balanceOfAt(_voter, voteInstance.snapshotBlock);
        uint256 totalSupport = 0;

        emit CastVote(_voteId);


        uint256 voteSupport;
        uint256[] storage oldVoteSupport = voteInstance.voters[msg.sender];
        bytes32[] storage cKeys = action.optionKeys;
        uint256 supportsLength = _supports.length;
        uint256 oldSupportLength = oldVoteSupport.length;
        uint256 totalParticipation = voteInstance.totalParticipation;
        require(cKeys.length == supportsLength); 
        require(oldSupportLength <= supportsLength); 
        _checkTotalSupport(_supports, voterStake);
        uint256 i = 0;
        
        
        
        for (i; i < oldSupportLength; i++) {
            voteSupport = action.options[cKeys[i]].actionSupport;
            totalParticipation = totalParticipation.sub(oldVoteSupport[i]);
            voteSupport = voteSupport.sub(oldVoteSupport[i]);
            voteSupport = voteSupport.add(_supports[i]);
            totalParticipation = totalParticipation.add(_supports[i]);
            action.options[cKeys[i]].actionSupport = voteSupport;
        }
        for (i; i < supportsLength; i++) {
            voteSupport = action.options[cKeys[i]].actionSupport;
            voteSupport = voteSupport.add(_supports[i]);
            totalParticipation = totalParticipation.add(_supports[i]);
            action.options[cKeys[i]].actionSupport = voteSupport;
        }
        voteInstance.totalParticipation = totalParticipation;
        voteInstance.voters[msg.sender] = _supports;
    }

    function _checkTotalSupport(uint256[] _supports, uint256 _voterStake) internal {
        uint256 totalSupport;
        for (uint64 i = 0; i < _supports.length; i++) {
            totalSupport = totalSupport.add(_supports[i]);
        }
        require(totalSupport <= _voterStake); 
    }

    
    function _pruneVotes(uint256 _voteId, uint256 _candidateSupportPct) internal {
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        Vote storage voteInstance = votes[_voteId];
        uint256 actionId = voteInstance.actionId;
        Action storage action = actions[actionId];
        bytes32[] memory candidateKeys = actions[actionId].optionKeys;
        uint256 candidateLength = candidateKeys.length;
        for (uint256 i = 0; i < candidateLength; i++) {
            bytes32 key = candidateKeys[i];
            OptionState storage candidateState = action.options[key];
            if (!_isValuePct(candidateState.actionSupport, voteInstance.totalParticipation, voteInstance.candidateSupportPct)) {
                voteInstance.totalParticipation -= candidateState.actionSupport;
                candidateState.actionSupport = 0;
            }
        }
    }

    
    function _executeVote(uint256 _voteId) internal {
        require(_voteId < voteLength, ERROR_VOTE_LENGTH);
        Vote storage voteInstance = votes[_voteId];
        uint256 actionId = voteInstance.actionId;
        Action storage action = actions[actionId];
        uint256 candidateSupportPct = voteInstance.candidateSupportPct;
        if (candidateSupportPct > 0) {
            _pruneVotes(_voteId, candidateSupportPct);
        }
        bytes memory script = encodeInput(voteInstance.actionId);
        emit ExecutionScript(script, 0);
        action.executed = true;
        runScript(script, new bytes(0), new address[](0));
        emit ExecuteVote(_voteId);
    }

    
    function _isVoteOpen(Vote storage voteArg) internal view returns (bool) {
        bool voteWithinTime = uint64(block.timestamp) < (voteArg.startDate.add(voteTime)); 
        return voteWithinTime && !actions[voteArg.actionId].executed;
    }

    
    function _isValuePct(uint256 _value, uint256 _total, uint256 _pct)
        internal pure returns (bool)
    {
        
        if (_value == 0 && _total > 0)
            return false;
        

        uint256 m = _total.mul(_pct);
        uint256 v = m / PCT_BASE;
        

        

        
        
        return m % PCT_BASE == 0 ? _value >= v : _value > v;
    }
}