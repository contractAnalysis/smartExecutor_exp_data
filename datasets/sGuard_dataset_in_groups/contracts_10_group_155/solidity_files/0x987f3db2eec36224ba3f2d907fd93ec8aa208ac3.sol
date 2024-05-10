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



interface AToken {
    function underlyingAssetAddress() external view returns (address);
}



contract AaveTokenAdapter is TokenAdapter {

    
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        return TokenMetadata({
            token: token,
            name: ERC20(token).name(),
            symbol: ERC20(token).symbol(),
            decimals: ERC20(token).decimals()
        });
    }

    
    function getComponents(address token) external view override returns (Component[] memory) {
        address underlying = AToken(token).underlyingAssetAddress();

        Component[] memory underlyingTokens = new Component[](1);

        underlyingTokens[0] = Component({
            token: underlying,
            tokenType: "ERC20",
            rate: uint256(1e18)
        });

        return underlyingTokens;
    }
}