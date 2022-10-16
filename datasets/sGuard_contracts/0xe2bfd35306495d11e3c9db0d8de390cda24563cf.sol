pragma solidity ^0.5.16;


contract MaximumGasPrice {
    
    uint256 constant private DEFAULT_MAX_GAS_PRICE = 20 * (10 ** 9);

    
    
    function checkGasPrice()
        external
        view
    {
        require(
            tx.gasprice <= DEFAULT_MAX_GAS_PRICE,
            "MaximumGasPrice/GAS_PRICE_EXCEEDS_20_GWEI"
        );
    }

    
    
    
    function checkGasPrice(uint256 maxGasPrice)
        external
        view
    {
        require(
            tx.gasprice <= maxGasPrice,
            "MaximumGasPrice/GAS_PRICE_EXCEEDS_MAXIMUM"
        );
    }
}