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





pragma solidity 0.4.24;




contract AddressBook is AragonApp {

    
    
    bytes32 public constant ADD_ENTRY_ROLE = 0x4a167688760e93a8dd0a899c70e125af7d665ed37fd06496b8c83ce9fdac41bd;
    
    bytes32 public constant REMOVE_ENTRY_ROLE = 0x4bf67e2ff5501162fc2ee020c851b17118c126a125e7f189b1c10056a35a8ed1;
    
    bytes32 public constant UPDATE_ENTRY_ROLE = 0x6838798f8ade371d93fbc95e535888e5fdc0abba71f87ab7320dd9c8220b4da0;

    
    string private constant ERROR_NOT_FOUND = "ENTRY_DOES_NOT_EXIST";
    string private constant ERROR_EXISTS = "ENTRY_ALREADY_EXISTS";
    string private constant ERROR_CID_MALFORMED = "CID_MALFORMED";
    string private constant ERROR_CID_LENGTH = "CID_LENGTH_INCORRECT";
    string private constant ERROR_NO_CID = "CID_DOES_NOT_MATCH";

    struct Entry {
        string data;
        uint256 index;
    }

    
    mapping(address => Entry) public entries;

    
    mapping(uint256 => address) public entryArr;
    uint256 public entryArrLength;

    
    event EntryAdded(address addr); 
    event EntryRemoved(address addr); 
    event EntryUpdated(address addr); 

    
    modifier entryExists(address _addr) {
        require(isEntryAdded(_addr), ERROR_NOT_FOUND);
        _;
    }

    
    modifier cidIsValid(string _cid) {
        bytes memory cidBytes = bytes(_cid);
        require(cidBytes[0] == "Q" && cidBytes[1] == "m", ERROR_CID_MALFORMED);
        require(cidBytes.length == 46, ERROR_CID_LENGTH);
        _;
    }

    
    function initialize() external onlyInit {
        initialized();
    }

    
    function addEntry(address _addr, string _cid) external cidIsValid(_cid) auth(ADD_ENTRY_ROLE) {
        require(bytes(entries[_addr].data).length == 0, ERROR_EXISTS);
        
        
        uint256 entryIndex = entryArrLength++;
        entryArr[entryIndex] = _addr;
        entries[_addr] = Entry(_cid, entryIndex);
        emit EntryAdded(_addr);
    }

    
    function removeEntry(address _addr, string _cid) external entryExists(_addr) auth(REMOVE_ENTRY_ROLE) {
        require(keccak256(bytes(_cid)) == keccak256(bytes(entries[_addr].data)), ERROR_NO_CID);
        uint256 rowToDelete = entries[_addr].index;
        if (entryArrLength != 1) {
            address entryToMove = entryArr[entryArrLength - 1];
            entryArr[rowToDelete] = entryToMove;
            entries[entryToMove].index = rowToDelete;
        }
        delete entries[_addr];
        
        entryArrLength--;
        emit EntryRemoved(_addr);
    }

    
    function updateEntry(
        address _addr,
        string _oldCid,
        string _newCid
    ) external auth(UPDATE_ENTRY_ROLE) entryExists(_addr) cidIsValid(_newCid)
    {
        require(keccak256(bytes(_oldCid)) == keccak256(bytes(entries[_addr].data)), ERROR_NO_CID);
        entries[_addr].data = _newCid;
        emit EntryUpdated(_addr);
    }

    
    function getEntry(address _addr) external view isInitialized returns (string contentId) {
        contentId = entries[_addr].data;
    }

    
    function getEntryIndex(address _addr) external view isInitialized entryExists(_addr) returns (uint256 index) {
        index = entries[_addr].index;
    }

    
    function isEntryAdded(address _entry) public view returns (bool isAdded) {
        if (entryArrLength == 0) {
            return false;
        }

        if (entries[_entry].index >= entryArrLength) {
            return false;
        }

        return (entryArr[entries[_entry].index] == _entry);
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



pragma solidity 0.4.24;



contract DepositableStorage {
    using UnstructuredStorage for bytes32;

    
    bytes32 internal constant DEPOSITABLE_POSITION = 0x665fd576fbbe6f247aff98f5c94a561e3f71ec2d3c988d56f12d342396c50cea;

    function isDepositable() public view returns (bool) {
        return DEPOSITABLE_POSITION.getStorageBool();
    }

    function setDepositable(bool _depositable) internal {
        DEPOSITABLE_POSITION.setStorageBool(_depositable);
    }
}



pragma solidity 0.4.24;







contract Vault is EtherTokenConstant, AragonApp, DepositableStorage {
    using SafeERC20 for ERC20;

    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    string private constant ERROR_DATA_NON_ZERO = "VAULT_DATA_NON_ZERO";
    string private constant ERROR_NOT_DEPOSITABLE = "VAULT_NOT_DEPOSITABLE";
    string private constant ERROR_DEPOSIT_VALUE_ZERO = "VAULT_DEPOSIT_VALUE_ZERO";
    string private constant ERROR_TRANSFER_VALUE_ZERO = "VAULT_TRANSFER_VALUE_ZERO";
    string private constant ERROR_SEND_REVERTED = "VAULT_SEND_REVERTED";
    string private constant ERROR_VALUE_MISMATCH = "VAULT_VALUE_MISMATCH";
    string private constant ERROR_TOKEN_TRANSFER_FROM_REVERTED = "VAULT_TOKEN_TRANSFER_FROM_REVERT";
    string private constant ERROR_TOKEN_TRANSFER_REVERTED = "VAULT_TOKEN_TRANSFER_REVERTED";

    event VaultTransfer(address indexed token, address indexed to, uint256 amount);
    event VaultDeposit(address indexed token, address indexed sender, uint256 amount);

    
    function () external payable isInitialized {
        require(msg.data.length == 0, ERROR_DATA_NON_ZERO);
        _deposit(ETH, msg.value);
    }

    
    function initialize() external onlyInit {
        initialized();
        setDepositable(true);
    }

    
    function deposit(address _token, uint256 _value) external payable isInitialized {
        _deposit(_token, _value);
    }

    
    
    function transfer(address _token, address _to, uint256 _value)
        external
        authP(TRANSFER_ROLE, arr(_token, _to, _value))
    {
        require(_value > 0, ERROR_TRANSFER_VALUE_ZERO);

        if (_token == ETH) {
            require(_to.send(_value), ERROR_SEND_REVERTED);
        } else {
            require(ERC20(_token).safeTransfer(_to, _value), ERROR_TOKEN_TRANSFER_REVERTED);
        }

        emit VaultTransfer(_token, _to, _value);
    }

    function balance(address _token) public view returns (uint256) {
        if (_token == ETH) {
            return address(this).balance;
        } else {
            return ERC20(_token).staticBalanceOf(address(this));
        }
    }

    
    function allowRecoverability(address) public view returns (bool) {
        return false;
    }

    function _deposit(address _token, uint256 _value) internal {
        require(isDepositable(), ERROR_NOT_DEPOSITABLE);
        require(_value > 0, ERROR_DEPOSIT_VALUE_ZERO);

        if (_token == ETH) {
            
            require(msg.value == _value, ERROR_VALUE_MISMATCH);
        } else {
            require(
                ERC20(_token).safeTransferFrom(msg.sender, address(this), _value),
                ERROR_TOKEN_TRANSFER_FROM_REVERTED
            );
        }

        emit VaultDeposit(_token, msg.sender, _value);
    }
}





pragma solidity ^0.4.24;






contract Allocations is AragonApp {

    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using SafeERC20 for ERC20;

    bytes32 public constant CREATE_ACCOUNT_ROLE = 0x9b9e262b9ea0587fdc5926b22b8ed5837efef4f4cc67bc1a7ee18f68ad83062f;
    bytes32 public constant CREATE_ALLOCATION_ROLE = 0x8af1e3d6225e5adff5174a4949cb3cc04f0f62937083325a9e302eaf5d07cdf1;
    bytes32 public constant EXECUTE_ALLOCATION_ROLE = 0x1ced0be26d1bb2db7a1a0a01064be22894ce4ca0321b6f4b28d0b1a5ce62e7ea;
    bytes32 public constant EXECUTE_PAYOUT_ROLE = 0xa5cf757319c734091fd95cf4b09938ff69ee22637eda897ea92ca59e56f00bcb;
    bytes32 public constant CHANGE_PERIOD_ROLE = 0xd35e458bacdd5343c2f050f574554b2f417a8ea38d6a9a65ce2225dbe8bb9a9d;
    bytes32 public constant CHANGE_BUDGETS_ROLE = 0xd79730e82bfef7d2f9639b9d10bf37ebb662b22ae2211502a00bdf7b2cc3a23a;
    bytes32 public constant SET_MAX_CANDIDATES_ROLE = 0xe593f1908655effa3e2eb1eab075684bd646a51d97f20646bb9ecb2df3e4f2bb;

    uint256 internal constant MAX_UINT256 = uint256(-1);
    uint64 internal constant MAX_UINT64 = uint64(-1);
    uint64 internal constant MINIMUM_PERIOD = uint64(1 days);
    uint256 internal constant MAX_SCHEDULED_PAYOUTS_PER_TX = 20;

    string private constant ERROR_NO_PERIOD = "NO_PERIOD";
    string private constant ERROR_NO_ACCOUNT = "NO_ACCOUNT";
    string private constant ERROR_NO_PAYOUT = "NO_PAYOUT";
    string private constant ERROR_NO_CANDIDATE = "NO_CANDIDATE";
    string private constant ERROR_PERIOD_SHORT = "SET_PERIOD_TOO_SHORT";
    string private constant ERROR_COMPLETE_TRANSITION = "COMPLETE_TRANSITION";
    string private constant ERROR_MIN_RECURRENCE = "RECURRENCES_BELOW_ONE";
    string private constant ERROR_CANDIDATE_NOT_RECEIVER = "CANDIDATE_NOT_RECEIVER";
    string private constant ERROR_INSUFFICIENT_FUNDS = "INSUFFICIENT_FUNDS";

    struct Payout {
        uint64 startTime;
        uint64 recurrences;
        uint64 period;
        address[] candidateAddresses;
        uint256[] supports;
        uint64[] executions;
        uint256 amount;
        string description;
    }

    struct Account {
        uint64 payoutsLength;
        bool hasBudget;
        address token;
        mapping (uint64 => Payout) payouts;
        string metadata;
        uint256 budget;
    }

    struct AccountStatement {
        mapping(address => uint256) expenses;
    }

    struct Period {
        uint64 startTime;
        uint64 endTime;
        mapping (uint256 => AccountStatement) accountStatement;
    }

    uint64 accountsLength;
    uint64 periodsLength;
    uint64 periodDuration;
    uint256 maxCandidates;
    Vault public vault;
    mapping (uint64 => Account) accounts;
    mapping (uint64 => Period) periods;
    mapping(address => uint) accountProxies; 

    event PayoutExecuted(uint64 accountId, uint64 payoutId, uint candidateId);
    event NewAccount(uint64 accountId);
    event NewPeriod(uint64 indexed periodId, uint64 periodStarts, uint64 periodEnds);
    event FundAccount(uint64 accountId);
    event SetDistribution(uint64 accountId, uint64 payoutId);
    event PaymentFailure(uint64 accountId, uint64 payoutId, uint256 candidateId);
    event SetBudget(uint256 indexed accountId, uint256 amount, string name, bool hasBudget);
    event ChangePeriodDuration(uint64 newDuration);

    modifier periodExists(uint64 _periodId) {
        require(_periodId < periodsLength, ERROR_NO_PERIOD);
        _;
    }

    modifier accountExists(uint64 _accountId) {
        require(_accountId < accountsLength, ERROR_NO_ACCOUNT);
        _;
    }

    modifier payoutExists(uint64 _accountId, uint64 _payoutId) {
        require(_payoutId < accounts[_accountId].payoutsLength, ERROR_NO_PAYOUT);
        _;
    }

    
    
    
    modifier transitionsPeriod {
        require(
            _tryTransitionAccountingPeriod(getMaxPeriodTransitions()),
            ERROR_COMPLETE_TRANSITION
        );
        _;
    }

    
    function initialize(
        Vault _vault,
        uint64 _periodDuration
    ) external onlyInit
    {
        vault = _vault;
        require(_periodDuration >= MINIMUM_PERIOD, ERROR_PERIOD_SHORT);
        periodDuration = _periodDuration;
        _newPeriod(getTimestamp64());
        accountsLength++;  
        maxCandidates = 50;
        initialized();
    }




    
    function getAccount(uint64 _accountId) external view accountExists(_accountId) isInitialized
    returns(string metadata, address token, bool hasBudget, uint256 budget)
    {
        Account storage account = accounts[_accountId];
        metadata = account.metadata;
        token = account.token;
        hasBudget = account.hasBudget;
        budget = account.budget;
    }

    
    function getPayout(uint64 _accountId, uint64 _payoutId) external view payoutExists(_accountId, _payoutId) isInitialized
    returns(uint amount, uint64 recurrences, uint startTime, uint period)
    {
        Payout storage payout = accounts[_accountId].payouts[_payoutId];
        amount = payout.amount;
        recurrences = payout.recurrences;
        startTime = payout.startTime;
        period = payout.period;
    }

    
    function getRemainingBudget(uint64 _accountId) external view accountExists(_accountId)
    returns(uint256)
    {
        return _getRemainingBudget(_accountId);
    }

    
    function getPayoutDescription(uint64 _accountId, uint64 _payoutId)
    external
    view
    payoutExists(_accountId, _payoutId)
    isInitialized
    returns(string description)
    {
        Payout storage payout = accounts[_accountId].payouts[_payoutId];
        description = payout.description;
    }

    
    function getNumberOfCandidates(uint64 _accountId, uint64 _payoutId) external view isInitialized payoutExists(_accountId, _payoutId)
    returns(uint256 numCandidates)
    {
        Payout storage payout = accounts[_accountId].payouts[_payoutId];
        numCandidates = payout.supports.length;
    }

    
    function getPayoutDistributionValue(uint64 _accountId, uint64 _payoutId, uint256 _idx)
    external
    view
    isInitialized
    payoutExists(_accountId, _payoutId)
    returns(uint256 supports, address candidateAddress, uint64 executions)
    {
        Payout storage payout = accounts[_accountId].payouts[_payoutId];
        require(_idx < payout.supports.length, ERROR_NO_CANDIDATE);
        supports = payout.supports[_idx];
        candidateAddress = payout.candidateAddresses[_idx];
        executions = payout.executions[_idx];
    }

    
    function getCurrentPeriodId() external view isInitialized returns (uint64) {
        return _currentPeriodId();
    }

    
    function getPeriod(uint64 _periodId)
    external
    view
    isInitialized
    periodExists(_periodId)
    returns (
        bool isCurrent,
        uint64 startTime,
        uint64 endTime
    )
    {
        Period storage period = periods[_periodId];

        isCurrent = _currentPeriodId() == _periodId;

        startTime = period.startTime;
        endTime = period.endTime;
    }




    
    function newAccount(
        string _metadata,
        address _token,
        bool _hasBudget,
        uint256 _budget
    ) external auth(CREATE_ACCOUNT_ROLE) returns(uint64 accountId)
    {
        accountId = accountsLength++;
        Account storage account = accounts[accountId];
        account.metadata = _metadata;
        account.hasBudget = _hasBudget;
        account.budget = _budget;
        account.token = _token;
        emit NewAccount(accountId);
    }

    
    function setPeriodDuration(uint64 _periodDuration)
        external
        auth(CHANGE_PERIOD_ROLE)
        transitionsPeriod
    {
        require(_periodDuration >= MINIMUM_PERIOD, ERROR_PERIOD_SHORT);
        periodDuration = _periodDuration;
        emit ChangePeriodDuration(_periodDuration);
    }

    
    function setMaxCandidates(uint256 _maxCandidates) external auth(SET_MAX_CANDIDATES_ROLE) {
        maxCandidates = _maxCandidates;
    }

    
    function setBudget(
        uint64 _accountId,
        uint256 _amount,
        string _metadata
    )
        external
        auth(CHANGE_BUDGETS_ROLE)
        transitionsPeriod
        accountExists(_accountId)
    {
        accounts[_accountId].budget = _amount;
        
        if (bytes(_metadata).length > 0) {
            accounts[_accountId].metadata = _metadata;
        }
        if (!accounts[_accountId].hasBudget) {
            accounts[_accountId].hasBudget = true;
        }
        emit SetBudget(_accountId, _amount, _metadata, true);
    }

    
    function removeBudget(uint64 _accountId, string _metadata)
        external
        auth(CHANGE_BUDGETS_ROLE)
        transitionsPeriod
        accountExists(_accountId)
    {
        accounts[_accountId].budget = 0;
        accounts[_accountId].hasBudget = false;
        
        if (bytes(_metadata).length > 0) {
            accounts[_accountId].metadata = _metadata;
        }
        emit SetBudget(_accountId, 0, _metadata, false);
    }

    
    function candidateExecutePayout(
        uint64 _accountId,
        uint64 _payoutId,
        uint256 _candidateId
    ) external transitionsPeriod isInitialized accountExists(_accountId) payoutExists(_accountId, _payoutId) 
    {
        
        require(msg.sender == accounts[_accountId].payouts[_payoutId].candidateAddresses[_candidateId], ERROR_CANDIDATE_NOT_RECEIVER);
        _executePayoutAtLeastOnce(_accountId, _payoutId, _candidateId, 0);
    }

    
    function executePayout(
        uint64 _accountId,
        uint64 _payoutId,
        uint256 _candidateId
    ) external transitionsPeriod auth(EXECUTE_PAYOUT_ROLE) accountExists(_accountId) payoutExists(_accountId, _payoutId)
    {
        _executePayoutAtLeastOnce(_accountId, _payoutId, _candidateId, 0);
    }

    
    function runPayout(uint64 _accountId, uint64 _payoutId)
    external
    auth(EXECUTE_ALLOCATION_ROLE)
    transitionsPeriod
    accountExists(_accountId)
    payoutExists(_accountId, _payoutId)
    returns(bool success)
    {
        success = _runPayout(_accountId, _payoutId);
    }

    
    function advancePeriod(uint64 _limit) external isInitialized {
        _tryTransitionAccountingPeriod(_limit);
    }

    
    function setDistribution(
        address[] _candidateAddresses,
        uint256[] _supports,
        uint256[] ,
        string ,
        string _description,
        uint256[] ,
        uint256[] ,
        uint64 _accountId,
        uint64 _recurrences,
        uint64 _startTime,
        uint64 _period,
        uint256 _amount
    ) public auth(CREATE_ALLOCATION_ROLE) returns(uint64 payoutId)
    {
        require(maxCandidates >= _candidateAddresses.length); 
        Account storage account = accounts[_accountId];
        require(vault.balance(account.token) >= _amount * _recurrences); 
        require(_recurrences > 0, ERROR_MIN_RECURRENCE);

        Payout storage payout = account.payouts[account.payoutsLength++];

        payout.amount = _amount;
        payout.recurrences = _recurrences;
        payout.candidateAddresses = _candidateAddresses;
        if (_recurrences > 1) {
            payout.period = _period;
            
            require(payout.period >= 1 days, ERROR_PERIOD_SHORT);
        }
        payout.startTime = _startTime; 
        payout.supports = _supports;
        payout.description = _description;
        payout.executions.length = _supports.length;
        payoutId = account.payoutsLength - 1;
        emit SetDistribution(_accountId, payoutId);
        if (_startTime <= getTimestamp64()) {
            _runPayout(_accountId, payoutId);
        }
    }

    function _executePayoutAtLeastOnce(
        uint64 _accountId,
        uint64 _payoutId,
        uint256 _candidateId,
        uint256 _paid
    )
        internal accountExists(_accountId) returns (uint256)
    {
        Account storage account = accounts[_accountId];
        Payout storage payout = account.payouts[_payoutId];
        require(_candidateId < payout.supports.length, ERROR_NO_CANDIDATE);

        uint256 paid = _paid;
        uint256 totalSupport = _getTotalSupport(payout);

        uint256 individualPayout = payout.supports[_candidateId].mul(payout.amount).div(totalSupport);
        if (individualPayout == 0) {
            return;
        }
        while (_nextPaymentTime(_accountId, _payoutId, _candidateId) <= getTimestamp64() && paid < MAX_SCHEDULED_PAYOUTS_PER_TX) {
            if (!_canMakePayment(_accountId, individualPayout)) {
                emit PaymentFailure(_accountId, _payoutId, _candidateId);
                break;
            }

            
            paid += 1;

            
            _executeCandidatePayout(_accountId, _payoutId, _candidateId, totalSupport);
        }
        return paid;
    }

    function _newPeriod(uint64 _startTime) internal returns (Period storage) {
        
        uint64 newPeriodId = periodsLength++;

        Period storage period = periods[newPeriodId];
        period.startTime = _startTime;

        
        
        uint64 endTime = _startTime + periodDuration - 1;
        if (endTime < _startTime) { 
            endTime = MAX_UINT64;
        }
        period.endTime = endTime;

        emit NewPeriod(newPeriodId, period.startTime, period.endTime);

        return period;
    }

    function _tryTransitionAccountingPeriod(uint64 _maxTransitions) internal returns (bool success) {
        Period storage currentPeriod = periods[_currentPeriodId()];
        uint64 maxTransitions = _maxTransitions;
        uint64 timestamp = getTimestamp64();

        
        while (timestamp > currentPeriod.endTime) {
            if (maxTransitions == 0) {
                
                
                return false;
            }
            
            maxTransitions -= 1;

            currentPeriod = _newPeriod(currentPeriod.endTime.add(1));
        }

        return true;
    }

    function _currentPeriodId() internal view returns (uint64) {
        
        return periodsLength - 1;
    }

    function _canMakePayment(uint64 _accountId, uint256 _amount) internal view returns (bool) {
        Account storage account = accounts[_accountId];
        return _getRemainingBudget(_accountId) >= _amount && vault.balance(account.token) >= _amount && _amount > 0;
    }

    function _getRemainingBudget(uint64 _accountId) internal view returns (uint256) {
        Account storage account = accounts[_accountId];
        if (!account.hasBudget) {
            return MAX_UINT256;
        }

        uint256 budget = account.budget;
        uint256 spent = periods[_currentPeriodId()].accountStatement[_accountId].expenses[account.token];

        
        
        if (spent >= budget) {
            return 0;
        }

        
        return budget - spent;
    }

    function _runPayout(uint64 _accountId, uint64 _payoutId) internal returns(bool success) {
        Account storage account = accounts[_accountId];
        uint256[] storage supports = account.payouts[_payoutId].supports;
        uint64 i;
        uint256 paid = 0;
        uint256 length = account.payouts[_payoutId].candidateAddresses.length;
        
        for (i = 0; i < length; i++) {
            if (supports[i] != 0 && _nextPaymentTime(_accountId, _payoutId, i) <= getTimestamp64()) {
                paid = _executePayoutAtLeastOnce(_accountId, _payoutId, i, paid);
            } else {
                emit PaymentFailure(_accountId, _payoutId, i);
            }
        }
        success = true;
    }

    function _getTotalSupport(Payout storage payout) internal view returns (uint256 totalSupport) {
        for (uint256 i = 0; i < payout.supports.length; i++) {
            totalSupport += payout.supports[i];
        }
    }

    function _nextPaymentTime(uint64 _accountId, uint64 _payoutId, uint256 _candidateIndex) internal view returns (uint64) {
        Account storage account = accounts[_accountId];
        Payout storage payout = account.payouts[_payoutId];

        if (payout.executions[_candidateIndex] >= payout.recurrences) {
            return MAX_UINT64; 
        }

        
        uint64 increase = payout.executions[_candidateIndex].mul(payout.period);
        uint64 nextPayment = payout.startTime.add(increase);
        return nextPayment;
    }

    function _executeCandidatePayout(
        uint64 _accountId,
        uint64 _payoutId,
        uint256 _candidateIndex,
        uint256 _totalSupport
    ) internal
    {
        Account storage account = accounts[_accountId];
        Payout storage payout = account.payouts[_payoutId];
        uint256 individualPayout = payout.supports[_candidateIndex].mul(payout.amount).div(_totalSupport);
        require(_canMakePayment(_accountId, individualPayout), ERROR_INSUFFICIENT_FUNDS);

        address token = account.token;
        uint256 expenses = periods[_currentPeriodId()].accountStatement[_accountId].expenses[token];
        periods[_currentPeriodId()].accountStatement[_accountId].expenses[token] = expenses.add(individualPayout);
        payout.executions[_candidateIndex] = payout.executions[_candidateIndex].add(1);
        vault.transfer(token, payout.candidateAddresses[_candidateIndex], individualPayout);
        emit PayoutExecuted(_accountId, _payoutId, _candidateIndex);
    }

    
    

    function getMaxPeriodTransitions() internal view returns (uint64) { return MAX_UINT64; }
}





pragma solidity ^0.4.24;


interface IForwarder {
    function isForwarder() external pure returns (bool);

    
    
    function canForward(address sender, bytes evmCallScript) public view returns (bool);

    
    
    function forward(bytes evmCallScript) public;
}



pragma solidity ^0.4.24;





contract DiscussionApp is IForwarder, AragonApp {
    using SafeMath for uint256;

    event Post(address indexed author, string postCid, uint256 discussionThreadId, uint256 postId, uint256 createdAt);
    event Revise(
        address indexed author,
        string revisedPostCid,
        uint256 discussionThreadId,
        uint256 postId,
        uint256 createdAt,
        uint256 revisedAt
    );
    event Hide(address indexed author, uint256 discussionThreadId, uint256 postId, uint256 hiddenAt);
    event CreateDiscussionThread(uint256 actionId, bytes _evmScript);

    bytes32 public constant EMPTY_ROLE = keccak256("EMPTY_ROLE");

    string private constant ERROR_CAN_NOT_FORWARD = "DISCUSSIONS_CAN_NOT_FORWARD";

    struct DiscussionPost {
        address author;
        string postCid;
        uint256 discussionThreadId;
        uint256 id;
        uint256 createdAt;
        bool show;
        string[] revisionCids;
    }

    uint256 discussionThreadId;

    mapping(uint256 => DiscussionPost[]) public discussionThreadPosts;

    function initialize() external onlyInit {
        discussionThreadId = 0;
        initialized();
    }

    
    function post(string postCid, uint256 discussionThreadId) external {
        DiscussionPost storage post;
        post.author = msg.sender;
        post.postCid = postCid;
        post.discussionThreadId = discussionThreadId;
        post.createdAt = now; 
        post.show = true;
        uint256 postId = discussionThreadPosts[discussionThreadId].length;
        post.id = postId;
        discussionThreadPosts[discussionThreadId].push(post);
        emit Post(msg.sender, postCid, discussionThreadId, postId, now); 
    }

    
    function hide(uint256 postId, uint256 discussionThreadId) external {
        DiscussionPost storage post = discussionThreadPosts[discussionThreadId][postId];
        require(post.author == msg.sender, "You cannot hide a post you did not author.");
        post.show = false;
        emit Hide(msg.sender, discussionThreadId, postId, now); 
    }

    
    function revise(string revisedPostCid, uint256 postId, uint256 discussionThreadId) external {
        DiscussionPost storage post = discussionThreadPosts[discussionThreadId][postId];
        require(post.author == msg.sender, "You cannot revise a post you did not author.");
        
        
        post.revisionCids.push(post.postCid);
        post.postCid = revisedPostCid;
        emit Revise(
            msg.sender,
            revisedPostCid,
            discussionThreadId,
            postId,
            post.createdAt,
            now 
        );
    }

    

    
    function isForwarder() external pure returns (bool) {
        return true;
    }

    
    function forward(bytes _evmScript) public {
        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);
        bytes memory input = new bytes(0); 
        address[] memory blacklist = new address[](1);
        emit CreateDiscussionThread(discussionThreadId, _evmScript);
        discussionThreadId = discussionThreadId + 1;
        runScript(_evmScript, input, blacklist);
    }

    
    function canForward(address _sender, bytes) public view returns (bool) {
        return true;
    }
}





pragma solidity 0.4.24;






interface Bounties {
    
    function fulfillBounty(
        address _sender,
        uint _bountyId,
        address[] _fulfillers,
        string _data
    ) external; 

    
    function updateFulfillment(
        address _sender,
        uint _bountyId,
        uint _fulfillmentId,
        address[] _fulfillers,
        string _data
    ) external; 

    function issueBounty(
        address sender,
        address[] _issuers,
        address[] _approvers,
        string _data,
        uint _deadline,
        address _token,
        uint _tokenVersion
    ) external returns (uint);

    function contribute(
        address _sender,
        uint _bountyId,
        uint _amount
    ) external payable;

    function issueAndContribute(
        address sender,
        address[] _issuers,
        address[] _approvers,
        string _data,
        uint _deadline,
        address _token,
        uint _tokenVersion,
        uint _depositAmount
    ) external payable returns (uint);

    function performAction(
        address _sender,
        uint _bountyId,
        string _data
    ) external;

    function acceptFulfillment(
        address _sender,
        uint _bountyId,
        uint _fulfillmentId,
        uint _approverId,
        uint[] _tokenAmounts
    ) external;

    function drainBounty(
        address _sender,
        uint _bountyId,
        uint _issuerId,
        uint[] _amounts
    ) external;

    function changeDeadline(
        address _sender,
        uint _bountyId,
        uint _issuerId,
        uint _deadline
    ) external;

    function changeData(
        address _sender,
        uint _bountyId,
        uint _issuerId,
        string _data
    ) external;
}


interface ERC20Token {
    function approve(address _spender, uint256 _value) external returns (bool success);
    function transfer(address to, uint tokens) external returns (bool success);
}



contract Projects is AragonApp, DepositableStorage {

    using SafeMath for uint256;

    Bounties public bountiesRegistry;
    BountySettings public settings;
    Vault public vault;
    
    bytes32 public constant FUND_ISSUES_ROLE =  keccak256("FUND_ISSUES_ROLE");
    bytes32 public constant REMOVE_ISSUES_ROLE = keccak256("REMOVE_ISSUES_ROLE");
    bytes32 public constant ADD_REPO_ROLE = keccak256("ADD_REPO_ROLE");
    bytes32 public constant CHANGE_SETTINGS_ROLE =  keccak256("CHANGE_SETTINGS_ROLE");
    bytes32 public constant CURATE_ISSUES_ROLE = keccak256("CURATE_ISSUES_ROLE");
    bytes32 public constant REMOVE_REPO_ROLE =  keccak256("REMOVE_REPO_ROLE");
    bytes32 public constant REVIEW_APPLICATION_ROLE = keccak256("REVIEW_APPLICATION_ROLE");
    bytes32 public constant WORK_REVIEW_ROLE = keccak256("WORK_REVIEW_ROLE");
    bytes32 public constant FUND_OPEN_ISSUES_ROLE = keccak256("FUND_OPEN_ISSUES_ROLE");
    bytes32 public constant UPDATE_BOUNTIES_ROLE = keccak256("UPDATE_BOUNTIES_ROLE");

    string private constant ERROR_PROJECTS_VAULT_NOT_CONTRACT = "PROJECTS_VAULT_NOT_CONTRACT";
    string private constant ERROR_STANDARD_BOUNTIES_NOT_CONTRACT = "STANDARD_BOUNTIES_NOT_CONTRACT";
    string private constant ERROR_LENGTH_EXCEEDED = "LENGTH_EXCEEDED";
    string private constant ERROR_LENGTH_MISMATCH = "ARRAY_LENGTH_MISMATCH";
    string private constant ERROR_CID_LENGTH = "IPFS_ADDRESSES_LENGTH";
    string private constant ERROR_ISSUE_INACTIVE = "ISSUE_NOT_ACTIVE";
    string private constant ERROR_ISSUE_ACTIVE = "ISSUE_HAS_BOUNTY";
    string private constant ERROR_BOUNTY_FULFILLED = "BOUNTY_FULFILLED";
    string private constant ERROR_BOUNTY_REMOVED = "BOUNTY_REMOVED";
    string private constant ERROR_INVALID_AMOUNT = "INVALID_TOKEN_AMOUNT";
    string private constant ERROR_ETH_CONTRACT = "WRONG_ETH_TOKEN";
    string private constant ERROR_REPO_MISSING = "REPO_NOT_ADDED";
    string private constant ERROR_REPO_EXISTS = "REPO_ALREADY_ADDED";
    string private constant ERROR_USER_APPLIED = "USER_ALREADY_APPLIED";
    string private constant ERROR_NO_APPLICATION = "USER_APPLICATION_MISSING";
    string private constant ERROR_NO_ERC721 = "ERC_721_FORBIDDEN";
    string private constant ERROR_PENDING_BOUNTIES = "REPO_HAS_PENDING_BOUNTIES";
    string private constant ERROR_OPEN_BOUNTY = "CANNOT_ASSIGN_OPEN_BOUNTY";


    
    uint256 private constant CID_LENGTH = 46;

    
    mapping(bytes32 => Repo) private repos;
    
    mapping (bytes32 => uint256) openBounties;
    
    mapping(uint256 => bytes32) private repoIndex;
    uint256 private repoIndexLength;
    enum SubmissionStatus { Unreviewed, Accepted, Rejected }  

    
    struct BountySettings {
        uint256[] expMultipliers;
        bytes32[] expLevels;
        uint256 baseRate;
        uint256 bountyDeadline;
        address bountyCurrency;
    }

    struct Repo {
        mapping(uint256 => Issue) issues;
        uint index;
    }

    struct AssignmentRequest {
        SubmissionStatus status;
        string requestHash; 
        bool exists;
    }

    struct Issue {
        bytes32 repo;  
        uint256 number; 
        bool hasBounty;
        bool fulfilled;
        address tokenContract;
        uint256 bountySize;
        uint256 priority;
        address bountyWallet; 
        uint standardBountyId;
        address assignee;
        address[] applicants;
        
        uint256[] submissionIndices;
        mapping(address => AssignmentRequest) assignmentRequests;
    }

    
    event RepoAdded(bytes32 indexed repoId, uint index);
    
    event RepoRemoved(bytes32 indexed repoId, uint index);
    
    event RepoUpdated(bytes32 indexed repoId, uint newIndex);
    
    event BountyAdded(bytes32 repoId, uint256 issueNumber, uint256 bountySize, uint256 registryId, string ipfsHash);
    
    event BountyRemoved(bytes32 repoId, uint256 issueNumber, uint256 oldBountySize);
    
    event IssueCurated(bytes32 repoId);
    
    event BountySettingsChanged();
    
    event AssignmentRequested(bytes32 indexed repoId, uint256 issueNumber);
    
    event AssignmentApproved(address applicant, bytes32 indexed repoId, uint256 issueNumber);
    
    event AssignmentRejected(address applicant, bytes32 indexed repoId, uint256 issueNumber);
    
    event SubmissionAccepted(uint256 submissionNumber, bytes32 repoId, uint256 issueNumber);
    
    event SubmissionRejected(uint256 submissionNumber, bytes32 repoId, uint256 issueNumber);
    
    event AwaitingSubmissions(bytes32 repoId, uint256 issueNumber);


    
    function initialize(
        address _bountiesAddr,
        Vault _vault
    ) external onlyInit
    {
        require(isContract(_vault), ERROR_PROJECTS_VAULT_NOT_CONTRACT);
        require(isContract(_bountiesAddr), ERROR_STANDARD_BOUNTIES_NOT_CONTRACT);

        vault = _vault;

        bountiesRegistry = Bounties(_bountiesAddr); 

        _addExperienceLevel(100, bytes32("Beginner"));
        _addExperienceLevel(300, bytes32("Intermediate"));
        _addExperienceLevel(500, bytes32("Advanced"));

        _changeBountySettings(
            0, 
            336, 
            ETH, 
            _bountiesAddr 
        );

        setDepositable(true);
        initialized();
    }






    
    function changeBountySettings(
        uint256[] _expMultipliers,
        bytes32[] _expLevels,
        uint256 _baseRate,
        uint256 _bountyDeadline,
        address _bountyCurrency,
        address _bountyAllocator
    ) external auth(CHANGE_SETTINGS_ROLE)
    {
        require(_expMultipliers.length == _expLevels.length, ERROR_LENGTH_MISMATCH);
        require(_isBountiesContractValid(_bountyAllocator), ERROR_STANDARD_BOUNTIES_NOT_CONTRACT);
        settings.expLevels.length = 0;
        settings.expMultipliers.length = 0;
        for (uint i = 0; i < _expLevels.length; i++) {
            _addExperienceLevel(_expMultipliers[i], _expLevels[i]);
        }
        _changeBountySettings(_baseRate, _bountyDeadline, _bountyCurrency, _bountyAllocator);
    }





    
    function getIssue(bytes32 _repoId, uint256 _issueNumber) external view isInitialized
    returns(bool hasBounty, uint standardBountyId, bool fulfilled, uint balance, address assignee)
    {
        Issue storage issue = repos[_repoId].issues[_issueNumber];
        hasBounty = issue.hasBounty;
        fulfilled = issue.fulfilled;
        standardBountyId = issue.standardBountyId;
        balance = issue.bountySize;
        assignee = issue.assignee;
    }

    
    function getReposCount() external view isInitialized returns (uint count) {
        return repoIndexLength;
    }

    
    function getRepo(bytes32 _repoId) external view isInitialized returns (uint256 index, uint256 openIssueCount) {
        require(isRepoAdded(_repoId), ERROR_REPO_MISSING);
        index = repos[_repoId].index;
        openIssueCount = openBounties[_repoId];
    }

    

    function getSettings() external view isInitialized returns (
        uint256[] expMultipliers,
        bytes32[] expLevels,
        uint256 baseRate,
        uint256 bountyDeadline,
        address bountyCurrency,
        address bountyAllocator
        
    )
    {
        return (
            settings.expMultipliers,
            settings.expLevels,
            settings.baseRate,
            settings.bountyDeadline,
            settings.bountyCurrency,
            bountiesRegistry
            
        );
    }




    
    function addRepo(
        bytes32 _repoId
    ) external auth(ADD_REPO_ROLE) returns (uint index)
    {
        require(!isRepoAdded(_repoId), ERROR_REPO_EXISTS);
        repoIndex[repoIndexLength] = _repoId;
        repos[_repoId].index = repoIndexLength++;
        
        emit RepoAdded(_repoId, repos[_repoId].index);
        return repoIndexLength - 1;
    }

    
    function removeRepo(
        bytes32 _repoId
    ) external auth(REMOVE_REPO_ROLE) returns (bool success)
    {
        require(isRepoAdded(_repoId), ERROR_REPO_MISSING);
        require(openBounties[_repoId] == 0, ERROR_PENDING_BOUNTIES);
        uint rowToDelete = repos[_repoId].index;

        if (repoIndexLength != 1) {
            bytes32 repoToMove = repoIndex[repoIndexLength - 1];
            repoIndex[rowToDelete] = repoToMove;
            repos[repoToMove].index = rowToDelete;
        }

        repoIndexLength--;
        emit RepoRemoved(_repoId, rowToDelete);
        return true;
    }





    
    function requestAssignment(
        bytes32 _repoId,
        uint256 _issueNumber,
        string _application
    ) external isInitialized
    {
        Issue storage issue = repos[_repoId].issues[_issueNumber];

        require(!issue.fulfilled,ERROR_BOUNTY_FULFILLED);
        require(issue.hasBounty, ERROR_ISSUE_INACTIVE);
        require(issue.assignee != address(-1), ERROR_OPEN_BOUNTY);
        require(issue.assignmentRequests[msg.sender].exists == false, ERROR_USER_APPLIED);

        issue.applicants.push(msg.sender);
        issue.assignmentRequests[msg.sender] = AssignmentRequest(
            SubmissionStatus.Unreviewed,
            _application,
            true
        );
        bountiesRegistry.performAction(
            address(this),
            issue.standardBountyId,
            _application
        );
        emit AssignmentRequested(_repoId, _issueNumber);
    }

    
    function reviewApplication(
        bytes32 _repoId,
        uint256 _issueNumber,
        address _requestor,
        string _updatedApplication,
        bool _approved
    ) external auth(REVIEW_APPLICATION_ROLE)
    {
        Issue storage issue = repos[_repoId].issues[_issueNumber];
        require(issue.assignee != address(-1), ERROR_OPEN_BOUNTY);
        require(issue.assignmentRequests[_requestor].exists == true, ERROR_NO_APPLICATION);
        issue.assignmentRequests[_requestor].requestHash = _updatedApplication;

        if (_approved) {
            issue.assignee = _requestor;
            issue.assignmentRequests[_requestor].status = SubmissionStatus.Accepted;
            emit AssignmentApproved(_requestor, _repoId, _issueNumber);
        } else {
            issue.assignmentRequests[_requestor].status = SubmissionStatus.Rejected;
            emit AssignmentRejected(_requestor, _repoId, _issueNumber);
        }
        bountiesRegistry.performAction(
            address(this),
            issue.standardBountyId,
            _updatedApplication
        );

    }

    
    function reviewSubmission(
        bytes32 _repoId,
        uint256 _issueNumber,
        uint256 _submissionNumber,
        bool _approved,
        string _updatedSubmissionHash,
        uint256[] _tokenAmounts
    ) external auth(WORK_REVIEW_ROLE)
    {
        Issue storage issue = repos[_repoId].issues[_issueNumber];

        require(!issue.fulfilled,ERROR_BOUNTY_FULFILLED);
        require(issue.assignee != address(0), ERROR_ISSUE_INACTIVE);

        if (_approved) {
            uint256 tokenTotal;
            for (uint256 i = 0; i < _tokenAmounts.length; i++) {
                tokenTotal = tokenTotal.add(_tokenAmounts[i]);
            }
            require(tokenTotal >= issue.bountySize, ERROR_INVALID_AMOUNT);

            issue.fulfilled = true;
            bountiesRegistry.acceptFulfillment(
                address(this),
                issue.standardBountyId,
                _submissionNumber,
                0,
                _tokenAmounts
            );
            openBounties[_repoId] = openBounties[_repoId].sub(1);
            emit SubmissionAccepted(_submissionNumber, _repoId, _issueNumber);
        } else {
            emit SubmissionRejected(_submissionNumber, _repoId, _issueNumber);
        }

        bountiesRegistry.performAction(
            address(this),
            issue.standardBountyId,
            _updatedSubmissionHash
        );
    }

    
    function updateBounty(
        bytes32 _repoId,
        uint256 _issueNumber,
        string _data,
        uint256 _deadline,
        string _description
    ) external auth(UPDATE_BOUNTIES_ROLE)
    {
        Issue storage issue = repos[_repoId].issues[_issueNumber];

        require(!issue.fulfilled,ERROR_BOUNTY_FULFILLED);
        require(issue.hasBounty, ERROR_ISSUE_INACTIVE);

        bountiesRegistry.changeData(
            address(this),
            issue.standardBountyId,
            0,
            _data
        );
        bountiesRegistry.changeDeadline(
            address(this),
            issue.standardBountyId,
            0,
            _deadline
        );
    }

    
    function removeBounties(
        bytes32[] _repoIds,
        uint256[] _issueNumbers,
        string _description
    ) external auth(REMOVE_ISSUES_ROLE)
    {
        require(_repoIds.length < 256, ERROR_LENGTH_EXCEEDED);
        require(_issueNumbers.length < 256, ERROR_LENGTH_EXCEEDED);
        require(_repoIds.length == _issueNumbers.length, ERROR_LENGTH_MISMATCH);
        for (uint8 i = 0; i < _issueNumbers.length; i++) {
            _removeBounty(_repoIds[i], _issueNumbers[i]);
        }
    }





    
    function getApplicantsLength(
        bytes32 _repoId,
        uint256 _issueNumber
    ) external view isInitialized returns(uint256 applicantQty)
    {
        applicantQty = repos[_repoId].issues[_issueNumber].applicants.length;
    }

    
    function getApplicant(
        bytes32 _repoId,
        uint256 _issueNumber,
        uint256 _idx
    ) external view isInitialized returns(address applicant, string application, SubmissionStatus status)
    {
        Issue storage issue = repos[_repoId].issues[_issueNumber];
        applicant = issue.applicants[_idx];
        application = issue.assignmentRequests[applicant].requestHash;
        status = issue.assignmentRequests[applicant].status;
    }





    
    function addBounties(
        bytes32[] _repoIds,
        uint256[] _issueNumbers,
        uint256[] _bountySizes,
        uint256[] _deadlines,
        uint256[] _tokenTypes,
        address[] _tokenContracts,
        string _ipfsAddresses,
        string _description
    ) public payable auth(FUND_ISSUES_ROLE)
    {
        
        
        string memory ipfsHash;
        uint standardBountyId;
        require(bytes(_ipfsAddresses).length == (CID_LENGTH * _bountySizes.length), ERROR_CID_LENGTH);

        for (uint i = 0; i < _bountySizes.length; i++) {
            ipfsHash = getHash(_ipfsAddresses, i);

            
            standardBountyId = _issueBounty(
                ipfsHash,
                _deadlines[i],
                _tokenContracts[i],
                _tokenTypes[i],
                _bountySizes[i]
            );

            
            _addBounty(
                _repoIds[i],
                _issueNumbers[i],
                standardBountyId,
                _tokenContracts[i],
                _bountySizes[i],
                ipfsHash
            );
        }
    }

    
    function addBountiesNoAssignment(
        bytes32[] _repoIds,
        uint256[] _issueNumbers,
        uint256[] _bountySizes,
        uint256[] _deadlines,
        uint256[] _tokenTypes,
        address[] _tokenContracts,
        string _ipfsAddresses,
        string _description
    ) public payable auth(FUND_OPEN_ISSUES_ROLE)
    {
        string memory ipfsHash;
        uint standardBountyId;

        for (uint i = 0; i < _bountySizes.length; i++) {
            ipfsHash = getHash(_ipfsAddresses, i);

            
            standardBountyId = _issueBounty(
                ipfsHash,
                _deadlines[i],
                _tokenContracts[i],
                _tokenTypes[i],
                _bountySizes[i]
            );

            
            _addBounty(
                _repoIds[i],
                _issueNumbers[i],
                standardBountyId,
                _tokenContracts[i],
                _bountySizes[i],
                ipfsHash
            );

            repos[_repoIds[i]].issues[_issueNumbers[i]].assignee = address(-1);
            emit AwaitingSubmissions(_repoIds[i], _issueNumbers[i]);
        }

    }

    
    function curateIssues(
        address[] ,
        uint256[] issuePriorities,
        uint256[] issueDescriptionIndices,
        string ,
        string _description,
        uint256[] issueRepos,
        uint256[] issueNumbers,
        uint256 
    ) public auth(CURATE_ISSUES_ROLE)
    {
        bytes32 repoId;
        uint256 issueLength = issuePriorities.length;
        require(issueLength == issueDescriptionIndices.length, "LENGTH_MISMATCH: issuePriorites and issueDescriptionIdx");
        require(issueLength == issueRepos.length, "LENGTH_MISMATCH: issuePriorites and issueRepos");
        require(issueLength == issueNumbers.length, "LENGTH_MISMATCH: issuePriorites and issueNumbers");

        for (uint256 i = 0; i < issueLength; i++) {
            repoId = bytes32(issueRepos[i]);
            repos[repoId].issues[uint256(issueNumbers[i])].priority = issuePriorities[i];
            emit IssueCurated(repoId);
        }
    }





    
    function isRepoAdded(bytes32 _repoId) public view isInitialized returns(bool isAdded) {
        uint256 repoIdxVal = repos[_repoId].index;
        if (repoIndexLength == 0)
            return false;
        if (repoIdxVal >= repoIndexLength)
            return false;
        return (repoIndex[repos[_repoId].index] == _repoId);
    }





    
    function _isBountiesContractValid(address _bountyRegistry) internal view returns(bool) {
        if (_bountyRegistry == address(0)) {
            return false;
        }
        if (_bountyRegistry == address(bountiesRegistry)) {
            return true;
        }
        uint256 size;
        
        assembly { size := extcodesize(_bountyRegistry) }
        if (size != 23406) {
            return false;
        }
        uint256 segments = 4;
        uint256 segmentLength = size / segments;
        bytes memory registryCode = new bytes(segmentLength);
        bytes32[4] memory validRegistryHashes = [
            bytes32(0x9904de0ff2a8144b30f80f0de9184731b7c39116b1f021bad12dcbb740f8371d),
            bytes32(0xd2319fa5b8b5614a3634c84ff340d27fa6e5921162e44bc2256f379ad86608f3),
            bytes32(0x0fd4c8d32b2c21b41989666a6d19f7a5f4987ae6d915dd96698de62db8a79643),
            bytes32(0x6af9efdc22f9352086c68a7b5c270db4f0fdc2b5ab18984a2d17b92ae327e144)
        ];
        for (uint256 i = 0; i < segments; i++) {
            
            assembly{ extcodecopy(_bountyRegistry,add(0x20,registryCode),div(mul(i,segmentLength),segments),segmentLength) }
            if (validRegistryHashes[i] != keccak256(registryCode)) {
                return false;
            }
        }

        return true;
    }

    
    function _changeBountySettings(
        uint256 _baseRate,
        uint256 _bountyDeadline,
        address _bountyCurrency,
        address _bountyAllocator
    ) internal
    {
        settings.baseRate = _baseRate;
        settings.bountyDeadline = _bountyDeadline;
        settings.bountyCurrency = _bountyCurrency;
        bountiesRegistry = Bounties(_bountyAllocator);

        emit BountySettingsChanged();
    }

    
    function _addExperienceLevel(
        uint _multiplier,
        bytes32 _description
    ) internal
    {
        settings.expMultipliers.push(_multiplier);
        settings.expLevels.push(_description);
    }

    
    function _issueBounty(
        string _ipfsHash,
        uint256 _deadline,
        address _tokenContract,
        uint256 _tokenType,
        uint256 _bountySize
    ) internal returns (uint256 bountyId)
    {
        require(_tokenType != 721, ERROR_NO_ERC721);
        uint256 registryTokenType;
        if (_tokenType == 0) {
            require(_tokenContract == ETH, ERROR_ETH_CONTRACT);
            registryTokenType = _tokenType;
        } else if (_tokenType == 1) {
            require(_tokenContract == ETH, ERROR_ETH_CONTRACT);
            registryTokenType = 0;
        } else {
            registryTokenType = _tokenType;
        }

        address[] memory issuers = new address[](1);
        issuers[0] = address(this);

        if (_tokenType > 0) {
            vault.transfer(_tokenContract, this, _bountySize);
            if (registryTokenType != 0) {
                require(ERC20Token(_tokenContract).approve(bountiesRegistry, _bountySize), "ERROR_ERC20_TRANSFER");
            }
        }

        if (registryTokenType == 0) {
            bountyId = bountiesRegistry.issueAndContribute.value(_bountySize)(
                address(this),      
                issuers,            
                issuers,            
                _ipfsHash,          
                _deadline,          
                _tokenContract,     
                registryTokenType,   
                _bountySize
            );
        } else {
            bountyId = bountiesRegistry.issueAndContribute(
                address(this),      
                issuers,            
                issuers,            
                _ipfsHash,          
                _deadline,          
                _tokenContract,     
                registryTokenType,   
                _bountySize
            );
        }
    }

    
    function _addBounty(
        bytes32 _repoId,
        uint256 _issueNumber,
        uint _standardBountyId,
        address _tokenContract,
        uint256 _bountySize,
        string _ipfsHash
    ) internal
    {
        address[] memory emptyAddressArray = new address[](0);
        uint256[] memory emptySubmissionIndexArray = new uint256[](0);
        
        require(isRepoAdded(_repoId), ERROR_REPO_MISSING);
        require(!repos[_repoId].issues[_issueNumber].hasBounty, ERROR_ISSUE_ACTIVE);

        repos[_repoId].issues[_issueNumber] = Issue(
            _repoId,
            _issueNumber,
            true,
            false,
            _tokenContract,
            _bountySize,
            999,
            ETH,
            _standardBountyId,
            ETH,
            emptyAddressArray,
            
            
            emptySubmissionIndexArray
        );
        openBounties[_repoId] = openBounties[_repoId].add(1);
        emit BountyAdded(
            _repoId,
            _issueNumber,
            _bountySize,
            _standardBountyId,
            _ipfsHash
        );
    }

    
    function _removeBounty(
        bytes32 _repoId,
        uint256 _issueNumber
    ) internal
    {
        Issue storage issue = repos[_repoId].issues[_issueNumber];
        require(issue.hasBounty, ERROR_BOUNTY_REMOVED);
        require(!issue.fulfilled, ERROR_BOUNTY_FULFILLED);
        issue.hasBounty = false;
        uint256[] memory originalAmount = new uint256[](1);
        originalAmount[0] = issue.bountySize;
        bountiesRegistry.drainBounty(
            address(this),
            issue.standardBountyId,
            0,
            originalAmount
        );
        _returnValueToVault(originalAmount[0], issue.tokenContract);
        issue.bountySize = 0;
        bountiesRegistry.changeDeadline(
            address(this),
            issue.standardBountyId,
            0,
            getTimestamp()
        );
        openBounties[_repoId] = openBounties[_repoId].sub(1);
        emit BountyRemoved(
            _repoId,
            _issueNumber,
            originalAmount[0]
        );
    }

    function _returnValueToVault(uint256 _amount, address _token) internal {
        if (_token == ETH)
            vault.deposit.value(_amount)(_token, _amount);
        else {
            require(ERC20Token(_token).approve(vault, _amount), "ERROR_ERC20__APPROVAL");
            vault.deposit(_token, _amount);
        }
    }

    
    function getHash(
        string _str,
        uint256 _hashIndex
    ) internal pure returns (string)
    {
        
        
        uint256 startIndex = _hashIndex * CID_LENGTH;
        uint256 endIndex = startIndex + CID_LENGTH;
        bytes memory strBytes = bytes(_str);
        bytes memory result = new bytes(endIndex-startIndex);
        uint256 length = endIndex - startIndex;
        
        uint256 dest;
        
        uint256 src;
        
        
        
        
        assembly {
            dest := add(result,0x20)
            src := add(strBytes,add(0x20,startIndex))
            mstore(dest, mload(src))
        }
        
        
        src += 32;
        dest += 32;
        length -= 32;
        uint mask = 256 ** (32 - length) - 1;
        
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }

        return string(result);
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





pragma solidity 0.4.24;







contract Rewards is AragonApp {

    using SafeMath for uint256;
    using SafeMath64 for uint64;
    
    bytes32 public constant ADD_REWARD_ROLE = 0x7941efc179bdce37ebd8db3e2deb46ce5280bf6d2de2e50938a9e920494c1941;

    
    uint8 internal constant MAX_OCCURRENCES = uint8(42);

    
    string private constant ERROR_VAULT = "VAULT_NOT_A_CONTRACT";
    string private constant ERROR_REWARD_TIME_SPAN = "REWARD_CLAIMED_BEFORE_DURATION_AND_DELAY";
    string private constant ERROR_VAULT_FUNDS = "VAULT_NOT_ENOUGH_FUNDS_TO_COVER_REWARD";
    string private constant ERROR_REFERENCE_TOKEN = "REFERENCE_TOKEN_NOT_A_CONTRACT";
    string private constant ERROR_REWARD_TOKEN = "REWARD_TOKEN_NOT_ETH_OR_CONTRACT";
    string private constant ERROR_MERIT_OCCURRENCES = "MERIT_REWARD_MUST_ONLY_OCCUR_ONCE";
    string private constant ERROR_MAX_OCCURRENCES = "OCURRENCES_LIMIT_REACHED";
    string private constant ERROR_START_BLOCK = "START_PERIOD_BEFORE_TOKEN_CREATION";
    string private constant ERROR_REWARD_CLAIMED = "REWARD_ALREADY_CLAIMED";
    string private constant ERROR_ZERO_DURATION = "DURATION_MUST_BE_AT_LEAST_ONE_BLOCK";
    string private constant ERROR_ZERO_OCCURRENCE = "OCCURRENCES_LESS_THAN_ONE";
    string private constant ERROR_ZERO_REWARD = "NO_REWARD_TO_CLAIM";
    string private constant ERROR_EXISTS = "REWARD_DOES_NOT_EXIST";
    string private constant ERROR_NONTRANSFERRABLE = "MINIME_CANNOT_TRANSFER";

    
    struct Reward {
        MiniMeToken referenceToken;
        bool isMerit;
        uint64 blockStart;
        uint64 duration;
        uint64 delay;
        uint256 amount;
        address creator;
        address rewardToken;
        string description;
        mapping (address => uint) timeClaimed;
    }

    
    mapping (address => uint) internal totalAmountClaimed;
    uint256 public totalClaimsEach;

    
    mapping(uint256 => Reward) rewards;
    uint256 rewardsRegistryLength;
    
    Vault public vault;

    
    event RewardAdded(uint256 rewardId); 
    event RewardClaimed(uint256 rewardId, address claimant);

    
    function initialize(Vault _vault) external onlyInit {
        require(isContract(_vault), ERROR_VAULT);
        vault = _vault;
        initialized();
    }

    
    function claimReward(uint256 _rewardID) external isInitialized returns (uint256) {
        Reward storage reward = rewards[_rewardID];
        require(reward.blockStart > 0, ERROR_EXISTS);
        uint256 rewardTimeSpan = reward.blockStart.add(reward.duration).add(reward.delay);
        require(rewardTimeSpan < getBlockNumber(), ERROR_REWARD_TIME_SPAN);

        require(reward.timeClaimed[msg.sender] == 0, ERROR_REWARD_CLAIMED);
        reward.timeClaimed[msg.sender] = getTimestamp();

        uint256 rewardAmount = _calculateRewardAmount(reward);
        require(rewardAmount > 0, ERROR_ZERO_REWARD);
        require(vault.balance(reward.rewardToken) >= rewardAmount, ERROR_VAULT_FUNDS);

        _transferReward(reward, rewardAmount);

        emit RewardClaimed(_rewardID, msg.sender);
        return rewardAmount;
    }

    
    function getRewardsLength() external view isInitialized returns (uint256 rewardsLength) {
        rewardsLength = rewardsRegistryLength;
    }

    
    function getReward(uint256 rewardID) external view isInitialized returns (
        string description,
        bool isMerit,
        address referenceToken,
        address rewardToken,
        uint256 amount,
        uint256 startBlock,
        uint256 endBlock,
        uint256 duration,
        uint256 delay,
        uint256 rewardAmount,
        uint256 timeClaimed,
        address creator
    )
    {
        Reward storage reward = rewards[rewardID];
        description = reward.description;
        isMerit = reward.isMerit;
        referenceToken = reward.referenceToken;
        rewardToken = reward.rewardToken;
        amount = reward.amount;
        endBlock = reward.blockStart + reward.duration;
        startBlock = reward.blockStart;
        duration = reward.duration;
        delay = reward.delay;
        timeClaimed = reward.timeClaimed[msg.sender];
        creator = reward.creator;
        rewardAmount = _calculateRewardAmount(reward);
    }

    
    function getTotalAmountClaimed(address _token)
    external view isInitialized returns (uint256)
    {
        return totalAmountClaimed[_token];
    }

    
    function newReward(
        string _description,
        bool _isMerit,
        MiniMeToken _referenceToken,
        address _rewardToken,
        uint256 _amount,
        uint64 _startBlock,
        uint64 _duration,
        uint8 _occurrences,
        uint64 _delay
    ) public auth(ADD_REWARD_ROLE) returns (uint256 rewardId)
    {
        require(isContract(_referenceToken), ERROR_REFERENCE_TOKEN);
        require(_rewardToken == address(0) || isContract(_rewardToken), ERROR_REWARD_TOKEN);
        require(_duration > 0, ERROR_ZERO_DURATION);
        require(_occurrences > 0, ERROR_ZERO_OCCURRENCE);
        require(!_isMerit || _occurrences == 1, ERROR_MERIT_OCCURRENCES);
        require(_occurrences < MAX_OCCURRENCES, ERROR_MAX_OCCURRENCES);
        require(_startBlock > _referenceToken.creationBlock(), ERROR_START_BLOCK);
        if (_isMerit) {
            require(!_referenceToken.transfersEnabled(), ERROR_NONTRANSFERRABLE);
        }
        rewardId = rewardsRegistryLength++; 
        Reward storage reward = rewards[rewardsRegistryLength - 1]; 
        reward.description = _description;
        reward.isMerit = _isMerit;
        reward.referenceToken = _referenceToken;
        reward.rewardToken = _rewardToken;
        reward.amount = _amount;
        reward.duration = _duration;
        reward.delay = _delay;
        reward.blockStart = _startBlock;
        reward.creator = msg.sender;
        emit RewardAdded(rewardId);
        if (_occurrences > 1) {
            newReward(
                _description,
                _isMerit,
                _referenceToken,
                _rewardToken,
                _amount,
                _startBlock + _duration,
                _duration,
                _occurrences - 1,
                _delay
            );
        }
    }

    
    function _transferReward(Reward storage reward, uint256 rewardAmount) private {
        totalClaimsEach++;
        totalAmountClaimed[reward.rewardToken] = totalAmountClaimed[reward.rewardToken].add(rewardAmount);
        vault.transfer(reward.rewardToken, msg.sender, rewardAmount);
    }

    
    function _calculateRewardAmount(Reward storage reward) private view returns (uint256 rewardAmount) {
        uint256 balance;
        uint256 supply;
        balance = reward.referenceToken.balanceOfAt(msg.sender, reward.blockStart + reward.duration);
        supply = reward.referenceToken.totalSupplyAt(reward.blockStart + reward.duration);
        if (reward.isMerit) {
            
            
            uint256 originalBalance = balance;
            uint256 originalSupply = supply;
            balance -= reward.referenceToken.balanceOfAt(msg.sender, reward.blockStart);
            supply -= reward.referenceToken.totalSupplyAt(reward.blockStart);
            if (originalBalance <= balance || originalSupply < supply) {
                return 0;
            }
        }
        rewardAmount = supply == 0 ? 0 : reward.amount.mul(balance).div(supply);
    }
}



pragma solidity 0.4.24;






contract ERC1271 {
    bytes4 constant public ERC1271_INTERFACE_ID = 0xfb855dc9; 

    bytes4 constant public ERC1271_RETURN_VALID_SIGNATURE =   0x20c13b0b; 
    bytes4 constant public ERC1271_RETURN_INVALID_SIGNATURE = 0x00000000;

    
    function isValidSignature(bytes32 _hash, bytes memory _signature) public view returns (bytes4);

    function returnIsValidSignatureMagicNumber(bool isValid) internal pure returns (bytes4) {
        return isValid ? ERC1271_RETURN_VALID_SIGNATURE : ERC1271_RETURN_INVALID_SIGNATURE;
    }
}


contract ERC1271Bytes is ERC1271 {
    
    function isValidSignature(bytes _data, bytes _signature) public view returns (bytes4) {
        return isValidSignature(keccak256(_data), _signature);
    }
}



pragma solidity 0.4.24;






library SignatureValidator {
    enum SignatureMode {
        Invalid, 
        EIP712,  
        EthSign, 
        ERC1271, 
        NMode    
    }

    
    bytes4 public constant ERC1271_RETURN_VALID_SIGNATURE = 0x20c13b0b;
    uint256 internal constant ERC1271_ISVALIDSIG_MAX_GAS = 250000;

    string private constant ERROR_INVALID_LENGTH_POP_BYTE = "SIGVAL_INVALID_LENGTH_POP_BYTE";

    
    
    
    
    
    function isValidSignature(bytes32 hash, address signer, bytes signature) internal view returns (bool) {
        if (signature.length == 0) {
            return false;
        }

        uint8 modeByte = uint8(signature[0]);
        if (modeByte >= uint8(SignatureMode.NMode)) {
            return false;
        }
        SignatureMode mode = SignatureMode(modeByte);

        if (mode == SignatureMode.EIP712) {
            return ecVerify(hash, signer, signature);
        } else if (mode == SignatureMode.EthSign) {
            return ecVerify(
                keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),
                signer,
                signature
            );
        } else if (mode == SignatureMode.ERC1271) {
            
            return safeIsValidSignature(signer, hash, popFirstByte(signature));
        } else {
            return false;
        }
    }

    function ecVerify(bytes32 hash, address signer, bytes memory signature) private pure returns (bool) {
        (bool badSig, bytes32 r, bytes32 s, uint8 v) = unpackEcSig(signature);

        if (badSig) {
            return false;
        }

        return signer == ecrecover(hash, v, r, s);
    }

    function unpackEcSig(bytes memory signature) private pure returns (bool badSig, bytes32 r, bytes32 s, uint8 v) {
        if (signature.length != 66) {
            badSig = true;
            return;
        }

        v = uint8(signature[65]);
        assembly {
            r := mload(add(signature, 33))
            s := mload(add(signature, 65))
        }

        
        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            badSig = true;
        }
    }

    function popFirstByte(bytes memory input) private pure returns (bytes memory output) {
        uint256 inputLength = input.length;
        require(inputLength > 0, ERROR_INVALID_LENGTH_POP_BYTE);

        output = new bytes(inputLength - 1);

        if (output.length == 0) {
            return output;
        }

        uint256 inputPointer;
        uint256 outputPointer;
        assembly {
            inputPointer := add(input, 0x21)
            outputPointer := add(output, 0x20)
        }
        memcpy(outputPointer, inputPointer, output.length);
    }

    function safeIsValidSignature(address validator, bytes32 hash, bytes memory signature) private view returns (bool) {
        bytes memory data = abi.encodeWithSelector(ERC1271(validator).isValidSignature.selector, hash, signature);
        bytes4 erc1271Return = safeBytes4StaticCall(validator, data, ERC1271_ISVALIDSIG_MAX_GAS);
        return erc1271Return == ERC1271_RETURN_VALID_SIGNATURE;
    }

    function safeBytes4StaticCall(address target, bytes data, uint256 maxGas) private view returns (bytes4 ret) {
        uint256 gasLeft = gasleft();

        uint256 callGas = gasLeft > maxGas ? maxGas : gasLeft;
        bool ok;
        assembly {
            ok := staticcall(callGas, target, add(data, 0x20), mload(data), 0, 0)
        }

        if (!ok) {
            return;
        }

        uint256 size;
        assembly { size := returndatasize }
        if (size != 32) {
            return;
        }

        assembly {
            let ptr := mload(0x40)       
            returndatacopy(ptr, 0, size) 
            ret := mload(ptr)            
        }

        return ret;
    }

    
    function memcpy(uint256 dest, uint256 src, uint256 len) private pure {
        
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



pragma solidity 0.4.24;


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external pure returns (bool);
}





pragma solidity 0.4.24;







contract Agent is IERC165, ERC1271Bytes, IForwarder, IsContract, Vault {
    

    bytes32 public constant EXECUTE_ROLE = 0xcebf517aa4440d1d125e0355aae64401211d0848a23c02cc5d29a14822580ba4;
    bytes32 public constant SAFE_EXECUTE_ROLE = 0x0a1ad7b87f5846153c6d5a1f761d71c7d0cfd122384f56066cd33239b7933694;
    bytes32 public constant ADD_PROTECTED_TOKEN_ROLE = 0x6eb2a499556bfa2872f5aa15812b956cc4a71b4d64eb3553f7073c7e41415aaa;
    bytes32 public constant REMOVE_PROTECTED_TOKEN_ROLE = 0x71eee93d500f6f065e38b27d242a756466a00a52a1dbcd6b4260f01a8640402a;
    bytes32 public constant ADD_PRESIGNED_HASH_ROLE = 0x0b29780bb523a130b3b01f231ef49ed2fa2781645591a0b0a44ca98f15a5994c;
    bytes32 public constant DESIGNATE_SIGNER_ROLE = 0x23ce341656c3f14df6692eebd4757791e33662b7dcf9970c8308303da5472b7c;
    bytes32 public constant RUN_SCRIPT_ROLE = 0xb421f7ad7646747f3051c50c0b8e2377839296cd4973e27f63821d73e390338f;

    uint256 public constant PROTECTED_TOKENS_CAP = 10;

    bytes4 private constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    string private constant ERROR_TARGET_PROTECTED = "AGENT_TARGET_PROTECTED";
    string private constant ERROR_PROTECTED_TOKENS_MODIFIED = "AGENT_PROTECTED_TOKENS_MODIFIED";
    string private constant ERROR_PROTECTED_BALANCE_LOWERED = "AGENT_PROTECTED_BALANCE_LOWERED";
    string private constant ERROR_TOKENS_CAP_REACHED = "AGENT_TOKENS_CAP_REACHED";
    string private constant ERROR_TOKEN_NOT_ERC20 = "AGENT_TOKEN_NOT_ERC20";
    string private constant ERROR_TOKEN_ALREADY_PROTECTED = "AGENT_TOKEN_ALREADY_PROTECTED";
    string private constant ERROR_TOKEN_NOT_PROTECTED = "AGENT_TOKEN_NOT_PROTECTED";
    string private constant ERROR_DESIGNATED_TO_SELF = "AGENT_DESIGNATED_TO_SELF";
    string private constant ERROR_CAN_NOT_FORWARD = "AGENT_CAN_NOT_FORWARD";

    mapping (bytes32 => bool) public isPresigned;
    address public designatedSigner;
    address[] public protectedTokens;

    event SafeExecute(address indexed sender, address indexed target, bytes data);
    event Execute(address indexed sender, address indexed target, uint256 ethValue, bytes data);
    event AddProtectedToken(address indexed token);
    event RemoveProtectedToken(address indexed token);
    event PresignHash(address indexed sender, bytes32 indexed hash);
    event SetDesignatedSigner(address indexed sender, address indexed oldSigner, address indexed newSigner);

    
    function execute(address _target, uint256 _ethValue, bytes _data)
        external 
        authP(EXECUTE_ROLE, arr(_target, _ethValue, uint256(_getSig(_data)))) 
    {
        bool result = _target.call.value(_ethValue)(_data);

        if (result) {
            emit Execute(msg.sender, _target, _ethValue, _data);
        }

        assembly {
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, returndatasize)

            
            
            switch result case 0 { revert(ptr, returndatasize) }
            default { return(ptr, returndatasize) }
        }
    }

    
    function safeExecute(address _target, bytes _data)
        external 
        authP(SAFE_EXECUTE_ROLE, arr(_target, uint256(_getSig(_data)))) 
    {
        uint256 protectedTokensLength = protectedTokens.length;
        address[] memory protectedTokens_ = new address[](protectedTokensLength);
        uint256[] memory balances = new uint256[](protectedTokensLength);

        for (uint256 i = 0; i < protectedTokensLength; i++) {
            address token = protectedTokens[i];
            require(_target != token, ERROR_TARGET_PROTECTED);
            
            protectedTokens_[i] = token;
            
            balances[i] = balance(token);
        }

        bool result = _target.call(_data);

        bytes32 ptr;
        uint256 size;
        assembly {
            size := returndatasize
            ptr := mload(0x40)
            mstore(0x40, add(ptr, returndatasize))
            returndatacopy(ptr, 0, returndatasize)
        }

        if (result) {
            
            
            require(protectedTokens.length == protectedTokensLength, ERROR_PROTECTED_TOKENS_MODIFIED);
            for (uint256 j = 0; j < protectedTokensLength; j++) {
                require(protectedTokens[j] == protectedTokens_[j], ERROR_PROTECTED_TOKENS_MODIFIED);
                require(balance(protectedTokens[j]) >= balances[j], ERROR_PROTECTED_BALANCE_LOWERED);
            }

            emit SafeExecute(msg.sender, _target, _data);

            assembly {
                return(ptr, size)
            }
        } else {
            
            assembly {
                revert(ptr, size)
            }
        }
    }

    
    function addProtectedToken(address _token) external authP(ADD_PROTECTED_TOKEN_ROLE, arr(_token)) {
        require(protectedTokens.length < PROTECTED_TOKENS_CAP, ERROR_TOKENS_CAP_REACHED);
        require(_isERC20(_token), ERROR_TOKEN_NOT_ERC20);
        require(!_tokenIsProtected(_token), ERROR_TOKEN_ALREADY_PROTECTED);

        _addProtectedToken(_token);
    }

    
    function removeProtectedToken(address _token) external authP(REMOVE_PROTECTED_TOKEN_ROLE, arr(_token)) {
        require(_tokenIsProtected(_token), ERROR_TOKEN_NOT_PROTECTED);

        _removeProtectedToken(_token);
    }

    
    function presignHash(bytes32 _hash)
        external
        authP(ADD_PRESIGNED_HASH_ROLE, arr(_hash))
    {
        isPresigned[_hash] = true;

        emit PresignHash(msg.sender, _hash);
    }

    
    function setDesignatedSigner(address _designatedSigner)
        external
        authP(DESIGNATE_SIGNER_ROLE, arr(_designatedSigner))
    {
        
        
        
        
        
        require(_designatedSigner != address(this), ERROR_DESIGNATED_TO_SELF);

        address oldDesignatedSigner = designatedSigner;
        designatedSigner = _designatedSigner;

        emit SetDesignatedSigner(msg.sender, oldDesignatedSigner, _designatedSigner);
    }

    

    
    function isForwarder() external pure returns (bool) {
        return true;
    }

    
    function forward(bytes _evmScript) public {
        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);

        bytes memory input = ""; // no input
        address[] memory blacklist = new address[](0); // no addr blacklist, can interact with anything
        runScript(_evmScript, input, blacklist);
        // We don't need to emit an event here as EVMScriptRunner will emit ScriptResult if successful
    }

    /**
    * @notice Tells whether `_sender` can forward actions or not
    * @dev IForwarder interface conformance
    * @param _sender Address of the account intending to forward an action
    * @return True if the given address can run scripts, false otherwise
    */
    function canForward(address _sender, bytes _evmScript) public view returns (bool) {
        // Note that `canPerform()` implicitly does an initialization check itself
        return canPerform(_sender, RUN_SCRIPT_ROLE, arr(_getScriptACLParam(_evmScript)));
    }

    // ERC-165 conformance

    /**
     * @notice Tells whether this contract supports a given ERC-165 interface
     * @param _interfaceId Interface bytes to check
     * @return True if this contract supports the interface
     */
    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        return
            _interfaceId == ERC1271_INTERFACE_ID ||
            _interfaceId == ERC165_INTERFACE_ID;
    }

    // ERC-1271 conformance

    /**
     * @notice Tells whether a signature is seen as valid by this contract through ERC-1271
     * @param _hash Arbitrary length data signed on the behalf of address (this)
     * @param _signature Signature byte array associated with _data
     * @return The ERC-1271 magic value if the signature is valid
     */
    function isValidSignature(bytes32 _hash, bytes _signature) public view returns (bytes4) {
        // Short-circuit in case the hash was presigned. Optimization as performing calls
        // and ecrecover is more expensive than an SLOAD.
        if (isPresigned[_hash]) {
            return returnIsValidSignatureMagicNumber(true);
        }

        bool isValid;
        if (designatedSigner == address(0)) {
            isValid = false;
        } else {
            isValid = SignatureValidator.isValidSignature(_hash, designatedSigner, _signature);
        }

        return returnIsValidSignatureMagicNumber(isValid);
    }

    // Getters

    function getProtectedTokensLength() public view isInitialized returns (uint256) {
        return protectedTokens.length;
    }

    // Internal fns

    function _addProtectedToken(address _token) internal {
        protectedTokens.push(_token);

        emit AddProtectedToken(_token);
    }

    function _removeProtectedToken(address _token) internal {
        protectedTokens[_protectedTokenIndex(_token)] = protectedTokens[protectedTokens.length - 1];
        protectedTokens.length--;

        emit RemoveProtectedToken(_token);
    }

    function _isERC20(address _token) internal view returns (bool) {
        if (!isContract(_token)) {
            return false;
        }

        // Throwaway sanity check to make sure the token's `balanceOf()` does not error (for now)
        balance(_token);

        return true;
    }

    function _protectedTokenIndex(address _token) internal view returns (uint256) {
        for (uint i = 0; i < protectedTokens.length; i++) {
            if (protectedTokens[i] == _token) {
              return i;
            }
        }

        revert(ERROR_TOKEN_NOT_PROTECTED);
    }

    function _tokenIsProtected(address _token) internal view returns (bool) {
        for (uint256 i = 0; i < protectedTokens.length; i++) {
            if (protectedTokens[i] == _token) {
                return true;
            }
        }

        return false;
    }

    function _getScriptACLParam(bytes _evmScript) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_evmScript)));
    }

    function _getSig(bytes _data) internal pure returns (bytes4 sig) {
        if (_data.length < 4) {
            return;
        }

        assembly { sig := mload(add(_data, 0x20)) }
    }
}

