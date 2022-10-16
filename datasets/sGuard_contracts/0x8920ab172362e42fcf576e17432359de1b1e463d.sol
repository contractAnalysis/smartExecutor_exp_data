pragma solidity 0.5.7;



interface IOracle {

    
    function read()
        external
        view
        returns (uint256);
}





pragma solidity 0.5.7;




contract ConstantPriceOracle is
    IOracle
{
    
    uint256 public stablePrice;

    
    
    constructor(
        uint256 _stablePrice
    )
        public
    {
        stablePrice = _stablePrice;
    }

    
    function read()
        external
        view
        returns (uint256)
    {
        return stablePrice;
    }
}