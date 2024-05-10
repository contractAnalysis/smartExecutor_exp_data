pragma solidity ^0.5.0;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.5.0;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;



contract PaymentHandler {

	
	PaymentMaster public master;

	
	constructor(PaymentMaster _master) public {
		master = _master;
	}

	
	function getMasterAddress() public view returns (address) {
		return address(master);
	}

	
	function() external payable {
		
		address payable ownerAddress = address(uint160(master.owner()));

		
		ownerAddress.transfer(msg.value);

		
		master.firePaymentReceivedEvent(address(this), msg.sender, msg.value);
	}

	
	function sweepTokens(IERC20 token) public {
		
		address ownerAddress = master.owner();

		
		uint balance = token.balanceOf(address(this));

		
		token.transfer(ownerAddress, balance);
	}

}



pragma solidity ^0.5.0;





contract PaymentMaster is Ownable {

	
  address[] public handlerList;

	
	mapping(address => bool) public handlerMap;

	
	event HandlerCreated(address indexed _addr);
	event EthPaymentReceived(address indexed _to, address indexed _from, uint256 _amount);

	
	function deployNewHandler() public {
		
		PaymentHandler createdHandler = new PaymentHandler(this);

		
		handlerList.push(address(createdHandler));
		handlerMap[address(createdHandler)] = true;

		
		emit HandlerCreated(address(createdHandler));
	}

	
	function getHandlerList() public view returns (address[] memory) {
			
      return handlerList;
  }

	
	function getHandlerListLength() public view returns (uint) {
		return handlerList.length;
	}

	
	function firePaymentReceivedEvent(address to, address from, uint256 amount) public {
		
		require(handlerMap[msg.sender], "Only payment handlers are allowed to trigger payment events.");

		
		emit EthPaymentReceived(to, from, amount);
	}

	
	function multiHandlerSweep(address[] memory handlers, IERC20 tokenContract) public {
		for (uint i = 0; i < handlers.length; i++) {

			
			require(handlerMap[handlers[i]], "Only payment handlers are valid sweep targets.");

			
			PaymentHandler(address(uint160(handlers[i]))).sweepTokens(tokenContract);
		}
	}

	
	function sweepTokens(IERC20 token) public {
		
		uint balance = token.balanceOf(address(this));

		
		token.transfer(this.owner(), balance);
	}
}