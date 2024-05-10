pragma solidity ^0.5.0;

library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        

        
        
        return a / b;
    }
    
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


 
contract Ownable {
    address payable public owner;
    address payable public developer;    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event DeveloperAddressSet(address indexed developer);
    
   constructor() public {
      owner = msg.sender;
      developer = 0x3bb68c4d093E12bd772ce07107E0b4666E9C833d;
    }
    
    
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    
    
    function transferOwnership(address payable newOwner) public onlyOwner {
      require(newOwner != address(0));
      owner = newOwner;
      emit OwnershipTransferred(owner, newOwner);
    }
    
    function setDeveloperAddress(address payable newDeveloper) public {
      require(newDeveloper != address(0));
      developer = newDeveloper;
      
      emit DeveloperAddressSet(newDeveloper);
    }
}




contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TokenVesting is Ownable {
  using SafeMath for uint256;

  event Vested(address beneficiary, uint256 amount);
  event Released(address beneficiary, uint256 amount);

  struct Balance {
      uint256 value;
      uint256 start;
      uint256 currentPeriod;
  }

  mapping(address => Balance) private balances;
  mapping (address => uint256) private released;
  uint256 private period;
  uint256 public duration;
  mapping (uint256 => uint256) private percentagePerPeriod;

  constructor() public {
    owner = msg.sender;
    period = 4;
    duration = 10512000; 
    percentagePerPeriod[0] = 15;
    percentagePerPeriod[1] = 20;
    percentagePerPeriod[2] = 30;
    percentagePerPeriod[3] = 35;
  }
  
  function balanceOf(address _owner) public view returns(uint256) {
      return balances[_owner].value.sub(released[_owner]);
  }
    
  function vesting(address _beneficiary, uint256 _amount) public onlyOwner {
      if(balances[_beneficiary].start == 0){
          balances[_beneficiary].start = now;
      }

      balances[_beneficiary].value = balances[_beneficiary].value.add(_amount);
      emit Vested(_beneficiary, _amount);
  }
  
  
  function release(address _beneficiary) public onlyOwner {
    require(balances[_beneficiary].currentPeriod.add(1) <= period);
    require(balances[_beneficiary].value > released[_beneficiary]);
    require(balances[_beneficiary].start != 0);
    require(now >= balances[_beneficiary].start.add((balances[_beneficiary].currentPeriod.add(1) * duration)));

    uint256 amountReleasedThisPeriod = balances[_beneficiary].value.mul(percentagePerPeriod[balances[_beneficiary].currentPeriod]);
    amountReleasedThisPeriod = amountReleasedThisPeriod.div(100);
    released[_beneficiary] = released[_beneficiary].add(amountReleasedThisPeriod);
    balances[_beneficiary].currentPeriod = balances[_beneficiary].currentPeriod.add(1);

    BasicToken(owner).transfer(_beneficiary, amountReleasedThisPeriod);

    emit Released(_beneficiary, amountReleasedThisPeriod);
  }
  
  function setDuration(uint256 _duration) public onlyOwner {
        duration = _duration;
    }
}


contract TokenPool is Ownable {
  using SafeMath for uint256;

  event Pooled(address beneficiary, uint256 amount);
  event Unlocked(address beneficiary, uint256 amount);

  struct Balance {
      uint256 value;
      string channel;
  }

  mapping(address => Balance) private balances;
  uint256 public minWithdraw;

  constructor() public {
    owner = msg.sender;
    minWithdraw = 1000*10**18;
  }
  
  function balanceOf(address _owner) public view returns(uint256) {
      return balances[_owner].value;
  }
  
  function pooling(address _beneficiary, uint256 _amount, string memory _channel) public onlyOwner {
      balances[_beneficiary].value = balances[_beneficiary].value.add(_amount);
      balances[_beneficiary].channel = _channel;
      emit Pooled(_beneficiary, _amount);
  }
  
  function unlock(address _beneficiary) public onlyOwner {
    require(balances[_beneficiary].value >= minWithdraw);
    BasicToken(owner).transfer(_beneficiary, balances[_beneficiary].value);
    balances[_beneficiary].value = 0;
    emit Unlocked(_beneficiary, balances[_beneficiary].value);
  }
  
  function setMinWithdraw(uint256 _minWithdraw) public onlyOwner {
        minWithdraw = _minWithdraw;
    }
}