// File: @aragon/apps-finance/contracts/Finance.sol

/*
 * SPDX-License-Identitifer:    GPL-3.0-or-later
 */

pragma solidity 0.4.24;










contract Finance is EtherTokenConstant, IsContract, AragonApp {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using SafeERC20 for ERC20;

    bytes32 public constant CREATE_PAYMENTS_ROLE = keccak256("CREATE_PAYMENTS_ROLE");
    bytes32 public constant CHANGE_PERIOD_ROLE = keccak256("CHANGE_PERIOD_ROLE");
    bytes32 public constant CHANGE_BUDGETS_ROLE = keccak256("CHANGE_BUDGETS_ROLE");
    bytes32 public constant EXECUTE_PAYMENTS_ROLE = keccak256("EXECUTE_PAYMENTS_ROLE");
    bytes32 public constant MANAGE_PAYMENTS_ROLE = keccak256("MANAGE_PAYMENTS_ROLE");

    uint256 internal constant NO_SCHEDULED_PAYMENT = 0;
    uint256 internal constant NO_TRANSACTION = 0;
    uint256 internal constant MAX_SCHEDULED_PAYMENTS_PER_TX = 20;
    uint256 internal constant MAX_UINT256 = uint256(-1);
    uint64 internal constant MAX_UINT64 = uint64(-1);
    uint64 internal constant MINIMUM_PERIOD = uint64(1 days);

    string private constant ERROR_COMPLETE_TRANSITION = "FINANCE_COMPLETE_TRANSITION";
    string private constant ERROR_NO_SCHEDULED_PAYMENT = "FINANCE_NO_SCHEDULED_PAYMENT";
    string private constant ERROR_NO_TRANSACTION = "FINANCE_NO_TRANSACTION";
    string private constant ERROR_NO_PERIOD = "FINANCE_NO_PERIOD";
    string private constant ERROR_VAULT_NOT_CONTRACT = "FINANCE_VAULT_NOT_CONTRACT";
    string private constant ERROR_SET_PERIOD_TOO_SHORT = "FINANCE_SET_PERIOD_TOO_SHORT";
    string private constant ERROR_NEW_PAYMENT_AMOUNT_ZERO = "FINANCE_NEW_PAYMENT_AMOUNT_ZERO";
    string private constant ERROR_NEW_PAYMENT_INTERVAL_ZERO = "FINANCE_NEW_PAYMENT_INTRVL_ZERO";
    string private constant ERROR_NEW_PAYMENT_EXECS_ZERO = "FINANCE_NEW_PAYMENT_EXECS_ZERO";
    string private constant ERROR_NEW_PAYMENT_IMMEDIATE = "FINANCE_NEW_PAYMENT_IMMEDIATE";
    string private constant ERROR_RECOVER_AMOUNT_ZERO = "FINANCE_RECOVER_AMOUNT_ZERO";
    string private constant ERROR_DEPOSIT_AMOUNT_ZERO = "FINANCE_DEPOSIT_AMOUNT_ZERO";
    string private constant ERROR_ETH_VALUE_MISMATCH = "FINANCE_ETH_VALUE_MISMATCH";
    string private constant ERROR_BUDGET = "FINANCE_BUDGET";
    string private constant ERROR_EXECUTE_PAYMENT_NUM = "FINANCE_EXECUTE_PAYMENT_NUM";
    string private constant ERROR_EXECUTE_PAYMENT_TIME = "FINANCE_EXECUTE_PAYMENT_TIME";
    string private constant ERROR_PAYMENT_RECEIVER = "FINANCE_PAYMENT_RECEIVER";
    string private constant ERROR_TOKEN_TRANSFER_FROM_REVERTED = "FINANCE_TKN_TRANSFER_FROM_REVERT";
    string private constant ERROR_TOKEN_APPROVE_FAILED = "FINANCE_TKN_APPROVE_FAILED";
    string private constant ERROR_PAYMENT_INACTIVE = "FINANCE_PAYMENT_INACTIVE";
    string private constant ERROR_REMAINING_BUDGET = "FINANCE_REMAINING_BUDGET";

    
    struct ScheduledPayment {
        address token;
        address receiver;
        address createdBy;
        bool inactive;
        uint256 amount;
        uint64 initialPaymentTime;
        uint64 interval;
        uint64 maxExecutions;
        uint64 executions;
    }

    
    struct Transaction {
        address token;
        address entity;
        bool isIncoming;
        uint256 amount;
        uint256 paymentId;
        uint64 paymentExecutionNumber;
        uint64 date;
        uint64 periodId;
    }

    struct TokenStatement {
        uint256 expenses;
        uint256 income;
    }

    struct Period {
        uint64 startTime;
        uint64 endTime;
        uint256 firstTransactionId;
        uint256 lastTransactionId;
        mapping (address => TokenStatement) tokenStatement;
    }

    struct Settings {
        uint64 periodDuration;
        mapping (address => uint256) budgets;
        mapping (address => bool) hasBudget;
    }

    Vault public vault;
    Settings internal settings;

    
    mapping (uint256 => ScheduledPayment) internal scheduledPayments;
    
    
    uint256 public paymentsNextIndex;

    mapping (uint256 => Transaction) internal transactions;
    uint256 public transactionsNextIndex;

    mapping (uint64 => Period) internal periods;
    uint64 public periodsLength;

    event NewPeriod(uint64 indexed periodId, uint64 periodStarts, uint64 periodEnds);
    event SetBudget(address indexed token, uint256 amount, bool hasBudget);
    event NewPayment(uint256 indexed paymentId, address indexed recipient, uint64 maxExecutions, string reference);
    event NewTransaction(uint256 indexed transactionId, bool incoming, address indexed entity, uint256 amount, string reference);
    event ChangePaymentState(uint256 indexed paymentId, bool active);
    event ChangePeriodDuration(uint64 newDuration);
    event PaymentFailure(uint256 paymentId);

    
    
    
    modifier transitionsPeriod {
        bool completeTransition = _tryTransitionAccountingPeriod(getMaxPeriodTransitions());
        require(completeTransition, ERROR_COMPLETE_TRANSITION);
        _;
    }

    modifier scheduledPaymentExists(uint256 _paymentId) {
        require(_paymentId > 0 && _paymentId < paymentsNextIndex, ERROR_NO_SCHEDULED_PAYMENT);
        _;
    }

    modifier transactionExists(uint256 _transactionId) {
        require(_transactionId > 0 && _transactionId < transactionsNextIndex, ERROR_NO_TRANSACTION);
        _;
    }

    modifier periodExists(uint64 _periodId) {
        require(_periodId < periodsLength, ERROR_NO_PERIOD);
        _;
    }

    
    function () external payable isInitialized transitionsPeriod {
        require(msg.value > 0, ERROR_DEPOSIT_AMOUNT_ZERO);
        _deposit(
            ETH,
            msg.value,
            "Ether transfer to Finance app",
            msg.sender,
            true
        );
    }

    
    function initialize(Vault _vault, uint64 _periodDuration) external onlyInit {
        initialized();

        require(isContract(_vault), ERROR_VAULT_NOT_CONTRACT);
        vault = _vault;

        require(_periodDuration >= MINIMUM_PERIOD, ERROR_SET_PERIOD_TOO_SHORT);
        settings.periodDuration = _periodDuration;

        
        
        scheduledPayments[0].inactive = true;
        paymentsNextIndex = 1;

        
        transactionsNextIndex = 1;

        
        _newPeriod(getTimestamp64());
    }

    
    function deposit(address _token, uint256 _amount, string _reference) external payable isInitialized transitionsPeriod {
        require(_amount > 0, ERROR_DEPOSIT_AMOUNT_ZERO);
        if (_token == ETH) {
            
            require(msg.value == _amount, ERROR_ETH_VALUE_MISMATCH);
        }

        _deposit(
            _token,
            _amount,
            _reference,
            msg.sender,
            true
        );
    }

    
    function newImmediatePayment(address _token, address _receiver, uint256 _amount, string _reference)
        external
        
        
        authP(CREATE_PAYMENTS_ROLE, _arr(_token, _receiver, _amount, MAX_UINT256, uint256(1), getTimestamp()))
        transitionsPeriod
    {
        require(_amount > 0, ERROR_NEW_PAYMENT_AMOUNT_ZERO);

        _makePaymentTransaction(
            _token,
            _receiver,
            _amount,
            NO_SCHEDULED_PAYMENT,   
            0,   
            _reference
        );
    }

    
    function newScheduledPayment(
        address _token,
        address _receiver,
        uint256 _amount,
        uint64 _initialPaymentTime,
        uint64 _interval,
        uint64 _maxExecutions,
        string _reference
    )
        external
        
        authP(CREATE_PAYMENTS_ROLE, _arr(_token, _receiver, _amount, uint256(_interval), uint256(_maxExecutions), uint256(_initialPaymentTime)))
        transitionsPeriod
        returns (uint256 paymentId)
    {
        require(_amount > 0, ERROR_NEW_PAYMENT_AMOUNT_ZERO);
        require(_interval > 0, ERROR_NEW_PAYMENT_INTERVAL_ZERO);
        require(_maxExecutions > 0, ERROR_NEW_PAYMENT_EXECS_ZERO);

        
        require(!settings.hasBudget[_token] || settings.budgets[_token] >= _amount, ERROR_BUDGET);

        
        if (_maxExecutions == 1) {
            require(_initialPaymentTime > getTimestamp64(), ERROR_NEW_PAYMENT_IMMEDIATE);
        }

        paymentId = paymentsNextIndex++;
        emit NewPayment(paymentId, _receiver, _maxExecutions, _reference);

        ScheduledPayment storage payment = scheduledPayments[paymentId];
        payment.token = _token;
        payment.receiver = _receiver;
        payment.amount = _amount;
        payment.initialPaymentTime = _initialPaymentTime;
        payment.interval = _interval;
        payment.maxExecutions = _maxExecutions;
        payment.createdBy = msg.sender;

        
        
        _executePayment(paymentId);
    }

    
    function setPeriodDuration(uint64 _periodDuration)
        external
        authP(CHANGE_PERIOD_ROLE, arr(uint256(_periodDuration), uint256(settings.periodDuration)))
        transitionsPeriod
    {
        require(_periodDuration >= MINIMUM_PERIOD, ERROR_SET_PERIOD_TOO_SHORT);
        settings.periodDuration = _periodDuration;
        emit ChangePeriodDuration(_periodDuration);
    }

    
    function setBudget(
        address _token,
        uint256 _amount
    )
        external
        authP(CHANGE_BUDGETS_ROLE, arr(_token, _amount, settings.budgets[_token], uint256(settings.hasBudget[_token] ? 1 : 0)))
        transitionsPeriod
    {
        settings.budgets[_token] = _amount;
        if (!settings.hasBudget[_token]) {
            settings.hasBudget[_token] = true;
        }
        emit SetBudget(_token, _amount, true);
    }

    
    function removeBudget(address _token)
        external
        authP(CHANGE_BUDGETS_ROLE, arr(_token, uint256(0), settings.budgets[_token], uint256(settings.hasBudget[_token] ? 1 : 0)))
        transitionsPeriod
    {
        settings.budgets[_token] = 0;
        settings.hasBudget[_token] = false;
        emit SetBudget(_token, 0, false);
    }

    
    function executePayment(uint256 _paymentId)
        external
        authP(EXECUTE_PAYMENTS_ROLE, arr(_paymentId, scheduledPayments[_paymentId].amount))
        scheduledPaymentExists(_paymentId)
        transitionsPeriod
    {
        _executePaymentAtLeastOnce(_paymentId);
    }

    
    function receiverExecutePayment(uint256 _paymentId) external scheduledPaymentExists(_paymentId) transitionsPeriod {
        require(scheduledPayments[_paymentId].receiver == msg.sender, ERROR_PAYMENT_RECEIVER);
        _executePaymentAtLeastOnce(_paymentId);
    }

    
    function setPaymentStatus(uint256 _paymentId, bool _active)
        external
        authP(MANAGE_PAYMENTS_ROLE, arr(_paymentId, uint256(_active ? 1 : 0)))
        scheduledPaymentExists(_paymentId)
    {
        scheduledPayments[_paymentId].inactive = !_active;
        emit ChangePaymentState(_paymentId, _active);
    }

    
    function recoverToVault(address _token) external isInitialized transitionsPeriod {
        uint256 amount = _token == ETH ? address(this).balance : ERC20(_token).staticBalanceOf(address(this));
        require(amount > 0, ERROR_RECOVER_AMOUNT_ZERO);

        _deposit(
            _token,
            amount,
            "Recover to Vault",
            address(this),
            false
        );
    }

    
    function tryTransitionAccountingPeriod(uint64 _maxTransitions) external isInitialized returns (bool success) {
        return _tryTransitionAccountingPeriod(_maxTransitions);
    }

    

    
    function allowRecoverability(address) public view returns (bool) {
        return !hasInitialized();
    }

    function getPayment(uint256 _paymentId)
        public
        view
        scheduledPaymentExists(_paymentId)
        returns (
            address token,
            address receiver,
            uint256 amount,
            uint64 initialPaymentTime,
            uint64 interval,
            uint64 maxExecutions,
            bool inactive,
            uint64 executions,
            address createdBy
        )
    {
        ScheduledPayment storage payment = scheduledPayments[_paymentId];

        token = payment.token;
        receiver = payment.receiver;
        amount = payment.amount;
        initialPaymentTime = payment.initialPaymentTime;
        interval = payment.interval;
        maxExecutions = payment.maxExecutions;
        executions = payment.executions;
        inactive = payment.inactive;
        createdBy = payment.createdBy;
    }

    function getTransaction(uint256 _transactionId)
        public
        view
        transactionExists(_transactionId)
        returns (
            uint64 periodId,
            uint256 amount,
            uint256 paymentId,
            uint64 paymentExecutionNumber,
            address token,
            address entity,
            bool isIncoming,
            uint64 date
        )
    {
        Transaction storage transaction = transactions[_transactionId];

        token = transaction.token;
        entity = transaction.entity;
        isIncoming = transaction.isIncoming;
        date = transaction.date;
        periodId = transaction.periodId;
        amount = transaction.amount;
        paymentId = transaction.paymentId;
        paymentExecutionNumber = transaction.paymentExecutionNumber;
    }

    function getPeriod(uint64 _periodId)
        public
        view
        periodExists(_periodId)
        returns (
            bool isCurrent,
            uint64 startTime,
            uint64 endTime,
            uint256 firstTransactionId,
            uint256 lastTransactionId
        )
    {
        Period storage period = periods[_periodId];

        isCurrent = _currentPeriodId() == _periodId;

        startTime = period.startTime;
        endTime = period.endTime;
        firstTransactionId = period.firstTransactionId;
        lastTransactionId = period.lastTransactionId;
    }

    function getPeriodTokenStatement(uint64 _periodId, address _token)
        public
        view
        periodExists(_periodId)
        returns (uint256 expenses, uint256 income)
    {
        TokenStatement storage tokenStatement = periods[_periodId].tokenStatement[_token];
        expenses = tokenStatement.expenses;
        income = tokenStatement.income;
    }

    
    function currentPeriodId() public view isInitialized returns (uint64) {
        return _currentPeriodId();
    }

    
    function getPeriodDuration() public view isInitialized returns (uint64) {
        return settings.periodDuration;
    }

    
    function getBudget(address _token) public view isInitialized returns (uint256 budget, bool hasBudget) {
        budget = settings.budgets[_token];
        hasBudget = settings.hasBudget[_token];
    }

    
    function getRemainingBudget(address _token) public view isInitialized returns (uint256) {
        return _getRemainingBudget(_token);
    }

    
    function canMakePayment(address _token, uint256 _amount) public view isInitialized returns (bool) {
        return _canMakePayment(_token, _amount);
    }

    
    function nextPaymentTime(uint256 _paymentId) public view scheduledPaymentExists(_paymentId) returns (uint64) {
        return _nextPaymentTime(_paymentId);
    }

    

    function _deposit(address _token, uint256 _amount, string _reference, address _sender, bool _isExternalDeposit) internal {
        _recordIncomingTransaction(
            _token,
            _sender,
            _amount,
            _reference
        );

        if (_token == ETH) {
            vault.deposit.value(_amount)(ETH, _amount);
        } else {
            
            
            
            if (_isExternalDeposit) {
                
                require(
                    ERC20(_token).safeTransferFrom(msg.sender, address(this), _amount),
                    ERROR_TOKEN_TRANSFER_FROM_REVERTED
                );
            }
            
            require(ERC20(_token).safeApprove(vault, _amount), ERROR_TOKEN_APPROVE_FAILED);
            
            vault.deposit(_token, _amount);
        }
    }

    function _executePayment(uint256 _paymentId) internal returns (uint256) {
        ScheduledPayment storage payment = scheduledPayments[_paymentId];
        require(!payment.inactive, ERROR_PAYMENT_INACTIVE);

        uint64 paid = 0;
        while (_nextPaymentTime(_paymentId) <= getTimestamp64() && paid < MAX_SCHEDULED_PAYMENTS_PER_TX) {
            if (!_canMakePayment(payment.token, payment.amount)) {
                emit PaymentFailure(_paymentId);
                break;
            }

            
            payment.executions += 1;
            paid += 1;

            
            _unsafeMakePaymentTransaction(
                payment.token,
                payment.receiver,
                payment.amount,
                _paymentId,
                payment.executions,
                ""
            );
        }

        return paid;
    }

    function _executePaymentAtLeastOnce(uint256 _paymentId) internal {
        uint256 paid = _executePayment(_paymentId);
        if (paid == 0) {
            if (_nextPaymentTime(_paymentId) <= getTimestamp64()) {
                revert(ERROR_EXECUTE_PAYMENT_NUM);
            } else {
                revert(ERROR_EXECUTE_PAYMENT_TIME);
            }
        }
    }

    function _makePaymentTransaction(
        address _token,
        address _receiver,
        uint256 _amount,
        uint256 _paymentId,
        uint64 _paymentExecutionNumber,
        string _reference
    )
        internal
    {
        require(_getRemainingBudget(_token) >= _amount, ERROR_REMAINING_BUDGET);
        _unsafeMakePaymentTransaction(_token, _receiver, _amount, _paymentId, _paymentExecutionNumber, _reference);
    }

    /**
    * @dev Unsafe version of _makePaymentTransaction that assumes you have already checked the
    *      remaining budget
    */
    function _unsafeMakePaymentTransaction(
        address _token,
        address _receiver,
        uint256 _amount,
        uint256 _paymentId,
        uint64 _paymentExecutionNumber,
        string _reference
    )
        internal
    {
        _recordTransaction(
            false,
            _token,
            _receiver,
            _amount,
            _paymentId,
            _paymentExecutionNumber,
            _reference
        );

        vault.transfer(_token, _receiver, _amount);
    }

    function _newPeriod(uint64 _startTime) internal returns (Period storage) {
        // There should be no way for this to overflow since each period is at least one day
        uint64 newPeriodId = periodsLength++;

        Period storage period = periods[newPeriodId];
        period.startTime = _startTime;

        // Be careful here to not overflow; if startTime + periodDuration overflows, we set endTime
        // to MAX_UINT64 (let's assume that's the end of time for now).
        uint64 endTime = _startTime + settings.periodDuration - 1;
        if (endTime < _startTime) { // overflowed
            endTime = MAX_UINT64;
        }
        period.endTime = endTime;

        emit NewPeriod(newPeriodId, period.startTime, period.endTime);

        return period;
    }

    function _recordIncomingTransaction(
        address _token,
        address _sender,
        uint256 _amount,
        string _reference
    )
        internal
    {
        _recordTransaction(
            true, // incoming transaction
            _token,
            _sender,
            _amount,
            NO_SCHEDULED_PAYMENT, // unrelated to any existing payment
            0, // and no payment executions
            _reference
        );
    }

    function _recordTransaction(
        bool _incoming,
        address _token,
        address _entity,
        uint256 _amount,
        uint256 _paymentId,
        uint64 _paymentExecutionNumber,
        string _reference
    )
        internal
    {
        uint64 periodId = _currentPeriodId();
        TokenStatement storage tokenStatement = periods[periodId].tokenStatement[_token];
        if (_incoming) {
            tokenStatement.income = tokenStatement.income.add(_amount);
        } else {
            tokenStatement.expenses = tokenStatement.expenses.add(_amount);
        }

        uint256 transactionId = transactionsNextIndex++;

        Transaction storage transaction = transactions[transactionId];
        transaction.token = _token;
        transaction.entity = _entity;
        transaction.isIncoming = _incoming;
        transaction.amount = _amount;
        transaction.paymentId = _paymentId;
        transaction.paymentExecutionNumber = _paymentExecutionNumber;
        transaction.date = getTimestamp64();
        transaction.periodId = periodId;

        Period storage period = periods[periodId];
        if (period.firstTransactionId == NO_TRANSACTION) {
            period.firstTransactionId = transactionId;
        }

        emit NewTransaction(transactionId, _incoming, _entity, _amount, _reference);
    }

    function _tryTransitionAccountingPeriod(uint64 _maxTransitions) internal returns (bool success) {
        Period storage currentPeriod = periods[_currentPeriodId()];
        uint64 timestamp = getTimestamp64();

        // Transition periods if necessary
        while (timestamp > currentPeriod.endTime) {
            if (_maxTransitions == 0) {
                // Required number of transitions is over allowed number, return false indicating
                // it didn't fully transition
                return false;
            }
            // We're already protected from underflowing above
            _maxTransitions -= 1;

            // If there were any transactions in period, record which was the last
            // In case 0 transactions occured, first and last tx id will be 0
            if (currentPeriod.firstTransactionId != NO_TRANSACTION) {
                currentPeriod.lastTransactionId = transactionsNextIndex.sub(1);
            }

            // New period starts at end time + 1
            currentPeriod = _newPeriod(currentPeriod.endTime.add(1));
        }

        return true;
    }

    function _canMakePayment(address _token, uint256 _amount) internal view returns (bool) {
        return _getRemainingBudget(_token) >= _amount && vault.balance(_token) >= _amount;
    }

    function _currentPeriodId() internal view returns (uint64) {
        // There is no way for this to overflow if protected by an initialization check
        return periodsLength - 1;
    }

    function _getRemainingBudget(address _token) internal view returns (uint256) {
        if (!settings.hasBudget[_token]) {
            return MAX_UINT256;
        }

        uint256 budget = settings.budgets[_token];
        uint256 spent = periods[_currentPeriodId()].tokenStatement[_token].expenses;

        // A budget decrease can cause the spent amount to be greater than period budget
        // If so, return 0 to not allow more spending during period
        if (spent >= budget) {
            return 0;
        }

        // We're already protected from the overflow above
        return budget - spent;
    }

    function _nextPaymentTime(uint256 _paymentId) internal view returns (uint64) {
        ScheduledPayment storage payment = scheduledPayments[_paymentId];

        if (payment.executions >= payment.maxExecutions) {
            return MAX_UINT64; // re-executes in some billions of years time... should not need to worry
        }

        // Split in multiple lines to circumvent linter warning
        uint64 increase = payment.executions.mul(payment.interval);
        uint64 nextPayment = payment.initialPaymentTime.add(increase);
        return nextPayment;
    }

    // Syntax sugar

    function _arr(address _a, address _b, uint256 _c, uint256 _d, uint256 _e, uint256 _f) internal pure returns (uint256[] r) {
        r = new uint256[](6);
        r[0] = uint256(_a);
        r[1] = uint256(_b);
        r[2] = _c;
        r[3] = _d;
        r[4] = _e;
        r[5] = _f;
    }

    // Mocked fns (overrided during testing)
    // Must be view for mocking purposes

    function getMaxPeriodTransitions() internal view returns (uint64) { return MAX_UINT64; }
}

