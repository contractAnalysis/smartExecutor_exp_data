pragma solidity 0.6.6;



library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


interface Aggregator {
    function latestAnswer() external view returns(uint256);
    function latestTimestamp() external view returns(uint256);
}


contract OracleResolver {
    using Address for address;

    Aggregator aggr;

    uint256 internal constant expiration = 2 hours;

    constructor() public {
        if (address(0xF79D6aFBb6dA890132F9D7c355e3015f15F3406F).isContract()) {
            
            aggr = Aggregator(0xF79D6aFBb6dA890132F9D7c355e3015f15F3406F);
        } else revert();
    }

    function ethUsdPrice() public view returns (uint256) {
        require(now < aggr.latestTimestamp() + expiration, "Oracle data are outdated");
        return aggr.latestAnswer() / 1000;
    }
}