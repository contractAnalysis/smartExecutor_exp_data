pragma solidity 0.4.24;


interface AggregatorInterface {
  function currentAnswer() external view returns (int256);
}


contract AggregatorProxy {
  AggregatorInterface public aggregator;

  
  constructor(address _aggregator) public {
    aggregator = AggregatorInterface(_aggregator);
  }

  
  function latestAnswer() external view returns (int256) {
    return aggregator.currentAnswer();
  }
}