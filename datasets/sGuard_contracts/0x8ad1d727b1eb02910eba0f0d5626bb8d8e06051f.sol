pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



interface BasePool {
    function totalBalanceOf(address) external view returns (uint256);
}



contract PoolTogetherAdapter is ProtocolAdapter {

    
    function adapterType() external pure override returns (string memory) {
        return "Asset";
    }

    
    function tokenType() external pure override returns (string memory) {
        return "PoolTogether pool";
    }

    
    function getBalance(address token, address account) external view override returns (uint256) {
        return BasePool(token).totalBalanceOf(account);
    }
}