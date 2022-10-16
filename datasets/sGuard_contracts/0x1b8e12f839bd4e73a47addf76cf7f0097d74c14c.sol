pragma solidity ^0.5.0;



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

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



pragma solidity >=0.5.0 <0.6.0;



contract Initializable {

    
    bool private initialized;

    
    bool private initializing;

    
    modifier initializer() {
        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    
    function isConstructor() private view returns (bool) {
        
        
        
        
        
        uint256 cs;
        assembly { cs := extcodesize(address) }
        return cs == 0;
    }

    
    uint256[50] private ______gap;
}



pragma solidity ^0.5.0;



contract Ownable is Initializable {
    address private _owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    
    function initialize(address sender) public initializer {
        _owner = sender;
    }

    
    function owner() public view returns(address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}



pragma solidity ^0.5.0;



interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



pragma solidity ^0.5.0;





contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns(string memory) {
        return _name;
    }

    
    function symbol() public view returns(string memory) {
        return _symbol;
    }

    
    function decimals() public view returns(uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}





pragma solidity ^0.5.0;



library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    
    function mul(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        int256 c = a * b;

        
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    
    function div(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        
        require(b != -1 || a != MIN_INT256);

        
        return a / b;
    }

    
    function sub(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    
    function add(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    
    function abs(int256 a)
    internal
    pure
    returns (int256)
    {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}



pragma solidity ^0.5.0;







contract vUSD is ERC20Detailed, Ownable {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);

    
    address public monetaryPolicy;

    modifier onlyMonetaryPolicy() {
        require(msg.sender == monetaryPolicy);
        _;
    }

    bool private rebasePausedDeprecated;
    bool private tokenPausedDeprecated;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10 * 10**6 * 10**DECIMALS; 

    
    
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    
    uint256 private constant MAX_SUPPLY = ~uint128(0);  

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    
    
    mapping (address => mapping (address => uint256)) private _allowedFragments;

    mapping (address => bool) public minters;

    function addMinter(address _minter) public onlyOwner {
        minters[_minter] = true;
    }

    function removeMinter(address _minter) public onlyOwner {
        minters[_minter] = false;
    }

    function mint(address account, uint amount) public {
        require(minters[msg.sender], "!minter");
        require(account != address(0x0), "ERC20: mint to the zero address");
        uint256 gonValue = amount.mul(_gonsPerFragment);
        _totalSupply = _totalSupply.add(amount);
        _gonBalances[account] = _gonBalances[account].add(gonValue);
        emit Transfer(address(0x0), account, amount);
    }

    function burn(uint amount) public {
        require(msg.sender != address(0x0), "ERC20: burn from the zero address");
        uint256 gonValue = amount.mul(_gonsPerFragment);
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(gonValue);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(address(0x0), msg.sender, amount);
    }

    
    function setMonetaryPolicy(address monetaryPolicy_)
    external
    onlyOwner
    {
        monetaryPolicy = monetaryPolicy_;
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

    
    function rebase(uint256 epoch, int256 supplyDelta)
    external
    onlyMonetaryPolicy
    returns (uint256)
    {
        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        
        
        
        
        
        
        
        
        
        

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function initialize(address owner_)
    public
    initializer
    {
        ERC20Detailed.initialize("Value USD", "vUSD", uint8(DECIMALS));
        Ownable.initialize(owner_);

        rebasePausedDeprecated = false;
        tokenPausedDeprecated = false;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[address(this)] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        emit Transfer(address(0x0), owner_, _totalSupply);
    }

    
    function totalSupply()
    public
    view
    returns (uint256)
    {
        return _totalSupply;
    }

    
    function balanceOf(address who)
    public
    view
    returns (uint256)
    {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    
    function transfer(address to, uint256 value)
    public
    validRecipient(to)
    returns (bool)
    {
        uint256 gonValue = value.mul(_gonsPerFragment);
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    
    function allowance(address owner_, address spender)
    public
    view
    returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    
    function transferFrom(address from, address to, uint256 value)
    public
    validRecipient(to)
    returns (bool)
    {
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        uint256 gonValue = value.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        emit Transfer(from, to, value);

        return true;
    }

    
    function approve(address spender, uint256 value)
    public
    returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue)
    public
    returns (bool)
    {
        _allowedFragments[msg.sender][spender] =
        _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }
}