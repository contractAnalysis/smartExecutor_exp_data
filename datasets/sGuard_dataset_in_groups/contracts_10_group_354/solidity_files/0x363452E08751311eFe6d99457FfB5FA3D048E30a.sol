pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;


interface ERC20 {
    function balanceOf(address) external view returns (uint256);
}



abstract contract ProtocolAdapter {

    
    function adapterType() external pure virtual returns (string memory);

    
    function tokenType() external pure virtual returns (string memory);

    
    function getBalance(address token, address account) public view virtual returns (uint256);
}



contract IdleAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "IdleToken";

    
    function getBalance(address token, address account) public view override returns (uint256) {
        return ERC20(token).balanceOf(account);
    }
}