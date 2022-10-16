pragma solidity 0.5.16;


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
        require(isOwner(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract FlashExchange is Ownable {
 
 using SafeMath for uint256;
 
 
 uint256 constant FLASHLOAN_LP_YIELD = 18; 
 uint256 constant FLASHLOAN_LP_YIELD_BASE = 1000; 
 
 mapping(address => bool) flashboys;
 
 mapping(address => uint256) assetsMaxYield;
 
 
 modifier onlyFlashboys {
     require(flashboys[msg.sender], "Only flashboys can call this function");
     _;
 }
 
 function addFlashboys(address [] memory _flashboys) public onlyOwner {
 
    for(uint256 i=0; i< _flashboys.length; i++){
        flashboys[_flashboys[i]] = true;
    }
 }
 
 function addAsset(address _asset, uint256 _maxYield) public onlyOwner {
    assetsMaxYield[_asset] = _maxYield;
 }
 
 
 
 function exchange(address _asset, uint256 _amount) public payable onlyFlashboys{
     
     uint256 yield = _amount.mul(FLASHLOAN_LP_YIELD).div(FLASHLOAN_LP_YIELD_BASE);

    require(yield <= assetsMaxYield[_asset], "Flashloan is too big");

    if(_asset == EthAddressLib.ethAddress()){
        require(msg.value == _amount, "The value sent is not enough");
        msg.sender.transfer(_amount.add(yield));
    } else {
              
            require(IERC20(_asset).transferFrom(msg.sender, address(this), _amount));
      
        require(IERC20(_asset).transfer(msg.sender, _amount.add(yield)));
    }    
}

    function () external payable{

    }
    
    
    function withdraw(address _asset) public onlyOwner {
        if (_asset == EthAddressLib.ethAddress()) {
            msg.sender.transfer(address(this).balance);
        } else {
            
            require(
                IERC20(_asset).transfer(
                    msg.sender,
                    IERC20(_asset).balanceOf(address(this))
                )
            );
        }
    }
}

library EthAddressLib {

    
    function ethAddress() internal pure returns(address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}



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


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}