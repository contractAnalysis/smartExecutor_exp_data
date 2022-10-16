pragma solidity ^0.5.7;

library BrokerData {

  struct BrokerOrder {
    address owner;
    bytes32 orderHash;
    uint fillAmountB;
    uint requestedAmountS;
    uint requestedFeeAmount;
    address tokenRecipient;
    bytes extraData;
  }

  
  struct BrokerApprovalRequest {
    BrokerOrder[] orders;
    
    address tokenS;
    
    
    address tokenB;
    address feeToken;
    
    
    uint totalFillAmountB;
    
    
    uint totalRequestedAmountS;
    uint totalRequestedFeeAmount;
  }

  struct BrokerInterceptorReport {
    address owner;
    address broker;
    bytes32 orderHash;
    address tokenB;
    address tokenS;
    address feeToken;
    uint fillAmountB;
    uint spentAmountS;
    uint spentFeeAmount;
    address tokenRecipient;
    bytes extraData;
  }

}





pragma solidity ^0.5.7;
pragma experimental ABIEncoderV2;


interface IUniswapV2Router01 {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

}



pragma solidity ^0.5.0;


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



pragma solidity ^0.5.0;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





pragma solidity ^0.5.7;


interface IBrokerDelegate {

  
  function brokerRequestAllowance(BrokerData.BrokerApprovalRequest calldata request) external returns (bool);

  
  function onOrderFillReport(BrokerData.BrokerInterceptorReport calldata fillReport) external;

  
  function brokerBalanceOf(address owner, address token) external view returns (uint);
}





pragma solidity ^0.5.7;


interface IDepositContract {

    function perform(
        address addr,
        string calldata signature,
        bytes calldata encodedParams,
        uint value
    ) external returns (bytes memory);

}





pragma solidity ^0.5.7;

library Types {

    struct RequestFee {
        address feeRecipient;
        address feeToken;
        uint feeAmount;
    }

    struct RequestSignature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    enum RequestType {Update, Transfer, Approve, Perform}

    struct Request {
        address owner;
        address target;
        RequestType requestType;
        bytes payload;
        uint nonce;
        RequestFee fee;
        RequestSignature signature;
    }

    struct TransferRequest {
        address token;
        address recipient;
        uint amount;
        bool unwrap;
    }

    struct UpdateRequest {
        address version;
        bytes additionalData;
    }

    struct ApproveRequest {
        address operator;
        bool canOperate;
    }

    struct PerformRequest {
        address to;
        string functionSignature;
        bytes encodedParams;
        uint value;
    }

}





pragma solidity ^0.5.7;



library RequestImpl {

    bytes constant personalPrefix = "\x19Ethereum Signed Message:\n32";

    function getSigner(Types.Request memory self) internal pure returns (address) {
        bytes32 messageHash = keccak256(abi.encode(
                self.owner,
                self.target,
                self.requestType,
                self.payload,
                self.nonce,
                abi.encode(self.fee.feeRecipient, self.fee.feeToken, self.fee.feeAmount)
            ));

        bytes32 prefixedHash = keccak256(abi.encodePacked(personalPrefix, messageHash));
        return ecrecover(prefixedHash, self.signature.v, self.signature.r, self.signature.s);
    }

    function decodeTransferRequest(Types.Request memory self)
    internal
    pure
    returns (Types.TransferRequest memory){
        require(self.requestType == Types.RequestType.Transfer, "INVALID_REQUEST_TYPE");

        (
        address token,
        address recipient,
        uint amount,
        bool unwrap
        ) = abi.decode(self.payload, (address, address, uint, bool));

        return Types.TransferRequest({
            token : token,
            recipient : recipient,
            amount : amount,
            unwrap : unwrap
            });
    }

    function decodeUpdateRequest(Types.Request memory self)
    internal
    pure
    returns (Types.UpdateRequest memory updateRequest)
    {
        require(self.requestType == Types.RequestType.Update, "INVALID_REQUEST_TYPE");

        (
        updateRequest.version,
        updateRequest.additionalData
        ) = abi.decode(self.payload, (address, bytes));
    }

    function decodeApproveRequest(Types.Request memory self)
    internal
    pure
    returns (Types.ApproveRequest memory approveRequest)
    {
        require(self.requestType == Types.RequestType.Approve, "INVALID_REQUEST_TYPE");

        (
        approveRequest.operator,
        approveRequest.canOperate
        ) = abi.decode(self.payload, (address, bool));
    }

    function decodePerformRequest(Types.Request memory self)
    internal
    pure
    returns (Types.PerformRequest memory performRequest)
    {
        require(self.requestType == Types.RequestType.Perform, "INVALID_REQUEST_TYPE");

        (
        performRequest.to,
        performRequest.functionSignature,
        performRequest.encodedParams,
        performRequest.value
    ) = abi.decode(self.payload, (address, string, bytes, uint));
    }

}





