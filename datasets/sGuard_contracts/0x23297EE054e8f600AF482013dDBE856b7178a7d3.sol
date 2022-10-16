pragma solidity 0.5.9;
pragma experimental ABIEncoderV2;




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



contract WETH9 {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() external payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}



contract LibOrder
{
    
    
    enum OrderStatus {
        INVALID,                     
        INVALID_MAKER_ASSET_AMOUNT,  
        INVALID_TAKER_ASSET_AMOUNT,  
        FILLABLE,                    
        EXPIRED,                     
        FULLY_FILLED,                
        CANCELLED                    
    }

    struct Order {
        address makerAddress;           
        address takerAddress;           
        address feeRecipientAddress;    
        address senderAddress;          
        uint256 makerAssetAmount;       
        uint256 takerAssetAmount;       
        uint256 makerFee;               
        uint256 takerFee;               
        uint256 expirationTimeSeconds;  
        uint256 salt;                   
        bytes makerAssetData;           
        bytes takerAssetData;           
        bytes makerFeeAssetData;        
        bytes takerFeeAssetData;        
    }

    struct OrderInfo {
        OrderStatus orderStatus;                    
        bytes32 orderHash;                    
        uint256 orderTakerAssetFilledAmount;  
    }
}



contract LibFillResults
{
    struct BatchMatchedFillResults {
        FillResults[] left;              
        FillResults[] right;             
        uint256 profitInLeftMakerAsset;  
        uint256 profitInRightMakerAsset; 
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;  
        uint256 takerAssetFilledAmount;  
        uint256 makerFeePaid;            
        uint256 takerFeePaid;            
        uint256 protocolFeePaid;         
    }

    struct MatchedFillResults {
        FillResults left;                
        FillResults right;               
        uint256 profitInLeftMakerAsset;  
        uint256 profitInRightMakerAsset; 
    }
}



library LibZeroExTransaction {

    struct ZeroExTransaction {
        uint256 salt;                   
        uint256 expirationTimeSeconds;  
        uint256 gasPrice;               
        address signerAddress;          
        bytes data;                     
    }
}



library LibBytesRichErrors {

    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}



library LibRichErrors {

    
    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

    
    
    
    
    
    
    function StandardError(
        string memory message
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }
    

    
    
    function rrevert(bytes memory errorData)
        internal
        pure
    {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}



library LibBytes {

    using LibBytes for bytes;

    
    
    
    
    
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    
    
    
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    
    
    
    
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
            
            
            
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            
            if (source == dest) {
                return;
            }

            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if (source > dest) {
                assembly {
                    
                    
                    
                    
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    
                    
                    
                    
                    let last := mload(sEnd)

                    
                    
                    
                    
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    
                    
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    
                    
                    
                    
                    let first := mload(source)

                    
                    
                    
                    
                    
                    
                    
                    
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    
                    mstore(dest, first)
                }
            }
        }
    }

    
    
    
    
    
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        
        
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    
    
    
    
    
    
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        
        
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    
    
    
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

        
        result = b[b.length - 1];

        assembly {
            
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    
    
    
    
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        
        
        
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    
    
    
    
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 
            ));
        }

        
        
        
        index += 20;

        
        assembly {
            
            
            
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    
    
    
    
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 
            ));
        }

        
        
        
        index += 20;

        
        assembly {
            
            
            
            

            
            
            
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            
            
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    
    
    
    
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        
        index += 32;

        
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    
    
    
    
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        
        index += 32;

        
        assembly {
            mstore(add(b, index), input)
        }
    }

    
    
    
    
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    
    
    
    
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    
    
    
    
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

        
        index += 32;

        
        assembly {
            result := mload(add(b, index))
            
            
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    
    
    
    
    
    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}



