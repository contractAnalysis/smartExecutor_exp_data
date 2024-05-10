pragma solidity ^0.5.2;


interface IGovernance {
    function update(address target, bytes calldata data) external;
}



pragma solidity ^0.5.2;


contract Governable {
    IGovernance public governance;

    constructor(address _governance) public {
        governance = IGovernance(_governance);
    }

    modifier onlyGovernance() {
        require(msg.sender == address(governance), "Only governance contract is authorized");
        _;
    }
}



pragma solidity ^0.5.2;


contract IWithdrawManager {
    function createExitQueue(address token) external;

    function verifyInclusion(
        bytes calldata data,
        uint8 offset,
        bool verifyTxInclusion
    ) external view returns (uint256 age);

    function addExitToQueue(
        address exitor,
        address childToken,
        address rootToken,
        uint256 exitAmountOrTokenId,
        bytes32 txHash,
        bool isRegularExit,
        uint256 priority
    ) external;

    function addInput(
        uint256 exitId,
        uint256 age,
        address utxoOwner,
        address token
    ) external;

    function challengeExit(
        uint256 exitId,
        uint256 inputId,
        bytes calldata challengeData,
        address adjudicatorPredicate
    ) external;
}



pragma solidity ^0.5.2;


contract Registry is Governable {
    
    bytes32 private constant WETH_TOKEN = keccak256("wethToken");
    bytes32 private constant DEPOSIT_MANAGER = keccak256("depositManager");
    bytes32 private constant STAKE_MANAGER = keccak256("stakeManager");
    bytes32 private constant VALIDATOR_SHARE = keccak256("validatorShare");
    bytes32 private constant WITHDRAW_MANAGER = keccak256("withdrawManager");
    bytes32 private constant CHILD_CHAIN = keccak256("childChain");
    bytes32 private constant STATE_SENDER = keccak256("stateSender");
    bytes32 private constant SLASHING_MANAGER = keccak256("slashingManager");

    address public erc20Predicate;
    address public erc721Predicate;

    mapping(bytes32 => address) public contractMap;
    mapping(address => address) public rootToChildToken;
    mapping(address => address) public childToRootToken;
    mapping(address => bool) public proofValidatorContracts;
    mapping(address => bool) public isERC721;

    enum Type {Invalid, ERC20, ERC721, Custom}
    struct Predicate {
        Type _type;
    }
    mapping(address => Predicate) public predicates;

    event TokenMapped(address indexed rootToken, address indexed childToken);
    event ProofValidatorAdded(address indexed validator, address indexed from);
    event ProofValidatorRemoved(address indexed validator, address indexed from);
    event PredicateAdded(address indexed predicate, address indexed from);
    event PredicateRemoved(address indexed predicate, address indexed from);
    event ContractMapUpdated(bytes32 indexed key, address indexed previousContract, address indexed newContract);

    constructor(address _governance) public Governable(_governance) {}

    function updateContractMap(bytes32 _key, address _address) external onlyGovernance {
        emit ContractMapUpdated(_key, contractMap[_key], _address);
        contractMap[_key] = _address;
    }

    
    function mapToken(
        address _rootToken,
        address _childToken,
        bool _isERC721
    ) external onlyGovernance {
        require(_rootToken != address(0x0) && _childToken != address(0x0), "INVALID_TOKEN_ADDRESS");
        rootToChildToken[_rootToken] = _childToken;
        childToRootToken[_childToken] = _rootToken;
        isERC721[_rootToken] = _isERC721;
        IWithdrawManager(contractMap[WITHDRAW_MANAGER]).createExitQueue(_rootToken);
        emit TokenMapped(_rootToken, _childToken);
    }

    function addErc20Predicate(address predicate) public onlyGovernance {
        require(predicate != address(0x0), "Can not add null address as predicate");
        erc20Predicate = predicate;
        addPredicate(predicate, Type.ERC20);
    }

    function addErc721Predicate(address predicate) public onlyGovernance {
        erc721Predicate = predicate;
        addPredicate(predicate, Type.ERC721);
    }

    function addPredicate(address predicate, Type _type) public onlyGovernance {
        require(predicates[predicate]._type == Type.Invalid, "Predicate already added");
        predicates[predicate]._type = _type;
        emit PredicateAdded(predicate, msg.sender);
    }

    function removePredicate(address predicate) public onlyGovernance {
        require(predicates[predicate]._type != Type.Invalid, "Predicate does not exist");
        delete predicates[predicate];
        emit PredicateRemoved(predicate, msg.sender);
    }

    function getValidatorShareAddress() public view returns (address) {
        return contractMap[VALIDATOR_SHARE];
    }

    function getWethTokenAddress() public view returns (address) {
        return contractMap[WETH_TOKEN];
    }

    function getDepositManagerAddress() public view returns (address) {
        return contractMap[DEPOSIT_MANAGER];
    }

    function getStakeManagerAddress() public view returns (address) {
        return contractMap[STAKE_MANAGER];
    }

    function getSlashingManagerAddress() public view returns (address) {
        return contractMap[SLASHING_MANAGER];
    }

    function getWithdrawManagerAddress() public view returns (address) {
        return contractMap[WITHDRAW_MANAGER];
    }

    function getChildChainAndStateSender() public view returns (address, address) {
        return (contractMap[CHILD_CHAIN], contractMap[STATE_SENDER]);
    }

    function isTokenMapped(address _token) public view returns (bool) {
        return rootToChildToken[_token] != address(0x0);
    }

    function isTokenMappedAndIsErc721(address _token) public view returns (bool) {
        require(isTokenMapped(_token), "TOKEN_NOT_MAPPED");
        return isERC721[_token];
    }

    function isTokenMappedAndGetPredicate(address _token) public view returns (address) {
        if (isTokenMappedAndIsErc721(_token)) {
            return erc721Predicate;
        }
        return erc20Predicate;
    }

    function isChildTokenErc721(address childToken) public view returns (bool) {
        address rootToken = childToRootToken[childToken];
        require(rootToken != address(0x0), "Child token is not mapped");
        return isERC721[rootToken];
    }
}



