pragma solidity 0.6.2;

interface ICompliance {

    
    event TokenAgentAdded(address _agentAddress);

    
    event TokenAgentRemoved(address _agentAddress);

    
    event TokenBound(address _token);

    
    event TokenUnbound(address _token);

    
    function isTokenAgent(address _agentAddress) external view returns (bool);

    
    function isTokenBound(address _token) external view returns (bool);

    
    function addTokenAgent(address _agentAddress) external;

    
    function removeTokenAgent(address _agentAddress) external;

    
    function bindToken(address _token) external;

    
    function unbindToken(address _token) external;


   
    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool);

   
    function transferred(address _from, address _to, uint256 _amount) external;

   
    function created(address _to, uint256 _amount) external;

   
    function destroyed(address _from, uint256 _amount) external;

   
    function transferOwnershipOnComplianceContract(address newOwner) external;
}



pragma solidity ^0.6.0;


contract Context {
    
    
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity 0.6.2;



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() external view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





pragma solidity 0.6.2;



contract DefaultCompliance is ICompliance, Ownable {

    
    mapping(address => bool) private _tokenAgentsList;

    
    mapping(address => bool) private _tokensBound;

    
    function isTokenAgent(address _agentAddress) public override view returns (bool) {
        return (_tokenAgentsList[_agentAddress]);
    }

    
    function isTokenBound(address _token) public override view returns (bool) {
        return (_tokensBound[_token]);
    }

    
    function addTokenAgent(address _agentAddress) external override onlyOwner {
        require(!_tokenAgentsList[_agentAddress], "This Agent is already registered");
        _tokenAgentsList[_agentAddress] = true;
        emit TokenAgentAdded(_agentAddress);
    }

    
    function removeTokenAgent(address _agentAddress) external override onlyOwner {
        require(_tokenAgentsList[_agentAddress], "This Agent is not registered yet");
        _tokenAgentsList[_agentAddress] = false;
        emit TokenAgentRemoved(_agentAddress);
    }

    
    function bindToken(address _token) external override onlyOwner {
        require(!_tokensBound[_token], "This token is already bound");
        _tokensBound[_token] = true;
        emit TokenBound(_token);
    }

    
    function unbindToken(address _token) external override onlyOwner {
        require(_tokensBound[_token], "This token is not bound yet");
        _tokensBound[_token] = false;
        emit TokenUnbound(_token);
    }

   
    function canTransfer(address _from, address _to, uint256 _value) external override view returns (bool) {
        return true;
    }

   
    function transferred(address _from, address _to, uint256 _value) external override {

    }

   
    function created(address _to, uint256 _value) external override {

    }

   
    function destroyed(address _from, uint256 _value) external override {

    }

   
    function transferOwnershipOnComplianceContract(address newOwner) external override onlyOwner {
        transferOwnership(newOwner);
    }
}