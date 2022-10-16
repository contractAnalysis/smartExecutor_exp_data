pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;


interface ERC20 {
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




interface stableswap {
    function coins(int128) external view returns (address);
    function balances(int128) external view returns (uint256);
}



contract CurveTokenAdapter is TokenAdapter {

    address internal constant COMPOUND_POOL_TOKEN = 0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2;
    address internal constant Y_POOL_TOKEN = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    address internal constant BUSD_POOL_TOKEN = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;

    
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        return TokenMetadata({
            token: token,
            name: string(abi.encodePacked(ERC20(token).symbol(), " pool")),
            symbol: ERC20(token).symbol(),
            decimals: ERC20(token).decimals()
        });
    }

    
    function getComponents(address token) external view override returns (Component[] memory) {
        (stableswap ss, uint256 length, string memory tokenType) = getPoolInfo(token);
        Component[] memory underlyingTokens = new Component[](length);

        for (uint256 i = 0; i < length; i++) {
            underlyingTokens[i] = Component({
                token: ss.coins(int128(i)),
                tokenType: tokenType,
                rate: ss.balances(int128(i)) * 1e18 / ERC20(token).totalSupply()
            });
        }

        return underlyingTokens;
    }

    
    function getPoolInfo(address token) internal pure returns (stableswap, uint256, string memory) {
        if (token == COMPOUND_POOL_TOKEN) {
            return (stableswap(0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56), 2, "CToken");
        } else if (token == Y_POOL_TOKEN) {
            return (stableswap(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51), 4, "YToken");
        } else if (token == BUSD_POOL_TOKEN) {
            return (stableswap(0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27), 4, "YToken");
        } else {
            return (stableswap(address(0)), 0, "");
        }
    }
}