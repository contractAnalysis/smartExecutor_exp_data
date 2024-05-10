pragma solidity 0.5.15;




interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) public view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) public view returns (address owner);

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


contract IERC721Receiver {
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}


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


contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}





contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}



library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


contract ERC20Mintable is ERC20, MinterRole {
    
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}


contract ERC20Capped is ERC20Mintable {
    uint256 private _cap;

    
    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }
}



contract ERC20Burnable is Context, ERC20 {
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}




contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


contract Pausable is Context, PauserRole {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    
    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}







contract ShotgunClause {

	using SafeMath for uint256;

	ShardGovernor private _shardGovernor;
	ShardRegistry private _shardRegistry;

	enum ClaimWinner { None, Claimant, Counterclaimant }
	ClaimWinner private _claimWinner = ClaimWinner.None;

	uint private _deadlineTimestamp;
	uint private _initialOfferInWei;
	uint private _pricePerShardInWei;
	address payable private _initialClaimantAddress;
	uint private _initialClaimantBalance;
	bool private _shotgunEnacted = false;
	uint private _counterWeiContributed;
	address[] private _counterclaimants;
	mapping(address => uint) private _counterclaimContribs;

	event Countercommit(address indexed committer, uint indexed weiAmount);
	event EtherCollected(address indexed collector, uint indexed weiAmount);

	constructor(
		address payable initialClaimantAddress,
		uint initialClaimantBalance,
		address shardRegistryAddress
	) public payable {
		_shardGovernor = ShardGovernor(msg.sender);
		_shardRegistry = ShardRegistry(shardRegistryAddress);
		_deadlineTimestamp = now.add(1 * 14 days);
		_initialClaimantAddress = initialClaimantAddress;
		_initialClaimantBalance = initialClaimantBalance;
		_initialOfferInWei = msg.value;
		_pricePerShardInWei = (_initialOfferInWei.mul(10**18)).div(_shardRegistry.cap().sub(_initialClaimantBalance));
		_claimWinner = ClaimWinner.Claimant;
	}

	
	function counterCommitEther() external payable {
		require(
			_shardRegistry.balanceOf(msg.sender) > 0,
			"[counterCommitEther] Account does not own Shards"
		);
		require(
			msg.value > 0,
			"[counterCommitEther] Ether is required"
		);
		require(
			_initialClaimantAddress != address(0),
			"[counterCommitEther] Initial claimant does not exist"
		);
		require(
			msg.sender != _initialClaimantAddress,
			"[counterCommitEther] Initial claimant cannot countercommit"
		);
		require(
			!_shotgunEnacted,
			"[counterCommitEther] Shotgun already enacted"
		);
		require(
			now < _deadlineTimestamp,
			"[counterCommitEther] Deadline has expired"
		);
		require(
			msg.value + _counterWeiContributed <= getRequiredWeiForCounterclaim(),
			"[counterCommitEther] Ether exceeds goal"
		);
		if (_counterclaimContribs[msg.sender] == 0) {
			_counterclaimants.push(msg.sender);
		}
		_counterclaimContribs[msg.sender] = _counterclaimContribs[msg.sender].add(msg.value);
		_counterWeiContributed = _counterWeiContributed.add(msg.value);
		emit Countercommit(msg.sender, msg.value);
		if (_counterWeiContributed == getRequiredWeiForCounterclaim()) {
			_claimWinner = ClaimWinner.Counterclaimant;
			enactShotgun();
			(bool success, ) = _initialClaimantAddress.call.value(_initialOfferInWei)("");
			require(success, "[counterCommitEther] Transfer failed.");
		}
	}

	/**
		* @notice Collect ether from completed Shotgun.
		* @dev Called by Shard Registry after burning caller's Shards.
		* @dev For counterclaimants, returns both the proportional worth of their
		Shards in Ether AND any counterclaim contributions they have made.
		* @dev alternative: OpenZeppelin PaymentSplitter
		*/
	function collectEtherProceeds(uint balance, address payable caller) external {
		require(
			msg.sender == address(_shardRegistry),
			"[collectEtherProceeds] Caller not authorized"
		);
		if (_claimWinner == ClaimWinner.Claimant && caller != _initialClaimantAddress) {
			uint weiProceeds = (_pricePerShardInWei.mul(balance)).div(10**18);
			weiProceeds = weiProceeds.add(_counterclaimContribs[caller]);
			_counterclaimContribs[caller] = 0;
			(bool success, ) = address(caller).call.value(weiProceeds)("");
			require(success, "[collectEtherProceeds] Transfer failed.");
			emit EtherCollected(caller, weiProceeds);
		} else if (_claimWinner == ClaimWinner.Counterclaimant && caller == _initialClaimantAddress) {
			uint amount = (_pricePerShardInWei.mul(_initialClaimantBalance)).div(10**18);
			_initialClaimantBalance = 0;
			(bool success, ) = address(caller).call.value(amount)("");
			require(success, "[collectEtherProceeds] Transfer failed.");
			emit EtherCollected(caller, amount);
		}
	}

	/**
		* @notice Use by successful counterclaimants to collect Shards from initial claimant.
		*/
	function collectShardProceeds() external {
		require(
			_shotgunEnacted && _claimWinner == ClaimWinner.Counterclaimant,
			"[collectShardProceeds] Shotgun has not been enacted or invalid winner"
		);
		require(
			_counterclaimContribs[msg.sender] != 0,
			"[collectShardProceeds] Account has not participated in counterclaim"
		);
		uint proportionContributed = (_counterclaimContribs[msg.sender].mul(10**18)).div(_counterWeiContributed);
		_counterclaimContribs[msg.sender] = 0;
		uint shardsToReceive = (proportionContributed.mul(_initialClaimantBalance)).div(10**18);
		_shardGovernor.transferShards(msg.sender, shardsToReceive);
	}

	function deadlineTimestamp() external view returns (uint256) {
		return _deadlineTimestamp;
	}

	function shotgunEnacted() external view returns (bool) {
		return _shotgunEnacted;
	}

	function initialClaimantAddress() external view returns (address) {
		return _initialClaimantAddress;
	}

	function initialClaimantBalance() external view returns (uint) {
		return _initialClaimantBalance;
	}

	function initialOfferInWei() external view returns (uint256) {
		return _initialOfferInWei;
	}

	function pricePerShardInWei() external view returns (uint256) {
		return _pricePerShardInWei;
	}

	function claimWinner() external view returns (ClaimWinner) {
		return _claimWinner;
	}

	function counterclaimants() external view returns (address[] memory) {
		return _counterclaimants;
	}

	function getCounterclaimantContribution(address counterclaimant) external view returns (uint) {
		return _counterclaimContribs[counterclaimant];
	}

	function counterWeiContributed() external view returns (uint) {
		return _counterWeiContributed;
	}

	function getContractBalance() external view returns (uint) {
		return address(this).balance;
	}

	function shardGovernor() external view returns (address) {
		return address(_shardGovernor);
	}

	function getRequiredWeiForCounterclaim() public view returns (uint) {
		return (_pricePerShardInWei.mul(_initialClaimantBalance)).div(10**18);
	}

	
	function enactShotgun() public {
		require(
			!_shotgunEnacted,
			"[enactShotgun] Shotgun already enacted"
		);
		require(
			_claimWinner == ClaimWinner.Counterclaimant ||
			(_claimWinner == ClaimWinner.Claimant && now > _deadlineTimestamp),
			"[enactShotgun] Conditions not met to enact Shotgun Clause"
		);
		_shotgunEnacted = true;
		_shardGovernor.enactShotgun();
	}
}



