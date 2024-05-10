pragma solidity 0.5.12;




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



library FixedPoint {
  using SafeMath for uint256;

  
  uint256 public constant SCALE = 1e18;

  
  struct Fixed18 {
    uint256 mantissa;
  }

  
  function calculateMantissa(uint256 numerator, uint256 denominator) public pure returns (uint256) {
    uint256 mantissa = numerator.mul(SCALE);
    mantissa = mantissa.div(denominator);
    return mantissa;
  }

  
  function multiplyUint(Fixed18 storage f, uint256 b) public view returns (uint256) {
    uint256 result = f.mantissa.mul(b);
    result = result.div(SCALE);
    return result;
  }

  
  function divideUintByFixed(uint256 dividend, Fixed18 storage divisor) public view returns (uint256) {
    return divideUintByMantissa(dividend, divisor.mantissa);
  }

  
  function divideUintByMantissa(uint256 dividend, uint256 mantissa) public pure returns (uint256) {
    uint256 result = SCALE.mul(dividend);
    result = result.div(mantissa);
    return result;
  }
}