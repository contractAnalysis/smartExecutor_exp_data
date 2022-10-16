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


contract Ownable is Context {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address payable msgSender = _msgSender();
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

    
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.5.0;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
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



pragma solidity ^0.5.0;





interface Invest2cDAI_NEW {
    function LetsInvest(address _towhomtoissue) external payable;
}

interface Invest2Fulcrum {
    function LetsInvest2Fulcrum(address _towhomtoissue) external payable;
}



contract SafeNotSorryZapV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint;
    
    
    
    
    
    Invest2Fulcrum public Invest2FulcrumContract = Invest2Fulcrum(0xAB58BBF6B6ca1B064aa59113AeA204F554E8fBAe);
    Invest2cDAI_NEW public Invest2cDAI_NEWContract = Invest2cDAI_NEW(0x1FE91B5D531620643cADcAcc9C3bA83097c1B698);
    
    
    
    uint public balance = address(this).balance;
    
    
    bool private stopped = false;
    
    
    function set_Invest2FulcrumContract (Invest2Fulcrum _Invest2FulcrumContract) onlyOwner public {
        Invest2FulcrumContract = _Invest2FulcrumContract;
    }
    
    
    function set_Invest2cDAI_NEWContract (Invest2cDAI_NEW _Invest2cDAI_NEWContract) onlyOwner public {
        Invest2cDAI_NEWContract = _Invest2cDAI_NEWContract;
    }
    
    
    modifier stopInEmergency {if (!stopped) _;}
    modifier onlyInEmergency {if (stopped) _;}

    
    function toggleContractActive() onlyOwner public {
    stopped = !stopped;
    }

    function LetsInvest(uint _allocationToCDAI_new) stopInEmergency nonReentrant payable public returns (bool) {
        uint investment_amt = msg.value;
        uint investAmt2cDAI_NEW = SafeMath.div(SafeMath.mul(investment_amt,_allocationToCDAI_new), 100);
        uint investAmt2cFulcrum = SafeMath.sub(investment_amt, investAmt2cDAI_NEW);
        require (SafeMath.sub(investment_amt,SafeMath.add(investAmt2cDAI_NEW, investAmt2cFulcrum)) == 0);
        Invest2cDAI_NEWContract.LetsInvest.value(investAmt2cDAI_NEW)(msg.sender);
        Invest2FulcrumContract.LetsInvest2Fulcrum.value(investAmt2cFulcrum)(msg.sender);
        return true;
        
    }
    
    function depositETH() payable public onlyOwner returns (uint) {
        balance += msg.value;
    }
    
    
    function() external payable {
        if (msg.sender == _owner) {
            depositETH();
        } else {
            LetsInvest(90);
        }
    }
    
    
    function withdraw() onlyOwner public{
        _owner.transfer(address(this).balance);
    }
    

}