pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



abstract contract ProtocolAdapter {

    
    function adapterType() external pure virtual returns (string memory);

    
    function tokenType() external pure virtual returns (string memory);

    
    function getBalance(address token, address account) public view virtual returns (uint256);
}



interface Proxy {
    function target() external view returns (address);
}



interface Synthetix {
    function balanceOf(address) external view returns (uint256);
    function transferableSynthetix(address) external view returns (uint256);
}



contract SynthetixAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    
    function getBalance(address token, address account) public view override returns (uint256) {
        Synthetix synthetix = Synthetix(Proxy(token).target());

        return synthetix.balanceOf(account) - synthetix.transferableSynthetix(account);
    }
}