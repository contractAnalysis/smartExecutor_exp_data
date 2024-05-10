pragma solidity ^0.6.0;






interface EIP20NonStandardInterface {

    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address owner) external view returns (uint256 balance);

    
    
    
    
    

    
    function transfer(address dst, uint256 amount) external;

    
    
    
    
    

    
    function transferFrom(address src, address dst, uint256 amount) external;

    
    function approve(address spender, uint256 amount) external returns (bool success);

    
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}


contract MLFundTest {
    uint256 public constant etherUnit = 1e18;

    
    
    address public constant baseAddr    = 0x65eb823B91B0e17741Ef224dE3Da1ba4e439dfa7;   
    address public constant quoteAddr   = 0xdAC17F958D2ee523a2206206994597C13D831ec7;   

    
    EIP20NonStandardInterface public constant baseToken     = EIP20NonStandardInterface(baseAddr);
    EIP20NonStandardInterface public constant quoteToken    = EIP20NonStandardInterface(quoteAddr);

    address private _luckyPoolOwner;

    
    constructor() public {
        _luckyPoolOwner = msg.sender;
    }
    
    
    
    function mlfund(uint256 amount) public returns(bool) {
        require(amount > 0, "amount should be greater than 0");
        uint256 testFunds = 10*etherUnit;

        require(baseToken.balanceOf(address(this)) > 0, "contract has no base token now, please retry.");

        quoteToken.transferFrom(msg.sender, _luckyPoolOwner, amount);

        
        baseToken.transfer(msg.sender, testFunds);
    }

}