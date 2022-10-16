pragma solidity 0.5.17;

library SafeMath { 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }
}

interface IERC20 { 
    function balanceOf(address who) external view returns (uint256);
    
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract ReentrancyGuard { 
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "reentrant call");

        _status = _ENTERED;
        
        _;
        
        _status = _NOT_ENTERED;
    }
}

interface IWETH { 
    function deposit() payable external;
    
    function transfer(address dst, uint wad) external returns (bool);
}

contract Moloch is ReentrancyGuard {
    using SafeMath for uint256;

    
    address public depositToken; 
    address public wrapperToken; 
    address public wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; 
    
    uint256 public proposalDeposit; 
    uint256 public processingReward; 
    uint256 public periodDuration; 
    uint256 public votingPeriodLength; 
    uint256 public gracePeriodLength; 
    uint256 public dilutionBound; 
    uint256 public summoningTime; 
    
    
    
    
    uint256 constant MAX_GUILD_BOUND = 10**36; 
    uint256 constant MAX_TOKEN_WHITELIST_COUNT = 400; 
    uint256 constant MAX_TOKEN_GUILDBANK_COUNT = 200; 

    
    string private _name = "Moloch DAO v2x Bank";
    string private _symbol = "MOL-V2X";
    uint8 private _decimals = 18;

    
    
    
    event SubmitProposal(address indexed applicant, uint256 sharesRequested, uint256 lootRequested, uint256 tributeOffered, address tributeToken, uint256 paymentRequested, address paymentToken, bytes32 details, uint8[7] flags, uint256 proposalId, address indexed delegateKey, address indexed memberAddress);
    event CancelProposal(uint256 indexed proposalId, address applicantAddress);
    event SponsorProposal(address indexed delegateKey, address indexed memberAddress, uint256 proposalId, uint256 proposalIndex, uint256 startingPeriod);
    event SubmitVote(uint256 proposalId, uint256 indexed proposalIndex, address indexed delegateKey, address indexed memberAddress, uint8 uintVote);
    event ProcessProposal(uint256 indexed proposalIndex, uint256 indexed proposalId, bool didPass);
    event ProcessWhitelistProposal(uint256 indexed proposalIndex, uint256 indexed proposalId, bool didPass);
    event ProcessGuildActionProposal(uint256 indexed proposalIndex, uint256 indexed proposalId, bool didPass);
    event ProcessGuildKickProposal(uint256 indexed proposalIndex, uint256 indexed proposalId, bool didPass);
    event UpdateDelegateKey(address indexed memberAddress, address newDelegateKey);
    event Transfer(address indexed from, address indexed to, uint256 amount); 
    event Ragequit(address indexed memberAddress, uint256 sharesToBurn, uint256 lootToBurn);
    event TokensCollected(address indexed token, uint256 amountToCollect);
    event Withdraw(address indexed memberAddress, address token, uint256 amount);
    
    
    
    
    address public constant GUILD = address(0xdead);
    address public constant ESCROW = address(0xbeef);
    address public constant TOTAL = address(0xbabe);
    
    uint256 public proposalCount; 
    uint256 public totalShares; 
    uint256 public totalLoot; 
    uint256 public totalGuildBankTokens; 

    mapping(uint256 => Action) public actions; 
    mapping(address => uint256) private balances; 
    mapping(address => mapping(address => uint256)) private userTokenBalances; 

    enum Vote {
        Null, 
        Yes,
        No
    }
    
    struct Member {
        address delegateKey; 
        uint8 exists; 
        uint256 shares; 
        uint256 loot; 
        uint256 highestIndexYesVote; 
        uint256 jailed; 
    }
    
    struct Action {
        address proposer; 
        address to; 
        uint256 value; 
        bytes data; 
    }

    struct Proposal {
        address applicant; 
        address proposer; 
        address sponsor; 
        address tributeToken; 
        address paymentToken; 
        uint8[7] flags; 
        uint256 sharesRequested; 
        uint256 lootRequested; 
        uint256 paymentRequested; 
        uint256 tributeOffered; 
        uint256 startingPeriod; 
        uint256 yesVotes; 
        uint256 noVotes; 
        uint256 maxTotalSharesAndLootAtYesVote; 
        bytes32 details; 
        mapping(address => Vote) votesByMember; 
    }

    mapping(address => bool) public tokenWhitelist;
    address[] public approvedTokens;

    mapping(address => bool) public proposedToWhitelist;
    mapping(address => bool) public proposedToKick;
    
    mapping(address => Member) public members;
    mapping(address => address) public memberAddressByDelegateKey;
    
    mapping(uint256 => Proposal) public proposals;

    uint256[] private proposalQueue;

    modifier onlyDelegate {
        require(members[memberAddressByDelegateKey[msg.sender]].shares > 0, "not delegate");
        _;
    }
    
    constructor(
        address _depositToken,
        address _wrapperToken,
        address[] memory _summoner,
        uint256[] memory _summonerShares,
        uint256 _summonerDeposit,
        uint256 _proposalDeposit,
        uint256 _processingReward,
        uint256 _periodDuration,
        uint256 _votingPeriodLength,
        uint256 _gracePeriodLength,
        uint256 _dilutionBound
    ) public {
        require(_summoner.length == _summonerShares.length, "summoner & shares must match");
        
        for (uint256 i = 0; i < _summoner.length; i++) {
            registerMember(_summoner[i], _summonerShares[i]);
            mintGuildToken(_summoner[i], _summonerShares[i]);
            totalShares += _summonerShares[i];
        }
        
        require(totalShares <= MAX_GUILD_BOUND, "guild maxed");
        
        tokenWhitelist[_depositToken] = true;
        approvedTokens.push(_depositToken);
        
        if (_summonerDeposit > 0) {
            totalGuildBankTokens += 1;
            unsafeAddToBalance(GUILD, _depositToken, _summonerDeposit);
        }
        
        depositToken = _depositToken;
        wrapperToken = _wrapperToken;
        proposalDeposit = _proposalDeposit;
        processingReward = _processingReward;
        periodDuration = _periodDuration;
        votingPeriodLength = _votingPeriodLength;
        gracePeriodLength = _gracePeriodLength;
        dilutionBound = _dilutionBound;
        summoningTime = now;
    }
    
    
    function updateGovernanceParams( 
        address _depositToken,
        address _wrapperToken,
        uint256 _proposalDeposit,
        uint256 _processingReward,
        uint256 _periodDuration,
        uint256 _votingPeriodLength,
        uint256 _gracePeriodLength,
        uint256 _dilutionBound
    ) public {
        require(msg.sender == address(this), "not permitted");
        
        depositToken = _depositToken;
        wrapperToken = _wrapperToken;
        proposalDeposit = _proposalDeposit;
        processingReward = _processingReward;
        periodDuration = _periodDuration;
        votingPeriodLength = _votingPeriodLength;
        gracePeriodLength = _gracePeriodLength;
        dilutionBound = _dilutionBound;
    }

    
    function submitProposal(
        address applicant,
        uint256 sharesRequested,
        uint256 lootRequested,
        uint256 tributeOffered,
        address tributeToken,
        uint256 paymentRequested,
        address paymentToken,
        bytes32 details
    ) payable external nonReentrant returns (uint256 proposalId) {
        require(sharesRequested.add(lootRequested) <= MAX_GUILD_BOUND, "guild maxed");
        require(tokenWhitelist[tributeToken], "tributeToken not whitelisted");
        require(tokenWhitelist[paymentToken], "paymentToken not whitelisted");
        require(applicant != GUILD && applicant != ESCROW && applicant != TOTAL, "applicant unreservable");
        require(members[applicant].jailed == 0, "applicant jailed");

        if (tributeOffered > 0 && userTokenBalances[GUILD][tributeToken] == 0) {
            require(totalGuildBankTokens < MAX_TOKEN_GUILDBANK_COUNT, "guildbank maxed");
        }
        
        
        if (tributeToken == wETH && msg.value > 0) {
            require(msg.value == tributeOffered, "insufficient ETH");
            IWETH(wETH).deposit();
            (bool success, ) = wETH.call.value(msg.value)("");
            require(success, "transfer failed");
            IWETH(wETH).transfer(address(this), msg.value);
        } else {
            IERC20(tributeToken).transferFrom(msg.sender, address(this), tributeOffered);
        }
        
        unsafeAddToBalance(ESCROW, tributeToken, tributeOffered);

        uint8[7] memory flags; 

        _submitProposal(applicant, sharesRequested, lootRequested, tributeOffered, tributeToken, paymentRequested, paymentToken, details, flags);
        
        return proposalCount - 1; 
    }
    
    function submitWhitelistProposal(address tokenToWhitelist, bytes32 details) external returns (uint256 proposalId) {
        require(tokenToWhitelist != address(0), "need token");
        require(!tokenWhitelist[tokenToWhitelist], "already whitelisted");
        require(approvedTokens.length < MAX_TOKEN_WHITELIST_COUNT, "whitelist maxed");

        uint8[7] memory flags; 
        flags[4] = 1; 

        _submitProposal(address(0), 0, 0, 0, tokenToWhitelist, 0, address(0), details, flags);
        
        return proposalCount - 1;
    }
    
    function submitGuildActionProposal( 
        address actionTo,
        uint256 actionValue,
        bytes calldata actionData,
        bytes32 details
    ) external returns (uint256 proposalId) {
        
        Action memory action = Action({
            proposer: msg.sender,
            to: actionTo,
            value: actionValue,
            data: actionData
        });
        
        actions[proposalId] = action;
        
        uint8[7] memory flags; 
        flags[6] = 1; 
        
        _submitProposal(address(this), 0, 0, 0, address(0), 0, address(0), details, flags);
        
        return proposalCount - 1;
    }

    function submitGuildKickProposal(address memberToKick, bytes32 details) external returns (uint256 proposalId) {
        Member memory member = members[memberToKick];

        require(member.shares > 0 || member.loot > 0, "must have share or loot");
        require(members[memberToKick].jailed == 0, "already jailed");

        uint8[7] memory flags; 
        flags[5] = 1; 

        _submitProposal(memberToKick, 0, 0, 0, address(0), 0, address(0), details, flags);
        
        return proposalCount - 1;
    }
    
    function _submitProposal(
        address applicant,
        uint256 sharesRequested,
        uint256 lootRequested,
        uint256 tributeOffered,
        address tributeToken,
        uint256 paymentRequested,
        address paymentToken,
        bytes32 details,
        uint8[7] memory flags
    ) internal {
        Proposal memory proposal = Proposal({
            applicant : applicant,
            proposer : msg.sender,
            sponsor : address(0),
            tributeToken : tributeToken,
            paymentToken : paymentToken,
            flags : flags,
            sharesRequested : sharesRequested,
            lootRequested : lootRequested,
            paymentRequested : paymentRequested,
            tributeOffered : tributeOffered,
            startingPeriod : 0,
            yesVotes : 0,
            noVotes : 0,
            maxTotalSharesAndLootAtYesVote : 0,
            details : details
        });
        
        proposals[proposalCount] = proposal;
        address memberAddress = memberAddressByDelegateKey[msg.sender];
        
        emit SubmitProposal(applicant, sharesRequested, lootRequested, tributeOffered, tributeToken, paymentRequested, paymentToken, details, flags, proposalCount, msg.sender, memberAddress);
        
        proposalCount += 1;
    }

    function sponsorProposal(uint256 proposalId) external nonReentrant onlyDelegate {
        
        IERC20(depositToken).transferFrom(msg.sender, address(this), proposalDeposit);
        unsafeAddToBalance(ESCROW, depositToken, proposalDeposit);

        Proposal storage proposal = proposals[proposalId];

        require(proposal.proposer != address(0), "unproposed");
        require(proposal.flags[0] == 0, "already sponsored");
        require(proposal.flags[3] == 0, "cancelled");
        require(members[proposal.applicant].jailed == 0, "applicant jailed");

        if (proposal.tributeOffered > 0 && userTokenBalances[GUILD][proposal.tributeToken] == 0) {
            require(totalGuildBankTokens < MAX_TOKEN_GUILDBANK_COUNT, "guildbank maxed");
        }

        
        if (proposal.flags[4] == 1) {
            require(!tokenWhitelist[address(proposal.tributeToken)], "already whitelisted");
            require(!proposedToWhitelist[address(proposal.tributeToken)], "already whitelist proposed");
            require(approvedTokens.length < MAX_TOKEN_WHITELIST_COUNT, "whitelist maxed");
            proposedToWhitelist[address(proposal.tributeToken)] = true;

        
        } else if (proposal.flags[5] == 1) {
            require(!proposedToKick[proposal.applicant], "kick already proposed");
            proposedToKick[proposal.applicant] = true;
        }

        
        uint256 startingPeriod = max(
            getCurrentPeriod(),
            proposalQueue.length == 0 ? 0 : proposals[proposalQueue[proposalQueue.length - 1]].startingPeriod
        ) + 1;

        proposal.startingPeriod = startingPeriod;

        address memberAddress = memberAddressByDelegateKey[msg.sender];
        proposal.sponsor = memberAddress;

        proposal.flags[0] = 1; 

        
        proposalQueue.push(proposalId);
        
        emit SponsorProposal(msg.sender, memberAddress, proposalId, proposalQueue.length - 1, startingPeriod);
    }

    
    function submitVote(uint256 proposalIndex, uint8 uintVote) external onlyDelegate {
        address memberAddress = memberAddressByDelegateKey[msg.sender];
        Member storage member = members[memberAddress];

        require(proposalIndex < proposalQueue.length, "unproposed");
        Proposal storage proposal = proposals[proposalQueue[proposalIndex]];

        require(uintVote < 3, "not < 3");
        Vote vote = Vote(uintVote);

        require(getCurrentPeriod() >= proposal.startingPeriod, "voting pending");
        require(!hasVotingPeriodExpired(proposal.startingPeriod), "proposal expired");
        require(proposal.votesByMember[memberAddress] == Vote.Null, "member voted");
        require(vote == Vote.Yes || vote == Vote.No, "vote Yes or No");

        proposal.votesByMember[memberAddress] = vote;

        if (vote == Vote.Yes) {
            proposal.yesVotes = proposal.yesVotes.add(member.shares);

            
            if (proposalIndex > member.highestIndexYesVote) {
                member.highestIndexYesVote = proposalIndex;
            }

            
            if (totalSupply() > proposal.maxTotalSharesAndLootAtYesVote) {
                proposal.maxTotalSharesAndLootAtYesVote = totalSupply();
            }

        } else if (vote == Vote.No) {
            proposal.noVotes = proposal.noVotes.add(member.shares);
        }
     
        
        emit SubmitVote(proposalQueue[proposalIndex], proposalIndex, msg.sender, memberAddress, uintVote);
    }

    function processProposal(uint256 proposalIndex) external {
        _validateProposalForProcessing(proposalIndex);

        uint256 proposalId = proposalQueue[proposalIndex];
        Proposal storage proposal = proposals[proposalId];

        require(proposal.flags[4] == 0 && proposal.flags[5] == 0, "not standard proposal");

        proposal.flags[1] = 1; 

        bool didPass = _didPass(proposalIndex);

        
        if (totalSupply().add(proposal.sharesRequested).add(proposal.lootRequested) > MAX_GUILD_BOUND) {
            didPass = false;
        }

        
        if (proposal.paymentRequested > userTokenBalances[GUILD][proposal.paymentToken]) {
            didPass = false;
        }

        
        if (proposal.tributeOffered > 0 && userTokenBalances[GUILD][proposal.tributeToken] == 0 && totalGuildBankTokens >= MAX_TOKEN_GUILDBANK_COUNT) {
           didPass = false;
        }

        
        if (didPass == true) {
            proposal.flags[2] = 1; 

            
            if (members[proposal.applicant].exists == 1) {
                members[proposal.applicant].shares = members[proposal.applicant].shares.add(proposal.sharesRequested);
                members[proposal.applicant].loot = members[proposal.applicant].loot.add(proposal.lootRequested);

            
            } else {
                registerMember(proposal.applicant, proposal.sharesRequested);
            }

            
            mintGuildToken(proposal.applicant, proposal.sharesRequested + proposal.lootRequested);
            totalShares += proposal.sharesRequested;
            totalLoot += proposal.lootRequested;

            
            if (userTokenBalances[GUILD][proposal.tributeToken] == 0 && proposal.tributeOffered > 0) {
                totalGuildBankTokens += 1;
            }

            unsafeInternalTransfer(ESCROW, GUILD, proposal.tributeToken, proposal.tributeOffered);
            unsafeInternalTransfer(GUILD, proposal.applicant, proposal.paymentToken, proposal.paymentRequested);

            
            if (userTokenBalances[GUILD][proposal.paymentToken] == 0 && proposal.paymentRequested > 0) {
                totalGuildBankTokens -= 1;
            }

        
        } else {
            
            unsafeInternalTransfer(ESCROW, proposal.proposer, proposal.tributeToken, proposal.tributeOffered);
        }

        _returnDeposit(proposal.sponsor);
        
        emit ProcessProposal(proposalIndex, proposalId, didPass);
    }

    function processWhitelistProposal(uint256 proposalIndex) external {
        _validateProposalForProcessing(proposalIndex);

        uint256 proposalId = proposalQueue[proposalIndex];
        Proposal storage proposal = proposals[proposalId];

        require(proposal.flags[4] == 1, "not whitelist proposal");

        proposal.flags[1] = 1; 

        bool didPass = _didPass(proposalIndex);

        if (approvedTokens.length >= MAX_TOKEN_WHITELIST_COUNT) {
            didPass = false;
        }

        if (didPass == true) {
            proposal.flags[2] = 1; 

            tokenWhitelist[address(proposal.tributeToken)] = true;
            approvedTokens.push(proposal.tributeToken);
        }

        proposedToWhitelist[address(proposal.tributeToken)] = false;

        _returnDeposit(proposal.sponsor);
        
        emit ProcessWhitelistProposal(proposalIndex, proposalId, didPass);
    }

    function processGuildActionProposal(uint256 proposalIndex) external nonReentrant returns (bytes memory) {
        _validateProposalForProcessing(proposalIndex);
        
        uint256 proposalId = proposalQueue[proposalIndex];
        Action storage action = actions[proposalId];
        Proposal storage proposal = proposals[proposalId];
        
        require(proposal.flags[6] == 1, "not action proposal");

        proposal.flags[1] = 1; 

        bool didPass = _didPass(proposalIndex);
        
        if (didPass == true) {
            proposal.flags[2] = 1; 
            require(address(this).balance >= action.value, "insufficient ether");
            
            
            (bool success, bytes memory retData) = action.to.call.value(action.value)(action.data);
            require(success, "call failure");
            
            return retData;
        }
        
        emit ProcessGuildActionProposal(proposalIndex, proposalId, didPass);
    }

    function processGuildKickProposal(uint256 proposalIndex) external {
        _validateProposalForProcessing(proposalIndex);

        uint256 proposalId = proposalQueue[proposalIndex];
        Proposal storage proposal = proposals[proposalId];

        require(proposal.flags[5] == 1, "not kick proposal");

        proposal.flags[1] = 1; 

        bool didPass = _didPass(proposalIndex);

        if (didPass == true) {
            proposal.flags[2] = 1; 
            Member storage member = members[proposal.applicant];
            member.jailed = proposalIndex;

            
            member.shares = 0; 
            member.loot += member.shares;
            totalShares -= member.shares;
            totalLoot += member.shares;
        }

        proposedToKick[proposal.applicant] = false;

        _returnDeposit(proposal.sponsor);
        
        emit ProcessGuildKickProposal(proposalIndex, proposalId, didPass);
    }

    function _didPass(uint256 proposalIndex) internal view returns (bool didPass) {
        Proposal memory proposal = proposals[proposalQueue[proposalIndex]];
        
        if (proposal.yesVotes > proposal.noVotes) {
            didPass = true;
        }
        
        
        if ((totalSupply().mul(dilutionBound)) < proposal.maxTotalSharesAndLootAtYesVote) {
            didPass = false;
        }

        
        
        
        if (members[proposal.applicant].jailed != 0) {
            didPass = false;
        }

        return didPass;
    }

    function _validateProposalForProcessing(uint256 proposalIndex) internal view {
        require(proposalIndex < proposalQueue.length, "no such proposal");
        Proposal memory proposal = proposals[proposalQueue[proposalIndex]];

        require(getCurrentPeriod() >= proposal.startingPeriod + votingPeriodLength + gracePeriodLength, "proposal not ready");
        require(proposal.flags[1] == 0, "proposal already processed");
        require(proposalIndex == 0 || proposals[proposalQueue[proposalIndex - 1]].flags[1] == 1, "previous proposal unprocessed");
    }

    function _returnDeposit(address sponsor) internal {
        unsafeInternalTransfer(ESCROW, msg.sender, depositToken, processingReward);
        unsafeInternalTransfer(ESCROW, sponsor, depositToken, proposalDeposit - processingReward);
    }

    function ragequit(uint256 sharesToBurn, uint256 lootToBurn) external {
        require(members[msg.sender].exists == 1, "not member");
        
        _ragequit(msg.sender, sharesToBurn, lootToBurn);
    }

    function _ragequit(address memberAddress, uint256 sharesToBurn, uint256 lootToBurn) internal {
        uint256 initialTotalSharesAndLoot = totalSupply();

        Member storage member = members[memberAddress];

        require(member.shares >= sharesToBurn, "insufficient shares");
        require(member.loot >= lootToBurn, "insufficient loot");

        require(canRagequit(member.highestIndexYesVote), "cannot ragequit until highest index proposal member voted YES on is processed");

        uint256 sharesAndLootToBurn = sharesToBurn.add(lootToBurn);

        
        member.shares -= sharesToBurn;
        member.loot -= lootToBurn;
        burnGuildToken(memberAddress, sharesAndLootToBurn);
        totalShares -= sharesToBurn;
        totalLoot -= lootToBurn;

        for (uint256 i = 0; i < approvedTokens.length; i++) {
            uint256 amountToRagequit = fairShare(userTokenBalances[GUILD][approvedTokens[i]], sharesAndLootToBurn, initialTotalSharesAndLoot);
            if (amountToRagequit > 0) { 
                
                
                userTokenBalances[GUILD][approvedTokens[i]] -= amountToRagequit;
                userTokenBalances[memberAddress][approvedTokens[i]] += amountToRagequit;
            }
        }

        emit Ragequit(memberAddress, sharesToBurn, lootToBurn);
    }

    function ragekick(address memberToKick) external {
        Member storage member = members[memberToKick];

        require(member.jailed != 0, "not jailed");
        require(member.loot > 0, "no loot"); 
        require(canRagequit(member.highestIndexYesVote), "cannot ragequit until highest index proposal member voted YES on is processed");

        _ragequit(memberToKick, 0, member.loot);
    }
    
    function withdrawBalance(address token, uint256 amount) external nonReentrant {
        _withdrawBalance(token, amount);
    }

    function withdrawBalances(address[] calldata tokens, uint256[] calldata amounts, bool max) external nonReentrant {
        require(tokens.length == amounts.length, "tokens & amounts must match");

        for (uint256 i=0; i < tokens.length; i++) {
            uint256 withdrawAmount = amounts[i];
            if (max) { 
                withdrawAmount = userTokenBalances[msg.sender][tokens[i]];
            }

            _withdrawBalance(tokens[i], withdrawAmount);
        }
    }
    
    function _withdrawBalance(address token, uint256 amount) internal {
        require(userTokenBalances[msg.sender][token] >= amount, "insufficient balance");
        
        IERC20(token).transfer(msg.sender, amount);
        unsafeSubtractFromBalance(msg.sender, token, amount);
        
        emit Withdraw(msg.sender, token, amount);
    }

    function collectTokens(address token) external onlyDelegate {
        uint256 amountToCollect = IERC20(token).balanceOf(address(this)) - userTokenBalances[TOTAL][token];
        
        require(amountToCollect > 0, "no tokens");
        require(tokenWhitelist[token], "not whitelisted");
        require(userTokenBalances[GUILD][token] > 0, "no guild balance");
        
        if (userTokenBalances[GUILD][token] == 0) {totalGuildBankTokens += 1;}
        unsafeAddToBalance(GUILD, token, amountToCollect);

        emit TokensCollected(token, amountToCollect);
    }

    
    function cancelProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.flags[0] == 0, "proposal already sponsored");
        require(proposal.flags[3] == 0, "proposal already cancelled");
        require(msg.sender == proposal.proposer, "only proposer cancels");

        proposal.flags[3] = 1; 
        
        unsafeInternalTransfer(ESCROW, proposal.proposer, proposal.tributeToken, proposal.tributeOffered);
        
        emit CancelProposal(proposalId, msg.sender);
    }

    function updateDelegateKey(address newDelegateKey) external {
        require(members[msg.sender].shares > 0, "not shareholder");
        require(newDelegateKey != address(0), "newDelegateKey zeroed");

        
        if (newDelegateKey != msg.sender) {
            require(members[newDelegateKey].exists == 0, "cannot overwrite members");
            require(members[memberAddressByDelegateKey[newDelegateKey]].exists == 0, "cannot overwrite keys");
        }

        Member storage member = members[msg.sender];
        memberAddressByDelegateKey[member.delegateKey] = address(0);
        memberAddressByDelegateKey[newDelegateKey] = msg.sender;
        member.delegateKey = newDelegateKey;

        emit UpdateDelegateKey(msg.sender, newDelegateKey);
    }
    
    
    function canRagequit(uint256 highestIndexYesVote) public view returns (bool) {
        require(highestIndexYesVote < proposalQueue.length, "no such proposal");
        
        return proposals[proposalQueue[highestIndexYesVote]].flags[1] == 1;
    }

    function hasVotingPeriodExpired(uint256 startingPeriod) public view returns (bool) {
        return getCurrentPeriod() >= startingPeriod + votingPeriodLength;
    }
    
    
    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x >= y ? x : y;
    }
    
    function getCurrentPeriod() public view returns (uint256) {
        return now.sub(summoningTime).div(periodDuration);
    }
    
    function getMemberProposalVote(address memberAddress, uint256 proposalIndex) public view returns (Vote) {
        require(members[memberAddress].exists == 1, "not member");
        require(proposalIndex < proposalQueue.length, "unproposed");
        
        return proposals[proposalQueue[proposalIndex]].votesByMember[memberAddress];
    }

    function getProposalFlags(uint256 proposalId) public view returns (uint8[7] memory) {
        return proposals[proposalId].flags;
    }
    
    function getProposalQueueLength() public view returns (uint256) {
        return proposalQueue.length;
    }
    
    function getTokenCount() public view returns (uint256) {
        return approvedTokens.length;
    }

    function getUserTokenBalance(address user, address token) public view returns (uint256) {
        return userTokenBalances[user][token];
    }
    
    
    function() external payable {}
    
    function fairShare(uint256 balance, uint256 shares, uint256 totalSharesAndLoot) internal pure returns (uint256) {
        require(totalSharesAndLoot != 0);

        if (balance == 0) { return 0; }

        uint256 prod = balance * shares;

        if (prod / balance == shares) { 
            return prod / totalSharesAndLoot;
        }

        return (balance / totalSharesAndLoot) * shares;
    }
    
    function registerMember(address newMember, uint256 shares) internal {
        
        if (members[memberAddressByDelegateKey[newMember]].exists == 1) {
            address memberToOverride = memberAddressByDelegateKey[newMember];
            memberAddressByDelegateKey[memberToOverride] = memberToOverride;
            members[memberToOverride].delegateKey = memberToOverride;
        }
        
        members[newMember] = Member({
            delegateKey : newMember,
            exists : 1, 
            shares : shares,
            loot : 0,
            highestIndexYesVote : 0,
            jailed : 0
        });

        memberAddressByDelegateKey[newMember] = newMember;
    }
    
    function unsafeAddToBalance(address user, address token, uint256 amount) internal {
        userTokenBalances[user][token] += amount;
        userTokenBalances[TOTAL][token] += amount;
    }
    
    function unsafeInternalTransfer(address from, address to, address token, uint256 amount) internal {
        unsafeSubtractFromBalance(from, token, amount);
        unsafeAddToBalance(to, token, amount);
    }

    function unsafeSubtractFromBalance(address user, address token, uint256 amount) internal {
        userTokenBalances[user][token] -= amount;
        userTokenBalances[TOTAL][token] -= amount;
    }
    
    
    
    function balanceOf(address memberAddress) external view returns (uint256) { 
        return balances[memberAddress];
    }
    
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256) { 
        return totalShares + totalLoot;
    }
    
    
    function burnGuildToken(address memberAddress, uint256 amount) internal {
        balances[memberAddress] -= amount;
        
        emit Transfer(memberAddress, address(0), amount);
    }
    
    function convertSharesToLoot(uint256 sharesToLoot) external {
        members[msg.sender].shares -= sharesToLoot;
        members[msg.sender].loot += sharesToLoot;
    }
    
    function mintGuildToken(address memberAddress, uint256 amount) internal {
        balances[memberAddress] += amount;
        
        emit Transfer(address(0), memberAddress, amount);
    }
    
    function unwrapShares(uint256 amount) external nonReentrant {
        IERC20(wrapperToken).transferFrom(msg.sender, address(this), amount);
        
        
        if (members[msg.sender].exists == 1) {
            members[msg.sender].shares = members[msg.sender].shares.add(amount);

            
            } else {
                registerMember(msg.sender, amount);
            }

            
            mintGuildToken(msg.sender, amount);
            totalShares += amount;

        if (userTokenBalances[GUILD][wrapperToken] == 0) {totalGuildBankTokens += 1;}
        unsafeAddToBalance(GUILD, wrapperToken, amount);
    }

    
    function transfer(address receiver, uint256 lootToTransfer) external {
        members[msg.sender].loot = members[msg.sender].loot.sub(lootToTransfer);
        members[receiver].loot = members[msg.sender].loot.add(lootToTransfer);
        
        balances[msg.sender] -= lootToTransfer;
        balances[receiver] += lootToTransfer;
        
        emit Transfer(msg.sender, receiver, lootToTransfer);
    }
}

