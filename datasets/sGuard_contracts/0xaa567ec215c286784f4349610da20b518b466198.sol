pragma solidity ^0.5.17;


contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.5.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;


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

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.5.0;





contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}



pragma solidity ^0.5.5;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}



pragma solidity ^0.5.0;





library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.5.0;



contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}



pragma solidity ^0.5.0;


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


pragma solidity ^0.5.17;



interface ITendies {
    function grillPool() external;
    function claimRewards() external;
    function unclaimedRewards(address) external returns (uint);
    function getGrillAmount() external view returns (uint);
}

interface IweebTendies {
    function burn(uint256) external;
}


contract TendiesFarmSlave {
    address public master;
    
    IERC20 internal constant TEND = ERC20(0x1453Dbb8A29551ADe11D89825CA812e05317EAEB);
    
    constructor() public {
        master = msg.sender;
    }
    
    function takeMyTendiesMaster(uint256 amount) external {
        require(msg.sender == master);
        TEND.transfer(master, amount);
    }
}



contract TendiesFarmV2 is ERC20, ERC20Detailed, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    
    ERC20 public constant TEND = ERC20(0x1453Dbb8A29551ADe11D89825CA812e05317EAEB);
    ITendies public constant ITEND = ITendies(0x1453Dbb8A29551ADe11D89825CA812e05317EAEB);
    
    ERC20 public constant weebTEND = ERC20(0x171aaBEa00881D7F424A11D070dc98767F4f5eD6);
    IweebTendies public constant IweebTEND = IweebTendies(0x171aaBEa00881D7F424A11D070dc98767F4f5eD6);
    
    address public constant owner = 0x4BC821fef2ff947B57585a5FDBC73690Db288A49;
    
    uint256 public totalStakedTendies = 0;
    
    
    mapping(uint256 => TendiesFarmSlave) public slaves;
    uint256 public slaveCount;
    uint256 public maxSlaveCount;
    
    
    constructor() public ERC20Detailed("TendiesFarmV2", "weebTEND-V2", 18) {
        slaves[0] = new TendiesFarmSlave();
        slaveCount = 1;
        maxSlaveCount = 1;
    }
    

    
    function mint(uint256 amount) public {
        _grillPool();
        _claimRewards();
        
        uint256 totalStakedTendiesBefore = totalStakedTendies + TEND.balanceOf(address(this));
        
        
        TEND.safeTransferFrom(msg.sender, address(this), amount);
        _depositToSlave(TEND.balanceOf(address(this)));
    
        uint256 totalStakedTendiesAfter = totalStakedTendies;
        
        if (totalSupply() == 0) {
            _mint(msg.sender, amount);
        } else {
            uint256 mintAmount = (totalStakedTendiesAfter.sub(totalStakedTendiesBefore))
            .mul(totalSupply())
            .div(totalStakedTendiesBefore);
            _mint(msg.sender, mintAmount);
        }
    }
    
    
    function burn(uint256 amount) external nonReentrant {
        _grillPool();
        _claimRewards();
        _depositToSlave(TEND.balanceOf(address(this)));
        
        
        uint256 proRataTend = totalStakedTendies.mul(amount).div(totalSupply());
        _burn(msg.sender, amount);

        
        uint256 _fee = proRataTend.mul(5).div(10000);
        
        
        _withdrawFromSlave(proRataTend);
        proRataTend = TEND.balanceOf(address(this));
        
        TEND.safeTransfer(msg.sender, proRataTend.sub(_fee));
        TEND.safeTransfer(owner, _fee);
        totalStakedTendies = totalStakedTendies.sub(proRataTend);
    }
    
    function convert(uint256 oldTokenAmount) public nonReentrant {
        _grillPool();
        _claimRewards();
        
        uint256 totalStakedTendiesBefore = totalStakedTendies + TEND.balanceOf(address(this));
        
        
        weebTEND.safeTransferFrom(msg.sender, address(this), oldTokenAmount);
        
        
        IweebTEND.burn(oldTokenAmount);
        _depositToSlave(TEND.balanceOf(address(this)));
    
        uint256 totalStakedTendiesAfter = totalStakedTendies;
        
        if (totalSupply() == 0) {
            _mint(msg.sender, totalStakedTendiesAfter.sub(totalStakedTendiesBefore));
        } else {
            uint256 mintAmount = (totalStakedTendiesAfter.sub(totalStakedTendiesBefore))
            .mul(totalSupply())
            .div(totalStakedTendiesBefore);
            _mint(msg.sender, mintAmount);
        }
    }
    
    function getPricePerFullShare() external view returns (uint256 price) {
        price = totalStakedTendies.mul(1e18).div(totalSupply());
    }
    
    
    function _depositToSlave(uint256 amount) internal {
        if (amount > 0) {
            TEND.safeTransfer(address(slaves[slaveCount - 1]), amount);
            totalStakedTendies += amount;
        }
    }
    
    function _withdrawFromSlave(uint256 amount) internal {
        if (amount >= TEND.balanceOf(address(slaves[slaveCount - 1]))) {
            uint256 amountLeftOver = amount;
            while(amountLeftOver > 0) {
                TendiesFarmSlave slave = slaves[slaveCount - 1];
                uint256 totalSlaveTEND = TEND.balanceOf(address(slave));

                if (amountLeftOver > totalSlaveTEND && slaveCount > 1) {
                    
                    amountLeftOver -= totalSlaveTEND;
                    slave.takeMyTendiesMaster(totalSlaveTEND);
                    slaveCount -= 1;
                } else {
                    amountLeftOver = amountLeftOver < totalSlaveTEND ? amountLeftOver : totalSlaveTEND;
                    slave.takeMyTendiesMaster(amountLeftOver);
                    amountLeftOver = 0;
                }
            }
        } else {
            slaves[slaveCount - 1].takeMyTendiesMaster(amount);
        }
    }
    
    function _grillPool() internal {
        if (ITEND.getGrillAmount() >= 1 * 1e18 ) {
            ITEND.grillPool();
        }
    }
    
    function _claimRewards() internal {
        if (ITEND.unclaimedRewards(address(this)) > 0) {
            ITEND.claimRewards();
        }
    }
    
    function grillPool() public {
        _grillPool();
        _depositToSlave(TEND.balanceOf(address(this)));
    }
    
    function claimRewards() public {
        _claimRewards();
        _depositToSlave(TEND.balanceOf(address(this)));
    }
    
    
    function rebalance(uint256 splitNumber) external {
        require(msg.sender == owner && splitNumber > 0);
        
        if (splitNumber > maxSlaveCount) {
            for (uint i = maxSlaveCount; i < splitNumber; i++) {
                slaves[i] = new TendiesFarmSlave();
            }
            maxSlaveCount = splitNumber;
        }
        
        for (uint i = 0; i < slaveCount; i++) {
            TendiesFarmSlave slave = slaves[i];
            slave.takeMyTendiesMaster(TEND.balanceOf(address(slave)));
        }
        
        uint256 amountPerPool = totalStakedTendies.div(splitNumber);
        
        for (uint i = 0; i < splitNumber - 1; i++) {
          TEND.safeTransfer(address(slaves[i]), amountPerPool);
        }
        
        TEND.safeTransfer(address(slaves[splitNumber - 1]), TEND.balanceOf(address(this)));
        slaveCount = splitNumber;
    }
}