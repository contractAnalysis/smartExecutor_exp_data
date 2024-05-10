pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



abstract contract ProtocolAdapter {

    
    function adapterType() external pure virtual returns (string memory);

    
    function tokenType() external pure virtual returns (string memory);

    
    function getBalance(address token, address account) public view virtual returns (uint256);
}



interface BasePool {
    function totalBalanceOf(address) external view returns (uint256);
}



contract PoolTogetherAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "PoolTogether pool";

    
    function getBalance(address token, address account) public view override returns (uint256) {
        return BasePool(token).totalBalanceOf(account);
    }
}