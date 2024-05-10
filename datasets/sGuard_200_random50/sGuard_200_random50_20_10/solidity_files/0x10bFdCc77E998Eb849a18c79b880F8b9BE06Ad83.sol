pragma solidity 0.5.16;

interface IContractRegistry {

	event ContractAddressUpdated(string contractName, address addr);

	
	function set(string calldata contractName, address addr) external ;

	
	function get(string calldata contractName) external view returns (address);
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




contract ContractRegistry is IContractRegistry, WithClaimableMigrationOwnership, WithClaimableFunctionalOwnership {

	mapping (string => address) contracts;

	function set(string calldata contractName, address addr) external onlyFunctionalOwner {
		contracts[contractName] = addr;
		emit ContractAddressUpdated(contractName, addr);
	}

	function get(string calldata contractName) external view returns (address) {
		address addr = contracts[contractName];
		require(addr != address(0), "the contract name is not registered");
		return addr;
	}
}