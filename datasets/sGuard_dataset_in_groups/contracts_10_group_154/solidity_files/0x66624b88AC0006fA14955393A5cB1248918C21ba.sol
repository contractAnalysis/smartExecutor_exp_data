pragma solidity 0.5.16;

interface IIdleRebalancerV3 {
  function getAllocations() external view returns (uint256[] memory _allocations);
  function setAllocations(uint256[] calldata _allocations, address[] calldata _addresses) external;
}



pragma solidity ^0.5.0;


contract Context {
    
    
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


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = _msgSender();
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
}



pragma solidity ^0.5.0;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}




pragma solidity 0.5.16;




contract IdleRebalancerV3_1 is IIdleRebalancerV3, Ownable {
  using SafeMath for uint256;
  uint256[] public lastAmounts;
  address[] public lastAmountsAddresses;
  address public rebalancerManager;
  address public idleToken;
  uint256 private constant MAX_PERC = 100000;

  
  constructor(address[] memory _protocolTokens, address _rebalancerManager) public {
    require(_rebalancerManager != address(0), 'manager addr is 0');
    rebalancerManager = _rebalancerManager;
    lastAmounts = new uint256[](_protocolTokens.length);
    lastAmountsAddresses = new address[](_protocolTokens.length);

    lastAmounts[0] = MAX_PERC;
    lastAmountsAddresses[0] = _protocolTokens[0];
    for(uint256 i = 1; i < _protocolTokens.length; i++) {
      require(_protocolTokens[i] != address(0), 'some addr is 0');
      
      lastAmountsAddresses[i] = _protocolTokens[i];
    }
  }

  
  modifier onlyRebalancerAndIdle() {
    require(msg.sender == rebalancerManager || msg.sender == idleToken, "Only rebalacer and IdleToken");
    _;
  }

  
  function setRebalancerManager(address _rebalancerManager)
    external onlyOwner {
      require(_rebalancerManager != address(0), "_rebalancerManager addr is 0");

      rebalancerManager = _rebalancerManager;
  }

  function setIdleToken(address _idleToken)
    external onlyOwner {
      require(idleToken == address(0), "idleToken addr already set");
      require(_idleToken != address(0), "_idleToken addr is 0");
      idleToken = _idleToken;
  }

  
  function setNewToken(address _newToken)
    external onlyOwner {
      require(_newToken != address(0), "New token should be != 0");
      for (uint256 i = 0; i < lastAmountsAddresses.length; i++) {
        if (lastAmountsAddresses[i] == _newToken) {
          return;
        }
      }

      lastAmountsAddresses.push(_newToken);
      lastAmounts.push(0);
  }
  

  
  function setAllocations(uint256[] calldata _allocations, address[] calldata _addresses)
    external onlyRebalancerAndIdle
  {
    require(_allocations.length == lastAmounts.length, "Alloc lengths are different, allocations");
    require(_allocations.length == _addresses.length, "Alloc lengths are different, addresses");

    uint256 total;
    for (uint256 i = 0; i < _allocations.length; i++) {
      require(_addresses[i] == lastAmountsAddresses[i], "Addresses do not match");
      total = total.add(_allocations[i]);
      lastAmounts[i] = _allocations[i];
    }
    require(total == MAX_PERC, "Not allocating 100%");
  }

  function getAllocations()
    external view returns (uint256[] memory _allocations) {
    return lastAmounts;
  }

  function getAllocationsLength()
    external view returns (uint256) {
    return lastAmounts.length;
  }
}