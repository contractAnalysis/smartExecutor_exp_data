pragma solidity 0.4.26;







contract IContractId {
    
    
    function contractId() public pure returns (bytes32 id, uint256 version);
}


contract ETODurationTerms is IContractId {

    
    
    

    
    uint32 public WHITELIST_DURATION;

    
    uint32 public PUBLIC_DURATION;

    
    uint32 public SIGNING_DURATION;

    
    uint32 public CLAIM_DURATION;

    
    
    

    constructor(
        uint32 whitelistDuration,
        uint32 publicDuration,
        uint32 signingDuration,
        uint32 claimDuration
    )
        public
    {
        WHITELIST_DURATION = whitelistDuration;
        PUBLIC_DURATION = publicDuration;
        SIGNING_DURATION = signingDuration;
        CLAIM_DURATION = claimDuration;
    }

    
    
    

    function contractId() public pure returns (bytes32 id, uint256 version) {
        return (0x5fb50201b453799d95f8a80291b940f1c543537b95bff2e3c78c2e36070494c0, 0);
    }
}