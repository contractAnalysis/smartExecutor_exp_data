pragma solidity ^0.5.0;


contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.5.0;


library ZeroCopySource {
    
    function NextBool(bytes memory buff, uint256 offset) internal pure returns(bool, uint256) {
        require(offset + 1 <= buff.length, "Offset exceeds limit");
        
        byte v;
        assembly{
            v := mload(add(add(buff, 0x20), offset))
        }
        bool value;
        if (v == 0x01) {
		    value = true;
    	} else if (v == 0x00) {
            value = false;
        } else {
            revert("NextBool value error");
        }
        return (value, offset + 1);
    }

    
    function NextByte(bytes memory buff, uint256 offset) internal pure returns (byte, uint256) {
        require(offset + 1 <= buff.length, "Offset exceeds maximum");
        byte v;
        assembly{
            v := mload(add(add(buff, 0x20), offset))
        }
        return (v, offset + 1);
    }

    
    function NextUint8(bytes memory buff, uint256 offset) internal pure returns (uint8, uint256) {
        require(offset + 1 <= buff.length, "Offset exceeds maximum");
        uint8 v;
        assembly{
            let tmpbytes := mload(0x40)
            let bvalue := mload(add(add(buff, 0x20), offset))
            mstore8(tmpbytes, byte(0, bvalue))
            mstore(0x40, add(tmpbytes, 0x01))
            v := mload(sub(tmpbytes, 0x1f))
        }
        return (v, offset + 1);
    }

    
    function NextUint16(bytes memory buff, uint256 offset) internal pure returns (uint16, uint256) {
        require(offset + 2 <= buff.length, "offset exceeds maximum");
        
        uint16 v;
        assembly {
            let tmpbytes := mload(0x40)
            let bvalue := mload(add(add(buff, 0x20), offset))
            mstore8(tmpbytes, byte(0x01, bvalue))
            mstore8(add(tmpbytes, 0x01), byte(0, bvalue))
            mstore(0x40, add(tmpbytes, 0x02))
            v := mload(sub(tmpbytes, 0x1e))
        }
        return (v, offset + 2);
    }


    
    function NextUint32(bytes memory buff, uint256 offset) internal pure returns (uint32, uint256) {
        require(offset + 4 <= buff.length, "offset exceeds maximum");
        uint32 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x04
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(sub(tmpbytes, sub(0x20, byteLen)))
        }
        return (v, offset + 4);
    }

    
    function NextUint64(bytes memory buff, uint256 offset) internal pure returns (uint64, uint256) {
        require(offset + 8 <= buff.length, "offset exceeds maximum");
        uint64 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x08
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(sub(tmpbytes, sub(0x20, byteLen)))
        }
        return (v, offset + 8);
    }

    
    function NextUint256(bytes memory buff, uint256 offset) internal pure returns (uint256, uint256) {
        require(offset + 32 <= buff.length, "offset exceeds maximum");
        uint256 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x20
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(tmpbytes)
        }
        require(v >= 0 && v <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
        return (v, offset + 32);
    }
    
    function NextVarBytes(bytes memory buff, uint256 offset) internal pure returns(bytes memory, uint256) {
        uint len;
        (len, offset) = NextVarUint(buff, offset);
        require(offset + len <= buff.length, "offset exceeds maximum");
        bytes memory tempBytes;
        assembly{
            switch iszero(len)
            case 0 {
                
                
                tempBytes := mload(0x40)

                
                
                
                
                
                
                
                
                let lengthmod := and(len, 31)

                
                
                
                
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, len)

                for {
                    
                    
                    let cc := add(add(add(buff, lengthmod), mul(0x20, iszero(lengthmod))), offset)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, len)

                
                
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return (tempBytes, offset + len);
    }
    
    function NextHash(bytes memory buff, uint256 offset) internal pure returns (bytes32 , uint256) {
        require(offset + 32 <= buff.length, "offset exceeds maximum");
        bytes32 v;
        assembly {
            v := mload(add(buff, add(offset, 0x20)))
        }
        return (v, offset + 32);
    }

    
    function NextBytes20(bytes memory buff, uint256 offset) internal pure returns (bytes20 , uint256) {
        require(offset + 20 <= buff.length, "offset exceeds maximum");
        bytes20 v;
        assembly {
            v := mload(add(buff, add(offset, 0x20)))
        }
        return (v, offset + 20);
    }
    
    function NextVarUint(bytes memory buff, uint256 offset) internal pure returns(uint, uint256) {
        byte v;
        (v, offset) = NextByte(buff, offset);

        if (v == 0xFD) {
            return NextUint16(buff, offset);
        } else if (v == 0xFE) {
            return NextUint32(buff, offset);
        } else if (v == 0xFF) {
            return NextUint64(buff, offset);
        } else{
            return (uint8(v), offset);
        }
    }
}