pragma solidity ^0.5.2;



contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.5.2;


contract ProxyStorage is Ownable {
    address internal proxyTo;
}





pragma solidity ^0.5.2;




interface ERCProxy {
    function proxyType() external pure returns (uint256 proxyTypeId);

    function implementation() external view returns (address codeAddr);
}



pragma solidity ^0.5.2;


contract DelegateProxy is ERCProxy {
    function proxyType() external pure returns (uint256 proxyTypeId) {
        
        proxyTypeId = 2;
    }

    function implementation() external view returns (address);

    function delegatedFwd(address _dst, bytes memory _calldata) internal {
        
        assembly {
            let result := delegatecall(sub(gas, 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
            let size := returndatasize

            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            
            
            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }
}



pragma solidity ^0.5.2;


contract Proxy is ProxyStorage, DelegateProxy {
    event ProxyUpdated(address indexed _new, address indexed _old);
    event OwnerUpdate(address _prevOwner, address _newOwner);

    constructor(address _proxyTo) public {
        updateImplementation(_proxyTo);
    }

    function() external payable {
        
        
        delegatedFwd(proxyTo, msg.data);
    }

    function implementation() external view returns (address) {
        return proxyTo;
    }

    function updateImplementation(address _newProxyTo) public onlyOwner {
        require(_newProxyTo != address(0x0), "INVALID_PROXY_ADDRESS");
        require(isContract(_newProxyTo), "DESTINATION_ADDRESS_IS_NOT_A_CONTRACT");
        emit ProxyUpdated(_newProxyTo, proxyTo);
        proxyTo = _newProxyTo;
    }

    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly {
            size := extcodesize(_target)
        }
        return size > 0;
    }
}




pragma solidity ^0.5.0;


library RLPReader {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

    struct Iterator {
        RLPItem item; 
        uint256 nextPtr; 
    }

    
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self));

        uint256 ptr = self.nextPtr;
        uint256 itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    
    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    
    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {
        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    
    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {
        require(isList(self));

        uint256 ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    
    function rlpLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len;
    }

    
    function payloadLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len - _payloadOffset(item.memPtr);
    }

    
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {
        require(isList(item));

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    
    function isList(RLPItem memory item) internal pure returns (bool) {
        if (item.len == 0) return false;

        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    

    
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {
        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    
    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1);
        uint256 result;
        uint256 memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        
        require(item.len == 21);

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {
        require(item.len > 0 && item.len <= 33);

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset;

        uint256 result;
        uint256 memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

            
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    
    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {
        
        require(item.len == 33);

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0);

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset; 
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }

    

    
    function numItems(RLPItem memory item) private pure returns (uint256) {
        if (item.len == 0) return 0;

        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); 
            count++;
        }

        return count;
    }

    
    function _itemLength(uint256 memPtr) private pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START) itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) 
                memPtr := add(memPtr, 1) 

                
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) 
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) 
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    
    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)) return 1;
        else if (byte0 < LIST_SHORT_START)
            
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }

    
    function copy(
        uint256 src,
        uint256 dest,
        uint256 len
    ) private pure {
        if (len == 0) return;

        
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        
        uint256 mask = 256**(WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) 
            let destpart := and(mload(dest), mask) 
            mstore(dest, or(destpart, srcpart))
        }
    }
}



pragma solidity ^0.5.2;



library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



pragma solidity ^0.5.2;


