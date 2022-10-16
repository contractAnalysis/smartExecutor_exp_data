pragma solidity ^0.6.0;












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

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}





abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function approve(address spender, uint256 tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}



contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}




contract Token is ERC20Interface, Owned {
    using SafeMath for uint256;
    string public symbol = "TDEX";
    string public  name = "Tradepower Dex";
    uint256 public decimals = 18;
    uint256 private _totalSupply = 20e6 * 10 ** (decimals);
    uint256 private last_visit;
    uint256 private locked_tockens = 2e6 * 10 ** (decimals);
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    
    
    
    constructor() public {
        owner = 0x50F0fdC4E1a91C068e8c4627B7C2b418f7e6bf21;
        balances[address(owner)] = totalSupply();
        last_visit = now;
        emit Transfer(address(0),address(owner), totalSupply());
    }

    

    function totalSupply() public override view returns (uint256){
       return _totalSupply;
    }

    
    
    
    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    
    
    
    
    
    function transfer(address to, uint256 tokens) public override returns (bool success) {
        
        require(address(to) != address(0));
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        if (msg.sender == owner ){
            if (locked_tockens != 0){
                check_time();
            }
            require(balances[msg.sender].sub(tokens) >= locked_tockens, "Please wait for tokens to be released");
        }
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function check_time() private {
        if ((now.sub(last_visit)).div(1 weeks) >= 1){
            uint256 weeks_spanned;
            uint256 released;
            uint256 week_allowance = 50000 * 10 ** (decimals);
            weeks_spanned = (now.sub(last_visit)).div(1 weeks);
            released = weeks_spanned.mul(week_allowance);
            if (released > locked_tockens){
                released = locked_tockens;
            }
            last_visit = now;
            locked_tockens = locked_tockens.sub(released);
        }
    }

    
    
    
    
    function approve(address spender, uint256 tokens) public override returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success){
        require(tokens <= allowed[from][msg.sender]); 
        require(balances[from] >= tokens);
        if (from == owner){
            if (locked_tockens != 0){
                check_time();
            }
            require(balances[msg.sender].sub(tokens) >= locked_tockens);
        }
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;
    }


    
    
    
    
    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }

}