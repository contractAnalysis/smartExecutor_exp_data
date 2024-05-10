pragma solidity ^0.5.0;


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

    
    function getDocument(bytes32 name) external view returns (string memory, bytes32); 
    function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external; 
    event Document(bytes32 indexed name, string uri, bytes32 documentHash);

    
    function isControllable() external view returns (bool); 

    
    function isIssuable() external view returns (bool); 
    function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data) external; 
    event IssuedByPartition(bytes32 indexed partition, address indexed operator, address indexed to, uint256 value, bytes data, bytes operatorData);

    
    function redeemByPartition(bytes32 partition, uint256 value, bytes calldata data) external; 
    function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data, bytes calldata operatorData) external; 
    event RedeemedByPartition(bytes32 indexed partition, address indexed operator, address indexed from, uint256 value, bytes data, bytes operatorData);

    
    function canTransferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data) external view returns (byte, bytes32, bytes32); 
    function canOperatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData) external view returns (byte, bytes32, bytes32); 

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

    
    event ApprovalByPartition(bytes32 indexed partition, address indexed owner, address indexed spender, uint256 value);

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

contract ERC1820Implementer {
  bytes32 constant ERC1820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC1820_ACCEPT_MAGIC"));

  mapping(bytes32 => bool) internal _interfaceHashes;

  function canImplementInterfaceForAddress(bytes32 interfaceHash, address ) 
    external
    view
    returns(bytes32)
  {
    if(_interfaceHashes[interfaceHash]) {
      return ERC1820_ACCEPT_MAGIC;
    } else {
      return "";
    }
  }

  function _setInterface(string memory interfaceLabel) internal {
    _interfaceHashes[keccak256(abi.encodePacked(interfaceLabel))] = true;
  }

}

