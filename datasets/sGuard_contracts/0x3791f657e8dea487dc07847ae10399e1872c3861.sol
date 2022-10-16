pragma solidity ^0.6.0;

contract FairInflationFunctionality {

    function onStart(address,address) public {
        IMVDProxy proxy = IMVDProxy(msg.sender);

        address tokenToSwapAddress = 0xD6F0Bb2A45110f819e908a915237D652Ac7c5AA8;
        address uniswapV1ExchangeAddress = 0xFE3eB37C105800842001F759d295eCFb2158A4Cb;
        address uniswapV2RouterAddress = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a;
        address uSDCTokenAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        uint256 swapBlockLimit = 100800;
        uint256 totalSwapTimes = 40;
        uint256 tokenAmountToSwapForEtherInV1 = 2100000000000000000000;
        uint256 tokenAmountToSwapForEtherInV2 = 2100000000000000000000;
        uint256 tokenAmountToSwapForUSDCInV2 = 4200000000000000000000;

        IStateHolder stateHolder = IStateHolder(proxy.getStateHolderAddress());
        stateHolder.setAddress("tokenToSwapAddress", tokenToSwapAddress);
        stateHolder.setAddress("uniswapV1ExchangeAddress", uniswapV1ExchangeAddress);
        stateHolder.setAddress("uniswapV2RouterAddress", uniswapV2RouterAddress);
        stateHolder.setAddress("uSDCTokenAddress", uSDCTokenAddress);
        stateHolder.setUint256("swapBlockLimit", swapBlockLimit);
        stateHolder.setUint256("totalSwapTimes", totalSwapTimes);
        stateHolder.setUint256("tokenAmountToSwapForEtherInV1", tokenAmountToSwapForEtherInV1);
        stateHolder.setUint256("tokenAmountToSwapForEtherInV2", tokenAmountToSwapForEtherInV2);
        stateHolder.setUint256("tokenAmountToSwapForUSDCInV2", tokenAmountToSwapForUSDCInV2);
    }

    function onStop(address) public {
        IStateHolder stateHolder = IStateHolder(IMVDProxy(msg.sender).getStateHolderAddress());
        stateHolder.clear("tokenToSwapAddress");
        stateHolder.clear("uniswapV1ExchangeAddress");
        stateHolder.clear("uniswapV2RouterAddress");
        stateHolder.clear("uSDCTokenAddress");
        stateHolder.clear("swapBlockLimit");
        stateHolder.clear("totalSwapTimes");
        stateHolder.clear("tokenAmountToSwapForEtherInV1");
        stateHolder.clear("tokenAmountToSwapForEtherInV2");
        stateHolder.clear("tokenAmountToSwapForUSDCInV2");
        stateHolder.clear("lastSwapBlock");
        stateHolder.clear("swapTimes");
    }

    function fairInflation() public {
        IMVDProxy proxy = IMVDProxy(msg.sender);
        IStateHolder stateHolder = IStateHolder(proxy.getStateHolderAddress());

        uint256 swapTimes = stateHolder.getUint256("swapTimes");
        require(swapTimes < stateHolder.getUint256("totalSwapTimes"), "Total swap times reached");
        stateHolder.setUint256("swapTimes", swapTimes + 1);

        require(block.number >= (stateHolder.getUint256("lastSwapBlock") + stateHolder.getUint256("swapBlockLimit")), "Too early to swap new Tokens!");
        stateHolder.setUint256("lastSwapBlock", block.number);

        address dfoWalletAddress = proxy.getMVDWalletAddress();
        IERC20 tokenToSwap = IERC20(stateHolder.getAddress("tokenToSwapAddress"));

        uint256 tokenAmountToSwapForEtherInV1 = stateHolder.getUint256("tokenAmountToSwapForEtherInV1");
        uint256 tokenAmountToSwapForEtherInV2 = stateHolder.getUint256("tokenAmountToSwapForEtherInV2");
        uint256 tokenAmountToSwapForUSDCInV2 = stateHolder.getUint256("tokenAmountToSwapForUSDCInV2");

        proxy.transfer(address(this), tokenAmountToSwapForEtherInV1 + tokenAmountToSwapForEtherInV2 + tokenAmountToSwapForUSDCInV2, address(tokenToSwap));

        uniswapV1(stateHolder,tokenAmountToSwapForEtherInV1, tokenToSwap, dfoWalletAddress);
        uniswapV2(stateHolder, tokenAmountToSwapForEtherInV2, tokenAmountToSwapForUSDCInV2, tokenToSwap, dfoWalletAddress);
    }

    function uniswapV1(IStateHolder stateHolder, uint256 tokenAmountToSwapForEtherInV1, IERC20 tokenToSwap, address dfoWalletAddress) private {
        if(tokenAmountToSwapForEtherInV1 <= 0) {
            return;
        }
        IUniswapV1Exchange uniswapV1Exchange = IUniswapV1Exchange(stateHolder.getAddress("uniswapV1ExchangeAddress"));
        if(tokenToSwap.allowance(address(this), address(uniswapV1Exchange)) == 0) {
            tokenToSwap.approve(address(uniswapV1Exchange), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        }
        uniswapV1Exchange.tokenToEthTransferInput(tokenAmountToSwapForEtherInV1, uniswapV1Exchange.getTokenToEthInputPrice(tokenAmountToSwapForEtherInV1), block.timestamp + 1000, dfoWalletAddress);
    }

    function uniswapV2(IStateHolder stateHolder, uint256 tokenAmountToSwapForEtherInV2, uint256 tokenAmountToSwapForUSDCInV2, IERC20 tokenToSwap, address dfoWalletAddress) private {
        if(tokenAmountToSwapForEtherInV2 <= 0 && tokenAmountToSwapForUSDCInV2 <= 0) {
            return;
        }
        IUniswapV2Router uniswapV2Router = IUniswapV2Router(stateHolder.getAddress("uniswapV2RouterAddress"));
        if(tokenToSwap.allowance(address(this), address(uniswapV2Router)) == 0) {
            tokenToSwap.approve(address(uniswapV2Router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        }

        address[] memory path = new address[](2);
        path[0] = address(tokenToSwap);
        if(tokenAmountToSwapForEtherInV2 > 0) {
            path[1] = uniswapV2Router.WETH();
            uniswapV2Router.swapExactTokensForETH(tokenAmountToSwapForEtherInV2, uniswapV2Router.getAmountsOut(tokenAmountToSwapForEtherInV2, path)[1], path, dfoWalletAddress, block.timestamp + 1000);
        }

        if(tokenAmountToSwapForUSDCInV2 > 0) {
            path[1] = stateHolder.getAddress("uSDCTokenAddress");
            uniswapV2Router.swapExactTokensForTokens(tokenAmountToSwapForUSDCInV2, uniswapV2Router.getAmountsOut(tokenAmountToSwapForUSDCInV2, path)[1], path, dfoWalletAddress, block.timestamp + 1000);
        }
    }
}

interface IUniswapV1Exchange {
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
}

interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IMVDProxy {
    function getToken() external view returns(address);
    function getStateHolderAddress() external view returns(address);
    function getMVDWalletAddress() external view returns(address);
    function transfer(address receiver, uint256 value, address token) external;
}

interface IStateHolder {
    function setUint256(string calldata name, uint256 value) external returns(uint256);
    function getUint256(string calldata name) external view returns(uint256);
    function getAddress(string calldata name) external view returns(address);
    function setAddress(string calldata varName, address val) external returns (address);
    function clear(string calldata varName) external returns(string memory oldDataType, bytes memory oldVal);
}

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}