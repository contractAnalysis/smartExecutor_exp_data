pragma solidity ^0.5.0;

contract EIP20Interface {
    
    
    uint256 public totalSupply;

    
    
    function balanceOf(address _owner) public view returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract HelixNebula is EIP20Interface {


    address payable wallet;
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    
    constructor() public {
        wallet=msg.sender;
        totalSupply = 70000000000000000;                        
        balances[msg.sender] = totalSupply;
        name = "HelixNebula";                                   
        decimals = 7;                            
        symbol = "UN";                               
    }
 
   function GetMinedTokens() public view returns(uint){
      return totalSupply-balances[wallet];  
   }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(msg.sender != wallet);    
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); 
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); 
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

 
    
  uint votecost=10000 szabo; 
  uint HelixPrice=100000 szabo; 
  uint trigger=0;
  struct votedata{
      uint hid;
      address voterad;
      uint vtype;  
  }
  struct Human {
    uint id;
    string name;
    uint lang;
    int vote;
    uint views;
    string story;
    uint timestamp;
    address payable ethaddress;
    address payable ownerAddress;
    string pass;
  }
  votedata[] public voters;
  Human[] public Humans;
  uint public nextId = 1;
  
  function DeleteVotesByid(uint _id) internal{
     for(uint i = 0; i < voters.length; i++) {
      if(voters[i].hid == _id) {
            delete voters[i];
      }
     }
  }
  function create(string memory _name,uint _lang,string memory story,address payable _ethaddress,string memory pass) public {
    bytes memory EmptyStringstory = bytes(story); 
    require(EmptyStringstory.length > 4,"null story"); 
    Humans.push(Human(nextId, _name,_lang,0,0,story,block.timestamp,_ethaddress,msg.sender,pass));
    
    uint timetemp=block.timestamp - Humans[0].timestamp;
    uint tdays=timetemp/(3600*24);
    
    if(tdays>60){
        DeleteVotesByid(Humans[0].id);
        delete Humans[0];
        
    }
    
    for(uint i=0;i<Humans.length; i++){
        if(Humans[i].vote < -100){
            DeleteVotesByid(Humans[i].id);
            delete Humans[i];
        }
    }
    
    nextId++;
  }
  function GetdatePoint(uint _dtime) view internal returns(uint){
       uint timetemp=block.timestamp - _dtime;
       uint tdays=timetemp/(3600*24);
       uint pdays=tdays+1;
       uint points=((120-pdays)**2)/pdays;
       return points;
  }

  function GetRandomHuman(uint _randseed,uint _decimals,uint _lang) public view returns(string memory,string memory,int,address,uint,uint){  
      uint[] memory points=new uint[](Humans.length);
      uint maxlengthpoint=0;
      for(uint i = 0; i < Humans.length; i++) 
      {
          if(Humans[i].lang != _lang){
               points[i]=0;
          }else{
              uint daypoint=GetdatePoint(Humans[i].timestamp);
              int uvotes=Humans[i].vote*10;
              int mpoints=int(daypoint)+uvotes;
              if(mpoints<0){
                  mpoints=1;
              }
              points[i]=uint(mpoints);
              maxlengthpoint=maxlengthpoint+uint(mpoints);
          }
      }
      uint randnumber=(_randseed  * maxlengthpoint)/_decimals;
     
      
      uint tempnumber=0;
      for(uint i = 0; i < points.length; i++) {
          if(tempnumber<randnumber && randnumber<tempnumber+points[i] && points[i] !=0){
              uint timetemp=block.timestamp - Humans[i].timestamp;
              uint tdays=timetemp/(3600*24);
              if(60-tdays>0){
                  return (Humans[i].name,Humans[i].story,Humans[i].vote,Humans[i].ethaddress,Humans[i].id,60-tdays);
              }else{
                  return ("Problem","We have problem . please refersh again.",0,msg.sender,0,0);
              }
          }else{
              tempnumber=tempnumber+points[i];
          }
      }
      return ("No Story","If you see this story it means that there is no story at this language, if you know some one need help, ask them to add new story.",0,msg.sender,0,0);
  }

  function read(uint id) internal view  returns(uint, string memory) {
    uint i = find(id);
    return(Humans[i].id, Humans[i].name);
  }
  function GetVotedata(uint id) view public returns(int256,uint)
  {
     uint Vcost=votecost;
     uint votecounts=0;
     uint hindex=find(id);
     for(uint i = 0; i < voters.length; i++) {
      if(voters[i].hid == id && voters[i].voterad == msg.sender) {
        if(votecounts>0){
            Vcost=Vcost*2;
        }
        votecounts++;
      }
    } 
    return(Humans[hindex].vote,Vcost);
  }
  function vote(uint id,uint vtype) public payable returns(uint){
      
    uint votecounts=0;
    uint Vcost=votecost;
    for(uint i = 0; i < voters.length; i++) {
      if(voters[i].hid == id && voters[i].voterad == msg.sender) {
        if(votecounts>0){
            Vcost=Vcost*2;
        }
        votecounts++;
      }
    }
    if(msg.value >= Vcost){
        uint j = find(id);
        if(balances[wallet]>(10**7)){
            balances[wallet] -=10**7;
            balances[msg.sender] +=10**7;
            wallet.transfer(msg.value);
        }else{
            if(vtype==1){
                Humans[j].ethaddress.transfer(msg.value);
            }else{
                wallet.transfer(msg.value);
            }
        }
        if(vtype==1){
            Humans[j].vote++;
        }else{
            Humans[j].vote--;
        }
        voters.push(votedata(id, msg.sender,1));
        return Vcost*2;
    }else{
       return 0; 
    }
  }
  
  function SendTransaction(address payable _adr,address payable _referraladr,bool _hasreferral) public payable{
      uint HelixToTransfer=msg.value/HelixPrice;
      
      if(balances[wallet]>(2*HelixToTransfer*(10**7))){
          if(_hasreferral == true){
            balances[_referraladr] += HelixToTransfer*(10**7);
            balances[wallet] -= HelixToTransfer*(10**7);
          }
          balances[msg.sender] += HelixToTransfer*(10**7);
          balances[wallet] -= HelixToTransfer*(10**7);
          _adr.transfer(msg.value*9/10);
          wallet.transfer(msg.value/10);
      }else{
          _adr.transfer(msg.value); 
      }
  }
  
  function destroy(uint id) public {
      if(msg.sender==wallet){
        uint i = find(id);
        delete Humans[i];
      }else{
        revert('Access denied!');
      }
      
  }
  
  function GetStroyByindex(uint _index)view public returns(uint,string memory,string memory,uint,address)
  {
      if(msg.sender==wallet){
        return (Humans[_index].id,Humans[_index].name,Humans[_index].story,Humans[_index].lang,Humans[_index].ethaddress);
      }
      revert('Access denied!');
  }
  
  function find(uint id) view internal returns(uint) {
    for(uint i = 0; i < Humans.length; i++) {
      if(Humans[i].id == id) {
        return i;
      }
    }
    revert('User does not exist!');
  }
}