// CertificateController comment...
contract CertificateController {

  // If set to 'true', the certificate control is activated
  bool _certificateControllerActivated;

  // Address used by off-chain controller service to sign certificate
  mapping(address => bool) internal _certificateSigners;

  // A nonce used to ensure a certificate can be used only once
  mapping(address => uint256) internal _checkCount;

  event Checked(address sender);

  constructor(address _certificateSigner, bool activated) public {
    _setCertificateSigner(_certificateSigner, true);
    _certificateControllerActivated = activated;
  }

  /**
   * @dev Modifier to protect methods with certificate control
   */
  modifier isValidCertificate(bytes memory data) {

    if(_certificateControllerActivated) {
      require(_certificateSigners[msg.sender] || _checkCertificate(data, 0, 0x00000000), "A3"); 

      _checkCount[msg.sender] += 1; 

      emit Checked(msg.sender);
    }

    _;
  }

  
  


  
  function checkCount(address sender) external view returns (uint256) {
    return _checkCount[sender];
  }

  
  function certificateSigners(address operator) external view returns (bool) {
    return _certificateSigners[operator];
  }

  
  function _setCertificateSigner(address operator, bool authorized) internal {
    require(operator != address(0)); 
    _certificateSigners[operator] = authorized;
  }

  
  function certificateControllerActivated() external view returns (bool) {
    return _certificateControllerActivated;
  }

  
  function _setCertificateControllerActivated(bool activated) internal {
    _certificateControllerActivated = activated;
  }

  
  function _checkCertificate(
    bytes memory data,
    uint256 amount,
    bytes4 functionID
  )
    internal
    view
    returns(bool)
  {
    uint256 counter = _checkCount[msg.sender];

    uint256 e;
    bytes32 r;
    bytes32 s;
    uint8 v;

    
    if (data.length != 97) {
      return false;
    }

    
    assembly {
      
      
      e := mload(add(data, 0x20))
      r := mload(add(data, 0x40))
      s := mload(add(data, 0x60))
      v := byte(0, mload(add(data, 0x80)))
    }

    
    if (e < now) {
      return false;
    }

    if (v < 27) {
      v += 27;
    }

    
    if (v == 27 || v == 28) {
      
      bytes memory payload;

      assembly {
        let payloadsize := sub(calldatasize, 160)
        payload := mload(0x40) 
        mstore(0x40, add(payload, and(add(add(payloadsize, 0x20), 0x1f), not(0x1f)))) 
        mstore(payload, payloadsize) 
        calldatacopy(add(add(payload, 0x20), 4), 4, sub(payloadsize, 4))
      }

      if(functionID == 0x00000000) {
        assembly {
          calldatacopy(add(payload, 0x20), 0, 4)
        }
      } else {
        for (uint i = 0; i < 4; i++) { 
          payload[i] = functionID[i];
        }
      }

      
      bytes memory pack = abi.encodePacked(
        msg.sender,
        this,
        amount,
        payload,
        e,
        counter
      );
      bytes32 hash = keccak256(pack);

      
      if (_certificateSigners[ecrecover(hash, v, r, s)]) {
        return true;
      }
    }
    return false;
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
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);

  function tokensToTransfer(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;

}





interface IERC1400TokensValidator {

  function canValidate(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);

  function tokensToValidate(
    bytes4 functionSig,
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
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);

  function tokensReceived(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;

}


















contract ERC1400Raw is IERC1400Raw, Ownable, ERC1820Client, ERC1820Implementer, CertificateController {
  using SafeMath for uint256;

  string constant internal ERC1400_TOKENS_SENDER = "ERC1400TokensSender";
  string constant internal ERC1400_TOKENS_VALIDATOR = "ERC1400TokensValidator";
  string constant internal ERC1400_TOKENS_RECIPIENT = "ERC1400TokensRecipient";

  string internal _name;
  string internal _symbol;
  uint256 internal _granularity;
  uint256 internal _totalSupply;

  bool internal _migrated;

  
  bool internal _isControllable;

  
  mapping(address => uint256) internal _balances;

  
  
  mapping(address => mapping(address => bool)) internal _authorizedOperator;

  
  address[] internal _controllers;

  
  mapping(address => bool) internal _isController;
  

  
  modifier whenNotMigrated() {
      require(!_migrated, "A8");
      _;
  }

  
  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    address certificateSigner,
    bool certificateActivated
  )
    public
    CertificateController(certificateSigner, certificateActivated)
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
    _callPreTransferHooks("", msg.sender, msg.sender, to, value, data, "");

    _transferWithData(msg.sender, msg.sender, to, value, data, "");

    _callPostTransferHooks("", msg.sender, msg.sender, to, value, data, "");
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

    _callPreTransferHooks("", msg.sender, from, to, value, data, operatorData);

    _transferWithData(msg.sender, from, to, value, data, operatorData);

    _callPostTransferHooks("", msg.sender, from, to, value, data, operatorData);
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
    _callPreTransferHooks("", msg.sender, msg.sender, address(0), value, data, "");

    _redeem(msg.sender, msg.sender, value, data, "");
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

    _callPreTransferHooks("", msg.sender, from, address(0), value, data, operatorData);

    _redeem(msg.sender, from, value, data, operatorData);
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
    * @param operator The address performing the transfer.
    * @param from Token holder.
    * @param to Token recipient.
    * @param value Number of tokens to transfer.
    * @param data Information attached to the transfer.
    * @param operatorData Information attached to the transfer by the operator (if any)..
    */
  function _transferWithData(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
    whenNotMigrated
  {
    require(_isMultiple(value), "A9"); 
    require(to != address(0), "A6"); 
    require(_balances[from] >= value, "A4"); 
  
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);

    emit TransferWithData(operator, from, to, value, data, operatorData);
  }

  
  function _redeem(address operator, address from, uint256 value, bytes memory data, bytes memory operatorData)
    internal
    whenNotMigrated
  {
    require(_isMultiple(value), "A9"); 
    require(from != address(0), "A5"); 
    require(_balances[from] >= value, "A4"); 

    _balances[from] = _balances[from].sub(value);
    _totalSupply = _totalSupply.sub(value);

    emit Redeemed(operator, from, value, data, operatorData);
  }

  
  function _callPreTransferHooks(
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
    senderImplementation = interfaceAddr(from, ERC1400_TOKENS_SENDER);
    if (senderImplementation != address(0)) {
      IERC1400TokensSender(senderImplementation).tokensToTransfer(msg.sig, partition, operator, from, to, value, data, operatorData);
    }

    address validatorImplementation;
    validatorImplementation = interfaceAddr(address(this), ERC1400_TOKENS_VALIDATOR);
    if (validatorImplementation != address(0)) {
      IERC1400TokensValidator(validatorImplementation).tokensToValidate(msg.sig, partition, operator, from, to, value, data, operatorData);
    }
  }

  
  function _callPostTransferHooks(
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
    address recipientImplementation;
    recipientImplementation = interfaceAddr(to, ERC1400_TOKENS_RECIPIENT);

    if (recipientImplementation != address(0)) {
      IERC1400TokensRecipient(recipientImplementation).tokensReceived(msg.sig, partition, operator, from, to, value, data, operatorData);
    }
  }

  
  function _issue(address operator, address to, uint256 value, bytes memory data, bytes memory operatorData)
    internal
    whenNotMigrated  
  {
    require(_isMultiple(value), "A9"); 
    require(to != address(0), "A6"); 

    _totalSupply = _totalSupply.add(value);
    _balances[to] = _balances[to].add(value);

    emit Issued(operator, to, value, data, operatorData);
  }

  

  
  function _setHookContract(address validatorAddress, string memory interfaceLabel) internal {
    ERC1820Client.setInterfaceImplementation(interfaceLabel, validatorAddress);
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
  

  
  
  mapping(bytes32 => mapping (address => mapping (address => uint256))) internal _allowedByPartition;

  
  mapping (address => mapping (bytes32 => mapping (address => bool))) internal _authorizedOperatorByPartition;

  
  mapping (bytes32 => address[]) internal _controllersByPartition;

  
  mapping (bytes32 => mapping (address => bool)) internal _isControllerByPartition;
  

  
  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    address certificateSigner,
    bool certificateActivated,
    bytes32[] memory defaultPartitions
  )
    public
    ERC1400Raw(name, symbol, granularity, controllers, certificateSigner, certificateActivated)
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
    return _transferByPartition(partition, msg.sender, msg.sender, to, value, data, "");
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
    require(_isOperatorForPartition(partition, msg.sender, from)
      || (value <= _allowedByPartition[partition][from][msg.sender]), "A7"); 

    if(_allowedByPartition[partition][from][msg.sender] >= value) {
      _allowedByPartition[partition][from][msg.sender] = _allowedByPartition[partition][from][msg.sender].sub(value);
    } else {
      _allowedByPartition[partition][from][msg.sender] = 0;
    }

    return _transferByPartition(partition, msg.sender, from, to, value, data, operatorData);
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
    bytes memory operatorData
  )
    internal
    returns (bytes32)
  {
    require(_balanceOfByPartition[from][fromPartition] >= value, "A4"); 

    bytes32 toPartition = fromPartition;

    if(operatorData.length != 0 && data.length >= 64) {
      toPartition = _getDestinationPartition(fromPartition, data);
    }

    _callPreTransferHooks(fromPartition, operator, from, to, value, data, operatorData);

    _removeTokenFromPartition(from, fromPartition, value);
    _transferWithData(operator, from, to, value, data, operatorData);
    _addTokenToPartition(to, toPartition, value);

    _callPostTransferHooks(toPartition, operator, from, to, value, data, operatorData);

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

  
  function allowanceByPartition(bytes32 partition, address owner, address spender) external view returns (uint256) {
    return _allowedByPartition[partition][owner][spender];
  }

  
  function approveByPartition(bytes32 partition, address spender, uint256 value) external returns (bool) {
    require(spender != address(0), "A5"); 
    _allowedByPartition[partition][msg.sender][spender] = value;
    emit ApprovalByPartition(partition, msg.sender, spender, value);
    return true;
  }

  

  
  function transferWithData(address to, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {
    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, data, "");
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

    _transferByDefaultPartitions(msg.sender, from, to, value, data, operatorData);
  }

  
  function redeem(uint256 , bytes calldata ) external { 
    revert("A8"); 
  }

  
  function redeemFrom(address , uint256 , bytes calldata , bytes calldata ) external { 
    revert("A8"); 
  }

  
  function _transferByDefaultPartitions(
    address operator,
    address from,
    address to,
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
        _transferByPartition(_defaultPartitions[i], operator, from, to, _remainingValue, data, operatorData);
        _remainingValue = 0;
        break;
      } else if (_localBalance != 0) {
        _transferByPartition(_defaultPartitions[i], operator, from, to, _localBalance, data, operatorData);
        _remainingValue = _remainingValue - _localBalance;
      }
    }

    require(_remainingValue == 0, "A8"); 
  }
}





