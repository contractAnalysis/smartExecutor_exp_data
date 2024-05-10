pragma solidity ^0.5.12;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
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





interface IERC1400  {

    
    
    
    
    
    
    

    
    function isControllable() external view returns (bool); 

    
    function isIssuable() external view returns (bool); 
    function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data) external; 
    event IssuedByPartition(bytes32 indexed partition, address indexed operator, address indexed to, uint256 value, bytes data, bytes operatorData);

    
    function redeemByPartition(bytes32 partition, uint256 value, bytes calldata data) external; 
    function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data, bytes calldata operatorData) external; 
    event RedeemedByPartition(bytes32 indexed partition, address indexed operator, address indexed from, uint256 value, bytes data, bytes operatorData);

    
    function canTransferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data) external view returns (byte, bytes32, bytes32); 
    
    

}







interface IERC1400Partition {

    
    function balanceOfByPartition(bytes32 partition, address tokenHolder) external view returns (uint256); 
    function partitionsOf(address tokenHolder) external view returns (bytes32[] memory); 

    
    function transferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data) external returns (bytes32); 
    function operatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData) external returns (bytes32); 

    
    function getDefaultPartitions() external view returns (bytes32[] memory); 
    function setDefaultPartitions(bytes32[] calldata partitions) external; 

    
    function controllersByPartition(bytes32 partition) external view returns (address[] memory); 
    function authorizeOperatorByPartition(bytes32 partition, address operator) external; 
    function revokeOperatorByPartition(bytes32 partition, address operator) external; 
    function isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) external view returns (bool); 

    
    event TransferByPartition(
        bytes32 indexed fromPartition,
        address operator,
        address indexed from,
        address indexed to,
        uint256 value,
        bytes data,
        bytes operatorData
    );

    event ChangedPartition(
        bytes32 indexed fromPartition,
        bytes32 indexed toPartition,
        uint256 value
    );

    
    event AuthorizedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);
    event RevokedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);

}


library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
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


contract ReentrancyGuard {
    
    uint256 private _guardCounter;

    constructor () internal {
        
        
        _guardCounter = 1;
    }

    
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

contract ERC1820Registry {
    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;
    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address);
    function setManager(address _addr, address _newManager) external;
    function getManager(address _addr) public view returns (address);
}



contract ERC1820Client {
    ERC1820Registry constant ERC1820REGISTRY = ERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    function setInterfaceImplementation(string memory _interfaceLabel, address _implementation) internal {
        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        ERC1820REGISTRY.setInterfaceImplementer(address(this), interfaceHash, _implementation);
    }

    function interfaceAddr(address addr, string memory _interfaceLabel) internal view returns(address) {
        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        return ERC1820REGISTRY.getInterfaceImplementer(addr, interfaceHash);
    }

    function delegateManagement(address _newManager) internal {
        ERC1820REGISTRY.setManager(address(this), _newManager);
    }
}

contract CertificateController {

  
  mapping(address => bool) internal _certificateSigners;

  
  mapping(address => uint256) internal _checkCount;

  event Checked(address sender);

  constructor(address _certificateSigner) public {
    _setCertificateSigner(_certificateSigner, true);
  }

  
  modifier isValidCertificate(bytes memory data) {

    require(_certificateSigners[msg.sender] || _checkCertificate(data, msg.sig, bytes32(_checkCount[msg.sender])), "A3: Transfer Blocked - Sender lockup period not ended");

    _checkCount[msg.sender] += 1; 

    emit Checked(msg.sender);
    _;
  }

  
  function checkCount(address sender) external view returns (uint256) {
    return _checkCount[sender];
  }

  
  function certificateSigners(address operator) external view returns (bool) {
    return _certificateSigners[operator];
  }

  
  function _setCertificateSigner(address operator, bool authorized) internal {
    require(operator != address(0), "Action Blocked - Not a valid address");
    _certificateSigners[operator] = authorized;
  }

  
   function _checkCertificate(bytes memory signature, bytes4 function_id, bytes32 nonce) internal view returns(bool) {
       require(signature.length == 65, "A valid signature containing (v, r, s) is needed.");

       
       bytes32 tmp_hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", function_id, nonce));
       uint8 v = uint8(signature[0]);
       bytes32 r = bytes32(0);
       bytes32 s = bytes32(0);

       
       
       assembly {
            r := mload(add(signature, 0x21))
            s := mload(add(signature, 0x41))
       }
       assert(r != bytes32(0) && s != bytes32(0));

       
       if (v != 27 && v != 28) {
           return false;
       }

       
       if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
           return false;
       }

       return _certificateSigners[ecrecover(tmp_hash, v, r, s)];
   }
}





interface IERC1400Raw {

  function name() external view returns (string memory); 
  function symbol() external view returns (string memory); 
  function totalSupply() external view returns (uint256); 
  function balanceOf(address owner) external view returns (uint256); 
  function granularity() external view returns (uint256); 

