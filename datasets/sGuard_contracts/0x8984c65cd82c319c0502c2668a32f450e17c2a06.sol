pragma solidity 0.6.4;
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
    function balanceOf(address) external view returns (uint256);
    function transferableSynthetix(address) external view returns (uint256);
}



contract SynthetixAssetAdapter is ProtocolAdapter {

    
    function adapterType() external pure override returns (string memory) {
        return "Asset";
    }

    
    function tokenType() external pure override returns (string memory) {
        return "ERC20";
    }

    
    function getBalance(address token, address account) external view override returns (uint256) {
        Synthetix synthetix = Synthetix(Proxy(token).target());

        return synthetix.balanceOf(account) - synthetix.transferableSynthetix(account);
    }
}