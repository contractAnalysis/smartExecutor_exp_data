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




interface IMakerOracle {

    
    event LogNote(
        bytes4 indexed msgSig,
        address indexed msgSender,
        bytes32 indexed arg1,
        bytes32 indexed arg2,
        uint256 msgValue,
        bytes msgData
    ) anonymous;

    
    function peek()
        external
        view
        returns (bytes32, bool);

    
    function read()
        external
        view
        returns (bytes32);
}




contract WethPriceOracle is
    IPriceOracle
{
    

    IMakerOracle public MEDIANIZER;

    

    constructor(
        address medianizer
    )
        public
    {
        MEDIANIZER = IMakerOracle(medianizer);
    }

    

    function getPrice(
        address 
    )
        public
        view
        returns (Monetary.Price memory)
    {
        (bytes32 value, ) = MEDIANIZER.peek();
        return Monetary.Price({ value: uint256(value) });
    }
}