// File: @aragon/ppf-contracts/contracts/IFeed.sol

pragma solidity ^0.4.18;

interface IFeed {
    function ratePrecision() external pure returns (uint256);
    function get(address base, address quote) external view returns (uint128 xrt, uint64 when);
}

// File: @aragon/apps-payroll/contracts/Payroll.sol

pragma solidity 0.4.24;










/**
 * @title Payroll in multiple currencies
 */
contract Payroll is EtherTokenConstant, IForwarder, IsContract, AragonApp {
    using SafeMath for uint256;
    using SafeMath64 for uint64;

    /* Hardcoded constants to save gas
    * bytes32 constant public ADD_EMPLOYEE_ROLE = keccak256("ADD_EMPLOYEE_ROLE");
    * bytes32 constant public TERMINATE_EMPLOYEE_ROLE = keccak256("TERMINATE_EMPLOYEE_ROLE");
    * bytes32 constant public SET_EMPLOYEE_SALARY_ROLE = keccak256("SET_EMPLOYEE_SALARY_ROLE");
    * bytes32 constant public ADD_BONUS_ROLE = keccak256("ADD_BONUS_ROLE");
    * bytes32 constant public ADD_REIMBURSEMENT_ROLE = keccak256("ADD_REIMBURSEMENT_ROLE");
    * bytes32 constant public MANAGE_ALLOWED_TOKENS_ROLE = keccak256("MANAGE_ALLOWED_TOKENS_ROLE");
    * bytes32 constant public MODIFY_PRICE_FEED_ROLE = keccak256("MODIFY_PRICE_FEED_ROLE");
    * bytes32 constant public MODIFY_RATE_EXPIRY_ROLE = keccak256("MODIFY_RATE_EXPIRY_ROLE");
    */

    bytes32 constant public ADD_EMPLOYEE_ROLE = 0x9ecdc3c63716b45d0756eece5fe1614cae1889ec5a1ce62b3127c1f1f1615d6e;
    bytes32 constant public TERMINATE_EMPLOYEE_ROLE = 0x69c67f914d12b6440e7ddf01961214818d9158fbcb19211e0ff42800fdea9242;
    bytes32 constant public SET_EMPLOYEE_SALARY_ROLE = 0xea9ac65018da2421cf419ee2152371440c08267a193a33ccc1e39545d197e44d;
    bytes32 constant public ADD_BONUS_ROLE = 0xceca7e2f5eb749a87aaf68f3f76d6b9251aa2f4600f13f93c5a4adf7a72df4ae;
    bytes32 constant public ADD_REIMBURSEMENT_ROLE = 0x90698b9d54427f1e41636025017309bdb1b55320da960c8845bab0a504b01a16;
    bytes32 constant public MANAGE_ALLOWED_TOKENS_ROLE = 0x0be34987c45700ee3fae8c55e270418ba903337decc6bacb1879504be9331c06;
    bytes32 constant public MODIFY_PRICE_FEED_ROLE = 0x74350efbcba8b85341c5bbf70cc34e2a585fc1463524773a12fa0a71d4eb9302;
    bytes32 constant public MODIFY_RATE_EXPIRY_ROLE = 0x79fe989a8899060dfbdabb174ebb96616fa9f1d9dadd739f8d814cbab452404e;

    uint256 internal constant MAX_ALLOWED_TOKENS = 20; 
    uint64 internal constant MIN_RATE_EXPIRY = uint64(1 minutes); 

    uint256 internal constant MAX_UINT256 = uint256(-1);
    uint64 internal constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_EMPLOYEE_DOESNT_EXIST = "PAYROLL_EMPLOYEE_DOESNT_EXIST";
    string private constant ERROR_NON_ACTIVE_EMPLOYEE = "PAYROLL_NON_ACTIVE_EMPLOYEE";
    string private constant ERROR_SENDER_DOES_NOT_MATCH = "PAYROLL_SENDER_DOES_NOT_MATCH";
    string private constant ERROR_FINANCE_NOT_CONTRACT = "PAYROLL_FINANCE_NOT_CONTRACT";
    string private constant ERROR_TOKEN_ALREADY_SET = "PAYROLL_TOKEN_ALREADY_SET";
    string private constant ERROR_MAX_ALLOWED_TOKENS = "PAYROLL_MAX_ALLOWED_TOKENS";
    string private constant ERROR_MIN_RATES_MISMATCH = "PAYROLL_MIN_RATES_MISMATCH";
    string private constant ERROR_TOKEN_ALLOCATION_MISMATCH = "PAYROLL_TOKEN_ALLOCATION_MISMATCH";
    string private constant ERROR_NOT_ALLOWED_TOKEN = "PAYROLL_NOT_ALLOWED_TOKEN";
    string private constant ERROR_DISTRIBUTION_NOT_FULL = "PAYROLL_DISTRIBUTION_NOT_FULL";
    string private constant ERROR_INVALID_PAYMENT_TYPE = "PAYROLL_INVALID_PAYMENT_TYPE";
    string private constant ERROR_NOTHING_PAID = "PAYROLL_NOTHING_PAID";
    string private constant ERROR_CAN_NOT_FORWARD = "PAYROLL_CAN_NOT_FORWARD";
    string private constant ERROR_EMPLOYEE_NULL_ADDRESS = "PAYROLL_EMPLOYEE_NULL_ADDRESS";
    string private constant ERROR_EMPLOYEE_ALREADY_EXIST = "PAYROLL_EMPLOYEE_ALREADY_EXIST";
    string private constant ERROR_FEED_NOT_CONTRACT = "PAYROLL_FEED_NOT_CONTRACT";
    string private constant ERROR_EXPIRY_TIME_TOO_SHORT = "PAYROLL_EXPIRY_TIME_TOO_SHORT";
    string private constant ERROR_PAST_TERMINATION_DATE = "PAYROLL_PAST_TERMINATION_DATE";
    string private constant ERROR_EXCHANGE_RATE_TOO_LOW = "PAYROLL_EXCHANGE_RATE_TOO_LOW";
    string private constant ERROR_LAST_PAYROLL_DATE_TOO_BIG = "PAYROLL_LAST_DATE_TOO_BIG";
    string private constant ERROR_INVALID_REQUESTED_AMOUNT = "PAYROLL_INVALID_REQUESTED_AMT";

    enum PaymentType { Payroll, Reimbursement, Bonus }

    struct Employee {
        address accountAddress; 
        uint256 denominationTokenSalary; 
        uint256 accruedSalary; 
        uint256 bonus;
        uint256 reimbursements;
        uint64 lastPayroll;
        uint64 endDate;
        address[] allocationTokenAddresses;
        mapping(address => uint256) allocationTokens;
    }

    Finance public finance;
    address public denominationToken;
    IFeed public feed;
    uint64 public rateExpiryTime;

    
    uint256 public nextEmployee;
    mapping(uint256 => Employee) internal employees;     
    mapping(address => uint256) internal employeeIds;    

    mapping(address => bool) internal allowedTokens;

    event AddEmployee(
        uint256 indexed employeeId,
        address indexed accountAddress,
        uint256 initialDenominationSalary,
        uint64 startDate,
        string role
    );
    event TerminateEmployee(uint256 indexed employeeId, uint64 endDate);
    event SetEmployeeSalary(uint256 indexed employeeId, uint256 denominationSalary);
    event AddEmployeeAccruedSalary(uint256 indexed employeeId, uint256 amount);
    event AddEmployeeBonus(uint256 indexed employeeId, uint256 amount);
    event AddEmployeeReimbursement(uint256 indexed employeeId, uint256 amount);
    event ChangeAddressByEmployee(uint256 indexed employeeId, address indexed newAccountAddress, address indexed oldAccountAddress);
    event DetermineAllocation(uint256 indexed employeeId);
    event SendPayment(
        uint256 indexed employeeId,
        address indexed accountAddress,
        address indexed token,
        uint256 amount,
        uint256 exchangeRate,
        string paymentReference
    );
    event SetAllowedToken(address indexed token, bool allowed);
    event SetPriceFeed(address indexed feed);
    event SetRateExpiryTime(uint64 time);

    
    modifier employeeIdExists(uint256 _employeeId) {
        require(_employeeExists(_employeeId), ERROR_EMPLOYEE_DOESNT_EXIST);
        _;
    }

    
    modifier employeeActive(uint256 _employeeId) {
        
        require(_isEmployeeIdActive(_employeeId), ERROR_NON_ACTIVE_EMPLOYEE);
        _;
    }

    
    modifier employeeMatches {
        require(employees[employeeIds[msg.sender]].accountAddress == msg.sender, ERROR_SENDER_DOES_NOT_MATCH);
        _;
    }

    
    function initialize(Finance _finance, address _denominationToken, IFeed _priceFeed, uint64 _rateExpiryTime) external onlyInit {
        initialized();

        require(isContract(_finance), ERROR_FINANCE_NOT_CONTRACT);
        finance = _finance;

        denominationToken = _denominationToken;
        _setPriceFeed(_priceFeed);
        _setRateExpiryTime(_rateExpiryTime);

        
        nextEmployee = 1;
    }

    
    function setAllowedToken(address _token, bool _allowed) external authP(MANAGE_ALLOWED_TOKENS_ROLE, arr(_token)) {
        require(allowedTokens[_token] != _allowed, ERROR_TOKEN_ALREADY_SET);
        allowedTokens[_token] = _allowed;
        emit SetAllowedToken(_token, _allowed);
    }

    
    function setPriceFeed(IFeed _feed) external authP(MODIFY_PRICE_FEED_ROLE, arr(_feed, feed)) {
        _setPriceFeed(_feed);
    }

    
    function setRateExpiryTime(uint64 _time) external authP(MODIFY_RATE_EXPIRY_ROLE, arr(uint256(_time), uint256(rateExpiryTime))) {
        _setRateExpiryTime(_time);
    }

    
    function addEmployee(address _accountAddress, uint256 _initialDenominationSalary, uint64 _startDate, string _role)
        external
        authP(ADD_EMPLOYEE_ROLE, arr(_accountAddress, _initialDenominationSalary, uint256(_startDate)))
    {
        _addEmployee(_accountAddress, _initialDenominationSalary, _startDate, _role);
    }

    
    function addBonus(uint256 _employeeId, uint256 _amount)
        external
        authP(ADD_BONUS_ROLE, arr(_employeeId, _amount))
        employeeActive(_employeeId)
    {
        _addBonus(_employeeId, _amount);
    }

    
    function addReimbursement(uint256 _employeeId, uint256 _amount)
        external
        authP(ADD_REIMBURSEMENT_ROLE, arr(_employeeId, _amount))
        employeeActive(_employeeId)
    {
        _addReimbursement(_employeeId, _amount);
    }

    
    function setEmployeeSalary(uint256 _employeeId, uint256 _denominationSalary)
        external
        authP(SET_EMPLOYEE_SALARY_ROLE, arr(_employeeId, _denominationSalary, employees[_employeeId].denominationTokenSalary))
        employeeActive(_employeeId)
    {
        Employee storage employee = employees[_employeeId];

        
        uint256 owed = _getOwedSalarySinceLastPayroll(employee, false);
        _addAccruedSalary(_employeeId, owed);

        
        employee.lastPayroll = getTimestamp64();
        employee.denominationTokenSalary = _denominationSalary;

        emit SetEmployeeSalary(_employeeId, _denominationSalary);
    }

    
    function terminateEmployee(uint256 _employeeId, uint64 _endDate)
        external
        authP(TERMINATE_EMPLOYEE_ROLE, arr(_employeeId, uint256(_endDate)))
        employeeActive(_employeeId)
    {
        _terminateEmployee(_employeeId, _endDate);
    }

    
    function changeAddressByEmployee(address _newAccountAddress) external employeeMatches nonReentrant {
        uint256 employeeId = employeeIds[msg.sender];
        address oldAddress = employees[employeeId].accountAddress;

        _setEmployeeAddress(employeeId, _newAccountAddress);
        
        
        delete employeeIds[oldAddress];

        emit ChangeAddressByEmployee(employeeId, _newAccountAddress, oldAddress);
    }

    
    function determineAllocation(address[] _tokens, uint256[] _distribution) external employeeMatches nonReentrant {
        
        require(_tokens.length <= MAX_ALLOWED_TOKENS, ERROR_MAX_ALLOWED_TOKENS);
        require(_tokens.length == _distribution.length, ERROR_TOKEN_ALLOCATION_MISMATCH);

        uint256 employeeId = employeeIds[msg.sender];
        Employee storage employee = employees[employeeId];

        
        address[] memory previousAllowedTokenAddresses = employee.allocationTokenAddresses;
        for (uint256 j = 0; j < previousAllowedTokenAddresses.length; j++) {
            delete employee.allocationTokens[previousAllowedTokenAddresses[j]];
        }
        delete employee.allocationTokenAddresses;

        
        for (uint256 i = 0; i < _tokens.length; i++) {
            employee.allocationTokenAddresses.push(_tokens[i]);
            employee.allocationTokens[_tokens[i]] = _distribution[i];
        }

        _ensureEmployeeTokenAllocationsIsValid(employee);
        emit DetermineAllocation(employeeId);
    }

    
    function payday(PaymentType _type, uint256 _requestedAmount, uint256[] _minRates) external employeeMatches nonReentrant {
        uint256 paymentAmount;
        uint256 employeeId = employeeIds[msg.sender];
        Employee storage employee = employees[employeeId];
        _ensureEmployeeTokenAllocationsIsValid(employee);
        require(_minRates.length == 0 || _minRates.length == employee.allocationTokenAddresses.length, ERROR_MIN_RATES_MISMATCH);

        
        if (_type == PaymentType.Payroll) {
            
            
            
            uint256 totalOwedSalary = _getTotalOwedCappedSalary(employee);
            paymentAmount = _ensurePaymentAmount(totalOwedSalary, _requestedAmount);
            _updateEmployeeAccountingBasedOnPaidSalary(employee, paymentAmount);
        } else if (_type == PaymentType.Reimbursement) {
            uint256 owedReimbursements = employee.reimbursements;
            paymentAmount = _ensurePaymentAmount(owedReimbursements, _requestedAmount);
            employee.reimbursements = owedReimbursements.sub(paymentAmount);
        } else if (_type == PaymentType.Bonus) {
            uint256 owedBonusAmount = employee.bonus;
            paymentAmount = _ensurePaymentAmount(owedBonusAmount, _requestedAmount);
            employee.bonus = owedBonusAmount.sub(paymentAmount);
        } else {
            revert(ERROR_INVALID_PAYMENT_TYPE);
        }

        
        require(_transferTokensAmount(employeeId, _type, paymentAmount, _minRates), ERROR_NOTHING_PAID);
        _removeEmployeeIfTerminatedAndPaidOut(employeeId);
    }

    

    
    function isForwarder() external pure returns (bool) {
        return true;
    }

    
    function forward(bytes _evmScript) public {
        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);
        bytes memory input = new bytes(0); 

        
        
        address[] memory blacklist = new address[](1);
        blacklist[0] = address(finance);

        runScript(_evmScript, input, blacklist);
    }

    
    function canForward(address _sender, bytes) public view returns (bool) {
        return _isEmployeeIdActive(employeeIds[_sender]);
    }

    

    
    function getEmployeeIdByAddress(address _accountAddress) public view returns (uint256) {
        require(employeeIds[_accountAddress] != uint256(0), ERROR_EMPLOYEE_DOESNT_EXIST);
        return employeeIds[_accountAddress];
    }

    
    function getEmployee(uint256 _employeeId)
        public
        view
        employeeIdExists(_employeeId)
        returns (
            address accountAddress,
            uint256 denominationSalary,
            uint256 accruedSalary,
            uint256 bonus,
            uint256 reimbursements,
            uint64 lastPayroll,
            uint64 endDate,
            address[] allocationTokens
        )
    {
        Employee storage employee = employees[_employeeId];

        accountAddress = employee.accountAddress;
        denominationSalary = employee.denominationTokenSalary;
        accruedSalary = employee.accruedSalary;
        bonus = employee.bonus;
        reimbursements = employee.reimbursements;
        lastPayroll = employee.lastPayroll;
        endDate = employee.endDate;
        allocationTokens = employee.allocationTokenAddresses;
    }

    
    function getTotalOwedSalary(uint256 _employeeId) public view employeeIdExists(_employeeId) returns (uint256) {
        return _getTotalOwedCappedSalary(employees[_employeeId]);
    }

    
    function getAllocation(uint256 _employeeId, address _token) public view employeeIdExists(_employeeId) returns (uint256) {
        return employees[_employeeId].allocationTokens[_token];
    }

    
    function isTokenAllowed(address _token) public view isInitialized returns (bool) {
        return allowedTokens[_token];
    }

    

    
    function _setPriceFeed(IFeed _feed) internal {
        require(isContract(_feed), ERROR_FEED_NOT_CONTRACT);
        feed = _feed;
        emit SetPriceFeed(feed);
    }

    
    function _setRateExpiryTime(uint64 _time) internal {
        
        require(_time >= MIN_RATE_EXPIRY, ERROR_EXPIRY_TIME_TOO_SHORT);
        rateExpiryTime = _time;
        emit SetRateExpiryTime(rateExpiryTime);
    }

    
    function _addEmployee(address _accountAddress, uint256 _initialDenominationSalary, uint64 _startDate, string _role) internal {
        uint256 employeeId = nextEmployee++;

        _setEmployeeAddress(employeeId, _accountAddress);

        Employee storage employee = employees[employeeId];
        employee.denominationTokenSalary = _initialDenominationSalary;
        employee.lastPayroll = _startDate;
        employee.endDate = MAX_UINT64;

        emit AddEmployee(employeeId, _accountAddress, _initialDenominationSalary, _startDate, _role);
    }

    
    function _addBonus(uint256 _employeeId, uint256 _amount) internal {
        Employee storage employee = employees[_employeeId];
        employee.bonus = employee.bonus.add(_amount);
        emit AddEmployeeBonus(_employeeId, _amount);
    }

    
    function _addReimbursement(uint256 _employeeId, uint256 _amount) internal {
        Employee storage employee = employees[_employeeId];
        employee.reimbursements = employee.reimbursements.add(_amount);
        emit AddEmployeeReimbursement(_employeeId, _amount);
    }

    
    function _addAccruedSalary(uint256 _employeeId, uint256 _amount) internal {
        Employee storage employee = employees[_employeeId];
        employee.accruedSalary = employee.accruedSalary.add(_amount);
        emit AddEmployeeAccruedSalary(_employeeId, _amount);
    }

    
    function _setEmployeeAddress(uint256 _employeeId, address _accountAddress) internal {
        
        require(_accountAddress != address(0), ERROR_EMPLOYEE_NULL_ADDRESS);
        
        require(employeeIds[_accountAddress] == uint256(0), ERROR_EMPLOYEE_ALREADY_EXIST);

        employees[_employeeId].accountAddress = _accountAddress;

        
        employeeIds[_accountAddress] = _employeeId;
    }

    
    function _terminateEmployee(uint256 _employeeId, uint64 _endDate) internal {
        
        require(_endDate >= getTimestamp64(), ERROR_PAST_TERMINATION_DATE);
        employees[_employeeId].endDate = _endDate;
        emit TerminateEmployee(_employeeId, _endDate);
    }

    
    function _transferTokensAmount(uint256 _employeeId, PaymentType _type, uint256 _totalAmount, uint256[] _minRates) internal returns (bool somethingPaid) {
        if (_totalAmount == 0) {
            return false;
        }

        Employee storage employee = employees[_employeeId];
        address employeeAddress = employee.accountAddress;
        string memory paymentReference = _paymentReferenceFor(_type);

        address[] storage allocationTokenAddresses = employee.allocationTokenAddresses;
        for (uint256 i = 0; i < allocationTokenAddresses.length; i++) {
            address token = allocationTokenAddresses[i];
            uint256 tokenAllocation = employee.allocationTokens[token];
            if (tokenAllocation != uint256(0)) {
                
                
                uint256 exchangeRate = _getExchangeRateInDenominationToken(token);
                require(_minRates.length > 0 ? exchangeRate >= _minRates[i] : exchangeRate > 0, ERROR_EXCHANGE_RATE_TOO_LOW);

                
                uint256 tokenAmount = _totalAmount.mul(exchangeRate).mul(tokenAllocation);
                
                tokenAmount = tokenAmount.div(100).div(feed.ratePrecision());

                
                finance.newImmediatePayment(token, employeeAddress, tokenAmount, paymentReference);
                emit SendPayment(_employeeId, employeeAddress, token, tokenAmount, exchangeRate, paymentReference);
                somethingPaid = true;
            }
        }
    }

    
    function _removeEmployeeIfTerminatedAndPaidOut(uint256 _employeeId) internal {
        Employee storage employee = employees[_employeeId];

        if (
            employee.lastPayroll == employee.endDate &&
            (employee.accruedSalary == 0 && employee.bonus == 0 && employee.reimbursements == 0)
        ) {
            delete employeeIds[employee.accountAddress];
            delete employees[_employeeId];
        }
    }

    
    function _updateEmployeeAccountingBasedOnPaidSalary(Employee storage _employee, uint256 _paymentAmount) internal {
        uint256 accruedSalary = _employee.accruedSalary;

        if (_paymentAmount <= accruedSalary) {
            
            
            
            _employee.accruedSalary = accruedSalary - _paymentAmount;
            return;
        }

        
        
        uint256 currentSalaryPaid = _paymentAmount;
        if (accruedSalary > 0) {
            
            
            
            currentSalaryPaid = _paymentAmount - accruedSalary;
            
            _employee.accruedSalary = 0;
        }

        uint256 salary = _employee.denominationTokenSalary;
        uint256 timeDiff = currentSalaryPaid.div(salary);

        
        
        
        uint256 extraSalary = currentSalaryPaid % salary;
        if (extraSalary > 0) {
            timeDiff = timeDiff.add(1);
            _employee.accruedSalary = salary - extraSalary;
        }

        uint256 lastPayrollDate = uint256(_employee.lastPayroll).add(timeDiff);
        
        
        
        require(lastPayrollDate <= uint256(getTimestamp64()), ERROR_LAST_PAYROLL_DATE_TOO_BIG);
        
        _employee.lastPayroll = uint64(lastPayrollDate);
    }

    
    function _employeeExists(uint256 _employeeId) internal view returns (bool) {
        return employees[_employeeId].accountAddress != address(0);
    }

    
    function _ensureEmployeeTokenAllocationsIsValid(Employee storage _employee) internal view {
        uint256 sum = 0;
        address[] memory allocationTokenAddresses = _employee.allocationTokenAddresses;
        for (uint256 i = 0; i < allocationTokenAddresses.length; i++) {
            address token = allocationTokenAddresses[i];
            require(allowedTokens[token], ERROR_NOT_ALLOWED_TOKEN);
            sum = sum.add(_employee.allocationTokens[token]);
        }
        require(sum == 100, ERROR_DISTRIBUTION_NOT_FULL);
    }

    
    function _isEmployeeActive(Employee storage _employee) internal view returns (bool) {
        return _employee.endDate >= getTimestamp64();
    }

    
    function _isEmployeeIdActive(uint256 _employeeId) internal view returns (bool) {
        return _isEmployeeActive(employees[_employeeId]);
    }

    
    function _getExchangeRateInDenominationToken(address _token) internal view returns (uint256) {
        
        (uint128 xrt, uint64 when) = feed.get(
            denominationToken,  
            _token              
        );

        
        if (getTimestamp64().sub(when) >= rateExpiryTime) {
            return 0;
        }

        return uint256(xrt);
    }

    
    function _getOwedSalarySinceLastPayroll(Employee storage _employee, bool _capped) internal view returns (uint256) {
        uint256 timeDiff = _getOwedPayrollPeriod(_employee);
        if (timeDiff == 0) {
            return 0;
        }
        uint256 salary = _employee.denominationTokenSalary;

        if (_capped) {
            
            uint256 result = salary * timeDiff;
            return (result / timeDiff != salary) ? MAX_UINT256 : result;
        } else {
            return salary.mul(timeDiff);
        }
    }

    
    function _getOwedPayrollPeriod(Employee storage _employee) internal view returns (uint256) {
        
        uint64 date = _isEmployeeActive(_employee) ? getTimestamp64() : _employee.endDate;

        
        
        
        
        
        if (date <= _employee.lastPayroll) {
            return 0;
        }

        
        return uint256(date - _employee.lastPayroll);
    }

    
    function _getTotalOwedCappedSalary(Employee storage _employee) internal view returns (uint256) {
        uint256 currentOwedSalary = _getOwedSalarySinceLastPayroll(_employee, true); 
        uint256 totalOwedSalary = currentOwedSalary + _employee.accruedSalary;
        if (totalOwedSalary < currentOwedSalary) {
            totalOwedSalary = MAX_UINT256;
        }
        return totalOwedSalary;
    }

    
    function _paymentReferenceFor(PaymentType _type) internal pure returns (string memory) {
        if (_type == PaymentType.Payroll) {
            return "Employee salary";
        } else if (_type == PaymentType.Reimbursement) {
            return "Employee reimbursement";
        } if (_type == PaymentType.Bonus) {
            return "Employee bonus";
        }
        revert(ERROR_INVALID_PAYMENT_TYPE);
    }

    function _ensurePaymentAmount(uint256 _owedAmount, uint256 _requestedAmount) private pure returns (uint256) {
        require(_owedAmount > 0, ERROR_NOTHING_PAID);
        require(_owedAmount >= _requestedAmount, ERROR_INVALID_REQUESTED_AMOUNT);
        return _requestedAmount > 0 ? _requestedAmount : _owedAmount;
    }
}