  function controllers() external view returns (address[] memory); 
  function authorizeOperator(address operator) external; 
  function revokeOperator(address operator) external; 
  function isOperator(address operator, address tokenHolder) external view returns (bool); 

  function transferWithData(address to, uint256 value, bytes calldata data) external; 
  function transferFromWithData(address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData) external; 

  function redeem(uint256 value, bytes calldata data) external; 
  function redeemFrom(address from, uint256 value, bytes calldata data, bytes calldata operatorData) external; 

  event TransferWithData(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256 value,
    bytes data,
    bytes operatorData
  );
  event Issued(address indexed operator, address indexed to, uint256 value, bytes data, bytes operatorData);
  event Redeemed(address indexed operator, address indexed from, uint256 value, bytes data, bytes operatorData);
  event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
  event RevokedOperator(address indexed operator, address indexed tokenHolder);

}





interface IERC1400TokensSender {

  function canTransfer(
    bytes32 partition,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);

  function tokensToTransfer(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;

}





interface IERC1400TokensRecipient {

  function canReceive(
    bytes32 partition,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);

  function tokensReceived(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;

}

















contract ERC1400Raw is IERC1400Raw, Ownable, ERC1820Client, CertificateController, ReentrancyGuard {
  using SafeMath for uint256;

  string internal _name;
  string internal _symbol;
  uint256 internal _granularity;
  uint256 internal _totalSupply;

  
  bool internal _isControllable;

  
  mapping(address => uint256) internal _balances;

  
  
  mapping(address => mapping(address => bool)) internal _authorizedOperator;

  
  address[] internal _controllers;

  
  mapping(address => bool) internal _isController;
  

  
  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    address certificateSigner
  )
    public
    CertificateController(certificateSigner)
  {
    _name = name;
    _symbol = symbol;
    _totalSupply = 0;
    require(granularity >= 1); 
    _granularity = granularity;

    _setControllers(controllers);
  }

  

  
  function name() external view returns(string memory) {
    return _name;
  }

  
  function symbol() external view returns(string memory) {
    return _symbol;
  }

  
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  
  function balanceOf(address tokenHolder) external view returns (uint256) {
    return _balances[tokenHolder];
  }

  
  function granularity() external view returns(uint256) {
    return _granularity;
  }

  
  function controllers() external view returns (address[] memory) {
    return _controllers;
  }

  
  function authorizeOperator(address operator) external {
    require(operator != msg.sender);
    _authorizedOperator[operator][msg.sender] = true;
    emit AuthorizedOperator(operator, msg.sender);
  }

  
  function revokeOperator(address operator) external {
    require(operator != msg.sender);
    _authorizedOperator[operator][msg.sender] = false;
    emit RevokedOperator(operator, msg.sender);
  }

  
  function isOperator(address operator, address tokenHolder) external view returns (bool) {
    return _isOperator(operator, tokenHolder);
  }

  
  function transferWithData(address to, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {
    _transferWithData("", msg.sender, msg.sender, to, value, data, "", true);
  }

  /**
   * [ERC1400Raw INTERFACE (11/13)]
   * @dev Transfer the amount of tokens on behalf of the address 'from' to the address 'to'.
   * @param from Token holder (or 'address(0)' to set from to 'msg.sender').
   * @param to Token recipient.
   * @param value Number of tokens to transfer.
   * @param data Information attached to the transfer, and intended for the token holder ('from').
   * @param operatorData Information attached to the transfer by the operator. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   */
  function transferFromWithData(address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    isValidCertificate(operatorData)
  {
    require(_isOperator(msg.sender, from), "A7"); 

    _transferWithData("", msg.sender, from, to, value, data, operatorData, true);
  }

  /**
   * [ERC1400Raw INTERFACE (12/13)]
   * @dev Redeem the amount of tokens from the address 'msg.sender'.
   * @param value Number of tokens to redeem.
   * @param data Information attached to the redemption, by the token holder. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   */
  function redeem(uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {
    _redeem("", msg.sender, msg.sender, value, data, "");
  }

  /**
   * [ERC1400Raw INTERFACE (13/13)]
   * @dev Redeem the amount of tokens on behalf of the address from.
   * @param from Token holder whose tokens will be redeemed (or address(0) to set from to msg.sender).
   * @param value Number of tokens to redeem.
   * @param data Information attached to the redemption.
   * @param operatorData Information attached to the redemption, by the operator. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   */
  function redeemFrom(address from, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    isValidCertificate(operatorData)
  {
    require(_isOperator(msg.sender, from), "A7"); 

    _redeem("", msg.sender, from, value, data, operatorData);
  }

  /********************** ERC1400Raw INTERNAL FUNCTIONS ***************************/

  /**
   * [INTERNAL]
   * @dev Check if 'value' is multiple of the granularity.
   * @param value The quantity that want's to be checked.
   * @return 'true' if 'value' is a multiple of the granularity.
   */
  function _isMultiple(uint256 value) internal view returns(bool) {
    return(value.div(_granularity).mul(_granularity) == value);
  }

  /**
   * [INTERNAL]
   * @dev Check whether an address is a regular address or not.
   * @param addr Address of the contract that has to be checked.
   * @return 'true' if 'addr' is a regular address (not a contract).
   */
  function _isRegularAddress(address addr) internal view returns(bool) {
    if (addr == address(0)) { return false; }
    uint size;
    assembly { size := extcodesize(addr) } // solhint-disable-line no-inline-assembly
    return size == 0;
  }

  /**
   * [INTERNAL]
   * @dev Indicate whether the operator address is an operator of the tokenHolder address.
   * @param operator Address which may be an operator of 'tokenHolder'.
   * @param tokenHolder Address of a token holder which may have the 'operator' address as an operator.
   * @return 'true' if 'operator' is an operator of 'tokenHolder' and 'false' otherwise.
   */
  function _isOperator(address operator, address tokenHolder) internal view returns (bool) {
    return (operator == tokenHolder
      || _authorizedOperator[operator][tokenHolder]
      || (_isControllable && _isController[operator])
    );
  }

   /**
    * [INTERNAL]
    * @dev Perform the transfer of tokens.
    * @param partition Name of the partition (bytes32 to be left empty for ERC1400Raw transfer).
    * @param operator The address performing the transfer.
    * @param from Token holder.
    * @param to Token recipient.
    * @param value Number of tokens to transfer.
    * @param data Information attached to the transfer.
    * @param operatorData Information attached to the transfer by the operator (if any)..
    * @param preventLocking 'true' if you want this function to throw when tokens are sent to a contract not
    * implementing 'erc777tokenHolder'.
    * ERC1400Raw native transfer functions MUST set this parameter to 'true', and backwards compatible ERC20 transfer
    * functions SHOULD set this parameter to 'false'.
    */
  function _transferWithData(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData,
    bool preventLocking
  )
    internal
    nonReentrant
  {
    require(_isMultiple(value), "A9"); 
    require(to != address(0), "A6"); 
    require(_balances[from] >= value, "A4"); 

    _callSender(partition, operator, from, to, value, data, operatorData);

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);

    _callRecipient(partition, operator, from, to, value, data, operatorData, preventLocking);

    emit TransferWithData(operator, from, to, value, data, operatorData);
  }

  
  function _redeem(bytes32 partition, address operator, address from, uint256 value, bytes memory data, bytes memory operatorData)
    internal
    nonReentrant
  {
    require(_isMultiple(value), "A9"); 
    require(from != address(0), "A5"); 
    require(_balances[from] >= value, "A4"); 

    _callSender(partition, operator, from, address(0), value, data, operatorData);

    _balances[from] = _balances[from].sub(value);
    _totalSupply = _totalSupply.sub(value);

    emit Redeemed(operator, from, value, data, operatorData);
  }

  
  function _callSender(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
  {
    address senderImplementation;
    senderImplementation = interfaceAddr(from, "ERC1400TokensSender");

    if (senderImplementation != address(0)) {
      IERC1400TokensSender(senderImplementation).tokensToTransfer(partition, operator, from, to, value, data, operatorData);
    }
  }

  
  function _callRecipient(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData,
    bool preventLocking
  )
    internal
  {
    address recipientImplementation;
    recipientImplementation = interfaceAddr(to, "ERC1400TokensRecipient");

    if (recipientImplementation != address(0)) {
      IERC1400TokensRecipient(recipientImplementation).tokensReceived(partition, operator, from, to, value, data, operatorData);
    } else if (preventLocking) {
      require(_isRegularAddress(to), "A6"); 
    }
  }

  
  function _issue(bytes32 partition, address operator, address to, uint256 value, bytes memory data, bytes memory operatorData) internal nonReentrant {
    require(_isMultiple(value), "A9"); 
    require(to != address(0), "A6"); 

    _totalSupply = _totalSupply.add(value);
    _balances[to] = _balances[to].add(value);

    _callRecipient(partition, operator, address(0), to, value, data, operatorData, true);

    emit Issued(operator, to, value, data, operatorData);
  }

  

  
  function _setControllers(address[] memory operators) internal {
    for (uint i = 0; i<_controllers.length; i++){
      _isController[_controllers[i]] = false;
    }
    for (uint j = 0; j<operators.length; j++){
      _isController[operators[j]] = true;
    }
    _controllers = operators;
  }

}









contract ERC1400Partition is IERC1400Partition, ERC1400Raw {

  
  
  bytes32[] internal _totalPartitions;

  
  mapping (bytes32 => uint256) internal _indexOfTotalPartitions;

  
  mapping (bytes32 => uint256) internal _totalSupplyByPartition;

  
  mapping (address => bytes32[]) internal _partitionsOf;

  
  mapping (address => mapping (bytes32 => uint256)) internal _indexOfPartitionsOf;

  
  mapping (address => mapping (bytes32 => uint256)) internal _balanceOfByPartition;

  
  bytes32[] internal _defaultPartitions;
  

  
  
  mapping (address => mapping (bytes32 => mapping (address => bool))) internal _authorizedOperatorByPartition;

  
  mapping (bytes32 => address[]) internal _controllersByPartition;

  
  mapping (bytes32 => mapping (address => bool)) internal _isControllerByPartition;
  

  
  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    address certificateSigner,
    bytes32[] memory defaultPartitions
  )
    public
    ERC1400Raw(name, symbol, granularity, controllers, certificateSigner)
  {
    _defaultPartitions = defaultPartitions;
  }

  

  
  function balanceOfByPartition(bytes32 partition, address tokenHolder) external view returns (uint256) {
    return _balanceOfByPartition[tokenHolder][partition];
  }

  
  function partitionsOf(address tokenHolder) external view returns (bytes32[] memory) {
    return _partitionsOf[tokenHolder];
  }

  
  function transferByPartition(
    bytes32 partition,
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    isValidCertificate(data)
    returns (bytes32)
  {
    return _transferByPartition(partition, msg.sender, msg.sender, to, value, data, "", true);
  }

  /**
   * [ERC1400Partition INTERFACE (4/10)]
   * @dev Transfer tokens from a specific partition through an operator.
   * @param partition Name of the partition.
   * @param from Token holder.
   * @param to Token recipient.
   * @param value Number of tokens to transfer.
   * @param data Information attached to the transfer. [CAN CONTAIN THE DESTINATION PARTITION]
   * @param operatorData Information attached to the transfer, by the operator. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   * @return Destination partition.
   */
  function operatorTransferByPartition(
    bytes32 partition,
    address from,
    address to,
    uint256 value,
    bytes calldata data,
    bytes calldata operatorData
  )
    external
    isValidCertificate(operatorData)
    returns (bytes32)
  {
    require(_isOperatorForPartition(partition, msg.sender, from), "A7"); 

    return _transferByPartition(partition, msg.sender, from, to, value, data, operatorData, true);
  }

  
  function getDefaultPartitions() external view returns (bytes32[] memory) {
    return _defaultPartitions;
  }

  
  function setDefaultPartitions(bytes32[] calldata partitions) external onlyOwner {
    _defaultPartitions = partitions;
  }

  
  function controllersByPartition(bytes32 partition) external view returns (address[] memory) {
    return _controllersByPartition[partition];
  }

  
  function authorizeOperatorByPartition(bytes32 partition, address operator) external {
    _authorizedOperatorByPartition[msg.sender][partition][operator] = true;
    emit AuthorizedOperatorByPartition(partition, operator, msg.sender);
  }

  
  function revokeOperatorByPartition(bytes32 partition, address operator) external {
    _authorizedOperatorByPartition[msg.sender][partition][operator] = false;
    emit RevokedOperatorByPartition(partition, operator, msg.sender);
  }

  
  function isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) external view returns (bool) {
    return _isOperatorForPartition(partition, operator, tokenHolder);
  }

  

  
   function _isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) internal view returns (bool) {
     return (_isOperator(operator, tokenHolder)
       || _authorizedOperatorByPartition[tokenHolder][partition][operator]
       || (_isControllable && _isControllerByPartition[partition][operator])
     );
   }

  
  function _transferByPartition(
    bytes32 fromPartition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData,
    bool preventLocking
  )
    internal
    returns (bytes32)
  {
    require(_balanceOfByPartition[from][fromPartition] >= value, "A4"); 

    bytes32 toPartition = fromPartition;

    if(operatorData.length != 0 && data.length >= 64) {
      toPartition = _getDestinationPartition(fromPartition, data);
    }

    _removeTokenFromPartition(from, fromPartition, value);
    _transferWithData(fromPartition, operator, from, to, value, data, operatorData, preventLocking);
    _addTokenToPartition(to, toPartition, value);

    emit TransferByPartition(fromPartition, operator, from, to, value, data, operatorData);

    if(toPartition != fromPartition) {
      emit ChangedPartition(fromPartition, toPartition, value);
    }

    return toPartition;
  }

  
  function _removeTokenFromPartition(address from, bytes32 partition, uint256 value) internal {
    _balanceOfByPartition[from][partition] = _balanceOfByPartition[from][partition].sub(value);
    _totalSupplyByPartition[partition] = _totalSupplyByPartition[partition].sub(value);

    
    if(_totalSupplyByPartition[partition] == 0) {
      uint256 index1 = _indexOfTotalPartitions[partition];
      require(index1 > 0, "A8"); 

      
      bytes32 lastValue = _totalPartitions[_totalPartitions.length - 1];
      _totalPartitions[index1 - 1] = lastValue; 
      _indexOfTotalPartitions[lastValue] = index1;

      _totalPartitions.length -= 1;
      _indexOfTotalPartitions[partition] = 0;
    }

    
    if(_balanceOfByPartition[from][partition] == 0) {
      uint256 index2 = _indexOfPartitionsOf[from][partition];
      require(index2 > 0, "A8"); 

      
      bytes32 lastValue = _partitionsOf[from][_partitionsOf[from].length - 1];
      _partitionsOf[from][index2 - 1] = lastValue;  
      _indexOfPartitionsOf[from][lastValue] = index2;

      _partitionsOf[from].length -= 1;
      _indexOfPartitionsOf[from][partition] = 0;
    }

  }

  
  function _addTokenToPartition(address to, bytes32 partition, uint256 value) internal {
    if(value != 0) {
      if (_indexOfPartitionsOf[to][partition] == 0) {
        _partitionsOf[to].push(partition);
        _indexOfPartitionsOf[to][partition] = _partitionsOf[to].length;
      }
      _balanceOfByPartition[to][partition] = _balanceOfByPartition[to][partition].add(value);

      if (_indexOfTotalPartitions[partition] == 0) {
        _totalPartitions.push(partition);
        _indexOfTotalPartitions[partition] = _totalPartitions.length;
      }
      _totalSupplyByPartition[partition] = _totalSupplyByPartition[partition].add(value);
    }
  }

  
  function _getDestinationPartition(bytes32 fromPartition, bytes memory data) internal pure returns(bytes32 toPartition) {
    bytes32 changePartitionFlag = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    bytes32 flag;
    assembly {
      flag := mload(add(data, 32))
    }
    if(flag == changePartitionFlag) {
      assembly {
        toPartition := mload(add(data, 64))
      }
    } else {
      toPartition = fromPartition;
    }
  }

  

  
  function totalPartitions() external view returns (bytes32[] memory) {
    return _totalPartitions;
  }

  
   function _setPartitionControllers(bytes32 partition, address[] memory operators) internal {
     for (uint i = 0; i<_controllersByPartition[partition].length; i++){
       _isControllerByPartition[partition][_controllersByPartition[partition][i]] = false;
     }
     for (uint j = 0; j<operators.length; j++){
       _isControllerByPartition[partition][operators[j]] = true;
     }
     _controllersByPartition[partition] = operators;
   }

  

  
  function transferWithData(address to, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {
    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, data, "", true);
  }

  /**
   * [NOT MANDATORY FOR ERC1400Partition STANDARD][OVERRIDES ERC1400Raw METHOD]
   * @dev Transfer the value of tokens on behalf of the address from to the address to.
   * @param from Token holder (or 'address(0)'' to set from to 'msg.sender').
   * @param to Token recipient.
   * @param value Number of tokens to transfer.
   * @param data Information attached to the transfer, and intended for the token holder ('from'). [CAN CONTAIN THE DESTINATION PARTITION]
   * @param operatorData Information attached to the transfer by the operator. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   */
  function transferFromWithData(address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    isValidCertificate(operatorData)
  {
    require(_isOperator(msg.sender, from), "A7"); 

    _transferByDefaultPartitions(msg.sender, from, to, value, data, operatorData, true);
  }

  
  function redeem(uint256 , bytes calldata ) external { 
    revert("A8: Transfer Blocked - Token restriction");
  }

  
  function redeemFrom(address , uint256 , bytes calldata , bytes calldata ) external { 
    revert("A8: Transfer Blocked - Token restriction");
  }

  
  function _transferByDefaultPartitions(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData,
    bool preventLocking
  )
    internal
  {
    require(_defaultPartitions.length != 0, "A8"); 

    uint256 _remainingValue = value;
    uint256 _localBalance;

    for (uint i = 0; i < _defaultPartitions.length; i++) {
      _localBalance = _balanceOfByPartition[from][_defaultPartitions[i]];
      if(_remainingValue <= _localBalance) {
        _transferByPartition(_defaultPartitions[i], operator, from, to, _remainingValue, data, operatorData, preventLocking);
        _remainingValue = 0;
        break;
      } else if (_localBalance != 0) {
        _transferByPartition(_defaultPartitions[i], operator, from, to, _localBalance, data, operatorData, preventLocking);
        _remainingValue = _remainingValue - _localBalance;
      }
    }

    require(_remainingValue == 0, "A8"); 
  }
}











contract ERC1400 is IERC1400, ERC1400Partition, MinterRole {

  
  

  
  
  

  
  bool internal _isIssuable;

  
  modifier issuableToken() {
    require(_isIssuable, "A8"); 
    _;
  }

  
  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    address certificateSigner,
    bytes32[] memory defaultPartitions
  )
    public
    ERC1400Partition(name, symbol, granularity, controllers, certificateSigner, defaultPartitions)
  {
    setInterfaceImplementation("ERC1400Token", address(this));
    _isControllable = true;
    _isIssuable = true;
  }

  

  
   
  

  
   
  

  
  function isControllable() external view returns (bool) {
    return _isControllable;
  }

  
  function isIssuable() external view returns (bool) {
    return _isIssuable;
  }

  
  function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data)
    external
    onlyMinter
    issuableToken
    isValidCertificate(data)
  {
    _issueByPartition(partition, msg.sender, tokenHolder, value, data, "");
  }

  /**
   * [ERC1400 INTERFACE (6/9)]
   * @dev Redeem tokens of a specific partition.
   * @param partition Name of the partition.
   * @param value Number of tokens redeemed.
   * @param data Information attached to the redemption, by the redeemer. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   */
  function redeemByPartition(bytes32 partition, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {
    _redeemByPartition(partition, msg.sender, msg.sender, value, data, "");
  }

  /**
   * [ERC1400 INTERFACE (7/9)]
   * @dev Redeem tokens of a specific partition.
   * @param partition Name of the partition.
   * @param tokenHolder Address for which we want to redeem tokens.
   * @param value Number of tokens redeemed.
   * @param data Information attached to the redemption.
   * @param operatorData Information attached to the redemption, by the operator. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   */
  function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    isValidCertificate(operatorData)
  {
    require(_isOperatorForPartition(partition, msg.sender, tokenHolder), "A7"); 

    _redeemByPartition(partition, msg.sender, tokenHolder, value, data, operatorData);
  }

  
  function canTransferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data)
    external
    view
    returns (byte, bytes32, bytes32)
  {
    
    if (!_certificateSigners[msg.sender] && !_checkCertificate(data, 0xf3d490db, bytes32(_checkCount[msg.sender]))) { 
      return(hex"A3", "", partition); // Transfer Blocked - Sender lockup period not ended
    } else {
      return _canTransfer(partition, msg.sender, msg.sender, to, value, data, "");
    }
  }

  /**
   * [ERC1400 INTERFACE (9/9)]
   * @dev Know the reason on success or failure based on the EIP-1066 application-specific status codes.
   * @param partition Name of the partition.
   * @param from Token holder.
   * @param to Token recipient.
   * @param value Number of tokens to transfer.
   * @param data Information attached to the transfer. [CAN CONTAIN THE DESTINATION PARTITION]
   * @param operatorData Information attached to the transfer, by the operator. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   * @return ESC (Ethereum Status Code) following the EIP-1066 standard.
   * @return Additional bytes32 parameter that can be used to define
   * application specific reason codes with additional details (for example the
   * transfer restriction rule responsible for making the transfer operation invalid).
   * @return Destination partition.
   */
   // @leonod commented to save opcodes
  /*function canOperatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    view
    returns (byte, bytes32, bytes32)
  {
     @see https://github.com/LeonodTeam/ERC1400
  }*/

  /********************** ERC1400 INTERNAL FUNCTIONS **************************/

  /**
   * [INTERNAL]
   * @dev Know the reason on success or failure based on the EIP-1066 application-specific status codes.
   * @param partition Name of the partition.
   * @param operator The address performing the transfer.
   * @param from Token holder.
   * @param to Token recipient.
   * @param value Number of tokens to transfer.
   * @param data Information attached to the transfer. [CAN CONTAIN THE DESTINATION PARTITION]
   * @param operatorData Information attached to the transfer, by the operator (if any).
   * @return ESC (Ethereum Status Code) following the EIP-1066 standard.
   * @return Additional bytes32 parameter that can be used to define
   * application specific reason codes with additional details (for example the
   * transfer restriction rule responsible for making the transfer operation invalid).
   * @return Destination partition.
   */
   function _canTransfer(bytes32 partition, address operator, address from, address to, uint256 value, bytes memory data, bytes memory operatorData)
     internal
     view
     returns (byte, bytes32, bytes32)
   {
     if(!_isOperatorForPartition(partition, operator, from))
       return(hex"A7", "", partition); // "Transfer Blocked - Identity restriction"

     if((_balances[from] < value) || (_balanceOfByPartition[from][partition] < value))
       return(hex"A4", "", partition); // Transfer Blocked - Sender balance insufficient

     if(to == address(0))
       return(hex"A6", "", partition); // Transfer Blocked - Receiver not eligible

     address senderImplementation;
     address recipientImplementation;
     senderImplementation = interfaceAddr(from, "ERC1400TokensSender");
     recipientImplementation = interfaceAddr(to, "ERC1400TokensRecipient");

     if((senderImplementation != address(0))
       && !IERC1400TokensSender(senderImplementation).canTransfer(partition, from, to, value, data, operatorData))
       return(hex"A5", "", partition); // Transfer Blocked - Sender not eligible

     if((recipientImplementation != address(0))
       && !IERC1400TokensRecipient(recipientImplementation).canReceive(partition, from, to, value, data, operatorData))
       return(hex"A6", "", partition); // Transfer Blocked - Receiver not eligible

     if(!_isMultiple(value))
       return(hex"A9", "", partition); // Transfer Blocked - Token granularity

     return(hex"A2", "", partition);  // Transfer Verified - Off-Chain approval for restricted token
   }

  /**
   * [INTERNAL]
   * @dev Issue tokens from a specific partition.
   * @param toPartition Name of the partition.
   * @param operator The address performing the issuance.
   * @param to Token recipient.
   * @param value Number of tokens to issue.
   * @param data Information attached to the issuance.
   * @param operatorData Information attached to the issuance, by the operator (if any).
   */
  function _issueByPartition(
    bytes32 toPartition,
    address operator,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
  {
    _issue(toPartition, operator, to, value, data, operatorData);
    _addTokenToPartition(to, toPartition, value);

    emit IssuedByPartition(toPartition, operator, to, value, data, operatorData);
  }

  /**
   * [INTERNAL]
   * @dev Redeem tokens of a specific partition.
   * @param fromPartition Name of the partition.
   * @param operator The address performing the redemption.
   * @param from Token holder whose tokens will be redeemed.
   * @param value Number of tokens to redeem.
   * @param data Information attached to the redemption.
   * @param operatorData Information attached to the redemption, by the operator (if any).
   */
  function _redeemByPartition(
    bytes32 fromPartition,
    address operator,
    address from,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
  {
    require(_balanceOfByPartition[from][fromPartition] >= value, "A4"); 

    _removeTokenFromPartition(from, fromPartition, value);
    _redeem(fromPartition, operator, from, value, data, operatorData);

    emit RedeemedByPartition(fromPartition, operator, from, value, data, operatorData);
  }

  

  
   
  

  
   
  

  
  function setControllers(address[] calldata operators) external onlyOwner {
    _setControllers(operators);
  }

  
   function setPartitionControllers(bytes32 partition, address[] calldata operators) external onlyOwner {
     _setPartitionControllers(partition, operators);
   }

   
  function setCertificateSigner(address operator, bool authorized) external onlyOwner {
    _setCertificateSigner(operator, authorized);
  }

  


  
  function redeem(uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {
    _redeemByDefaultPartitions(msg.sender, msg.sender, value, data, "");
  }

  /**
   * [NOT MANDATORY FOR ERC1400 STANDARD][OVERRIDES ERC1400Partition METHOD]
   * @dev Redeem the value of tokens on behalf of the address 'from'.
   * @param from Token holder whose tokens will be redeemed (or 'address(0)' to set from to 'msg.sender').
   * @param value Number of tokens to redeem.
   * @param data Information attached to the redemption.
   * @param operatorData Information attached to the redemption, by the operator. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   */
  function redeemFrom(address from, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    isValidCertificate(operatorData)
  {
    require(_isOperator(msg.sender, from), "A7"); 

    _redeemByDefaultPartitions(msg.sender, from, value, data, operatorData);
  }

  
  function _redeemByDefaultPartitions(
    address operator,
    address from,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
  {
    require(_defaultPartitions.length != 0, "A8"); 

    uint256 _remainingValue = value;
    uint256 _localBalance;

    for (uint i = 0; i < _defaultPartitions.length; i++) {
      _localBalance = _balanceOfByPartition[from][_defaultPartitions[i]];
      if(_remainingValue <= _localBalance) {
        _redeemByPartition(_defaultPartitions[i], operator, from, _remainingValue, data, operatorData);
        _remainingValue = 0;
        break;
      } else {
        _redeemByPartition(_defaultPartitions[i], operator, from, _localBalance, data, operatorData);
        _remainingValue = _remainingValue - _localBalance;
      }
    }

    require(_remainingValue == 0, "A8"); 
  }

}










contract ERC1400ERC20 is IERC20, ERC1400 {

  
  mapping (address => mapping (address => uint256)) internal _allowed;

  
  mapping (address => bool) internal _whitelisted;

  
  modifier areWhitelisted(address sender, address recipient) {
    require(_whitelisted[sender], "A5"); 
    require(_whitelisted[recipient], "A6"); 
    _;
  }

  
  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    address certificateSigner,
    bytes32[] memory tokenDefaultPartitions
  )
    public
    ERC1400(name, symbol, granularity, controllers, certificateSigner, tokenDefaultPartitions)
  {
    setInterfaceImplementation("ERC20Token", address(this));
  }

  
  function _transferWithData(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData,
    bool preventLocking
  )
    internal
  {
    ERC1400Raw._transferWithData(partition, operator, from, to, value, data, operatorData, preventLocking);

    emit Transfer(from, to, value);
  }

  
  function _redeem(bytes32 partition, address operator, address from, uint256 value, bytes memory data, bytes memory operatorData) internal {
    ERC1400Raw._redeem(partition, operator, from, value, data, operatorData);

    emit Transfer(from, address(0), value);  
  }

  
  function _issue(bytes32 partition, address operator, address to, uint256 value, bytes memory data, bytes memory operatorData) internal {
    ERC1400Raw._issue(partition, operator, to, value, data, operatorData);

    emit Transfer(address(0), to, value); 
  }

  
  function decimals() external pure returns(uint8) {
    return uint8(18);
  }

  
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowed[owner][spender];
  }

  
  function approve(address spender, uint256 value) external returns (bool) {
    require(spender != address(0), "A5"); 
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  
  function transfer(address to, uint256 value) external areWhitelisted(msg.sender, to) returns (bool) {
    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, "", "", false);
    return true;
  }

  /**
   * [NOT MANDATORY FOR ERC1400 STANDARD]
   * @dev Transfer tokens from one address to another.
   * @param from The address which you want to transfer tokens from.
   * @param to The address which you want to transfer to.
   * @param value The amount of tokens to be transferred.
   * @return A boolean that indicates if the operation was successful.
   */
  function transferFrom(address from, address to, uint256 value) external areWhitelisted(from, to) returns (bool) {
    require( _isOperator(msg.sender, from)
      || (value <= _allowed[from][msg.sender]), "A7"); 

    if(_allowed[from][msg.sender] >= value) {
      _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    } else {
      _allowed[from][msg.sender] = 0;
    }

    _transferByDefaultPartitions(msg.sender, from, to, value, "", "", false);
    return true;
  }

  /***************** ERC1400ERC20 OPTIONAL FUNCTIONS ***************************/

  /**
   * [NOT MANDATORY FOR ERC1400ERC20 STANDARD]
   * @dev Get whitelisted status for a tokenHolder.
   * @param tokenHolder Address whom to check the whitelisted status for.
   * @return bool 'true' if tokenHolder is whitelisted, 'false' if not.
   */
  function whitelisted(address tokenHolder) external view returns (bool) {
    return _whitelisted[tokenHolder];
  }

  /**
   * [NOT MANDATORY FOR ERC1400ERC20 STANDARD]
   * @dev Set whitelisted status for a tokenHolder.
   * @param tokenHolder Address to add/remove from whitelist.
   * @param authorized 'true' if tokenHolder shall be added to whitelist, 'false' if not.
   */
  function setWhitelisted(address tokenHolder, bool authorized) external {
    require(_isController[msg.sender]);
    _setWhitelisted(tokenHolder, authorized);
  }

  /**
   * [NOT MANDATORY FOR ERC1400ERC20 STANDARD]
   * @dev Set whitelisted status for a tokenHolder.
   * @param tokenHolder Address to add/remove from whitelist.
   * @param authorized 'true' if tokenHolder shall be added to whitelist, 'false' if not.
   */
  function _setWhitelisted(address tokenHolder, bool authorized) internal {
    require(tokenHolder != address(0)); // Action Blocked - Not a valid address
    _whitelisted[tokenHolder] = authorized;
  }

}

/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */




/**
 * @title ERC1400
 * @dev ERC1400 logic
 */
contract MWT is ERC1400ERC20 {

  // Some actions might need the actors to be whitelisted in the future
  bool needWhitelisting = false;

  /**
  * [ERC1400ERC20 CONSTRUCTOR]
  * @dev Initialize ERC71400ERC20 and CertificateController parameters + register
  * the contract implementation in ERC1820Registry.
  * @param name Name of the token.
  * @param symbol Symbol of the token.
  * @param granularity Granularity of the token.
  * @param controllers Array of initial controllers.
  * @param certificateSigner Address of the off-chain service which signs the
  * conditional ownership certificates required for token transfers, issuance,
  * redemption (Cf. CertificateController.sol).
  */
  constructor(
      string memory name,
      string memory symbol,
      uint256 granularity,
      address[] memory controllers,
      address certificateSigner,
      bytes32[] memory tokenDefaultPartitions
  )
      public
      ERC1400ERC20(name, symbol, granularity, controllers, certificateSigner, tokenDefaultPartitions)
  {
  }

  /**
   * @dev Add this to a function that might reequire involved actors to be whitelisted in the future
   */
  modifier mayNeedWhitelisting(address sender, address recipient) {
    if (needWhitelisting) {
      require(_whitelisted[sender], "A5"); 
      require(_whitelisted[recipient], "A6"); 
    }
    _;
  }

  
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "A8"); 
    require(recipient != address(0), "A8"); 
    require(_defaultPartitions.length != 0, "A8"); 

    bytes32 perpetualPartition = _defaultPartitions[0];

    require(_balanceOfByPartition[sender][perpetualPartition] >= amount, "A4"); 

    _removeTokenFromPartition(sender, perpetualPartition, amount);
    _transferWithData(perpetualPartition, sender, sender, recipient, amount, "", "", false);
    _addTokenToPartition(recipient, perpetualPartition, amount);
  }

  
  function setNeedWhitelisting(bool needWhitelist) external onlyOwner {
    needWhitelisting = needWhitelist;
  }

  
  function balanceOf(address tokenHolder) external view returns (uint256) {
    bytes32 perpetualPartition = _defaultPartitions[0];
    return _balanceOfByPartition[tokenHolder][perpetualPartition];
  }

  
  function transfer(address to, uint256 value) external mayNeedWhitelisting(msg.sender, to) returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  
  function removeMinter(address minter) external onlyOwner {
    _removeMinter(minter);
  }

  
  function addMinter(address account) public onlyOwner {
    _addMinter(account);
  }

  
  function needWhitelist() external view returns (bool) {
    return needWhitelisting;
  }
}