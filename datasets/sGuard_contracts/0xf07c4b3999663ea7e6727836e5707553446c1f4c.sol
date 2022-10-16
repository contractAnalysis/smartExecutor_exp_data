pragma solidity ^0.5.0;




library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}






contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}







contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}





contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}






contract GAMTToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    
    
    
    constructor() public {
        symbol = "GAMT";
        name = "GAMT";
        decimals = 4;
        _totalSupply = 1000000000 * 10 ** uint256(decimals);
        balances[0xB2c85cB2fE0aBC7819988736D8a79acb9D2c2403] = _totalSupply;
        emit Transfer(address(0), 0xB2c85cB2fE0aBC7819988736D8a79acb9D2c2403, _totalSupply);
    }


    
    
    
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

    uint256 public sellPrice;
 uint256 public buyPrice;

 function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
   sellPrice = newSellPrice;
   buyPrice = newBuyPrice;
 }
 
 function buy() public payable returns (uint amount) {
        amount = msg.value / buyPrice;                    
        require(balances[address(this)] >= amount);       
        balances[msg.sender] += amount;                   
        balances[address(this)] -= amount;                
        emit Transfer(address(this), msg.sender, amount); 
        return amount;                                    
    }
    
    function sell(uint amount) public returns (uint revenue) {
        require(balances[msg.sender] >= amount);         
        balances[address(this)] += amount;               
        balances[msg.sender] -= amount;                  
        revenue = amount * sellPrice;
        msg.sender.transfer(revenue);                     
        emit Transfer(msg.sender, address(this), amount); 
        return revenue;                                   
    }

 mapping (address => bool) public frozenAccount;
 event FrozenFunds(address target, bool frozen);

 function freezeAccount(address target, bool freeze) public onlyOwner {
   frozenAccount[target] = freeze;
   emit FrozenFunds(target, freeze);
 }

 uint minBalanceForAccounts;

  function setMinBalance(uint minimumBalanceInFinney) public onlyOwner {
   minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
  }


    address payable toAddr;

    
    
    
    
    
    function transfer(address to, uint tokens) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        if (msg.sender.balance < minBalanceForAccounts) {
            sell((minBalanceForAccounts - msg.sender.balance) / sellPrice);
        }
   
   if(to.balance<minBalanceForAccounts) {
       toAddr = address(uint160(to));
       toAddr.transfer(sell((minBalanceForAccounts - to.balance) / sellPrice));
   }   
   
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function mintToken(address target, uint256 mintedAmount) public onlyOwner {
   balances[target] += mintedAmount;
   _totalSupply += mintedAmount;
   emit Transfer(address(0), owner, mintedAmount);
   emit Transfer(owner, target, mintedAmount);
  }


    
    
    
    
    
    
    
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    
    
    
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    
    
    
    
    
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    
    
    
    function () external payable {
        revert();
    }


    
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}