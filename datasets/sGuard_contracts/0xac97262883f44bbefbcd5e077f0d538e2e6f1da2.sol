pragma solidity ^0.6.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity >=0.6.0;



contract P2pSwap {
    struct Swap {
        address aliceAddress;
        address token1;
        uint256 value1;
        address token2;
        uint256 value2;
        uint8 executed; 
    }

    mapping(uint256 => Swap) swaps;

    function getSwap(uint256 _id)
    public view returns (address, address, uint256, address, uint256, uint8) {
        Swap memory swap = swaps[_id];
        return (
            swap.aliceAddress,
            swap.token1,
            swap.value1,
            swap.token2,
            swap.value2,
            swap.executed
        );
    }

    function registerSwap(
        uint256 _id,
        address _aliceAddress,
        address _token1,
        uint256 _value1,
        address _token2,
        uint256 _value2)
    public returns (bool) {
        require(_id != 0);
        require(_aliceAddress != address(0));
        require(_token1 != address(0));
        require(_value1 != 0);
        require(_token2 != address(0));
        require(_value2 != 0);
        Swap storage swap = swaps[_id];
        require(swap.aliceAddress == address(0), "Swap already exists");
        swap.aliceAddress = _aliceAddress;
        swap.token1 = _token1;
        swap.value1 = _value1;
        swap.token2 = _token2;
        swap.value2 = _value2;
        return true;
    }

    function cancelSwap(uint256 _id) public returns (bool) {
        Swap storage swap = swaps[_id];
        require(swap.executed == 0, "Swap not available");
        swap.executed = 2;
    }

    function executeSwap(uint256 _id, address _bob)
    public returns (bool) {
        require(_bob != address(0));
        Swap storage swap = swaps[_id];
        require(swap.aliceAddress != address(0), "Swap does not exists");
        require(swap.executed == 0, "Swap not available");
        IERC20 Token1 = IERC20(swap.token1);
        IERC20 Token2 = IERC20(swap.token2);
        
        bool p1 = Token1.transferFrom(swap.aliceAddress, _bob, swap.value1);
        require(p1, "Failed to transfer side1");
        bool p2 = Token2.transferFrom(_bob, swap.aliceAddress, swap.value2);
        require(p2, "Failed to transfer side2");
        swap.executed = 1;
        return true;
    }
}