pragma solidity 0.4.24;






contract Survey is AragonApp {
    using SafeMath for uint256;
    using SafeMath64 for uint64;

    bytes32 public constant CREATE_SURVEYS_ROLE = keccak256("CREATE_SURVEYS_ROLE");
    bytes32 public constant MODIFY_PARTICIPATION_ROLE = keccak256("MODIFY_PARTICIPATION_ROLE");

    uint64 public constant PCT_BASE = 10 ** 18; 
    uint256 public constant ABSTAIN_VOTE = 0;

    string private constant ERROR_MIN_PARTICIPATION = "SURVEY_MIN_PARTICIPATION";
    string private constant ERROR_NO_SURVEY = "SURVEY_NO_SURVEY";
    string private constant ERROR_NO_VOTING_POWER = "SURVEY_NO_VOTING_POWER";
    string private constant ERROR_CAN_NOT_VOTE = "SURVEY_CAN_NOT_VOTE";
    string private constant ERROR_VOTE_WRONG_INPUT = "SURVEY_VOTE_WRONG_INPUT";
    string private constant ERROR_VOTE_WRONG_OPTION = "SURVEY_VOTE_WRONG_OPTION";
    string private constant ERROR_NO_STAKE = "SURVEY_NO_STAKE";
    string private constant ERROR_OPTIONS_NOT_ORDERED = "SURVEY_OPTIONS_NOT_ORDERED";
    string private constant ERROR_NO_OPTION = "SURVEY_NO_OPTION";

    struct OptionCast {
        uint256 optionId;
        uint256 stake;
    }

    
    struct MultiOptionVote {
        uint256 optionsCastedLength;
        
        
        mapping (uint256 => OptionCast) castedVotes;
    }

    struct SurveyStruct {
        uint64 startDate;
        uint64 snapshotBlock;
        uint64 minParticipationPct;
        uint256 options;
        uint256 votingPower;                    
        uint256 participation;                  

        
        mapping (uint256 => uint256) optionPower;       
        mapping (address => MultiOptionVote) votes;     
    }

    MiniMeToken public token;
    uint64 public minParticipationPct;
    uint64 public surveyTime;

    
    mapping (uint256 => SurveyStruct) internal surveys;
    uint256 public surveysLength;

    event StartSurvey(uint256 indexed surveyId, address indexed creator, string metadata);
    event CastVote(uint256 indexed surveyId, address indexed voter, uint256 option, uint256 stake, uint256 optionPower);
    event ResetVote(uint256 indexed surveyId, address indexed voter, uint256 option, uint256 previousStake, uint256 optionPower);
    event ChangeMinParticipation(uint64 minParticipationPct);

    modifier acceptableMinParticipationPct(uint64 _minParticipationPct) {
        require(_minParticipationPct > 0 && _minParticipationPct <= PCT_BASE, ERROR_MIN_PARTICIPATION);
        _;
    }

    modifier surveyExists(uint256 _surveyId) {
        require(_surveyId < surveysLength, ERROR_NO_SURVEY);
        _;
    }

    
    function initialize(
        MiniMeToken _token,
        uint64 _minParticipationPct,
        uint64 _surveyTime
    )
        external
        onlyInit
        acceptableMinParticipationPct(_minParticipationPct)
    {
        initialized();

        token = _token;
        minParticipationPct = _minParticipationPct;
        surveyTime = _surveyTime;
    }

    
    function changeMinAcceptParticipationPct(uint64 _minParticipationPct)
        external
        authP(MODIFY_PARTICIPATION_ROLE, arr(uint256(_minParticipationPct), uint256(minParticipationPct)))
        acceptableMinParticipationPct(_minParticipationPct)
    {
        minParticipationPct = _minParticipationPct;

        emit ChangeMinParticipation(_minParticipationPct);
    }

    
    function newSurvey(string _metadata, uint256 _options) external auth(CREATE_SURVEYS_ROLE) returns (uint256 surveyId) {
        uint64 snapshotBlock = getBlockNumber64() - 1; 
        uint256 votingPower = token.totalSupplyAt(snapshotBlock);
        require(votingPower > 0, ERROR_NO_VOTING_POWER);

        surveyId = surveysLength++;

        SurveyStruct storage survey = surveys[surveyId];
        survey.startDate = getTimestamp64();
        survey.snapshotBlock = snapshotBlock; 
        survey.minParticipationPct = minParticipationPct;
        survey.options = _options;
        survey.votingPower = votingPower;

        emit StartSurvey(surveyId, msg.sender, _metadata);
    }

    
    function resetVote(uint256 _surveyId) external surveyExists(_surveyId) {
        require(canVote(_surveyId, msg.sender), ERROR_CAN_NOT_VOTE);

        _resetVote(_surveyId);
    }

    
    function voteOptions(uint256 _surveyId, uint256[] _optionIds, uint256[] _stakes)
        external
        surveyExists(_surveyId)
    {
        require(_optionIds.length == _stakes.length && _optionIds.length > 0, ERROR_VOTE_WRONG_INPUT);
        require(canVote(_surveyId, msg.sender), ERROR_CAN_NOT_VOTE);

        _voteOptions(_surveyId, _optionIds, _stakes);
    }

    
    function voteOption(uint256 _surveyId, uint256 _optionId) external surveyExists(_surveyId) {
        require(canVote(_surveyId, msg.sender), ERROR_CAN_NOT_VOTE);

        SurveyStruct storage survey = surveys[_surveyId];
        
        uint256 voterStake = token.balanceOfAt(msg.sender, survey.snapshotBlock);
        uint256[] memory options = new uint256[](1);
        uint256[] memory stakes = new uint256[](1);
        options[0] = _optionId;
        stakes[0] = voterStake;

        _voteOptions(_surveyId, options, stakes);
    }

    

    function canVote(uint256 _surveyId, address _voter) public view surveyExists(_surveyId) returns (bool) {
        SurveyStruct storage survey = surveys[_surveyId];

        return _isSurveyOpen(survey) && token.balanceOfAt(_voter, survey.snapshotBlock) > 0;
    }

    function getSurvey(uint256 _surveyId)
        public
        view
        surveyExists(_surveyId)
        returns (
            bool open,
            uint64 startDate,
            uint64 snapshotBlock,
            uint64 minParticipation,
            uint256 votingPower,
            uint256 participation,
            uint256 options
        )
    {
        SurveyStruct storage survey = surveys[_surveyId];

        open = _isSurveyOpen(survey);
        startDate = survey.startDate;
        snapshotBlock = survey.snapshotBlock;
        minParticipation = survey.minParticipationPct;
        votingPower = survey.votingPower;
        participation = survey.participation;
        options = survey.options;
    }

    
    
    function getVoterState(uint256 _surveyId, address _voter)
        external
        view
        surveyExists(_surveyId)
        returns (uint256[] options, uint256[] stakes)
    {
        MultiOptionVote storage vote = surveys[_surveyId].votes[_voter];

        if (vote.optionsCastedLength == 0) {
            return (new uint256[](0), new uint256[](0));
        }

        options = new uint256[](vote.optionsCastedLength + 1);
        stakes = new uint256[](vote.optionsCastedLength + 1);
        for (uint256 i = 0; i <= vote.optionsCastedLength; i++) {
            options[i] = vote.castedVotes[i].optionId;
            stakes[i] = vote.castedVotes[i].stake;
        }
    }

    function getOptionPower(uint256 _surveyId, uint256 _optionId) public view surveyExists(_surveyId) returns (uint256) {
        SurveyStruct storage survey = surveys[_surveyId];
        require(_optionId <= survey.options, ERROR_NO_OPTION);

        return survey.optionPower[_optionId];
    }

    function isParticipationAchieved(uint256 _surveyId) public view surveyExists(_surveyId) returns (bool) {
        SurveyStruct storage survey = surveys[_surveyId];
        
        uint256 participationPct = survey.participation.mul(PCT_BASE) / survey.votingPower;
        return participationPct >= survey.minParticipationPct;
    }

    

    
    function _resetVote(uint256 _surveyId) internal {
        SurveyStruct storage survey = surveys[_surveyId];
        MultiOptionVote storage previousVote = survey.votes[msg.sender];
        if (previousVote.optionsCastedLength > 0) {
            
            for (uint256 i = 1; i <= previousVote.optionsCastedLength; i++) {
                OptionCast storage previousOptionCast = previousVote.castedVotes[i];
                uint256 previousOptionPower = survey.optionPower[previousOptionCast.optionId];
                uint256 currentOptionPower = previousOptionPower.sub(previousOptionCast.stake);
                survey.optionPower[previousOptionCast.optionId] = currentOptionPower;

                emit ResetVote(_surveyId, msg.sender, previousOptionCast.optionId, previousOptionCast.stake, currentOptionPower);
            }

            
            uint256 voterStake = token.balanceOfAt(msg.sender, survey.snapshotBlock);
            uint256 previousParticipation = voterStake.sub(previousVote.castedVotes[0].stake);
            
            survey.participation = survey.participation.sub(previousParticipation);

            
            delete survey.votes[msg.sender];
        }
    }

    
    function _voteOptions(uint256 _surveyId, uint256[] _optionIds, uint256[] _stakes) internal {
        SurveyStruct storage survey = surveys[_surveyId];
        MultiOptionVote storage senderVotes = survey.votes[msg.sender];

        
        _resetVote(_surveyId);

        uint256 totalVoted = 0;
        
        senderVotes.castedVotes[0] = OptionCast({ optionId: ABSTAIN_VOTE, stake: 0 });
        for (uint256 optionIndex = 1; optionIndex <= _optionIds.length; optionIndex++) {
            
            
            
            uint256 optionId = _optionIds[optionIndex - 1];
            uint256 stake = _stakes[optionIndex - 1];

            require(optionId != ABSTAIN_VOTE && optionId <= survey.options, ERROR_VOTE_WRONG_OPTION);
            require(stake > 0, ERROR_NO_STAKE);
            
            
            
            require(senderVotes.castedVotes[optionIndex - 1].optionId < optionId, ERROR_OPTIONS_NOT_ORDERED);

            
            senderVotes.castedVotes[optionIndex] = OptionCast({ optionId: optionId, stake: stake });

            
            survey.optionPower[optionId] = survey.optionPower[optionId].add(stake);

            
            totalVoted = totalVoted.add(stake);

            emit CastVote(_surveyId, msg.sender, optionId, stake, survey.optionPower[optionId]);
        }

        
        
        
        uint256 voterStake = token.balanceOfAt(msg.sender, survey.snapshotBlock);
        senderVotes.castedVotes[0].stake = voterStake.sub(totalVoted);

        
        senderVotes.optionsCastedLength = _optionIds.length;

        
        survey.participation = survey.participation.add(totalVoted);
        assert(survey.participation <= survey.votingPower);
    }

    function _isSurveyOpen(SurveyStruct storage _survey) internal view returns (bool) {
        return getTimestamp64() < _survey.startDate.add(surveyTime);
    }
}





