pragma solidity ^0.4.24;


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



pragma solidity 0.4.24;

interface IBridgeValidators {
    function initialize(uint256 _requiredSignatures, address[] _initialValidators, address _owner) external returns(bool);
    function isValidator(address _validator) external view returns(bool);
    function requiredSignatures() external view returns(uint256);
    function owner() external view returns(address);
}



pragma solidity 0.4.24;

interface IOwnedUpgradeabilityProxy {
    function proxyOwner() external view returns (address);
}



pragma solidity 0.4.24;


contract OwnedUpgradeability {

    function upgradeabilityAdmin() public view returns (address) {
        return IOwnedUpgradeabilityProxy(this).proxyOwner();
    }

    
    modifier onlyIfOwnerOfProxy() {
        require(msg.sender == upgradeabilityAdmin());
        _;
    }
}



pragma solidity 0.4.24;


contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;


    mapping(bytes32 => uint256[]) internal uintArrayStorage;
    mapping(bytes32 => string[]) internal stringArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
    
    mapping(bytes32 => bool[]) internal boolArrayStorage;
    mapping(bytes32 => int256[]) internal intArrayStorage;
    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;
}



pragma solidity 0.4.24;



contract EternalOwnable is EternalStorage {
    
    event EternalOwnershipTransferred(address previousOwner, address newOwner);

    
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    
    function owner() public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("owner"))];
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    
    function setOwner(address newOwner) internal {
        emit EternalOwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;
    }
}



pragma solidity ^0.4.24;


interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



pragma solidity 0.4.24;







contract BasicBridge is EternalStorage, EternalOwnable, OwnedUpgradeability {
    using SafeMath for uint256;

    event GasPriceChanged(uint256 gasPrice);
    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);
    event DailyLimitChanged(uint256 newLimit);
    event ExecutionDailyLimitChanged(uint256 newLimit);

    function getBridgeInterfacesVersion() public pure returns(uint64 major, uint64 minor, uint64 patch) {
        return (2, 2, 0);
    }

    function setGasPrice(uint256 _gasPrice) public onlyOwner {
        require(_gasPrice > 0);
        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;
        emit GasPriceChanged(_gasPrice);
    }

    function gasPrice() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("gasPrice"))];
    }

    function setRequiredBlockConfirmations(uint256 _blockConfirmations) public onlyOwner {
        require(_blockConfirmations > 0);
        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _blockConfirmations;
        emit RequiredBlockConfirmationChanged(_blockConfirmations);
    }

    function requiredBlockConfirmations() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))];
    }

    function deployedAtBlock() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))];
    }

    function setTotalSpentPerDay(uint256 _day, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))] = _value;
    }

    function totalSpentPerDay(uint256 _day) public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))];
    }

    function setTotalExecutedPerDay(uint256 _day, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))] = _value;
    }

    function totalExecutedPerDay(uint256 _day) public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))];
    }

    function minPerTx() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("minPerTx"))];
    }

    function maxPerTx() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("maxPerTx"))];
    }

    function executionMaxPerTx() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("executionMaxPerTx"))];
    }

    function setInitialize(bool _status) internal {
        boolStorage[keccak256(abi.encodePacked("isInitialized"))] = _status;
    }

    function isInitialized() public view returns(bool) {
        return boolStorage[keccak256(abi.encodePacked("isInitialized"))];
    }

    function getCurrentDay() public view returns(uint256) {
        return now / 1 days;
    }

    function setDailyLimit(uint256 _dailyLimit) public onlyOwner {
        uintStorage[keccak256(abi.encodePacked("dailyLimit"))] = _dailyLimit;
        emit DailyLimitChanged(_dailyLimit);
    }

    function dailyLimit() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("dailyLimit"))];
    }

    function setExecutionDailyLimit(uint256 _dailyLimit) public onlyOwner {
        uintStorage[keccak256(abi.encodePacked("executionDailyLimit"))] = _dailyLimit;
        emit ExecutionDailyLimitChanged(_dailyLimit);
    }

    function executionDailyLimit() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("executionDailyLimit"))];
    }

    function setExecutionMaxPerTx(uint256 _maxPerTx) external onlyOwner {
        require(_maxPerTx < executionDailyLimit());
        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx"))] = _maxPerTx;
    }

    function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {
        require(_maxPerTx < dailyLimit());
        uintStorage[keccak256(abi.encodePacked("maxPerTx"))] = _maxPerTx;
    }

    function setMinPerTx(uint256 _minPerTx) external onlyOwner {
        require(_minPerTx < dailyLimit() && _minPerTx < maxPerTx());
        uintStorage[keccak256(abi.encodePacked("minPerTx"))] = _minPerTx;
    }

    function withinLimit(uint256 _amount) public view returns(bool) {
        uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);
        return dailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();
    }

    function withinExecutionLimit(uint256 _amount) public view returns(bool) {
        uint256 nextLimit = totalExecutedPerDay(getCurrentDay()).add(_amount);
        return executionDailyLimit() >= nextLimit && _amount <= executionMaxPerTx();
    }

    function claimTokens(address _token, address _to) public onlyIfOwnerOfProxy {
        require(_to != address(0));
        if (_token == address(0)) {
            _to.transfer(address(this).balance);
            return;
        }

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(this);
        require(token.transfer(_to, balance));
    }


    function isContract(address _addr) internal view returns (bool)
    {
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }
}



