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
    function debtBalanceOf(address, bytes32) external view returns (uint256);
}



contract SynthetixDebtAdapter is ProtocolAdapter {

    address internal constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;

    
    function adapterType() external pure override returns (string memory) {
        return "Debt";
    }

    
    function tokenType() external pure override returns (string memory) {
        return "ERC20";
    }

    
    function getBalance(address, address account) external view override returns (uint256) {
        Synthetix synthetix = Synthetix(Proxy(SNX).target());

        return synthetix.debtBalanceOf(account, "sUSD");
    }
}