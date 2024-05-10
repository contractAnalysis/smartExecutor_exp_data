pragma solidity ^0.4.18;

contract ERC20Interface {
    
    function totalSupply() public constant returns (uint256 supply);

    
    function balanceOf(address _owner) public constant returns (uint256 balance);

    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
   
contract TokenMultiTransfer {
    
    address public owner;
    
    function TokenMultiTransfer() public
    {
        owner = msg.sender;
    }
    
    function MultiTransferFrom(address erc20, address[] addresses, uint256[] amounts) public  
    {
        require (owner == msg.sender);
        
        uint256 n = addresses.length;
        
        ERC20Interface token = ERC20Interface(erc20);
        
        for (uint256 i = 0; i < n ; i++)
        {
            token.transferFrom(msg.sender, addresses[i], amounts[i]);
        }
    }
}