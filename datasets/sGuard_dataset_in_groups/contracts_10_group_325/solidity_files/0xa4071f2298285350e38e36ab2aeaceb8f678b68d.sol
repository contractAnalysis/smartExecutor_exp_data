pragma solidity 0.4.25;



interface IReconciliationAdjuster {
        function adjustBuy(uint256 _sdrAmount) external view returns (uint256);

        function adjustSell(uint256 _sdrAmount) external view returns (uint256);
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



contract Claimable is Ownable {
  address public pendingOwner;

    modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

    function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

    function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}




contract ReconciliationAdjuster is IReconciliationAdjuster, Claimable {
    string public constant VERSION = "1.0.0";

    using SafeMath for uint256;

        uint256 public constant MAX_RESOLUTION = 0x10000000000000000;

    uint256 public sequenceNum = 0;
    uint256 public factorN = 0;
    uint256 public factorD = 0;

    event FactorSaved(uint256 _factorN, uint256 _factorD);
    event FactorNotSaved(uint256 _factorN, uint256 _factorD);

        modifier onlyIfFactorSet() {
        assert(factorN > 0 && factorD > 0);
        _;
    }

        function setFactor(uint256 _sequenceNum, uint256 _factorN, uint256 _factorD) external onlyOwner {
        require(1 <= _factorN && _factorN <= MAX_RESOLUTION, "adjustment factor numerator is out of range");
        require(1 <= _factorD && _factorD <= MAX_RESOLUTION, "adjustment factor denominator is out of range");

        if (sequenceNum < _sequenceNum) {
            sequenceNum = _sequenceNum;
            factorN = _factorN;
            factorD = _factorD;
            emit FactorSaved(_factorN, _factorD);
        }
        else {
            emit FactorNotSaved(_factorN, _factorD);
        }
    }

        function adjustBuy(uint256 _sdrAmount) external view onlyIfFactorSet returns (uint256) {
        return _sdrAmount.mul(factorD) / factorN;
    }

        function adjustSell(uint256 _sdrAmount) external view onlyIfFactorSet returns (uint256) {
        return _sdrAmount.mul(factorN) / factorD;
    }
}