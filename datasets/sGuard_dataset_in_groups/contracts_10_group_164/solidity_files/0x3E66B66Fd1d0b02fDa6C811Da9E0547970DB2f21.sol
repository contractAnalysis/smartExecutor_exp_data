pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

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


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface PoolInterface {
    function swapExactAmountIn(address, uint, address, uint, uint) external returns (uint, uint);
    function swapExactAmountOut(address, uint, address, uint, uint) external returns (uint, uint);
    function calcInGivenOut(uint, uint, uint, uint, uint, uint) external pure returns (uint);
    function calcOutGivenIn(uint, uint, uint, uint, uint, uint) external pure returns (uint);
    function getDenormalizedWeight(address) external view returns (uint);
    function getBalance(address) external view returns (uint);
    function getSwapFee() external view returns (uint);
}

interface TokenInterface {
    function balanceOf(address) external view returns (uint);
    function allowance(address, address) external view returns (uint);
    function approve(address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
}

interface RegistryInterface {
    function getBestPoolsWithLimit(address, address, uint) external view returns (address[] memory);
}

contract ExchangeProxy is Ownable {

    using SafeMath for uint256;

    struct Pool {
        address pool;
        uint    tokenBalanceIn;
        uint    tokenWeightIn;
        uint    tokenBalanceOut;
        uint    tokenWeightOut;
        uint    swapFee;
        uint    effectiveLiquidity;
    }

    struct Swap {
        address pool;
        address tokenIn;
        address tokenOut;
        uint    swapAmount; 
        uint    limitReturnAmount; 
        uint    maxPrice;
    }

    TokenInterface weth;
    RegistryInterface registry;
    address private constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint private constant BONE = 10**18;

    constructor(address _weth) public {
        weth = TokenInterface(_weth);
    }

    function setRegistry(address _registry) external onlyOwner {
        registry = RegistryInterface(_registry);
    }

    function batchSwapExactIn(
        Swap[] memory swaps,
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint totalAmountIn,
        uint minTotalAmountOut
    )
        public payable
        returns (uint totalAmountOut)
    {
        transferFromAll(tokenIn, totalAmountIn);

        for (uint i = 0; i < swaps.length; i++) {
            Swap memory swap = swaps[i];
            TokenInterface SwapTokenIn = TokenInterface(swap.tokenIn);
            PoolInterface pool = PoolInterface(swap.pool);

            if (SwapTokenIn.allowance(address(this), swap.pool) > 0) {
                SwapTokenIn.approve(swap.pool, 0);
            }
            SwapTokenIn.approve(swap.pool, swap.swapAmount);

            (uint tokenAmountOut,) = pool.swapExactAmountIn(
                                        swap.tokenIn,
                                        swap.swapAmount,
                                        swap.tokenOut,
                                        swap.limitReturnAmount,
                                        swap.maxPrice
                                    );
            totalAmountOut = tokenAmountOut.add(totalAmountOut);
        }

        require(totalAmountOut >= minTotalAmountOut, "ERR_LIMIT_OUT");

        transferAll(tokenOut, totalAmountOut);
        transferAll(tokenIn, getBalance(tokenIn));
    }

    function batchSwapExactOut(
        Swap[] memory swaps,
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint maxTotalAmountIn
    )
        public payable
        returns (uint totalAmountIn)
    {
        transferFromAll(tokenIn, maxTotalAmountIn);

        for (uint i = 0; i < swaps.length; i++) {
            Swap memory swap = swaps[i];
            TokenInterface SwapTokenIn = TokenInterface(swap.tokenIn);
            PoolInterface pool = PoolInterface(swap.pool);

            if (SwapTokenIn.allowance(address(this), swap.pool) > 0) {
                SwapTokenIn.approve(swap.pool, 0);
            }
            SwapTokenIn.approve(swap.pool, swap.limitReturnAmount);

            (uint tokenAmountIn,) = pool.swapExactAmountOut(
                                        swap.tokenIn,
                                        swap.limitReturnAmount,
                                        swap.tokenOut,
                                        swap.swapAmount,
                                        swap.maxPrice
                                    );
            totalAmountIn = tokenAmountIn.add(totalAmountIn);
        }
        require(totalAmountIn <= maxTotalAmountIn, "ERR_LIMIT_IN");

        transferAll(tokenOut, getBalance(tokenOut));
        transferAll(tokenIn, getBalance(tokenIn));

    }

    function multihopBatchSwapExactIn(
        Swap[][] memory swapSequences,
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint totalAmountIn,
        uint minTotalAmountOut
    )
        public payable
        returns (uint totalAmountOut)
    {

        transferFromAll(tokenIn, totalAmountIn);

        for (uint i = 0; i < swapSequences.length; i++) {
            uint tokenAmountOut;
            for (uint k = 0; k < swapSequences[i].length; k++) {
                Swap memory swap = swapSequences[i][k];
                TokenInterface SwapTokenIn = TokenInterface(swap.tokenIn);
                if (k == 1) {
                    
                    
                    swap.swapAmount = tokenAmountOut;
                }

                PoolInterface pool = PoolInterface(swap.pool);
                if (SwapTokenIn.allowance(address(this), swap.pool) > 0) {
                    SwapTokenIn.approve(swap.pool, 0);
                }
                SwapTokenIn.approve(swap.pool, swap.swapAmount);
                (tokenAmountOut,) = pool.swapExactAmountIn(
                                            swap.tokenIn,
                                            swap.swapAmount,
                                            swap.tokenOut,
                                            swap.limitReturnAmount,
                                            swap.maxPrice
                                        );
            }
            
            totalAmountOut = tokenAmountOut.add(totalAmountOut);
        }

        require(totalAmountOut >= minTotalAmountOut, "ERR_LIMIT_OUT");

        transferAll(tokenOut, totalAmountOut);
        transferAll(tokenIn, getBalance(tokenIn));

    }

    function multihopBatchSwapExactOut(
        Swap[][] memory swapSequences,
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint maxTotalAmountIn
    )
        public payable
        returns (uint totalAmountIn)
    {

        transferFromAll(tokenIn, maxTotalAmountIn);

        for (uint i = 0; i < swapSequences.length; i++) {
            uint tokenAmountInFirstSwap;
            
            if (swapSequences[i].length == 1) {
                Swap memory swap = swapSequences[i][0];
                TokenInterface SwapTokenIn = TokenInterface(swap.tokenIn);

                PoolInterface pool = PoolInterface(swap.pool);
                if (SwapTokenIn.allowance(address(this), swap.pool) > 0) {
                    SwapTokenIn.approve(swap.pool, 0);
                }
                SwapTokenIn.approve(swap.pool, swap.limitReturnAmount);

                (tokenAmountInFirstSwap,) = pool.swapExactAmountOut(
                                        swap.tokenIn,
                                        swap.limitReturnAmount,
                                        swap.tokenOut,
                                        swap.swapAmount,
                                        swap.maxPrice
                                    );
            } else {
                
                
                
                uint intermediateTokenAmount; 
                Swap memory secondSwap = swapSequences[i][1];
                PoolInterface poolSecondSwap = PoolInterface(secondSwap.pool);
                intermediateTokenAmount = poolSecondSwap.calcInGivenOut(
                                        poolSecondSwap.getBalance(secondSwap.tokenIn),
                                        poolSecondSwap.getDenormalizedWeight(secondSwap.tokenIn),
                                        poolSecondSwap.getBalance(secondSwap.tokenOut),
                                        poolSecondSwap.getDenormalizedWeight(secondSwap.tokenOut),
                                        secondSwap.swapAmount,
                                        poolSecondSwap.getSwapFee()
                                    );

                
                Swap memory firstSwap = swapSequences[i][0];
                TokenInterface FirstSwapTokenIn = TokenInterface(firstSwap.tokenIn);
                PoolInterface poolFirstSwap = PoolInterface(firstSwap.pool);
                if (FirstSwapTokenIn.allowance(address(this), firstSwap.pool) < uint(-1)) {
                    FirstSwapTokenIn.approve(firstSwap.pool, uint(-1));
                }

                (tokenAmountInFirstSwap,) = poolFirstSwap.swapExactAmountOut(
                                        firstSwap.tokenIn,
                                        firstSwap.limitReturnAmount,
                                        firstSwap.tokenOut,
                                        intermediateTokenAmount, 
                                        firstSwap.maxPrice
                                    );

                
                TokenInterface SecondSwapTokenIn = TokenInterface(secondSwap.tokenIn);
                if (SecondSwapTokenIn.allowance(address(this), secondSwap.pool) < uint(-1)) {
                    SecondSwapTokenIn.approve(secondSwap.pool, uint(-1));
                }

                poolSecondSwap.swapExactAmountOut(
                                        secondSwap.tokenIn,
                                        secondSwap.limitReturnAmount,
                                        secondSwap.tokenOut,
                                        secondSwap.swapAmount,
                                        secondSwap.maxPrice
                                    );
            }
            totalAmountIn = tokenAmountInFirstSwap.add(totalAmountIn);
        }

        require(totalAmountIn <= maxTotalAmountIn, "ERR_LIMIT_IN");

        transferAll(tokenOut, getBalance(tokenOut));
        transferAll(tokenIn, getBalance(tokenIn));

    }

    function smartSwapExactIn(
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint totalAmountIn,
        uint minTotalAmountOut,
        uint nPools
    )
        public payable
        returns (uint totalAmountOut)
    {
        Swap[] memory swaps;
        if (isETH(tokenIn)) {
          (swaps,) = viewSplitExactIn(address(weth), address(tokenOut), totalAmountIn, nPools);
        } else if (isETH(tokenOut)){
          (swaps,) = viewSplitExactIn(address(tokenIn), address(weth), totalAmountIn, nPools);
        } else {
          (swaps,) = viewSplitExactIn(address(tokenIn), address(tokenOut), totalAmountIn, nPools);
        }

        totalAmountOut = batchSwapExactIn(swaps, tokenIn, tokenOut, totalAmountIn, minTotalAmountOut);
    }

    function smartSwapExactOut(
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint totalAmountOut,
        uint maxTotalAmountIn,
        uint nPools
    )
        public payable
        returns (uint totalAmountIn)
    {
        Swap[] memory swaps;
        if (isETH(tokenIn)) {
          (swaps,) = viewSplitExactOut(address(weth), address(tokenOut), totalAmountOut, nPools);
        } else if (isETH(tokenOut)){
          (swaps,) = viewSplitExactOut(address(tokenIn), address(weth), totalAmountOut, nPools);
        } else {
          (swaps,) = viewSplitExactOut(address(tokenIn), address(tokenOut), totalAmountOut, nPools);
        }

        totalAmountIn = batchSwapExactOut(swaps, tokenIn, tokenOut, maxTotalAmountIn);
    }

    function viewSplitExactIn(
        address tokenIn,
        address tokenOut,
        uint swapAmount,
        uint nPools
    )
        public view
        returns (Swap[] memory swaps, uint totalOutput)
    {
        address[] memory poolAddresses = registry.getBestPoolsWithLimit(tokenIn, tokenOut, nPools);

        Pool[] memory pools = new Pool[](poolAddresses.length);
        uint sumEffectiveLiquidity;
        for (uint i = 0; i < poolAddresses.length; i++) {
            pools[i] = getPoolData(tokenIn, tokenOut, poolAddresses[i]);
            sumEffectiveLiquidity = sumEffectiveLiquidity.add(pools[i].effectiveLiquidity);
        }

        uint[] memory bestInputAmounts = new uint[](pools.length);
        uint totalInputAmount;
        for (uint i = 0; i < pools.length; i++) {
            bestInputAmounts[i] = swapAmount.mul(pools[i].effectiveLiquidity).div(sumEffectiveLiquidity);
            totalInputAmount = totalInputAmount.add(bestInputAmounts[i]);
        }

        if (totalInputAmount < swapAmount) {
            bestInputAmounts[0] = bestInputAmounts[0].add(swapAmount.sub(totalInputAmount));
        } else {
            bestInputAmounts[0] = bestInputAmounts[0].sub(totalInputAmount.sub(swapAmount));
        }

        swaps = new Swap[](pools.length);

        for (uint i = 0; i < pools.length; i++) {
            swaps[i] = Swap({
                        pool: pools[i].pool,
                        tokenIn: tokenIn,
                        tokenOut: tokenOut,
                        swapAmount: bestInputAmounts[i],
                        limitReturnAmount: 0,
                        maxPrice: uint(-1)
                    });
        }

        totalOutput = calcTotalOutExactIn(bestInputAmounts, pools);

        return (swaps, totalOutput);
    }

    function viewSplitExactOut(
        address tokenIn,
        address tokenOut,
        uint swapAmount,
        uint nPools
    )
        public view
        returns (Swap[] memory swaps, uint totalOutput)
    {
        address[] memory poolAddresses = registry.getBestPoolsWithLimit(tokenIn, tokenOut, nPools);

        Pool[] memory pools = new Pool[](poolAddresses.length);
        uint sumEffectiveLiquidity;
        for (uint i = 0; i < poolAddresses.length; i++) {
            pools[i] = getPoolData(tokenIn, tokenOut, poolAddresses[i]);
            sumEffectiveLiquidity = sumEffectiveLiquidity.add(pools[i].effectiveLiquidity);
        }

        uint[] memory bestInputAmounts = new uint[](pools.length);
        uint totalInputAmount;
        for (uint i = 0; i < pools.length; i++) {
            bestInputAmounts[i] = swapAmount.mul(pools[i].effectiveLiquidity).div(sumEffectiveLiquidity);
            totalInputAmount = totalInputAmount.add(bestInputAmounts[i]);
        }
        
         if (totalInputAmount < swapAmount) {
            bestInputAmounts[0] = bestInputAmounts[0].add(swapAmount.sub(totalInputAmount));
        } else {
            bestInputAmounts[0] = bestInputAmounts[0].sub(totalInputAmount.sub(swapAmount));
        }

        swaps = new Swap[](pools.length);

        for (uint i = 0; i < pools.length; i++) {
            swaps[i] = Swap({
                        pool: pools[i].pool,
                        tokenIn: tokenIn,
                        tokenOut: tokenOut,
                        swapAmount: bestInputAmounts[i],
                        limitReturnAmount: uint(-1),
                        maxPrice: uint(-1)
                    });
        }

        totalOutput = calcTotalOutExactOut(bestInputAmounts, pools);

        return (swaps, totalOutput);
    }

    function getPoolData(
        address tokenIn,
        address tokenOut,
        address poolAddress
    )
        internal view
        returns (Pool memory)
    {
        PoolInterface pool = PoolInterface(poolAddress);
        uint tokenBalanceIn = pool.getBalance(tokenIn);
        uint tokenBalanceOut = pool.getBalance(tokenOut);
        uint tokenWeightIn = pool.getDenormalizedWeight(tokenIn);
        uint tokenWeightOut = pool.getDenormalizedWeight(tokenOut);
        uint swapFee = pool.getSwapFee();

        uint effectiveLiquidity = calcEffectiveLiquidity(
                                            tokenWeightIn,
                                            tokenBalanceOut,
                                            tokenWeightOut
                                        );
        Pool memory returnPool = Pool({
            pool: poolAddress,
            tokenBalanceIn: tokenBalanceIn,
            tokenWeightIn: tokenWeightIn,
            tokenBalanceOut: tokenBalanceOut,
            tokenWeightOut: tokenWeightOut,
            swapFee: swapFee,
            effectiveLiquidity: effectiveLiquidity
        });

        return returnPool;
    }

    function calcEffectiveLiquidity(
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut
    )
        internal pure
        returns (uint effectiveLiquidity)
    {

        
        effectiveLiquidity = 
            tokenWeightIn.mul(BONE).div(
                tokenWeightOut.add(tokenWeightIn)
            ).mul(tokenBalanceOut).div(BONE);

        return effectiveLiquidity;
    }

    function calcTotalOutExactIn(
        uint[] memory bestInputAmounts,
        Pool[] memory bestPools
    )
        internal pure
        returns (uint totalOutput)
    {
        totalOutput = 0;
        for (uint i = 0; i < bestInputAmounts.length; i++) {
            uint output = PoolInterface(bestPools[i].pool).calcOutGivenIn(
                                bestPools[i].tokenBalanceIn,
                                bestPools[i].tokenWeightIn,
                                bestPools[i].tokenBalanceOut,
                                bestPools[i].tokenWeightOut,
                                bestInputAmounts[i],
                                bestPools[i].swapFee
                            );

            totalOutput = totalOutput.add(output);
        }
        return totalOutput;
    }

    function calcTotalOutExactOut(
        uint[] memory bestInputAmounts,
        Pool[] memory bestPools
    )
        internal pure
        returns (uint totalOutput)
    {
        totalOutput = 0;
        for (uint i = 0; i < bestInputAmounts.length; i++) {
            uint output = PoolInterface(bestPools[i].pool).calcInGivenOut(
                                bestPools[i].tokenBalanceIn,
                                bestPools[i].tokenWeightIn,
                                bestPools[i].tokenBalanceOut,
                                bestPools[i].tokenWeightOut,
                                bestInputAmounts[i],
                                bestPools[i].swapFee
                            );

            totalOutput = totalOutput.add(output);
        }
        return totalOutput;
    }

    function transferFromAll(TokenInterface token, uint amount) internal returns(bool) {
        if (isETH(token)) {
            weth.deposit.value(msg.value)();
        } else {
            require(token.transferFrom(msg.sender, address(this), amount), "ERR_TRANSFER_FAILED");
        }
    }

    function getBalance(TokenInterface token) internal view returns (uint) {
        if (isETH(token)) {
            return weth.balanceOf(address(this));
        } else {
            return token.balanceOf(address(this));
        }
    }

    function transferAll(TokenInterface token, uint amount) internal returns(bool) {
        if (amount == 0) {
            return true;
        }

        if (isETH(token)) {
            weth.withdraw(amount);
            (bool xfer,) = msg.sender.call.value(amount)("");
            require(xfer, "ERR_ETH_FAILED");
        } else {
            require(token.transfer(msg.sender, amount), "ERR_TRANSFER_FAILED");
        }
    }

    function isETH(TokenInterface token) internal pure returns(bool) {
        return (address(token) == ETH_ADDRESS);
    }

    function() external payable {}
}