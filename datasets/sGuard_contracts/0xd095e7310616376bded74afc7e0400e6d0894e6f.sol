pragma solidity 0.5.16;

interface IContractRegistry {

	event ContractAddressUpdated(string contractName, address addr);

	
	function set(string calldata contractName, address addr) external ;

	
	function get(string calldata contractName) external view returns (address);
}



pragma solidity 0.5.16;



interface IGuardiansRegistration {
	event GuardianRegistered(address addr);
	event GuardianDataUpdated(address addr, bytes4 ip, address orbsAddr, string name, string website, string contact);
	event GuardianUnregistered(address addr);
	event GuardianMetadataChanged(address addr, string key, string newValue, string oldValue);

	

    
	function registerGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website, string calldata contact) external;

    
	function updateGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website, string calldata contact) external;

	
	function updateGuardianIp(bytes4 ip) external ;

    
    function setMetadata(string calldata key, string calldata value) external;

    
    function getMetadata(address addr, string calldata key) external view returns (string memory);

    
	function unregisterGuardian() external;

    
    
	function getGuardianData(address addr) external view returns (bytes4 ip, address orbsAddr, string memory name, string memory website, string memory contact, uint registration_time, uint last_update_time);

	
	
	function getGuardiansOrbsAddress(address[] calldata addrs) external view returns (address[] memory orbsAddrs);

	
	
	function getGuardianIp(address addr) external view returns (bytes4 ip);

	
	function getGuardianIps(address[] calldata addr) external view returns (bytes4[] memory ips);


	
	
	function isRegistered(address addr) external view returns (bool);

	

    
    
	function getOrbsAddresses(address[] calldata ethereumAddrs) external view returns (address[] memory orbsAddr);

	
	
	function getEthereumAddresses(address[] calldata orbsAddrs) external view returns (address[] memory ethereumAddr);

	
	function resolveGuardianAddress(address ethereumOrOrbsAddress) external view returns (address mainAddress);

}



pragma solidity 0.5.16;



interface IElections  {
	
	event GuardianVotedUnready(address guardian);
	event GuardianVotedOut(address guardian);

	
	event VoteUnreadyCasted(address voter, address subject);
	event VoteOutCasted(address voter, address subject);
	event StakeChanged(address addr, uint256 selfStake, uint256 delegated_stake, uint256 effective_stake);

	event GuardianStatusUpdated(address addr, bool readyToSync, bool readyForCommittee);

	
	event VoteUnreadyTimeoutSecondsChanged(uint32 newValue, uint32 oldValue);
	event MinSelfStakePercentMilleChanged(uint32 newValue, uint32 oldValue);
	event VoteOutPercentageThresholdChanged(uint8 newValue, uint8 oldValue);
	event VoteUnreadyPercentageThresholdChanged(uint8 newValue, uint8 oldValue);

	

	
	function voteUnready(address subject_addr) external;

	
	function voteOut(address subjectAddr) external;

	
	function readyToSync() external;

	
	function readyForCommittee() external;

	

	
	
	
	function delegatedStakeChange(address addr, uint256 selfStake, uint256 delegatedStake, uint256 totalDelegatedStake) external ;

	
	
	function guardianRegistered(address addr) external ;

	
	
	function guardianUnregistered(address addr) external ;

	
	
	function guardianCertificationChanged(address addr, bool isCertified) external ;

	

	
	function setContractRegistry(IContractRegistry _contractRegistry) external ;

	function setVoteUnreadyTimeoutSeconds(uint32 voteUnreadyTimeoutSeconds) external ;
	function setMinSelfStakePercentMille(uint32 minSelfStakePercentMille) external ;
	function setVoteOutPercentageThreshold(uint8 voteUnreadyPercentageThreshold) external ;
	function setVoteUnreadyPercentageThreshold(uint8 voteUnreadyPercentageThreshold) external ;
	function getSettings() external view returns (
		uint32 voteUnreadyTimeoutSeconds,
		uint32 minSelfStakePercentMille,
		uint8 voteUnreadyPercentageThreshold,
		uint8 voteOutPercentageThreshold
	);
}



pragma solidity 0.5.16;

