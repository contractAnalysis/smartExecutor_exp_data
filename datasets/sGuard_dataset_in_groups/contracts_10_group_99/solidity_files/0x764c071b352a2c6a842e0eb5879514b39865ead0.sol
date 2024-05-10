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
 

contract TimeLock {
    address public owner; 
    uint256 currentDate;
    uint256 public nextDate; 
    address public receiver = 0x24dd6DE5dAF992eAf99Df9514efd0c63Bfc66CC9; 
    constructor() public {
        currentDate = now; 
        nextDate = now + 90 days; 
        owner = msg.sender; 
    }
    
    
    function withDraw(IERC20 token) public{
        require(msg.sender == owner, "Only owner can call withdraw"); 
        if (now >= nextDate){ 
            uint256 balance = token.balanceOf(address(this)); 
            token.transfer(receiver,balance); 
        } else {
            revert(); 
        }
    }
}