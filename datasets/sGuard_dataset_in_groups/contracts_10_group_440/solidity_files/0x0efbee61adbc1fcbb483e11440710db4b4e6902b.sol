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

contract TokenMultiSearch {
    function GetMultiBalance(address erc20, address[] searches) public constant returns (uint256[] balances)  
    {
        uint256 n = searches.length;
        balances = new uint256[](n);
        
        ERC20Interface token = ERC20Interface(erc20);
        
        for (uint256 i = 0; i < n ; i++)
        {
            balances[i] = token.balanceOf(searches[i]);
        }
    }
}