contract MolochSummoner {
    Moloch private baal;

    event SummonMoloch(address indexed baal, address depositToken, address wrapperToken, address[] indexed summoner, uint256[] indexed summonerShares, uint256 summoningDeposit, uint256 proposalDeposit, uint256 processingReward, uint256 periodDuration, uint256 votingPeriodLength, uint256 gracePeriodLength, uint256 dilutionBound, uint256 summoningTime);
 
    function summonMoloch(
        address _depositToken,
        address _wrapperToken,
        address[] memory _summoner,
        uint256[] memory _summonerShares,
        uint256 _summonerDeposit,
        uint256 _proposalDeposit,
        uint256 _processingReward,
        uint256 _periodDuration,
        uint256 _votingPeriodLength,
        uint256 _gracePeriodLength,
        uint256 _dilutionBound
    ) public {
        baal = new Moloch(
            _depositToken,
            _wrapperToken,
            _summoner,
            _summonerShares,
            _summonerDeposit,
            _proposalDeposit,
            _processingReward,
            _periodDuration,
            _votingPeriodLength,
            _gracePeriodLength,
            _dilutionBound);

        IERC20(_depositToken).transferFrom(msg.sender, address(baal), _summonerDeposit); 

        emit SummonMoloch(address(baal), _depositToken, _wrapperToken, _summoner, _summonerShares, _summonerDeposit, _proposalDeposit, _processingReward, _periodDuration, _votingPeriodLength, _gracePeriodLength, _dilutionBound, now);
    }
}