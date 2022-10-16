pragma solidity 0.6.5;
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



interface BPool {
    function getFinalTokens() external view returns (address[] memory);
    function getBalance(address) external view returns (uint256);
    function getNormalizedWeight(address) external view returns (uint256);
}



contract BalancerTokenAdapter is TokenAdapter {


    
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        return TokenMetadata({
            token: token,
            name: getPoolName(token),
            symbol: ERC20(token).symbol(),
            decimals: ERC20(token).decimals()
        });
    }

    
    function getComponents(address token) external view override returns (Component[] memory) {
        address[] memory underlyingTokensAddresses;
        try BPool(token).getFinalTokens() returns (address[] memory result) {
            underlyingTokensAddresses = result;
        } catch {
            underlyingTokensAddresses = new address[](0);
        }

        uint256 totalSupply = ERC20(token).totalSupply();

        Component[] memory underlyingTokens = new Component[](underlyingTokensAddresses.length);

        for (uint256 i = 0; i < underlyingTokens.length; i++) {
            address underlyingToken = underlyingTokensAddresses[i];
            underlyingTokens[i] = Component({
                token: underlyingToken,
                tokenType: "ERC20",
                rate: BPool(token).getBalance(underlyingToken) * 1e18 / totalSupply
            });
        }

        return underlyingTokens;
    }

    function getPoolName(address token) internal view returns (string memory) {
        address[] memory underlyingTokensAddresses;
        try BPool(token).getFinalTokens() returns (address[] memory result) {
            underlyingTokensAddresses = result;
        } catch {
            return "Unknown pool";
        }

        string memory poolName = "";
        uint256 lastIndex = underlyingTokensAddresses.length - 1;
        for (uint256 i = 0; i < underlyingTokensAddresses.length; i++) {
            poolName = string(abi.encodePacked(
                poolName,
                getPoolElement(token, underlyingTokensAddresses[i]),
                i == lastIndex ? " pool" : " + "
            ));
        }
        return poolName;
    }

    function getPoolElement(address pool, address token) internal view returns (string memory) {
        return string(abi.encodePacked(
            convertToString(BPool(pool).getNormalizedWeight(token) / 1e16),
            "% ",
            getSymbol(token)
        ));
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
            if (data[i] != bytes1(0)) {
                length++;
            }
        }

        result = new bytes(length);

        for (uint256 i = 0; i < length; i++) {
            result[i] = data[i];
        }

        return string(result);
    }

    
    function convertToString(uint256 data) internal pure returns (string memory) {
        uint256 length = 0;

        uint256 dataCopy = data;
        while (dataCopy != 0){
            length++;
            dataCopy /= 10;
        }

        bytes memory result = new bytes(length);
        dataCopy = data;
        for (uint256 i = length - 1; i < length; i--) {
            result[i] = bytes1(uint8(48 + dataCopy % 10));
            dataCopy /= 10;
        }

        return string(result);
    }
}