pragma solidity 0.4.24;







contract Voting is IForwarder, AragonApp {
    using SafeMath for uint256;
    using SafeMath64 for uint64;

    bytes32 public constant CREATE_VOTES_ROLE = keccak256("CREATE_VOTES_ROLE");
    bytes32 public constant MODIFY_SUPPORT_ROLE = keccak256("MODIFY_SUPPORT_ROLE");
    bytes32 public constant MODIFY_QUORUM_ROLE = keccak256("MODIFY_QUORUM_ROLE");

    uint64 public constant PCT_BASE = 10 ** 18; 

    string private constant ERROR_NO_VOTE = "VOTING_NO_VOTE";
    string private constant ERROR_INIT_PCTS = "VOTING_INIT_PCTS";
    string private constant ERROR_CHANGE_SUPPORT_PCTS = "VOTING_CHANGE_SUPPORT_PCTS";
    string private constant ERROR_CHANGE_QUORUM_PCTS = "VOTING_CHANGE_QUORUM_PCTS";
    string private constant ERROR_INIT_SUPPORT_TOO_BIG = "VOTING_INIT_SUPPORT_TOO_BIG";
    string private constant ERROR_CHANGE_SUPPORT_TOO_BIG = "VOTING_CHANGE_SUPP_TOO_BIG";
    string private constant ERROR_CAN_NOT_VOTE = "VOTING_CAN_NOT_VOTE";
    string private constant ERROR_CAN_NOT_EXECUTE = "VOTING_CAN_NOT_EXECUTE";
    string private constant ERROR_CAN_NOT_FORWARD = "VOTING_CAN_NOT_FORWARD";
    string private constant ERROR_NO_VOTING_POWER = "VOTING_NO_VOTING_POWER";

    enum VoterState { Absent, Yea, Nay }

    struct Vote {
        bool executed;
        uint64 startDate;
        uint64 snapshotBlock;
        uint64 supportRequiredPct;
        uint64 minAcceptQuorumPct;
        uint256 yea;
        uint256 nay;
        uint256 votingPower;
        bytes executionScript;
        mapping (address => VoterState) voters;
    }

    MiniMeToken public token;
    uint64 public supportRequiredPct;
    uint64 public minAcceptQuorumPct;
    uint64 public voteTime;

    
    mapping (uint256 => Vote) internal votes;
    uint256 public votesLength;

    event StartVote(uint256 indexed voteId, address indexed creator, string metadata);
    event CastVote(uint256 indexed voteId, address indexed voter, bool supports, uint256 stake);
    event ExecuteVote(uint256 indexed voteId);
    event ChangeSupportRequired(uint64 supportRequiredPct);
    event ChangeMinQuorum(uint64 minAcceptQuorumPct);

    modifier voteExists(uint256 _voteId) {
        require(_voteId < votesLength, ERROR_NO_VOTE);
        _;
    }

    
    function initialize(
        MiniMeToken _token,
        uint64 _supportRequiredPct,
        uint64 _minAcceptQuorumPct,
        uint64 _voteTime
    )
        external
        onlyInit
    {
        initialized();

        require(_minAcceptQuorumPct <= _supportRequiredPct, ERROR_INIT_PCTS);
        require(_supportRequiredPct < PCT_BASE, ERROR_INIT_SUPPORT_TOO_BIG);

        token = _token;
        supportRequiredPct = _supportRequiredPct;
        minAcceptQuorumPct = _minAcceptQuorumPct;
        voteTime = _voteTime;
    }

    
    function changeSupportRequiredPct(uint64 _supportRequiredPct)
        external
        authP(MODIFY_SUPPORT_ROLE, arr(uint256(_supportRequiredPct), uint256(supportRequiredPct)))
    {
        require(minAcceptQuorumPct <= _supportRequiredPct, ERROR_CHANGE_SUPPORT_PCTS);
        require(_supportRequiredPct < PCT_BASE, ERROR_CHANGE_SUPPORT_TOO_BIG);
        supportRequiredPct = _supportRequiredPct;

        emit ChangeSupportRequired(_supportRequiredPct);
    }

    
    function changeMinAcceptQuorumPct(uint64 _minAcceptQuorumPct)
        external
        authP(MODIFY_QUORUM_ROLE, arr(uint256(_minAcceptQuorumPct), uint256(minAcceptQuorumPct)))
    {
        require(_minAcceptQuorumPct <= supportRequiredPct, ERROR_CHANGE_QUORUM_PCTS);
        minAcceptQuorumPct = _minAcceptQuorumPct;

        emit ChangeMinQuorum(_minAcceptQuorumPct);
    }

    
    function newVote(bytes _executionScript, string _metadata) external auth(CREATE_VOTES_ROLE) returns (uint256 voteId) {
        return _newVote(_executionScript, _metadata, true, true);
    }

    
    function newVote(bytes _executionScript, string _metadata, bool _castVote, bool _executesIfDecided)
        external
        auth(CREATE_VOTES_ROLE)
        returns (uint256 voteId)
    {
        return _newVote(_executionScript, _metadata, _castVote, _executesIfDecided);
    }

    
    function vote(uint256 _voteId, bool _supports, bool _executesIfDecided) external voteExists(_voteId) {
        require(_canVote(_voteId, msg.sender), ERROR_CAN_NOT_VOTE);
        _vote(_voteId, _supports, msg.sender, _executesIfDecided);
    }

    
    function executeVote(uint256 _voteId) external voteExists(_voteId) {
        _executeVote(_voteId);
    }

    

    function isForwarder() external pure returns (bool) {
        return true;
    }

    
    function forward(bytes _evmScript) public {
        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);
        _newVote(_evmScript, "", true, true);
    }

    function canForward(address _sender, bytes) public view returns (bool) {
        // Note that `canPerform()` implicitly does an initialization check itself
        return canPerform(_sender, CREATE_VOTES_ROLE, arr());
    }

    // Getter fns

    /**
    * @dev Initialization check is implicitly provided by `voteExists()` as new votes can only be
    *      created via `newVote(),` which requires initialization
    */
    function canExecute(uint256 _voteId) public view voteExists(_voteId) returns (bool) {
        return _canExecute(_voteId);
    }

    /**
    * @dev Initialization check is implicitly provided by `voteExists()` as new votes can only be
    *      created via `newVote(),` which requires initialization
    */
    function canVote(uint256 _voteId, address _voter) public view voteExists(_voteId) returns (bool) {
        return _canVote(_voteId, _voter);
    }

    function getVote(uint256 _voteId)
        public
        view
        voteExists(_voteId)
        returns (
            bool open,
            bool executed,
            uint64 startDate,
            uint64 snapshotBlock,
            uint64 supportRequired,
            uint64 minAcceptQuorum,
            uint256 yea,
            uint256 nay,
            uint256 votingPower,
            bytes script
        )
    {
        Vote storage vote_ = votes[_voteId];

        open = _isVoteOpen(vote_);
        executed = vote_.executed;
        startDate = vote_.startDate;
        snapshotBlock = vote_.snapshotBlock;
        supportRequired = vote_.supportRequiredPct;
        minAcceptQuorum = vote_.minAcceptQuorumPct;
        yea = vote_.yea;
        nay = vote_.nay;
        votingPower = vote_.votingPower;
        script = vote_.executionScript;
    }

    function getVoterState(uint256 _voteId, address _voter) public view voteExists(_voteId) returns (VoterState) {
        return votes[_voteId].voters[_voter];
    }

    // Internal fns

    function _newVote(bytes _executionScript, string _metadata, bool _castVote, bool _executesIfDecided)
        internal
        returns (uint256 voteId)
    {
        uint64 snapshotBlock = getBlockNumber64() - 1; // avoid double voting in this very block
        uint256 votingPower = token.totalSupplyAt(snapshotBlock);
        require(votingPower > 0, ERROR_NO_VOTING_POWER);

        voteId = votesLength++;

        Vote storage vote_ = votes[voteId];
        vote_.startDate = getTimestamp64();
        vote_.snapshotBlock = snapshotBlock;
        vote_.supportRequiredPct = supportRequiredPct;
        vote_.minAcceptQuorumPct = minAcceptQuorumPct;
        vote_.votingPower = votingPower;
        vote_.executionScript = _executionScript;

        emit StartVote(voteId, msg.sender, _metadata);

        if (_castVote && _canVote(voteId, msg.sender)) {
            _vote(voteId, true, msg.sender, _executesIfDecided);
        }
    }

    function _vote(
        uint256 _voteId,
        bool _supports,
        address _voter,
        bool _executesIfDecided
    ) internal
    {
        Vote storage vote_ = votes[_voteId];

        // This could re-enter, though we can assume the governance token is not malicious
        uint256 voterStake = token.balanceOfAt(_voter, vote_.snapshotBlock);
        VoterState state = vote_.voters[_voter];

        // If voter had previously voted, decrease count
        if (state == VoterState.Yea) {
            vote_.yea = vote_.yea.sub(voterStake);
        } else if (state == VoterState.Nay) {
            vote_.nay = vote_.nay.sub(voterStake);
        }

        if (_supports) {
            vote_.yea = vote_.yea.add(voterStake);
        } else {
            vote_.nay = vote_.nay.add(voterStake);
        }

        vote_.voters[_voter] = _supports ? VoterState.Yea : VoterState.Nay;

        emit CastVote(_voteId, _voter, _supports, voterStake);

        if (_executesIfDecided && _canExecute(_voteId)) {
            // We've already checked if the vote can be executed with `_canExecute()`
            _unsafeExecuteVote(_voteId);
        }
    }

    function _executeVote(uint256 _voteId) internal {
        require(_canExecute(_voteId), ERROR_CAN_NOT_EXECUTE);
        _unsafeExecuteVote(_voteId);
    }

    /**
    * @dev Unsafe version of _executeVote that assumes you have already checked if the vote can be executed
    */
    function _unsafeExecuteVote(uint256 _voteId) internal {
        Vote storage vote_ = votes[_voteId];

        vote_.executed = true;

        bytes memory input = new bytes(0); // TODO: Consider input for voting scripts
        runScript(vote_.executionScript, input, new address[](0));

        emit ExecuteVote(_voteId);
    }

    function _canExecute(uint256 _voteId) internal view returns (bool) {
        Vote storage vote_ = votes[_voteId];

        if (vote_.executed) {
            return false;
        }

        // Voting is already decided
        if (_isValuePct(vote_.yea, vote_.votingPower, vote_.supportRequiredPct)) {
            return true;
        }

        // Vote ended?
        if (_isVoteOpen(vote_)) {
            return false;
        }
        // Has enough support?
        uint256 totalVotes = vote_.yea.add(vote_.nay);
        if (!_isValuePct(vote_.yea, totalVotes, vote_.supportRequiredPct)) {
            return false;
        }
        // Has min quorum?
        if (!_isValuePct(vote_.yea, vote_.votingPower, vote_.minAcceptQuorumPct)) {
            return false;
        }

        return true;
    }

    function _canVote(uint256 _voteId, address _voter) internal view returns (bool) {
        Vote storage vote_ = votes[_voteId];

        return _isVoteOpen(vote_) && token.balanceOfAt(_voter, vote_.snapshotBlock) > 0;
    }

    function _isVoteOpen(Vote storage vote_) internal view returns (bool) {
        return getTimestamp64() < vote_.startDate.add(voteTime) && !vote_.executed;
    }

    /**
    * @dev Calculates whether `_value` is more than a percentage `_pct` of `_total`
    */
    function _isValuePct(uint256 _value, uint256 _total, uint256 _pct) internal pure returns (bool) {
        if (_total == 0) {
            return false;
        }

        uint256 computedPct = _value.mul(PCT_BASE) / _total;
        return computedPct > _pct;
    }
}

// File: @aragon/id/contracts/ens/IPublicResolver.sol

pragma solidity ^0.4.0;


interface IPublicResolver {
    function supportsInterface(bytes4 interfaceID) constant returns (bool);
    function addr(bytes32 node) constant returns (address ret);
    function setAddr(bytes32 node, address addr);
    function hash(bytes32 node) constant returns (bytes32 ret);
    function setHash(bytes32 node, bytes32 hash);
}

// File: @aragon/id/contracts/IFIFSResolvingRegistrar.sol

pragma solidity 0.4.24;



interface IFIFSResolvingRegistrar {
    function register(bytes32 _subnode, address _owner) external;
    function registerWithResolver(bytes32 _subnode, address _owner, IPublicResolver _resolver) public;
}

// File: @aragon/os/contracts/acl/IACLOracle.sol

/*
 * SPDX-License-Identitifer:    MIT
 */

pragma solidity ^0.4.24;


interface IACLOracle {
    function canPerform(address who, address where, bytes32 what, uint256[] how) external view returns (bool);
}

// File: @aragon/os/contracts/acl/ACL.sol

pragma solidity 0.4.24;








