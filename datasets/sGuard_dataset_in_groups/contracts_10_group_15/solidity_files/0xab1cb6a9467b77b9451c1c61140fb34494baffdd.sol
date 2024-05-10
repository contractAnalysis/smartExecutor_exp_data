pragma solidity ^0.4.23;



contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  
  constructor() public {
    owner = msg.sender;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}



pragma solidity ^0.4.23;



library SafeMath {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}



pragma solidity ^0.4.23;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



pragma solidity ^0.4.23;




contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



pragma solidity ^0.4.23;



contract Pausable is Ownable  {
  event Pause();
  event Unpause();

  bool public paused = false;


  
  modifier whenNotPaused() {
    require(!paused, "Is paused");
    _;
  }

  
  modifier whenPaused() {
    require(paused, "Is not paused");
    _;
  }

  
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}



pragma solidity ^0.4.23;






contract AtlantisSimpleSwapBridge is Ownable, Pausable {
    using SafeMath for uint256;

    mapping (address => bool) public supportedTokens;

    uint256 public swapCount;

    address public feeWallet;

    uint256 public feeRatio;    

    
    event TokenSwapped(
    uint256 indexed swapId, address from, bytes32 to, uint256 amount, address token, uint256 fee, uint256 srcNetwork, uint256 dstNetwork);

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);


    
    constructor (
        address _feeWallet,
        uint256 _feeRatio
    ) public
    {
        feeWallet = _feeWallet;
        feeRatio = _feeRatio;
    }

    
    
    
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public whenNotPaused {

        require(supportedTokens[_token], "Not suppoted token.");
        require(msg.sender == _token, "Invalid msg sender for this tx.");

        uint256 swapAmount;
        uint256 dstNetwork;
        bytes32 receiver;

        
        
        
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            swapAmount := mload(add(ptr, 164))
            dstNetwork := mload(add(ptr, 196))
            receiver :=  mload(add(ptr, 228))
        }

        require(swapAmount > 0, "Swap amount must be larger than zero.");

        uint256 requiredFee = querySwapFee(swapAmount);
        require(_amount >= swapAmount.add(requiredFee), "No enough of token amount are approved.");

        if(requiredFee > 0) {
            require(ERC20(_token).transferFrom(from, feeWallet, requiredFee), "Fee transfer failed.");
        }

        require(ERC20(_token).transferFrom(from, this, swapAmount), "Swap amount transfer failed.");

        emit TokenSwapped(swapCount, from, receiver, swapAmount, _token, requiredFee, 1, dstNetwork);
        
        swapCount = swapCount + 1;
    }

    function addSupportedToken(address _token) public onlyOwner {
        supportedTokens[_token] = true;
    }

    function removeSupportedToken(address _token) public onlyOwner {
        supportedTokens[_token] = false;
    }

    function changeFeeWallet(address _newFeeWallet) public onlyOwner {
        feeWallet = _newFeeWallet;
    }

    function changeFeeRatio(uint256 _feeRatio) public onlyOwner {
        feeRatio = _feeRatio;
    }

    function querySwapFee(uint256 _amount) public view returns (uint256) {
        uint256 requiredFee = feeRatio.mul(_amount).div(10000);

        return requiredFee;
    }

    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            address(msg.sender).transfer(address(this).balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(address(msg.sender), balance);

        emit ClaimedTokens(_token, address(msg.sender), balance);
    }
}