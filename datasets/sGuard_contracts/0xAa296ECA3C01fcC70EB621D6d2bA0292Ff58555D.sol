pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;


interface ERC20 {
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


interface BasePool {
    function token() external view returns (address);
}



contract PoolTogetherTokenAdapter is TokenAdapter {

    address internal constant SAI_POOL = 0xb7896fce748396EcFC240F5a0d3Cc92ca42D7d84;

    
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        return TokenMetadata({
            token: token,
            name: getPoolName(token),
            symbol: "PLT",
            decimals: ERC20(BasePool(token).token()).decimals()
        });
    }

    
    function getComponents(address token) external view override returns (Component[] memory) {
        Component[] memory underlyingTokens = new Component[](1);

        underlyingTokens[0] = Component({
            token: BasePool(token).token(),
            tokenType: "ERC20",
            rate: 1e18
        });

        return underlyingTokens;
    }

    function getPoolName(address token) internal view returns (string memory) {
        if (token == SAI_POOL) {
            return "SAI pool";
        } else {
            address underlying = BasePool(token).token();
            return string(abi.encodePacked(ERC20(underlying).symbol(), " pool"));
        }
    }
}