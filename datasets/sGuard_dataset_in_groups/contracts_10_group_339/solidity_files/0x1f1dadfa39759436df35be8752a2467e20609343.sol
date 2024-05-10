pragma solidity 0.5.9;


library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}


contract Context {
    
    
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool); 

    function approve(address spender, uint256 value) external returns (bool); 

    function transferFrom(address from, address to, uint256 value) external returns (bool); 

    function totalSupply() external view returns (uint256); 

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256); 

    event Transfer(address indexed from, address indexed to, uint256 value); 

    event Approval(address indexed owner, address indexed spender, uint256 value); 
}



contract StandardToken is IERC20, Context {
    using SafeMath for uint256; 
    
    mapping (address => uint256) internal _balances; 
    mapping (address => mapping (address => uint256)) internal _allowed; 
    
    uint256 internal _totalSupply; 
    
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply; 
    }

    
    function balanceOf(address owner) public view  returns (uint256) {
        return _balances[owner];
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(_msgSender(), to, value);
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(_msgSender(), spender, value); 
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value); 
        _approve(from, _msgSender(), _allowed[from][_msgSender()].sub(value)); 
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowed[_msgSender()][spender].add(addedValue)); 
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowed[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Cannot transfer to the zero address"); 
        _balances[from] = _balances[from].sub(value); 
        _balances[to] = _balances[to].add(value); 
        emit Transfer(from, to, value); 
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0), "Cannot approve to the zero address"); 
        require(owner != address(0), "Setter cannot be the zero address"); 
	    _allowed[owner][spender] = value;
        emit Approval(owner, spender, value); 
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowed[account][_msgSender()].sub(amount));
    }

}


contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
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

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract HatToken is StandardToken, Ownable {
    string public constant name = "Health Alliance Token";
    string public constant symbol = "HAT";
    uint8 public constant decimals = 18;
    
    uint256 internal constant INITIAL_SUPPLY = 1000000000 ether;
    uint256 internal constant lock_total = 50000000 ether;            
    uint256 private start_time;
    uint256 private one_year = 31536000;   

    uint256 private release_value = 6000000 ether;

    address private constant tokenWallet = 0x7637aF16615D3B994e96C704713d9b40Baac6771;
    address private constant team_address =0x836F93846DA00edacD4C48426D26AB6953E02a36;
    address private constant foundation_address = 0xBa2b3f062104b5b9325cFA3d2D31f7A5f3981F52;
    event Lock(address account, uint lock_total);
    
    
    constructor() public {
        _totalSupply = INITIAL_SUPPLY;
        _owner = tokenWallet;
        _balances[_owner] = 900000000 * 10 ** uint(decimals);
        start_time = now.add(one_year*2);
        _lock(team_address);
        _lock(foundation_address);
        emit Transfer(address(0), _owner, 900000000 * 10 ** uint(decimals));
    }
    function _lock(address account) internal {
        _balances[account] = _balances[account].add(lock_total);
        emit Transfer(address(0), account, lock_total);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        if (msg.sender == team_address || msg.sender == foundation_address) {
            uint256 extra = getLockBalance();
            require(_balances[_msgSender()].sub(_value) >= extra);
        }
        return super.transfer(_to, _value);
        
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (_from == team_address || _from == foundation_address) {
        uint256 extra = getLockBalance();
        require(_balances[_from].sub(_value) >= extra);
        }
        return super.transferFrom(_from, _to, _value);
    }
     function getLockBalance() public view returns(uint) {
         if (now < start_time) {
             return lock_total;
         }

        uint256 value = release_value.mul(((now.sub(start_time)).div(31536000)).add(1));

        if (value >= lock_total) {
            return 0;
        } 
        return lock_total.sub(value);   
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount); 
    }

    
    function burnFrom(address account, uint256 amount) public onlyOwner {
        _burnFrom(account, amount); 
    }
}