pragma solidity 0.4.24;

contract ERC677Receiver {
  function onTokenTransfer(address _from, uint _value, bytes _data) external returns(bool);
}



pragma solidity 0.4.24;

interface IForeignBridgeValidators {
    function isValidator(address _validator) external view returns(bool);
    function requiredSignatures() external view returns(uint256);
    function setValidators(address[] _validators) external returns(bool);
}



pragma solidity 0.4.24;



library Message {
    function addressArrayContains(address[] array, address value) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    function parseMessage(bytes message)
        internal
        pure
        returns(address recipient, uint256 amount, bytes32 txHash, address contractAddress)
    {
        require(isMessageValid(message));
        assembly {
            recipient := and(mload(add(message, 20)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            amount := mload(add(message, 52))
            txHash := mload(add(message, 84))
            contractAddress := mload(add(message, 104))
        }
    }

    function parseNewSetMessage(bytes message)
        internal
        returns(address[] memory newSet, bytes32 txHash, uint256 blockNumber, address contractAddress)
    {
        uint256 msgLength;
        uint256 position;
        address newSetMember;
        assembly {
            msgLength := mload(message)
            txHash := mload(add(message, 32))
            blockNumber:= mload(add(message, 64))
            contractAddress := mload(add(message, 84))
            position := 104
        }
        uint256 newSetLength = (msgLength - position) / 20 + 1;
        newSet = new address[](newSetLength);
        uint256 i = 0;
        while (position <= msgLength) {
            assembly {
                newSetMember := mload(add(message, position))
            }
            newSet[i] = newSetMember;
            position += 20;
            i++;
        }
        return (newSet, txHash, blockNumber, contractAddress);
    }

    function isMessageValid(bytes _msg) internal pure returns(bool) {
        return _msg.length == requiredMessageLength();
    }

    function requiredMessageLength() internal pure returns(uint256) {
        return 104;
    }

    function recoverAddressFromSignedMessage(bytes signature, bytes message, bool knownLength) internal pure returns (address) {
        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        bytes1 v;
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        if (knownLength) {
            return ecrecover(hashMessage(message), uint8(v), r, s);
        } else {
            return ecrecover(hashMessageOfUnknownLength(message), uint8(v), r, s);
        }
    }

    function hashMessage(bytes message) internal pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        
        string memory msgLength = "104";
        return keccak256(abi.encodePacked(prefix, msgLength, message));
    }

    function hashMessageOfUnknownLength(bytes message) internal pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        uint256 lengthOffset;
        uint256 length;
        assembly {
          
          length := mload(message)
          
          lengthOffset := add(prefix, 57)
        }
        uint256 lengthLength = 0;
        
        uint256 divisor = 100000;
        
        while (divisor != 0) {
          
          uint256 digit = length / divisor;
          if (digit == 0) {
            
            if (lengthLength == 0) {
              divisor /= 10;
              continue;
            }
          }
          
          lengthLength++;
          
          length -= digit * divisor;
          
          divisor /= 10;
          
          digit += 0x30;
          
          lengthOffset++;
          assembly {
            mstore8(lengthOffset, digit)
          }
        }
        
        if (lengthLength == 0) {
          lengthLength = 1 + 0x19 + 1;
        } else {
          lengthLength += 1 + 0x19;
        }
        
        assembly {
          mstore(prefix, lengthLength)
        }
        return keccak256(prefix, message);
    }

    function hasEnoughValidSignaturesForeignBridgeValidator(
        bytes _message,
        uint8[] _vs,
        bytes32[] _rs,
        bytes32[] _ss,
        IForeignBridgeValidators _validatorContract) internal view
    {
        uint256 requiredSignatures = _validatorContract.requiredSignatures();
        require(_vs.length == _rs.length);
        require(_vs.length == _ss.length);
        require(_vs.length >= requiredSignatures);
        bytes32 hash = hashMessage(_message);
        address[] memory encounteredAddresses = new address[](requiredSignatures);
        uint256 signaturesCount;

        for (uint256 i = 0; i < _vs.length; i++) {
            address recoveredAddress = ecrecover(hash, _vs[i], _rs[i], _ss[i]);
            if(_validatorContract.isValidator(recoveredAddress)) {
                if (!addressArrayContains(encounteredAddresses, recoveredAddress)) {
                    encounteredAddresses[i] = recoveredAddress;
                    signaturesCount++;

                    if (signaturesCount == requiredSignatures) {
                        return;
                    }
                }
            }
        }
        require(signaturesCount >=requiredSignatures);
    }

    function hasEnoughValidNewSetSignaturesForeignBridgeValidator(
        bytes _message,
        uint8[] _vs,
        bytes32[] _rs,
        bytes32[] _ss,
        IForeignBridgeValidators _validatorContract) internal view
    {
        uint256 requiredSignatures = _validatorContract.requiredSignatures();
        require(_vs.length == _rs.length);
        require(_vs.length == _ss.length);
        require(_vs.length >= requiredSignatures);
        bytes32 hash = hashMessageOfUnknownLength(_message);
        address[] memory encounteredAddresses = new address[](requiredSignatures);
        uint256 signaturesCount;

        for (uint256 i = 0; i < _vs.length; i++) {
            address recoveredAddress = ecrecover(hash, _vs[i], _rs[i], _ss[i]);
            if(_validatorContract.isValidator(recoveredAddress)) {
                if (!addressArrayContains(encounteredAddresses, recoveredAddress)) {
                    encounteredAddresses[i] = recoveredAddress;
                    signaturesCount++;

                    if (signaturesCount == requiredSignatures) {
                        return;
                    }
                }
            }
        }
        require(signaturesCount >=requiredSignatures);
    }

    function recover(bytes32 hash, bytes sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        
        if (sig.length != 65) {
          return (address(0));
        }

        
        assembly {
          r := mload(add(sig, 32))
          s := mload(add(sig, 64))
          v := byte(0, mload(add(sig, 96)))
        }

        
        if (v < 27) {
          v += 27;
        }

        
        if (v != 27 && v != 28) {
          return (address(0));
        } else {
          return ecrecover(hash, v, r, s);
        }
    }
}