pragma solidity ^0.5.0;


library ZeroCopySink {
    
    function WriteBool(bool b) internal pure returns (bytes memory) {
        bytes memory buff;
        assembly{
            buff := mload(0x40)
            mstore(buff, 1)
            switch iszero(b)
            case 1 {
                mstore(add(buff, 0x20), shl(248, 0x00))
                
            }
            default {
                mstore(add(buff, 0x20), shl(248, 0x01))
                
            }
            mstore(0x40, add(buff, 0x40))
        }
        return buff;
    }

    
    function WriteByte(byte b) internal pure returns (bytes memory) {
        return WriteUint8(uint8(b));
    }

    
    function WriteUint8(uint8 v) internal pure returns (bytes memory) {
        bytes memory buff;
        assembly{
            buff := mload(0x40)
            mstore(buff, 1)
            mstore(add(buff, 0x20), shl(248, v))
            
            mstore(0x40, add(buff, 0x40))
        }    
        return buff;
    }

    
    function WriteUint16(uint16 v) internal pure returns (bytes memory) {
        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x02
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x40))
        }
        return buff;
    }
    
    
    function WriteUint32(uint32 v) internal pure returns(bytes memory) {
        bytes memory buff;
        assembly{
            buff := mload(0x40)
            let byteLen := 0x04
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x40))
        }
        return buff;
    }

    
    function WriteUint64(uint64 v) internal pure returns(bytes memory) {
        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x08
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x40))
        }
        return buff;
    }

    
    function WriteUint255(uint256 v) internal pure returns (bytes memory) {
        require(v >= 0 && v <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds uint255 range");
        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x20
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x40))
        }
        return buff;
    }

    
    function WriteVarBytes(bytes memory data) internal pure returns (bytes memory) {
        uint64 l = uint64(data.length);
        return abi.encodePacked(WriteVarUint(l), data);
    }

    function WriteVarUint(uint64 v) internal pure returns (bytes memory) {
        if (v < 0xFD){
    		return WriteUint8(uint8(v));
    	} else if (v <= 0xFFFF) {
    		return abi.encodePacked(WriteByte(0xFD), WriteUint16(uint16(v)));
    	} else if (v <= 0xFFFFFFFF) {
            return abi.encodePacked(WriteByte(0xFE), WriteUint32(uint32(v)));
    	} else {
    		return abi.encodePacked(WriteByte(0xFF), WriteUint64(uint64(v)));
    	}
    }

    
    function WriteInt8(int8 v) internal pure returns (bytes memory) {
        return WriteUint8(uint8(v));
    }

    function WriteInt16(int16 v) internal pure returns (bytes memory){
        return WriteUint16(uint16(v));
    }

    function WriteInt32(int32 v) internal pure returns (bytes memory) {
        return WriteUint32(uint32(v));
    }

    function WriteInt64(int64 v) internal pure returns (bytes memory) {
        return WriteUint64(uint64(v));
    }
}



pragma solidity ^0.5.0;


