pragma solidity ^0.5.0;

interface IERC20 {
     function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    
     function mint(address recipient, uint256 amount) external returns (bool);

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

contract MajaToken is IERC20{
    
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping(address => bool) private minters;
    address public owner;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        owner = msg.sender;
        minters[msg.sender] = true;
    } 
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyMinters(){
        require(minters[msg.sender]);
        _;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    

    function addMinter() public {
        minters[msg.sender] = false;
        
    }
    
    
    function getStatus() public view returns (bool) {
        return minters[msg.sender];
    }
    
    
    
    function approveMinter(address _minter) public onlyOwner {
       if(!minters[_minter]){
            minters[_minter] = true;
       }
    }

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    
    function mint(address recipient, uint256 amount) public onlyMinters returns (bool) {
        _mint(recipient, amount);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
       
    }

    function _mint(address account, uint256 amount) public onlyMinters {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(value);
        _totalSupply = _totalSupply.sub(value);
       
    }

    
}