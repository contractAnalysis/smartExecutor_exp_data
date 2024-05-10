pragma solidity 0.5.7;



interface IMetaOracle {

    
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (bytes32);

    
    function getSourceMedianizer()
        external
        view
        returns (address);
}





pragma solidity 0.5.7;



interface IMetaOracleV2 {

    
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (uint256);
}





pragma solidity 0.5.7;
pragma experimental "ABIEncoderV2";






contract MovingAverageOracleV1Proxy is
    IMetaOracleV2
{

    
    IMetaOracle public metaOracleInstance;

    
    
    constructor(
        IMetaOracle _metaOracleInstance
    )
        public
    {
        metaOracleInstance = _metaOracleInstance;
    }

    

    
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (uint256)
    {
        return uint256(metaOracleInstance.read(_dataDays));
    }
}