interface IERC1400TokensChecker {

  
  
  
  
  
  
  
  
  

  function canTransferByPartition(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes calldata data,
    bytes calldata operatorData
    ) external view returns (byte, bytes32, bytes32);

}












contract ERC1400 is IERC1400, ERC1400Partition, MinterRole {
  
  string constant internal ERC1400_INTERFACE_NAME = "ERC1400Token";
  string constant internal ERC1400_TOKENS_CHECKER = "ERC1400TokensChecker";

  struct Doc {
    string docURI;
    bytes32 docHash;
  }

  
  mapping(bytes32 => Doc) internal _documents;

  
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
    bool certificateActivated,
    bytes32[] memory defaultPartitions
  )
    public
    ERC1400Partition(name, symbol, granularity, controllers, certificateSigner, certificateActivated, defaultPartitions)
  {
    ERC1820Client.setInterfaceImplementation(ERC1400_INTERFACE_NAME, address(this));
    _isControllable = true;
    _isIssuable = true;

    ERC1820Implementer._setInterface(ERC1400_INTERFACE_NAME); 
  }

  

  
  function getDocument(bytes32 name) external view returns (string memory, bytes32) {
    require(bytes(_documents[name].docURI).length != 0); 
    return (
      _documents[name].docURI,
      _documents[name].docHash
    );
  }

  
  function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external {
    require(_isController[msg.sender]);
    _documents[name] = Doc({
      docURI: uri,
      docHash: documentHash
    });
    emit Document(name, uri, documentHash);
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
    bytes4 functionSig = this.transferByPartition.selector; 
    if(!_checkCertificate(data, 0, functionSig)) {
      return(hex"A3", "", partition); // Transfer Blocked - Sender lockup period not ended
    } else {
      return _canTransfer(functionSig, partition, msg.sender, msg.sender, to, value, data, "");
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
  function canOperatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    view
    returns (byte, bytes32, bytes32)
  {
    bytes4 functionSig = this.operatorTransferByPartition.selector; // 0x8c0dee9c: 4 first bytes of keccak256(operatorTransferByPartition(bytes32,address,address,uint256,bytes,bytes))
    if(!_checkCertificate(operatorData, 0, functionSig)) {
      return(hex"A3", "", partition); // Transfer Blocked - Sender lockup period not ended
    } else {
      return _canTransfer(functionSig, partition, msg.sender, from, to, value, data, operatorData);
    }
  }

  /********************** ERC1400 INTERNAL FUNCTIONS **************************/

  /**
   * [INTERNAL]
   * @dev Know the reason on success or failure based on the EIP-1066 application-specific status codes.
   * @param functionSig ID of the function that needs to be called.
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
   function _canTransfer(bytes4 functionSig, bytes32 partition, address operator, address from, address to, uint256 value, bytes memory data, bytes memory operatorData)
     internal
     view
     returns (byte, bytes32, bytes32)
   {
     address checksImplementation = interfaceAddr(address(this), ERC1400_TOKENS_CHECKER);

     if((checksImplementation != address(0))) {
       return IERC1400TokensChecker(checksImplementation).canTransferByPartition(functionSig, partition, operator, from, to, value, data, operatorData);
     }
     else {
       return(hex"00", "", partition);
     }
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
    _issue(operator, to, value, data, operatorData);
    _addTokenToPartition(to, toPartition, value);

    _callPostTransferHooks(toPartition, operator, address(0), to, value, data, operatorData);

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

    _callPreTransferHooks(fromPartition, operator, from, address(0), value, data, operatorData);

    _removeTokenFromPartition(from, fromPartition, value);
    _redeem(operator, from, value, data, operatorData);

    emit RedeemedByPartition(fromPartition, operator, from, value, data, operatorData);
  }

  

  
  function renounceControl() external onlyOwner {
    _isControllable = false;
  }

  
  function renounceIssuance() external onlyOwner {
    _isIssuable = false;
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

  
  function setCertificateControllerActivated(bool activated) external onlyOwner {
   _setCertificateControllerActivated(activated);
  }

  
  function setHookContract(address validatorAddress, string calldata interfaceLabel) external onlyOwner {
    ERC1400Raw._setHookContract(validatorAddress, interfaceLabel);
  }

  

  
  function migrate(address newContractAddress, bool definitive) external onlyOwner {
    _migrate(newContractAddress, definitive);
  }

  
  function _migrate(address newContractAddress, bool definitive) internal {
    ERC1820Client.setInterfaceImplementation(ERC1400_INTERFACE_NAME, newContractAddress);
    if(definitive) {
      _migrated = true;
    }
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

  string constant internal ERC20_INTERFACE_NAME = "ERC20Token";

  
  mapping (address => mapping (address => uint256)) internal _allowed;

  
  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    address certificateSigner,
    bool certificateActivated,
    bytes32[] memory defaultPartitions
  )
    public
    ERC1400(name, symbol, granularity, controllers, certificateSigner, certificateActivated, defaultPartitions)
  {
    ERC1820Client.setInterfaceImplementation(ERC20_INTERFACE_NAME, address(this));

    ERC1820Implementer._setInterface(ERC20_INTERFACE_NAME); 
  }

  
  function _transferWithData(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
  {
    ERC1400Raw._transferWithData(operator, from, to, value, data, operatorData);

    emit Transfer(from, to, value);
  }

  
  function _redeem(address operator, address from, uint256 value, bytes memory data, bytes memory operatorData) internal {
    ERC1400Raw._redeem(operator, from, value, data, operatorData);

    emit Transfer(from, address(0), value);  
  }

  
  function _issue(address operator, address to, uint256 value, bytes memory data, bytes memory operatorData) internal {
    ERC1400Raw._issue(operator, to, value, data, operatorData);

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

  
  function transfer(address to, uint256 value) external returns (bool) {
    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, "", "");
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
  function transferFrom(address from, address to, uint256 value) external returns (bool) {
    require( _isOperator(msg.sender, from)
      || (value <= _allowed[from][msg.sender]), "A7"); 

    if(_allowed[from][msg.sender] >= value) {
      _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    } else {
      _allowed[from][msg.sender] = 0;
    }

    _transferByDefaultPartitions(msg.sender, from, to, value, "", "");
    return true;
  }

  

  
  function migrate(address newContractAddress, bool definitive) external onlyOwner {
    ERC1820Client.setInterfaceImplementation(ERC20_INTERFACE_NAME, newContractAddress);
    ERC1400._migrate(newContractAddress, definitive);
  }

}