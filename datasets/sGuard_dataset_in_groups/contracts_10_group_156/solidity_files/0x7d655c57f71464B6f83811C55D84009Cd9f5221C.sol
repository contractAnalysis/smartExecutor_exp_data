pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;


contract ReentrancyGuard {
  bool private _notEntered;

  constructor() internal {
    
    
    
    
    
    
    _notEntered = true;
  }

  
  modifier nonReentrant() {
    
    require(_notEntered, "ReentrancyGuard: reentrant call");

    
    _notEntered = false;

    _;

    
    
    _notEntered = true;
  }
}


contract Context {
  
  
  constructor() internal {}

  function _msgSender() internal virtual view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal virtual view returns (bytes memory) {
    this; 
    return msg.data;
  }
}


contract Pausable is Context {
  
  event Paused(address account);

  
  event Unpaused(address account);

  bool private _paused;

  
  constructor() internal {
    _paused = false;
  }

  
  function paused() public view returns (bool) {
    return _paused;
  }

  
  modifier whenNotPaused() {
    require(!_paused, "Pausable: paused");
    _;
  }

  
  modifier whenPaused() {
    require(_paused, "Pausable: not paused");
    _;
  }

  
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}


contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
  constructor() internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


interface IERC20 {
  
  function totalSupply() external view returns (uint256);

  
  function balanceOf(address account) external view returns (uint256);

  
  function transfer(address recipient, uint256 amount) external returns (bool);

  
  function allowance(address owner, address spender) external view returns (uint256);

  
  function approve(address spender, uint256 amount) external returns (bool);

  
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  
  event Transfer(address indexed from, address indexed to, uint256 value);

  
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {
  
  function isContract(address account) internal view returns (bool) {
    
    
    
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    
    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
}


library SafeMath {
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
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
    return div(a, b, "SafeMath: division by zero");
  }

  
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    
    require(b > 0, errorMessage);
    uint256 c = a / b;
    

    return c;
  }

  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}


library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    
    
    
    
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).sub(
      value,
      "SafeERC20: decreased allowance below zero"
    );
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    
    

    
    
    
    
    
    require(address(token).isContract(), "SafeERC20: call to non-contract");

    
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, "SafeERC20: low-level call failed");

    if (returndata.length > 0) {
      
      
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}


contract BulkCheckout is Ownable, Pausable, ReentrancyGuard {
  using Address for address payable;
  using SafeMath for uint256;
  
  address constant ETH_TOKEN_PLACHOLDER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  
  struct Donation {
    address token; 
    uint256 amount; 
    address payable dest; 
  }

  
  event DonationSent(
    address indexed token,
    uint256 indexed amount,
    address dest,
    address indexed donor
  );

  
  event TokenWithdrawn(address indexed token, uint256 indexed amount, address indexed dest);

  
  function donate(Donation[] calldata _donations) external payable nonReentrant whenNotPaused {
    
    uint256 _ethDonationTotal = 0;

    for (uint256 i = 0; i < _donations.length; i++) {
      emit DonationSent(_donations[i].token, _donations[i].amount, _donations[i].dest, msg.sender);
      if (_donations[i].token != ETH_TOKEN_PLACHOLDER) {
        
        
        SafeERC20.safeTransferFrom(
          IERC20(_donations[i].token),
          msg.sender,
          _donations[i].dest,
          _donations[i].amount
        );
      } else {
        
        
        _donations[i].dest.sendValue(_donations[i].amount);
        _ethDonationTotal = _ethDonationTotal.add(_donations[i].amount);
      }
    }

    
    require(msg.value == _ethDonationTotal, "BulkCheckout: Too much ETH sent");
  }

  
  function withdrawToken(address _tokenAddress, address _dest) external onlyOwner {
    uint256 _balance = IERC20(_tokenAddress).balanceOf(address(this));
    emit TokenWithdrawn(_tokenAddress, _balance, _dest);
    SafeERC20.safeTransfer(IERC20(_tokenAddress), _dest, _balance);
  }

  
  function withdrawEther(address payable _dest) external onlyOwner {
    uint256 _balance = address(this).balance;
    emit TokenWithdrawn(ETH_TOKEN_PLACHOLDER, _balance, _dest);
    _dest.sendValue(_balance);
  }

  
  function pause() external onlyOwner whenNotPaused {
    _pause();
  }

  
  function unpause() external onlyOwner whenPaused {
    _unpause();
  }
}