pragma solidity 0.5.4;



interface IGovernanceRegistry {
    
    
    function isSignee(address account) external view returns (bool);

    
    function isVault(address account) external view returns (bool) ;

}



interface IToken {

    function burn(uint256 amount) external ;

    function mint(address account, uint256 amount) external ;

}



library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    event ForceTransfer(address indexed from, address indexed to, uint256 value, bytes32 details);
}



contract Burner {

    using SafeMath for uint256;

    uint256 public index;

    
    event BurnFrom(address indexed account, address indexed vault, bytes32 indexed barId, uint256 value);

    
    IGovernanceRegistry public registry;

    
    IToken public token;

    
    constructor(IGovernanceRegistry governanceRegistry, IToken mintedToken) public {
        registry = governanceRegistry;
        token = mintedToken;
    }

    
    function burn(address account, bytes32 barId ,uint256 value) onlyVault external {
        IERC20(address(token)).transferFrom(account, address(this), value);
        token.burn(value);
        emit BurnFrom(account, msg.sender, barId, value);          
    }

    
    modifier onlyVault() {
        require(registry.isVault(msg.sender), "Caller is not a vault");
        _;
    }
}