/* solium-disable function-order */
// Allow public initialize() to be first
contract ACL is IACL, TimeHelpers, AragonApp, ACLHelpers {
    /* Hardcoded constants to save gas
    bytes32 public constant CREATE_PERMISSIONS_ROLE = keccak256("CREATE_PERMISSIONS_ROLE");
    */
    bytes32 public constant CREATE_PERMISSIONS_ROLE = 0x0b719b33c83b8e5d300c521cb8b54ae9bd933996a14bef8c2f4e0285d2d2400a;

    enum Op { NONE, EQ, NEQ, GT, LT, GTE, LTE, RET, NOT, AND, OR, XOR, IF_ELSE } 

    struct Param {
        uint8 id;
        uint8 op;
        uint240 value; 
        
        
    }

    uint8 internal constant BLOCK_NUMBER_PARAM_ID = 200;
    uint8 internal constant TIMESTAMP_PARAM_ID    = 201;
    
    uint8 internal constant ORACLE_PARAM_ID       = 203;
    uint8 internal constant LOGIC_OP_PARAM_ID     = 204;
    uint8 internal constant PARAM_VALUE_PARAM_ID  = 205;
    

    
    bytes32 public constant EMPTY_PARAM_HASH = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
    bytes32 public constant NO_PERMISSION = bytes32(0);
    address public constant ANY_ENTITY = address(-1);
    address public constant BURN_ENTITY = address(1); 

    uint256 internal constant ORACLE_CHECK_GAS = 30000;

    string private constant ERROR_AUTH_INIT_KERNEL = "ACL_AUTH_INIT_KERNEL";
    string private constant ERROR_AUTH_NO_MANAGER = "ACL_AUTH_NO_MANAGER";
    string private constant ERROR_EXISTENT_MANAGER = "ACL_EXISTENT_MANAGER";

    
    mapping (bytes32 => bytes32) internal permissions; 
    mapping (bytes32 => Param[]) internal permissionParams; 

    
    mapping (bytes32 => address) internal permissionManager;

    event SetPermission(address indexed entity, address indexed app, bytes32 indexed role, bool allowed);
    event SetPermissionParams(address indexed entity, address indexed app, bytes32 indexed role, bytes32 paramsHash);
    event ChangePermissionManager(address indexed app, bytes32 indexed role, address indexed manager);

    modifier onlyPermissionManager(address _app, bytes32 _role) {
        require(msg.sender == getPermissionManager(_app, _role), ERROR_AUTH_NO_MANAGER);
        _;
    }

    modifier noPermissionManager(address _app, bytes32 _role) {
        
        require(getPermissionManager(_app, _role) == address(0), ERROR_EXISTENT_MANAGER);
        _;
    }

    
    function initialize(address _permissionsCreator) public onlyInit {
        initialized();
        require(msg.sender == address(kernel()), ERROR_AUTH_INIT_KERNEL);

        _createPermission(_permissionsCreator, this, CREATE_PERMISSIONS_ROLE, _permissionsCreator);
    }

    
    function createPermission(address _entity, address _app, bytes32 _role, address _manager)
        external
        auth(CREATE_PERMISSIONS_ROLE)
        noPermissionManager(_app, _role)
    {
        _createPermission(_entity, _app, _role, _manager);
    }

    
    function grantPermission(address _entity, address _app, bytes32 _role)
        external
    {
        grantPermissionP(_entity, _app, _role, new uint256[](0));
    }

    
    function grantPermissionP(address _entity, address _app, bytes32 _role, uint256[] _params)
        public
        onlyPermissionManager(_app, _role)
    {
        bytes32 paramsHash = _params.length > 0 ? _saveParams(_params) : EMPTY_PARAM_HASH;
        _setPermission(_entity, _app, _role, paramsHash);
    }

    
    function revokePermission(address _entity, address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {
        _setPermission(_entity, _app, _role, NO_PERMISSION);
    }

    
    function setPermissionManager(address _newManager, address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {
        _setPermissionManager(_newManager, _app, _role);
    }

    
    function removePermissionManager(address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {
        _setPermissionManager(address(0), _app, _role);
    }

    
    function createBurnedPermission(address _app, bytes32 _role)
        external
        auth(CREATE_PERMISSIONS_ROLE)
        noPermissionManager(_app, _role)
    {
        _setPermissionManager(BURN_ENTITY, _app, _role);
    }

    
    function burnPermissionManager(address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {
        _setPermissionManager(BURN_ENTITY, _app, _role);
    }

    
    function getPermissionParamsLength(address _entity, address _app, bytes32 _role) external view returns (uint) {
        return permissionParams[permissions[permissionHash(_entity, _app, _role)]].length;
    }

    
    function getPermissionParam(address _entity, address _app, bytes32 _role, uint _index)
        external
        view
        returns (uint8, uint8, uint240)
    {
        Param storage param = permissionParams[permissions[permissionHash(_entity, _app, _role)]][_index];
        return (param.id, param.op, param.value);
    }

    
    function getPermissionManager(address _app, bytes32 _role) public view returns (address) {
        return permissionManager[roleHash(_app, _role)];
    }

    
    function hasPermission(address _who, address _where, bytes32 _what, bytes memory _how) public view returns (bool) {
        return hasPermission(_who, _where, _what, ConversionHelpers.dangerouslyCastBytesToUintArray(_how));
    }

    function hasPermission(address _who, address _where, bytes32 _what, uint256[] memory _how) public view returns (bool) {
        bytes32 whoParams = permissions[permissionHash(_who, _where, _what)];
        if (whoParams != NO_PERMISSION && evalParams(whoParams, _who, _where, _what, _how)) {
            return true;
        }

        bytes32 anyParams = permissions[permissionHash(ANY_ENTITY, _where, _what)];
        if (anyParams != NO_PERMISSION && evalParams(anyParams, ANY_ENTITY, _where, _what, _how)) {
            return true;
        }

        return false;
    }

    function hasPermission(address _who, address _where, bytes32 _what) public view returns (bool) {
        uint256[] memory empty = new uint256[](0);
        return hasPermission(_who, _where, _what, empty);
    }

    function evalParams(
        bytes32 _paramsHash,
        address _who,
        address _where,
        bytes32 _what,
        uint256[] _how
    ) public view returns (bool)
    {
        if (_paramsHash == EMPTY_PARAM_HASH) {
            return true;
        }

        return _evalParam(_paramsHash, 0, _who, _where, _what, _how);
    }

    
    function _createPermission(address _entity, address _app, bytes32 _role, address _manager) internal {
        _setPermission(_entity, _app, _role, EMPTY_PARAM_HASH);
        _setPermissionManager(_manager, _app, _role);
    }

    
    function _setPermission(address _entity, address _app, bytes32 _role, bytes32 _paramsHash) internal {
        permissions[permissionHash(_entity, _app, _role)] = _paramsHash;
        bool entityHasPermission = _paramsHash != NO_PERMISSION;
        bool permissionHasParams = entityHasPermission && _paramsHash != EMPTY_PARAM_HASH;

        emit SetPermission(_entity, _app, _role, entityHasPermission);
        if (permissionHasParams) {
            emit SetPermissionParams(_entity, _app, _role, _paramsHash);
        }
    }

    function _saveParams(uint256[] _encodedParams) internal returns (bytes32) {
        bytes32 paramHash = keccak256(abi.encodePacked(_encodedParams));
        Param[] storage params = permissionParams[paramHash];

        if (params.length == 0) { 
            for (uint256 i = 0; i < _encodedParams.length; i++) {
                uint256 encodedParam = _encodedParams[i];
                Param memory param = Param(decodeParamId(encodedParam), decodeParamOp(encodedParam), uint240(encodedParam));
                params.push(param);
            }
        }

        return paramHash;
    }

    function _evalParam(
        bytes32 _paramsHash,
        uint32 _paramId,
        address _who,
        address _where,
        bytes32 _what,
        uint256[] _how
    ) internal view returns (bool)
    {
        if (_paramId >= permissionParams[_paramsHash].length) {
            return false; 
        }

        Param memory param = permissionParams[_paramsHash][_paramId];

        if (param.id == LOGIC_OP_PARAM_ID) {
            return _evalLogic(param, _paramsHash, _who, _where, _what, _how);
        }

        uint256 value;
        uint256 comparedTo = uint256(param.value);

        
        if (param.id == ORACLE_PARAM_ID) {
            value = checkOracle(IACLOracle(param.value), _who, _where, _what, _how) ? 1 : 0;
            comparedTo = 1;
        } else if (param.id == BLOCK_NUMBER_PARAM_ID) {
            value = getBlockNumber();
        } else if (param.id == TIMESTAMP_PARAM_ID) {
            value = getTimestamp();
        } else if (param.id == PARAM_VALUE_PARAM_ID) {
            value = uint256(param.value);
        } else {
            if (param.id >= _how.length) {
                return false;
            }
            value = uint256(uint240(_how[param.id])); 
        }

        if (Op(param.op) == Op.RET) {
            return uint256(value) > 0;
        }

        return compare(value, Op(param.op), comparedTo);
    }

    function _evalLogic(Param _param, bytes32 _paramsHash, address _who, address _where, bytes32 _what, uint256[] _how)
        internal
        view
        returns (bool)
    {
        if (Op(_param.op) == Op.IF_ELSE) {
            uint32 conditionParam;
            uint32 successParam;
            uint32 failureParam;

            (conditionParam, successParam, failureParam) = decodeParamsList(uint256(_param.value));
            bool result = _evalParam(_paramsHash, conditionParam, _who, _where, _what, _how);

            return _evalParam(_paramsHash, result ? successParam : failureParam, _who, _where, _what, _how);
        }

        uint32 param1;
        uint32 param2;

        (param1, param2,) = decodeParamsList(uint256(_param.value));
        bool r1 = _evalParam(_paramsHash, param1, _who, _where, _what, _how);

        if (Op(_param.op) == Op.NOT) {
            return !r1;
        }

        if (r1 && Op(_param.op) == Op.OR) {
            return true;
        }

        if (!r1 && Op(_param.op) == Op.AND) {
            return false;
        }

        bool r2 = _evalParam(_paramsHash, param2, _who, _where, _what, _how);

        if (Op(_param.op) == Op.XOR) {
            return r1 != r2;
        }

        return r2; 
    }

    function compare(uint256 _a, Op _op, uint256 _b) internal pure returns (bool) {
        if (_op == Op.EQ)  return _a == _b;                              
        if (_op == Op.NEQ) return _a != _b;                              
        if (_op == Op.GT)  return _a > _b;                               
        if (_op == Op.LT)  return _a < _b;                               
        if (_op == Op.GTE) return _a >= _b;                              
        if (_op == Op.LTE) return _a <= _b;                              
        return false;
    }

    function checkOracle(IACLOracle _oracleAddr, address _who, address _where, bytes32 _what, uint256[] _how) internal view returns (bool) {
        bytes4 sig = _oracleAddr.canPerform.selector;

        
        bytes memory checkCalldata = abi.encodeWithSelector(sig, _who, _where, _what, _how);
        uint256 oracleCheckGas = ORACLE_CHECK_GAS;

        bool ok;
        assembly {
            ok := staticcall(oracleCheckGas, _oracleAddr, add(checkCalldata, 0x20), mload(checkCalldata), 0, 0)
        }

        if (!ok) {
            return false;
        }

        uint256 size;
        assembly { size := returndatasize }
        if (size != 32) {
            return false;
        }

        bool result;
        assembly {
            let ptr := mload(0x40)       
            returndatacopy(ptr, 0, size) 
            result := mload(ptr)         
            mstore(ptr, 0)               
        }

        return result;
    }

    
    function _setPermissionManager(address _newManager, address _app, bytes32 _role) internal {
        permissionManager[roleHash(_app, _role)] = _newManager;
        emit ChangePermissionManager(_app, _role, _newManager);
    }

    function roleHash(address _where, bytes32 _what) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("ROLE", _where, _what));
    }

    function permissionHash(address _who, address _where, bytes32 _what) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("PERMISSION", _who, _where, _what));
    }
}





pragma solidity ^0.4.24;


contract APMNamehash {
    
    bytes32 internal constant APM_NODE = 0x9065c3e7f7b7ef1ef4e53d2d0b8e0cef02874ab020c1ece79d5f0d3d0111c0ba;

    function apmNamehash(string name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(APM_NODE, keccak256(bytes(name))));
    }
}



pragma solidity 0.4.24;





contract Repo is AragonApp {
    
    bytes32 public constant CREATE_VERSION_ROLE = 0x1f56cfecd3595a2e6cc1a7e6cb0b20df84cdbd92eff2fee554e70e4e45a9a7d8;

    string private constant ERROR_INVALID_BUMP = "REPO_INVALID_BUMP";
    string private constant ERROR_INVALID_VERSION = "REPO_INVALID_VERSION";
    string private constant ERROR_INEXISTENT_VERSION = "REPO_INEXISTENT_VERSION";

    struct Version {
        uint16[3] semanticVersion;
        address contractAddress;
        bytes contentURI;
    }

    uint256 internal versionsNextIndex;
    mapping (uint256 => Version) internal versions;
    mapping (bytes32 => uint256) internal versionIdForSemantic;
    mapping (address => uint256) internal latestVersionIdForContract;

    event NewVersion(uint256 versionId, uint16[3] semanticVersion);

    
    function initialize() public onlyInit {
        initialized();
        versionsNextIndex = 1;
    }

    
    function newVersion(
        uint16[3] _newSemanticVersion,
        address _contractAddress,
        bytes _contentURI
    ) public auth(CREATE_VERSION_ROLE)
    {
        address contractAddress = _contractAddress;
        uint256 lastVersionIndex = versionsNextIndex - 1;

        uint16[3] memory lastSematicVersion;

        if (lastVersionIndex > 0) {
            Version storage lastVersion = versions[lastVersionIndex];
            lastSematicVersion = lastVersion.semanticVersion;

            if (contractAddress == address(0)) {
                contractAddress = lastVersion.contractAddress;
            }
            
            require(
                lastVersion.contractAddress == contractAddress || _newSemanticVersion[0] > lastVersion.semanticVersion[0],
                ERROR_INVALID_VERSION
            );
        }

        require(isValidBump(lastSematicVersion, _newSemanticVersion), ERROR_INVALID_BUMP);

        uint256 versionId = versionsNextIndex++;
        versions[versionId] = Version(_newSemanticVersion, contractAddress, _contentURI);
        versionIdForSemantic[semanticVersionHash(_newSemanticVersion)] = versionId;
        latestVersionIdForContract[contractAddress] = versionId;

        emit NewVersion(versionId, _newSemanticVersion);
    }

    function getLatest() public view returns (uint16[3] semanticVersion, address contractAddress, bytes contentURI) {
        return getByVersionId(versionsNextIndex - 1);
    }

    function getLatestForContractAddress(address _contractAddress)
        public
        view
        returns (uint16[3] semanticVersion, address contractAddress, bytes contentURI)
    {
        return getByVersionId(latestVersionIdForContract[_contractAddress]);
    }

    function getBySemanticVersion(uint16[3] _semanticVersion)
        public
        view
        returns (uint16[3] semanticVersion, address contractAddress, bytes contentURI)
    {
        return getByVersionId(versionIdForSemantic[semanticVersionHash(_semanticVersion)]);
    }

    function getByVersionId(uint _versionId) public view returns (uint16[3] semanticVersion, address contractAddress, bytes contentURI) {
        require(_versionId > 0 && _versionId < versionsNextIndex, ERROR_INEXISTENT_VERSION);
        Version storage version = versions[_versionId];
        return (version.semanticVersion, version.contractAddress, version.contentURI);
    }

    function getVersionsCount() public view returns (uint256) {
        return versionsNextIndex - 1;
    }

    function isValidBump(uint16[3] _oldVersion, uint16[3] _newVersion) public pure returns (bool) {
        bool hasBumped;
        uint i = 0;
        while (i < 3) {
            if (hasBumped) {
                if (_newVersion[i] != 0) {
                    return false;
                }
            } else if (_newVersion[i] != _oldVersion[i]) {
                if (_oldVersion[i] > _newVersion[i] || _newVersion[i] - _oldVersion[i] != 1) {
                    return false;
                }
                hasBumped = true;
            }
            i++;
        }
        return hasBumped;
    }

    function semanticVersionHash(uint16[3] version) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(version[0], version[1], version[2]));
    }
}



pragma solidity 0.4.24;


contract KernelStorage {
    
    mapping (bytes32 => mapping (bytes32 => address)) public apps;
    bytes32 public recoveryVaultAppId;
}





pragma solidity ^0.4.24;


contract ERCProxy {
    uint256 internal constant FORWARDING = 1;
    uint256 internal constant UPGRADEABLE = 2;

    function proxyType() public pure returns (uint256 proxyTypeId);
    function implementation() public view returns (address codeAddr);
}



pragma solidity 0.4.24;




contract DelegateProxy is ERCProxy, IsContract {
    uint256 internal constant FWD_GAS_LIMIT = 10000;

    
    function delegatedFwd(address _dst, bytes _calldata) internal {
        require(isContract(_dst));
        uint256 fwdGasLimit = FWD_GAS_LIMIT;

        assembly {
            let result := delegatecall(sub(gas, fwdGasLimit), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            
            
            switch result case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}



pragma solidity 0.4.24;




contract DepositableDelegateProxy is DepositableStorage, DelegateProxy {
    event ProxyDeposit(address sender, uint256 value);

    function () external payable {
        
        if (gasleft() < FWD_GAS_LIMIT) {
            require(msg.value > 0 && msg.data.length == 0);
            require(isDepositable());
            emit ProxyDeposit(msg.sender, msg.value);
        } else { 
            address target = implementation();
            delegatedFwd(target, msg.data);
        }
    }
}



pragma solidity 0.4.24;






contract AppProxyBase is AppStorage, DepositableDelegateProxy, KernelNamespaceConstants {
    
    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public {
        setKernel(_kernel);
        setAppId(_appId);

        
        
        
        
        address appCode = getAppBase(_appId);

        
        if (_initializePayload.length > 0) {
            require(isContract(appCode));
            
            
            require(appCode.delegatecall(_initializePayload));
        }
    }

    function getAppBase(bytes32 _appId) internal view returns (address) {
        return kernel().getApp(KERNEL_APP_BASES_NAMESPACE, _appId);
    }
}



pragma solidity 0.4.24;



contract AppProxyUpgradeable is AppProxyBase {
    
    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
        AppProxyBase(_kernel, _appId, _initializePayload)
        public 
    {
        
    }

    
    function implementation() public view returns (address) {
        return getAppBase(appId());
    }

    
    function proxyType() public pure returns (uint256 proxyTypeId) {
        return UPGRADEABLE;
    }
}



pragma solidity 0.4.24;





contract AppProxyPinned is IsContract, AppProxyBase {
    using UnstructuredStorage for bytes32;

    
    bytes32 internal constant PINNED_CODE_POSITION = 0xdee64df20d65e53d7f51cb6ab6d921a0a6a638a91e942e1d8d02df28e31c038e;

    
    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
        AppProxyBase(_kernel, _appId, _initializePayload)
        public 
    {
        setPinnedCode(getAppBase(_appId));
        require(isContract(pinnedCode()));
    }

    
    function implementation() public view returns (address) {
        return pinnedCode();
    }

    
    function proxyType() public pure returns (uint256 proxyTypeId) {
        return FORWARDING;
    }

    function setPinnedCode(address _pinnedCode) internal {
        PINNED_CODE_POSITION.setStorageAddress(_pinnedCode);
    }

    function pinnedCode() internal view returns (address) {
        return PINNED_CODE_POSITION.getStorageAddress();
    }
}



pragma solidity 0.4.24;




contract AppProxyFactory {
    event NewAppProxy(address proxy, bool isUpgradeable, bytes32 appId);

    
    function newAppProxy(IKernel _kernel, bytes32 _appId) public returns (AppProxyUpgradeable) {
        return newAppProxy(_kernel, _appId, new bytes(0));
    }

    
    function newAppProxy(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public returns (AppProxyUpgradeable) {
        AppProxyUpgradeable proxy = new AppProxyUpgradeable(_kernel, _appId, _initializePayload);
        emit NewAppProxy(address(proxy), true, _appId);
        return proxy;
    }

    
    function newAppProxyPinned(IKernel _kernel, bytes32 _appId) public returns (AppProxyPinned) {
        return newAppProxyPinned(_kernel, _appId, new bytes(0));
    }

    
    function newAppProxyPinned(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public returns (AppProxyPinned) {
        AppProxyPinned proxy = new AppProxyPinned(_kernel, _appId, _initializePayload);
        emit NewAppProxy(address(proxy), false, _appId);
        return proxy;
    }
}



pragma solidity 0.4.24;














contract Kernel is IKernel, KernelStorage, KernelAppIds, KernelNamespaceConstants, Petrifiable, IsContract, VaultRecoverable, AppProxyFactory, ACLSyntaxSugar {
    
    bytes32 public constant APP_MANAGER_ROLE = 0xb6d92708f3d4817afc106147d969e229ced5c46e65e0a5002a0d391287762bd0;

    string private constant ERROR_APP_NOT_CONTRACT = "KERNEL_APP_NOT_CONTRACT";
    string private constant ERROR_INVALID_APP_CHANGE = "KERNEL_INVALID_APP_CHANGE";
    string private constant ERROR_AUTH_FAILED = "KERNEL_AUTH_FAILED";

    
    constructor(bool _shouldPetrify) public {
        if (_shouldPetrify) {
            petrify();
        }
    }

    
    function initialize(IACL _baseAcl, address _permissionsCreator) public onlyInit {
        initialized();

        
        _setApp(KERNEL_APP_BASES_NAMESPACE, KERNEL_DEFAULT_ACL_APP_ID, _baseAcl);

        
        IACL acl = IACL(newAppProxy(this, KERNEL_DEFAULT_ACL_APP_ID));
        acl.initialize(_permissionsCreator);
        _setApp(KERNEL_APP_ADDR_NAMESPACE, KERNEL_DEFAULT_ACL_APP_ID, acl);

        recoveryVaultAppId = KERNEL_DEFAULT_VAULT_APP_ID;
    }

    
    function newAppInstance(bytes32 _appId, address _appBase)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_BASES_NAMESPACE, _appId))
        returns (ERCProxy appProxy)
    {
        return newAppInstance(_appId, _appBase, new bytes(0), false);
    }

    
    function newAppInstance(bytes32 _appId, address _appBase, bytes _initializePayload, bool _setDefault)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_BASES_NAMESPACE, _appId))
        returns (ERCProxy appProxy)
    {
        _setAppIfNew(KERNEL_APP_BASES_NAMESPACE, _appId, _appBase);
        appProxy = newAppProxy(this, _appId, _initializePayload);
        
        
        if (_setDefault) {
            setApp(KERNEL_APP_ADDR_NAMESPACE, _appId, appProxy);
        }
    }

    
    function newPinnedAppInstance(bytes32 _appId, address _appBase)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_BASES_NAMESPACE, _appId))
        returns (ERCProxy appProxy)
    {
        return newPinnedAppInstance(_appId, _appBase, new bytes(0), false);
    }

    
    function newPinnedAppInstance(bytes32 _appId, address _appBase, bytes _initializePayload, bool _setDefault)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_BASES_NAMESPACE, _appId))
        returns (ERCProxy appProxy)
    {
        _setAppIfNew(KERNEL_APP_BASES_NAMESPACE, _appId, _appBase);
        appProxy = newAppProxyPinned(this, _appId, _initializePayload);
        
        
        if (_setDefault) {
            setApp(KERNEL_APP_ADDR_NAMESPACE, _appId, appProxy);
        }
    }

    
    function setApp(bytes32 _namespace, bytes32 _appId, address _app)
        public
        auth(APP_MANAGER_ROLE, arr(_namespace, _appId))
    {
        _setApp(_namespace, _appId, _app);
    }

    
    function setRecoveryVaultAppId(bytes32 _recoveryVaultAppId)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_ADDR_NAMESPACE, _recoveryVaultAppId))
    {
        recoveryVaultAppId = _recoveryVaultAppId;
    }

    
    
    function CORE_NAMESPACE() external pure returns (bytes32) { return KERNEL_CORE_NAMESPACE; }
    function APP_BASES_NAMESPACE() external pure returns (bytes32) { return KERNEL_APP_BASES_NAMESPACE; }
    function APP_ADDR_NAMESPACE() external pure returns (bytes32) { return KERNEL_APP_ADDR_NAMESPACE; }
    function KERNEL_APP_ID() external pure returns (bytes32) { return KERNEL_CORE_APP_ID; }
    function DEFAULT_ACL_APP_ID() external pure returns (bytes32) { return KERNEL_DEFAULT_ACL_APP_ID; }
    

    
    function getApp(bytes32 _namespace, bytes32 _appId) public view returns (address) {
        return apps[_namespace][_appId];
    }

    
    function getRecoveryVault() public view returns (address) {
        return apps[KERNEL_APP_ADDR_NAMESPACE][recoveryVaultAppId];
    }

    
    function acl() public view returns (IACL) {
        return IACL(getApp(KERNEL_APP_ADDR_NAMESPACE, KERNEL_DEFAULT_ACL_APP_ID));
    }

    
    function hasPermission(address _who, address _where, bytes32 _what, bytes _how) public view returns (bool) {
        IACL defaultAcl = acl();
        return address(defaultAcl) != address(0) && 
            defaultAcl.hasPermission(_who, _where, _what, _how);
    }

    function _setApp(bytes32 _namespace, bytes32 _appId, address _app) internal {
        require(isContract(_app), ERROR_APP_NOT_CONTRACT);
        apps[_namespace][_appId] = _app;
        emit SetApp(_namespace, _appId, _app);
    }

    function _setAppIfNew(bytes32 _namespace, bytes32 _appId, address _app) internal {
        address app = getApp(_namespace, _appId);
        if (app != address(0)) {
            
            require(app == _app, ERROR_INVALID_APP_CHANGE);
        } else {
            _setApp(_namespace, _appId, _app);
        }
    }

    modifier auth(bytes32 _role, uint256[] memory _params) {
        require(
            hasPermission(msg.sender, address(this), _role, ConversionHelpers.dangerouslyCastUintArrayToBytes(_params)),
            ERROR_AUTH_FAILED
        );
        _;
    }
}



pragma solidity 0.4.24;







contract KernelProxy is IKernelEvents, KernelStorage, KernelAppIds, KernelNamespaceConstants, IsContract, DepositableDelegateProxy {
    
    constructor(IKernel _kernelImpl) public {
        require(isContract(address(_kernelImpl)));
        apps[KERNEL_CORE_NAMESPACE][KERNEL_CORE_APP_ID] = _kernelImpl;

        
        
        
        
        emit SetApp(KERNEL_CORE_NAMESPACE, KERNEL_CORE_APP_ID, _kernelImpl);
    }

    
    function proxyType() public pure returns (uint256 proxyTypeId) {
        return UPGRADEABLE;
    }

    
    function implementation() public view returns (address) {
        return apps[KERNEL_CORE_NAMESPACE][KERNEL_CORE_APP_ID];
    }
}





pragma solidity ^0.4.24;


library ScriptHelpers {
    function getSpecId(bytes _script) internal pure returns (uint32) {
        return uint32At(_script, 0);
    }

    function uint256At(bytes _data, uint256 _location) internal pure returns (uint256 result) {
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
}



pragma solidity 0.4.24;








contract EVMScriptRegistry is IEVMScriptRegistry, EVMScriptRegistryConstants, AragonApp {
    using ScriptHelpers for bytes;

    
    bytes32 public constant REGISTRY_ADD_EXECUTOR_ROLE = 0xc4e90f38eea8c4212a009ca7b8947943ba4d4a58d19b683417f65291d1cd9ed2;
    
    bytes32 public constant REGISTRY_MANAGER_ROLE = 0xf7a450ef335e1892cb42c8ca72e7242359d7711924b75db5717410da3f614aa3;

    uint256 internal constant SCRIPT_START_LOCATION = 4;

    string private constant ERROR_INEXISTENT_EXECUTOR = "EVMREG_INEXISTENT_EXECUTOR";
    string private constant ERROR_EXECUTOR_ENABLED = "EVMREG_EXECUTOR_ENABLED";
    string private constant ERROR_EXECUTOR_DISABLED = "EVMREG_EXECUTOR_DISABLED";
    string private constant ERROR_SCRIPT_LENGTH_TOO_SHORT = "EVMREG_SCRIPT_LENGTH_TOO_SHORT";

    struct ExecutorEntry {
        IEVMScriptExecutor executor;
        bool enabled;
    }

    uint256 private executorsNextIndex;
    mapping (uint256 => ExecutorEntry) public executors;

    event EnableExecutor(uint256 indexed executorId, address indexed executorAddress);
    event DisableExecutor(uint256 indexed executorId, address indexed executorAddress);

    modifier executorExists(uint256 _executorId) {
        require(_executorId > 0 && _executorId < executorsNextIndex, ERROR_INEXISTENT_EXECUTOR);
        _;
    }

    
    function initialize() public onlyInit {
        initialized();
        
        executorsNextIndex = 1;
    }

    
    function addScriptExecutor(IEVMScriptExecutor _executor) external auth(REGISTRY_ADD_EXECUTOR_ROLE) returns (uint256 id) {
        uint256 executorId = executorsNextIndex++;
        executors[executorId] = ExecutorEntry(_executor, true);
        emit EnableExecutor(executorId, _executor);
        return executorId;
    }

    
    function disableScriptExecutor(uint256 _executorId)
        external
        authP(REGISTRY_MANAGER_ROLE, arr(_executorId))
    {
        
        
        ExecutorEntry storage executorEntry = executors[_executorId];
        require(executorEntry.enabled, ERROR_EXECUTOR_DISABLED);
        executorEntry.enabled = false;
        emit DisableExecutor(_executorId, executorEntry.executor);
    }

    
    function enableScriptExecutor(uint256 _executorId)
        external
        authP(REGISTRY_MANAGER_ROLE, arr(_executorId))
        executorExists(_executorId)
    {
        ExecutorEntry storage executorEntry = executors[_executorId];
        require(!executorEntry.enabled, ERROR_EXECUTOR_ENABLED);
        executorEntry.enabled = true;
        emit EnableExecutor(_executorId, executorEntry.executor);
    }

    
    function getScriptExecutor(bytes _script) public view returns (IEVMScriptExecutor) {
        require(_script.length >= SCRIPT_START_LOCATION, ERROR_SCRIPT_LENGTH_TOO_SHORT);
        uint256 id = _script.getSpecId();

        
        
        ExecutorEntry storage entry = executors[id];
        return entry.enabled ? entry.executor : IEVMScriptExecutor(0);
    }
}





pragma solidity ^0.4.24;




contract BaseEVMScriptExecutor is IEVMScriptExecutor, Autopetrified {
    uint256 internal constant SCRIPT_START_LOCATION = 4;
}



pragma solidity 0.4.24;






contract CallsScript is BaseEVMScriptExecutor {
    using ScriptHelpers for bytes;

    
    bytes32 internal constant EXECUTOR_TYPE = 0x2dc858a00f3e417be1394b87c07158e989ec681ce8cc68a9093680ac1a870302;

    string private constant ERROR_BLACKLISTED_CALL = "EVMCALLS_BLACKLISTED_CALL";
    string private constant ERROR_INVALID_LENGTH = "EVMCALLS_INVALID_LENGTH";

    

    event LogScriptCall(address indexed sender, address indexed src, address indexed dst);

    
    function execScript(bytes _script, bytes, address[] _blacklist) external isInitialized returns (bytes) {
        uint256 location = SCRIPT_START_LOCATION; 
        while (location < _script.length) {
            
            require(_script.length - location >= 0x18, ERROR_INVALID_LENGTH);

            address contractAddress = _script.addressAt(location);
            
            for (uint256 i = 0; i < _blacklist.length; i++) {
                require(contractAddress != _blacklist[i], ERROR_BLACKLISTED_CALL);
            }

            
            
            emit LogScriptCall(msg.sender, address(this), contractAddress);

            uint256 calldataLength = uint256(_script.uint32At(location + 0x14));
            uint256 startOffset = location + 0x14 + 0x04;
            uint256 calldataStart = _script.locationOf(startOffset);

            
            location = startOffset + calldataLength;
            require(location <= _script.length, ERROR_INVALID_LENGTH);

            bool success;
            assembly {
                success := call(
                    sub(gas, 5000),       
                    contractAddress,      
                    0,                    
                    calldataStart,        
                    calldataLength,       
                    0,                    
                    0                     
                )

                switch success
                case 0 {
                    let ptr := mload(0x40)

                    switch returndatasize
                    case 0 {
                        
                        
                        
                        mstore(ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000)         
                        mstore(add(ptr, 0x04), 0x0000000000000000000000000000000000000000000000000000000000000020) 
                        mstore(add(ptr, 0x24), 0x0000000000000000000000000000000000000000000000000000000000000016) 
                        mstore(add(ptr, 0x44), 0x45564d43414c4c535f43414c4c5f524556455254454400000000000000000000) 

                        revert(ptr, 100) 
                    }
                    default {
                        
                        returndatacopy(ptr, 0, returndatasize)
                        revert(ptr, returndatasize)
                    }
                }
                default { }
            }
        }
        
        
    }

    function executorType() external pure returns (bytes32) {
        return EXECUTOR_TYPE;
    }
}



pragma solidity 0.4.24;







contract EVMScriptRegistryFactory is EVMScriptRegistryConstants {
    EVMScriptRegistry public baseReg;
    IEVMScriptExecutor public baseCallScript;

    
    constructor() public {
        baseReg = new EVMScriptRegistry();
        baseCallScript = IEVMScriptExecutor(new CallsScript());
    }

    
    function newEVMScriptRegistry(Kernel _dao) public returns (EVMScriptRegistry reg) {
        bytes memory initPayload = abi.encodeWithSelector(reg.initialize.selector);
        reg = EVMScriptRegistry(_dao.newPinnedAppInstance(EVMSCRIPT_REGISTRY_APP_ID, baseReg, initPayload, true));

        ACL acl = ACL(_dao.acl());

        acl.createPermission(this, reg, reg.REGISTRY_ADD_EXECUTOR_ROLE(), this);

        reg.addScriptExecutor(baseCallScript);     

        
        acl.revokePermission(this, reg, reg.REGISTRY_ADD_EXECUTOR_ROLE());
        acl.removePermissionManager(reg, reg.REGISTRY_ADD_EXECUTOR_ROLE());

        return reg;
    }
}



pragma solidity 0.4.24;








contract DAOFactory {
    IKernel public baseKernel;
    IACL public baseACL;
    EVMScriptRegistryFactory public regFactory;

    event DeployDAO(address dao);
    event DeployEVMScriptRegistry(address reg);

    
    constructor(IKernel _baseKernel, IACL _baseACL, EVMScriptRegistryFactory _regFactory) public {
        
        if (address(_regFactory) != address(0)) {
            regFactory = _regFactory;
        }

        baseKernel = _baseKernel;
        baseACL = _baseACL;
    }

    
    function newDAO(address _root) public returns (Kernel) {
        Kernel dao = Kernel(new KernelProxy(baseKernel));

        if (address(regFactory) == address(0)) {
            dao.initialize(baseACL, _root);
        } else {
            dao.initialize(baseACL, this);

            ACL acl = ACL(dao.acl());
            bytes32 permRole = acl.CREATE_PERMISSIONS_ROLE();
            bytes32 appManagerRole = dao.APP_MANAGER_ROLE();

            acl.grantPermission(regFactory, acl, permRole);

            acl.createPermission(regFactory, dao, appManagerRole, this);

            EVMScriptRegistry reg = regFactory.newEVMScriptRegistry(dao);
            emit DeployEVMScriptRegistry(address(reg));

            
            
            acl.revokePermission(regFactory, dao, appManagerRole);
            acl.removePermissionManager(dao, appManagerRole);

            
            acl.revokePermission(regFactory, acl, permRole);
            acl.revokePermission(this, acl, permRole);
            acl.grantPermission(_root, acl, permRole);
            acl.setPermissionManager(_root, acl, permRole);
        }

        emit DeployDAO(address(dao));

        return dao;
    }
}





pragma solidity ^0.4.15;


interface AbstractENS {
    function owner(bytes32 _node) public constant returns (address);
    function resolver(bytes32 _node) public constant returns (address);
    function ttl(bytes32 _node) public constant returns (uint64);
    function setOwner(bytes32 _node, address _owner) public;
    function setSubnodeOwner(bytes32 _node, bytes32 label, address _owner) public;
    function setResolver(bytes32 _node, address _resolver) public;
    function setTTL(bytes32 _node, uint64 _ttl) public;

    
    event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);

    
    event Transfer(bytes32 indexed _node, address _owner);

    
    event NewResolver(bytes32 indexed _node, address _resolver);

    
    event NewTTL(bytes32 indexed _node, uint64 _ttl);
}





