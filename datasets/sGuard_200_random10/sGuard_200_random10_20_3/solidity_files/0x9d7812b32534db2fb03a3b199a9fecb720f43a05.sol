pragma solidity 0.5.12;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    
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

contract StaticCheckCheezeWizards is Ownable {

    
    
    address cheezeWizardTournamentAddress;

    
    
    address openSeaAdminAddress;

    constructor (address _cheezeWizardTournamentAddress, address _openSeaAdminAddress) public {
        cheezeWizardTournamentAddress = _cheezeWizardTournamentAddress;
        openSeaAdminAddress = _openSeaAdminAddress;
    }

    function succeedIfCurrentWizardFingerprintMatchesProvidedWizardFingerprint(uint256 _wizardId, bytes32 _fingerprint, bool checkTxOrigin) public view {
        require(_fingerprint == IBasicTournament(cheezeWizardTournamentAddress).wizardFingerprint(_wizardId));
        if(checkTxOrigin){
            require(openSeaAdminAddress == tx.origin);
        }
    }

    function changeTournamentAddress(address _newTournamentAddress) external onlyOwner {
        cheezeWizardTournamentAddress = _newTournamentAddress;
    }

    function changeOpenSeaAdminAddress(address _newOpenSeaAdminAddress) external onlyOwner {
        openSeaAdminAddress = _newOpenSeaAdminAddress;
    }
}

contract IBasicTournament {
    function wizardFingerprint(uint256 wizardId) external view returns (bytes32);
}