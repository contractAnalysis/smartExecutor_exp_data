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



interface CToken {
    function exchangeRateStored() external view returns (uint256);
    function underlying() external view returns (address);
}



contract CompoundTokenAdapter is TokenAdapter {

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant CETH = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    address internal constant CSAI = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;

    
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        if (token == CSAI) {
            return TokenMetadata({
                token: CSAI,
                name: "Compound Sai",
                symbol: "cSAI",
                decimals: uint8(8)
            });
        } else {
            return TokenMetadata({
                token: token,
                name: ERC20(token).name(),
                symbol: ERC20(token).symbol(),
                decimals: ERC20(token).decimals()
            });
        }
    }

    
    function getComponents(address token) external view override returns (Component[] memory) {
        Component[] memory underlyingTokens = new Component[](1);

        underlyingTokens[0] = Component({
            token: getUnderlying(token),
            tokenType: "ERC20",
            rate: CToken(token).exchangeRateStored()
        });

        return underlyingTokens;
    }

    
    function getUnderlying(address token) internal view returns (address) {
        return token == CETH ? ETH : CToken(token).underlying();
    }
}