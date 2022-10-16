pragma solidity ^0.4.26;

interface OrFeedInterface {
  function getExchangeRate(string fromSymbol, string toSymbol, string venue, uint256 amount) external view returns (uint256);
}

contract ProofEthSwap {
    function ETHtoUSD() external view returns(uint256){
        OrFeedInterface orFeed = OrFeedInterface(0x8316B082621CFedAB95bf4a44a1d4B64a6ffc336);
        return orFeed.getExchangeRate("ETH", "USD", "DEFAULT", 1e6);
    }
}