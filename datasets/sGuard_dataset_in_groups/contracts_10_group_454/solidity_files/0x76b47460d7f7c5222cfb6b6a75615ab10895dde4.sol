pragma solidity ^0.5.0;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.5.0;



interface IPriceOracleGetter {
    
    function getAssetPrice(address _asset) external view returns (uint256);
}



pragma solidity ^0.5.0;

interface IChainlinkAggregator {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy);
}



pragma solidity ^0.5.0;

library EthAddressLib {

    
    function ethAddress() internal pure returns(address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}



pragma solidity ^0.5.0;












contract ChainlinkProxyPriceProvider is IPriceOracleGetter, Ownable {

    event AssetSourceUpdated(address indexed asset, address indexed source);
    event FallbackOracleUpdated(address indexed fallbackOracle);

    mapping(address => IChainlinkAggregator) private assetsSources;
    IPriceOracleGetter private fallbackOracle;

    
    
    
    
    
    constructor(address[] memory _assets, address[] memory _sources, address _fallbackOracle) public {
        internalSetFallbackOracle(_fallbackOracle);
        internalSetAssetsSources(_assets, _sources);
    }

    
    
    
    function setAssetSources(address[] calldata _assets, address[] calldata _sources) external onlyOwner {
        internalSetAssetsSources(_assets, _sources);
    }

    
    
    
    function setFallbackOracle(address _fallbackOracle) external onlyOwner {
        internalSetFallbackOracle(_fallbackOracle);
    }

    
    
    
    function internalSetAssetsSources(address[] memory _assets, address[] memory _sources) internal {
        require(_assets.length == _sources.length, "INCONSISTENT_PARAMS_LENGTH");
        for (uint256 i = 0; i < _assets.length; i++) {
            assetsSources[_assets[i]] = IChainlinkAggregator(_sources[i]);
            emit AssetSourceUpdated(_assets[i], _sources[i]);
        }
    }

    
    
    function internalSetFallbackOracle(address _fallbackOracle) internal {
        fallbackOracle = IPriceOracleGetter(_fallbackOracle);
        emit FallbackOracleUpdated(_fallbackOracle);
    }

    
    
    function getAssetPrice(address _asset) public view returns(uint256) {
        IChainlinkAggregator source = assetsSources[_asset];
        if (_asset == EthAddressLib.ethAddress()) {
            return 1 ether;
        } else {
            
            if (address(source) == address(0)) {
                return IPriceOracleGetter(fallbackOracle).getAssetPrice(_asset);
            } else {
                int256 _price = IChainlinkAggregator(source).latestAnswer();
                if (_price > 0) {
                    return uint256(_price);
                } else {
                    return IPriceOracleGetter(fallbackOracle).getAssetPrice(_asset);
                }
            }
        }
    }

    
    
    function getAssetsPrices(address[] calldata _assets) external view returns(uint256[] memory) {
        uint256[] memory prices = new uint256[](_assets.length);
        for (uint256 i = 0; i < _assets.length; i++) {
            prices[i] = getAssetPrice(_assets[i]);
        }
        return prices;
    }

    
    
    
    function getSourceOfAsset(address _asset) external view returns(address) {
        return address(assetsSources[_asset]);
    }

    
    
    function getFallbackOracle() external view returns(address) {
        return address(fallbackOracle);
    }
}