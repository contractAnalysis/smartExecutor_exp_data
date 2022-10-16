pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;



interface IChainlinkAggregator {

    
    
    
    function latestAnswer() external view returns (int256 answer);
}


contract ChainlinkStopLimit {

    
    
    
    
    function checkStopLimit(bytes calldata stopLimitData)
        external
        view
    {
        (
            address oracle,
            int256 minPrice,
            int256 maxPrice
        ) = abi.decode(
            stopLimitData,
            (address, int256, int256)
        );

        int256 latestPrice = IChainlinkAggregator(oracle).latestAnswer();
        require(
            latestPrice >= minPrice && latestPrice <= maxPrice,
            "ChainlinkStopLimit/OUT_OF_PRICE_RANGE"
        );
    }
}