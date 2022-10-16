pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



interface Proxy {
    function target() external view returns (address);
}



interface Synthetix {
    function collateral(address) external view returns (uint256);
}



contract SynthetixAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    
    function getBalance(address token, address account) external view override returns (uint256) {
        Synthetix synthetix = Synthetix(Proxy(token).target());

        return synthetix.collateral(account);
    }
}