library Utils {

    
    function bytesToBytes32(bytes memory _bs) internal pure returns (bytes32 value) {
        require(_bs.length == 32, "bytes length is not 32.");
        assembly {
            
            value := mload(add(_bs, 0x20))
        }
    }

    
    function bytesToUint256(bytes memory _bs) internal pure returns (uint256 value) {
        require(_bs.length == 32, "bytes length is not 32.");
        assembly {
            
            value := mload(add(_bs, 0x20))
        }
        require(value >= 0 && value <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
    }

    
    function uint256ToBytes(uint256 _value) internal pure returns (bytes memory bs) {
        require(_value >= 0 && _value <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
        assembly {
            
            
            bs := mload(0x40)
            
            mstore(bs, 0x20)
            
            mstore(add(bs, 0x20), _value)
            
            mstore(0x40, add(bs, 0x40))
        }
    }

    
    function bytesToAddress(bytes memory _bs) internal pure returns (address addr)
    {
        require(_bs.length == 20, "bytes length does not match address");
        assembly {
            
            
            addr := mload(add(_bs, 0x14))
        }

    }
    
    
    function addressToBytes(address _addr) internal pure returns (bytes memory bs){
        assembly {
            
            
            bs := mload(0x40)
            
            mstore(bs, 0x14)
            
            mstore(add(bs, 0x20), shl(96, _addr))
            
            mstore(0x40, add(bs, 0x40))
       }
    }

    
    function hashLeaf(bytes memory _data) internal pure returns (bytes32 result)  {
        result = sha256(abi.encodePacked(byte(0x0), _data));
    }

    
    function hashChildren(bytes32 _l, bytes32  _r) internal pure returns (bytes32 result)  {
        result = sha256(abi.encodePacked(bytes1(0x01), _l, _r));
    }

    
    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
        bool success = true;

        assembly {
            
            let fslot := sload(_preBytes_slot)
            
            
            
            
            
            
            
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            
            switch eq(slength, mlength)
            case 1 {
                
                
                
                
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            
                            success := 0
                        }
                    }
                    default {
                        
                        
                        
                        
                        let cb := 1

                        
                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        
                        
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                
                success := 0
            }
        }

        return success;
    }

    
    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                
                
                tempBytes := mload(0x40)

                
                
                
                
                
                
                
                
                
                let lengthmod := and(_length, 31)

                
                
                
                
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    
                    
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                
                
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    
    function containsAddress(address[] memory _addrArray, address _addr) internal pure returns (bool exist){
        exist = false;
        for(uint i = 0; i < _addrArray.length; i++){
            if (_addr == _addrArray[i]){
                exist = true;
                break;
            }
        }
    }

    
    function compressMCPubKey(bytes memory key) internal pure returns (bytes memory newkey) {
        require(key.length >= 34, "key lenggh is too short");
         newkey = slice(key, 0, 35);
         if (uint8(key[66]) % 2 == 0){
             newkey[2] = byte(0x02);
         } else {
             newkey[2] = byte(0x03);
         }
         return newkey;
    }
    
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    
    function findBookKeeper(uint64[] memory _arr, uint64 _len, uint _v) internal pure returns (uint64, bool) {
        require(_len > 0, "book keeper list cannot empty");
        require(_arr.length == _len, "cannot partially query");
        require(_v > 0, "block height must be positive");

        uint64 left = 0;
        uint64 right = _len - 1;

        
        if (_len == 1){
            return (0, true);
        }

        while (left <= right){
            uint64 middle = left + ((right - left) >> 1);

            if(_arr[middle] == _v){
                return (middle, true);
            }

            if(_arr[middle] < _v){
			    left = middle + 1;
            } else {
                right = middle - 1;
            }
        }

        if(left >= 1 && _arr[left - 1] < _v){
            return (left - 1, true);
        }

        return (0, false);
    }
}



pragma solidity ^0.5.0;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.5.0;


interface IEthCrossChainManager {
    function crossChain(uint64 _toChainId, bytes calldata _toContract, bytes calldata _method, bytes calldata _txData) external returns (bool);
}



pragma solidity ^0.5.0;


interface IEthCrossChainManagerProxy {
    function getEthCrossChainManager() external view returns (address);
}



pragma solidity ^0.5.0;








interface ERC20Interface {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function balanceOf(address account) external view returns (uint256);
}

