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



interface CurveRewards {
    function earned(address) external view returns (uint256);
}



interface iETHRewards {
    function earned(address) external view returns (uint256);
}



interface Unipool {
    function earned(address) external view returns (uint256);
}



interface Synthetix {
    function collateral(address) external view returns (uint256);
}



contract SynthetixAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address internal constant SUSD_POOL_TOKEN = 0xC25a3A3b969415c80451098fa907EC722572917F;
    address internal constant IETH = 0xA9859874e1743A32409f75bB11549892138BBA1E;
    address internal constant UNISWAP_SETH = 0xe9Cf7887b93150D4F2Da7dFc6D502B216438F244;
    address internal constant LP_REWARD_CURVE = 0xDCB6A51eA3CA5d3Fd898Fd6564757c7aAeC3ca92;
    address internal constant LP_REWARD_IETH = 0xC746bc860781DC90BBFCD381d6A058Dc16357F8d;
    address internal constant LP_REWARD_UNISWAP = 0x48D7f315feDcaD332F68aafa017c7C158BC54760;

    
    function getBalance(address token, address account) external view override returns (uint256) {
        if (token == SNX) {
            uint256 balance = Synthetix(SNX).collateral(account);
            balance = balance + CurveRewards(LP_REWARD_CURVE).earned(account);
            balance = balance + iETHRewards(LP_REWARD_IETH).earned(account);
            balance = balance + Unipool(LP_REWARD_UNISWAP).earned(account);
            return balance;
        } else if (token == SUSD_POOL_TOKEN) {
            return ERC20(LP_REWARD_CURVE).balanceOf(account);
        } else if (token == IETH) {
            return ERC20(LP_REWARD_IETH).balanceOf(account);
        } else if (token == UNISWAP_SETH) {
            return ERC20(LP_REWARD_UNISWAP).balanceOf(account);
        } else {
            return 0;
        }
    }
}