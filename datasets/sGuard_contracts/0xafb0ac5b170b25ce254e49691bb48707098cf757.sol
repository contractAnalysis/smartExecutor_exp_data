pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}


interface ERC20 {
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}



interface Staking {
    function getTotalStake(address) external view returns (uint256);
}



contract ZrxAdapter is ProtocolAdapter {

    address internal constant STAKING = 0xa26e80e7Dea86279c6d778D702Cc413E6CFfA777;

    
    function adapterType() external pure override returns (string memory) {
        return "Asset";
    }

    
    function tokenType() external pure override returns (string memory) {
        return "ERC20";
    }

    
    function getBalance(address, address account) external view override returns (uint256) {
        return Staking(STAKING).getTotalStake(account);
    }
}