pragma solidity ^0.5.0;

interface InterestRateInterface {

    
    function getInterestRate(uint dmmTokenId, uint totalSupply, uint activeSupply) external view returns (uint);

}



pragma solidity ^0.5.0;


contract InterestRateImplV1 is InterestRateInterface {

    constructor() public {
    }

    function getInterestRate(uint dmmTokenId, uint totalSupply, uint activeSupply) external view returns (uint) {
        
        return 62500000000000000;
    }

}