contract ShardRegistry is ERC20Detailed, ERC20Capped, ERC20Burnable, ERC20Pausable {

	ShardGovernor private _shardGovernor;
	enum ClaimWinner { None, Claimant, Counterclaimant }

	constructor (
		uint256 cap,
		string memory name,
		string memory symbol
	) ERC20Detailed(name, symbol, 18) ERC20Capped(cap) public {
		_shardGovernor = ShardGovernor(msg.sender);
	}

	
	function lockShardsAndClaim() external payable {
		require(
			_shardGovernor.checkLock(),
			"[lockShardsAndClaim] NFT not locked, Shotgun cannot be triggered"
		);
		require(
			_shardGovernor.checkShotgunState(),
			"[lockShardsAndClaim] Shotgun already in progress"
		);
		require(
			msg.value > 0,
			"[lockShardsAndClaim] Transaction must send ether to activate Shotgun Clause"
		);
		uint initialClaimantBalance = balanceOf(msg.sender);
		require(
			initialClaimantBalance > 0,
			"[lockShardsAndClaim] Account does not own Shards"
		);
		require(
			initialClaimantBalance < cap(),
			"[lockShardsAndClaim] Account owns all Shards"
		);
		transfer(address(_shardGovernor), balanceOf(msg.sender));
		(bool success) = _shardGovernor.claimInitialShotgun.value(msg.value)(
			msg.sender, initialClaimantBalance
		);
		require(
			success,
			"[lockShards] Ether forwarding unsuccessful"
		);
	}

	
	function burnAndCollectEther(address shotgunClause) external {
		ShotgunClause _shotgunClause = ShotgunClause(shotgunClause);
		bool enacted = _shotgunClause.shotgunEnacted();
		if (!enacted) {
			_shotgunClause.enactShotgun();
		}
		require(
			enacted || _shotgunClause.shotgunEnacted(),
			"[burnAndCollectEther] Shotgun Clause not enacted"
		);
		uint balance = balanceOf(msg.sender);
		require(
			balance > 0 || msg.sender == _shotgunClause.initialClaimantAddress(),
			"[burnAndCollectEther] Account does not own Shards"
		);
		require(
			uint(_shotgunClause.claimWinner()) == uint(ClaimWinner.Claimant) &&
			msg.sender != _shotgunClause.initialClaimantAddress() ||
			uint(_shotgunClause.claimWinner()) == uint(ClaimWinner.Counterclaimant) &&
			msg.sender == _shotgunClause.initialClaimantAddress(),
			"[burnAndCollectEther] Account does not have right to collect ether"
		);
		burn(balance);
		_shotgunClause.collectEtherProceeds(balance, msg.sender);
	}
}







