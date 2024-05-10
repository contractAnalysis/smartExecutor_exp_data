pragma solidity ^0.6.12;

library SafeMath {

    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint a, uint b) internal pure returns (uint) {
        return a >= b ? a : b;
    }

    function min256(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
}



interface GeneralERC20 {
	function transfer(address to, uint256 amount) external;
	function transferFrom(address from, address to, uint256 amount) external;
	function approve(address spender, uint256 amount) external;
	function balanceOf(address spender) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);
}

library SafeERC20 {
	function checkSuccess()
		private
		pure
		returns (bool)
	{
		uint256 returnValue = 0;

		assembly {
			
			switch returndatasize()

			
			case 0x0 {
				returnValue := 1
			}

			
			case 0x20 {
				
				returndatacopy(0x0, 0x0, 0x20)

				
				returnValue := mload(0x0)
			}

			
			default { }
		}

		return returnValue != 0;
	}

	function transfer(address token, address to, uint256 amount) internal {
		GeneralERC20(token).transfer(to, amount);
		require(checkSuccess());
	}

	function transferFrom(address token, address from, address to, uint256 amount) internal {
		GeneralERC20(token).transferFrom(from, to, amount);
		require(checkSuccess());
	}

	function approve(address token, address spender, uint256 amount) internal {
		GeneralERC20(token).approve(spender, amount);
		require(checkSuccess());
	}
}


contract ADXSupplyController {
	enum GovernanceLevel { None, Mint, All }
	mapping (address => uint8) governance;
	constructor() public {
		governance[msg.sender] = uint8(GovernanceLevel.All);
	}

	function mint(ADXToken token, address owner, uint amount) external {
		require(governance[msg.sender] >= uint8(GovernanceLevel.Mint), 'NOT_GOVERNANCE');
		uint totalSupplyAfter = SafeMath.add(token.totalSupply(), amount);
		
		if (now < 1599696000) {
			
			require(totalSupplyAfter <= 50000000000000000000000000, 'EARLY_MINT_TOO_LARGE');
		} else {
			
			require(totalSupplyAfter <= 150000000000000000000000000, 'MINT_TOO_LARGE');
		}
		token.mint(owner, amount);
	}

	function changeSupplyController(ADXToken token, address newSupplyController) external {
		require(governance[msg.sender] >= uint8(GovernanceLevel.All), 'NOT_GOVERNANCE');
		token.changeSupplyController(newSupplyController);
	}

	function setGovernance(address addr, uint8 level) external {
		require(governance[msg.sender] >= uint8(GovernanceLevel.All), 'NOT_GOVERNANCE');
		governance[addr] = level;
	}
}

contract ADXToken {
	using SafeMath for uint;

	
	string public constant name = "AdEx Network";
	string public constant symbol = "ADX";
	uint8 public constant decimals = 18;

	
	uint public totalSupply;
	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;

	event Approval(address indexed owner, address indexed spender, uint amount);
	event Transfer(address indexed from, address indexed to, uint amount);

	address public supplyController;
	address public immutable PREV_TOKEN;

	constructor(address supplyControllerAddr, address prevTokenAddr) public {
		supplyController = supplyControllerAddr;
		PREV_TOKEN = prevTokenAddr;
	}

	function balanceOf(address owner) external view returns (uint balance) {
		return balances[owner];
	}

	function transfer(address to, uint amount) external returns (bool success) {
		balances[msg.sender] = balances[msg.sender].sub(amount);
		balances[to] = balances[to].add(amount);
		emit Transfer(msg.sender, to, amount);
		return true;
	}

	function transferFrom(address from, address to, uint amount) external returns (bool success) {
		balances[from] = balances[from].sub(amount);
		allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
		balances[to] = balances[to].add(amount);
		emit Transfer(from, to, amount);
		return true;
	}

	function approve(address spender, uint amount) external returns (bool success) {
		allowed[msg.sender][spender] = amount;
		emit Approval(msg.sender, spender, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint remaining) {
		return allowed[owner][spender];
	}

	
	function innerMint(address owner, uint amount) internal {
		totalSupply = totalSupply.add(amount);
		balances[owner] = balances[owner].add(amount);
		
		emit Transfer(address(0), owner, amount);
	}

	function mint(address owner, uint amount) external {
		require(msg.sender == supplyController, 'NOT_SUPPLYCONTROLLER');
		innerMint(owner, amount);
	}

	function changeSupplyController(address newSupplyController) external {
		require(msg.sender == supplyController, 'NOT_SUPPLYCONTROLLER');
		supplyController = newSupplyController;
	}

	
	
	uint constant PREV_TO_CURRENT_TOKEN_MULTIPLIER = 100000000000000;
	function swap(uint prevTokenAmount) external {
		innerMint(msg.sender, prevTokenAmount.mul(PREV_TO_CURRENT_TOKEN_MULTIPLIER));
		SafeERC20.transferFrom(PREV_TOKEN, msg.sender, address(0), prevTokenAmount);
	}
}