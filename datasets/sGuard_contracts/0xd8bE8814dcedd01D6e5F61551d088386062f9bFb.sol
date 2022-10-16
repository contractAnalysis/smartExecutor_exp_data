pragma solidity ^0.5.0;




library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
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

contract ValidatorManagerContract {
    using SafeMath for uint256;

    
    
    uint8 public threshold_num;
    uint8 public threshold_denom;

    
    address[] public validators;

    
    uint64[] public powers;

    
    uint256 public totalPower;

    
    
    uint256 public nonce;

    
    address public loomAddress;

    
    
    
    event ValidatorSetChanged(address[] _validators, uint64[] _powers);

    
    
    
    function getPowers() public view returns(uint64[] memory) {
        return powers;
    }

    
    
    
    function getValidators() public view returns(address[] memory) {
        return validators;
    }

    
    
    
    
    
    
    
    
    constructor (
        address[] memory _validators,
        uint64[] memory _powers,
        uint8 _threshold_num,
        uint8 _threshold_denom,
        address _loomAddress
    ) 
        public 
    {
        threshold_num = _threshold_num;
        threshold_denom = _threshold_denom;
        require(threshold_num <= threshold_denom && threshold_num > 0, "Invalid threshold fraction.");
        loomAddress = _loomAddress;
        _rotateValidators(_validators, _powers);
    }

    
    
    
    
    
    
    
    
    function setLoom(
        address _loomAddress,
        uint256[] calldata _signersIndexes, 
        uint8[] calldata _v,
        bytes32[] calldata _r,
        bytes32[] calldata _s
    ) 
        external 
    {
        
        
        bytes32 message = createMessage(
            keccak256(abi.encodePacked(_loomAddress))
        );

        
        checkThreshold(message, _signersIndexes, _v, _r, _s);

        
        loomAddress = _loomAddress;
        nonce++;
    }

    
    
    
    
    
    
    
    
    
    
    function setQuorum(
        uint8 _num,
        uint8 _denom,
        uint256[] calldata _signersIndexes, 
        uint8[] calldata _v,
        bytes32[] calldata _r,
        bytes32[] calldata _s
    ) 
        external 
    {
        require(_num <= _denom && _num > 0, "Invalid threshold fraction");

        
        
        bytes32 message = createMessage(
            keccak256(abi.encodePacked(_num, _denom))
        );

        
        checkThreshold(message, _signersIndexes, _v, _r, _s);

        threshold_num = _num;
        threshold_denom = _denom;
        nonce++;
    }

    
    
    
    
    
    
    
    
    
    
    function rotateValidators(
        address[] calldata _newValidators, 
        uint64[] calldata  _newPowers,
        uint256[] calldata _signersIndexes, 
        uint8[] calldata _v,
        bytes32[] calldata _r,
        bytes32[] calldata _s
    ) 
        external 
    {
        
        
        bytes32 message = createMessage(
            keccak256(abi.encodePacked(_newValidators,_newPowers))
        );

        
        checkThreshold(message, _signersIndexes, _v, _r, _s);

        
        _rotateValidators(_newValidators, _newPowers);
        nonce++;
    }


    
    
    
    
    
    
    
    function signedByValidator(
        bytes32 _message,
        uint256 _signersIndex,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) 
        public 
        view
    {
        
        
        
        
        address signer = ecrecover(_message, _v, _r, _s);
        require(validators[_signersIndex] == signer, "Message not signed by a validator");
    }

    
    
    
    
    
    
    
    function checkThreshold(bytes32 _message, uint256[] memory _signersIndexes, uint8[] memory _v, bytes32[] memory _r, bytes32[] memory _s) public view {
        uint256 sig_length = _v.length;

        require(sig_length <= validators.length,
                "checkThreshold:: Cannot submit more signatures than existing validators"
        );

        require(sig_length > 0 && sig_length == _r.length && _r.length == _s.length && sig_length == _signersIndexes.length,
                "checkThreshold:: Incorrect number of params"
        );

        
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _message));

        
        
        uint256 votedPower;
        for (uint256 i = 0; i < sig_length; i++) {
            if (i > 0) {
                require(_signersIndexes[i] > _signersIndexes[i-1]);
            }

            
            if (uint256(_s[i]) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
                continue;
            }
            address signer = ecrecover(hash, _v[i], _r[i], _s[i]);
            require(signer == validators[_signersIndexes[i]], "checkThreshold:: Recovered address is not a validator");

            votedPower = votedPower.add(powers[_signersIndexes[i]]);
        }

        require(votedPower * threshold_denom >= totalPower *
                threshold_num, "checkThreshold:: Not enough power from validators");
    }



    
    
    
    
    function _rotateValidators(address[] memory _validators, uint64[] memory _powers) internal {
        uint256 val_length = _validators.length;

        require(val_length == _powers.length, "_rotateValidators: Array lengths do not match!");

        require(val_length > 0, "Must provide more than 0 validators");

        uint256 _totalPower = 0;
        for (uint256 i = 0; i < val_length; i++) {
            _totalPower = _totalPower.add(_powers[i]);
        }

        
        totalPower = _totalPower;

        
        validators = _validators;
        powers = _powers;

        emit ValidatorSetChanged(_validators, _powers);
    }

    
    
    
    
    function createMessage(bytes32 hash)
    private
    view returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                nonce,
                hash
            )
        );
    }

}


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


