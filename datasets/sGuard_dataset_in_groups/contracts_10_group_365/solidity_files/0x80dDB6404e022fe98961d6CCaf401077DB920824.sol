pragma solidity 0.5.16;


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


contract ERC20 is IERC20 {
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
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IBorrower {
    function executeOnFlashMint(uint256 amount) external;
}




contract FlashToken is ERC20 {
    using SafeMath for uint256;

    ERC20 internal _baseToken;
    address private _factory;

    
    
    

    
    modifier initializeTemplate() {
        
        _factory = msg.sender;

        
        uint32 codeSize;
        assembly {
            codeSize := extcodesize(address)
        }
        require(codeSize == 0, "must be called within contract constructor");
        _;
    }

    
    function initialize(address baseToken) public initializeTemplate() {
        _baseToken = ERC20(baseToken);
    }

    
    
    function getFactory() public view returns (address factory) {
        return _factory;
    }

    
    
    function getBaseToken() public view returns (address baseToken) {
        return address(_baseToken);
    }

    
    
    

    
    
    
    modifier flashMint(uint256 amount) {
        
        _mint(msg.sender, amount); 

        
        _;

        
        _burn(msg.sender, amount); 

        
        require(
            _baseToken.balanceOf(address(this)) >= totalSupply(),
            "redeemability was broken"
        );
    }

    
    function deposit(uint256 amount) public {
        require(
            _baseToken.transferFrom(msg.sender, address(this), amount),
            "transfer in failed"
        );
        _mint(msg.sender, amount);
    }

    
    function withdraw(uint256 amount) public {
        _burn(msg.sender, amount); 
        require(_baseToken.transfer(msg.sender, amount), "transfer out failed");
    }

    
    function softFlashFuck(uint256 amount) public flashMint(amount) {
        
        IBorrower(msg.sender).executeOnFlashMint(amount);
    }

    
    function hardFlashFuck(
        address target,
        bytes memory targetCalldata,
        uint256 amount
    ) public flashMint(amount) {
        (bool success, ) = target.call(targetCalldata);
        require(success, "external call failed");
    }
}







contract Spawn {
  constructor(
    address logicContract,
    bytes memory initializationCalldata
  ) public payable {
    
    (bool ok, ) = logicContract.delegatecall(initializationCalldata);
    if (!ok) {
      
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    
    bytes memory runtimeCode = abi.encodePacked(
      bytes10(0x363d3d373d3d3d363d73),
      logicContract,
      bytes15(0x5af43d82803e903d91602b57fd5bf3)
    );

    
    assembly {
      return(add(0x20, runtimeCode), 45) 
    }
  }
}









contract Spawner {
  
  
  
  
  
  
  
  
  function _spawn(
    address creator,
    address logicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {

    

    bytes memory initCode;
    bytes32 initCodeHash;
    (initCode, initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);

    

    (address target, bytes32 safeSalt) = _getNextNonceTargetWithInitCodeHash(creator, initCodeHash);

    

    return _executeSpawnCreate2(initCode, safeSalt, target);
  }

  
  
  
  
  
  
  
  
  function _spawnSalty(
    address creator,
    address logicContract,
    bytes memory initializationCalldata,
    bytes32 salt
  ) internal returns (address spawnedContract) {

    

    bytes memory initCode;
    bytes32 initCodeHash;
    (initCode, initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);

    

    (address target, bytes32 safeSalt, bool validity) = _getSaltyTargetWithInitCodeHash(creator, initCodeHash, salt);
    require(validity, "contract already deployed with supplied salt");

    

    return _executeSpawnCreate2(initCode, safeSalt, target);
  }

  
  
  
  
  
  
  function _executeSpawnCreate2(bytes memory initCode, bytes32 safeSalt, address target) private returns (address spawnedContract) {
    assembly {
      let encoded_data := add(0x20, initCode) 
      let encoded_size := mload(initCode)     
      spawnedContract := create2(             
        callvalue,                            
        encoded_data,                         
        encoded_size,                         
        safeSalt                              
      )

      
      if iszero(spawnedContract) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    
    require(spawnedContract == target, "attempted deployment to unexpected address");

    
    return spawnedContract;
  }

  
  
  
  
  
  
  
  
  
  
  
  function _getSaltyTarget(
    address creator,
    address logicContract,
    bytes memory initializationCalldata,
    bytes32 salt
  ) internal view returns (address target, bool validity) {

    

    bytes32 initCodeHash;
    ( , initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);

    

    (target, , validity) = _getSaltyTargetWithInitCodeHash(creator, initCodeHash, salt);

    
    return (target, validity);
  }

  
  
  
  
  
  
  
  
  function _getSaltyTargetWithInitCodeHash(
    address creator,
    bytes32 initCodeHash,
    bytes32 salt
  ) private view returns (address target, bytes32 safeSalt, bool validity) {
    
    safeSalt = keccak256(abi.encodePacked(creator, salt));

    
    target = _computeTargetWithCodeHash(initCodeHash, safeSalt);

    
    validity = _getTargetValidity(target);

    
    return (target, safeSalt, validity);
  }

  
  
  
  
  
  
  
  
  
  function _getNextNonceTarget(
    address creator,
    address logicContract,
    bytes memory initializationCalldata
  ) internal view returns (address target) {

    

    bytes32 initCodeHash;
    ( , initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);

    

    (target, ) = _getNextNonceTargetWithInitCodeHash(creator, initCodeHash);

    
    return target;
  }

  
  
  
  
  
  
  function _getNextNonceTargetWithInitCodeHash(
    address creator,
    bytes32 initCodeHash
  ) private view returns (address target, bytes32 safeSalt) {
    
    uint256 nonce = 0;

    while (true) {
      
      safeSalt = keccak256(abi.encodePacked(creator, nonce));

      
      target = _computeTargetWithCodeHash(initCodeHash, safeSalt);

      
      
      
      if (_getTargetValidity(target))
        break;
      else
        nonce++;
    }
    
    
    return (target, safeSalt);
  }

  
  
  
  
  
  
  
  function _getInitCodeAndHash(
    address logicContract,
    bytes memory initializationCalldata
  ) private pure returns (bytes memory initCode, bytes32 initCodeHash) {
    
    initCode = abi.encodePacked(
      type(Spawn).creationCode,
      abi.encode(logicContract, initializationCalldata)
    );

    
    initCodeHash = keccak256(initCode);

    
    return (initCode, initCodeHash);
  }
  
  
  
  
  
  
  
  function _computeTargetWithCodeHash(
    bytes32 initCodeHash,
    bytes32 safeSalt
  ) private view returns (address target) {
    return address(    
      uint160(                   
        uint256(                 
          keccak256(             
            abi.encodePacked(    
              bytes1(0xff),      
              address(this),     
              safeSalt,          
              initCodeHash       
            )
          )
        )
      )
    );
  }

  
  
  
  function _getTargetValidity(address target) private view returns (bool validity) {
    
    uint256 codeSize;
    assembly { codeSize := extcodesize(target) }
    return codeSize == 0;
  }
}




contract FlashTokenFactory is Spawner {
    uint256 private _tokenCount;
    address private _templateContract;
    mapping(address => address) private _baseToFlash;
    mapping(address => address) private _flashToBase;
    mapping(uint256 => address) private _idToBase;

    event TemplateSet(address indexed templateContract);
    event FlashTokenCreated(
        address indexed token,
        address indexed flashToken,
        uint256 tokenID
    );

    
    constructor(address templateContract) public {
        _templateContract = templateContract;
        emit TemplateSet(templateContract);
    }

    
    function createFlashToken(address token)
        public
        returns (address flashToken)
    {
        require(token != address(0), "cannot wrap address 0");
        if (_baseToFlash[token] != address(0)) {
            return _baseToFlash[token];
        } else {
            require(_baseToFlash[token] == address(0), "token already wrapped");

            flashToken = _flashWrap(token);

            _baseToFlash[token] = flashToken;
            _flashToBase[flashToken] = token;
            _tokenCount += 1;
            _idToBase[_tokenCount] = token;

            emit FlashTokenCreated(token, flashToken, _tokenCount);
            return flashToken;
        }
    }

    
    function _flashWrap(address token) private returns (address flashToken) {
        FlashToken template;
        bytes memory initCalldata = abi.encodeWithSelector(
            template.initialize.selector,
            token
        );
        return Spawner._spawn(address(this), _templateContract, initCalldata);
    }

    

    
    function getFlashToken(address token)
        public
        view
        returns (address flashToken)
    {
        return _baseToFlash[token];
    }

    
    function getBaseToken(address flashToken)
        public
        view
        returns (address token)
    {
        return _flashToBase[flashToken];
    }

    
    function getBaseFromID(uint256 tokenID)
        public
        view
        returns (address token)
    {
        return _idToBase[tokenID];
    }

    
    function getTokenCount() public view returns (uint256 tokenCount) {
        return _tokenCount;
    }

}