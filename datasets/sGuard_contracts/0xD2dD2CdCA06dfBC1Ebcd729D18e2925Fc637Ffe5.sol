pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;



library Monetary {

    
    struct Price {
        uint256 value;
    }

    
    struct Value {
        uint256 value;
    }
}





pragma solidity 0.5.7;



contract IDydxPriceOracle {
    function getPrice(
        address token
    )
        public
        view
        returns (Monetary.Price memory);
}





pragma solidity 0.5.7;





contract DydxOracleAdapter {

    
    IDydxPriceOracle public dYdXOracleInstance;
    address public erc20TokenAddress;

    
    
    constructor(
        IDydxPriceOracle _dYdXOracleInstance,
        address _erc20TokenAddress
    )
        public
    {
        dYdXOracleInstance = _dYdXOracleInstance;
        erc20TokenAddress = _erc20TokenAddress;
    }

    

    
    function read()
        external
        view
        returns (uint256)
    {
        
        Monetary.Price memory price = dYdXOracleInstance.getPrice(erc20TokenAddress);
        return price.value;
    }
}