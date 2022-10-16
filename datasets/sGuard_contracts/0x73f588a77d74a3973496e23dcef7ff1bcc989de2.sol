pragma solidity ^0.4.24;





contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



pragma solidity ^0.4.24;

contract EIP918Interface {

    
    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);

    
    

    
    function getChallengeNumber() public view returns (bytes32);

    
    function getMiningDifficulty() public view returns (uint);

    
    function getMiningTarget() public view returns (uint);

    
    function getMiningReward() public view returns (uint);
    
    
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

}



pragma solidity ^0.4.24;




contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    
    constructor() public {
        owner = msg.sender;
    }
	
    modifier onlyOwner {
        require(msg.sender == owner, "owner required");
        _;
    }
	
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
	
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



pragma solidity ^0.4.24;


contract Admin is Owned
{
	
	event AdminAdded(address indexed admin, address indexed account);
	
	
    event AdminRemoved(address indexed admin, address indexed account);
	
	
	event AdminRenounced(address indexed account);
	
	
	
	mapping(address => bool) public admin;
	
	constructor()
		Owned()
		public
	{
		addAdmin(msg.sender);
	}
	
	modifier onlyAdmin() {
		require(admin[msg.sender], "Admin required");
		_;
	}
	
	function isAdmin(address _account) public view returns (bool) {
		return admin[_account];
	}
	
	function addAdmin(address _account) public onlyOwner {
		require(_account != address(0));
		require(!admin[_account], "Admin already added");
		admin[_account] = true;
		emit AdminAdded(msg.sender, _account);
	}
	
	function removeAdmin(address _account) public onlyOwner {
		require(_account != address(0));
		require(_account != owner, "Owner can not remove his admin role");
		require(admin[_account], "Remove admin only");
		admin[_account] = false;
		emit AdminRemoved(msg.sender, _account);
	}
	
	function renounceAdmin() public {
		require(msg.sender != owner, "Owner can not renounce to his admin role");
		require(admin[msg.sender], "Renounce admin only");
		admin[msg.sender] = false;
		emit AdminRenounced(msg.sender);
    }
}



pragma solidity ^0.4.24;






contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}



pragma solidity ^0.4.24;




library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}



pragma solidity ^0.4.24;

library ExtendedMath {
    
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {
        if(a > b) return b;
        return a;
    }
}



pragma solidity ^0.4.24;























