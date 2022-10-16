pragma solidity 0.6.6;


interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  
  
  
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{
}

contract AggregatorFacade is AggregatorV2V3Interface {

  AggregatorInterface public aggregator;
  uint8 public override decimals;
  string public override description;

  uint256 constant public override version = 2;

  
  
  string constant private V3_NO_DATA_ERROR = "No data present";

  constructor(
    address _aggregator,
    uint8 _decimals,
    string memory _description
  ) public {
    aggregator = AggregatorInterface(_aggregator);
    decimals = _decimals;
    description = _description;
  }

    function latestRound()
    external
    view
    virtual
    override
    returns (uint256)
  {
    return aggregator.latestRound();
  }

    function latestAnswer()
    external
    view
    virtual
    override
    returns (int256)
  {
    return aggregator.latestAnswer();
  }

    function latestTimestamp()
    external
    view
    virtual
    override
    returns (uint256)
  {
    return aggregator.latestTimestamp();
  }

    function latestRoundData()
    external
    view
    virtual
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    return _getRoundData(uint80(aggregator.latestRound()));
  }

    function getAnswer(uint256 _roundId)
    external
    view
    virtual
    override
    returns (int256)
  {
    return aggregator.getAnswer(_roundId);
  }

    function getTimestamp(uint256 _roundId)
    external
    view
    virtual
    override
    returns (uint256)
  {
    return aggregator.getTimestamp(_roundId);
  }

    function getRoundData(uint80 _roundId)
    external
    view
    virtual
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    return _getRoundData(_roundId);
  }


  
  function _getRoundData(uint80 _roundId)
    internal
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    answer = aggregator.getAnswer(_roundId);
    updatedAt = uint64(aggregator.getTimestamp(_roundId));

    require(updatedAt > 0, V3_NO_DATA_ERROR);

    return (_roundId, answer, updatedAt, updatedAt, _roundId);
  }

}