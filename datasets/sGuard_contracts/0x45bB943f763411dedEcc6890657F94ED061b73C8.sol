pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;




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




contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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




interface I_MakerOracle {

    

    
    function peek()
        external
        view
        returns (bytes32, bool);

    
    function read()
        external
        view
        returns (bytes32);

    
    function bar()
        external
        view
        returns (uint256);

    
    function age()
        external
        view
        returns (uint32);

    

    
    function poke(
        uint256[] calldata val_,
        uint256[] calldata age_,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    )
        external;
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




library BaseMath {
    using SafeMath for uint256;

    
    uint256 constant internal BASE = 10 ** 18;

    
    function base()
        internal
        pure
        returns (uint256)
    {
        return BASE;
    }

    
    function baseMul(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        return value.mul(baseValue).div(BASE);
    }

    
    function baseDivMul(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        return value.div(BASE).mul(baseValue);
    }

    
    function baseMulRoundUp(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        if (value == 0 || baseValue == 0) {
            return 0;
        }
        return value.mul(baseValue).sub(1).div(BASE).add(1);
    }

    
    function baseDiv(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        return value.mul(BASE).div(baseValue);
    }

    
    function baseReciprocal(
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {
        return baseDiv(BASE, baseValue);
    }
}




interface I_P1Oracle {

    
    function getPrice()
        external
        view
        returns (uint256);
}




contract P1MakerOracle is
    Ownable,
    I_P1Oracle
{
    using BaseMath for uint256;

    

    event LogRouteSet(
        address indexed sender,
        address oracle
    );

    event LogAdjustmentSet(
        address indexed oracle,
        uint256 adjustment
    );

    

    
    mapping(address => address) public _ROUTER_;

    
    mapping(address => uint256) public _ADJUSTMENTS_;

    

    
    function getPrice()
        external
        view
        returns (uint256)
    {
        
        address oracle = _ROUTER_[msg.sender];

        
        require(
            oracle != address(0),
            "Sender not authorized to get price"
        );

        
        uint256 adjustment = _ADJUSTMENTS_[oracle];
        if (adjustment == 0) {
            adjustment = BaseMath.base();
        }

        
        uint256 rawPrice = uint256(I_MakerOracle(oracle).read());
        uint256 result = rawPrice.baseMul(adjustment);

        
        require(
            result != 0,
            "Oracle would return zero price"
        );

        return result;
    }

    

    
    function setRoute(
        address sender,
        address oracle
    )
        external
        onlyOwner
    {
        _ROUTER_[sender] = oracle;
        emit LogRouteSet(sender, oracle);
    }

    
    function setAdjustment(
        address oracle,
        uint256 adjustment
    )
        external
        onlyOwner
    {
        _ADJUSTMENTS_[oracle] = adjustment;
        emit LogAdjustmentSet(oracle, adjustment);
    }
}