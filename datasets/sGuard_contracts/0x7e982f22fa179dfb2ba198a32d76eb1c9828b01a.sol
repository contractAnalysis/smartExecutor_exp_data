pragma solidity ^0.4.25;

contract MigtyJackContract {
    address deployer = address(0x4B18fB98461a1F46edFd866c0adb7802C29A6FE5);
    
    bool destroyed = false;
    
    
    string public UDID;
    
    
    string public EncrytedMessage;
    
    
    string[] public OnwersEmail;
    string[] public OnwersId;
    
    uint8 public OnwersNumber;
    
    modifier onlyDeployer() {
        require(msg.sender == deployer);
        _;
    }
    
    modifier isValid() {
        require(!destroyed);
        _;
    }
    
    function migtyJaxxAddress() public view returns(address){
        return deployer;
    }
    
    function smartContractStatus() public view returns(bool){
        return !destroyed;
    }
    
    
    function MigtyJackContract (string _UDID, string _encryptedMessage, string _ownerEmail, string _ownerId) public{
        UDID = _UDID;
        EncrytedMessage = _encryptedMessage;
        OnwersEmail.push(_ownerEmail);
        OnwersId.push(_ownerId);
        OnwersNumber = 1;
    }
    
    
    function AppendOwner (string _ownerEmail, string _ownerId) isValid() onlyDeployer() public {
        OnwersEmail.push(_ownerEmail);
        OnwersId.push(_ownerId);
        OnwersNumber += 1;
    }
    
    
    function changeOwnerAddress(address _newOwer) isValid() onlyDeployer() public {
        require(deployer != _newOwer);
        deployer = _newOwer;
    }
    
    
    function destroy() isValid() onlyDeployer() public {
        destroyed = true;
    }

    
    
}