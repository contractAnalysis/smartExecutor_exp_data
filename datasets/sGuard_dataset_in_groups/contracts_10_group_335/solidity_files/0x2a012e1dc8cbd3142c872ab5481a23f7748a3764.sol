pragma solidity ^0.6.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.6.0;


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.6.0;


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



pragma solidity >=0.4.21 <0.7.0;




contract Vesting is Ownable {
	using SafeMath for uint256;

	uint256 public unitPerBlock;
	address public token;
	mapping(address => uint256) private amounts;
	mapping(address => uint256) private pendings;
	mapping(address => uint256) private beginningBlocks;
	mapping(address => uint256) private lastValues;

	constructor(address _token, uint256 _unitPerBlock) public {
		token = _token;
		unitPerBlock = _unitPerBlock;
	}

	function tap() public {
		(uint256 withdrawable, uint256 cumulative, ) = getAmounts(msg.sender);
		require(
			IERC20(token).transfer(msg.sender, withdrawable),
			"fail to transfer"
		);
		lastValues[msg.sender] = cumulative;
	}

	function getAmounts(address _user)
		public
		view
		returns (
			uint256 _withdrawable,
			uint256 _cumulative,
			uint256 _total
		)
	{
		uint256 total = amounts[_user];
		uint256 blocks = block.number.sub(beginningBlocks[_user]);
		uint256 max = blocks.mul(unitPerBlock);
		uint256 maxReward = (total > max ? max : total).add(pendings[_user]);
		uint256 withdrawable = maxReward.sub(lastValues[_user]);
		return (withdrawable, maxReward, total);
	}

	function _setAmounts(address _user, uint256 _value) public onlyOwner {
		(uint256 withdrawable, , ) = getAmounts(_user);
		pendings[_user] = withdrawable;
		beginningBlocks[_user] = block.number;
		amounts[_user] = _value;
	}

	function _setUnitPerBlock(uint256 _value) public onlyOwner {
		unitPerBlock = _value;
	}

	function _close() public onlyOwner {
		IERC20 _token = IERC20(token);
		require(
			_token.transfer(owner(), _token.balanceOf(address(this))),
			"fail to transfer"
		);
	}
}