contract LockProxyPip1 is Context {
    using SafeMath for uint;

    struct RegisterAssetTxArgs {
        bytes assetHash;
        bytes nativeAssetHash;
    }

    struct TxArgs {
        bytes fromAssetHash;
        bytes toAssetHash;
        bytes toAddress;
        uint256 amount;
        uint256 feeAmount;
        bytes feeAddress;
        bytes fromAddress;
        uint256 nonce;
    }

    address public managerProxyContract;
    uint256 public currentNonce = 0;

    mapping(bytes32 => bool) public registry;
    mapping(bytes32 => uint256) public balances;

    event SetManagerProxyEvent(address manager);
    event DelegateAssetEvent(address assetHash, uint64 nativeChainId, bytes nativeLockProxy, bytes nativeAssetHash);
    event UnlockEvent(address toAssetHash, address toAddress, uint256 amount, bytes txArgs);
    event LockEvent(address fromAssetHash, address fromAddress, uint64 toChainId, bytes toAssetHash, bytes toAddress, bytes txArgs);

    constructor(address ethCCMProxyAddr) public {
        managerProxyContract = ethCCMProxyAddr;
        emit SetManagerProxyEvent(managerProxyContract);
    }

    modifier onlyManagerContract() {
        IEthCrossChainManagerProxy ieccmp = IEthCrossChainManagerProxy(managerProxyContract);
        require(_msgSender() == ieccmp.getEthCrossChainManager(), "msgSender is not EthCrossChainManagerContract");
        _;
    }

    function delegateAsset(uint64 nativeChainId, bytes memory nativeLockProxy, bytes memory nativeAssetHash, uint256 delegatedSupply) public {
        require(nativeChainId > 0, "nativeChainId cannot be zero");
        require(nativeLockProxy.length > 0, "empty nativeLockProxy");
        require(nativeAssetHash.length > 0, "empty nativeAssetHash");

        address assetHash = _msgSender();
        bytes32 key = _getRegistryKey(assetHash, nativeChainId, nativeLockProxy, nativeAssetHash);

        require(registry[key] != true, "asset already registered");
        require(balances[key] == 0, "balance is not zero");
        require(_balanceFor(assetHash) == delegatedSupply, "controlled balance does not match delegatedSupply");

        registry[key] = true;

        RegisterAssetTxArgs memory txArgs = RegisterAssetTxArgs({
            assetHash: Utils.addressToBytes(assetHash),
            nativeAssetHash: nativeAssetHash
        });

        bytes memory txData = _serializeRegisterAssetTxArgs(txArgs);

        IEthCrossChainManager eccm = _getEccm();
        require(eccm.crossChain(nativeChainId, nativeLockProxy, "registerAsset", txData), "EthCrossChainManager crossChain executed error!");
        balances[key] = delegatedSupply;

        emit DelegateAssetEvent(assetHash, nativeChainId, nativeLockProxy, nativeAssetHash);
    }

    function registerAsset(bytes memory argsBs, bytes memory fromContractAddr, uint64 fromChainId) onlyManagerContract public returns (bool) {
        RegisterAssetTxArgs memory args = _deserializeRegisterAssetTxArgs(argsBs);

        bytes32 key = _getRegistryKey(Utils.bytesToAddress(args.nativeAssetHash), fromChainId, fromContractAddr, args.assetHash);

        require(registry[key] != true, "asset already registerd");
        registry[key] = true;

        return true;
    }

    
    function lock(
        address fromAssetHash,
        uint64 toChainId,
        bytes memory targetProxyHash,
        bytes memory toAssetHash,
        bytes memory toAddress,
        uint256 amount,
        uint256 feeAmount,
        bytes memory feeAddress
    )
        public
        payable
        returns (bool)
    {
        require(toChainId > 0, "toChainId cannot be zero");
        require(targetProxyHash.length > 0, "empty targetProxyHash");
        require(toAssetHash.length > 0, "empty toAssetHash");
        require(toAddress.length > 0, "empty toAddress");
        require(amount > 0, "amount must be more than zero!");

        require(_transferToContract(fromAssetHash, amount), "transfer asset from fromAddress to lock_proxy contract  failed!");

        bytes32 key = _getRegistryKey(fromAssetHash, toChainId, targetProxyHash, toAssetHash);
        require(registry[key] == true, "asset not registered");

        uint256 nonce = _getNextNonce();
        TxArgs memory txArgs = TxArgs({
            fromAssetHash: Utils.addressToBytes(fromAssetHash),
            toAssetHash: toAssetHash,
            toAddress: toAddress,
            amount: amount,
            feeAmount: feeAmount,
            feeAddress: feeAddress,
            fromAddress: abi.encodePacked(_msgSender()),
            nonce: nonce
        });

        require(feeAmount <= amount, "fee amount cannot be greater than amount");

        bytes memory txData = _serializeTxArgs(txArgs);
        IEthCrossChainManager eccm = _getEccm();

        require(eccm.crossChain(toChainId, targetProxyHash, "unlock", txData), "EthCrossChainManager crossChain executed error!");
        balances[key] = balances[key].add(txArgs.amount);

        emit LockEvent(fromAssetHash, _msgSender(), toChainId, toAssetHash, toAddress, txData);

        return true;
    }

    
    
    
    
    
    
    
    
    function unlock(bytes memory argsBs, bytes memory fromContractAddr, uint64 fromChainId) onlyManagerContract public returns (bool) {
        TxArgs memory args = _deserializeTxArgs(argsBs);
        address toAssetHash = Utils.bytesToAddress(args.toAssetHash);
        address toAddress = Utils.bytesToAddress(args.toAddress);

        bytes32 key = _getRegistryKey(toAssetHash, fromChainId, fromContractAddr, args.fromAssetHash);

        require(registry[key] == true, "asset not registered");
        require(balances[key] >= args.amount, "insufficient balance in registry");

        balances[key] = balances[key].sub(args.amount);
        require(_transferFromContract(toAssetHash, toAddress, args.amount), "transfer asset from lock_proxy contract to toAddress failed!");

        emit UnlockEvent(toAssetHash, toAddress, args.amount, argsBs);
        return true;
    }

    function _getNextNonce() private returns (uint256) {
      currentNonce++;
      return currentNonce;
    }

    function _balanceFor(address fromAssetHash) public view returns (uint256) {
        if (fromAssetHash == address(0)) {
            
            address selfAddr = address(this);
            return selfAddr.balance;
        } else {
            ERC20Interface erc20Token = ERC20Interface(fromAssetHash);
            return erc20Token.balanceOf(address(this));
        }
    }
    function _getEccm() internal view returns (IEthCrossChainManager) {
      IEthCrossChainManagerProxy eccmp = IEthCrossChainManagerProxy(managerProxyContract);
      address eccmAddr = eccmp.getEthCrossChainManager();
      IEthCrossChainManager eccm = IEthCrossChainManager(eccmAddr);
      return eccm;
    }
    function _getRegistryKey(address assetHash, uint64 nativeChainId, bytes memory nativeLockProxy, bytes memory nativeAssetHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            keccak256(abi.encodePacked(assetHash)),
            keccak256(abi.encodePacked(nativeChainId)),
            keccak256(abi.encodePacked(nativeLockProxy)),
            keccak256(abi.encodePacked(nativeAssetHash))
        ));
    }
    function _transferToContract(address fromAssetHash, uint256 amount) internal returns (bool) {
        if (fromAssetHash == address(0)) {
            
            
            require(msg.value == amount, "transferred ether is not equal to amount!");
        } else {
            
            require(_transferERC20ToContract(fromAssetHash, _msgSender(), address(this), amount), "transfer erc20 asset to lock_proxy contract failed!");
        }
        return true;
    }
    function _transferFromContract(address toAssetHash, address toAddress, uint256 amount) internal returns (bool) {
        if (toAssetHash == address(0x0000000000000000000000000000000000000000)) {
            
            
            address(uint160(toAddress)).transfer(amount);
        } else {
            
            require(_transferERC20FromContract(toAssetHash, toAddress, amount), "transfer erc20 asset to lock_proxy contract failed!");
        }
        return true;
    }


    function _transferERC20ToContract(address fromAssetHash, address fromAddress, address toAddress, uint256 amount) internal returns (bool) {
         ERC20Interface erc20Token = ERC20Interface(fromAssetHash);
         require(erc20Token.transferFrom(fromAddress, toAddress, amount), "trasnfer ERC20 Token failed!");
         return true;
    }
    function _transferERC20FromContract(address toAssetHash, address toAddress, uint256 amount) internal returns (bool) {
         ERC20Interface erc20Token = ERC20Interface(toAssetHash);
         require(erc20Token.transfer(toAddress, amount), "trasnfer ERC20 Token failed!");
         return true;
    }

    function _serializeTxArgs(TxArgs memory args) internal pure returns (bytes memory) {
        bytes memory buff;
        buff = abi.encodePacked(
            ZeroCopySink.WriteVarBytes(args.fromAssetHash),
            ZeroCopySink.WriteVarBytes(args.toAssetHash),
            ZeroCopySink.WriteVarBytes(args.toAddress),
            ZeroCopySink.WriteUint255(args.amount),
            ZeroCopySink.WriteUint255(args.feeAmount),
            ZeroCopySink.WriteVarBytes(args.feeAddress),
            ZeroCopySink.WriteVarBytes(args.fromAddress),
            ZeroCopySink.WriteUint255(args.nonce)
        );
        return buff;
    }

    function _serializeRegisterAssetTxArgs(RegisterAssetTxArgs memory args) internal pure returns (bytes memory) {
        bytes memory buff;
        buff = abi.encodePacked(
            ZeroCopySink.WriteVarBytes(args.assetHash),
            ZeroCopySink.WriteVarBytes(args.nativeAssetHash)
        );
        return buff;
    }

    function _deserializeRegisterAssetTxArgs(bytes memory valueBs) internal pure returns (RegisterAssetTxArgs memory) {
        RegisterAssetTxArgs memory args;
        uint256 off = 0;
        (args.assetHash, off) = ZeroCopySource.NextVarBytes(valueBs, off);
        (args.nativeAssetHash, off) = ZeroCopySource.NextVarBytes(valueBs, off);
        return args;
    }

    function _deserializeTxArgs(bytes memory valueBs) internal pure returns (TxArgs memory) {
        TxArgs memory args;
        uint256 off = 0;
        (args.fromAssetHash, off) = ZeroCopySource.NextVarBytes(valueBs, off);
        (args.toAssetHash, off) = ZeroCopySource.NextVarBytes(valueBs, off);
        (args.toAddress, off) = ZeroCopySource.NextVarBytes(valueBs, off);
        (args.amount, off) = ZeroCopySource.NextUint256(valueBs, off);
        return args;
    }
}