pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



interface Unipool {
    function earned(address) external view returns (uint256);
}



contract LPUniswapSNXAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant LP_REWARD_UNISWAP = 0x48D7f315feDcaD332F68aafa017c7C158BC54760;

    
    function getBalance(address, address account) external view override returns (uint256) {
        return Unipool(LP_REWARD_UNISWAP).earned(account);
    }
}