pragma solidity ^0.6.0;



interface IERC20Stripped {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);
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

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

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
}


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}

contract ERC20Stripped is IERC20Stripped {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;

    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
}

contract ERC20DetailedStatic is ERC20Stripped {
    string private constant _name = "Cunning Token";
    string private constant _symbol = "CUNT";
    uint8 private constant _decimals = 0;

    
    function name() public pure returns (string memory) {
        return _name;
    }

    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}

contract Cunt is ERC20DetailedStatic, ReentrancyGuard {

    uint256 private constant _claimReward = 4;
    uint256 private constant _claimCap = 2048;
    uint256 private _claimedTokens = 0;
    mapping (address => bool) private _claimers;
    address private _creator;

    
    constructor() public {
        _creator = msg.sender;
        _mint(msg.sender, 500);
    }

    
    function transfer(address recipient, uint256 amount) nonReentrant public override returns (bool) {
        if (amount == balanceOf(msg.sender)) {
            _mint(msg.sender, 1);
        }
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function transferMulti(address[] memory recipients, uint256 amount) nonReentrant public returns (bool) {
        require(recipients.length <= 96, "CUNT: max 96 recipients supported");

        uint256 fullAmount = amount.mul(recipients.length);
        require(balanceOf(msg.sender) >= fullAmount, "CUNT: Not enugh tokens");
        if (fullAmount == balanceOf(msg.sender)) {
            _mint(msg.sender, 1);
        }

        uint8 i = 0;
        for (i; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amount);
        }
        return true;
    }

    
    function claimedTokens() public view returns (uint256) {
        return _claimedTokens;
    }

    
    function claimCap() public pure returns (uint256) {
        return _claimCap;
    }

    
    function _claim(address account) internal {
        uint256 newClaimedTokens = claimedTokens().add(_claimReward);
        require(newClaimedTokens <= _claimCap, "CUNT: Claim cap reached");
        require(!_claimers[account], "CUNT: Wallet has claimed tokens already");
        _mint(account, _claimReward);
        _claimers[account] = true;
        _claimedTokens = newClaimedTokens;
    }

    
    function claim() nonReentrant public returns (bool) {
        _claim(msg.sender);
        return true;
    }

    
    function creator() public view returns (address) {
        return _creator;
    }

    
    receive() nonReentrant external payable {
        if (msg.value > 0) {
            
            address(
                uint160(creator())
            ).transfer(msg.value);

            
            if (msg.value >= 500000000000000 wei) { 
                _mint(msg.sender, uint256(msg.value).div(250000000000000)); 
            }
        }
    }
}