pragma solidity 0.6.2;




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

  address public admin; 
  event Beacon(string bls, uint beacon);

  
  constructor(uint _minimumOracles, address _relayHub) public {
    admin = msg.sender;
    minimumOracles = _minimumOracles;
    relayHub = _relayHub;
  }

  
  function installOracle(address _oracle) public {
    require(admin == _msgSender(), "Only admin can install oracle");
    appointedOracle[_oracle] = true;
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