interface IProtocol {
    event ProtocolVersionChanged(string deploymentSubset, uint256 currentVersion, uint256 nextVersion, uint256 fromTimestamp);

    

    
    function deploymentSubsetExists(string calldata deploymentSubset) external view returns (bool);

    
    function getProtocolVersion(string calldata deploymentSubset) external view returns (uint256);

    

    
    function createDeploymentSubset(string calldata deploymentSubset, uint256 initialProtocolVersion) external ;

    
    function setProtocolVersion(string calldata deploymentSubset, uint256 nextVersion, uint256 fromTimestamp) external ;
}



pragma solidity 0.5.16;



interface ICommittee {
	event GuardianCommitteeChange(address addr, uint256 weight, bool certification, bool inCommittee);
	event CommitteeSnapshot(address[] addrs, uint256[] weights, bool[] certification);

	

	

	
	
    
	function memberWeightChange(address addr, uint256 weight) external returns (bool committeeChanged) ;

	
	
	function memberCertificationChange(address addr, bool isCertified) external returns (bool committeeChanged) ;

	
	
	function removeMember(address addr) external returns (bool committeeChanged) ;

	
	
	function addMember(address addr, uint256 weight, bool isCertified) external returns (bool committeeChanged) ;

	
	
	function getCommittee() external view returns (address[] memory addrs, uint256[] memory weights, bool[] memory certification);

	

	function setMaxTimeBetweenRewardAssignments(uint32 maxTimeBetweenRewardAssignments) external ;
	function setMaxCommittee(uint8 maxCommitteeSize) external ;

	event MaxTimeBetweenRewardAssignmentsChanged(uint32 newValue, uint32 oldValue);
	event MaxCommitteeSizeChanged(uint8 newValue, uint8 oldValue);

    
	function setContractRegistry(IContractRegistry _contractRegistry) external ;

    

    
    
	function getCommitteeInfo() external view returns (address[] memory addrs, uint256[] memory weights, address[] memory orbsAddrs, bool[] memory certification, bytes4[] memory ips);

	
	function getSettings() external view returns (uint32 maxTimeBetweenRewardAssignments, uint8 maxCommitteeSize);
}



pragma solidity 0.5.16;




interface ICertification  {
	event GuardianCertificationUpdate(address guardian, bool isCertified);

	

    
    
	function isGuardianCertified(address addr) external view returns (bool isCertified);

    
    
	function setGuardianCertification(address addr, bool isCertified) external  ;

	

    
	function setContractRegistry(IContractRegistry _contractRegistry) external ;

}



pragma solidity 0.5.16;



interface ISubscriptions {
    event SubscriptionChanged(uint256 vcid, uint256 genRefTime, uint256 expiresAt, string tier, string deploymentSubset);
    event Payment(uint256 vcid, address by, uint256 amount, string tier, uint256 rate);
    event VcConfigRecordChanged(uint256 vcid, string key, string value);
    event SubscriberAdded(address subscriber);
    event VcCreated(uint256 vcid, address owner); 
    event VcOwnerChanged(uint256 vcid, address previousOwner, address newOwner);

    

    
    
    function createVC(string calldata tier, uint256 rate, uint256 amount, address owner, bool isCertified, string calldata deploymentSubset) external returns (uint, uint);

    
    
    function extendSubscription(uint256 vcid, uint256 amount, address payer) external;

    
    function setVcConfigRecord(uint256 vcid, string calldata key, string calldata value) external ;

    
    function getVcConfigRecord(uint256 vcid, string calldata key) external view returns (string memory);

    
    function setVcOwner(uint256 vcid, address owner) external ;

    
    function getGenesisRefTimeDelay() external view returns (uint256);

    

    
    function addSubscriber(address addr) external ;

    
    function setGenesisRefTimeDelay(uint256 newGenesisRefTimeDelay) external ;

    
    function setContractRegistry(IContractRegistry _contractRegistry) external ;

}



pragma solidity 0.5.16;



interface IDelegations  {
    
	event DelegatedStakeChanged(address indexed addr, uint256 selfDelegatedStake, uint256 delegatedStake, address[] delegators, uint256[] delegatorTotalStakes);

    
	event Delegated(address indexed from, address indexed to);

	

	
	function delegate(address to) external ;

	function refreshStakeNotification(address addr) external ;

	

    
	function setContractRegistry(IContractRegistry _contractRegistry) external ;

	function importDelegations(address[] calldata from, address[] calldata to, bool notifyElections) external ;
	function finalizeDelegationImport() external ;

	event DelegationsImported(address[] from, address[] to, bool notifiedElections);
	event DelegationImportFinalized();

	

