pragma solidity 0.5.8;


interface Erc1820Registry {
	function setInterfaceImplementer(address _target, bytes32 _interfaceHash, address _implementer) external;
}


contract Erc777TokensRecipient {
	constructor() public {
		
		Erc1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24).setInterfaceImplementer(address(this), 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b, address(this));
	}

	
	function tokensReceived(address, address, address, uint256, bytes calldata, bytes calldata) external { }

	
	
	
	
	function canImplementInterfaceForAddress(bytes32 _interfaceHash, address _implementer) external view returns(bytes32) {
		
		if (_implementer == address(this) && _interfaceHash == 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b) {
			
			return 0xa2ef4600d742022d532d4747cb3547474667d6f13804902513b2ec01c848f4b4;
		} else {
			return bytes32(0);
		}
	}
}


contract Ownable {
	event OwnershipTransferStarted(address indexed owner, address indexed pendingOwner);
	event OwnershipTransferCancelled(address indexed owner, address indexed pendingOwner);
	event OwnershipTransferFinished(address indexed oldOwner, address indexed newOwner);

	address public owner;
	address public pendingOwner;

	constructor(address _owner) public {
		require(_owner != address(0), "Contract must have an owner.");
		owner = _owner;
	}

	
	modifier onlyOwner() {
		require(msg.sender == owner, "Only the owner may call this method.");
		_;
	}

	
	
	function startOwnershipTransfer(address _pendingOwner) external onlyOwner {
		require(_pendingOwner != address(0), "Contract must have an owner.");
		
		if (pendingOwner != address(0)) {
			cancelOwnershipTransfer();
		}
		pendingOwner = _pendingOwner;
		emit OwnershipTransferStarted(owner, pendingOwner);
	}

	
	
	function cancelOwnershipTransfer() public onlyOwner {
		require(pendingOwner != address(0), "There is no pending transfer to be cancelled.");
		address _pendingOwner = pendingOwner;
		pendingOwner = address(0);
		emit OwnershipTransferCancelled(owner, _pendingOwner);
	}

	
	function acceptOwnership() external {
		require(msg.sender == pendingOwner, "Only the pending owner can call this method.");
		address _oldOwner = owner;
		owner = pendingOwner;
		pendingOwner = address(0);
		emit OwnershipTransferFinished(_oldOwner, owner);
	}
}


