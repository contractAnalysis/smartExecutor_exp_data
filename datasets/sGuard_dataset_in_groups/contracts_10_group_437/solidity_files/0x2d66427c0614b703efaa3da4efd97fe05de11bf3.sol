pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;


interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
}




struct TokenMetadata {
    address token;
    string name;
    string symbol;
    uint8 decimals;
}


struct Component {
    address token;    
    string tokenType; 
    uint256 rate;     
}



interface TokenAdapter {

    
    function getMetadata(address token) external view returns (TokenMetadata memory);

    
    function getComponents(address token) external view returns (Component[] memory);
}



interface IPieSmartPool {
    function getTokens() external view returns (address[] memory);
    function getBPool() external view returns (address);
}



interface BPool {
    function getFinalTokens() external view returns (address[] memory);
    function getBalance(address) external view returns (uint256);
    function getNormalizedWeight(address) external view returns (uint256);
}



contract PieDAOPieTokenAdapter is TokenAdapter {

    
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        return TokenMetadata({
            token: token,
            name: ERC20(token).name(),
            symbol: ERC20(token).symbol(),
            decimals: ERC20(token).decimals()
        });
    }

    
    function getComponents(address token) external view override returns (Component[] memory) {
        address[] memory underlyingTokensAddresses = IPieSmartPool(token).getTokens();
        uint256 totalSupply = ERC20(token).totalSupply();
        BPool bPool = BPool(IPieSmartPool(token).getBPool());

        Component[] memory underlyingTokens = new Component[](underlyingTokensAddresses.length);
        address underlyingToken;

        for (uint256 i = 0; i < underlyingTokens.length; i++) {
            underlyingToken = underlyingTokensAddresses[i];
            underlyingTokens[i] = Component({
                token: underlyingToken,
                tokenType: "ERC20",
                rate: bPool.getBalance(underlyingToken) * 1e18 / totalSupply
            });
        }

        return underlyingTokens;
    }
}