pragma solidity ^0.5.11;


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address target) external view returns (uint256);

    function allowance(address target, address spender)
        external
        view
        returns (uint256);
}



pragma solidity ^0.5.11;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.5.11;




contract WithCoffeeToken is IERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) allowances;

    string public constant name = "With ☕️";
    string public constant symbol = "With ☕️";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 165e18;

    constructor() public {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(
            value,
            "With ☕️/Not-Enough-Balance"
        );
        balances[to] = balances[to].add(value);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool)
    {
        allowances[from][msg.sender] = allowances[from][msg.sender].sub(
            value,
            "With ☕️/Not-Enough-Allowance"
        );
        balances[from] = balances[from].sub(
            value,
            "With ☕️/Not-Enough-Balance"
        );
        balances[to] = balances[to].add(value);

        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowances[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    function balanceOf(address target) external view returns (uint256) {
        return balances[target];
    }

    function allowance(address target, address spender)
        external
        view
        returns (uint256)
    {
        return allowances[target][spender];
    }
}