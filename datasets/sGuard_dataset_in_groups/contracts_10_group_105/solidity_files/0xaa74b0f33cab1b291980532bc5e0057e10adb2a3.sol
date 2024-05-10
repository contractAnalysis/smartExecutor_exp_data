pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;


interface ERC20 {
    function balanceOf(address) external view returns (uint256);
}



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



contract CompoundAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "CToken";

    
    function getBalance(address token, address account) external view override returns (uint256) {
        return ERC20(token).balanceOf(account);
    }
}