contract ChainIdMixin {
    bytes public constant networkId = hex"89";
    uint256 public constant CHAINID = 137;
}



pragma solidity ^0.5.2;


contract RootChainHeader {
    event NewHeaderBlock(
        address indexed proposer,
        uint256 indexed headerBlockId,
        uint256 indexed reward,
        uint256 start,
        uint256 end,
        bytes32 root
    );
    
    event ResetHeaderBlock(address indexed proposer, uint256 indexed headerBlockId);
    struct HeaderBlock {
        bytes32 root;
        uint256 start;
        uint256 end;
        uint256 createdAt;
        address proposer;
    }
}


contract RootChainStorage is ProxyStorage, RootChainHeader, ChainIdMixin {
    bytes32 public heimdallId;
    uint8 public constant VOTE_TYPE = 2;

    uint16 internal constant MAX_DEPOSITS = 10000;
    uint256 public _nextHeaderBlock = MAX_DEPOSITS;
    uint256 internal _blockDepositId = 1;
    mapping(uint256 => HeaderBlock) public headerBlocks;
    Registry internal registry;
}



pragma solidity ^0.5.2;


contract IStakeManager {
    
    function startAuction(uint256 validatorId, uint256 amount) external;

    function confirmAuctionBid(
        uint256 validatorId,
        uint256 heimdallFee,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external;

    function transferFunds(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);

    function delegationDeposit(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);

    function stake(
        uint256 amount,
        uint256 heimdallFee,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external;

    function unstake(uint256 validatorId) external;

    function totalStakedFor(address addr) external view returns (uint256);

    function supportsHistory() external pure returns (bool);

    function stakeFor(
        address user,
        uint256 amount,
        uint256 heimdallFee,
        bool acceptDelegation,
        bytes memory signerPubkey
    ) public;

    function checkSignatures(
        uint256 blockInterval,
        bytes32 voteHash,
        bytes32 stateRoot,
        address proposer,
        bytes memory sigs
    ) public returns (uint256);

    function updateValidatorState(uint256 validatorId, int256 amount) public;

    function ownerOf(uint256 tokenId) public view returns (address);

    function slash(bytes memory slashingInfoList) public returns (uint256);

    function validatorStake(uint256 validatorId) public view returns (uint256);

    function epoch() public view returns (uint256);

    function withdrawalDelay() public view returns (uint256);
}



pragma solidity ^0.5.2;


interface IRootChain {
    function slash() external;

    function submitHeaderBlock(bytes calldata data, bytes calldata sigs) external;

    function getLastChildBlock() external view returns (uint256);

    function currentHeaderBlock() external view returns (uint256);
}



pragma solidity ^0.5.2;


contract RootChain is RootChainStorage, IRootChain {
    using SafeMath for uint256;
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;

    modifier onlyDepositManager() {
        require(msg.sender == registry.getDepositManagerAddress(), "UNAUTHORIZED_DEPOSIT_MANAGER_ONLY");
        _;
    }

    function submitHeaderBlock(bytes calldata data, bytes calldata sigs) external {
        (address proposer, uint256 start, uint256 end, bytes32 rootHash, bytes32 accountHash, uint256 _borChainID) = abi
            .decode(data, (address, uint256, uint256, bytes32, bytes32, uint256));
        require(CHAINID == _borChainID, "Invalid bor chain id");

        require(_buildHeaderBlock(proposer, start, end, rootHash), "INCORRECT_HEADER_DATA");

        
        IStakeManager stakeManager = IStakeManager(registry.getStakeManagerAddress());
        uint256 _reward = stakeManager.checkSignatures(
            end.sub(start).add(1),
            
            keccak256(abi.encodePacked(bytes(hex"01"), data)),
            accountHash,
            proposer,
            sigs
        );

        require(_reward != 0, "Invalid checkpoint");
        emit NewHeaderBlock(proposer, _nextHeaderBlock, _reward, start, end, rootHash);
        _nextHeaderBlock = _nextHeaderBlock.add(MAX_DEPOSITS);
        _blockDepositId = 1;
    }

    function updateDepositId(uint256 numDeposits) external onlyDepositManager returns (uint256 depositId) {
        depositId = currentHeaderBlock().add(_blockDepositId);
        
        _blockDepositId = _blockDepositId.add(numDeposits);
        require(
            
            _blockDepositId <= MAX_DEPOSITS,
            "TOO_MANY_DEPOSITS"
        );
    }

    function getLastChildBlock() external view returns (uint256) {
        return headerBlocks[currentHeaderBlock()].end;
    }

    function slash() external {
        
    }

    function currentHeaderBlock() public view returns (uint256) {
        return _nextHeaderBlock.sub(MAX_DEPOSITS);
    }

    function _buildHeaderBlock(
        address proposer,
        uint256 start,
        uint256 end,
        bytes32 rootHash
    ) private returns (bool) {
        uint256 nextChildBlock;
        
        if (_nextHeaderBlock > MAX_DEPOSITS) {
            nextChildBlock = headerBlocks[currentHeaderBlock()].end + 1;
        }
        if (nextChildBlock != start) {
            return false;
        }

        HeaderBlock memory headerBlock = HeaderBlock({
            root: rootHash,
            start: nextChildBlock,
            end: end,
            createdAt: now,
            proposer: proposer
        });

        headerBlocks[_nextHeaderBlock] = headerBlock;
        return true;
    }

    
    function setNextHeaderBlock(uint256 _value) public onlyOwner {
        require(_value % MAX_DEPOSITS == 0, "Invalid value");
        for (uint256 i = _value; i < _nextHeaderBlock; i += MAX_DEPOSITS) {
            delete headerBlocks[i];
        }
        _nextHeaderBlock = _value;
        _blockDepositId = 1;
        emit ResetHeaderBlock(msg.sender, _nextHeaderBlock);
    }

    
    function setHeimdallId(string memory _heimdallId) public onlyOwner {
        heimdallId = keccak256(abi.encodePacked(_heimdallId));
    }
}



pragma solidity ^0.5.2;



interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.2;



contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public;
}



pragma solidity ^0.5.2;



contract IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4);
}



