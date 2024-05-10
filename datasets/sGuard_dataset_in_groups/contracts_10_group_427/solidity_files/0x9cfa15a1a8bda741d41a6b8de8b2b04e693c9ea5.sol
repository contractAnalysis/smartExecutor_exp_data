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

interface IUnderlyingTokenValuator {

    
    function getTokenValue(address token, uint amount) external view returns (uint);

}



pragma solidity ^0.5.0;


interface IUsdAggregator {

    
    function currentAnswer() external view returns (uint);

}



pragma solidity ^0.5.0;

library StringHelpers {

    function toString(address _address) public pure returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++) {
            b[i] = byte(uint8(uint(_address) / (2 ** (8 * (19 - i)))));
        }
        return string(b);
    }

}



pragma solidity ^0.5.0;






contract UnderlyingTokenValuatorImplV3 is IUnderlyingTokenValuator, Ownable {

    using StringHelpers for address;
    using SafeMath for uint;

    event DaiUsdAggregatorChanged(address indexed oldAggregator, address indexed newAggregator);
    event EthUsdAggregatorChanged(address indexed oldAggregator, address indexed newAggregator);
    event UsdcEthAggregatorChanged(address indexed oldAggregator, address indexed newAggregator);

    address public dai;
    address public usdc;
    address public weth;

    IUsdAggregator public ethUsdAggregator;
    IUsdAggregator public daiUsdAggregator;
    IUsdAggregator public usdcEthAggregator;

    uint public constant USD_AGGREGATOR_BASE = 100000000;
    uint public constant ETH_AGGREGATOR_BASE = 1e18;

    constructor(
        address _dai,
        address _usdc,
        address _weth,
        address _daiUsdAggregator,
        address _ethUsdAggregator,
        address _usdcEthAggregator
    ) public {
        dai = _dai;
        usdc = _usdc;
        weth = _weth;

        daiUsdAggregator = IUsdAggregator(_daiUsdAggregator);
        ethUsdAggregator = IUsdAggregator(_ethUsdAggregator);
        usdcEthAggregator = IUsdAggregator(_usdcEthAggregator);
    }

    function setDaiUsdAggregator(address _daiUsdAggregator) public onlyOwner {
        address oldAggregator = address(daiUsdAggregator);
        daiUsdAggregator = IUsdAggregator(_daiUsdAggregator);

        emit DaiUsdAggregatorChanged(oldAggregator, _daiUsdAggregator);
    }

    function setEthUsdAggregator(address _ethUsdAggregator) public onlyOwner {
        address oldAggregator = address(ethUsdAggregator);
        ethUsdAggregator = IUsdAggregator(_ethUsdAggregator);

        emit EthUsdAggregatorChanged(oldAggregator, _ethUsdAggregator);
    }

    function setUsdcEthAggregator(address _usdcEthAggregator) public onlyOwner {
        address oldAggregator = address(usdcEthAggregator);
        usdcEthAggregator = IUsdAggregator(_usdcEthAggregator);

        emit UsdcEthAggregatorChanged(oldAggregator, _usdcEthAggregator);
    }

    function getTokenValue(address token, uint amount) public view returns (uint) {
        if (token == weth) {
            return amount.mul(ethUsdAggregator.currentAnswer()).div(USD_AGGREGATOR_BASE);
        } else if (token == usdc) {
            uint wethValueAmount = amount.mul(usdcEthAggregator.currentAnswer()).div(ETH_AGGREGATOR_BASE);
            return getTokenValue(weth, wethValueAmount);
        } else if (token == dai) {
            return amount.mul(daiUsdAggregator.currentAnswer()).div(USD_AGGREGATOR_BASE);
        } else {
            revert(string(abi.encodePacked("Invalid token, found: ", token.toString())));
        }
    }

}