pragma solidity ^0.6.0;

contract NERVFairInflationV2 {

    
    
    
    function onStart(address,address) public {
        
        IMVDProxy proxy = IMVDProxy(msg.sender);

        
        address buidlTokenAddress = 0x7b123f53421b1bF8533339BFBdc7C98aA94163db;

        
        address arteTokenAddress = 0x44b6e3e85561ce054aB13Affa0773358D795D36D;

        
        address uSDCTokenAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

        
        address uniswapV2RouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

        
        uint256 swapBlockLimit = 6300;

        
        uint256 buidlAmountToSwapForEtherInV2 = 300000000000000000000;

        
        uint256 buidlAmountToSwapForUSDCInV2 = 300000000000000000000;

        
        uint256 arteAmountToSwapForEtherInV2 = 157000000000000000000;

        
        uint256 arteAmountToSwapForBuidlInV2 = 157000000000000000000;

        
        IStateHolder stateHolder = IStateHolder(proxy.getStateHolderAddress());
        stateHolder.setAddress("buidlTokenAddress", buidlTokenAddress);
        stateHolder.setAddress("arteTokenAddress", arteTokenAddress);
        stateHolder.setAddress("uSDCTokenAddress", uSDCTokenAddress);
        stateHolder.setAddress("uniswapV2RouterAddress", uniswapV2RouterAddress);
        stateHolder.setUint256("swapBlockLimit", swapBlockLimit);
        stateHolder.setUint256("buidlAmountToSwapForEtherInV2", buidlAmountToSwapForEtherInV2);
        stateHolder.setUint256("buidlAmountToSwapForUSDCInV2", buidlAmountToSwapForUSDCInV2);
        stateHolder.setUint256("arteAmountToSwapForEtherInV2", arteAmountToSwapForEtherInV2);
        stateHolder.setUint256("arteAmountToSwapForBuidlInV2", arteAmountToSwapForBuidlInV2);
    }

    
    
    function onStop(address) public {
        IStateHolder stateHolder = IStateHolder(IMVDProxy(msg.sender).getStateHolderAddress());
        stateHolder.clear("buidlTokenAddress");
        stateHolder.clear("arteTokenAddress");
        stateHolder.clear("uSDCTokenAddress");
        stateHolder.clear("uniswapV2RouterAddress");
        stateHolder.clear("swapBlockLimit");
        stateHolder.clear("buidlAmountToSwapForEtherInV2");
        stateHolder.clear("buidlAmountToSwapForUSDCInV2");
        stateHolder.clear("arteAmountToSwapForEtherInV2");
        stateHolder.clear("arteAmountToSwapForBuidlInV2");
        stateHolder.clear("lastSwapBlock");
    }

    
    
    
    function fairInflation() public {
        
        IMVDProxy proxy = IMVDProxy(msg.sender);
        IStateHolder stateHolder = IStateHolder(proxy.getStateHolderAddress());

        

        
        require(block.number >= (stateHolder.getUint256("lastSwapBlock") + stateHolder.getUint256("swapBlockLimit")), "Too early to swap new Tokens!");

        
        stateHolder.setUint256("lastSwapBlock", block.number);

        
        address dfoWalletAddress = proxy.getMVDWalletAddress();

        
        IERC20 buidlToken = IERC20(stateHolder.getAddress("buidlTokenAddress"));

        IUniswapV2Router uniswapV2Router = IUniswapV2Router(stateHolder.getAddress("uniswapV2RouterAddress"));

        address wethTokenAddress = uniswapV2Router.WETH();

        _swapBuidl(proxy, stateHolder, buidlToken, uniswapV2Router, wethTokenAddress, dfoWalletAddress);

        _swapArte(proxy, stateHolder, buidlToken, uniswapV2Router, wethTokenAddress, dfoWalletAddress);
    }

    function _swapBuidl(IMVDProxy proxy, IStateHolder stateHolder, IERC20 buidlToken, IUniswapV2Router uniswapV2Router, address wethTokenAddress, address dfoWalletAddress) private {
        
        uint256 buidlAmountToSwapForEtherInV2 = stateHolder.getUint256("buidlAmountToSwapForEtherInV2");

        
        uint256 buidlAmountToSwapForUSDCInV2 = stateHolder.getUint256("buidlAmountToSwapForUSDCInV2");

        
        proxy.transfer(address(this), buidlAmountToSwapForEtherInV2 + buidlAmountToSwapForUSDCInV2, address(buidlToken));

        
        _uniswapV2Buidl(stateHolder, buidlAmountToSwapForEtherInV2, buidlAmountToSwapForUSDCInV2, buidlToken, uniswapV2Router, wethTokenAddress, dfoWalletAddress);
    }

    
    function _uniswapV2Buidl(IStateHolder stateHolder, uint256 buidlAmountToSwapForEtherInV2, uint256 buidlAmountToSwapForUSDCInV2, IERC20 buidlToken, IUniswapV2Router uniswapV2Router, address wethTokenAddress, address dfoWalletAddress) private {
        
        if(buidlAmountToSwapForEtherInV2 <= 0 && buidlAmountToSwapForUSDCInV2 <= 0) {
            return;
        }

        
        if(buidlToken.allowance(address(this), address(uniswapV2Router)) == 0) {
            buidlToken.approve(address(uniswapV2Router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        }

        address[] memory path = new address[](2);
        path[0] = address(buidlToken);

        
        if(buidlAmountToSwapForEtherInV2 > 0) {
            path[1] = wethTokenAddress;
            uniswapV2Router.swapExactTokensForETH(buidlAmountToSwapForEtherInV2, uniswapV2Router.getAmountsOut(buidlAmountToSwapForEtherInV2, path)[1], path, dfoWalletAddress, block.timestamp + 1000);
        }

        
        if(buidlAmountToSwapForUSDCInV2 > 0) {
            path[1] = stateHolder.getAddress("uSDCTokenAddress");
            uniswapV2Router.swapExactTokensForTokens(buidlAmountToSwapForUSDCInV2, uniswapV2Router.getAmountsOut(buidlAmountToSwapForUSDCInV2, path)[1], path, dfoWalletAddress, block.timestamp + 1000);
        }
    }

    function _swapArte(IMVDProxy proxy, IStateHolder stateHolder, IERC20 buidlToken, IUniswapV2Router uniswapV2Router, address wethTokenAddress, address dfoWalletAddress) private {

        IERC20 arteToken = IERC20(stateHolder.getAddress("arteTokenAddress"));

        
        uint256 arteAmountToSwapForEtherInV2 = stateHolder.getUint256("arteAmountToSwapForEtherInV2");

        
        uint256 arteAmountToSwapForBuidlInV2 = stateHolder.getUint256("arteAmountToSwapForBuidlInV2");

        
        proxy.transfer(address(this), arteAmountToSwapForEtherInV2 + arteAmountToSwapForBuidlInV2, address(arteToken));

        
        _uniswapV2Arte(stateHolder, arteAmountToSwapForEtherInV2, arteAmountToSwapForBuidlInV2, buidlToken, arteToken, uniswapV2Router, wethTokenAddress, dfoWalletAddress);
    }

    
    function _uniswapV2Arte(IStateHolder stateHolder, uint256 arteAmountToSwapForEtherInV2, uint256 arteAmountToSwapForBuidlInV2, IERC20 buidlToken, IERC20 arteToken, IUniswapV2Router uniswapV2Router, address wethTokenAddress, address dfoWalletAddress) private {
        
        if(arteAmountToSwapForEtherInV2 <= 0 && arteAmountToSwapForBuidlInV2 <= 0) {
            return;
        }

        
        if(arteToken.allowance(address(this), address(uniswapV2Router)) == 0) {
            arteToken.approve(address(uniswapV2Router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        }

        address[] memory path = new address[](2);
        path[0] = address(arteToken);

        
        if(arteAmountToSwapForEtherInV2 > 0) {
            path[1] = wethTokenAddress;
            uniswapV2Router.swapExactTokensForETH(arteAmountToSwapForEtherInV2, uniswapV2Router.getAmountsOut(arteAmountToSwapForEtherInV2, path)[1], path, dfoWalletAddress, block.timestamp + 1000);
        }

        
        if(arteAmountToSwapForBuidlInV2 > 0) {
            path[1] = address(buidlToken);
            uniswapV2Router.swapExactTokensForTokens(arteAmountToSwapForBuidlInV2, uniswapV2Router.getAmountsOut(arteAmountToSwapForBuidlInV2, path)[1], path, dfoWalletAddress, block.timestamp + 1000);
        }
    }
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