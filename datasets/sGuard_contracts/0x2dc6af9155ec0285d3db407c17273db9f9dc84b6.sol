pragma solidity 0.5.8;

interface ERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address who) external view returns (uint256);
	function transfer(address to, uint256 value) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function transferFrom(address from, address to, uint256 value) external returns (bool);
	function approve(address spender, uint256 value) external returns (bool);
}

contract ERC20HTLCLite {
	struct Swap {
		uint256 outAmount; 
		uint256 expireHeight; 
		bytes32 randomNumberHash;
		uint64 timestamp;
		address senderAddr; 
		uint256 senderChainType;
		uint256 receiverChainType;
		address recipientAddr; 
		string receiverAddr; 
	}

	enum States {INVALID, OPEN, COMPLETED, EXPIRED}

	enum ChainTypes {ETH, PRA}

	
	event HTLC(
		address indexed _msgSender,
		address indexed _recipientAddr,
		bytes32 indexed _swapID,
		bytes32 _randomNumberHash,
		uint64 _timestamp,
		uint256 _expireHeight,
		uint256 _outAmount,
		uint256 _praAmount,
		string _receiverAddr
	);
	event Claimed(
		address indexed _msgSender,
		address indexed _recipientAddr,
		bytes32 indexed _swapID,
		bytes32 _randomNumber,
		string _receiverAddr
	);
	event Refunded(
		address indexed _msgSender,
		address indexed _recipientAddr,
		bytes32 indexed _swapID,
		bytes32 _randomNumberHash,
		string _receiverAddr
	);

	
	mapping(bytes32 => Swap) private swaps;
	mapping(bytes32 => States) private swapStates;

	address public praContractAddr;
	address public praRecipientAddr;
	address public owner;
	address public admin;

	
    bool public paused = false;

	
	constructor(address _praContract) public {
		praContractAddr = _praContract;
		owner = msg.sender;
	}

	
	modifier onlyAdmin() {
		require(msg.sender == admin || msg.sender == owner);
		_;
	}

	
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	
	modifier whenPaused {
		require(paused);
		_;
	}

	
	function pause() public onlyAdmin whenNotPaused returns (bool) {
		paused = true;
		return paused;
	}

	
	function unpause() public onlyAdmin whenPaused returns (bool) {
		paused = false;
		return paused;
	}

	
	
	
	function setAdmin(address _new_admin) public onlyAdmin {
		require(_new_admin != address(0));
		admin = _new_admin;
	}

	
	
	
	function setPraAddress(address _praContract) public onlyAdmin {
		praContractAddr = _praContract;
	}

	
	
	
	function setRecipientAddr(address _recipientAddr) public onlyAdmin {
		praRecipientAddr = _recipientAddr;
	}

	
	function() external payable { revert();	}

	

	
	
	
	
	
	
	
	
	function htlc(
		bytes32 _randomNumberHash,
		uint64 _timestamp,
		uint256 _heightSpan,
		uint256 _outAmount,
		uint256 _praAmount,
		string memory _receiverAddr
	) public whenNotPaused returns (bool) {
		bytes32 swapID = calSwapID(_randomNumberHash, _receiverAddr);
		require(swapStates[swapID] == States.INVALID, "swap is opened previously");
		
		
		require(_heightSpan >= 60 && _heightSpan <= 60480, "_heightSpan should be in [60, 60480]");
		require(_outAmount >= 100000000000000000, "_outAmount must be more than 0.1");
		require(
			_timestamp > now - 1800 && _timestamp < now + 1800,
			"Timestamp must be 30 minutes between current time"
		);
		require(_outAmount == _praAmount, "_outAmount must be equal _praAmount");

		
		Swap memory swap = Swap({
			outAmount: _outAmount,
			expireHeight: _heightSpan + block.number,
			randomNumberHash: _randomNumberHash,
			timestamp: _timestamp,
			senderAddr: msg.sender,
			senderChainType: uint256(ChainTypes.ETH),
			receiverAddr: _receiverAddr,
			receiverChainType: uint256(ChainTypes.PRA),
			recipientAddr: praRecipientAddr
		});

		
		swaps[swapID] = swap;
		swapStates[swapID] = States.OPEN;

		
		require(
			ERC20(praContractAddr).transferFrom(msg.sender, address(this), _outAmount),
			"failed to transfer client asset to swap contract"
		);

		
		emit HTLC(
			msg.sender,
			praRecipientAddr,
			swapID,
			_randomNumberHash,
			_timestamp,
			swap.expireHeight,
			_outAmount,
			_praAmount,
			_receiverAddr
		);

		
		
		swapStates[swapID] = States.COMPLETED;

		
		require(
			ERC20(praContractAddr).transfer(praRecipientAddr, _outAmount),
			"Failed to transfer locked asset to recipient"
		);

		
		delete swaps[swapID];

		
		emit Claimed(msg.sender, praRecipientAddr, swapID, _randomNumberHash, _receiverAddr);

		return true;
	}

	
	
	
	function queryOpenSwap(bytes32 _swapID)
		external
		view
		returns (
			bytes32 _randomNumberHash,
			uint64 _timestamp,
			uint256 _expireHeight,
			uint256 _outAmount,
			address _sender,
			address _recipient
		)
	{
		Swap memory swap = swaps[_swapID];
		return (
			swap.randomNumberHash,
			swap.timestamp,
			swap.expireHeight,
			swap.outAmount,
			swap.senderAddr,
			swap.recipientAddr
		);
	}

	
	
	
	function isSwapExist(bytes32 _swapID) external view returns (bool) {
		return (swapStates[_swapID] != States.INVALID);
	}

	
	
	
	
	function calSwapID(bytes32 _randomNumberHash, string memory receiverAddr) public pure returns (bytes32) {
		return sha256(abi.encodePacked(_randomNumberHash, receiverAddr));
	}
}