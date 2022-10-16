pragma solidity 0.6.11;










 
interface TRA {
  function approve(address spender, uint256 amount) external returns (bool);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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

contract Funding {
  
  
  
  using SafeMath for uint256;
  
  uint256 public _oneMonthBlock;
  uint256 public _threeMonthBlock;
  uint256 public _deployedBlock;
  address public _owner;
  address public _TRAAddress;

  bool public _threeMonthWithdrawn;
  TRA public _TRAContract;

  
  constructor() public {
    _owner = msg.sender;
    _TRAAddress = address(0);
    _TRAContract = TRA(_TRAAddress);
    _oneMonthBlock = uint256(5760).mul(30);
    _threeMonthBlock = uint256(5760).mul(30).mul(3);
    _deployedBlock = block.number;
    _threeMonthWithdrawn = false;
  }

  function SetTRAAddress(address TRAAddress) public {
    require(msg.sender == _owner,"Only owners can change the TRA address");
    _TRAAddress = TRAAddress;
    _TRAContract = TRA(_TRAAddress);
  }

  
  function ReleaseMonthly() public {
    
    require(block.number >= _deployedBlock.add(_oneMonthBlock),"One month hasn't passed since the last transaction");
    
    uint256 amount = 50000 * uint256(10) ** 18;
    
    _oneMonthBlock = _oneMonthBlock.add(_oneMonthBlock);
    _TRAContract.transfer(msg.sender,amount);
  }

  
  function ReleaseThreeMonths() public {
  
    require(block.number >= _deployedBlock.add(_threeMonthBlock),"Three month hasn't passed since the last transaction");
    require(_threeMonthWithdrawn == false,"Cannot withdraw more than once");
    
    uint256 amount = 300000 * uint256(10) ** 18;
    
    _threeMonthWithdrawn = true;
    _TRAContract.transfer(msg.sender,amount);
  }
}