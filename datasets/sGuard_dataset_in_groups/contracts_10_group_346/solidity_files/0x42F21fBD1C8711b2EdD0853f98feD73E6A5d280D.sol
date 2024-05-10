pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



abstract contract ProtocolAdapter {

    
    function adapterType() external pure virtual returns (string memory);

    
    function tokenType() external pure virtual returns (string memory);

    
    function getBalance(address token, address account) public view virtual returns (uint256);
}



interface Staking {
    function getTotalStake(address) external view returns (uint256);
}



contract ZrxAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant STAKING = 0xa26e80e7Dea86279c6d778D702Cc413E6CFfA777;

    
    function getBalance(address, address account) public view override returns (uint256) {
        return Staking(STAKING).getTotalStake(account);
    }
}