	function getDelegatedStakes(address addr) external view returns (uint256);
	function getSelfDelegatedStake(address addr) external view returns (uint256);
	function getDelegation(address addr) external view returns (address);
	function getTotalDelegatedStake() external view returns (uint256) ;


}



pragma solidity ^0.5.0;


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



pragma solidity 0.5.16;



interface IMigratableStakingContract {
    
    
    function getToken() external view returns (IERC20);

    
    
    
    
    function acceptMigration(address _stakeOwner, uint256 _amount) external;

    event AcceptedMigration(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}



pragma solidity 0.5.16;



interface IStakingContract {
    
    
    
    function stake(uint256 _amount) external;

    
    
    
    function unstake(uint256 _amount) external;

    
    
    
    function withdraw() external;

    
    function restake() external;

    
    
    
    
    
    
    
    function distributeRewards(uint256 _totalAmount, address[] calldata _stakeOwners, uint256[] calldata _amounts) external;

    
    
    
    function getStakeBalanceOf(address _stakeOwner) external view returns (uint256);

    
    
    function getTotalStakedTokens() external view returns (uint256);

    
    
    
    
    function getUnstakeStatus(address _stakeOwner) external view returns (uint256 cooldownAmount,
        uint256 cooldownEndTime);

    
    
    
    function migrateStakedTokens(IMigratableStakingContract _newStakingContract, uint256 _amount) external;

