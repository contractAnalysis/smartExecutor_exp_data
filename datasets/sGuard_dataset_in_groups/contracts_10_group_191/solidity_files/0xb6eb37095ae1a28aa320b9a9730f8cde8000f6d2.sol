pragma solidity ^0.5.0;


contract Killable {
	address payable public _owner;

	
	constructor() internal {
		_owner = msg.sender;
	}

	
	function kill() public {
		require(msg.sender == _owner, "only owner method");
		selfdestruct(_owner);
	}
}



pragma solidity ^0.5.0;


contract Context {
	
	
	constructor() internal {}

	

	function _msgSender() internal view returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {
		this; 
		return msg.data;
	}
}



pragma solidity ^0.5.0;


contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);

	
	constructor() internal {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	
	function owner() public view returns (address) {
		return _owner;
	}

	
	modifier onlyOwner() {
		require(isOwner(), "Ownable: caller is not the owner");
		_;
	}

	
	function isOwner() public view returns (bool) {
		return _msgSender() == _owner;
	}

	
	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	
	function _transferOwnership(address newOwner) internal {
		require(
			newOwner != address(0),
			"Ownable: new owner is the zero address"
		);
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}



pragma solidity ^0.5.0;

contract IGroup {
	function isGroup(address _addr) public view returns (bool);

	function addGroup(address _addr) external;

	function getGroupKey(address _addr) internal pure returns (bytes32) {
		return keccak256(abi.encodePacked("_group", _addr));
	}
}



pragma solidity ^0.5.0;


contract AddressValidator {
	string constant errorMessage = "this is illegal address";

	
	function validateIllegalAddress(address _addr) external pure {
		require(_addr != address(0), errorMessage);
	}

	
	function validateGroup(address _addr, address _groupAddr) external view {
		require(IGroup(_groupAddr).isGroup(_addr), errorMessage);
	}

	
	function validateGroups(
		address _addr,
		address _groupAddr1,
		address _groupAddr2
	) external view {
		if (IGroup(_groupAddr1).isGroup(_addr)) {
			return;
		}
		require(IGroup(_groupAddr2).isGroup(_addr), errorMessage);
	}

	
	function validateAddress(address _addr, address _target) external pure {
		require(_addr == _target, errorMessage);
	}

	
	function validateAddresses(
		address _addr,
		address _target1,
		address _target2
	) external pure {
		if (_addr == _target1) {
			return;
		}
		require(_addr == _target2, errorMessage);
	}

	
	function validate3Addresses(
		address _addr,
		address _target1,
		address _target2,
		address _target3
	) external pure {
		if (_addr == _target1) {
			return;
		}
		if (_addr == _target2) {
			return;
		}
		require(_addr == _target3, errorMessage);
	}
}



pragma solidity ^0.5.0;




contract UsingValidator {
	AddressValidator private _validator;

	
	constructor() public {
		_validator = new AddressValidator();
	}

	
	function addressValidator() internal view returns (AddressValidator) {
		return _validator;
	}
}



pragma solidity ^0.5.0;


contract AddressConfig is Ownable, UsingValidator, Killable {
	address public token = 0x98626E2C9231f03504273d55f397409deFD4a093;
	address public allocator;
	address public allocatorStorage;
	address public withdraw;
	address public withdrawStorage;
	address public marketFactory;
	address public marketGroup;
	address public propertyFactory;
	address public propertyGroup;
	address public metricsGroup;
	address public metricsFactory;
	address public policy;
	address public policyFactory;
	address public policySet;
	address public policyGroup;
	address public lockup;
	address public lockupStorage;
	address public voteTimes;
	address public voteTimesStorage;
	address public voteCounter;
	address public voteCounterStorage;

	
	function setAllocator(address _addr) external onlyOwner {
		allocator = _addr;
	}

	
	function setAllocatorStorage(address _addr) external onlyOwner {
		allocatorStorage = _addr;
	}

	
	function setWithdraw(address _addr) external onlyOwner {
		withdraw = _addr;
	}

	
	function setWithdrawStorage(address _addr) external onlyOwner {
		withdrawStorage = _addr;
	}

	
	function setMarketFactory(address _addr) external onlyOwner {
		marketFactory = _addr;
	}

	
	function setMarketGroup(address _addr) external onlyOwner {
		marketGroup = _addr;
	}

	
	function setPropertyFactory(address _addr) external onlyOwner {
		propertyFactory = _addr;
	}

	
	function setPropertyGroup(address _addr) external onlyOwner {
		propertyGroup = _addr;
	}

	
	function setMetricsFactory(address _addr) external onlyOwner {
		metricsFactory = _addr;
	}

	
	function setMetricsGroup(address _addr) external onlyOwner {
		metricsGroup = _addr;
	}

	
	function setPolicyFactory(address _addr) external onlyOwner {
		policyFactory = _addr;
	}

	
	function setPolicyGroup(address _addr) external onlyOwner {
		policyGroup = _addr;
	}

	
	function setPolicySet(address _addr) external onlyOwner {
		policySet = _addr;
	}

	
	function setPolicy(address _addr) external {
		addressValidator().validateAddress(msg.sender, policyFactory);
		policy = _addr;
	}

	
	function setToken(address _addr) external onlyOwner {
		token = _addr;
	}

	
	function setLockup(address _addr) external onlyOwner {
		lockup = _addr;
	}

	
	function setLockupStorage(address _addr) external onlyOwner {
		lockupStorage = _addr;
	}

	
	function setVoteTimes(address _addr) external onlyOwner {
		voteTimes = _addr;
	}

	
	function setVoteTimesStorage(address _addr) external onlyOwner {
		voteTimesStorage = _addr;
	}

	
	function setVoteCounter(address _addr) external onlyOwner {
		voteCounter = _addr;
	}

	
	function setVoteCounterStorage(address _addr) external onlyOwner {
		voteCounterStorage = _addr;
	}
}



pragma solidity ^0.5.0;


contract UsingConfig {
	AddressConfig private _config;

	
	constructor(address _addressConfig) public {
		_config = AddressConfig(_addressConfig);
	}

	
	function config() internal view returns (AddressConfig) {
		return _config;
	}

	
	function configAddress() external view returns (address) {
		return address(_config);
	}
}



pragma solidity ^0.5.0;

contract IMetrics {
	address public market;
	address public property;
}



pragma solidity ^0.5.0;


contract Metrics is IMetrics {
	address public market;
	address public property;

	constructor(address _market, address _property) public {
		
		market = _market;
		property = _property;
	}
}



pragma solidity ^0.5.0;

contract IMetricsGroup is IGroup {
	function removeGroup(address _addr) external;

	function totalIssuedMetrics() external view returns (uint256);

	function getMetricsCountPerProperty(address _property)
		public
		view
		returns (uint256);

	function hasAssets(address _property) public view returns (bool);
}



pragma solidity ^0.5.0;

contract IMetricsFactory {
	function create(address _property) external returns (address);

	function destroy(address _metrics) external;
}



pragma solidity ^0.5.0;


contract MetricsFactory is UsingConfig, UsingValidator, IMetricsFactory {
	event Create(address indexed _from, address _metrics);
	event Destroy(address indexed _from, address _metrics);

	
	
	constructor(address _config) public UsingConfig(_config) {}

	
	function create(address _property) external returns (address) {
		
		addressValidator().validateGroup(msg.sender, config().marketGroup());

		
		Metrics metrics = new Metrics(msg.sender, _property);

		
		IMetricsGroup metricsGroup = IMetricsGroup(config().metricsGroup());
		address metricsAddress = address(metrics);
		metricsGroup.addGroup(metricsAddress);

		emit Create(msg.sender, metricsAddress);
		return metricsAddress;
	}

	
	function destroy(address _metrics) external {
		
		IMetricsGroup metricsGroup = IMetricsGroup(config().metricsGroup());
		require(metricsGroup.isGroup(_metrics), "address is not metrics");

		
		addressValidator().validateGroup(msg.sender, config().marketGroup());

		
		Metrics metrics = Metrics(_metrics);
		addressValidator().validateAddress(msg.sender, metrics.market());

		
		IMetricsGroup(config().metricsGroup()).removeGroup(_metrics);
		emit Destroy(msg.sender, _metrics);
	}
}