pragma solidity ^0.4.0;



contract ENS is AbstractENS {
    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping(bytes32=>Record) records;

    
    modifier only_owner(bytes32 node) {
        if (records[node].owner != msg.sender) throw;
        _;
    }

    
    function ENS() public {
        records[0].owner = msg.sender;
    }

    
    function owner(bytes32 node) public constant returns (address) {
        return records[node].owner;
    }

    
    function resolver(bytes32 node) public constant returns (address) {
        return records[node].resolver;
    }

    
    function ttl(bytes32 node) public constant returns (uint64) {
        return records[node].ttl;
    }

    
    function setOwner(bytes32 node, address owner) only_owner(node) public {
        Transfer(node, owner);
        records[node].owner = owner;
    }

    
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) only_owner(node) public {
        var subnode = keccak256(node, label);
        NewOwner(node, label, owner);
        records[subnode].owner = owner;
    }

    
    function setResolver(bytes32 node, address resolver) only_owner(node) public {
        NewResolver(node, resolver);
        records[node].resolver = resolver;
    }

    
    function setTTL(bytes32 node, uint64 ttl) only_owner(node) public {
        NewTTL(node, ttl);
        records[node].ttl = ttl;
    }
}





pragma solidity ^0.4.0;



contract PublicResolver {
    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;
    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant CONTENT_INTERFACE_ID = 0xd8389dc5;
    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;
    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;
    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;
    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;

    event AddrChanged(bytes32 indexed node, address a);
    event ContentChanged(bytes32 indexed node, bytes32 hash);
    event NameChanged(bytes32 indexed node, string name);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);

    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    struct Record {
        address addr;
        bytes32 content;
        string name;
        PublicKey pubkey;
        mapping(string=>string) text;
        mapping(uint256=>bytes) abis;
    }

    AbstractENS ens;
    mapping(bytes32=>Record) records;

    modifier only_owner(bytes32 node) {
        if (ens.owner(node) != msg.sender) throw;
        _;
    }

    
    function PublicResolver(AbstractENS ensAddr) public {
        ens = ensAddr;
    }

    
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == ADDR_INTERFACE_ID ||
               interfaceID == CONTENT_INTERFACE_ID ||
               interfaceID == NAME_INTERFACE_ID ||
               interfaceID == ABI_INTERFACE_ID ||
               interfaceID == PUBKEY_INTERFACE_ID ||
               interfaceID == TEXT_INTERFACE_ID ||
               interfaceID == INTERFACE_META_ID;
    }

    
    function addr(bytes32 node) public constant returns (address ret) {
        ret = records[node].addr;
    }

    
    function setAddr(bytes32 node, address addr) only_owner(node) public {
        records[node].addr = addr;
        AddrChanged(node, addr);
    }

    
    function content(bytes32 node) public constant returns (bytes32 ret) {
        ret = records[node].content;
    }

    
    function setContent(bytes32 node, bytes32 hash) only_owner(node) public {
        records[node].content = hash;
        ContentChanged(node, hash);
    }

    
    function name(bytes32 node) public constant returns (string ret) {
        ret = records[node].name;
    }

    
    function setName(bytes32 node, string name) only_owner(node) public {
        records[node].name = name;
        NameChanged(node, name);
    }

    
    function ABI(bytes32 node, uint256 contentTypes) public constant returns (uint256 contentType, bytes data) {
        var record = records[node];
        for(contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {
                data = record.abis[contentType];
                return;
            }
        }
        contentType = 0;
    }

    
    function setABI(bytes32 node, uint256 contentType, bytes data) only_owner(node) public {
        
        if (((contentType - 1) & contentType) != 0) throw;

        records[node].abis[contentType] = data;
        ABIChanged(node, contentType);
    }

    
    function pubkey(bytes32 node) public constant returns (bytes32 x, bytes32 y) {
        return (records[node].pubkey.x, records[node].pubkey.y);
    }

    
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) only_owner(node) public {
        records[node].pubkey = PublicKey(x, y);
        PubkeyChanged(node, x, y);
    }

    
    function text(bytes32 node, string key) public constant returns (string ret) {
        ret = records[node].text[key];
    }

    
    function setText(bytes32 node, string key, string value) only_owner(node) public {
        records[node].text[key] = value;
        TextChanged(node, key, key);
    }
}







pragma solidity 0.4.24;


interface ITransferOracle {
    function getTransferability(address _from, address _to, uint256 _amount) external returns (bool);
}


contract WhitelistOracle is AragonApp, ITransferOracle {

    

    bytes32 public constant ADD_SENDER_ROLE = 0x649896fce4266201ed0200f1f18d2316c4c0be48c949b18cccd5ef15621249e3;
    bytes32 public constant REMOVE_SENDER_ROLE = 0x9d7a040f5c6540f643d8a175f70736671ffabd35f3de2e4176cfcbbe9cd71acb;

    string private constant ERROR_SENDER_ALREADY_ADDED = "WO_ERROR_SENDER_ALREADY_ADDED";
    string private constant ERROR_SENDER_NOT_EXIST = "WO_ERROR_SENDER_NOT_EXIST";
    event ValidSenderAdded(address _sender);
    event ValidSenderRemoved(address _sender);

    mapping(address => bool) validSender;

    function initialize(address[] _senders) external onlyInit {
        initialized();
        for (uint256 i = 0; i < _senders.length; i++) {
            validSender[_senders[i]] = true;
        }
    }

    function addSender(address _sender) external auth(ADD_SENDER_ROLE) {
        require(!validSender[_sender], ERROR_SENDER_ALREADY_ADDED);
        validSender[_sender] = true;
        emit ValidSenderAdded(_sender);
    }

    function removeSender(address _sender) external auth(REMOVE_SENDER_ROLE) {
        require(validSender[_sender], ERROR_SENDER_NOT_EXIST);
        validSender[_sender] = false;
        emit ValidSenderRemoved(_sender);
    }

    function getTransferability(address _from, address , uint256 ) external returns (bool) {
        return validSender[_from];
    }

}







pragma solidity 0.4.24;








contract TokenManager is ITokenController, IForwarder, AragonApp {
    using SafeMath for uint256;
    
    bytes32 public constant MINT_ROLE = 0x154c00819833dac601ee5ddded6fda79d9d8b506b911b3dbd54cdb95fe6c3686;
    bytes32 public constant ISSUE_ROLE = 0x2406f1e99f79cea012fb88c5c36566feaeefee0f4b98d3a376b49310222b53c4;
    bytes32 public constant ASSIGN_ROLE = 0xf5a08927c847d7a29dc35e105208dbde5ce951392105d712761cc5d17440e2ff;
    bytes32 public constant REVOKE_VESTINGS_ROLE = 0x95ffc68daedf1eb334cfcd22ee24a5eeb5a8e58aa40679f2ad247a84140f8d6e;
    bytes32 public constant BURN_ROLE = 0xe97b137254058bd94f28d2f3eb79e2d34074ffb488d042e3bc958e0a57d2fa22;
    bytes32 public constant SET_ORACLE = 0x11eba3f259e2be865238d718fd308257e3874ad4b3a642ea3af386a4eea190bd;

    uint256 public constant MAX_VESTINGS_PER_ADDRESS = 50;

    string private constant ERROR_CALLER_NOT_TOKEN = "TM_CALLER_NOT_TOKEN";
    string private constant ERROR_NO_VESTING = "TM_NO_VESTING";
    string private constant ERROR_TOKEN_CONTROLLER = "TM_TOKEN_CONTROLLER";
    string private constant ERROR_MINT_RECEIVER_IS_TM = "TM_MINT_RECEIVER_IS_TM";
    string private constant ERROR_VESTING_TO_TM = "TM_VESTING_TO_TM";
    string private constant ERROR_TOO_MANY_VESTINGS = "TM_TOO_MANY_VESTINGS";
    string private constant ERROR_WRONG_CLIFF_DATE = "TM_WRONG_CLIFF_DATE";
    string private constant ERROR_VESTING_NOT_REVOKABLE = "TM_VESTING_NOT_REVOKABLE";
    string private constant ERROR_REVOKE_TRANSFER_FROM_REVERTED = "TM_REVOKE_TRANSFER_FROM_REVERTED";
    string private constant ERROR_CAN_NOT_FORWARD = "TM_CAN_NOT_FORWARD";
    string private constant ERROR_BALANCE_INCREASE_NOT_ALLOWED = "TM_BALANCE_INC_NOT_ALLOWED";
    string private constant ERROR_ASSIGN_TRANSFER_FROM_REVERTED = "TM_ASSIGN_TRANSFER_FROM_REVERTED";

    struct TokenVesting {
        uint256 amount;
        uint64 start;
        uint64 cliff;
        uint64 vesting;
        bool revokable;
    }

    
    MiniMeToken public token;
    ITransferOracle public oracle;
    uint256 public maxAccountTokens;

    
    mapping (address => mapping (uint256 => TokenVesting)) internal vestings;
    mapping (address => uint256) public vestingsLengths;

    
    event NewVesting(address indexed receiver, uint256 vestingId, uint256 amount);
    event RevokeVesting(address indexed receiver, uint256 vestingId, uint256 nonVestedAmount);

    modifier onlyToken() {
        require(msg.sender == address(token), ERROR_CALLER_NOT_TOKEN);
        _;
    }

    modifier vestingExists(address _holder, uint256 _vestingId) {
        require(_vestingId < vestingsLengths[_holder], ERROR_NO_VESTING);
        require(vestings[_holder][_vestingId].amount != 0, ERROR_NO_VESTING);
        _;
    }

    
    function initialize(
        MiniMeToken _token,
        bool _transferable,
        uint256 _maxAccountTokens
    )
        external
        onlyInit
    {
        initialized();

        require(_token.controller() == address(this), ERROR_TOKEN_CONTROLLER);

        token = _token;
        maxAccountTokens = _maxAccountTokens == 0 ? uint256(-1) : _maxAccountTokens;

        if (token.transfersEnabled() != _transferable) {
            token.enableTransfers(_transferable);
        }
    }

    function setOracle(address _oracle) external auth(SET_ORACLE) {
        oracle = ITransferOracle(_oracle);
    }

    
    function mint(address _receiver, uint256 _amount) external authP(MINT_ROLE, arr(_receiver, _amount)) {
        require(_receiver != address(this), ERROR_MINT_RECEIVER_IS_TM);
        _mint(_receiver, _amount);
    }

    
    function issue(uint256 _amount) external authP(ISSUE_ROLE, arr(_amount)) {
        _mint(address(this), _amount);
    }

    
    function assign(address _receiver, uint256 _amount) external authP(ASSIGN_ROLE, arr(_receiver, _amount)) {
        _assign(_receiver, _amount);
    }

    
    function burn(address _holder, uint256 _amount) external authP(BURN_ROLE, arr(_holder, _amount)) {
        
        token.destroyTokens(_holder, _amount);
    }

    
    function assignVested(
        address _receiver,
        uint256 _amount,
        uint64 _start,
        uint64 _cliff,
        uint64 _vested,
        bool _revokable
    )
        external
        authP(ASSIGN_ROLE, arr(_receiver, _amount))
        returns (uint256)
    {
        require(_receiver != address(this), ERROR_VESTING_TO_TM);
        require(vestingsLengths[_receiver] < MAX_VESTINGS_PER_ADDRESS, ERROR_TOO_MANY_VESTINGS);
        require(_start <= _cliff && _cliff <= _vested, ERROR_WRONG_CLIFF_DATE);

        uint256 vestingId = vestingsLengths[_receiver]++;
        vestings[_receiver][vestingId] = TokenVesting({
            amount: _amount,
            start: _start,
            cliff: _cliff,
            vesting: _vested,
            revokable: _revokable
        });

        _assign(_receiver, _amount);

        emit NewVesting(_receiver, vestingId, _amount);

        return vestingId;
    }

    
    function revokeVesting(address _holder, uint256 _vestingId)
        external
        authP(REVOKE_VESTINGS_ROLE, arr(_holder))
        vestingExists(_holder, _vestingId)
    {
        TokenVesting memory v = vestings[_holder][_vestingId];
        require(v.revokable, ERROR_VESTING_NOT_REVOKABLE);

        uint256 nonVested = _calculateNonVestedTokens(
            v.amount,
            getTimestamp(),
            v.start,
            v.cliff,
            v.vesting
        );

        
        
        delete vestings[_holder][_vestingId];

        
        
        require(token.transferFrom(_holder, address(this), nonVested), ERROR_REVOKE_TRANSFER_FROM_REVERTED);

        emit RevokeVesting(_holder, _vestingId, nonVested);
    }

    
    
    
    

    
    function onTransfer(address _from, address _to, uint256 _amount) external onlyToken returns (bool) {
        bool transferability = true;
        if (_from != address(this) && address(oracle) != address(0x0)) {
            transferability = oracle.getTransferability(_from, _to, _amount);
        }
        bool balanceIncreaseAllowed = _isBalanceIncreaseAllowed(_to, _amount) && _transferableBalance(_from, getTimestamp()) >= _amount;
        return transferability && balanceIncreaseAllowed;
    }

    
    function onApprove(address, address, uint) external onlyToken returns (bool) {
        return true;
    }

    
    function proxyPayment(address) external payable onlyToken returns (bool) {
        return false;
    }

    

    function isForwarder() external pure returns (bool) {
        return true;
    }

    
    function forward(bytes _evmScript) public {
        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);
        bytes memory input = new bytes(0); 

        
        
        address[] memory blacklist = new address[](1);
        blacklist[0] = address(token);

        runScript(_evmScript, input, blacklist);
    }

    function canForward(address _sender, bytes) public view returns (bool) {
        return hasInitialized() && token.balanceOf(_sender) > 0;
    }

    

    function getVesting(
        address _recipient,
        uint256 _vestingId
    )
        public
        view
        vestingExists(_recipient, _vestingId)
        returns (
            uint256 amount,
            uint64 start,
            uint64 cliff,
            uint64 vesting,
            bool revokable
        )
    {
        TokenVesting memory tokenVesting = vestings[_recipient][_vestingId];
        amount = tokenVesting.amount;
        start = tokenVesting.start;
        cliff = tokenVesting.cliff;
        vesting = tokenVesting.vesting;
        revokable = tokenVesting.revokable;
    }

    function spendableBalanceOf(address _holder) public view isInitialized returns (uint256) {
        return _transferableBalance(_holder, getTimestamp());
    }

    function transferableBalance(address _holder, uint256 _time) public view isInitialized returns (uint256) {
        return _transferableBalance(_holder, _time);
    }

    
    function allowRecoverability(address _token) public view returns (bool) {
        return _token != address(token);
    }

    

    function _assign(address _receiver, uint256 _amount) internal {
        require(_isBalanceIncreaseAllowed(_receiver, _amount), ERROR_BALANCE_INCREASE_NOT_ALLOWED);
        
        require(token.transferFrom(address(this), _receiver, _amount), ERROR_ASSIGN_TRANSFER_FROM_REVERTED);
    }

    function _mint(address _receiver, uint256 _amount) internal {
        require(_isBalanceIncreaseAllowed(_receiver, _amount), ERROR_BALANCE_INCREASE_NOT_ALLOWED);
        token.generateTokens(_receiver, _amount); 
    }

    function _isBalanceIncreaseAllowed(address _receiver, uint256 _inc) internal view returns (bool) {
        
        if (_receiver == address(this)) {
            return true;
        }
        return token.balanceOf(_receiver).add(_inc) <= maxAccountTokens;
    }

    
    function _calculateNonVestedTokens(
        uint256 tokens,
        uint256 time,
        uint256 start,
        uint256 cliff,
        uint256 vested
    )
        private
        pure
        returns (uint256)
    {
        
        if (time >= vested) {
            return 0;
        }
        if (time < cliff) {
            return tokens;
        }

        
        
        

        
        
        
        
        uint256 vestedTokens = tokens.mul(time.sub(start)) / vested.sub(start);

        
        return tokens.sub(vestedTokens);
    }

    function _transferableBalance(address _holder, uint256 _time) internal view returns (uint256) {
        uint256 transferable = token.balanceOf(_holder);

        
        
        
        
        
        if (_holder != address(this)) {
            uint256 vestingsCount = vestingsLengths[_holder];
            for (uint256 i = 0; i < vestingsCount; i++) {
                TokenVesting memory v = vestings[_holder][i];
                uint256 nonTransferable = _calculateNonVestedTokens(
                    v.amount,
                    _time,
                    v.start,
                    v.cliff,
                    v.vesting
                );
                transferable = transferable.sub(nonTransferable);
            }
        }

        return transferable;
    }
}



pragma solidity 0.4.24;























contract BaseTemplate is APMNamehash, IsContract {
    using Uint256Helpers for uint256;


    
    
    
    
    
    
    
    
    bytes32 constant internal AGENT_APP_ID = 0x9ac98dc5f995bf0211ed589ef022719d1487e5cb2bab505676f0d084c07cf89a;
    bytes32 constant internal FINANCE_APP_ID = 0xbf8491150dafc5dcaee5b861414dca922de09ccffa344964ae167212e8c673ae;
    bytes32 constant internal PAYROLL_APP_ID = 0x463f596a96d808cb28b5d080181e4a398bc793df2c222f6445189eb801001991;
    bytes32 constant internal SURVEY_APP_ID = 0x030b2ab880b88e228f2da5a3d19a2a31bc10dbf91fb1143776a6de489389471e;
    bytes32 constant internal TOKEN_MANAGER_APP_ID = 0xc568f11b5218b4d75fdc69c471ebdcffcb59025cc9119abfb35ed6d0efcbc4ff;
    bytes32 constant internal VAULT_APP_ID = 0x7e852e0fcfce6551c13800f1e7476f982525c2b5277ba14b24339c68416336d1;
    bytes32 constant internal VOTING_APP_ID = 0x9fa3927f639745e587912d4b0fea7ef9013bf93fb907d29faeab57417ba6e1d4;
    bytes32 constant internal WHITELIST_ORACLE_APP_ID = 0x32ceb944f61770acf9d24fe42fd7ad630d08049a3b80b1475b120ab23569ba92;

    string constant private ERROR_ARAGON_ID_NOT_CONTRACT = "TEMPLATE_ARAGON_ID_NOT_CONTRACT";
    string constant private ERROR_ARAGON_ID_NOT_PROVIDED = "TEMPLATE_ARAGON_ID_NOT_PROVIDED";
    string constant private ERROR_CANNOT_CAST_VALUE_TO_ADDRESS = "TEMPLATE_CANNOT_CAST_VALUE_TO_ADDRESS";
    string constant private ERROR_DAO_FACTORY_NOT_CONTRACT = "TEMPLATE_DAO_FAC_NOT_CONTRACT";
    string constant private ERROR_ENS_NOT_CONTRACT = "TEMPLATE_ENS_NOT_CONTRACT";
    string constant private ERROR_INVALID_ID = "TEMPLATE_INVALID_ID";
    string constant private ERROR_MINIME_FACTORY_NOT_CONTRACT = "TEMPLATE_MINIME_FAC_NOT_CONTRACT";
    string constant private ERROR_MINIME_FACTORY_NOT_PROVIDED = "TEMPLATE_MINIME_FAC_NOT_PROVIDED";

    DAOFactory internal daoFactory;
    ENS internal ens;
    IFIFSResolvingRegistrar internal aragonID;
    MiniMeTokenFactory internal miniMeFactory;

    event DeployDao(address dao);
    event DeployToken(address token);
    event InstalledApp(address appProxy, bytes32 appId);
    event SetupDao(address dao);

    constructor(DAOFactory _daoFactory, ENS _ens, MiniMeTokenFactory _miniMeFactory, IFIFSResolvingRegistrar _aragonID) public {
        require(isContract(address(_daoFactory)), ERROR_DAO_FACTORY_NOT_CONTRACT);
        require(isContract(address(_ens)), ERROR_ENS_NOT_CONTRACT);

        aragonID = _aragonID;
        daoFactory = _daoFactory;
        ens = _ens;
        miniMeFactory = _miniMeFactory;
    }

    
    function _createDAO() internal returns (Kernel dao, ACL acl) {
        dao = daoFactory.newDAO(this);
        emit DeployDao(address(dao));
        acl = ACL(dao.acl());
        _createPermissionForTemplate(acl, dao, dao.APP_MANAGER_ROLE());
    }

    

    function _createPermissions(ACL _acl, address[] memory _grantees, address _app, bytes32 _permission, address _manager) internal {
        _acl.createPermission(_grantees[0], _app, _permission, address(this));
        for (uint256 i = 1; i < _grantees.length; i++) {
            _acl.grantPermission(_grantees[i], _app, _permission);
        }
        _acl.revokePermission(address(this), _app, _permission);
        _acl.setPermissionManager(_manager, _app, _permission);
    }

    function _createPermissionForTemplate(ACL _acl, address _app, bytes32 _permission) internal {
        _acl.createPermission(address(this), _app, _permission, address(this));
    }

    function _removePermissionFromTemplate(ACL _acl, address _app, bytes32 _permission) internal {
        _acl.revokePermission(address(this), _app, _permission);
        _acl.removePermissionManager(_app, _permission);
    }

    function _transferRootPermissionsFromTemplateAndFinalizeDAO(Kernel _dao, address _to) internal {
        _transferRootPermissionsFromTemplateAndFinalizeDAO(_dao, _to, _to);
    }

    function _transferRootPermissionsFromTemplateAndFinalizeDAO(Kernel _dao, address _to, address _manager) internal {
        ACL _acl = ACL(_dao.acl());
        _transferPermissionFromTemplate(_acl, _dao, _to, _dao.APP_MANAGER_ROLE(), _manager);
        _transferPermissionFromTemplate(_acl, _acl, _to, _acl.CREATE_PERMISSIONS_ROLE(), _manager);
        emit SetupDao(_dao);
    }

    function _transferPermissionFromTemplate(ACL _acl, address _app, address _to, bytes32 _permission, address _manager) internal {
        _acl.grantPermission(_to, _app, _permission);
        _acl.revokePermission(address(this), _app, _permission);
        _acl.setPermissionManager(_manager, _app, _permission);
    }

    

    function _installDefaultAgentApp(Kernel _dao) internal returns (Agent) {
        bytes memory initializeData = abi.encodeWithSelector(Agent(0).initialize.selector);
        Agent agent = Agent(_installDefaultApp(_dao, AGENT_APP_ID, initializeData));
        
        
        _dao.setRecoveryVaultAppId(AGENT_APP_ID);
        return agent;
    }

    function _installNonDefaultAgentApp(Kernel _dao) internal returns (Agent) {
        bytes memory initializeData = abi.encodeWithSelector(Agent(0).initialize.selector);
        return Agent(_installNonDefaultApp(_dao, AGENT_APP_ID, initializeData));
    }

    function _createAgentPermissions(ACL _acl, Agent _agent, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _agent, _agent.EXECUTE_ROLE(), _manager);
        _acl.createPermission(_grantee, _agent, _agent.RUN_SCRIPT_ROLE(), _manager);
    }

    

    function _installVaultApp(Kernel _dao) internal returns (Vault) {
        bytes memory initializeData = abi.encodeWithSelector(Vault(0).initialize.selector);
        return Vault(_installDefaultApp(_dao, VAULT_APP_ID, initializeData));
    }

    function _createVaultPermissions(ACL _acl, Vault _vault, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _vault, _vault.TRANSFER_ROLE(), _manager);
    }

    

    function _installVotingApp(Kernel _dao, MiniMeToken _token, uint64[3] memory _votingSettings) internal returns (Voting) {
        return _installVotingApp(_dao, _token, _votingSettings[0], _votingSettings[1], _votingSettings[2]);
    }

    function _installVotingApp(
        Kernel _dao,
        MiniMeToken _token,
        uint64 _support,
        uint64 _acceptance,
        uint64 _duration
    )
        internal returns (Voting)
    {
        bytes memory initializeData = abi.encodeWithSelector(Voting(0).initialize.selector, _token, _support, _acceptance, _duration);
        return Voting(_installNonDefaultApp(_dao, VOTING_APP_ID, initializeData));
    }

    function _createVotingPermissions(
        ACL _acl,
        Voting _voting,
        address _settingsGrantee,
        address _createVotesGrantee,
        address _manager
    )
        internal
    {
        _acl.createPermission(_settingsGrantee, _voting, _voting.MODIFY_QUORUM_ROLE(), _manager);
        _acl.createPermission(_settingsGrantee, _voting, _voting.MODIFY_SUPPORT_ROLE(), _manager);
        _acl.createPermission(_createVotesGrantee, _voting, _voting.CREATE_VOTES_ROLE(), _manager);
    }

    

    function _installSurveyApp(Kernel _dao, MiniMeToken _token, uint64 _minParticipationPct, uint64 _surveyTime) internal returns (Survey) {
        bytes memory initializeData = abi.encodeWithSelector(Survey(0).initialize.selector, _token, _minParticipationPct, _surveyTime);
        return Survey(_installNonDefaultApp(_dao, SURVEY_APP_ID, initializeData));
    }

    function _createSurveyPermissions(ACL _acl, Survey _survey, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _survey, _survey.CREATE_SURVEYS_ROLE(), _manager);
        _acl.createPermission(_grantee, _survey, _survey.MODIFY_PARTICIPATION_ROLE(), _manager);
    }

    

    function _installPayrollApp(
        Kernel _dao,
        Finance _finance,
        address _denominationToken,
        IFeed _priceFeed,
        uint64 _rateExpiryTime
    )
        internal returns (Payroll)
    {
        bytes memory initializeData = abi.encodeWithSelector(
            Payroll(0).initialize.selector,
            _finance,
            _denominationToken,
            _priceFeed,
            _rateExpiryTime
        );
        return Payroll(_installNonDefaultApp(_dao, PAYROLL_APP_ID, initializeData));
    }

    
    function _createPayrollPermissions(
        ACL _acl,
        Payroll _payroll,
        address _employeeManager,
        address _settingsManager,
        address _permissionsManager
    )
        internal
    {
        _acl.createPermission(_employeeManager, _payroll, _payroll.ADD_BONUS_ROLE(), _permissionsManager);
        _acl.createPermission(_employeeManager, _payroll, _payroll.ADD_EMPLOYEE_ROLE(), _permissionsManager);
        _acl.createPermission(_employeeManager, _payroll, _payroll.ADD_REIMBURSEMENT_ROLE(), _permissionsManager);
        _acl.createPermission(_employeeManager, _payroll, _payroll.TERMINATE_EMPLOYEE_ROLE(), _permissionsManager);
        _acl.createPermission(_employeeManager, _payroll, _payroll.SET_EMPLOYEE_SALARY_ROLE(), _permissionsManager);

        _acl.createPermission(_settingsManager, _payroll, _payroll.MODIFY_PRICE_FEED_ROLE(), _permissionsManager);
        _acl.createPermission(_settingsManager, _payroll, _payroll.MODIFY_RATE_EXPIRY_ROLE(), _permissionsManager);
        _acl.createPermission(_settingsManager, _payroll, _payroll.MANAGE_ALLOWED_TOKENS_ROLE(), _permissionsManager);
    }

    function _unwrapPayrollSettings(
        uint256[4] memory _payrollSettings
    )
        internal pure returns (address denominationToken, IFeed priceFeed, uint64 rateExpiryTime, address employeeManager)
    {
        denominationToken = _toAddress(_payrollSettings[0]);
        priceFeed = IFeed(_toAddress(_payrollSettings[1]));
        rateExpiryTime = _payrollSettings[2].toUint64();
        employeeManager = _toAddress(_payrollSettings[3]);
    }

    

    function _installFinanceApp(Kernel _dao, Vault _vault, uint64 _periodDuration) internal returns (Finance) {
        bytes memory initializeData = abi.encodeWithSelector(Finance(0).initialize.selector, _vault, _periodDuration);
        return Finance(_installNonDefaultApp(_dao, FINANCE_APP_ID, initializeData));
    }

    function _createFinancePermissions(ACL _acl, Finance _finance, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _finance, _finance.EXECUTE_PAYMENTS_ROLE(), _manager);
        _acl.createPermission(_grantee, _finance, _finance.MANAGE_PAYMENTS_ROLE(), _manager);
    }

    function _createFinanceCreatePaymentsPermission(ACL _acl, Finance _finance, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _finance, _finance.CREATE_PAYMENTS_ROLE(), _manager);
    }

    function _grantCreatePaymentPermission(ACL _acl, Finance _finance, address _to) internal {
        _acl.grantPermission(_to, _finance, _finance.CREATE_PAYMENTS_ROLE());
    }

    function _transferCreatePaymentManagerFromTemplate(ACL _acl, Finance _finance, address _manager) internal {
        _acl.setPermissionManager(_manager, _finance, _finance.CREATE_PAYMENTS_ROLE());
    }

    

    function _installTokenManagerApp(
        Kernel _dao,
        MiniMeToken _token,
        bool _transferable,
        uint256 _maxAccountTokens
    )
        internal returns (TokenManager)
    {
        TokenManager tokenManager = TokenManager(_installNonDefaultApp(_dao, TOKEN_MANAGER_APP_ID));
        _token.changeController(tokenManager);
        tokenManager.initialize(_token, _transferable, _maxAccountTokens);
        return tokenManager;
    }

    function _createTokenManagerPermissions(ACL _acl, TokenManager _tokenManager, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _tokenManager, _tokenManager.MINT_ROLE(), _manager);
        _acl.createPermission(_grantee, _tokenManager, _tokenManager.BURN_ROLE(), _manager);
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address[] memory _holders, uint256[] memory _stakes) internal {
        _createPermissionForTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
        for (uint256 i = 0; i < _holders.length; i++) {
            _tokenManager.mint(_holders[i], _stakes[i]);
        }
        _removePermissionFromTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address[] memory _holders, uint256 _stake) internal {
        _createPermissionForTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
        for (uint256 i = 0; i < _holders.length; i++) {
            _tokenManager.mint(_holders[i], _stake);
        }
        _removePermissionFromTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address _holder, uint256 _stake) internal {
        _createPermissionForTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
        _tokenManager.mint(_holder, _stake);
        _removePermissionFromTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
    }

    function _setOracle(ACL _acl, TokenManager _tokenManager, address _whitelistOracle) internal {
        _createPermissionForTemplate(_acl, _tokenManager, _tokenManager.SET_ORACLE());
        _tokenManager.setOracle(_whitelistOracle);
        _removePermissionFromTemplate(_acl, _tokenManager, _tokenManager.SET_ORACLE());
    }

    

    function _installWhitelistOracleApp(Kernel _dao) internal returns (WhitelistOracle) {
        return WhitelistOracle(_installNonDefaultApp(_dao, WHITELIST_ORACLE_APP_ID));
    }

    function _createWhitelistPermissions(ACL _acl, WhitelistOracle _whitelist, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _whitelist, _whitelist.ADD_SENDER_ROLE(), _manager);
        _acl.createPermission(_grantee, _whitelist, _whitelist.REMOVE_SENDER_ROLE(), _manager);
    }

    

    function _createEvmScriptsRegistryPermissions(ACL _acl, address _grantee, address _manager) internal {
        EVMScriptRegistry registry = EVMScriptRegistry(_acl.getEVMScriptRegistry());
        _acl.createPermission(_grantee, registry, registry.REGISTRY_MANAGER_ROLE(), _manager);
        _acl.createPermission(_grantee, registry, registry.REGISTRY_ADD_EXECUTOR_ROLE(), _manager);
    }

    

    function _installNonDefaultApp(Kernel _dao, bytes32 _appId) internal returns (address) {
        return _installNonDefaultApp(_dao, _appId, new bytes(0));
    }

    function _installNonDefaultApp(Kernel _dao, bytes32 _appId, bytes memory _initializeData) internal returns (address) {
        return _installApp(_dao, _appId, _initializeData, false);
    }

    function _installDefaultApp(Kernel _dao, bytes32 _appId) internal returns (address) {
        return _installDefaultApp(_dao, _appId, new bytes(0));
    }

    function _installDefaultApp(Kernel _dao, bytes32 _appId, bytes memory _initializeData) internal returns (address) {
        return _installApp(_dao, _appId, _initializeData, true);
    }

    function _installApp(Kernel _dao, bytes32 _appId, bytes memory _initializeData, bool _setDefault) internal returns (address) {
        address latestBaseAppAddress = _latestVersionAppBase(_appId);
        address instance = address(_dao.newAppInstance(_appId, latestBaseAppAddress, _initializeData, _setDefault));
        emit InstalledApp(instance, _appId);
        return instance;
    }

    function _latestVersionAppBase(bytes32 _appId) internal view returns (address base) {
        Repo repo = Repo(PublicResolver(ens.resolver(_appId)).addr(_appId));
        (,base,) = repo.getLatest();
    }

    

    function _createToken(string memory _name, string memory _symbol, uint8 _decimals) internal returns (MiniMeToken) {
        require(address(miniMeFactory) != address(0), ERROR_MINIME_FACTORY_NOT_PROVIDED);
        MiniMeToken token = miniMeFactory.createCloneToken(MiniMeToken(address(0)), 0, _name, _decimals, _symbol, true);
        emit DeployToken(address(token));
        return token;
    }

    function _ensureMiniMeFactoryIsValid(address _miniMeFactory) internal view {
        require(isContract(address(_miniMeFactory)), ERROR_MINIME_FACTORY_NOT_CONTRACT);
    }

    

    function _validateId(string memory _id) internal pure {
        require(bytes(_id).length > 0, ERROR_INVALID_ID);
    }

    function _registerID(string memory _name, address _owner) internal {
        require(address(aragonID) != address(0), ERROR_ARAGON_ID_NOT_PROVIDED);
        aragonID.register(keccak256(abi.encodePacked(_name)), _owner);
    }

    function _ensureAragonIdIsValid(address _aragonID) internal view {
        require(isContract(address(_aragonID)), ERROR_ARAGON_ID_NOT_CONTRACT);
    }

    

    function _toAddress(uint256 _value) private pure returns (address) {
        require(_value <= uint160(-1), ERROR_CANNOT_CAST_VALUE_TO_ADDRESS);
        return address(_value);
    }
}





