pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



interface CToken {
    function borrowBalanceStored(address) external view returns (uint256);
}



interface CompoundRegistry {
    function getCToken(address) external view returns (address);
}



contract CompoundDebtAdapter is ProtocolAdapter {

    address internal constant REGISTRY = 0xE6881a7d699d3A350Ce5bba0dbD59a9C36778Cb7;

    string public constant override adapterType = "Debt";

    string public constant override tokenType = "ERC20";

    
    function getBalance(address token, address account) external view override returns (uint256) {
        CToken cToken = CToken(CompoundRegistry(REGISTRY).getCToken(token));

        return cToken.borrowBalanceStored(account);
    }
}