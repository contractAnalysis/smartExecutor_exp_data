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


interface IBrokerDelegate {

  
  function brokerRequestAllowance(BrokerData.BrokerApprovalRequest calldata request) external returns (bool);

  
  function onOrderFillReport(BrokerData.BrokerInterceptorReport calldata fillReport) external;

  
  function brokerBalanceOf(address owner, address token) external view returns (uint);
}





pragma solidity ^0.5.7;







contract UniswapRebalancerMakerBroker is MakerBrokerBase, IBrokerDelegate {

    address internal _wethTokenAddress;
    address internal _loopringDelegate;
    address internal _uniswapV2Router;
    uint8 internal _slippageFactor;

    mapping(address => address) public tokenToExchange;
    mapping(address => bool) public tokenToIsSetup;

    constructor(address loopringDelegate, address uniswapV2Router, address wethTokenAddress) public {
        _loopringDelegate = loopringDelegate;
        _wethTokenAddress = wethTokenAddress;
        _uniswapV2Router = uniswapV2Router;
        _slippageFactor = 4;
    }

    function setupToken(address token) public {
        IERC20(token).safeApprove(_loopringDelegate, uint(- 1));
        IERC20(token).safeApprove(_uniswapV2Router, uint(- 1));
        tokenToIsSetup[token] = true;
    }

    function setupTokens(address[] calldata tokens) external {
        for (uint i = 0; i < tokens.length; i++) {
            setupToken(tokens[i]);
        }
    }

    function setSlippageFactor(uint8 slippageFactor) external onlyOwner {
        _slippageFactor = slippageFactor;
    }

    function getSlippageFactor() external view returns (uint8) {
        return _slippageFactor;
    }

    function() external payable {
        revert("UniswapRebalancerMakerBroker: NO_DEFAULT");
    }

    
    

    function brokerRequestAllowance(BrokerData.BrokerApprovalRequest memory request) public returns (bool) {
        require(msg.sender == _loopringDelegate, "UniswapRebalancerMakerBroker: UNAUTHORIZED");
        require(tokenToIsSetup[request.tokenS], "UniswapRebalancerMakerBroker: TOKEN_S_NOT_SETUP");

        for (uint i = 0; i < request.orders.length; i++) {
            require(request.orders[i].tokenRecipient == address(this), "UniswapRebalancerMakerBroker: INVALID_TOKEN_RECIPIENT");
            require(request.orders[i].owner == owner, "UniswapRebalancerMakerBroker: INVALID_ORDER_OWNER");
        }

        address[] memory intermediatePaths;
        if (request.orders[0].extraData.length == 0) {
            intermediatePaths = new address[](0);
        } else {
            intermediatePaths = abi.decode(request.orders[0].extraData, (address[]));
        }

        if (intermediatePaths.length == 0 || intermediatePaths[0] != address(0x0000000000000000000000000000000000000001)) {
            address[] memory path = new address[](intermediatePaths.length + 2);
            path[0] = request.tokenB;
            for (uint i = 0; i < intermediatePaths.length; i++) {
                path[i + 1] = intermediatePaths[i];
            }
            path[path.length - 1] = request.tokenS;

            
            IUniswapV2Router01(_uniswapV2Router).swapExactTokensForTokens(
                request.totalFillAmountB,
                request.totalRequestedAmountS / uint(_slippageFactor),
                path,
                address(this),
                block.timestamp
            );
        }

        
        return false;
    }

    function onOrderFillReport(BrokerData.BrokerInterceptorReport memory fillReport) public {
        
    }

    
    function brokerBalanceOf(address owner, address token) public view returns (uint) {
        return uint(- 1);
    }

    function balanceOf(address token) public view returns (uint) {
        return IERC20(token).balanceOf(address(this));
    }

}