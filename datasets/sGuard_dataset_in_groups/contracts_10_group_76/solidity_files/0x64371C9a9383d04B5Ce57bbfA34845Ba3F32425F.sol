pragma solidity ^0.6.12;

interface IOracle {
    function getData() external view returns (uint256, bool);
}



contract Ownable {
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  
  constructor() public {
    _owner = msg.sender;
  }

  
  function owner() public view returns(address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
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


contract SimpleOracle is IOracle, Ownable {
 
    uint256 price;

    function setData(uint256 _price) external onlyOwner {
        price = _price;
    }
    
    function getData() external override view returns (uint256, bool) {
        return (price, true);
    }
}