    event Staked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Unstaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Withdrew(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Restaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event MigratedStake(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}



pragma solidity 0.5.16;




interface IRewards {

    function assignRewards() external;
    function assignRewardsToCommittee(address[] calldata generalCommittee, uint256[] calldata generalCommitteeWeights, bool[] calldata certification) external ;

    

    event StakingRewardsDistributed(address indexed distributer, uint256 fromBlock, uint256 toBlock, uint split, uint txIndex, address[] to, uint256[] amounts);
    event StakingRewardsAssigned(address[] assignees, uint256[] amounts); 
    event StakingRewardsAddedToPool(uint256 added, uint256 total);
    event MaxDelegatorsStakingRewardsChanged(uint32 maxDelegatorsStakingRewardsPercentMille);

    
    function getStakingRewardBalance(address addr) external view returns (uint256 balance);

    
    
    
    function distributeOrbsTokenStakingRewards(uint256 totalAmount, uint256 fromBlock, uint256 toBlock, uint split, uint txIndex, address[] calldata to, uint256[] calldata amounts) external;

    
    function topUpStakingRewardsPool(uint256 amount) external;

    

    
    function setAnnualStakingRewardsRate(uint256 annual_rate_in_percent_mille, uint256 annual_cap) external ;


    

    event FeesAssigned(uint256 generalGuardianAmount, uint256 certifiedGuardianAmount);
    event FeesWithdrawn(address guardian, uint256 amount);
    event FeesWithdrawnFromBucket(uint256 bucketId, uint256 withdrawn, uint256 total, bool isCertified);
    event FeesAddedToBucket(uint256 bucketId, uint256 added, uint256 total, bool isCertified);

    

    
    function getFeeBalance(address addr) external view returns (uint256 balance);

    
    function withdrawFeeFunds() external;

    
    
    function fillCertificationFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external;

    
    
    function fillGeneralFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external;

    function getTotalBalances() external view returns (uint256 feesTotalBalance, uint256 stakingRewardsTotalBalance, uint256 bootstrapRewardsTotalBalance);

    

    event BootstrapRewardsAssigned(uint256 generalGuardianAmount, uint256 certifiedGuardianAmount);
    event BootstrapAddedToPool(uint256 added, uint256 total);
    event BootstrapRewardsWithdrawn(address guardian, uint256 amount);

    

    
    function getBootstrapBalance(address addr) external view returns (uint256 balance);

    
    function withdrawBootstrapFunds() external;

    
    function getLastRewardAssignmentTime() external view returns (uint256 time);

    
    
    function topUpBootstrapPool(uint256 amount) external;

    

    
    function setGeneralCommitteeAnnualBootstrap(uint256 annual_amount) external ;

    
    function setCertificationCommitteeAnnualBootstrap(uint256 annual_amount) external ;

    event EmergencyWithdrawal(address addr);

    function emergencyWithdraw() external ;

    

    
    function setContractRegistry(IContractRegistry _contractRegistry) external ;


}



pragma solidity ^0.5.0;


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



pragma solidity 0.5.16;



contract WithClaimableMigrationOwnership is Context{
    address private _migrationOwner;
    address pendingMigrationOwner;

    event MigrationOwnershipTransferred(address indexed previousMigrationOwner, address indexed newMigrationOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _migrationOwner = msgSender;
        emit MigrationOwnershipTransferred(address(0), msgSender);
    }

    
    function migrationOwner() public view returns (address) {
        return _migrationOwner;
    }

    
    modifier onlyMigrationOwner() {
        require(isMigrationOwner(), "WithClaimableMigrationOwnership: caller is not the migrationOwner");
        _;
    }

    
    function isMigrationOwner() public view returns (bool) {
        return _msgSender() == _migrationOwner;
    }

    
    function renounceMigrationOwnership() public onlyMigrationOwner {
        emit MigrationOwnershipTransferred(_migrationOwner, address(0));
        _migrationOwner = address(0);
    }

    
    function _transferMigrationOwnership(address newMigrationOwner) internal {
        require(newMigrationOwner != address(0), "MigrationOwner: new migrationOwner is the zero address");
        emit MigrationOwnershipTransferred(_migrationOwner, newMigrationOwner);
        _migrationOwner = newMigrationOwner;
    }

    
    modifier onlyPendingMigrationOwner() {
        require(msg.sender == pendingMigrationOwner, "Caller is not the pending migrationOwner");
        _;
    }
    
    function transferMigrationOwnership(address newMigrationOwner) public onlyMigrationOwner {
        pendingMigrationOwner = newMigrationOwner;
    }
    
    function claimMigrationOwnership() external onlyPendingMigrationOwner {
        _transferMigrationOwnership(pendingMigrationOwner);
        pendingMigrationOwner = address(0);
    }
}



pragma solidity 0.5.16;




contract Lockable is WithClaimableMigrationOwnership {

    bool public locked;

    event Locked();
    event Unlocked();

    function lock() external onlyMigrationOwner {
        locked = true;
        emit Locked();
    }

    function unlock() external onlyMigrationOwner {
        locked = false;
        emit Unlocked();
    }

    modifier onlyWhenActive() {
        require(!locked, "contract is locked for this operation");

        _;
    }
}



pragma solidity 0.5.16;



pragma solidity 0.5.16;


interface IProtocolWallet {
    event FundsAddedToPool(uint256 added, uint256 total);
    event ClientSet(address client);
    event MaxAnnualRateSet(uint256 maxAnnualRate);
    event EmergencyWithdrawal(address addr);

    
    
    function getToken() external view returns (IERC20);

    
    
    function getBalance() external view returns (uint256 balance);

    
    function topUp(uint256 amount) external;

    
    
    
    
    
    function withdraw(uint256 amount) external; 

    
    
    function setMaxAnnualRate(uint256 annual_rate) external; 

    
    function emergencyWithdraw() external; 

    
    function setClient(address client) external; 
}



pragma solidity 0.5.16;













contract ContractRegistryAccessor is WithClaimableMigrationOwnership {

    IContractRegistry contractRegistry;

    event ContractRegistryAddressUpdated(address addr);

    function setContractRegistry(IContractRegistry _contractRegistry) external onlyMigrationOwner {
        contractRegistry = _contractRegistry;
        emit ContractRegistryAddressUpdated(address(_contractRegistry));
    }

    function getProtocolContract() public view returns (IProtocol) {
        return IProtocol(contractRegistry.get("protocol"));
    }

    function getRewardsContract() public view returns (IRewards) {
        return IRewards(contractRegistry.get("rewards"));
    }

    function getCommitteeContract() public view returns (ICommittee) {
        return ICommittee(contractRegistry.get("committee"));
    }

    function getElectionsContract() public view returns (IElections) {
        return IElections(contractRegistry.get("elections"));
    }

    function getDelegationsContract() public view returns (IDelegations) {
        return IDelegations(contractRegistry.get("delegations"));
    }

    function getGuardiansRegistrationContract() public view returns (IGuardiansRegistration) {
        return IGuardiansRegistration(contractRegistry.get("guardiansRegistration"));
    }

    function getCertificationContract() public view returns (ICertification) {
        return ICertification(contractRegistry.get("certification"));
    }

    function getStakingContract() public view returns (IStakingContract) {
        return IStakingContract(contractRegistry.get("staking"));
    }

    function getSubscriptionsContract() public view returns (ISubscriptions) {
        return ISubscriptions(contractRegistry.get("subscriptions"));
    }

    function getStakingRewardsWallet() public view returns (IProtocolWallet) {
        return IProtocolWallet(contractRegistry.get("stakingRewardsWallet"));
    }

    function getBootstrapRewardsWallet() public view returns (IProtocolWallet) {
        return IProtocolWallet(contractRegistry.get("bootstrapRewardsWallet"));
    }

}



pragma solidity 0.5.16;



contract WithClaimableFunctionalOwnership is Context{
    address private _functionalOwner;
    address pendingFunctionalOwner;

    event FunctionalOwnershipTransferred(address indexed previousFunctionalOwner, address indexed newFunctionalOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _functionalOwner = msgSender;
        emit FunctionalOwnershipTransferred(address(0), msgSender);
    }

    
    function functionalOwner() public view returns (address) {
        return _functionalOwner;
    }

    
    modifier onlyFunctionalOwner() {
        require(isFunctionalOwner(), "WithClaimableFunctionalOwnership: caller is not the functionalOwner");
        _;
    }

    
    function isFunctionalOwner() public view returns (bool) {
        return _msgSender() == _functionalOwner;
    }

    
    function renounceFunctionalOwnership() public onlyFunctionalOwner {
        emit FunctionalOwnershipTransferred(_functionalOwner, address(0));
        _functionalOwner = address(0);
    }

    
    function _transferFunctionalOwnership(address newFunctionalOwner) internal {
        require(newFunctionalOwner != address(0), "FunctionalOwner: new functionalOwner is the zero address");
        emit FunctionalOwnershipTransferred(_functionalOwner, newFunctionalOwner);
        _functionalOwner = newFunctionalOwner;
    }

    
    modifier onlyPendingFunctionalOwner() {
        require(msg.sender == pendingFunctionalOwner, "Caller is not the pending functionalOwner");
        _;
    }
    
    function transferFunctionalOwnership(address newFunctionalOwner) public onlyFunctionalOwner {
        pendingFunctionalOwner = newFunctionalOwner;
    }
    
    function claimFunctionalOwnership() external onlyPendingFunctionalOwner {
        _transferFunctionalOwnership(pendingFunctionalOwner);
        pendingFunctionalOwner = address(0);
    }
}



pragma solidity 0.5.16;





contract GuardiansRegistration is IGuardiansRegistration, ContractRegistryAccessor, WithClaimableFunctionalOwnership, Lockable {

	modifier onlyRegisteredGuardian {
		require(isRegistered(msg.sender), "Guardian is not registered");

		_;
	}

	struct Guardian {
		address orbsAddr;
		bytes4 ip;
		string name;
		string website;
		string contact;
		uint256 registrationTime;
		uint256 lastUpdateTime;
	}
	mapping (address => Guardian) public guardians;
	mapping (address => address) public orbsAddressToEthereumAddress;
	mapping (bytes4 => address) public ipToGuardian;
	mapping (address => mapping(string => string)) public guardianMetadata;

	

    
	function registerGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website, string calldata contact) external onlyWhenActive {
		require(!isRegistered(msg.sender), "registerGuardian: Guardian is already registered");

		guardians[msg.sender].registrationTime = now;
		emit GuardianRegistered(msg.sender);

		_updateGuardian(msg.sender, ip, orbsAddr, name, website, contact);

		getElectionsContract().guardianRegistered(msg.sender);
	}

    
	function updateGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website, string calldata contact) external onlyRegisteredGuardian onlyWhenActive {
		_updateGuardian(msg.sender, ip, orbsAddr, name, website, contact);
	}

