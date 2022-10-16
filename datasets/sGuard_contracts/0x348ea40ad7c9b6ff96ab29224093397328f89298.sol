pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;


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


interface ERC20 {
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}



interface CToken {
    function isCToken() external view returns (bool);
}



interface Exchange {
    function name() external view returns (bytes32);
    function symbol() external view returns (bytes32);
    function decimals() external view returns (uint256);
}



interface Factory {
    function getToken(address) external view returns (address);
}



contract UniswapV1TokenAdapter is TokenAdapter {

    address internal constant FACTORY = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant SAI_POOL = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
    address internal constant CSAI_POOL = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;


    
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        return TokenMetadata({
            token: token,
            name: getPoolName(token),
            symbol: "UNI-V1",
            decimals: uint8(Exchange(token).decimals())
        });
    }

    
    function getComponents(address token) external view override returns (Component[] memory) {
        address underlyingToken = Factory(FACTORY).getToken(token);
        uint256 totalSupply = ERC20(token).totalSupply();
        string memory underlyingTokenType;
        Component[] memory underlyingTokens = new Component[](2);

        underlyingTokens[0] = Component({
            token: ETH,
            tokenType: "ERC20",
            rate: token.balance * 1e18 / totalSupply
        });

        try CToken(underlyingToken).isCToken() returns (bool) {
            underlyingTokenType = "CToken";
        } catch {
            underlyingTokenType = "ERC20";
        }

        underlyingTokens[1] = Component({
            token: underlyingToken,
            tokenType: underlyingTokenType,
            rate: ERC20(underlyingToken).balanceOf(token) * 1e18 / totalSupply
        });

        return underlyingTokens;
    }

    function getPoolName(address token) internal view returns (string memory) {
        if (token == SAI_POOL) {
            return "SAI pool";
        } else if (token == CSAI_POOL) {
            return "cSAI pool";
        } else {
            return string(abi.encodePacked(getSymbol(Factory(FACTORY).getToken(token)), " pool"));
        }
    }

    function getSymbol(address token) internal view returns (string memory) {
        (, bytes memory returnData) = token.staticcall(
            abi.encodeWithSelector(ERC20(token).symbol.selector)
        );

        if (returnData.length == 32) {
            return convertToString(abi.decode(returnData, (bytes32)));
        } else {
            return abi.decode(returnData, (string));
        }
    }

    
    function convertToString(bytes32 data) internal pure returns (string memory) {
        uint256 length = 0;
        bytes memory result;

        for (uint256 i = 0; i < 32; i++) {
            if (data[i] != byte(0)) {
                length++;
            }
        }

        result = new bytes(length);

        for (uint256 i = 0; i < length; i++) {
            result[i] = data[i];
        }

        return string(result);
    }
}