contract IERC20GatewayMintable is ERC20 {
    
    
    
    function mintTo(address _to, uint256 _amount) public;
}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ERC20Gateway {
    using SafeERC20 for IERC20;

  
  
  
  
  
  event TokenWithdrawn(address indexed owner, TokenKind kind, address contractAddress, uint256 value);

  
  
  
  
  event LoomCoinReceived(address indexed from, uint256 amount, address loomCoinAddress);

  
  
  
  
  event ERC20Received(address from, uint256 amount, address contractAddress);

  
  address public loomAddress;

  
  bool isGatewayEnabled;

  
  bool allowAnyToken;
  mapping (address => bool) public allowedTokens;

  
  address public owner;

  function getOwner() public view returns(address) {
    return owner;
  }

  function getAllowAnyToken() public view returns(bool) {
    return allowAnyToken;
  }

  
  mapping (address => uint256) public nonces;

  
  ValidatorManagerContract public vmc;

  
  
  enum TokenKind {
    ETH,
    ERC20,
    ERC721,
    ERC721X,
    LoomCoin
  }

  
  
  constructor(ValidatorManagerContract _vmc) public {
    vmc = _vmc;
    loomAddress = vmc.loomAddress();
    owner = msg.sender;
    isGatewayEnabled = true; 
    allowAnyToken = true; 
  }

  
  
  
  
  
  
  
  
  
  
  
  function withdrawERC20(
      uint256 amount,
      address contractAddress,
      uint256[] calldata _signersIndexes,
      uint8[] calldata _v,
      bytes32[] calldata _r,
      bytes32[] calldata _s
  )
    gatewayEnabled
    external
  {
    bytes32 message = createMessageWithdraw(
            "\x10Withdraw ERC20:\n",
            keccak256(abi.encodePacked(amount, contractAddress))
    );

    
    vmc.checkThreshold(message, _signersIndexes, _v, _r, _s);

    
    nonces[msg.sender]++;

    uint256 bal = IERC20(contractAddress).balanceOf(address(this));
    if (bal < amount) {
      IERC20GatewayMintable(contractAddress).mintTo(address(this), amount - bal);
    }
    IERC20(contractAddress).safeTransfer(msg.sender, amount);
    
    emit TokenWithdrawn(msg.sender, contractAddress == loomAddress ? TokenKind.LoomCoin : TokenKind.ERC20, contractAddress, amount);
  }

  
  
  function depositERC20(uint256 amount, address contractAddress) gatewayEnabled external {
    IERC20(contractAddress).safeTransferFrom(msg.sender, address(this), amount);

    emit ERC20Received(msg.sender, amount, contractAddress);
    if (contractAddress == loomAddress) {
        emit LoomCoinReceived(msg.sender, amount, contractAddress);
    }
  }

  function getERC20(address contractAddress) external view returns (uint256) {
      return IERC20(contractAddress).balanceOf(address(this));
  }

    
    
    
    
  function createMessageWithdraw(string memory prefix, bytes32 hash)
    internal
    view
    returns (bytes32)
  {
    return keccak256(
      abi.encodePacked(
        prefix,
        msg.sender,
        nonces[msg.sender],
        address(this),
        hash
      )
    );
  }

  modifier gatewayEnabled() {
    require(isGatewayEnabled, "Gateway is disabled.");
    _;
  }

  
  
  function enableGateway(bool enable) public {
    require(msg.sender == owner, "enableGateway: only owner can enable or disable gateway");
    isGatewayEnabled = enable;
  }

  
  
  function getGatewayEnabled() public view returns(bool) {
    return isGatewayEnabled;
  }

  
  
  
  function isTokenAllowed(address tokenAddress) public view returns(bool) {
    return allowAnyToken || allowedTokens[tokenAddress];
  }

  
  
  
  function toggleAllowAnyToken(bool allow) public {
    require(msg.sender == owner, "toggleAllowAnyToken: only owner can toggle");
    allowAnyToken = allow;
  }

  
  
  
  
  function toggleAllowToken(address tokenAddress, bool allow) public {
    require(msg.sender == owner, "toggleAllowToken: only owner can toggle");
    allowedTokens[tokenAddress] = allow;
  }

}