pragma solidity 0.4.24;




contract BasicForeignBridge is EternalStorage {
    using SafeMath for uint256;

    
    event RelayedMessage(address recipient, uint value, bytes32 transactionHash);

    function onExecuteMessage(address, uint256) internal returns(bool);

    function setRelayedMessages(bytes32 _txHash, bool _status) internal {
        boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))] = _status;
    }

    function relayedMessages(bytes32 _txHash) public view returns(bool) {
        return boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))];
    }

    function setLastRelayedBlockNumber(uint256 _blockNumber) internal {
        uintStorage[keccak256(abi.encodePacked("relayedMessagesLastBlockNumber"))] = _blockNumber;
    }

    function lastRelayedBlockNumber() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("relayedMessagesLastBlockNumber"))];
    }

    function messageWithinLimits(uint256) internal view returns(bool);

    function onFailedMessage(address, uint256, bytes32) internal;
}



pragma solidity 0.4.24;



contract ForeignValidatable is EternalStorage {
    function validatorContract() public view returns(IForeignBridgeValidators) {
        return IForeignBridgeValidators(addressStorage[keccak256(abi.encodePacked("validatorContract"))]);
    }

    modifier onlyValidator() {
        require(validatorContract().isValidator(msg.sender));
        _;
    }

    function requiredSignatures() public view returns(uint256) {
        return validatorContract().requiredSignatures();
    }
}



pragma solidity ^0.4.24;




contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    
    
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}



pragma solidity 0.4.24;


contract ERC677 is ERC20 {
    event Transfer(address indexed from, address indexed to, uint value, bytes data);

    function transferAndCall(address, uint, bytes) external returns (bool);
}



pragma solidity 0.4.24;


contract IBurnableMintableERC677Token is ERC677 {
    function mint(address, uint256) public returns (bool);
    function burn(uint256 _value) public;
    function claimTokens(address _token, address _to) public;
}



pragma solidity 0.4.24;



contract ERC677Bridge is BasicBridge {
    function erc677token() public view returns(IBurnableMintableERC677Token) {
        return IBurnableMintableERC677Token(addressStorage[keccak256(abi.encodePacked("erc677token"))]);
    }

    function setErc677token(address _token) internal {
        require(_token != address(0) && isContract(_token));
        addressStorage[keccak256(abi.encodePacked("erc677token"))] = _token;
    }

    function onTokenTransfer(address _from, uint256 _value, bytes _data) external returns(bool) {
        require(msg.sender == address(erc677token()));
        require(withinLimit(_value));
        setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(_value));
        if (!boolStorage[keccak256(abi.encodePacked("erc677tokenPreMinted"))]) {
            erc677token().burn(_value);
        }
        fireEventOnTokenTransfer(_from, _value, _data);
        return true;
    }

    function fireEventOnTokenTransfer(address , uint256 , bytes ) internal {
        
    }
}