	function updateGuardianIp(bytes4 ip) external onlyWhenActive {
		address guardianAddr = resolveGuardianAddress(msg.sender);
		Guardian memory data = guardians[guardianAddr];
		_updateGuardian(guardianAddr, ip, data.orbsAddr, data.name, data.website, data.contact);
	}

    
    function setMetadata(string calldata key, string calldata value) external onlyRegisteredGuardian onlyWhenActive {
		string memory oldValue = guardianMetadata[msg.sender][key];
		guardianMetadata[msg.sender][key] = value;
		emit GuardianMetadataChanged(msg.sender, key, value, oldValue);
	}

	function getMetadata(address addr, string calldata key) external view returns (string memory) {
		require(isRegistered(addr), "getMetadata: Guardian is not registered");
		return guardianMetadata[addr][key];
	}

	
	function unregisterGuardian() external onlyRegisteredGuardian onlyWhenActive {
		delete orbsAddressToEthereumAddress[guardians[msg.sender].orbsAddr];
		delete ipToGuardian[guardians[msg.sender].ip];
		delete guardians[msg.sender];

		getElectionsContract().guardianUnregistered(msg.sender);

		emit GuardianUnregistered(msg.sender);
	}

    
    
	function getGuardianData(address addr) external view returns (bytes4 ip, address orbsAddr, string memory name, string memory website, string memory contact, uint registration_time, uint last_update_time) {
		require(isRegistered(addr), "getGuardianData: Guardian is not registered");
		Guardian memory v = guardians[addr];
		return (v.ip, v.orbsAddr, v.name, v.website, v.contact, v.registrationTime, v.lastUpdateTime);
	}

