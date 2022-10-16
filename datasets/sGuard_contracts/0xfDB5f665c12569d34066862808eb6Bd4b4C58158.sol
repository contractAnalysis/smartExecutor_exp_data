pragma solidity ^0.5.8;



contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



pragma solidity ^0.5.8;



interface IArbitrator {
    
    function createDispute(uint256 _possibleRulings, bytes calldata _metadata) external returns (uint256);

    
    function closeEvidencePeriod(uint256 _disputeId) external;

    
    function executeRuling(uint256 _disputeId) external;

    
    function getDisputeFees() external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);

    
    function getSubscriptionFees(address _subscriber) external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);
}



pragma solidity ^0.5.8;


interface ERC165 {
    
    function supportsInterface(bytes4 _interfaceId) external pure returns (bool);
}



pragma solidity ^0.5.8;




contract IArbitrable is ERC165 {
    bytes4 internal constant ERC165_INTERFACE_ID = bytes4(0x01ffc9a7);
    bytes4 internal constant ARBITRABLE_INTERFACE_ID = bytes4(0x88f3ee69);

    
    event Ruled(IArbitrator indexed arbitrator, uint256 indexed disputeId, uint256 ruling);

    
    event EvidenceSubmitted(uint256 indexed disputeId, address indexed submitter, bytes evidence, bool finished);

    
    function submitEvidence(uint256 _disputeId, bytes calldata _evidence, bool _finished) external;

    
    function rule(uint256 _disputeId, uint256 _ruling) external;

    
    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        return _interfaceId == ARBITRABLE_INTERFACE_ID || _interfaceId == ERC165_INTERFACE_ID;
    }
}



pragma solidity ^0.5.8;




contract PrecedenceCampaignArbitrable is IArbitrable {
    
    
    string public constant ERROR_SENDER_NOT_ALLOWED = "PCA_SENDER_NOT_ALLOWED";

    address public owner;
    IArbitrator public arbitrator;

    modifier only(address _who) {
        require(msg.sender == _who, ERROR_SENDER_NOT_ALLOWED);
        _;
    }

    constructor (address _owner, IArbitrator _arbitrator) public {
        owner = _owner;
        arbitrator = _arbitrator;
    }

    function createDispute(uint256 _possibleRulings, bytes calldata _metadata) external only(owner) returns (uint256) {
        return _createDispute(_possibleRulings, _metadata);
    }

    function submitEvidence(uint256 _disputeId, bytes calldata _evidence, bool _finished) external only(owner) {
        _submitEvidence(_disputeId, msg.sender, _evidence, _finished);
    }

    function submitEvidenceFor(uint256 _disputeId, address _submitter, bytes calldata _evidence, bool _finished) external only(owner) {
        _submitEvidence(_disputeId, _submitter, _evidence, _finished);
    }

    function createAndSubmit(
        uint256 _possibleRulings,
        bytes calldata _metadata,
        address _submitter1,
        address _submitter2,
        bytes calldata _evidence1,
        bytes calldata _evidence2
    )
        external
        only(owner)
        returns (uint256)
    {
        uint256 disputeId = _createDispute(_possibleRulings, _metadata);
        _submitEvidence(disputeId, _submitter1, _evidence1, false);
        _submitEvidence(disputeId, _submitter2, _evidence2, false);

        return disputeId;
    }

    function closeEvidencePeriod(uint256 _disputeId) external only(owner) {
        arbitrator.closeEvidencePeriod(_disputeId);
    }

    function rule(uint256 _disputeId, uint256 _ruling) external only(address(arbitrator)) {
        emit Ruled(IArbitrator(msg.sender), _disputeId, _ruling);
    }

    function setOwner(address _owner) external only(owner) {
        owner = _owner;
    }

    function _createDispute(uint256 _possibleRulings, bytes memory _metadata) internal returns (uint256) {
        (address recipient, ERC20 feeToken, uint256 disputeFees) = arbitrator.getDisputeFees();
        feeToken.approve(recipient, disputeFees);
        return arbitrator.createDispute(_possibleRulings, _metadata);
    }

    function _submitEvidence(uint256 _disputeId, address _submitter, bytes memory _evidence, bool _finished) internal {
        emit EvidenceSubmitted(_disputeId, _submitter, _evidence, _finished);
        if (_finished) {
            arbitrator.closeEvidencePeriod(_disputeId);
        }
    }
}