contract ShardOffering {

	using SafeMath for uint256;

	ShardGovernor private _shardGovernor;
	uint private _offeringDeadline;
	uint private _pricePerShardInWei;
	uint private _contributionTargetInWei;
	uint private _liqProviderCutInShards;
	uint private _artistCutInShards;
	uint private _offererShardAmount;

	address[] private _contributors;
	mapping(address => uint) private _contributionsinWei;
	mapping(address => uint) private _contributionsInShards;
	mapping(address => bool) private _hasClaimedShards;
	uint private _totalWeiContributed;
	uint private _totalShardsClaimed;
	bool private _offeringCompleted;

	event Contribution(address indexed contributor, uint indexed weiAmount);
	event OfferingWrappedUp();

	constructor(
		uint pricePerShardInWei,
		uint shardAmountOffered,
		uint liqProviderCutInShards,
		uint artistCutInShards,
		uint offeringDeadline,
		uint cap
	) public {
		_pricePerShardInWei = pricePerShardInWei;
		_liqProviderCutInShards = liqProviderCutInShards;
		_artistCutInShards = artistCutInShards;
		_offeringDeadline = offeringDeadline;
		_shardGovernor = ShardGovernor(msg.sender);
		_contributionTargetInWei = (pricePerShardInWei.mul(shardAmountOffered)).div(10**18);
		_offererShardAmount = cap.sub(shardAmountOffered).sub(liqProviderCutInShards).sub(artistCutInShards);
	}

	
	function contribute() external payable {
		require(
			!_offeringCompleted,
			"[contribute] Offering is complete"
		);
		require(
			msg.value > 0,
			"[contribute] Contribution requires ether"
		);
		require(
			msg.value <= _contributionTargetInWei - _totalWeiContributed,
			"[contribute] Ether value exceeds remaining quota"
		);
		require(
			msg.sender != _shardGovernor.offererAddress(),
			"[contribute] Offerer cannot contribute"
		);
		require(
			now < _offeringDeadline,
			"[contribute] Deadline for offering expired"
		);
		require(
			_shardGovernor.checkLock(),
			"[contribute] NFT not locked yet"
		);
		if (_contributionsinWei[msg.sender] == 0) {
			_contributors.push(msg.sender);
		}
		_contributionsinWei[msg.sender] = _contributionsinWei[msg.sender].add(msg.value);
		uint shardAmount = (msg.value.mul(10**18)).div(_pricePerShardInWei);
		_contributionsInShards[msg.sender] = _contributionsInShards[msg.sender].add(shardAmount);
		_totalWeiContributed = _totalWeiContributed.add(msg.value);
		_totalShardsClaimed = _totalShardsClaimed.add(shardAmount);
		if (_totalWeiContributed == _contributionTargetInWei) {
			_offeringCompleted = true;
			(bool success, ) = _shardGovernor.offererAddress().call.value(address(this).balance)("");
			require(success, "[contribute] Transfer failed.");
		}
		emit Contribution(msg.sender, msg.value);
	}

	/**
		* @notice Prematurely end Offering.
		* @dev Called by Governor contract when Offering deadline expires and has not
		* raised the target amount of Ether.
		* @dev reentrancy is guarded in _shardGovernor.checkOfferingAndIssue() by
		`hasClaimedShards`.
		*/
	function wrapUpOffering() external {
		require(
			msg.sender == address(_shardGovernor),
			"[wrapUpOffering] Unauthorized caller"
		);
		_offeringCompleted = true;
		(bool success, ) = _shardGovernor.offererAddress().call.value(address(this).balance)("");
		require(success, "[wrapUpOffering] Transfer failed.");
		emit OfferingWrappedUp();
	}

	/**
		* @notice Records Shard claim for subcriber.
		* @dev Can only be called by Governor contract on Offering close.
		* @param claimant wallet address of the person claiming the Shards they
		subscribed to.
		*/
	function claimShards(address claimant) external {
		require(
			msg.sender == address(_shardGovernor),
			"[claimShards] Unauthorized caller"
		);
		_hasClaimedShards[claimant] = true;
	}

	function offeringDeadline() external view returns (uint) {
		return _offeringDeadline;
	}

	function getSubEther(address sub) external view returns (uint) {
		return _contributionsinWei[sub];
	}

	function getSubShards(address sub) external view returns (uint) {
		return _contributionsInShards[sub];
	}

	function hasClaimedShards(address claimant) external view returns (bool) {
		return _hasClaimedShards[claimant];
	}

	function pricePerShardInWei() external view returns (uint) {
		return _pricePerShardInWei;
	}

	function offererShardAmount() external view returns (uint) {
		return _offererShardAmount;
	}

	function liqProviderCutInShards() external view returns (uint) {
		return _liqProviderCutInShards;
	}

	function artistCutInShards() external view returns (uint) {
		return _artistCutInShards;
	}

	function offeringCompleted() external view returns (bool) {
		return _offeringCompleted;
	}

	function totalShardsClaimed() external view returns (uint) {
		return _totalShardsClaimed;
	}

	function totalWeiContributed() external view returns (uint) {
		return _totalWeiContributed;
	}

	function contributionTargetInWei() external view returns (uint) {
		return _contributionTargetInWei;
	}

	function getContractBalance() external view returns (uint) {
		return address(this).balance;
	}

	function contributors() external view returns (address[] memory) {
		return _contributors;
	}
}



