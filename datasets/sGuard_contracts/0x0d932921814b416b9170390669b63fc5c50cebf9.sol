pragma solidity ^0.5.17;


 
contract Burn {
    
    ERC20 constant VSN = ERC20(0x456AE45c0CE901E2e7c99c0718031cEc0A7A59Ff);
    
    uint256 public timer;

    event tokensBurnt(uint256 tokens);
    
    
    
    function setTimer() external {
        require(timer == 0);
        require(VSN.balanceOf(address(this)) > 0);
        timer = now + 24 hours;
    } 
    
    
    function burn() external {
        require(timer != 0  && now > timer);
        uint256 balance = VSN.balanceOf(address(this));
        VSN.transfer(address(0), balance);
        emit tokensBurnt(balance);
        timer = 0;
    } 
    
    
}


interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}