contract BasicToken is ERC20Basic {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    uint256 totalSupply_;
    
    
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}

contract StandardToken is ERC20, BasicToken, Ownable {
    mapping (address => mapping (address => uint256)) allowed;
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender] || msg.sender == owner);
    
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (msg.sender !=  owner) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        
        emit Transfer(_from, _to, _value);
        return true;
    }
      
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}



contract Configurable {
    uint256 public constant cap = 5000000000*10**18;
    uint256 public basePrice = 34537*10**18; 
    uint256 public tokensSold = 0;
    uint256 public tokensSoldInICO = 0;
    uint256 public tokensSoldInPrivateSales = 0;
    uint256 public tokensUseForReferral = 0;
    uint256 public tokensUseForIFBonus = 0;    
    uint256 public constant tokenReserve = 5000000000*10**18;
    uint256 public tokenReserveForICO = 175000000*10**18;
    uint256 public tokenReserveForPrivateSales = 1575000000*10**18;
    uint256 public tokenReserveForReferral = 250000000*10**18;
    uint256 public tokenReserveForIFBonus = 750000000*10**18;
    uint256 public remainingTokens = 0;
    uint256 public remainingTokensForICO = 0;
    uint256 public remainingTokensForPrivateSales = 0;
    uint256 public remainingTokensForReferral = 0;
    uint256 public remainingTokensForIFBonus = 0;

    uint256 public minTransaction = 3.62 ether; 
    uint256 public maxTransaction = 289.54 ether; 

    uint256 public totalSalesInEther = 0;
}

contract BurnableToken is BasicToken, Ownable {
    event Burn(address indexed burner, uint256 value);
    
    function burn(uint256 _value) public onlyOwner {
        _burn(msg.sender, _value);
      }
      
    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
}


