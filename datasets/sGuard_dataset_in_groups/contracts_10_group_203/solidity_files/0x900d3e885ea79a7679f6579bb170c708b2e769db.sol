pragma solidity ^0.4.24;

library SafeMath {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


contract AlphaCrowdsale is Ownable {
    
    using SafeMath for uint256;

    
    ERC20 private _token;

    
    address private _wallet;
    
    uint256 private _rate = 500;
    
    
    uint256 private _weiRaised;
    
    uint256 public _tierOneBonus;
    
    uint256 public _preSaleStartTime =  1596499200;
    
    uint256 public _preSaleEndTime = 1597708800;

    uint256 public _startTime =  1597708801;
    
    uint256 public _endTime = 1600128000;
    
    uint256 private _tokensSold;
    
    
    uint256 public _crowdsaleSupply = SafeMath.mul(125000000, 1 ether);
    
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor (address  wallet, ERC20 token) public {
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        
        _wallet = wallet;
        _token = token;
        _tokensSold = 0;
        
       _tierOneBonus =  SafeMath.div(SafeMath.mul(_rate,40),100);

    }

    function () external payable {
        buyTokens(msg.sender);
    }


    function token() public view returns (ERC20) {
        return _token;
    }

    function wallet() public view returns (address ) {
        return _wallet;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function buyTokens(address beneficiary) public  payable {
        require(validPurchase());

        uint256 weiAmount = msg.value;
        
        require(weiAmount >= 10000000000000000, "Wei amount should be greater than 0.01 ETH");
        _preValidatePurchase(beneficiary, weiAmount);
        
        uint256 tokens = 0;
        
        tokens = _processPurchase(weiAmount, tokens);
      
        _weiRaised = _weiRaised.add(weiAmount);
        
        _deliverTokens(beneficiary, tokens);  
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);
        
        _tokensSold = _tokensSold.add(tokens);
        
        _forwardFunds();
     
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal pure {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.transfer(beneficiary, tokenAmount);
    }

    function _processPurchase(uint256 weiAmount, uint256 tokenAmount)  internal returns (uint256) {
        if (now < _startTime) { 
          tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierOneBonus));
        }               
        
        tokenAmount = tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_rate));
        
        require(_crowdsaleSupply >= tokenAmount);
        
        _crowdsaleSupply = _crowdsaleSupply.sub(tokenAmount);        

        return tokenAmount;
        
    }
    
      
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= _preSaleStartTime && now <= _endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
  }

  
    function hasEnded() public constant returns (bool) {
      return now > _endTime;
    }

    function updateWallet(address newWallet) public onlyOwner returns(bool) {
        _wallet = newWallet;
        return true;
    }
    
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
    function withdrawTokens(uint _amount) external onlyOwner {
       _token.transfer(_wallet, _amount);
   }
   
}