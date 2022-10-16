pragma solidity ^0.4.18;



library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}





contract Ownable {

    address public owner;

    
    function Ownable() public {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        owner = newOwner;
    }
}




contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}





contract ERC20Bridge is Ownable {

	using SafeMath for uint;

    uint public minFee =  1 * 10**18; 
    uint public maxFee = 20 * 10**18; 

    uint public minValue = 10 * 10**18; 
    uint public maxValue = 10000 * 10**18; 

    uint public validatorsCount = 0;
    uint public validationsRequired = 2;

    ERC20 private erc20Instance;  

    struct Transaction {
		address initiator;
		uint amount;
		uint fee;
		uint validated;
		bool completed;
	}

    event FundsReceived(address indexed initiator, uint amount);

    event ValidatorAdded(address indexed validator);
    event ValidatorRemoved(address indexed validator);

    event Validated(bytes32 indexed txHash, address indexed validator, uint validatedCount, bool completed, uint fee);

    mapping (address => bool) public isValidator;

    mapping (bytes32 => Transaction) public transactions;
	mapping (bytes32 => mapping (address => bool)) public validatedBy; 

	function ERC20Bridge(address _addr) public {
		erc20Instance = ERC20(_addr);
    }

    
	function() external payable {
		revert();
	}

	function setMinValue( uint _value ) onlyOwner public {
        require (_value > 0);
        minValue = _value;
	}

	function setMaxValue( uint _value ) onlyOwner public {
        require (_value > 0);
        maxValue = _value;
	}

	function setMinFee( uint _value ) onlyOwner public {
        require (_value > 0);
        minFee = _value;
	}

	function setMaxFee( uint _value ) onlyOwner public {
        require (_value > 0);
        maxFee = _value;
	}

	function setValidationsRequired( uint value ) onlyOwner public {
        require (value > 0);
        validationsRequired = value;
	}

	function addValidator( address _validator ) onlyOwner public {
        require (!isValidator[_validator]);
        isValidator[_validator] = true;
        validatorsCount = validatorsCount.add(1);
        ValidatorAdded(_validator);
	}

	function removeValidator( address _validator ) onlyOwner public {
        require (isValidator[_validator]);
        isValidator[_validator] = false;
        validatorsCount = validatorsCount.sub(1);
        ValidatorRemoved(_validator);
	}

	function validate(bytes32 _txHash, address _initiator, uint _amount, uint _fee) public {
        
        require ( isValidator[msg.sender]);
        require ( !transactions[_txHash].completed );
        require ( !validatedBy[_txHash][msg.sender] );
        require ( _amount>=minValue && _amount<=maxValue ); 
        require ( _fee>=minFee && _fee<=maxFee ); 

        if ( transactions[_txHash].initiator == address(0) ) {
            require ( _amount > 0 && erc20Instance.balanceOf(address(this)) >= _amount );
            transactions[_txHash].initiator = _initiator;
            transactions[_txHash].amount = _amount;
            transactions[_txHash].fee = _fee;
            transactions[_txHash].validated = 1;

        } else {
            require ( transactions[_txHash].amount > 0 );
            require ( erc20Instance.balanceOf(address(this)) >= transactions[_txHash].amount );
            require ( _initiator == transactions[_txHash].initiator );
            
            transactions[_txHash].validated = transactions[_txHash].validated.add(1);
            transactions[_txHash].fee = transactions[_txHash].fee.add(_fee);
        }
        validatedBy[_txHash][msg.sender] = true;
        erc20Instance.transfer(msg.sender, _fee);
        if (transactions[_txHash].validated >= validationsRequired) {
            erc20Instance.transfer(_initiator, transactions[_txHash].amount.sub(transactions[_txHash].fee));
            transactions[_txHash].completed = true;
        }
        Validated(_txHash, msg.sender, transactions[_txHash].validated, transactions[_txHash].completed, _fee);
	}
}