pragma solidity ^0.5.7;


interface IVersionable {

  
  function versionBeginUsage(
    address owner,
    address payable depositAddress,
    address oldVersion,
    bytes calldata additionalData
  ) external;

  
  function versionEndUsage(
    address owner,
    address payable depositAddress,
    address newVersion,
    bytes calldata additionalData
  ) external;

}





pragma solidity ^0.5.7;


interface IDolomiteMarginTradingBroker {
    function brokerMarginRequestApproval(address owner, address token, uint amount) external;

    function brokerMarginGetTrader(address owner, bytes calldata orderData) external view returns (address);
}





pragma solidity ^0.5.7;


interface IDepositContractRegistry {

    function depositAddressOf(address owner) external view returns (address payable);

    function operatorOf(address owner, address operator) external returns (bool);

}





pragma solidity ^0.5.7;



library DepositContractImpl {

    function wrapAndTransferToken(
        IDepositContract self,
        address token,
        address recipient,
        uint amount,
        address wethAddress
    ) internal {
        if (token == wethAddress) {
            uint etherBalance = address(self).balance;
            if (etherBalance > 0) {
                wrapEth(self, token, etherBalance);
            }
        }
        transferToken(self, token, recipient, amount);
    }

    function transferToken(IDepositContract self, address token, address recipient, uint amount) internal {
        self.perform(token, "transfer(address,uint256)", abi.encode(recipient, amount), 0);
    }

    function transferEth(IDepositContract self, address recipient, uint amount) internal {
        self.perform(recipient, "", abi.encode(), amount);
    }

    function approveToken(IDepositContract self, address token, address broker, uint amount) internal {
        self.perform(token, "approve(address,uint256)", abi.encode(broker, amount), 0);
    }

    function wrapEth(IDepositContract self, address wethToken, uint amount) internal {
        self.perform(wethToken, "deposit()", abi.encode(), amount);
    }

    function unwrapWeth(IDepositContract self, address wethToken, uint amount) internal {
        self.perform(wethToken, "withdraw(uint256)", abi.encode(amount), 0);
    }

    function setDydxOperator(IDepositContract self, address dydxContract, address operator) internal {
        bytes memory encodedParams = abi.encode(
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000020),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000001),
            operator,
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000001)
        );
        self.perform(dydxContract, "setOperators((address,bool)[])", encodedParams, 0);
    }
}

// File: contracts/dolomite-direct/Requestable.sol

contract Requestable {

    using RequestImpl for Types.Request;

    mapping(address => uint) nonces;

    function validateRequest(Types.Request memory request) internal {
        require(request.target == address(this), "INVALID_TARGET");
        require(request.getSigner() == request.owner, "INVALID_SIGNATURE");
        require(nonces[request.owner] + 1 == request.nonce, "INVALID_NONCE");

        if (request.fee.feeAmount > 0) {
            require(balanceOf(request.owner, request.fee.feeToken) >= request.fee.feeAmount, "INSUFFICIENT_FEE_BALANCE");
        }

        nonces[request.owner] += 1;
    }

    function completeRequest(Types.Request memory request) internal {
        if (request.fee.feeAmount > 0) {
            _payRequestFee(request.owner, request.fee.feeToken, request.fee.feeRecipient, request.fee.feeAmount);
        }
    }

    function nonceOf(address owner) public view returns (uint) {
        return nonces[owner];
    }

    
    function balanceOf(address owner, address token) public view returns (uint);
    function _payRequestFee(address owner, address feeToken, address feeRecipient, uint feeAmount) internal;
}




pragma solidity ^0.5.7;














