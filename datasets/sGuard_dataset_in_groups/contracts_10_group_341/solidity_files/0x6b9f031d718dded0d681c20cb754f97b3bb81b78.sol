pragma solidity ^0.4.26;
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
	return (c);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
	return (c);
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
	return (c);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
	return (c);
    }
}
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);   
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);      
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens); 
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

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

contract GEEQToken is ERC20Interface, Owned {
    using SafeMath for uint;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 _totalSupply;
    uint256 _totalMinted;
    uint256 _maxMintable;
    bool public pauseOn;
    bool public migrationOn;
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;   

    event PauseEvent(string pauseevent);
    event ErrorEvent(address indexed addr, string errorstr);
    event BurnEvent(address indexed addr, uint256 tokens);

    constructor() public {
        symbol = "GEEQ";
        name = "Geeq";
        decimals = 18;
        _totalMinted = 0;       
        _totalSupply = 0;       
        _maxMintable = 100000000 * 10**uint(decimals);  
        owner = msg.sender;
    }
    
    mapping(address => bytes32) public geeqaddress;
    event MigrateEvent(address indexed addr, bytes32 geeqaddress, uint256 balance);
    function migrateGEEQ(bytes32 registeraddress) public {
        if (migrationOn){
            geeqaddress[msg.sender] = registeraddress;  
            emit MigrateEvent(msg.sender, registeraddress, balances[msg.sender]);    
            burn(balances[msg.sender]);
        } else {
            emit ErrorEvent (msg.sender, "Attempted to migrate before GEEQ Migration has begun.");
        }
    }
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }    
    
    
    function pauseEnable() onlyOwner public {
        pauseOn= true;
    }
    function pauseDisable() onlyOwner public {
        pauseOn= false;
    }
    function migrationEnable() onlyOwner public {
        migrationOn= true;
    }
    function migrationDisable() onlyOwner public {
        migrationOn= false;
    }

    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }
    function totalMinted() public constant returns (uint) {
        return _totalMinted;
    }
    function burn(uint256 tokens) internal {      
        if(balances[msg.sender]>= tokens) {
            _totalSupply=_totalSupply.sub(balances[msg.sender]);
            balances[msg.sender] = balances[msg.sender].sub(tokens);
            balances[address(0)] = balances[address(0)].add(tokens);
            emit BurnEvent(msg.sender, tokens);
        } else {
            revert();       
        }            
    }

    
    function mint(address receiver, uint256 token_amt) onlyOwner public {            
        if( _totalMinted.add(token_amt) > _maxMintable) { 
            revert();       
        }
        balances[receiver] = balances[receiver].add(token_amt);
        _totalMinted =_totalMinted.add(token_amt);
        _totalSupply =_totalSupply.add(token_amt);
        emit Transfer(address(0), receiver, token_amt);      
    } 


    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) public returns (bool success) {
        if(pauseOn){
            emit ErrorEvent(msg.sender, "Contract is paused. Please migrate to the native chain with migrateGEEQ.");
            revert();           
        } else {
            balances[msg.sender] = balances[msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(msg.sender, to, tokens);
            return true;           
        }
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    } 
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        if(pauseOn){
            emit ErrorEvent(msg.sender, "Contract is paused. Please migrate to the native chain with migrateGEEQ.");
            revert();           
        } else {
            balances[from] = balances[from].sub(tokens);
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(from, to, tokens);
            return true;           
        }
    }
    
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }  
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;           
    }  
    function() public { }
    

}