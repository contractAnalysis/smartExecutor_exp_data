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
    function debtBalanceOf(address, bytes32) external view returns (uint256);
}



contract SynthetixDebtAdapter is ProtocolAdapter {

    address internal constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;

    string public constant override adapterType = "Debt";

    string public constant override tokenType = "ERC20";

    
    function getBalance(address, address account) public view override returns (uint256) {
        Synthetix synthetix = Synthetix(Proxy(SNX).target());

        return synthetix.debtBalanceOf(account, "sUSD");
    }
}