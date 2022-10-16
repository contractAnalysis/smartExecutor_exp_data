pragma solidity ^0.6.0;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface IOneSplit {

    function getExpectedReturn(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 parts,
        uint256 disableFlags 
    )
        external
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution 
        );

    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution, 
        uint256 disableFlags 
    )
        external
        payable
        returns(uint256 returnAmount);

    function goodSwap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minReturn,
        uint256 parts,
        uint256 disableFlags 
    )
        external
        payable;
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "caller must be the Contract Owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "New Owner must not be empty.");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract OneInchArb is Ownable {
    
    
    IOneSplit internal OneSplit;
    ERC20 internal IFromToken;
    ERC20 internal IToToken;
    
    
    address payable public ONEINCH_ADDRESS;
    
    uint constant internal MAX_QTY   = (10**28);
    
    
    constructor(
        address payable _oneinch) public {
            ONEINCH_ADDRESS = _oneinch;
        }
    
    
    function updateOneinchAddress(address payable _address) onlyOwner public {
        ONEINCH_ADDRESS = _address;
    }
    
    function arb(address _fromToken ,address _toToken ,uint256 _amount, uint256 _minreturn,  uint256[] memory _distribution1,uint256[] memory _distribution2 ) onlyOwner public payable returns(uint256) {
 
        IFromToken = ERC20(_fromToken);
        IToToken = ERC20(_toToken);
        OneSplit = IOneSplit(ONEINCH_ADDRESS);
        
        if (IFromToken.allowance(address(this), ONEINCH_ADDRESS) < _amount)
        {
            IFromToken.approve(ONEINCH_ADDRESS, MAX_QTY);
        }
        
        if (IToToken.allowance(address(this), ONEINCH_ADDRESS) < _amount){
            IToToken.approve(ONEINCH_ADDRESS, MAX_QTY);
        }
        
        uint256 iGot = OneSplit.swap(_fromToken, _toToken, _amount,_minreturn, _distribution1, 0);
        
        uint256 iSell = OneSplit.swap(_toToken,_fromToken, iGot,_amount, _distribution2,0);
        
        require (_amount >= iSell);
        
        uint256 profit  = _amount - iSell;
        
        return profit;
        
    }
    
    
    function SendToken(address _token, uint256 _amount) onlyOwner public {
        if (_token != address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) )
        {
        IFromToken = ERC20(_token);
        IFromToken.transfer(msg.sender, IFromToken.balanceOf(address(this)));
        }
        if (_token == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) )
        {
            msg.sender.transfer(_amount);
        }
    }
    
}