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



interface Factory {
    function getToken(address) external view returns (address);
}



contract UniswapV1Adapter is ProtocolAdapter {

    
    function adapterType() external pure override returns (string memory) {
        return "Asset";
    }

    
    function tokenType() external pure override returns (string memory) {
        return "Uniswap V1 pool token";
    }

    
    function getBalance(address token, address account) external view override returns (uint256) {
        return ERC20(token).balanceOf(account);
    }
}