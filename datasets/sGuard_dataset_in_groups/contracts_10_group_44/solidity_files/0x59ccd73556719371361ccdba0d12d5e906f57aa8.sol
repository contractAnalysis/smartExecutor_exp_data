pragma solidity ^0.4.26;

library CappedMath {
    uint constant private UINT_MAX = 2**256 - 1;

    
    function addCap(uint _a, uint _b) internal pure returns (uint) {
        uint c = _a + _b;
        return c >= _a ? c : UINT_MAX;
    }

    
    function subCap(uint _a, uint _b) internal pure returns (uint) {
        if (_b > _a)
            return 0;
        else
            return _a - _b;
    }

    
    function mulCap(uint _a, uint _b) internal pure returns (uint) {
        
        
        
        if (_a == 0)
            return 0;

        uint c = _a * _b;
        return c / _a == _b ? c : UINT_MAX;
    }
}


contract Arbitrator {

    enum DisputeStatus {Waiting, Appealable, Solved}

    modifier requireArbitrationFee(bytes _extraData) {
        require(msg.value >= arbitrationCost(_extraData), "Not enough ETH to cover arbitration costs.");
        _;
    }
    modifier requireAppealFee(uint _disputeID, bytes _extraData) {
        require(msg.value >= appealCost(_disputeID, _extraData), "Not enough ETH to cover appeal costs.");
        _;
    }

    
    event DisputeCreation(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    
    event AppealPossible(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    
    event AppealDecision(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    
    function createDispute(uint _choices, bytes _extraData) public requireArbitrationFee(_extraData) payable returns(uint disputeID) {}

    
    function arbitrationCost(bytes _extraData) public view returns(uint fee);

    
    function appeal(uint _disputeID, bytes _extraData) public requireAppealFee(_disputeID,_extraData) payable {
        emit AppealDecision(_disputeID, Arbitrable(msg.sender));
    }

    
    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint fee);

    
    function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {}

    
    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status);

    
    function currentRuling(uint _disputeID) public view returns(uint ruling);
}


interface IArbitrable {
    
    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    
    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

    
    event Evidence(Arbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    
    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    
    function rule(uint _disputeID, uint _ruling) public;
}


contract Arbitrable is IArbitrable {
    Arbitrator public arbitrator;
    bytes public arbitratorExtraData; 

    modifier onlyArbitrator {require(msg.sender == address(arbitrator), "Can only be called by the arbitrator."); _;}

    
    constructor(Arbitrator _arbitrator, bytes _arbitratorExtraData) public {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }

    
    function rule(uint _disputeID, uint _ruling) public onlyArbitrator {
        emit Ruling(Arbitrator(msg.sender),_disputeID,_ruling);

        executeRuling(_disputeID,_ruling);
    }


    
    function executeRuling(uint _disputeID, uint _ruling) internal;
}


contract KlerosGovernor is Arbitrable {
    using CappedMath for uint;

    
    enum Status { NoDispute, DisputeCreated, Resolved }

    struct Session {
        Round[] rounds; 
        uint ruling; 
        uint disputeID; 
        uint[] submittedLists; 
        uint sumDeposit; 
        Status status; 
        mapping(bytes32 => bool) alreadySubmitted; 
        uint durationOffset; 
    }

    struct Transaction {
        address target; 
        uint value; 
        bytes data; 
        bool executed; 
    }

    struct Submission {
        address submitter; 
        uint deposit; 
        Transaction[] txs; 
        bytes32 listHash; 
        uint submissionTime; 
        bool approved; 
        uint approvalTime; 
    }

    struct Round {
        mapping (uint => uint) paidFees; 
        mapping (uint => bool) hasPaid; 
        uint feeRewards; 
        mapping(address => mapping (uint => uint)) contributions; 
        uint successfullyPaid; 
    }

    uint constant NO_SHADOW_WINNER = uint(-1); 

    address public deployer; 

    uint public reservedETH; 

    uint public submissionBaseDeposit; 
    uint public submissionTimeout; 
    uint public executionTimeout; 
    uint public withdrawTimeout; 
    uint public sharedMultiplier; 
    uint public winnerMultiplier; 
    uint public loserMultiplier; 
    uint public constant MULTIPLIER_DIVISOR = 10000; 

    uint public lastApprovalTime; 
    uint public shadowWinner; 

    Submission[] public submissions; 
    Session[] public sessions; 

    
    modifier duringSubmissionPeriod() {
        uint offset = sessions[sessions.length - 1].durationOffset;
        require(now - lastApprovalTime <= submissionTimeout.addCap(offset), "Submission time has ended.");
        _;
    }
    modifier duringApprovalPeriod() {
        uint offset = sessions[sessions.length - 1].durationOffset;
        require(now - lastApprovalTime > submissionTimeout.addCap(offset), "Approval time has not started yet.");
        _;
    }
    modifier onlyByGovernor() {require(address(this) == msg.sender, "Only the governor can execute this."); _;}

    
    
    event ListSubmitted(uint indexed _listID, address indexed _submitter, uint indexed _session, string _description);

    
    constructor (
        Arbitrator _arbitrator,
        bytes _extraData,
        uint _submissionBaseDeposit,
        uint _submissionTimeout,
        uint _executionTimeout,
        uint _withdrawTimeout,
        uint _sharedMultiplier,
        uint _winnerMultiplier,
        uint _loserMultiplier
    ) public Arbitrable(_arbitrator, _extraData) {
        lastApprovalTime = now;
        submissionBaseDeposit = _submissionBaseDeposit;
        submissionTimeout = _submissionTimeout;
        executionTimeout = _executionTimeout;
        withdrawTimeout = _withdrawTimeout;
        sharedMultiplier = _sharedMultiplier;
        winnerMultiplier = _winnerMultiplier;
        loserMultiplier = _loserMultiplier;
        shadowWinner = NO_SHADOW_WINNER;
        sessions.length++;
        deployer = msg.sender;
    }

    
    function setMetaEvidence(string _metaEvidence) external {
        require(msg.sender == deployer, "Can only be called once by the deployer of the contract.");
        deployer = address(0);
        emit MetaEvidence(0, _metaEvidence);
    }

    
    function changeSubmissionDeposit(uint _submissionBaseDeposit) public onlyByGovernor {
        submissionBaseDeposit = _submissionBaseDeposit;
    }

    
    function changeSubmissionTimeout(uint _submissionTimeout) public onlyByGovernor duringSubmissionPeriod {
        submissionTimeout = _submissionTimeout;
    }

    
    function changeExecutionTimeout(uint _executionTimeout) public onlyByGovernor {
        executionTimeout = _executionTimeout;
    }

    
    function changeWithdrawTimeout(uint _withdrawTimeout) public onlyByGovernor {
        withdrawTimeout = _withdrawTimeout;
    }

    
    function changeSharedMultiplier(uint _sharedMultiplier) public onlyByGovernor {
        sharedMultiplier = _sharedMultiplier;
    }

    
    function changeWinnerMultiplier(uint _winnerMultiplier) public onlyByGovernor {
        winnerMultiplier = _winnerMultiplier;
    }

    
    function changeLoserMultiplier(uint _loserMultiplier) public onlyByGovernor {
        loserMultiplier = _loserMultiplier;
    }

    
    function changeArbitrator(Arbitrator _arbitrator, bytes _arbitratorExtraData) public onlyByGovernor duringSubmissionPeriod {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }

    
    function submitList (address[] _target, uint[] _value, bytes _data, uint[] _dataSize, string _description) public payable duringSubmissionPeriod {
        require(_target.length == _value.length, "Incorrect input. Target and value arrays must be of the same length.");
        require(_target.length == _dataSize.length, "Incorrect input. Target and datasize arrays must be of the same length.");
        Session storage session = sessions[sessions.length - 1];
        Submission storage submission = submissions[submissions.length++];
        submission.submitter = msg.sender;
        
        submission.deposit = submissionBaseDeposit + arbitrator.arbitrationCost(arbitratorExtraData);
        require(msg.value >= submission.deposit, "Submission deposit must be paid in full.");
        
        
        
        
        bytes32[3] memory hashes;
        uint readingPosition;
        for (uint i = 0; i < _target.length; i++) {
            bytes memory readData = new bytes(_dataSize[i]);
            Transaction storage transaction = submission.txs[submission.txs.length++];
            transaction.target = _target[i];
            transaction.value = _value[i];
            for (uint j = 0; j < _dataSize[i]; j++) {
                readData[j] = _data[readingPosition + j];
            }
            transaction.data = readData;
            readingPosition += _dataSize[i];
            hashes[2] = keccak256(abi.encodePacked(transaction.target, transaction.value, transaction.data));
            require(uint(hashes[2]) >= uint(hashes[1]), "The transactions are in incorrect order.");
            hashes[0] = keccak256(abi.encodePacked(hashes[2], hashes[0]));
            hashes[1] = hashes[2];
        }
        require(!session.alreadySubmitted[hashes[0]], "The same list was already submitted earlier.");
        session.alreadySubmitted[hashes[0]] = true;
        submission.listHash = hashes[0];
        submission.submissionTime = now;
        session.sumDeposit += submission.deposit;
        session.submittedLists.push(submissions.length - 1);
        if (session.submittedLists.length == 1)
            session.durationOffset = now.subCap(lastApprovalTime);

        emit ListSubmitted(submissions.length - 1, msg.sender, sessions.length - 1, _description);

        uint remainder = msg.value - submission.deposit;
        if (remainder > 0)
            msg.sender.send(remainder);

        reservedETH += submission.deposit;
    }

    
    function withdrawTransactionList(uint _submissionID, bytes32 _listHash) public {
        Session storage session = sessions[sessions.length - 1];
        Submission storage submission = submissions[session.submittedLists[_submissionID]];
        require(now - lastApprovalTime <= submissionTimeout / 2, "Lists can be withdrawn only in the first half of the period.");
        
        require(submission.listHash == _listHash, "Provided hash doesn't correspond with submission ID.");
        require(submission.submitter == msg.sender, "Can't withdraw the list created by someone else.");
        require(now - submission.submissionTime <= withdrawTimeout, "Withdrawing time has passed.");
        session.submittedLists[_submissionID] = session.submittedLists[session.submittedLists.length - 1];
        session.alreadySubmitted[_listHash] = false;
        session.submittedLists.length--;
        session.sumDeposit = session.sumDeposit.subCap(submission.deposit);
        msg.sender.transfer(submission.deposit);

        reservedETH = reservedETH.subCap(submission.deposit);
    }

    
    function executeSubmissions() public duringApprovalPeriod {
        Session storage session = sessions[sessions.length - 1];
        require(session.status == Status.NoDispute, "Can't approve transaction list while dispute is active.");
        if (session.submittedLists.length == 0) {
            lastApprovalTime = now;
            session.status = Status.Resolved;
            sessions.length++;
        } else if (session.submittedLists.length == 1) {
            Submission storage submission = submissions[session.submittedLists[0]];
            submission.approved = true;
            submission.approvalTime = now;
            uint sumDeposit = session.sumDeposit;
            session.sumDeposit = 0;
            submission.submitter.send(sumDeposit);
            lastApprovalTime = now;
            session.status = Status.Resolved;
            sessions.length++;

            reservedETH = reservedETH.subCap(sumDeposit);
        } else {
            session.status = Status.DisputeCreated;
            uint arbitrationCost = arbitrator.arbitrationCost(arbitratorExtraData);
            session.disputeID = arbitrator.createDispute.value(arbitrationCost)(session.submittedLists.length, arbitratorExtraData);
            session.rounds.length++;
            session.sumDeposit = session.sumDeposit.subCap(arbitrationCost);

            reservedETH = reservedETH.subCap(arbitrationCost);
            emit Dispute(arbitrator, session.disputeID, 0, sessions.length - 1);
        }
    }

    
    function fundAppeal(uint _submissionID) public payable {
        Session storage session = sessions[sessions.length - 1];
        require(_submissionID <= session.submittedLists.length - 1, "SubmissionID is out of bounds.");
        require(session.status == Status.DisputeCreated, "No dispute to appeal.");
        require(arbitrator.disputeStatus(session.disputeID) == Arbitrator.DisputeStatus.Appealable, "Dispute is not appealable.");
        (uint appealPeriodStart, uint appealPeriodEnd) = arbitrator.appealPeriod(session.disputeID);
        require(
            now >= appealPeriodStart && now < appealPeriodEnd,
            "Appeal fees must be paid within the appeal period."
        );

        uint winner = arbitrator.currentRuling(session.disputeID);
        uint multiplier;
        
        if (winner == _submissionID + 1) {
            multiplier = winnerMultiplier;
        } else if (winner == 0) {
            multiplier = sharedMultiplier;
        } else {
            require(now - appealPeriodStart < (appealPeriodEnd - appealPeriodStart)/2, "The loser must pay during the first half of the appeal period.");
            multiplier = loserMultiplier;
        }

        Round storage round = session.rounds[session.rounds.length - 1];
        require(!round.hasPaid[_submissionID], "Appeal fee has already been paid.");
        uint appealCost = arbitrator.appealCost(session.disputeID, arbitratorExtraData);
        uint totalCost = appealCost.addCap((appealCost.mulCap(multiplier)) / MULTIPLIER_DIVISOR);

        
        uint contribution; 
        uint remainingETH; 
        (contribution, remainingETH) = calculateContribution(msg.value, totalCost.subCap(round.paidFees[_submissionID]));
        round.contributions[msg.sender][_submissionID] += contribution;
        round.paidFees[_submissionID] += contribution;
        
        if (round.paidFees[_submissionID] >= totalCost) {
            round.hasPaid[_submissionID] = true;
            if (shadowWinner == NO_SHADOW_WINNER)
                shadowWinner = _submissionID;

            round.feeRewards += round.paidFees[_submissionID];
            round.successfullyPaid += round.paidFees[_submissionID];
        }

        
        msg.sender.send(remainingETH);
        reservedETH += contribution;

        if (shadowWinner != NO_SHADOW_WINNER && shadowWinner != _submissionID && round.hasPaid[_submissionID]) {
            
            shadowWinner = NO_SHADOW_WINNER;
            arbitrator.appeal.value(appealCost)(session.disputeID, arbitratorExtraData);
            session.rounds.length++;
            round.feeRewards = round.feeRewards.subCap(appealCost);
            reservedETH = reservedETH.subCap(appealCost);
        }
    }

    
    function calculateContribution(uint _available, uint _requiredAmount)
        internal
        pure
        returns(uint taken, uint remainder)
    {
        if (_requiredAmount > _available)
            taken = _available;
        else {
            taken = _requiredAmount;
            remainder = _available - _requiredAmount;
        }
    }

    
    function withdrawFeesAndRewards(address _beneficiary, uint _session, uint _round, uint _submissionID) public {
        Session storage session = sessions[_session];
        Round storage round = session.rounds[_round];
        require(session.status == Status.Resolved, "Session has an ongoing dispute.");
        uint reward;
        
        if (!round.hasPaid[_submissionID]) {
            reward = round.contributions[_beneficiary][_submissionID];
        } else if (session.ruling == 0 || !round.hasPaid[session.ruling - 1]) {
            
            reward = round.successfullyPaid > 0
                ? (round.contributions[_beneficiary][_submissionID] * round.feeRewards) / round.successfullyPaid
                : 0;
        } else if (session.ruling - 1 == _submissionID) {
            
            reward = round.paidFees[_submissionID] > 0
                ? (round.contributions[_beneficiary][_submissionID] * round.feeRewards) / round.paidFees[_submissionID]
                : 0;
        }
        round.contributions[_beneficiary][_submissionID] = 0;

        _beneficiary.send(reward); 
        reservedETH = reservedETH.subCap(reward);
    }

    
    function rule(uint _disputeID, uint _ruling) public {
        Session storage session = sessions[sessions.length - 1];
        require(msg.sender == address(arbitrator), "Must be called by the arbitrator.");
        require(session.status == Status.DisputeCreated, "The dispute has already been resolved.");
        require(_ruling <= session.submittedLists.length, "Ruling is out of bounds.");

        if (shadowWinner != NO_SHADOW_WINNER) {
            emit Ruling(Arbitrator(msg.sender), _disputeID, shadowWinner + 1);
            executeRuling(_disputeID, shadowWinner + 1);
        } else {
            emit Ruling(Arbitrator(msg.sender), _disputeID, _ruling);
            executeRuling(_disputeID, _ruling);
        }
    }

    
    function executeRuling(uint _disputeID, uint _ruling) internal {
        Session storage session = sessions[sessions.length - 1];
        if (_ruling != 0) {
            Submission storage submission = submissions[session.submittedLists[_ruling - 1]];
            submission.approved = true;
            submission.approvalTime = now;
            submission.submitter.send(session.sumDeposit);
        }
        
        reservedETH = reservedETH.subCap(session.sumDeposit);

        session.sumDeposit = 0;
        shadowWinner = NO_SHADOW_WINNER;
        lastApprovalTime = now;
        session.status = Status.Resolved;
        session.ruling = _ruling;
        sessions.length++;
    }

    
    function executeTransactionList(uint _listID, uint _cursor, uint _count) public {
        Submission storage submission = submissions[_listID];
        require(submission.approved, "Can't execute list that wasn't approved.");
        require(now - submission.approvalTime <= executionTimeout, "Time to execute the transaction list has passed.");
        for (uint i = _cursor; i < submission.txs.length && (_count == 0 || i < _cursor + _count); i++) {
            Transaction storage transaction = submission.txs[i];
            uint expendableFunds = getExpendableFunds();
            if (!transaction.executed && transaction.value <= expendableFunds) {
                bool callResult = transaction.target.call.value(transaction.value)(transaction.data); 
                
                if (callResult == true) {
                    require(!transaction.executed, "This transaction has already been executed.");
                    transaction.executed = true;
                }
            }
        }
    }

    
    function () public payable {}

    
    function getExpendableFunds() public view returns (uint) {
        return address(this).balance.subCap(reservedETH);
    }

    
    function getTransactionInfo(uint _listID, uint _transactionIndex)
        public
        view
        returns (
            address target,
            uint value,
            bytes data,
            bool executed
        )
    {
        Submission storage submission = submissions[_listID];
        Transaction storage transaction = submission.txs[_transactionIndex];
        return (
            transaction.target,
            transaction.value,
            transaction.data,
            transaction.executed
        );
    }

    
    function getContributions(
        uint _session,
        uint _round,
        address _contributor
    ) public view returns(uint[] contributions) {
        Session storage session = sessions[_session];
        Round storage round = session.rounds[_round];

        contributions = new uint[](session.submittedLists.length);
        for (uint i = 0; i < contributions.length; i++) {
            contributions[i] = round.contributions[_contributor][i];
        }
    }

    
    function getRoundInfo(uint _session, uint _round)
        public
        view
        returns (
            uint[] paidFees,
            bool[] hasPaid,
            uint feeRewards,
            uint successfullyPaid
        )
    {
        Session storage session = sessions[_session];
        Round storage round = session.rounds[_round];
        paidFees = new uint[](session.submittedLists.length);
        hasPaid = new bool[](session.submittedLists.length);

        for (uint i = 0; i < session.submittedLists.length; i++) {
            paidFees[i] = round.paidFees[i];
            hasPaid[i] = round.hasPaid[i];
        }

        feeRewards = round.feeRewards;
        successfullyPaid = round.successfullyPaid;
    }

    
    function getSubmittedLists(uint _session) public view returns (uint[] submittedLists) {
        Session storage session = sessions[_session];
        submittedLists = session.submittedLists;
    }

    
    function getNumberOfTransactions(uint _listID) public view returns (uint txCount) {
        Submission storage submission = submissions[_listID];
        return submission.txs.length;
    }

    
    function getNumberOfCreatedLists() public view returns (uint) {
        return submissions.length;
    }

    
    function getCurrentSessionNumber() public view returns (uint) {
        return sessions.length - 1;
    }

    
    function getSessionRoundsNumber(uint _session) public view returns (uint) {
        Session storage session = sessions[_session];
        return session.rounds.length;
    }
}