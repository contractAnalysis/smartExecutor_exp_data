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
    
    
    
    return a / b;
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

contract Ownable {
  address public owner;

  
  function Ownable() public {
    owner = msg.sender;
  }


  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  
  modifier whenPaused() {
    require(paused);
    _;
  }

  
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
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


contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping(address => bool) public frozenAccount;

  event FrozenFunds(address target, bool frozen);

  uint256 totalSupply_;

  
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(!frozenAccount[msg.sender]);
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  
  function freezeAccount(address target, bool freeze) public onlyOwner {
    frozenAccount[target] = freeze;
    emit FrozenFunds(target, freeze);
  }
}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(!frozenAccount[_from]);
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

}



contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  
  function batchTransfer(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    require(!frozenAccount[msg.sender]);

    uint receiverCount = _receivers.length;
    require(receiverCount > 0);

    uint256 amount = _value.mul(uint256(receiverCount));
    require(_value > 0 && balances[msg.sender] >= amount);

    balances[msg.sender] = balances[msg.sender].sub(amount);
    for (uint i = 0; i < receiverCount; i++) {
        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
        emit Transfer(msg.sender, _receivers[i], _value);
    }

    return true;
  }

}
contract YAKL is PausableToken {
    uint8 public constant decimals = 18;
    uint256 public contractAmount = 33600000 * (10 ** uint256(decimals));
    address public originalAddr = 0x4254f5f0d3d0D46900053B1566ff16C8e7800816;
    address public receiveAddr =  0x0e8720C2AD735E7b38Bd9FfEA3186d7DDDD869c2;
    uint public supplyDateTime = 4102415999;
    uint256 public originAmount = 300000 * (10 ** uint256(decimals));
    
    function getContractAmount() constant returns (uint256){
        return contractAmount;
    }
    
    function setReceiveAddr(address newReceiveAddr) public onlyOwner{
        receiveAddr = newReceiveAddr;
    }
    
    function setSupplyDateTime(uint newSupplyDateTime) public onlyOwner{
        supplyDateTime = newSupplyDateTime;
    }
    
    function setOrigAmount(uint256 newOrigAmount) public onlyOwner{
        originAmount = newOrigAmount;
    }

    function apply() public onlyOwner{
      require(now > supplyDateTime && contractAmount > 0);
      uint256 _value = originAmount;
      for(uint i = 0; i < (now - supplyDateTime) / 60 days ;i ++){
          if(contractAmount >= 11200000 * (10 ** uint256(decimals))){
               _value -= _value * 2 / 100;
               
          }else{
               _value -= _value * 5 / 100; 
          }
          if(_value < originAmount / 3){
              _value = originAmount / 3;
              break;
          }
      }
      _value = _value / 30;
      if(contractAmount < _value){
          _value = contractAmount;
      }
      contractAmount -=_value;
      balances[receiveAddr]+= _value;
    }
    
    constructor() public {
      totalSupply_ = 42000000 * (10 ** uint256(decimals));
      balances[originalAddr] = 8400000 * (10 ** uint256(decimals));
      emit Transfer(address(0), originalAddr, 8400000 * (10 ** uint256(decimals)));
      paused = false;
  }
}