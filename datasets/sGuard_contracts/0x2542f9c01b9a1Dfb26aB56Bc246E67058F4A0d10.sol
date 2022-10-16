pragma solidity ^0.6.2;



contract MsgSender {

    address public relayHub;

    
    function _msgSender() internal view virtual returns (address payable) {
        if (msg.sender != relayHub) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    function _getRelayedCallSender() private pure returns (address payable result) {
        
        
        
        
        

        
        

        
        bytes memory array = msg.data;
        uint256 index = msg.data.length;

        
        assembly {
            
            result := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }
}


contract CommunityOracle is MsgSender {

  
  mapping (address => bool) public appointedOracle;
  mapping (address => bool) public oracleSubmitted;
  mapping (string => uint) public proposals;
  string[] public proposalList;
  uint public submitted;
  uint public minimumOracles;

  event Beacon(string bls, uint beacon);

  
  constructor(address[] memory _oracles, uint _minimumOracles, address _relayHub) public {
    require(_oracles.length > _minimumOracles, "More appointed oracles are required");
    for(uint i=0; i<_oracles.length; i++) {
        appointedOracle[_oracles[i]] = true;

    }
    minimumOracles = _minimumOracles;
    relayHub = _relayHub;
  }

  
  function submitBeacon(string memory _proposal) public {
      require(appointedOracle[_msgSender()], "Only appointed oracle");
      require(!oracleSubmitted[_msgSender()], "Appointed oracle has already submitted");
      oracleSubmitted[_msgSender()] = true;
      submitted = submitted + 1;

      
      if(proposals[_proposal] == 0) {
          proposalList.push(_proposal);
      }

      proposals[_proposal] = proposals[_proposal] + 1;
  }

  
  
  function getBeacon() public returns (uint) {
    require(submitted >= minimumOracles, "A minimum number of oracles must respond before fetching beacon");

    string memory winningProposal = proposalList[0];

    
    for(uint i=1; i<proposalList.length; i++) {
      string memory proposal = proposalList[i];

      
      if(proposals[proposal] > proposals[winningProposal]) {
        winningProposal = proposal;
      }
    }

    uint beacon = uint(keccak256(abi.encode(winningProposal)));
    emit Beacon(winningProposal, beacon);
    return beacon;
  }
}

contract CyberDice is MsgSender {

    
    mapping(address => uint) public userTickets;
    address[] public entries;

    
    mapping(address => bool) public relayers;

    uint public startBlock; 
    uint public deadline; 

    
    address public oracleCon; 
    address public winner;

    
    uint public roundNumber;

    
    uint public beacon;

    
    event Entry(address signer, uint newTickets, string message);
    event Deposit(address depositor, uint deposit);
    event RequestBeacon();
    event Winner(uint winningTicket, address winner, uint prize); 

    
    constructor(address[] memory _relayers, address _relayHub, address _oracleCon, uint _deadline, uint _roundNumber) public {
        
        for(uint i=0; i<_relayers.length; i++) {
            relayers[_relayers[i]] = true;
        }

        relayHub = _relayHub; 
        startBlock = block.number; 
        deadline = _deadline; 
        oracleCon = _oracleCon; 
        roundNumber = _roundNumber; 
    }

    
    function computeWinner() public {
        require(now > deadline, "We must wait until the competition deadline before computing the winner.");
        require(winner == address(0), "Winner already set");

        beacon = CommunityOracle(oracleCon).getBeacon();
        require(beacon != 0, "Beacon is not ready");

        uint winningTicket = beacon % entries.length;
        winner = entries[winningTicket];

        emit Winner(winningTicket, winner, address(this).balance);
    }

    
    function appendTickets(address _signer, uint _tickets) internal {
        userTickets[_signer] = userTickets[_signer] + _tickets;
        for(uint i=0; i<_tickets; i++) {
            entries.push(_signer);
        }
    }
    
    
    function submit(string memory _message) public
    {
        require(relayers[tx.origin], "All entries must be sent via any.sender");
        require(msg.sender == relayHub, "All entries must be sent via the RelayHub");
        require(deadline > now, "You have missed your chance to submit a ticket!");
        address ticketOwner = _msgSender();
        uint tickets = getNoTickets();
        appendTickets(ticketOwner, tickets);

        
        emit Entry(ticketOwner, tickets, _message);
    }

    
    function getNoTickets() internal view returns (uint) {

        
        if(5760 > block.number - startBlock) {
            return 3;
        }

        
        if(block.number % 5760 < 960) {
            return 2;
        }

        
        if(block.number % 5760 > 1920 && block.number % 5760 < 2880) {
            return 2;
        }

        
        return 1;
    }

    
    function totalTickets() public view returns(uint) {
        return entries.length;
    }

    
    function sendPrize() public payable {
        require(winner != address(0), "Winner must be set");
        payable(winner).transfer(address(this).balance);
      
    }

    
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}