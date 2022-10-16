pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;


interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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



interface SetToken {
    function getUnits() external view returns (uint256[] memory);
    function naturalUnit() external view returns (uint256);
    function getComponents() external view returns(address[] memory);
}


interface RebalancingSetToken {
    function unitShares() external view returns (uint256);
    function naturalUnit() external view returns (uint256);
    function currentSet() external view returns (SetToken);
}



contract TokenSetsTokenAdapter is TokenAdapter {

    
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        return TokenMetadata({
            token: token,
            name: ERC20(token).name(),
            symbol: ERC20(token).symbol(),
            decimals: ERC20(token).decimals()
        });
    }

    
    function getComponents(address token) external view override returns (Component[] memory) {
        RebalancingSetToken rebalancingSetToken = RebalancingSetToken(token);
        uint256 tokenUnitShare = rebalancingSetToken.unitShares();
        uint256 tokenNaturalUnit = rebalancingSetToken.naturalUnit();
        uint256 tokenRate = 1e18 * tokenUnitShare / tokenNaturalUnit;

        SetToken setToken = rebalancingSetToken.currentSet();
        uint256[] memory unitShares = setToken.getUnits();
        uint256 naturalUnit = setToken.naturalUnit();
        address[] memory components = setToken.getComponents();

        Component[] memory underlyingTokens = new Component[](components.length);

        for (uint256 i = 0; i < underlyingTokens.length; i++) {
            underlyingTokens[i] = Component({
                token: components[i],
                tokenType: "ERC20",
                rate: tokenRate * unitShares[i] / naturalUnit
            });
        }

        return underlyingTokens;
    }
}