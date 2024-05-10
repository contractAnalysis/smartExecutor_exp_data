pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



interface LendingPoolAddressesProvider {
    function getLendingPool() external view returns (LendingPool);
}



interface LendingPool {
    function getUserReserveData(address, address) external view returns (uint256, uint256);
}



contract AaveDebtAdapter is ProtocolAdapter {

    address internal constant PROVIDER = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;

    string public constant override adapterType = "Debt";

    string public constant override tokenType = "ERC20";

    
    function getBalance(address token, address account) external view override returns (uint256) {
        LendingPool pool = LendingPoolAddressesProvider(PROVIDER).getLendingPool();

        (, uint256 debtAmount) = pool.getUserReserveData(token, account);

        return debtAmount;
    }
}