contract _0xCatetherToken is ERC20Interface, EIP918Interface, ApproveAndCallFallBack, Owned, Admin
{
    using SafeMath for uint;
    using ExtendedMath for uint;
	
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public latestDifficultyPeriodStarted;
    uint public epochCount;
    
	
    uint public  _MINIMUM_TARGET = 2**16;
    
    uint public  _MAXIMUM_TARGET = 2**224; 
    
	uint public miningTarget;
    bytes32 public challengeNumber;   
    address public lastRewardTo;
    uint public lastRewardAmount;
    uint public lastRewardEthBlockNumber;
	
    
    
    mapping(bytes32 => bytes32) public solutionForChallenge;
    mapping(uint => uint) public targetForEpoch;
    mapping(uint => uint) public timeStampForEpoch;
    mapping(address => address) public donationsTo;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    event Donation(address donation);
    event DonationAddressOf(address donator, address donnationAddress);
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
	
	uint public tokensMinted;
	
	
	bool public transfersEnabled;
	event TransfersEnabled(address indexed admin);
	event TransfersDisabled(address indexed admin);
	
	
	bool public miningEnabled;
	event MiningEnabled(address indexed admin);
	event MiningDisabled(address indexed admin);
	
	
	bool public migrationEnabled;
	event MigrationEnabled(address indexed admin);
	event MigrationDisabled(address indexed admin);
	
	event MigratedTokens(address indexed user, uint tokens);
	
	address public deprecatedContractAddress;
	
	
	
    
    
    
    constructor() public{
        symbol = "0xCATE";
        name = "0xCatether Token";
        
        decimals = 4;
		
		
		deprecatedContractAddress = 0x8F7DbF90E71285552a687097220E1035C2e87639;
		
		
		
		
		tokensMinted = 0; 
		_totalSupply = 0; 
        epochCount = 15516; 
        
        challengeNumber = bytes32(0x781504f93328a5bf6401754a85baab350e71a11d9051cc86a8ff6f9ebcf38477); 
        targetForEpoch[(epochCount - 1)] = _MAXIMUM_TARGET;
        timeStampForEpoch[(epochCount - 1)] = block.timestamp;
        latestDifficultyPeriodStarted = block.number;
        
        targetForEpoch[epochCount] = _MAXIMUM_TARGET;
        miningTarget = _MAXIMUM_TARGET;
		
		
		
		
		
		transfersEnabled = true;
		emit TransfersEnabled(msg.sender);
		
		
		miningEnabled = true;
		emit MiningEnabled(msg.sender);
		
		
		migrationEnabled = true;
		emit MigrationEnabled(msg.sender);
    }
	
	modifier whenMiningEnabled {
		require(miningEnabled, "Mining disabled");
		_;
	}
	
	modifier whenTransfersEnabled {
		require(transfersEnabled, "Transfers disabled");
		_;
	}
	
	modifier whenMigrationEnabled {
		require(migrationEnabled, "Migration disabled");
		_;
	}
	
	
	
	
	function enableTransfers(bool enable) public onlyAdmin returns (bool) {
		if (transfersEnabled != enable) {
			transfersEnabled = enable;
			if (enable)
				emit TransfersEnabled(msg.sender);
			else emit TransfersDisabled(msg.sender);
			return true;
		}
		return false;
	}
	
	
	function enableMining(bool enable) public onlyAdmin returns (bool) {
		if (miningEnabled != enable) {
			miningEnabled = enable;
			if (enable)
				emit MiningEnabled(msg.sender);
			else emit MiningDisabled(msg.sender);
			return true;
		}
		return false;
	}
	
	
	function enableMigration(bool enable) public onlyAdmin returns (bool) {
		if (migrationEnabled != enable) {
			migrationEnabled = enable;
			if (enable)
				emit MigrationEnabled(msg.sender);
			else emit MigrationDisabled(msg.sender);
			return true;
		}
		return false;
	}
	
	
	
    function mint(uint256 nonce, bytes32 challenge_digest) public whenMiningEnabled returns (bool success) {
		
        
        bytes32 digest =  keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce));
        
		
        require(digest == challenge_digest, "challenge_digest error");
		
        
        require(uint256(digest) <= miningTarget, "miningTarget error");
        
		
		bytes32 solution = solutionForChallenge[challengeNumber]; 
        solutionForChallenge[challengeNumber] = digest;
        require(solution == 0x0, "solution exists");  
        
		uint reward_amount = getMiningReward();
        balances[msg.sender] = balances[msg.sender].add(reward_amount);
        _totalSupply = _totalSupply.add(reward_amount);
		tokensMinted = tokensMinted.add(reward_amount);
		
        
        lastRewardTo = msg.sender;
        lastRewardAmount = reward_amount;
        lastRewardEthBlockNumber = block.number;
        
		_startNewMiningEpoch();
        emit Mint(msg.sender, reward_amount, epochCount, challengeNumber );
		return true;
    }

    
    function _startNewMiningEpoch() internal {
		
		timeStampForEpoch[epochCount] = block.timestamp;
        epochCount = epochCount.add(1);
		
		
		
		
		miningTarget = _reAdjustDifficulty(epochCount);
		
		
		
		challengeNumber = blockhash(block.number.sub(1));
    }
	
    
    
    function _reAdjustDifficulty(uint epoch) internal returns (uint) {
    
        uint timeTarget = 300;  
        uint N = 6180;          
                                
        uint elapsedTime = timeStampForEpoch[epoch.sub(1)].sub(timeStampForEpoch[epoch.sub(2)]); 
        
		targetForEpoch[epoch] = (targetForEpoch[epoch.sub(1)].mul(10000)).div( N.mul(3920).div(N.sub(1000).add(elapsedTime.mul(1042).div(timeTarget))).add(N));
		
		
		
		
		
		
		
        latestDifficultyPeriodStarted = block.number;
		
		targetForEpoch[epoch] = adjustTargetInBounds(targetForEpoch[epoch]);
		
		return targetForEpoch[epoch];
    }
	
	function adjustTargetInBounds(uint target) internal view returns (uint newTarget) {
		newTarget = target;
		
		if (newTarget < _MINIMUM_TARGET) 
		{
			newTarget = _MINIMUM_TARGET;
		}
		
		if (newTarget > _MAXIMUM_TARGET) 
		{
			newTarget = _MAXIMUM_TARGET;
		}
	}
	
    
    function getChallengeNumber() public view returns (bytes32) {
        return challengeNumber;
    }

    
    function getMiningDifficulty() public view returns (uint) {
		return _MAXIMUM_TARGET.div(targetForEpoch[epochCount]);
	}
	
	function getMiningTarget() public view returns (uint) {
		return targetForEpoch[epochCount];
	}
	
	
    
    function getMiningReward() public view returns (uint) {
        bytes32 digest = solutionForChallenge[challengeNumber];
        if(epochCount > 160000) return (50000   * 10**uint(decimals) );									
        if(epochCount > 140000) return (75000   * 10**uint(decimals) );									
        if(epochCount > 120000) return (125000  * 10**uint(decimals) );									
        if(epochCount > 100000) return (250000  * 10**uint(decimals) );									
        if(epochCount > 80000) return  (500000  * 10**uint(decimals) );									
        if(epochCount > 60000) return  (1000000 * 10**uint(decimals) );       							
        if(epochCount > 40000) return  ((uint256(keccak256(abi.encodePacked(digest))) % 2500000) * 10**uint(decimals) );	
        if(epochCount > 20000) return  ((uint256(keccak256(abi.encodePacked(digest))) % 3500000) * 10**uint(decimals) );	
                               return  ((uint256(keccak256(abi.encodePacked(digest))) % 5000000) * 10**uint(decimals) );	
    }

    
    function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns (bytes32 digesttest) {
		return keccak256(abi.encodePacked(challenge_number,msg.sender,nonce));
	}

    
    function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {
		bytes32 digest = keccak256(abi.encodePacked(challenge_number,msg.sender,nonce));
		if(uint256(digest) > testTarget) revert();
		return (digest == challenge_digest);
	}

    
    
    
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    
    
    
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
	
	
	
    function changeDonation(address donationAddress) public returns (bool success) {
        donationsTo[msg.sender] = donationAddress;
        
        emit DonationAddressOf(msg.sender , donationAddress); 
        return true;
    }
	
	
	
    
    
    
    
    
    function transfer(address to, uint tokens) public whenTransfersEnabled returns (bool success) {
        
		return transferAndDonateTo(to, tokens, donationsTo[msg.sender]);
    }
    
    function transferAndDonateTo(address to, uint tokens, address donation) public whenTransfersEnabled returns (bool success) {
        require(to != address(0), "to address required");
		
		uint donation_tokens; 
		if (donation != address(0))
			donation_tokens = 5000;
		
        balances[msg.sender] = (balances[msg.sender].sub(tokens)).add(5000); 
        balances[to] = balances[to].add(tokens);
        balances[donation] = balances[donation].add(donation_tokens); 
		
		_totalSupply = _totalSupply.add(donation_tokens.add(5000));
		
        emit Transfer(msg.sender, to, tokens);
		emit Donation(msg.sender);
		if (donation != address(0)) {
			emit Donation(donation);
		}
        return true;
    }
	
    
    
    
    
    
    
    
    
    function approve(address spender, uint tokens) public whenTransfersEnabled returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint tokens) public whenTransfersEnabled returns (bool success) {
        require(to != address(0), "to address required");
		
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        
		address donation = donationsTo[msg.sender];
		uint donation_tokens; 
		if (donation != address(0))
			donation_tokens = 5000;
		
		balances[donation] = balances[donation].add(donation_tokens); 
        balances[msg.sender] = balances[msg.sender].add(5000); 
        _totalSupply = _totalSupply.add(donation_tokens.add(5000));
		
		emit Transfer(from, to, tokens);
		emit Donation(msg.sender);
		if (donation != address(0)) {
			emit Donation(donation);
		}
        
        return true;
    }
	
    
    
    
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    
    
    
    
    
    function approveAndCall(address spender, uint tokens, bytes memory data) public whenTransfersEnabled returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
	
	
	
	
	function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public whenMigrationEnabled {
		
		require(token == deprecatedContractAddress, "Wrong deprecated contract address");
		
		
		require(ERC20Interface(deprecatedContractAddress).transferFrom(from, address(this), tokens), "oldToken.transferFrom failed");
		
		balances[from] = balances[from].add(tokens);
		_totalSupply = _totalSupply.add(tokens);
		tokensMinted = tokensMinted.add(tokens); 
		emit MigratedTokens(from, tokens);
	}
	
	
	
    
    
    
    function () external payable {
        revert();
    }
    
    
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}