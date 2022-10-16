pragma solidity 0.6.8;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    }

interface PerlinDAO {
    function isPerlinDAO() external view returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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
}
    
contract Perlin is ERC20 {
    using SafeMath for uint256;

    
    string public name; string public symbol;
    uint256 public decimals; uint256 public override totalSupply;

    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    
    uint256 one;
    bool public emitting;
    uint256 public emissionCurve;
    uint256 baseline;
    uint256 public totalCap;
    uint256 public secondsPerEra;
    uint256 public currentEra;
    uint256 public nextEraTime;

    address public incentiveAddress;
    address public DAO;
    address public perlin1;
    address public burnAddress;

    
    event NewCurve(address indexed DAO, uint256 newCurve);
    event NewIncentiveAddress(address indexed DAO, address newIncentiveAddress);
    event NewDuration(address indexed DAO, uint256 newDuration);
    event NewDAO(address indexed DAO, address newOwner);
    event NewEra(uint256 currentEra, uint256 nextEraTime, uint256 emission);

    
    modifier onlyDAO() {
        require(msg.sender == DAO, "Must be DAO");
        _;
    }

    
    
    constructor() public {
        name = 'Perlin';
        symbol = 'PERL';
        decimals = 18;
        one = 10 ** decimals;
        totalSupply = 0;
        totalCap = 3 * 10**9 * one; 
        emissionCurve = 2048;
        emitting = false;
        currentEra = 1;
        secondsPerEra = 86400;
        nextEraTime = now + secondsPerEra;
        DAO = 0x3F2a2c502E575f2fd4053c76f4E21623143518d8;
        perlin1 = 0xb5A73f5Fc8BbdbcE59bfD01CA8d35062e0dad801;
        baseline = 1033200000 * one; 
        burnAddress = 0x0000000000000000000000000000000000000001;
    }

    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        _checkEmission();
        emit Transfer(sender, recipient, amount);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply = totalSupply.add(amount);
        require(totalSupply <= totalCap, "Must not mint more than the cap");
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, msg.sender).sub(amount, "ERC20: burn amount exceeds allowance");
        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    
    function daoStartEmissions() public onlyDAO {
        emitting = true;
    }
    
    function daoStopEmissions() public onlyDAO {
        emitting = false;
    }
    
    function daoChangeEmissionCurve(uint256 newCurve) public onlyDAO {
        emissionCurve = newCurve;
        emit NewCurve(msg.sender, newCurve);
    }
    
    function daoChangeEraDuration(uint256 newDuration) public onlyDAO {
        require(newDuration >= 100, "Must be greater than 100 seconds");
        secondsPerEra = newDuration;
        emit NewDuration(msg.sender, newDuration);
    }
    
    function daoChangeIncentiveAddress(address newIncentiveAddress) public onlyDAO {
        incentiveAddress = newIncentiveAddress;
        emit NewIncentiveAddress(msg.sender, newIncentiveAddress);
    }
    
    function daoChange(address newDAO) public onlyDAO {
        if (isContract(newDAO)) {
            require(PerlinDAO(newDAO).isPerlinDAO(), "Must be DAO");
        }
        DAO = newDAO;
        emit NewDAO(msg.sender, newDAO);
    }
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    
    function daoPurge() public onlyDAO {
        DAO = address(0);
        emit NewDAO(msg.sender, address(0));
    }

    
    
    function _checkEmission() private {
        if ((now >= nextEraTime) && emitting) {                                            
            currentEra = currentEra.add(1);                                                
            nextEraTime = now.add(secondsPerEra);                                          
            uint256 _emission = getDailyEmission();                                        
            _mint(incentiveAddress, _emission);                                            
            emit NewEra(currentEra, nextEraTime, _emission);                               
        }
    }
    
    function getDailyEmission() public view returns (uint256) {
        
        
        uint adjustedCap = (totalCap.mul(totalSupply)).div(baseline);
        return (adjustedCap.sub(totalSupply)).div(emissionCurve);
    }
    
    
    function upgrade() public {
        uint balance = ERC20(perlin1).balanceOf(msg.sender);
        require(ERC20(perlin1).transferFrom(msg.sender, burnAddress, balance));
        uint factor = 10**9;   
        _mint(msg.sender, balance.mul(factor));  
    }
}