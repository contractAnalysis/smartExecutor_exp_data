interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}








contract DemaxBallot {

    struct Voter {
        uint weight; 
        bool voted;  
        address delegate; 
        uint vote;   
    }

    mapping(address => Voter) public voters;
    mapping(uint => uint) public proposals;

    address public governor;
    address public proposer;
    uint public value;
    uint public endBlockNumber;
    bool public ended;
    string public subject;
    string public content;

    uint private constant NONE = 0;
    uint private constant YES = 1;
    uint private constant NO = 2;

    uint public total;
    uint public createTime;

    modifier onlyGovernor() {
        require(msg.sender == governor, 'DemaxBallot: FORBIDDEN');
        _;
    }

    
    constructor(address _proposer, uint _value, uint _endBlockNumber, address _governor, string memory _subject, string memory _content) public {
        proposer = _proposer;
        value = _value;
        endBlockNumber = _endBlockNumber;
        governor = _governor;
        subject = _subject;
        content = _content;
        proposals[YES] = 0;
        proposals[NO] = 0;
        createTime = block.timestamp;
    }

    
    function _giveRightToVote(address voter) private returns (Voter storage) {
        require(block.number < endBlockNumber, "Bollot is ended");
        Voter storage sender = voters[voter];
        require(!sender.voted, "You already voted");
        sender.weight += IERC20(governor).balanceOf(voter);
        require(sender.weight != 0, "Has no right to vote");
        return sender;
    }

    
    function delegate(address to) public {
        Voter storage sender = _giveRightToVote(msg.sender);
        require(to != msg.sender, "Self-delegation is disallowed");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            
            require(to != msg.sender, "Found loop in delegation");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            
            
            proposals[delegate_.vote] += sender.weight;
            total += sender.weight;
        } else {
            
            
            delegate_.weight += sender.weight;
            total += sender.weight;
        }
    }

    
    function vote(uint proposal) public {
        Voter storage sender = _giveRightToVote(msg.sender);
        require(proposal==YES || proposal==NO, 'Only vote 1 or 2');
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal] += sender.weight;
        total += sender.weight;
    }

    
    function winningProposal() public view returns (uint) {
        if (proposals[YES] > proposals[NO]) {
            return YES;
        } else if (proposals[YES] < proposals[NO]) {
            return NO;
        } else {
            return NONE;
        }
    }

    function result() public view returns (bool) {
        uint winner = winningProposal();
        if (winner == YES) {
            return true;
        }
        return false;
    }

    function end() public onlyGovernor returns (bool) {
        require(block.number >= endBlockNumber, "ballot not yet ended");
        require(!ended, "end has already been called");
        ended = true;
        return result();
    }

    function weight(address user) external view returns (uint) {
        Voter memory voter = voters[user];
        return voter.weight;
    }

}





contract Governable {
    address public governor;

    event ChangeGovernor(address indexed _old, address indexed _new);

    modifier onlyGovernor() {
        require(msg.sender == governor, 'Governable: FORBIDDEN');
        _;
    }

    
    function initGovernorAddress(address _governor) internal {
        require(governor == address(0), 'Governable: INITIALIZED');
        require(_governor != address(0), 'Governable: INPUT_ADDRESS_IS_ZERO');
        governor = _governor;
    }

    function changeGovernor(address _new) public onlyGovernor {
        _changeGovernor(_new);
    }

    function _changeGovernor(address _new) internal {
        require(_new != address(0), 'Governable: INVALID_ADDRESS');
        require(_new != governor, 'Governable: NO_CHANGE');
        address old = governor;
        governor = _new;
        emit ChangeGovernor(old, _new);
    }

}



pragma solidity >=0.6.6;




contract DemaxBallotFactory is Governable {

    event Created(address indexed proposer, address indexed ballotAddr, uint createTime);

    constructor (address _governor) public {
        initGovernorAddress(_governor);
    }

    function create(address _proposer, uint _value, uint _endBlockNumber, string calldata _subject, string calldata _content) external onlyGovernor returns (address) {
        require(_value >= 0 && _endBlockNumber > block.number, 'DemaxBallotFactory: INVALID_PARAMTERS');
        address ballotAddr = address(
            new DemaxBallot(_proposer, _value, _endBlockNumber, governor, _subject, _content)
        );
        emit Created(_proposer, ballotAddr, block.timestamp);
        return ballotAddr;
    }
}