contract ShardGovernor is IERC721Receiver {

  using SafeMath for uint256;

	
	bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

	ShardRegistry private _shardRegistry;
	ShardOffering private _shardOffering;
	ShotgunClause private _currentShotgunClause;
	address payable private _offererAddress;
	address private _nftRegistryAddress;
	address payable private _niftexWalletAddress;
	address payable private _artistWalletAddress;
	uint256 private _tokenId;

	enum ClaimWinner { None, Claimant, Counterclaimant }
	address[] private _shotgunAddressArray;
	mapping(address => uint) private _shotgunMapping;
	uint private _shotgunCounter;

	event NewShotgun(address indexed shotgun);
	event ShardsClaimed(address indexed claimant, uint indexed shardAmount);
	event NftRedeemed(address indexed redeemer);
	event ShotgunEnacted(address indexed enactor);
	event ShardsCollected(address indexed collector, uint indexed shardAmount, address indexed shotgun);

	
  constructor(
		address nftRegistryAddress,
		address payable offererAddress,
		uint256 tokenId,
		address payable niftexWalletAddress,
		address payable artistWalletAddress,
		uint liqProviderCutInShards,
		uint artistCutInShards,
		uint pricePerShardInWei,
		uint shardAmountOffered,
		uint offeringDeadline,
		uint256 cap,
		string memory name,
		string memory symbol
	) public {
		require(
			IERC721(nftRegistryAddress).ownerOf(tokenId) == offererAddress,
			"Offerer is not owner of tokenId"
		);
		_nftRegistryAddress = nftRegistryAddress;
		_niftexWalletAddress = niftexWalletAddress;
		_artistWalletAddress = artistWalletAddress;
		_tokenId = tokenId;
		_offererAddress = offererAddress;
		_shardRegistry = new ShardRegistry(cap, name, symbol);
		_shardOffering = new ShardOffering(
			pricePerShardInWei,
			shardAmountOffered,
			liqProviderCutInShards,
			artistCutInShards,
			offeringDeadline,
			cap
		);
  }

	
	function checkOfferingAndIssue() external {
		require(
			_shardRegistry.totalSupply() != _shardRegistry.cap(),
			"[checkOfferingAndIssue] Shards have already been issued"
		);
		require(
			!_shardOffering.hasClaimedShards(msg.sender),
			"[checkOfferingAndIssue] You have already claimed your Shards"
		);
		require(
			_shardOffering.offeringCompleted() ||
			(now > _shardOffering.offeringDeadline() && !_shardOffering.offeringCompleted()),
			"Offering not completed or deadline not expired"
		);
		if (_shardOffering.offeringCompleted()) {
			if (_shardOffering.getSubEther(msg.sender) != 0) {
				_shardOffering.claimShards(msg.sender);
				uint subShards = _shardOffering.getSubShards(msg.sender);
				bool success = _shardRegistry.mint(msg.sender, subShards);
				require(success, "[checkOfferingAndIssue] Mint failed");
				emit ShardsClaimed(msg.sender, subShards);
			} else if (msg.sender == _offererAddress) {
				_shardOffering.claimShards(msg.sender);
				uint offShards = _shardOffering.offererShardAmount();
				bool success = _shardRegistry.mint(msg.sender, offShards);
				require(success, "[checkOfferingAndIssue] Mint failed");
				emit ShardsClaimed(msg.sender, offShards);
			}
		} else {
			_shardOffering.wrapUpOffering();
			uint remainingShards = _shardRegistry.cap().sub(_shardOffering.totalShardsClaimed());
			remainingShards = remainingShards
				.sub(_shardOffering.liqProviderCutInShards())
				.sub(_shardOffering.artistCutInShards());
			bool success = _shardRegistry.mint(_offererAddress, remainingShards);
			require(success, "[checkOfferingAndIssue] Mint failed");
			emit ShardsClaimed(msg.sender, remainingShards);
		}
	}

	
	

	function mintReservedShards(address _beneficiary) external {
		bool niftex;
		if (_beneficiary == _niftexWalletAddress) niftex = true;
		require(
			niftex ||
			_beneficiary == _artistWalletAddress,
			"[mintReservedShards] Unauthorized beneficiary"
		);
		require(
			!_shardOffering.hasClaimedShards(_beneficiary),
			"[mintReservedShards] Shards already claimed"
		);
		_shardOffering.claimShards(_beneficiary);
		uint cut;
		if (niftex) {
			cut = _shardOffering.liqProviderCutInShards();
		} else {
			cut = _shardOffering.artistCutInShards();
		}
		bool success = _shardRegistry.mint(_beneficiary, cut);
		require(success, "[mintReservedShards] Mint failed");
		emit ShardsClaimed(_beneficiary, cut);
	}

	
	function redeem() external {
		require(
			_shardRegistry.balanceOf(msg.sender) == _shardRegistry.cap(),
			"[redeem] Account does not own total amount of Shards outstanding"
		);
		IERC721(_nftRegistryAddress).safeTransferFrom(address(this), msg.sender, _tokenId);
		emit NftRedeemed(msg.sender);
	}

	
	function claimInitialShotgun(
		address payable initialClaimantAddress,
		uint initialClaimantBalance
	) external payable returns (bool) {
		require(
			msg.sender == address(_shardRegistry),
			"[claimInitialShotgun] Caller not authorized"
		);
		_currentShotgunClause = (new ShotgunClause).value(msg.value)(
			initialClaimantAddress,
			initialClaimantBalance,
			address(_shardRegistry)
		);
		emit NewShotgun(address(_currentShotgunClause));
		_shardRegistry.pause();
		_shotgunAddressArray.push(address(_currentShotgunClause));
		_shotgunCounter++;
		_shotgunMapping[address(_currentShotgunClause)] = _shotgunCounter;
		return true;
	}

	
	function enactShotgun() external {
		require(
			_shotgunMapping[msg.sender] != 0,
			"[enactShotgun] Invalid Shotgun Clause"
		);
		ShotgunClause _shotgunClause = ShotgunClause(msg.sender);
		address initialClaimantAddress = _shotgunClause.initialClaimantAddress();
		if (uint(_shotgunClause.claimWinner()) == uint(ClaimWinner.Claimant)) {
			_shardRegistry.burn(_shardRegistry.balanceOf(initialClaimantAddress));
			IERC721(_nftRegistryAddress).safeTransferFrom(address(this), initialClaimantAddress, _tokenId);
			_shardRegistry.unpause();
			emit ShotgunEnacted(address(_shotgunClause));
		} else if (uint(_shotgunClause.claimWinner()) == uint(ClaimWinner.Counterclaimant)) {
			_shardRegistry.unpause();
			emit ShotgunEnacted(address(_shotgunClause));
		}
	}

	
	function transferShards(address recipient, uint amount) external {
		require(
			_shotgunMapping[msg.sender] != 0,
			"[transferShards] Unauthorized caller"
		);
		bool success = _shardRegistry.transfer(recipient, amount);
		require(success, "[transferShards] Transfer failed");
		emit ShardsCollected(recipient, amount, msg.sender);
	}

	
	function checkShotgunState() external view returns (bool) {
		if (_shotgunCounter == 0) {
			return true;
		} else {
			ShotgunClause _shotgunClause = ShotgunClause(_shotgunAddressArray[_shotgunCounter - 1]);
			if (_shotgunClause.shotgunEnacted()) {
				return true;
			} else {
				return false;
			}
		}
	}

	function currentShotgunClause() external view returns (address) {
		return address(_currentShotgunClause);
	}

	function shardRegistryAddress() external view returns (address) {
		return address(_shardRegistry);
	}

	function shardOfferingAddress() external view returns (address) {
		return address(_shardOffering);
	}

	function getContractBalance() external view returns (uint) {
		return address(this).balance;
	}

	function offererAddress() external view returns (address payable) {
		return _offererAddress;
	}

	function shotgunCounter() external view returns (uint) {
		return _shotgunCounter;
	}

	function shotgunAddressArray() external view returns (address[] memory) {
		return _shotgunAddressArray;
	}

	
	function checkLock() external view returns (bool) {
		address owner = IERC721(_nftRegistryAddress).ownerOf(_tokenId);
		return owner == address(this);
	}

	
	function onERC721Received(address, address, uint256, bytes memory) public returns(bytes4) {
		return _ERC721_RECEIVED;
	}
}