contract IExchangeCore {

    
    event Fill(
        address indexed makerAddress,         
        address indexed feeRecipientAddress,  
        bytes makerAssetData,                 
        bytes takerAssetData,                 
        bytes makerFeeAssetData,              
        bytes takerFeeAssetData,              
        bytes32 indexed orderHash,            
        address takerAddress,                 
        address senderAddress,                
        uint256 makerAssetFilledAmount,       
        uint256 takerAssetFilledAmount,       
        uint256 makerFeePaid,                 
        uint256 takerFeePaid,                 
        uint256 protocolFeePaid               
    );

    
    event Cancel(
        address indexed makerAddress,         
        address indexed feeRecipientAddress,  
        bytes makerAssetData,                 
        bytes takerAssetData,                 
        address senderAddress,                
        bytes32 indexed orderHash             
    );

    
    event CancelUpTo(
        address indexed makerAddress,         
        address indexed orderSenderAddress,   
        uint256 orderEpoch                    
    );

    
    
    
    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external
        payable;

    
    
    
    
    
    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    function cancelOrder(LibOrder.Order memory order)
        public
        payable;

    
    
    
    
    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);
}



contract IProtocolFees {

    
    event ProtocolFeeMultiplier(uint256 oldProtocolFeeMultiplier, uint256 updatedProtocolFeeMultiplier);

    
    event ProtocolFeeCollectorAddress(address oldProtocolFeeCollector, address updatedProtocolFeeCollector);

    
    
    function setProtocolFeeMultiplier(uint256 updatedProtocolFeeMultiplier)
        external;

    
    
    function setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector)
        external;

    
    function protocolFeeMultiplier()
        external
        view
        returns (uint256);

    
    function protocolFeeCollector()
        external
        view
        returns (address);
}



contract IMatchOrders {

    
    
    
    
    
    
    
    
    function batchMatchOrders(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures
    )
        public
        payable
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults);

    
    
    
    
    
    
    
    
    
    function batchMatchOrdersWithMaximalFill(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures
    )
        public
        payable
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults);

    
    
    
    
    
    
    
    
    
    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        payable
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);

    
    
    
    
    
    
    
    
    
    function matchOrdersWithMaximalFill(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        payable
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);
}



contract ISignatureValidator {

   
    enum SignatureType {
        Illegal,                     
        Invalid,                     
        EIP712,                      
        EthSign,                     
        Wallet,                      
        Validator,                   
        PreSigned,                   
        EIP1271Wallet,               
        NSignatureTypes              
    }

    event SignatureValidatorApproval(
        address indexed signerAddress,     
        address indexed validatorAddress,  
        bool isApproved                    
    );

    
    
    
    function preSign(bytes32 hash)
        external
        payable;

    
    
    
    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external
        payable;

    
    
    
    
    function isValidHashSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);

    
    
    
    
    function isValidOrderSignature(
        LibOrder.Order memory order,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);

    
    
    
    
    function isValidTransactionSignature(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);

    
    
    
    
    
    
    function _isValidOrderWithHashSignature(
        LibOrder.Order memory order,
        bytes32 orderHash,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid);

    
    
    
    
    
    
    function _isValidTransactionWithHashSignature(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes32 transactionHash,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid);
}



contract ITransactions {

    
    event TransactionExecution(bytes32 indexed transactionHash);

    
    
    
    
    function executeTransaction(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        public
        payable
        returns (bytes memory);

    
    
    
    
    function batchExecuteTransactions(
        LibZeroExTransaction.ZeroExTransaction[] memory transactions,
        bytes[] memory signatures
    )
        public
        payable
        returns (bytes[] memory);

    
    
    
    
    
    function _getCurrentContextAddress()
        internal
        view
        returns (address);
}



contract IAssetProxyDispatcher {

    
    event AssetProxyRegistered(
        bytes4 id,              
        address assetProxy      
    );

    
    
    
    function registerAssetProxy(address assetProxy)
        external;

    
    
    
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);
}



contract IWrapperFunctions {

    
    
    
    
    function fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    
    
    
    function batchFillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);

    
    
    
    
    
    function batchFillOrKillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);

    
    
    
    
    
    function batchFillOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);

    
    
    
    
    
    
    
    function marketSellOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    
    
    
    
    
    function marketBuyOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    
    
    
    
    function marketSellOrdersFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    
    
    
    
    function marketBuyOrdersFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    function batchCancelOrders(LibOrder.Order[] memory orders)
        public
        payable;
}