contract DolomiteDirectV1 is Requestable, IVersionable, IDolomiteMarginTradingBroker {
    using DepositContractImpl for IDepositContract;
    using SafeMath for uint;

    IDepositContractRegistry public registry;
    address public loopringDelegate;
    address public dolomiteMarginProtocolAddress;
    address public dydxProtocolAddress;
    address public wethTokenAddress;

    constructor(
        address _depositContractRegistry,
        address _loopringDelegate,
        address _dolomiteMarginProtocol,
        address _dydxProtocolAddress,
        address _wethTokenAddress
    ) public {
        registry = IDepositContractRegistry(_depositContractRegistry);
        loopringDelegate = _loopringDelegate;
        dolomiteMarginProtocolAddress = _dolomiteMarginProtocol;
        dydxProtocolAddress = _dydxProtocolAddress;
        wethTokenAddress = _wethTokenAddress;
    }

    
    function balanceOf(address owner, address token) public view returns (uint) {
        address depositAddress = registry.depositAddressOf(owner);
        uint tokenBalance = IERC20(token).balanceOf(depositAddress);
        if (token == wethTokenAddress) tokenBalance = tokenBalance.add(depositAddress.balance);
        return tokenBalance;
    }

    
    function transfer(Types.Request memory request) public {
        validateRequest(request);

        Types.TransferRequest memory transferRequest = request.decodeTransferRequest();
        address payable depositAddress = registry.depositAddressOf(request.owner);

        _transfer(
            transferRequest.token,
            depositAddress,
            transferRequest.recipient,
            transferRequest.amount,
            transferRequest.unwrap
        );

        completeRequest(request);
    }

    

    function _transfer(address token, address payable depositAddress, address recipient, uint amount, bool unwrap) internal {
        IDepositContract depositContract = IDepositContract(depositAddress);

        if (token == wethTokenAddress && unwrap) {
            if (depositAddress.balance < amount) {
                depositContract.unwrapWeth(wethTokenAddress, amount.sub(depositAddress.balance));
            }

            depositContract.transferEth(recipient, amount);
            return;
        }

        depositContract.wrapAndTransferToken(token, recipient, amount, wethTokenAddress);
    }

    
    

    function brokerRequestAllowance(BrokerData.BrokerApprovalRequest memory request) public returns (bool) {
        require(msg.sender == loopringDelegate);

        BrokerData.BrokerOrder[] memory mergedOrders = new BrokerData.BrokerOrder[](request.orders.length);
        uint numMergedOrders = 1;

        mergedOrders[0] = request.orders[0];

        if (request.orders.length > 1) {
            for (uint i = 1; i < request.orders.length; i++) {
                bool isDuplicate = false;

                for (uint b = 0; b < numMergedOrders; b++) {
                    if (request.orders[i].owner == mergedOrders[b].owner) {
                        mergedOrders[b].requestedAmountS += request.orders[i].requestedAmountS;
                        mergedOrders[b].requestedFeeAmount += request.orders[i].requestedFeeAmount;
                        isDuplicate = true;
                        break;
                    }
                }

                if (!isDuplicate) {
                    mergedOrders[numMergedOrders] = request.orders[i];
                    numMergedOrders += 1;
                }
            }
        }

        for (uint j = 0; j < numMergedOrders; j++) {
            BrokerData.BrokerOrder memory order = mergedOrders[j];
            address payable depositAddress = registry.depositAddressOf(order.owner);

            _transfer(request.tokenS, depositAddress, address(this), order.requestedAmountS, false);
            if (order.requestedFeeAmount > 0) _transfer(request.feeToken, depositAddress, address(this), order.requestedFeeAmount, false);
        }

        return false;
        
    }

    function onOrderFillReport(BrokerData.BrokerInterceptorReport memory fillReport) public {
        
    }

    function brokerBalanceOf(address owner, address tokenAddress) public view returns (uint) {
        return balanceOf(owner, tokenAddress);
    }

    
    

    function brokerMarginRequestApproval(address owner, address token, uint amount) public {
        require(msg.sender == dolomiteMarginProtocolAddress || msg.sender == loopringDelegate, "brokerMarginRequestApproval: INVALID_SENDER");

        address payable depositAddress = registry.depositAddressOf(owner);
        _transfer(token, depositAddress, address(this), amount, false);
    }

    function brokerMarginGetTrader(address owner, bytes memory orderData) public view returns (address) {
        return registry.depositAddressOf(owner);
    }

    
    

    function _payRequestFee(address owner, address feeToken, address feeRecipient, uint feeAmount) internal {
        _transfer(feeToken, registry.depositAddressOf(owner), feeRecipient, feeAmount, false);
    }

    
    

    function versionBeginUsage(
        address owner,
        address payable depositAddress,
        address oldVersion,
        bytes calldata additionalData
    ) external {
        
        IDepositContract(depositAddress).setDydxOperator(dydxProtocolAddress, dolomiteMarginProtocolAddress);
    }

    function versionEndUsage(
        address owner,
        address payable depositAddress,
        address newVersion,
        bytes calldata additionalData
    ) external {}


    
    

    
    function enableTrading(address token) public {
        IERC20(token).approve(loopringDelegate, 10 ** 70);
        IERC20(token).approve(dolomiteMarginProtocolAddress, 10 ** 70);
    }

    function enableTrading(address[] calldata tokens) external {
        for (uint i = 0; i < tokens.length; i++) {
            enableTrading(tokens[i]);
        }
    }

}



pragma solidity ^0.5.0;




