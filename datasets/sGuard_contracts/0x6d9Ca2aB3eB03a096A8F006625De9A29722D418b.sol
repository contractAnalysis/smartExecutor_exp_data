pragma solidity ^0.6.0;


interface IRebasedPriceOracle {
   function update() external;
}

interface IBPool {
      function gulp(address token) external;
}

interface IUniswapV2Pair {
    function sync() external;
}


contract Sync {

    IUniswapV2Pair constant UNISWAP = IUniswapV2Pair(0xa89004aA11CF28B34E125c63FBc56213fb663F70);
    IBPool constant BALANCER_REB80WETH20 = IBPool(0x2961c01EB89D9af84c3859cE9E00E78efFcAB32F);
    IRebasedPriceOracle oracle = IRebasedPriceOracle(0x693e4767C7cfDF3FcB33B079df02403Abc2e1921);
    
    event OracleUpdated();

    function syncAll() external {

        
        
        (bool success,) = address(oracle).call(abi.encodeWithSignature("update()"));
        
        if (success) {
            emit OracleUpdated();
        }
    
       

       UNISWAP.sync();
       BALANCER_REB80WETH20.gulp(0xE6279E1c65DD41b30bA3760DCaC3CD8bbb4420D6);

    } 
    
}