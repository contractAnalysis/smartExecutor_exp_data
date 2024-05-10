pragma solidity ^0.5.11;

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function balanceOf(address _target) external view returns (uint256);
    function allowance(address _target, address _spender) external view returns (uint256);
}



pragma solidity ^0.5.11;

interface IMint {
    function mint(uint256 _value) external returns (bool);
    function finishMint() external returns (bool);
}



pragma solidity ^0.5.11;

interface IBurn {
    function burn(uint256 _value) external returns(bool);
}



pragma solidity ^0.5.11;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() external view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.5.11;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
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

    
    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.5.11;



contract Freezer is Ownable {
    event Freezed(address dsc);
    event Unfreezed(address dsc);

    mapping(address => bool) public freezing;

    modifier isFreezed(address src) {
        require(freezing[src] == false, "Freeze/Fronzen-Account");
        _;
    }

    
    function freeze(address dsc) external onlyOwner {
        require(dsc != address(0), "Freeze/Zero-Address");
        require(freezing[dsc] == false, "Freeze/Already-Freezed");

        freezing[dsc] = true;

        emit Freezed(dsc);
    }

    
    function unFreeze(address dsc) external onlyOwner {
        require(freezing[dsc] == true, "Freeze/Already-Unfreezed");

        delete freezing[dsc];

        emit Unfreezed(dsc);
    }
}



pragma solidity ^0.5.11;



contract Pauser is Ownable {
    event Pause(address pauser);
    event Resume(address resumer);

    bool public pausing;

    modifier isPause() {
        require(pausing == false, "Pause/Pause-Functionality");
        _;
    }

    function pause() external onlyOwner {
        require(pausing == false, "Pause/Already-Pausing");

        pausing = true;

        emit Pause(msg.sender);
    }

    function resume() external onlyOwner {
        require(pausing == true, "Pause/Already-Resuming");

        pausing = false;

        emit Resume(msg.sender);
    }
}



pragma solidity ^0.5.11;




contract Locker is Ownable {
    event LockedUp(address target, uint256 value);

    using SafeMath for uint256;

    mapping(address => uint256) public lockup;

    modifier isLockup(address _target, uint256 _value) {
        uint256 balance = IERC20(address(this)).balanceOf(_target);
        require(
            balance.sub(_value, "Locker/Underflow-Value") >= lockup[_target],
            "Locker/Impossible-Over-Lockup"
        );
        _;
    }

    function lock(address target, uint256 value) internal onlyOwner returns (bool) {
        lockup[target] = lockup[target].add(value);
        emit LockedUp(target, lockup[target]);
    }

    function decreaseLockup(address target, uint256 value) external onlyOwner returns (bool) {
        require(lockup[target] > 0, "Locker/Not-Lockedup");

        lockup[target] = lockup[target].sub(value, "Locker/Impossible-Underflow");

        emit LockedUp(target, lockup[target]);
    }

    function deleteLockup(address target) external onlyOwner returns (bool) {
        require(lockup[target] > 0, "Locker/Not-Lockedup");

        delete lockup[target];

        emit LockedUp(target, 0);
    }
}



pragma solidity ^0.5.11;



contract Minter is Ownable {
    event Finished();

    bool public minting;

    modifier isMinting() {
        require(minting == true, "Minter/Finish-Minting");
        _;
    }

    constructor() public {
        minting = true;
    }

    function finishMint() external onlyOwner returns (bool) {
        require(minting == true, "Minter/Already-Finish");

        minting = false;

        emit Finished();

        return true;
    }
}



pragma solidity ^0.5.11;











contract Xank is IERC20, IMint, IBurn, Ownable, Freezer, Pauser, Locker, Minter {
    using SafeMath for uint256;

    string public constant name = "Xank";
    string public constant symbol = "XANK";
    uint8 public constant decimals = 16;
    uint256 public totalSupply = 1000000000;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private approved;

    constructor() public Minter() {
        totalSupply = totalSupply.mul(10**uint256(decimals));
        balances[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value)
        external
        isFreezed(msg.sender)
        isLockup(msg.sender, value)
        isPause
        returns (bool)
    {
        require(to != address(0), "Xank/Not-Allow-Zero-Address");

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferWithLockup(address to, uint256 value)
        external
        onlyOwner
        isLockup(msg.sender, value)
        isPause
        returns (bool)
    {
        require(to != address(0), "Xank/Not-Allow-Zero-Address");

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);

        lock(to, value);

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        external
        isFreezed(from)
        isLockup(from, value)
        isPause
        returns (bool)
    {
        require(from != address(0), "Xank/Not-Allow-Zero-Address");
        require(to != address(0), "Xank/Not-Allow-Zero-Address");

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        approved[from][msg.sender] = approved[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;
    }

    function mint(uint256 value) external isMinting onlyOwner isPause returns (bool) {
        totalSupply = totalSupply.add(value);
        balances[msg.sender] = balances[msg.sender].add(value);

        emit Transfer(address(0), msg.sender, value);

        return true;
    }

    function burn(uint256 value) external isPause returns (bool) {
        require(value <= balances[msg.sender], "Xank/Not-Allow-Unvalued-Burn");

        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);

        emit Transfer(msg.sender, address(0), value);

        return true;
    }

    function approve(address spender, uint256 value) external isPause returns (bool) {
        require(spender != address(0), "Xank/Not-Allow-Zero-Address");
        approved[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);

        return true;
    }

    function balanceOf(address target) external view returns (uint256) {
        return balances[target];
    }

    function allowance(address target, address spender) external view returns (uint256) {
        return approved[target][spender];
    }
}



pragma solidity ^0.5.11;



contract Airdropper is Ownable{
    Xank internal _xank;
    constructor(address xank) public {
        _xank = Xank(xank);
    }

    function airdropNoLock(address[] memory recipient, uint256[] memory amount) onlyOwner public{
        require(_xank.owner() == address(this), "NoLock/has to be owner");
        require(recipient.length == amount.length, "NoLock/should have same length array");
        _xank.transferFrom(msg.sender, address(this), _xank.balanceOf(msg.sender));
        for(uint256 i=0; i<recipient.length; i++){
            _xank.transfer(recipient[i], amount[i]);
        }

        _xank.transferOwnership(msg.sender);
        _xank.transfer(msg.sender, _xank.balanceOf(address(this)));
    }

    function airdropWithLock(address[] memory recipient, uint256[] memory amount) onlyOwner public{
        require(_xank.owner() == address(this), "WithLock/has to be owner");
        require(recipient.length == amount.length, "WithLock/should have same length array");
        _xank.transferFrom(msg.sender, address(this), _xank.balanceOf(msg.sender));
        for(uint256 i=0; i<recipient.length; i++){
            _xank.transferWithLockup(recipient[i], amount[i]);
        }

        _xank.transferOwnership(msg.sender);
        _xank.transfer(msg.sender, _xank.balanceOf(address(this)));
    }
}