pragma solidity 0.5.14;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
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
}

contract SwapToken { 
    using SafeMath for uint256;
    
    uint256 public swapsRegistered; 
    mapping (uint256 => Swap) public swaps; 
    
    event Registered(address indexed partyA, uint256 indexed swapNumber);
    event Executed(address indexed partyB, uint256 indexed swapNumber);
    
    struct Swap {
        address partyA;
        uint256 partyAswap;
    	IERC20 partyAtkn;
    	address partyB;
    	uint256 partyBswap;
    	IERC20 partyBtkn;
        uint256 swapNumber;
    	uint256 swapTermination;
        string details;
        bool executed;
    }
    
    function registerSwap( 
    	uint256 partyAswap,
    	IERC20 partyAtkn,
    	address partyB,
    	uint256 partyBswap,
    	IERC20 partyBtkn,
    	uint256 duration,
        string memory details) public {
        uint256 swapNumber = swapsRegistered.add(1); 
        uint256 swapTermination = now.add(duration); 
        swapsRegistered = swapsRegistered.add(1); 
        
        swaps[swapNumber] = Swap( 
            msg.sender,
            partyAswap,
            partyAtkn,
            partyB,
            partyBswap,
            partyBtkn,
            swapNumber,
            swapTermination,
            details,
            false);
        
        emit Registered(msg.sender, swapNumber); 
    }
    
    function executeSwap(uint256 swapNumber) public { 
        Swap storage swap = swaps[swapNumber]; 
        require(msg.sender == swap.partyB);
        require(swap.executed == false); 
        require(now <= swap.swapTermination); 
        
        swap.partyAtkn.transferFrom(swap.partyA, swap.partyB, swap.partyAswap);
        swap.partyBtkn.transferFrom(swap.partyB, swap.partyA, swap.partyBswap);
        
        swap.executed = true;
        emit Executed(msg.sender, swapNumber); 
    }
}