pragma solidity 0.4.24;







contract ForeignBridgeNativeToErc is ERC677Receiver, BasicBridge, BasicForeignBridge, ERC677Bridge, ForeignValidatable {

    
    event UserRequestForAffirmation(address recipient, uint256 value);

    event RelayedNewSetMessage(address[] newSet, bytes32 transactionHash);

    function initialize(
        address _validatorContract,
        address _erc677token,
        uint256 _dailyLimit,
        uint256 _maxPerTx,
        uint256 _minPerTx,
        uint256 _foreignGasPrice,
        uint256 _requiredBlockConfirmations,
        uint256 _homeDailyLimit,
        uint256 _homeMaxPerTx,
        address _owner,
        bool _erc677tokenPreMinted
    ) public returns(bool) {
        require(!isInitialized());
        require(_validatorContract != address(0) && isContract(_validatorContract));
        require(_minPerTx > 0 && _maxPerTx > _minPerTx && _dailyLimit > _maxPerTx);
        require(_foreignGasPrice > 0);
        require(_homeMaxPerTx < _homeDailyLimit);
        require(_owner != address(0));
        addressStorage[keccak256(abi.encodePacked("validatorContract"))] = _validatorContract;
        setErc677token(_erc677token);
        uintStorage[keccak256(abi.encodePacked("dailyLimit"))] = _dailyLimit;
        uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))] = block.number;
        uintStorage[keccak256(abi.encodePacked("maxPerTx"))] = _maxPerTx;
        uintStorage[keccak256(abi.encodePacked("minPerTx"))] = _minPerTx;
        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _foreignGasPrice;
        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _requiredBlockConfirmations;
        uintStorage[keccak256(abi.encodePacked("executionDailyLimit"))] = _homeDailyLimit;
        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx"))] = _homeMaxPerTx;
        boolStorage[keccak256(abi.encodePacked("erc677tokenPreMinted"))] = _erc677tokenPreMinted;
        setOwner(_owner);
        setInitialize(true);
        return isInitialized();
    }

    function getBridgeMode() public pure returns(bytes4 _data) {
        return bytes4(keccak256(abi.encodePacked("native-to-erc-core")));
    }

    function claimTokensFromErc677(address _token, address _to) external onlyIfOwnerOfProxy {
        erc677token().claimTokens(_token, _to);
    }

    function executeSignatures(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) external {
        require(Message.isMessageValid(message));
        Message.hasEnoughValidSignaturesForeignBridgeValidator(message, vs, rs, ss, validatorContract());
        address recipient;
        uint256 amount;
        bytes32 txHash;
        address contractAddress;
        (recipient, amount, txHash, contractAddress) = Message.parseMessage(message);
        if (messageWithinLimits(amount)) {
            require(contractAddress == address(this));
            require(!relayedMessages(txHash));
            setRelayedMessages(txHash, true);
            require(onExecuteMessage(recipient, amount));
            emit RelayedMessage(recipient, amount, txHash);
        } else {
            onFailedMessage(recipient, amount, txHash);
        }
    }

    function executeNewSetSignatures(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) external {
        Message.hasEnoughValidNewSetSignaturesForeignBridgeValidator(message, vs, rs, ss, validatorContract());
        address[] memory newSet;
        bytes32 txHash;
        uint256 blockNumber;
        address contractAddress;
        (newSet, txHash, blockNumber, contractAddress) = Message.parseNewSetMessage(message);
        require(contractAddress == address(this));
        require(!relayedMessages(txHash));
        require(blockNumber > lastRelayedBlockNumber());
        setRelayedMessages(txHash, true);
        setLastRelayedBlockNumber(blockNumber);
        require(validatorContract().setValidators(newSet));
        emit RelayedNewSetMessage(newSet, txHash);
    }

    function onExecuteMessage(address _recipient, uint256 _amount) internal returns(bool){
        if (_recipient == address(this)) {
            return erc677token().mint(_recipient, _amount);
        }
        setTotalExecutedPerDay(getCurrentDay(), totalExecutedPerDay(getCurrentDay()).add(_amount));
        if (boolStorage[keccak256(abi.encodePacked("erc677tokenPreMinted"))]) {
            return erc677token().transfer(_recipient, _amount);
        }
        return erc677token().mint(_recipient, _amount);
    }

    function fireEventOnTokenTransfer(address _from, uint256 _value, bytes ) internal {
        emit UserRequestForAffirmation(_from, _value);
    }

    function messageWithinLimits(uint256 _amount) internal view returns(bool) {
        return withinExecutionLimit(_amount);
    }

    function onFailedMessage(address, uint256, bytes32) internal {
        revert();
    }
}