contract CrowdsaleToken is StandardToken, Configurable, BurnableToken  {
    
     enum Stages {
        none,
        icoStart,
        icoEnd
    }
    
    bool  public haltedICO = false;
    bool  public privateSale = false;
    Stages public currentStage;
    TokenVesting public tokenVestingContract;
    TokenPool public tokenPoolContract; 
    
    
    constructor() public {
        currentStage = Stages.icoStart;
        balances[owner] = balances[owner].add(tokenReserve);
        totalSupply_ = totalSupply_.add(tokenReserve);

        remainingTokens = cap;
        remainingTokensForICO = tokenReserveForICO;
        remainingTokensForPrivateSales = tokenReserveForPrivateSales;
        remainingTokensForReferral = tokenReserveForReferral;
        remainingTokensForIFBonus = tokenReserveForIFBonus;
        tokenVestingContract = new TokenVesting();
        tokenPoolContract = new TokenPool();
        emit Transfer(address(this), owner, tokenReserve);
    }
    
    
    function () external payable {
        require(msg.value > 0);
        uint256 weiAmount = msg.value; 
        uint256 tokens = weiAmount.mul(basePrice).div(1 ether);
        
        
        if (privateSale && minTransaction <= msg.value && maxTransaction >= msg.value) {
            this.sendPrivate(msg.sender,tokens);
            owner.transfer(weiAmount.mul(9).div(10));
            developer.transfer(weiAmount.mul(1).div(10));
        } else if (!haltedICO && currentStage == Stages.icoStart && remainingTokensForICO > 0) {
            
            tokensSoldInICO = tokensSoldInICO.add(tokens);
            remainingTokensForICO = tokenReserveForICO.sub(tokensSoldInICO);
    
            tokensSold = tokensSold.add(tokens); 
            remainingTokens = cap.sub(tokensSold);
    
            balances[msg.sender] = balances[msg.sender].add(tokens);
            balances[owner] = balances[owner].sub(tokens);
            emit Transfer(address(this), msg.sender, tokens);
            owner.transfer(weiAmount.mul(9).div(10));
            developer.transfer(weiAmount.mul(1).div(10));
        } else {
            revert();
        }
    }
    
    function sendPrivate(address _to, uint256 _tokens) external payable {
        require(_to != address(0));
        require(address(tokenVestingContract) != address(0));
        require(remainingTokensForPrivateSales > 0);
        require(tokenReserveForPrivateSales >= tokensSoldInPrivateSales.add(_tokens));

        
        tokensSoldInPrivateSales = tokensSoldInPrivateSales.add(_tokens);
        remainingTokensForPrivateSales = tokenReserveForPrivateSales.sub(tokensSoldInPrivateSales);

        tokensSold = tokensSold.add(_tokens); 
        remainingTokens = cap.sub(tokensSold);

        balances[address(tokenVestingContract)] = balances[address(tokenVestingContract)].add(_tokens);
        tokenVestingContract.vesting(_to, _tokens);

        balances[owner] = balances[owner].sub(_tokens);
        emit Transfer(address(this), address(tokenVestingContract), _tokens);
    }

    function sendIFBonus(address _to, uint256 _tokens) external payable {
        require(_to != address(0));
        require(address(tokenVestingContract) != address(0));
        require(remainingTokensForIFBonus > 0);
        require(tokenReserveForIFBonus >= tokensUseForIFBonus.add(_tokens));

        tokensUseForIFBonus = tokensUseForIFBonus.add(_tokens);
        remainingTokensForIFBonus = tokenReserveForIFBonus.sub(tokensUseForIFBonus);

        tokensSold = tokensSold.add(_tokens); 
        remainingTokens = cap.sub(tokensSold);

        balances[address(tokenVestingContract)] = balances[address(tokenVestingContract)].add(_tokens);
        tokenVestingContract.vesting(_to, _tokens);

        balances[owner] = balances[owner].sub(_tokens);
        emit Transfer(address(this), address(tokenVestingContract), _tokens);
    }
    
    function release(address _to) external onlyOwner {
        tokenVestingContract.release(_to);
    }

    function setVestingDuration(uint256 _duration) public onlyOwner {
        tokenVestingContract.setDuration(_duration);
    }
    
    function sendPool(address _to, uint256 _tokens, string memory _channel) public payable onlyOwner {
        require(_to != address(0));
        require(address(tokenPoolContract) != address(0));
        require(remainingTokensForReferral > 0);
        require(tokenReserveForReferral >= tokensUseForReferral.add(_tokens));
        
        tokensUseForReferral = tokensUseForReferral.add(_tokens);
        remainingTokensForReferral = tokenReserveForReferral.sub(tokensUseForReferral);

        tokensSold = tokensSold.add(_tokens); 
        remainingTokens = cap.sub(tokensSold);

        balances[address(tokenPoolContract)] = balances[address(tokenPoolContract)].add(_tokens);
        tokenPoolContract.pooling(_to, _tokens, _channel);

        balances[owner] = balances[owner].sub(_tokens);
        emit Transfer(address(this), address(tokenPoolContract), _tokens);
    }
    
    function unlock(address _to) external onlyOwner {
        tokenPoolContract.unlock(_to);
    }

    function setMinWithdraw(uint256 _minWithdraw) public onlyOwner {
        tokenPoolContract.setMinWithdraw(_minWithdraw);
    }
    
    function startIco() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        currentStage = Stages.icoStart;
    }
    
    function startPrivateSale() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        privateSale = true;
    }
    
    function stopPrivateSale() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        privateSale = false;
    }
    
    event icoHalted(address sender);
    function haltICO() public onlyOwner {
        haltedICO = true;
        emit icoHalted(msg.sender);
    }

    event icoResumed(address sender);
    function resumeICO() public onlyOwner {
        haltedICO = false;
        emit icoResumed(msg.sender);
    }

    
    function endIco() internal {
        currentStage = Stages.icoEnd;
        
        
        
        
        
        
        owner.transfer(address(this).balance); 
    }


    
    function finalizeIco() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        endIco();
    }

    function setBasePrice(uint256 _basePrice) public onlyOwner {
        basePrice = _basePrice;
    }

    function setMinTransaction(uint256 _minTransaction) public onlyOwner {
        minTransaction = _minTransaction;
    }

    function setMaxTransaction(uint256 _maxTransaction) public onlyOwner {
        maxTransaction = _maxTransaction;
    }
}


contract HipoliToken is CrowdsaleToken {
    string public constant name = "HIPOLI Token";
    string public constant symbol = "HPL";
    uint32 public constant decimals = 18;
}