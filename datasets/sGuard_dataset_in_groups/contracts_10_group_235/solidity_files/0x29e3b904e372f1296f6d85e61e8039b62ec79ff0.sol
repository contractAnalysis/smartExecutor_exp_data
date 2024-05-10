pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



interface CurveRewards {
    function earned(address) external view returns (uint256);
}



contract LPCurveSNXAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant LP_REWARD_CURVE = 0xDCB6A51eA3CA5d3Fd898Fd6564757c7aAeC3ca92;

    
    function getBalance(address, address account) external view override returns (uint256) {
        return CurveRewards(LP_REWARD_CURVE).earned(account);
    }
}