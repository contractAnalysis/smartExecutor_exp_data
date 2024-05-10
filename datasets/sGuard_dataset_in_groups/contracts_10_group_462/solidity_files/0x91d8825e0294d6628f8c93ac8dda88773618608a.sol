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




contract IPriceOracle {

    

    uint256 public constant ONE_DOLLAR = 10 ** 36;

    

    
    function getPrice(
        address token
    )
        public
        view
        returns (Monetary.Price memory);
}




contract OnePriceOracle is
    IPriceOracle
{
    

    function getPrice(
        address 
    )
        public
        view
        returns (Monetary.Price memory)
    {
        return Monetary.Price({ value: 1 });
    }
}