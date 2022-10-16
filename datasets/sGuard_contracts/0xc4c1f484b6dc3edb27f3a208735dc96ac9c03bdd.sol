pragma solidity ^0.4.11;



library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}



contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    
    

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}



contract Transfereuim is Ownable, StandardToken {

    using SafeMath for uint256;
    
	
    string public constant name = "Transfereuim";
    string public constant symbol = "TRN";
    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 1000 * (10**6) * 10**decimals; 
	uint256 public totalSale;

    
    bool public isFinalized;              

    
    uint256 public startDate;
    
    
    uint256 public constant startIco = 1589547600;
    
    uint256 public constant tokenRatePre = 1000; 
    uint256 public constant tokenRate1 = 700; 
    uint256 public constant tokenRate2 = 500; 
    uint256 public constant tokenRate3 = 300; 
    uint256 public constant tokenRate4 = 200; 


    uint256 public constant tokenForBounty  = 450 * (10**6) * 10**decimals;
    uint256 public constant tokenForSale    = 550 * (10**6) * 10**decimals;

	
    address public constant ethFundAddress = 0x29ea5bB7Da8F412d472808D2577d13F82507039D;      

	address public constant bountyAddress = 0x29ea5bB7Da8F412d472808D2577d13F82507039D;
  

    
    function Transfereuim() {
      	isFinalized = false;                   
      	totalSale = 0;
      	startDate = getCurrent();

      	balances[bountyAddress] = tokenForBounty;
    }

    function getCurrent() internal returns (uint256) {
        return now;
    }
    

    function getRateTime(uint256 at) internal returns (uint256) {
        if (at < (startIco)) {
            return tokenRatePre;
        } else if (at < (startIco + 26 days)) {
            return tokenRate1;
        } else if (at < (startIco + 60 days)) {
            return tokenRate2;
        } else if (at < (startIco + 90 days)) {
            return tokenRate3;
        }
        return tokenRate4;
    }
    
    
    function () payable {
        buyTokens(msg.sender, msg.value);
    }
    	
    
    function buyTokens(address sender, uint256 value) internal {
        require(!isFinalized);
        require(value > 0 ether);

        
        uint256 tokenRateNow = getRateTime(getCurrent());
      	uint256 tokens = value * tokenRateNow; 
      	uint256 checkedSupply = totalSale + tokens;
      	
       	
      	require(tokenForSale >= checkedSupply);  

        
        balances[sender] += tokens;

        
        totalSale = checkedSupply;

        
        ethFundAddress.transfer(value);
    }

    
    function finalize() onlyOwner {
        require(!isFinalized);
    	require(msg.sender == ethFundAddress);
    	require(tokenForSale > totalSale);
    	
        balances[ethFundAddress] += (tokenForSale - totalSale);
           	      	
      	
      	isFinalized = true;

    }
    
}