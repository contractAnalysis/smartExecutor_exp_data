pragma solidity 0.5.15;



interface IWhitelist
{
  
  function detectTransferRestriction(
    address from,
    address to,
    uint value
  ) external view
    returns (uint8);

  
  function messageForTransferRestriction(
    uint8 restrictionCode
  ) external pure
    returns (string memory);

  
  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external;
}



pragma solidity >=0.4.24 <0.6.0;



contract Initializable {

  
  bool private initialized;

  
  bool private initializing;

  
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
    
    
    
    
    
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}



pragma solidity ^0.5.0;



contract Context is Initializable {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.5.0;




contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}



pragma solidity 0.5.15;




contract Whitelist is IWhitelist, Ownable
{
  
  event Approve(address indexed _trader, bool _isApproved);

  mapping(address => bool) public approved;
  address public dat;

  
  function initialize(
    address _dat
  ) public
  {
    Ownable.initialize(msg.sender);
    dat = _dat;

    
    approved[address(0)] = true;
  }

  function detectTransferRestriction(
    address _from,
    address _to,
    uint 
  ) public view returns(uint8)
  {
    if(approved[_from] && approved[_to])
    {
      
      return 0;
    }

    
    return 1;
  }

  function messageForTransferRestriction(
    uint8 _restrictionCode
  ) external pure
    returns (string memory)
  {
    if(_restrictionCode == 0)
    {
      return "SUCCESS";
    }
    if(_restrictionCode == 1)
    {
      return "DENIED";
    }
    return "UNKNOWN_ERROR";
  }

  
  function approve(
    address _trader,
    bool _isApproved
  ) external onlyOwner
  {
    approved[_trader] = _isApproved;
    emit Approve(_trader, _isApproved);
  }

  
  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external
  {
    require(dat == msg.sender, "CALL_VIA_DAT_ONLY");
    require(detectTransferRestriction(_from, _to, _value) == 0, "TRANSFER_DENIED");
    
  }
}