contract RecoverableWallet is Ownable, Erc777TokensRecipient {
	event RecoveryAddressAdded(address indexed newRecoverer, uint16 recoveryDelayInDays);
	event RecoveryAddressRemoved(address indexed oldRecoverer);
	event RecoveryStarted(address indexed newOwner);
	event RecoveryCancelled(address indexed oldRecoverer);
	event RecoveryFinished(address indexed newPendingOwner);

	
	
	mapping(address => uint16) public recoveryDelaysInDays;
	address public activeRecoveryAddress;
	uint256 public activeRecoveryEndTime = uint256(-1);

	
	modifier onlyDuringRecovery() {
		require(activeRecoveryAddress != address(0), "This method can only be called during a recovery.");
		_;
	}

	
	modifier onlyOutsideRecovery() {
		require(activeRecoveryAddress == address(0), "This method cannot be called during a recovery.");
		_;
	}

	constructor(address _initialOwner) Ownable(_initialOwner) public { }

	
	function () external payable { }

	
	
	
	function addRecoveryAddress(address _newRecoveryAddress, uint16 _recoveryDelayInDays) external onlyOwner onlyOutsideRecovery {
		require(_newRecoveryAddress != address(0), "Recovery address must be supplied.");
		require(_recoveryDelayInDays > 0, "Recovery delay must be at least 1 day.");
		recoveryDelaysInDays[_newRecoveryAddress] = _recoveryDelayInDays;
		emit RecoveryAddressAdded(_newRecoveryAddress, _recoveryDelayInDays);
	}

	
	
	function removeRecoveryAddress(address _oldRecoveryAddress) public onlyOwner onlyOutsideRecovery {
		require(_oldRecoveryAddress != address(0), "Recovery address must be supplied.");
		recoveryDelaysInDays[_oldRecoveryAddress] = 0;
		emit RecoveryAddressRemoved(_oldRecoveryAddress);
	}

	
	function startRecovery() external {
		uint16 _proposedRecoveryDelayInDays = recoveryDelaysInDays[msg.sender];
		require(_proposedRecoveryDelayInDays != 0, "Only designated recovery addresseses can initiate the recovery process.");

		bool _inRecovery = activeRecoveryAddress != address(0);
		if (_inRecovery) {
			
			uint16 _activeRecoveryDelayInDays = recoveryDelaysInDays[activeRecoveryAddress];
			require(_proposedRecoveryDelayInDays < _activeRecoveryDelayInDays, "Recovery is already under way and new recovery doesn't have a higher priority.");
			emit RecoveryCancelled(activeRecoveryAddress);
		}

		activeRecoveryAddress = msg.sender;
		activeRecoveryEndTime = block.timestamp + _proposedRecoveryDelayInDays * 1 days;
		emit RecoveryStarted(msg.sender);
	}

	
	
	function cancelRecovery() public onlyOwner onlyDuringRecovery {
		address _recoveryAddress = activeRecoveryAddress;
		resetRecovery();
		emit RecoveryCancelled(_recoveryAddress);
	}

	
	function cancelRecoveryAndRemoveRecoveryAddress() external onlyOwner onlyDuringRecovery {
		address _recoveryAddress = activeRecoveryAddress;
		cancelRecovery();
		removeRecoveryAddress(_recoveryAddress);
	}

	
	function finishRecovery() external onlyDuringRecovery {
		require(block.timestamp > activeRecoveryEndTime, "You must wait until the recovery delay is over before finishing the recovery.");

		address _oldOwner = owner;
		owner = activeRecoveryAddress;
		resetRecovery();
		emit RecoveryFinished(pendingOwner);
		emit OwnershipTransferStarted(_oldOwner, owner);
		emit OwnershipTransferFinished(_oldOwner, owner);
	}

	
	
	
	
	
	function deploy(uint256 _value, bytes calldata _data, uint256 _salt) external payable onlyOwner onlyOutsideRecovery returns (address) {
		require(address(this).balance >= _value, "Wallet does not have enough funds available to deploy the contract.");
		require(_data.length != 0, "Contract deployment must contain bytecode to deploy.");
		bytes memory _data2 = _data;
		address newContract;
		
		assembly { newContract := create2(_value, add(_data2, 32), mload(_data2), _salt) }
		require(newContract != address(0), "Contract creation returned address 0, indicating failure.");
		return newContract;
	}

	
	
	
	
	
	function execute(address payable _to, uint256 _value, bytes calldata _data) external payable onlyOwner onlyOutsideRecovery returns (bytes memory) {
		require(_to != address(0), "Transaction execution must contain a destination.  If you meant to deploy a contract, use deploy instead.");
		require(address(this).balance >= _value, "Wallet does not have enough funds available to execute the desired transaction.");
		(bool _success, bytes memory _result) = _to.call.value(_value)(_data);
		require(_success, "Contract execution failed.");
		return _result;
	}

	function resetRecovery() private {
		activeRecoveryAddress = address(0);
		activeRecoveryEndTime = uint256(-1);
	}
}


contract RecoverableWalletFactory {
	event WalletCreated(address indexed owner, RecoverableWallet indexed wallet);

	
	function createWallet() external returns (RecoverableWallet) {
		RecoverableWallet wallet = new RecoverableWallet(msg.sender);
		emit WalletCreated(msg.sender, wallet);
		return wallet;
	}

	
	function exists() external pure returns (bytes32) {
		return 0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef;
	}
}