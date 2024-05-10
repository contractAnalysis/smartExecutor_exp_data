pragma solidity 0.4.26;







contract IContractId {
    
    
    function contractId() public pure returns (bytes32 id, uint256 version);
}


contract ETOTermsConstraints is IContractId {


    
    
    
    enum OfferingDocumentType {
        Memorandum,
        Prospectus
    }

    enum OfferingDocumentSubType {
        Regular,
        Lean
    }

    enum AssetType {
        Security,
        VMA 
    }

    
    
    

    
    uint256 public constant DATE_TO_WHITELIST_MIN_DURATION = 7 days;

    
    uint256 public constant MIN_WHITELIST_DURATION = 0 days;
    uint256 public constant MAX_WHITELIST_DURATION = 30 days;
    uint256 public constant MIN_PUBLIC_DURATION = 0 days;
    uint256 public constant MAX_PUBLIC_DURATION = 60 days;

    
    uint256 public constant MIN_OFFER_DURATION = 1 days;
    
    uint256 public constant MAX_OFFER_DURATION = 90 days;

    uint256 public constant MIN_SIGNING_DURATION = 14 days;
    uint256 public constant MAX_SIGNING_DURATION = 60 days;

    uint256 public constant MIN_CLAIM_DURATION = 7 days;
    uint256 public constant MAX_CLAIM_DURATION = 30 days;

    
    bool public CAN_SET_TRANSFERABILITY;

    
    bool public HAS_NOMINEE;

    
    uint256 public MIN_TICKET_SIZE_EUR_ULPS;
    
    uint256 public MAX_TICKET_SIZE_EUR_ULPS;
    
    uint256 public MIN_INVESTMENT_AMOUNT_EUR_ULPS;
    
    uint256 public MAX_INVESTMENT_AMOUNT_EUR_ULPS;

    
    string public NAME;

    
    OfferingDocumentType public OFFERING_DOCUMENT_TYPE;
    OfferingDocumentSubType public OFFERING_DOCUMENT_SUB_TYPE;

    
    string public JURISDICTION;

    
    AssetType public ASSET_TYPE;

    
    address public TOKEN_OFFERING_OPERATOR;


    
    
    

    constructor(
        bool canSetTransferability,
        bool hasNominee,
        uint256 minTicketSizeEurUlps,
        uint256 maxTicketSizeEurUlps,
        uint256 minInvestmentAmountEurUlps,
        uint256 maxInvestmentAmountEurUlps,
        string name,
        OfferingDocumentType offeringDocumentType,
        OfferingDocumentSubType offeringDocumentSubType,
        string jurisdiction,
        AssetType assetType,
        address tokenOfferingOperator
    )
        public
    {
        require(maxTicketSizeEurUlps == 0 || minTicketSizeEurUlps<=maxTicketSizeEurUlps);
        require(maxInvestmentAmountEurUlps == 0 || minInvestmentAmountEurUlps<=maxInvestmentAmountEurUlps);
        require(maxInvestmentAmountEurUlps == 0 || minTicketSizeEurUlps<=maxInvestmentAmountEurUlps);
        require(assetType != AssetType.VMA || !canSetTransferability);
        require(tokenOfferingOperator != address(0x0));

        CAN_SET_TRANSFERABILITY = canSetTransferability;
        HAS_NOMINEE = hasNominee;
        MIN_TICKET_SIZE_EUR_ULPS = minTicketSizeEurUlps;
        MAX_TICKET_SIZE_EUR_ULPS = maxTicketSizeEurUlps;
        MIN_INVESTMENT_AMOUNT_EUR_ULPS = minInvestmentAmountEurUlps;
        MAX_INVESTMENT_AMOUNT_EUR_ULPS = maxInvestmentAmountEurUlps;
        NAME = name;
        OFFERING_DOCUMENT_TYPE = offeringDocumentType;
        OFFERING_DOCUMENT_SUB_TYPE = offeringDocumentSubType;
        JURISDICTION = jurisdiction;
        ASSET_TYPE = assetType;
        TOKEN_OFFERING_OPERATOR = tokenOfferingOperator;
    }

    
    
    
    function contractId() public pure returns (bytes32 id, uint256 version) {
        return (0xce2be4f5f23c4a6f67ed925fce56afa57c9c8b274b4dfca8d0b1104aa4a6b53a, 0);
    }

}