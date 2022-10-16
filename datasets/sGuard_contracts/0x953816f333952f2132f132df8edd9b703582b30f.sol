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



contract PoolDrop {

    function transferManyFrom(address _token, address _from, address[] memory _tos, uint256 _value)
    public returns (bool) {
        require(_token != address(0));
        require(_from != address(0));
        require(_value > 0);
        IERC20 Token = IERC20(_token);
        for (uint i = 0; i < _tos.length; i++) {
            Token.transferFrom(_from, _tos[i], _value);
        }
        return true;
    }
}