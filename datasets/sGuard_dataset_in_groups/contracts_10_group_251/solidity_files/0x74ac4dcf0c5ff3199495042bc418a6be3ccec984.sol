pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



interface iETHRewards {
    function earned(address) external view returns (uint256);
}



contract LPiETHSNXAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant LP_REWARD_IETH = 0xC746bc860781DC90BBFCD381d6A058Dc16357F8d;

    
    function getBalance(address, address account) external view override returns (uint256) {
        return iETHRewards(LP_REWARD_IETH).earned(account);
    }
}