pragma solidity ^0.5.2;



library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}



pragma solidity ^0.5.2;



library Counters {
    using SafeMath for uint256;

    struct Counter {
        
        
        
        uint256 _value; 
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}



pragma solidity ^0.5.2;



contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    

    
    mapping(bytes4 => bool) private _supportedInterfaces;

    
    constructor() internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}



pragma solidity ^0.5.2;



contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    
    mapping(uint256 => address) private _tokenOwner;

    
    mapping(uint256 => address) private _tokenApprovals;

    
    mapping(address => Counters.Counter) private _ownedTokensCount;

    
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    

    constructor() public {
        
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner].current();
    }

    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

// File: contracts/root/withdrawManager/ExitNFT.sol

pragma solidity ^0.5.2;


contract ExitNFT is ERC721 {
    Registry internal registry;

    modifier onlyWithdrawManager() {
        require(msg.sender == registry.getWithdrawManagerAddress(), "UNAUTHORIZED_WITHDRAW_MANAGER_ONLY");
        _;
    }

    constructor(address _registry) public {
        registry = Registry(_registry);
    }

    function mint(address _owner, uint256 _tokenId) external onlyWithdrawManager {
        _mint(_owner, _tokenId);
    }

    function burn(uint256 _tokenId) external onlyWithdrawManager {
        _burn(_tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
}



pragma solidity ^0.5.2;


contract ExitsDataStructure {
    struct Input {
        address utxoOwner;
        address predicate;
        address token;
    }

    struct PlasmaExit {
        uint256 receiptAmountOrNFTId;
        bytes32 txHash;
        address owner;
        address token;
        bool isRegularExit;
        address predicate;
        
        mapping(uint256 => Input) inputs;
    }
}


contract WithdrawManagerHeader is ExitsDataStructure {
    event Withdraw(uint256 indexed exitId, address indexed user, address indexed token, uint256 amount);

    event ExitStarted(
        address indexed exitor,
        uint256 indexed exitId,
        address indexed token,
        uint256 amount,
        bool isRegularExit
    );

    event ExitUpdated(uint256 indexed exitId, uint256 indexed age, address signer);
    event ExitPeriodUpdate(uint256 indexed oldExitPeriod, uint256 indexed newExitPeriod);

    event ExitCancelled(uint256 indexed exitId);
}


contract WithdrawManagerStorage is ProxyStorage, WithdrawManagerHeader {
    
    uint256 public HALF_EXIT_PERIOD = 302400;

    
    uint256 internal constant BOND_AMOUNT = 10**17;

    Registry internal registry;
    RootChain internal rootChain;

    mapping(uint128 => bool) isKnownExit;
    mapping(uint256 => PlasmaExit) public exits;
    
    mapping(bytes32 => uint256) public ownerExits;
    mapping(address => address) public exitsQueues;
    ExitNFT public exitNft;

    
    
    

    
    uint32 public ON_FINALIZE_GAS_LIMIT = 300000;

    uint256 public exitWindow;
}



pragma solidity ^0.5.2;


contract WithdrawManagerProxy is Proxy, WithdrawManagerStorage {
    constructor(
        address _proxyTo,
        address _registry,
        address _rootChain,
        address _exitNft
    ) public Proxy(_proxyTo) {
        registry = Registry(_registry);
        rootChain = RootChain(_rootChain);
        exitNft = ExitNFT(_exitNft);
    }
}