library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}





pragma solidity ^0.5.0;

library SafeEther {

    function toPayable(address _address) internal pure returns (address payable) {
        return address(uint160(_address));
    }

    function safeTransferEther(address recipient, uint amount) internal {
        safeTransferEther(recipient, amount, "CANNOT_TRANSFER_ETHER");
    }

    function safeTransferEther(address recipient, uint amount, string memory errorMessage) internal {
        (bool success,) = address(uint160(recipient)).call.value(amount)("");
        require(success, errorMessage);
    }

}

// File: contracts/market-making/helper/MakerBrokerBase.sol

/*
 * Copyright 2020 Dolomite
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http:
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.5.7;





contract MakerBrokerBase {

    using SafeEther for address payable;
    using SafeERC20 for IERC20;

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0x0), "ZERO_ADDRESS");
        owner = newOwner;
    }

    function withdrawDust(address token) external {
        _withdrawDust(token, msg.sender);
    }

    function withdrawDust(address token, address recipient) external {
        _withdrawDust(token, recipient);
    }

    function withdrawEthDust() external {
        _withdrawEthDust(msg.sender);
    }

    function withdrawEthDust(address payable recipient) external {
        _withdrawEthDust(recipient);
    }

    function _withdrawDust(address token, address recipient) internal {
        require(msg.sender == owner, "UNAUTHORIZED");
        IERC20(token).safeTransfer(
            recipient,
            IERC20(token).balanceOf(address(this))
        );
    }

    function _withdrawEthDust(address payable recipient) internal {
        require(msg.sender == owner, "UNAUTHORIZED");
        recipient.safeTransferEther(address(this).balance);
    }

}





pragma solidity ^0.5.7;

interface IWETH {
  event Deposit(address indexed src, uint wad);
  event Withdraw(address indexed src, uint wad);

  function deposit() external payable;
  function withdraw(uint wad) external;
}





pragma solidity ^0.5.7;







contract UniswapV2MakerBroker is MakerBrokerBase, IBrokerDelegate {

    address public wethTokenAddress;
    address public loopringDelegate;
    IUniswapV2Router01 public uniswapV2Router;

    mapping(address => address) public tokenToExchange;
    mapping(address => bool) public tokenToIsSetup;

    constructor(address _loopringDelegate, address _uniswapV2Router, address _wethTokenAddress) public {
        loopringDelegate = _loopringDelegate;
        wethTokenAddress = _wethTokenAddress;
        uniswapV2Router = IUniswapV2Router01(_uniswapV2Router);
    }

    function setupToken(address token) public {
        IERC20(token).safeApprove(loopringDelegate, uint(- 1));
        IERC20(token).safeApprove(address(uniswapV2Router), uint(- 1));
        tokenToIsSetup[token] = true;
    }

    function setupTokens(address[] calldata tokens) external {
        for (uint i = 0; i < tokens.length; i++) {
            setupToken(tokens[i]);
        }
    }

    function() external payable {
        revert("UniswapV2MakerBroker: NO_DEFAULT");
    }

    
    

    function brokerRequestAllowance(BrokerData.BrokerApprovalRequest memory request) public returns (bool) {
        require(msg.sender == loopringDelegate, "UniswapV2MakerBroker: UNAUTHORIZED");
        require(tokenToIsSetup[request.tokenS], "UniswapV2MakerBroker: TOKEN_S_NOT_SETUP");

        for (uint i = 0; i < request.orders.length; i++) {
            require(request.orders[i].tokenRecipient == address(this), "UniswapV2MakerBroker: INVALID_TOKEN_RECIPIENT");
            require(request.orders[i].owner == owner, "UniswapV2MakerBroker: INVALID_ORDER_OWNER");
        }

        address[] memory intermediatePaths;
        if (request.orders[0].extraData.length == 0) {
            intermediatePaths = new address[](0);
        } else {
            intermediatePaths = abi.decode(request.orders[0].extraData, (address[]));
        }

        address[] memory path = new address[](intermediatePaths.length + 2);
        path[0] = request.tokenB;
        for (uint i = 0; i < intermediatePaths.length; i++) {
            path[i + 1] = intermediatePaths[i];
        }
        path[path.length - 1] = request.tokenS;

        
        uniswapV2Router.swapExactTokensForTokens(
            request.totalFillAmountB,
            request.totalRequestedAmountS,
            path,
            address(this),
            block.timestamp
        );

        
        return false;
    }

    function onOrderFillReport(BrokerData.BrokerInterceptorReport memory fillReport) public {
        
    }

    
    function brokerBalanceOf(address owner, address tokenAddress) public view returns (uint) {
        return uint(- 1);
    }

}