pragma solidity ^0.4.18;


library DynamicScriptHelpers {
    
    
    
    

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











contract ADynamicForwarder is IForwarder {
    using DynamicScriptHelpers for bytes;
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



pragma solidity 0.4.24;




contract BaseCache is BaseTemplate {
    

    struct InstalledBase {
        ACL acl;
        Kernel dao;
        Vault vault;
    }

    struct InstalledTokens {
        MiniMeToken token1;
        MiniMeToken token2;
    }

    struct InstalledTokenManagers {
        TokenManager tokenManager1;
        TokenManager tokenManager2;
        WhitelistOracle whitelist;
    }

    struct InstalledVotingApps {
        DotVoting dotVoting;
        Voting voting;
        bool secondaryDot;
        bool secondaryVoting;
    }

    mapping (address => InstalledBase) internal baseCache;
    mapping (address => InstalledTokens) internal tokensCache;
    mapping (address => InstalledTokenManagers) internal tokenManagersCache;
    mapping (address => InstalledVotingApps) internal votingAppsCache;

    constructor(address[5] _deployedSetupContracts)
        BaseTemplate(
            DAOFactory(_deployedSetupContracts[0]),
            ENS(_deployedSetupContracts[1]),
            MiniMeTokenFactory(_deployedSetupContracts[2]),
            IFIFSResolvingRegistrar(_deployedSetupContracts[3])
    ) {}

    function _cacheBase(
        ACL _acl,
        Kernel _dao,
        Vault _vault,
        address _owner
    ) internal
    {
        InstalledBase storage baseInstance = baseCache[_owner];
        baseInstance.acl = _acl;
        baseInstance.dao = _dao;
        baseInstance.vault = _vault;
    }

    function _cacheTokens(
        MiniMeToken _token1,
        MiniMeToken _token2,
        address _owner
    ) internal
    {
        InstalledTokens storage tokensInstance = tokensCache[_owner];
        tokensInstance.token1 = _token1;
        tokensInstance.token2 = _token2;
    }

    function _cacheTokenManagers(
        TokenManager _tokenManager1,
        TokenManager _tokenManager2,
        WhitelistOracle _whitelist,
        address _owner
    ) internal
    {
        InstalledTokenManagers storage tokenManagersInstance = tokenManagersCache[_owner];
        tokenManagersInstance.tokenManager1 = _tokenManager1;
        tokenManagersInstance.tokenManager2 = _tokenManager2;
        tokenManagersInstance.whitelist = _whitelist;
    }

    function _cacheVotingApps(
        DotVoting _dotVoting,
        Voting _voting,
        bool _secondaryDot,
        bool _secondaryVoting,
        address _owner
    ) internal
    {
        InstalledVotingApps storage votingAppsInstance = votingAppsCache[_owner];
        votingAppsInstance.dotVoting = _dotVoting;
        votingAppsInstance.voting = _voting;
        votingAppsInstance.secondaryDot = _secondaryDot;
        votingAppsInstance.secondaryVoting = _secondaryVoting;
    }

    function _popBaseCache(address _owner) internal returns (ACL, Kernel, Vault) {
        

        InstalledBase storage baseInstance = baseCache[_owner];
        ACL acl = baseInstance.acl;
        Kernel dao = baseInstance.dao;
        Vault vault = baseInstance.vault;

        delete baseCache[_owner];
        return (acl, dao, vault);
    }

    function _popTokensCache(address _owner) internal returns (MiniMeToken, MiniMeToken) {
        InstalledTokens storage tokensInstance = tokensCache[_owner];
        MiniMeToken token1 = tokensInstance.token1;
        MiniMeToken token2 = tokensInstance.token2;

        delete tokensCache[_owner];
        return (token1, token2);
    }

    function _popTokenManagersCache(address _owner) internal returns (TokenManager, TokenManager, WhitelistOracle) {
        InstalledTokenManagers storage tokenManagersInstance = tokenManagersCache[_owner];
        TokenManager tokenManager1 = tokenManagersInstance.tokenManager1;
        TokenManager tokenManager2 = tokenManagersInstance.tokenManager2;
        WhitelistOracle whitelist = tokenManagersInstance.whitelist;

        delete tokenManagersCache[_owner];
        return (tokenManager1, tokenManager2, whitelist);
    }

    function _popVotingAppsCache(address _owner) internal returns (DotVoting, Voting, bool, bool) {
        InstalledVotingApps storage votingAppsInstance = votingAppsCache[_owner];
        DotVoting dotVoting = votingAppsInstance.dotVoting;
        Voting voting = votingAppsInstance.voting;
        bool secondaryDot = votingAppsInstance.secondaryDot;
        bool secondaryVoting = votingAppsInstance.secondaryVoting;

        delete votingAppsCache[_owner];
        return (dotVoting, voting, secondaryDot, secondaryVoting);
    }
}



pragma solidity 0.4.24;








contract BaseOEApps is BaseCache {

    
    
    
    
    
    
    bytes32 constant internal ADDRESS_BOOK_APP_ID = 0x32ec8cc9f3136797e0ae30e7bf3740905b0417b81ff6d4a74f6100f9037425de;
    bytes32 constant internal ALLOCATIONS_APP_ID = 0x370ef8036e8769f293a3d9c1362d0e21bdfa4e0465d2cd9cf196ebd4ba75aa8b;
    bytes32 constant internal DISCUSSIONS_APP_ID = 0xf8c9b8210902c14e71192ea564edd090c1659cbef1384e362fb508d396d72a38;
    bytes32 constant internal DOT_VOTING_APP_ID = 0x6bf2b7dbfbb51844d0d6fdc211b014638011261157487ccfef5c2e4fb26b1d7e;
    bytes32 constant internal PROJECTS_APP_ID = 0xac5c7cc8f4ed07bb3543b5a4152c4f1a045e1be68bd86e2cf6720b680d1d14f3;
    bytes32 constant internal REWARDS_APP_ID = 0x3ca69801a60916e9222ceb2fa3089b3f66b4e1b3fc49f4a562043d9ec1e5a00b;

    string constant private ERROR_BOUNTIES_NOT_CONTRACT = "BOUNTIES_REGISTRY_NOT_CONTRACT";
    address constant internal ANY_ENTITY = address(-1);
    Bounties internal bountiesRegistry;
    address[] private whiteListed = [address(0), address(0), address(0)];

    
    constructor(address[5] _deployedSetupContracts)
        BaseCache(_deployedSetupContracts)
        
        public
    {
        _ensureAragonIdIsValid(_deployedSetupContracts[3]);
        _ensureMiniMeFactoryIsValid(_deployedSetupContracts[2]);
        require(isContract(address(_deployedSetupContracts[4])), ERROR_BOUNTIES_NOT_CONTRACT);

        bountiesRegistry = Bounties(_deployedSetupContracts[4]);
        whiteListed[1] = address(bountiesRegistry);
    }



    function _installAddressBookApp(Kernel _dao) internal returns (AddressBook) {
        bytes memory initializeData = abi.encodeWithSelector(AddressBook(0).initialize.selector);
        return AddressBook(_installNonDefaultApp(_dao, ADDRESS_BOOK_APP_ID, initializeData));
    }

    function _createAddressBookPermissions(ACL _acl, AddressBook _addressBook, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _addressBook, _addressBook.ADD_ENTRY_ROLE(), _manager);
        _acl.createPermission(_grantee, _addressBook, _addressBook.REMOVE_ENTRY_ROLE(), _manager);
        _acl.createPermission(_grantee, _addressBook, _addressBook.UPDATE_ENTRY_ROLE(), _manager);
    }



    function _installAllocationsApp(Kernel _dao, Vault _vault, uint64 _periodDuration) internal returns (Allocations) {
        bytes memory initializeData = abi.encodeWithSelector(Allocations(0).initialize.selector, _vault, _periodDuration);
        return Allocations(_installNonDefaultApp(_dao, ALLOCATIONS_APP_ID, initializeData));
    }

    function _createAllocationsPermissions(
        ACL _acl,
        Allocations _allocations,
        address _createAllocationsGrantee,
        address _createAccountsGrantee,
        address _manager
    )
        internal
    {
        _acl.createPermission(_createAccountsGrantee, _allocations, _allocations.CREATE_ACCOUNT_ROLE(), _manager);
        _acl.createPermission(_createAccountsGrantee, _allocations, _allocations.CHANGE_BUDGETS_ROLE(), _manager);
        _acl.createPermission(_createAllocationsGrantee, _allocations, _allocations.CREATE_ALLOCATION_ROLE(), _manager);
        _acl.createPermission(ANY_ENTITY, _allocations, _allocations.EXECUTE_ALLOCATION_ROLE(), _manager);
        _acl.createPermission(ANY_ENTITY, _allocations, _allocations.EXECUTE_PAYOUT_ROLE(), _manager);
    }



    
    function _installDotVotingApp(Kernel _dao, MiniMeToken _token, uint64[3] memory _dotVotingSettings) internal returns (DotVoting) {
        return _installDotVotingApp(_dao, _token, _dotVotingSettings[0], _dotVotingSettings[1], _dotVotingSettings[2]);
    }

    function _installDotVotingApp(
        Kernel _dao,
        MiniMeToken _token,
        uint64 _quorum,
        uint64 _support,
        uint64 _duration
    )
        internal returns (DotVoting)
    {
        bytes memory initializeData = abi.encodeWithSelector(DotVoting(0).initialize.selector, _token, _quorum, _support, _duration);
        return DotVoting(_installNonDefaultApp(_dao, DOT_VOTING_APP_ID, initializeData));
    }

    function _createDotVotingPermissions(
        ACL _acl,
        DotVoting _dotVoting,
        address _grantee,
        address _manager
    )
        internal
    {
        _acl.createPermission(_grantee, _dotVoting, _dotVoting.ROLE_CREATE_VOTES(), _manager);
    }



    function _installDiscussionsApp(Kernel _dao) internal returns (DiscussionApp) {
        bytes memory initializeData = abi.encodeWithSelector(DiscussionApp(0).initialize.selector);
        return DiscussionApp(_installNonDefaultApp(_dao, DISCUSSIONS_APP_ID, initializeData));
    }

    function _createDiscussionsPermissions(ACL _acl, DiscussionApp _discussions, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _discussions, _discussions.EMPTY_ROLE(), _manager);
    }



    function _installProjectsApp(Kernel _dao, Vault _vault) internal returns (Projects) {
        bytes memory initializeData = abi.encodeWithSelector(Projects(0).initialize.selector, bountiesRegistry, _vault);
        return Projects(_installNonDefaultApp(_dao, PROJECTS_APP_ID, initializeData));
    }

    function _createProjectsPermissions(
        ACL _acl,
        Projects _projects,
        address _curator,
        address _grantee,
        address _manager
    )
        internal
    {
        _acl.createPermission(_curator, _projects, _projects.CURATE_ISSUES_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.FUND_ISSUES_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.REMOVE_ISSUES_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.FUND_OPEN_ISSUES_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.UPDATE_BOUNTIES_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.ADD_REPO_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.CHANGE_SETTINGS_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.REMOVE_REPO_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.REVIEW_APPLICATION_ROLE(), _manager);
        _acl.createPermission(_grantee, _projects, _projects.WORK_REVIEW_ROLE(), _manager);
    }



    function _installRewardsApp(Kernel _dao, Vault _vault) internal returns (Rewards) {
        bytes memory initializeData = abi.encodeWithSelector(Rewards(0).initialize.selector, _vault);
        return Rewards(_installNonDefaultApp(_dao, REWARDS_APP_ID, initializeData));
    }

    function _createRewardsPermissions(
        ACL _acl,
        Rewards _rewards,
        address _grantee,
        address _manager
    )
        internal
    {
        _acl.createPermission(_grantee, _rewards, _rewards.ADD_REWARD_ROLE(), _manager);
    }



    function _initializeWhitelistOracleApp(WhitelistOracle _whitelist, address _vault, address _finance) internal {
        whiteListed[0] = _vault;
        whiteListed[2] = _finance;
        _whitelist.initialize(whiteListed);
    }



    function _grantVaultPermissions(ACL _acl, Vault _vault, Allocations _allocations, Projects _projects, Rewards _rewards) internal {
        _acl.grantPermission(_allocations, _vault, _vault.TRANSFER_ROLE());
        _acl.grantPermission(_projects, _vault, _vault.TRANSFER_ROLE());
        _acl.grantPermission(_rewards, _vault, _vault.TRANSFER_ROLE());
    }

    
    function _transferPermissionFromTemplate(ACL _acl, address _app, bytes32 _permission, address _manager) internal {
        _acl.revokePermission(address(this), _app, _permission);
        _acl.setPermissionManager(_manager, _app, _permission);
    }
}



pragma solidity 0.4.24;



contract OpenEnterpriseTemplate is BaseOEApps {
    string constant private ERROR_MISSING_MEMBERS = "OPEN_ENTERPRISE_MISSING_MEMBERS";
    string constant private ERROR_BAD_VOTE_SETTINGS = "OPEN_ENTERPRISE_BAD_VOTE_SETTINGS";
    string constant private ERROR_BAD_DOT_VOTE_SETTINGS = "OPEN_ENTERPRISE_BAD_DOT_VOTE_SETTINGS";
    string constant private ERROR_BAD_MEMBERS_STAKES_LEN = "OPEN_ENTERPRISE_BAD_MEMBER_STAKES_LEN";

    uint64 constant private DEFAULT_PERIOD = uint64(30 days);
    uint8 constant private TOKEN_DECIMALS = uint8(18);
    uint256 constant private UNLIMITED_TOKENS = uint256(0);
    uint256 constant private ONE_TOKEN = uint256(1e18);

    
    constructor(address[5] _deployedSetupContracts) BaseOEApps(_deployedSetupContracts) public {}

    
    function newTokensAndInstance(
        string _id,
        string _name1,
        string _symbol1,
        string _name2,
        string _symbol2,
        uint64[6] _votingSettings,
        bool[2] _votingBools,
        bool _useAgentAsVault
    )
        external
    {
        (MiniMeToken token1, MiniMeToken token2) = newTokens(_name1, _symbol1, _name2, _symbol2);
        _newInstance(_id, _votingSettings, _votingBools, token1, token2, _useAgentAsVault);
    }

    
    function newTokenManagers(
        address[] _members1,
        uint256[] _stakes1,
        address[] _members2,
        uint256[] _stakes2,
        bool[4] _tokenBools
    ) public
    {
        _validateTokenSettings(_members1, _stakes1);
        _validateTokenSettings(_members2, _stakes2);
        (ACL acl, Kernel dao, Vault agentOrVault) = _popBaseCache(msg.sender);
        (MiniMeToken token1, MiniMeToken token2) = _popTokensCache(msg.sender);
        TokenManager tokenManager2 = TokenManager(0);
        WhitelistOracle whitelist = WhitelistOracle(0);

        
        TokenManager tokenManager1 = _installTokenManagerApp(
            dao,
            token1,
            true, 
            _tokenBools[0] ? ONE_TOKEN : UNLIMITED_TOKENS
        );

        
        if (!_tokenBools[1]) { 
            if (address(whitelist) == address(0)) {
                whitelist = _installWhitelistOracleApp(dao);
                _setOracle(acl, tokenManager1, whitelist);
            }
        }

        
        if (address(token2) != address(0)) {
            tokenManager2 = _installTokenManagerApp(dao, token2, true, _tokenBools[2] ? ONE_TOKEN : UNLIMITED_TOKENS);
            _mintTokens(acl, tokenManager2, _members2, _stakes2);
            if (!_tokenBools[3]) { 
                whitelist = _installWhitelistOracleApp(dao);
                _setOracle(acl, tokenManager2, whitelist);
            }
        }

        _mintTokens(acl, tokenManager1, _members1, _stakes1);
        _cacheBase(acl, dao, agentOrVault, msg.sender);
        _cacheTokenManagers(tokenManager1, tokenManager2, whitelist, msg.sender);
    }

    function finalizeDao(
        uint64[2] _periods,
        bool _useDiscussions
    ) public
    {
        (ACL acl, Kernel dao, Vault agentOrVault) = _popBaseCache(msg.sender);
        AddressBook addressBook = _installAddressBookApp(dao);
        Allocations allocations = _installAllocationsApp(dao, agentOrVault, _periods[0] == 0 ? DEFAULT_PERIOD : _periods[0]);
        Finance finance = _installFinanceApp(dao, agentOrVault, _periods[1] == 0 ? DEFAULT_PERIOD : _periods[1]);
        Projects projects = _installProjectsApp(dao, agentOrVault);
        Rewards rewards = _installRewardsApp(dao, agentOrVault);
        DiscussionApp discussions = DiscussionApp(0);
        if (_useDiscussions) {
            discussions = _installDiscussionsApp(dao);
        }
        _setupPermissions(
            acl,
            dao,
            addressBook,
            allocations,
            discussions,
            finance,
            projects,
            rewards,
            agentOrVault
        );
    }

    
    function newTokens(
        string _name1,
        string _symbol1,
        string _name2,
        string _symbol2
    )
    public returns (MiniMeToken, MiniMeToken)
    {
        MiniMeToken token1 = _createToken(_name1, _symbol1, TOKEN_DECIMALS);
        MiniMeToken token2 = MiniMeToken(0);
        if (keccak256(abi.encodePacked(_symbol2)) != keccak256(abi.encodePacked(""))) {
            token2 = _createToken(_name2, _symbol2, TOKEN_DECIMALS);
        }
        _cacheTokens(token1, token2, msg.sender);

        return (token1, token2);
    }

    
    function _newInstance(
        string _id,
        uint64[6] memory _votingSettings,
        bool[2] memory _votingBools,
        MiniMeToken _token1,
        MiniMeToken _token2,
        bool _useAgentAsVault
    )
        internal
    {
        _validateId(_id);
        _validateVotingSettings(_votingSettings);

        (Kernel dao, ACL acl) = _createDAO();
        Vault agentOrVault = _useAgentAsVault ? _installDefaultAgentApp(dao) : _installVaultApp(dao);
        DotVoting dotVoting = _installDotVotingApp(
            dao,
            _votingBools[0] ? _token2 : _token1,
            _votingSettings[0],
            _votingSettings[1],
            _votingSettings[2]
        );
        Voting voting = _installVotingApp(dao, _votingBools[1] ? _token2 : _token1, _votingSettings[3], _votingSettings[4], _votingSettings[5]);

        if (_useAgentAsVault) {
            _createAgentPermissions(acl, Agent(agentOrVault), voting, voting);
        }
        _cacheVotingApps(dotVoting, voting, _votingBools[0], _votingBools[1], msg.sender);
        _cacheBase(acl, dao, agentOrVault, msg.sender);
        _registerID(_id, dao);
    }

    function _setupPermissions(
        ACL _acl,
        Kernel _dao,
        AddressBook _addressBook,
        Allocations _allocations,
        DiscussionApp _discussions,
        Finance _finance,
        Projects _projects,
        Rewards _rewards,
        Vault _agentOrVault
    ) internal
    {
        _setupTokenPermissions(_acl, _dao, _finance, _agentOrVault);
        (DotVoting dotVoting, Voting voting, , ) = _popVotingAppsCache(msg.sender);

        if (address(_discussions) != address(0)) {
            _createDiscussionsPermissions(_acl, _discussions, ANY_ENTITY, voting);
        }
        _createAddressBookPermissions(_acl, _addressBook, voting, voting);
        _createAllocationsPermissions(_acl, _allocations, dotVoting, voting, voting);
        _createEvmScriptsRegistryPermissions(_acl, voting, voting);
        _createFinancePermissions(_acl, _finance, voting, voting);
        _createFinanceCreatePaymentsPermission(_acl, _finance, voting, voting);
        _createProjectsPermissions(_acl, _projects, dotVoting, voting, voting);
        _createRewardsPermissions(_acl, _rewards, voting, voting);
        _createVaultPermissions(_acl, _agentOrVault, _finance, address(this));
        _grantVaultPermissions(_acl, _agentOrVault, _allocations, _projects, _rewards);

        
        
        _transferPermissionFromTemplate(_acl, _agentOrVault, _agentOrVault.TRANSFER_ROLE(), voting);
        _transferRootPermissionsFromTemplateAndFinalizeDAO(_dao, voting);
    }

    function _setupTokenPermissions(
        ACL _acl,
        Kernel _dao,
        Finance _finance,
        Vault _vault
    ) internal
    {
        (DotVoting dotVoting, Voting voting, bool secondaryDot, bool secondaryVoting) = _popVotingAppsCache(msg.sender);
        (TokenManager tokenManager1, TokenManager tokenManager2, WhitelistOracle whitelist) = _popTokenManagersCache(msg.sender);
        if (address(tokenManager2) != address(0)) {
            _createTokenManagerPermissions(_acl, tokenManager2, voting, voting);
        }
        if (address(whitelist) != address(0)) {
            _initializeWhitelistOracleApp(whitelist, _vault, _finance);
            _createWhitelistPermissions(_acl, whitelist, voting, voting);
        }
        _createDotVotingPermissions(_acl, dotVoting, secondaryDot ? tokenManager2 : tokenManager1, voting);
        _createTokenManagerPermissions(_acl, tokenManager1, voting, voting);
        _createVotingPermissions(_acl, voting, voting, secondaryVoting ? tokenManager2 : tokenManager1, voting);

        _cacheVotingApps(dotVoting, voting, secondaryDot, secondaryVoting, msg.sender);
    }

    function _validateVotingSettings(uint64[6] memory _votingSettings) private pure {
        require(_votingSettings.length == 6, ERROR_BAD_VOTE_SETTINGS);
    }

    function _validateTokenSettings(address[] memory _members, uint256[] memory _stakes) private pure {
        require(_members.length > 0, ERROR_MISSING_MEMBERS);
        require(_members.length == _stakes.length, ERROR_BAD_MEMBERS_STAKES_LEN);
    }
}