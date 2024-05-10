pragma solidity 0.4.26;







contract IContractId {
    
    
    function contractId() public pure returns (bytes32 id, uint256 version);
}

contract ShareholderRights is IContractId {

    
    
    

    enum VotingRule {
        
        NoVotingRights,
        
        Positive,
        
        Negative,
        
        Proportional
    }

    
    
    

    bytes32 private constant EMPTY_STRING_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    
    
    

    
    
    
    

    
    bool public constant HAS_DRAG_ALONG_RIGHTS = true;
    
    bool public constant HAS_TAG_ALONG_RIGHTS = true;
    
    bool public constant HAS_GENERAL_INFORMATION_RIGHTS = true;
    
    VotingRule public GENERAL_VOTING_RULE;
    
    VotingRule public TAG_ALONG_VOTING_RULE;
    
    uint256 public LIQUIDATION_PREFERENCE_MULTIPLIER_FRAC;
    
    bool public HAS_FOUNDERS_VESTING;
    
    uint256 public GENERAL_VOTING_DURATION;
    
    uint256 public RESTRICTED_ACT_VOTING_DURATION;
    
    uint256 public VOTING_FINALIZATION_DURATION;
    
    uint256 public SHAREHOLDERS_VOTING_QUORUM_FRAC;
    
    uint256 public VOTING_MAJORITY_FRAC = 10**17; 
    
    string public INVESTMENT_AGREEMENT_TEMPLATE_URL;

    
    
    

    constructor(
        VotingRule generalVotingRule,
        VotingRule tagAlongVotingRule,
        uint256 liquidationPreferenceMultiplierFrac,
        bool hasFoundersVesting,
        uint256 generalVotingDuration,
        uint256 restrictedActVotingDuration,
        uint256 votingFinalizationDuration,
        uint256 shareholdersVotingQuorumFrac,
        uint256 votingMajorityFrac,
        string investmentAgreementTemplateUrl
    )
        public
    {
        
        require(uint(generalVotingRule) < 4);
        require(uint(tagAlongVotingRule) < 4);
        
        require(shareholdersVotingQuorumFrac <= 10**18);
        require(keccak256(abi.encodePacked(investmentAgreementTemplateUrl)) != EMPTY_STRING_HASH);

        GENERAL_VOTING_RULE = generalVotingRule;
        TAG_ALONG_VOTING_RULE = tagAlongVotingRule;
        LIQUIDATION_PREFERENCE_MULTIPLIER_FRAC = liquidationPreferenceMultiplierFrac;
        HAS_FOUNDERS_VESTING = hasFoundersVesting;
        GENERAL_VOTING_DURATION = generalVotingDuration;
        RESTRICTED_ACT_VOTING_DURATION = restrictedActVotingDuration;
        VOTING_FINALIZATION_DURATION = votingFinalizationDuration;
        SHAREHOLDERS_VOTING_QUORUM_FRAC = shareholdersVotingQuorumFrac;
        VOTING_MAJORITY_FRAC = votingMajorityFrac;
        INVESTMENT_AGREEMENT_TEMPLATE_URL = investmentAgreementTemplateUrl;
    }

    
    
    

    function contractId() public pure returns (bytes32 id, uint256 version) {
        return (0x7f46caed28b4e7a90dc4db9bba18d1565e6c4824f0dc1b96b3b88d730da56e57, 0);
    }
}