	function getGuardiansOrbsAddress(address[] calldata addrs) external view returns (address[] memory orbsAddrs) {
		orbsAddrs = new address[](addrs.length);
		for (uint i = 0; i < addrs.length; i++) {
			orbsAddrs[i] = guardians[addrs[i]].orbsAddr;
		}
	}

	function getGuardianIp(address addr) external view returns (bytes4 ip) {
		require(isRegistered(addr), "getGuardianIp: Guardian is not registered");
		return guardians[addr].ip;
	}

	function getGuardianIps(address[] calldata addrs) external view returns (bytes4[] memory ips) {
		ips = new bytes4[](addrs.length);
		for (uint i = 0; i < addrs.length; i++) {
			ips[i] = guardians[addrs[i]].ip;
		}
	}

	function isRegistered(address addr) public view returns (bool) {
		return guardians[addr].registrationTime != 0;
	}

	function resolveGuardianAddress(address ethereumOrOrbsAddress) public view returns (address ethereumAddress) {
		if (isRegistered(ethereumOrOrbsAddress)) {
			ethereumAddress = ethereumOrOrbsAddress;
		} else {
			ethereumAddress = orbsAddressToEthereumAddress[ethereumOrOrbsAddress];
		}

		require(ethereumAddress != address(0), "Cannot resolve address");
	}

	

    
    
	function getOrbsAddresses(address[] calldata ethereumAddrs) external view returns (address[] memory orbsAddrs) {
		orbsAddrs = new address[](ethereumAddrs.length);
		for (uint i = 0; i < ethereumAddrs.length; i++) {
			require(isRegistered(ethereumAddrs[i]), "getOrbsAddresses: Guardian is not registered"); 
			orbsAddrs[i] = guardians[ethereumAddrs[i]].orbsAddr;
		}
	}

	
	
	function getEthereumAddresses(address[] calldata orbsAddrs) external view returns (address[] memory ethereumAddrs) {
		ethereumAddrs = new address[](orbsAddrs.length);
		for (uint i = 0; i < orbsAddrs.length; i++) {
			ethereumAddrs[i] = orbsAddressToEthereumAddress[orbsAddrs[i]];
			require(ethereumAddrs[i] != address(0), "getEthereumAddresses: Guardian is not registered"); 
		}
	}

	

	function _updateGuardian(address guardianAddr, bytes4 ip, address orbsAddr, string memory name, string memory website, string memory contact) private {
		require(orbsAddr != address(0), "orbs address must be non zero");
		require(bytes(name).length != 0, "name must be given");
		require(bytes(contact).length != 0, "contact must be given");
		

		delete ipToGuardian[guardians[guardianAddr].ip];
		require(ipToGuardian[ip] == address(0), "ip is already in use");
		ipToGuardian[ip] = guardianAddr;

		delete orbsAddressToEthereumAddress[guardians[guardianAddr].orbsAddr];
		require(orbsAddressToEthereumAddress[orbsAddr] == address(0), "orbs address is already in use");
		orbsAddressToEthereumAddress[orbsAddr] = guardianAddr;

		guardians[guardianAddr].orbsAddr = orbsAddr;
		guardians[guardianAddr].ip = ip;
		guardians[guardianAddr].name = name;
		guardians[guardianAddr].website = website;
		guardians[guardianAddr].contact = contact;
		guardians[guardianAddr].lastUpdateTime = now;

        emit GuardianDataUpdated(guardianAddr, ip, orbsAddr, name, website, contact);
    }

}