contract ITransferSimulator {

    
    
    
    
    
    
    
    
    
    
    
    function simulateDispatchTransferFromCalls(
        bytes[] memory assetData,
        address[] memory fromAddresses,
        address[] memory toAddresses,
        uint256[] memory amounts
    )
        public;
}



contract IExchange is
    IProtocolFees,
    IExchangeCore,
    IMatchOrders,
    ISignatureValidator,
    ITransactions,
    IAssetProxyDispatcher,
    ITransferSimulator,
    IWrapperFunctions
{}




interface ExchangeReader {

    

    
    function getMaxMakerAmount(
        address makerToken,
        address takerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256);
}




interface ExchangeWrapper {

    

    
    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256);

    
    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256);
}




library MathHelpers {
    using SafeMath for uint256;

    
    function getPartialAmount(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {
        return numerator.mul(target).div(denominator);
    }

    
    function getPartialAmountRoundedUp(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {
        return divisionRoundedUp(numerator.mul(target), denominator);
    }

    
    function divisionRoundedUp(
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {
        assert(denominator != 0); 
        if (numerator == 0) {
            return 0;
        }
        return numerator.sub(1).div(denominator).add(1);
    }

    
    function maxUint256(
    )
        internal
        pure
        returns (uint256)
    {
        return 2 ** 256 - 1;
    }

    
    function maxUint32(
    )
        internal
        pure
        returns (uint32)
    {
        return 2 ** 32 - 1;
    }

    
    function getNumBits(
        uint256 n
    )
        internal
        pure
        returns (uint256)
    {
        uint256 first = 0;
        uint256 last = 256;
        while (first < last) {
            uint256 check = (first + last) / 2;
            if ((n >> check) == 0) {
                last = check;
            } else {
                first = check + 1;
            }
        }
        assert(first <= 256);
        return first;
    }
}




interface GeneralERC20 {
    function totalSupply(
    )
        external
        view
        returns (uint256);

    function balanceOf(
        address who
    )
        external
        view
        returns (uint256);

    function allowance(
        address owner,
        address spender
    )
        external
        view
        returns (uint256);

    function transfer(
        address to,
        uint256 value
    )
        external;


    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external;

    function approve(
        address spender,
        uint256 value
    )
        external;
}




library TokenInteract {
    function balanceOf(
        address token,
        address owner
    )
        internal
        view
        returns (uint256)
    {
        return GeneralERC20(token).balanceOf(owner);
    }

    function allowance(
        address token,
        address owner,
        address spender
    )
        internal
        view
        returns (uint256)
    {
        return GeneralERC20(token).allowance(owner, spender);
    }

    function approve(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {
        GeneralERC20(token).approve(spender, amount);

        require(
            checkSuccess(),
            "TokenInteract#approve: Approval failed"
        );
    }

    function transfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {
        address from = address(this);
        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transfer(to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transfer: Transfer failed"
        );
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transferFrom(from, to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transferFrom: TransferFrom failed"
        );
    }

    

    
    function checkSuccess(
    )
        private
        pure
        returns (bool)
    {
        uint256 returnValue = 0;

        
        assembly {
            
            switch returndatasize

            
            case 0x0 {
                returnValue := 1
            }

            
            case 0x20 {
                
                returndatacopy(0x0, 0x0, 0x20)

                
                returnValue := mload(0x0)
            }

            
            default { }
        }

        return returnValue != 0;
    }
}




library AdvancedTokenInteract {
    using TokenInteract for address;

    
    function ensureAllowance(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {
        if (token.allowance(address(this), spender) < amount) {
            token.approve(spender, MathHelpers.maxUint256());
        }
    }
}




contract ZeroExV3ExchangeWrapper is
    ExchangeWrapper,
    ExchangeReader
{
    bytes4 constant internal ERC20_PROXY_ID = 0xf47261b0;
    bytes4 constant internal ERC20_BRIDGE_PROXY_ID = 0xdc1600f3;

    using LibBytes for bytes;
    using SafeMath for uint256;
    using TokenInteract for address;
    using AdvancedTokenInteract for address;

    

    
    address public ZERO_EX_EXCHANGE;

    
    address public ZERO_EX_TOKEN_PROXY;

    
    WETH9 public WETH;

    

    constructor(
        address zeroExExchange,
        address zeroExProxy,
        address payable wethToken
    )
        public
    {
        ZERO_EX_EXCHANGE = zeroExExchange;
        ZERO_EX_TOKEN_PROXY = zeroExProxy;
        WETH = WETH9(wethToken);
    }

    

    
    function()
        external
        payable
    {
        require(
            msg.sender == address(WETH),
            "Cannot receive ETH"
        );
    }

    
    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256)
    {
        
        (LibOrder.Order memory order, bytes memory signature) = parseSignedOrder(
            orderData,
            makerToken,
            takerToken
        );

        
        takerToken.ensureAllowance(
            ZERO_EX_TOKEN_PROXY,
            requestedFillAmount
        );

        
        IExchange v3Exchange = IExchange(ZERO_EX_EXCHANGE);
        LibFillResults.FillResults memory fill = v3Exchange.fillOrKillOrder(
            order,
            requestedFillAmount,
            signature
        );

        
        makerToken.ensureAllowance(receiver, fill.makerAssetFilledAmount);

        
        uint256 protocolFeeRefund = WETH.balanceOf(address(this));
        if (makerToken == address(WETH)) {
            protocolFeeRefund = protocolFeeRefund.sub(fill.makerAssetFilledAmount);
        }
        if (protocolFeeRefund != 0) {
            WETH.withdraw(protocolFeeRefund);
            address(uint160(tradeOriginator)).transfer(protocolFeeRefund);
        }

        return fill.makerAssetFilledAmount;
    }

    
    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256)
    {
        (LibOrder.Order memory order, ) = parseSignedOrder(
            orderData,
            makerToken,
            takerToken
        );

        return MathHelpers.getPartialAmountRoundedUp(
            order.takerAssetAmount,
            order.makerAssetAmount,
            desiredMakerToken
        );
    }

    
    function getMaxMakerAmount(
        address makerToken,
        address takerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256)
    {
        (LibOrder.Order memory order, ) = parseSignedOrder(
            orderData,
            makerToken,
            takerToken
        );
        IExchange v3Exchange = IExchange(ZERO_EX_EXCHANGE);
        LibOrder.OrderInfo memory orderInfo = v3Exchange.getOrderInfo(order);

        if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE) {
            return 0;
        }

        uint256 remainingTakerAssetAmount =
            order.takerAssetAmount.sub(orderInfo.orderTakerAssetFilledAmount);

        return MathHelpers.getPartialAmount(
            remainingTakerAssetAmount,
            order.takerAssetAmount,
            order.makerAssetAmount
        );
    }

    
    function approveProtocolFeeCollector() external {
        IExchange v3Exchange = IExchange(ZERO_EX_EXCHANGE);
        address protocolFeeCollector = v3Exchange.protocolFeeCollector();
        if (protocolFeeCollector != address(0)) {
            WETH.approve(
                protocolFeeCollector,
                MathHelpers.maxUint256()
            );
        }
    }

    

    
    function parseSignedOrder(
        bytes memory orderData,
        address makerToken,
        address takerToken
    )
        private
        pure
        returns (LibOrder.Order memory, bytes memory)
    {
        (LibOrder.Order memory order, bytes memory signature) = abi.decode(
            orderData,
            (LibOrder.Order, bytes)
        );
        order.makerAssetData = overwriteAssetDataTokenAddress(order.makerAssetData, makerToken);
        order.takerAssetData = overwriteAssetDataTokenAddress(order.takerAssetData, takerToken);

        return (order, signature);
    }

    
    function overwriteAssetDataTokenAddress(
        bytes memory assetData,
        address token
    )
        private
        pure
        returns (bytes memory)
    {
        bytes4 assetProxyId = assetData.readBytes4(0);
        require(
            assetProxyId == ERC20_PROXY_ID || assetProxyId == ERC20_BRIDGE_PROXY_ID,
            "ZeroExV3ExchangeWrapper#overwriteAssetDataTokenAddress: invalid asset proxy id"
        );

        bytes memory newAssetData = assetData;
        newAssetData.writeAddress(16, token);
        return newAssetData;
    }
}