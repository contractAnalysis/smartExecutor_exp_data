pragma solidity 0.4.24;


contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  
  constructor() public {
    owner = msg.sender;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy);
}


contract AggregatorProxy is AggregatorInterface, Ownable {

  AggregatorInterface public aggregator;

  constructor(address _aggregator) public Ownable() {
    setAggregator(_aggregator);
  }

  
  function latestAnswer()
    external
    view
    returns (int256)
  {
    return aggregator.latestAnswer();
  }

  
  function latestTimestamp()
    external
    view
    returns (uint256)
  {
    return aggregator.latestTimestamp();
  }

  
  function getAnswer(uint256 _roundId)
    external
    view
    returns (int256)
  {
    return aggregator.getAnswer(_roundId);
  }

  
  function getTimestamp(uint256 _roundId)
    external
    view
    returns (uint256)
  {
    return aggregator.getTimestamp(_roundId);
  }

  
  function latestRound()
    external
    view
    returns (uint256)
  {
    return aggregator.latestRound();
  }

  
  function setAggregator(address _aggregator)
    public
    onlyOwner()
  {
    aggregator = AggregatorInterface(_aggregator);
  }

  
  function destroy()
    external
    onlyOwner()
  {
    selfdestruct(owner);
  }

}