pragma solidity 0.6.8;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}



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



library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    mapping (uint256 => address) public tokenHolders;
    mapping (address => uint256) public holderIDs;
    uint256 public holdersCount;
    uint256 public _minHolderAmount = 1000E18;

    
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        updateHolders(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function updateHolders(address sender, address recipient, uint256 amount) internal {
        if (_balances[sender] < _minHolderAmount) {
            
            
            tokenHolders[holderIDs[sender]] = tokenHolders[holdersCount];
            holderIDs[tokenHolders[holdersCount]] = holderIDs[sender];
            delete tokenHolders[holdersCount];
            delete holderIDs[sender];
            holdersCount--;
        }
        if (_balances[recipient] < _minHolderAmount && (_balances[recipient].add(amount) >= _minHolderAmount)) {
            
            tokenHolders[holdersCount + 1] = recipient;
            holderIDs[recipient] =  holdersCount + 1;
            holdersCount++;
        }
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        if (_balances[account] == 0) {
            
            tokenHolders[holdersCount + 1] = account;
            holderIDs[account] =  holdersCount + 1;
            holdersCount++;
        }
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IUniswapV2Pair {
    function sync() external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract WingsToken is ERC20, Ownable {
    using SafeMath for uint256;

    

    uint256 public lastBakeTime;

    uint256 public totalBaked;

    uint256 public constant BAKE_RATE = 5; 

    uint256 public constant BAKE_REWARD = 1;

    

    uint256 public constant POOL_REWARD = 48;

    uint256 public lastRewardTime;

    uint256 public rewardPool;

    mapping (address => uint256) public claimedRewards;

    mapping (address => uint256) public unclaimedRewards;

    
    mapping (uint256 => address) public topHolder;

    
    uint256 public constant MAX_TOP_HOLDERS = 50;

    uint256 internal totalTopHolders;

    

    address public pauser;

    bool public paused;

    

    ERC20 internal WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    IUniswapV2Factory public uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    address public uniswapPool;

    
    uint256 public randomRewardAmount = 5000E18;
    uint256 public randomWallets = 10;
    uint256 public _lastDistribution;

    
    address public externalCaller;

    

    modifier onlyPauser() {
        require(pauser == _msgSender(), "Wings: caller is not the pauser.");
        _;
    }

    modifier onlyExternalCaller() {
        require(externalCaller == _msgSender(), "Wings: caller is not the external caller.");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Wings: paused");
        _;
    }

    modifier when3DaysBetweenLastSnapshot() {
        require((now - lastRewardTime) >= 3 days, "Wings: not enough days since last snapshot taken.");
        _;
    }

    

    event PoolBaked(address tender, uint256 bakeAmount, uint256 newTotalSupply, uint256 newUniswapPoolSupply, uint256 userReward, uint256 newPoolReward);

    event PayoutSnapshotTaken(uint256 totalTopHolders, uint256 totalPayout, uint256 snapshot);

    event PayoutClaimed(address indexed topHolderAddress, uint256 claimedReward);

    constructor(uint256 initialSupply, address new_owner)
    public
    Ownable()
    ERC20("Wings", "WING")
    {
        uint mint_amount = initialSupply * 10 ** uint(decimals());
        _mint(new_owner, mint_amount);
        setPauser(new_owner);
        paused = true;
        transferOwnership(new_owner);
    }

    function setUniswapPool() external onlyOwner {
        require(uniswapPool == address(0), "Wings: pool already created");
        uniswapPool = uniswapFactory.createPair(address(WETH), address(this));
    }

    

    function setPauser(address newPauser) public onlyOwner {
        require(newPauser != address(0), "Wings: pauser is the zero address.");
        pauser = newPauser;
    }

    function unpause() external onlyPauser {
        paused = false;

        
        lastBakeTime = now;
        lastRewardTime = now;
        rewardPool = 0;
    }

    function pause() external onlyPauser {
        paused = true;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused || msg.sender == pauser, "Wings: token transfer while paused and not pauser role.");
    }

    

    function getInfoFor(address addr) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        return (
        balanceOf(addr),
        claimedRewards[addr],
        balanceOf(uniswapPool),
        _totalSupply,
        totalBaked,
        getBakeAmount(),
        lastBakeTime,
        lastRewardTime,
        rewardPool
        );
    }

    function bakePool() external {
        uint256 bakeAmount = getBakeAmount();
        require(bakeAmount >= 1 * 1e18, "bakePool: min bake amount not reached.");

        
        lastBakeTime = now;

        uint256 userReward = bakeAmount.mul(BAKE_REWARD).div(100);
        uint256 poolReward = bakeAmount.mul(POOL_REWARD).div(100);
        uint256 finalBake = bakeAmount.sub(userReward).sub(poolReward);

        _totalSupply = _totalSupply.sub(finalBake);
        _balances[uniswapPool] = _balances[uniswapPool].sub(bakeAmount);

        totalBaked = totalBaked.add(finalBake);
        rewardPool = rewardPool.add(poolReward);

        _balances[msg.sender] = _balances[msg.sender].add(userReward);

        IUniswapV2Pair(uniswapPool).sync();

        emit PoolBaked(msg.sender, bakeAmount, _totalSupply, balanceOf(uniswapPool), userReward, poolReward);
    }

    function getBakeAmount() public view returns (uint256) {
        if (paused) return 0;
        uint256 timeBetweenLastBake = now - lastBakeTime;
        uint256 tokensInUniswapPool = balanceOf(uniswapPool);
        uint256 dayInSeconds = 1 days;
        return (tokensInUniswapPool.mul(BAKE_RATE)
        .mul(timeBetweenLastBake))
        .div(dayInSeconds)
        .div(100);
    }

    

    function updateTopHolders(address[] calldata holders) external onlyOwner when3DaysBetweenLastSnapshot {
        totalTopHolders = holders.length < MAX_TOP_HOLDERS ? holders.length : MAX_TOP_HOLDERS;

        
        uint256 toPayout = rewardPool.div(totalTopHolders);
        uint256 totalPayoutSent = rewardPool;
        for (uint256 i = 0; i < totalTopHolders; i++) {
            unclaimedRewards[holders[i]] = unclaimedRewards[holders[i]].add(toPayout);
        }

        
        lastRewardTime = now;
        rewardPool = 0;

        emit PayoutSnapshotTaken(totalTopHolders, totalPayoutSent, now);
    }

    function claimRewards() external {
        require(unclaimedRewards[msg.sender] > 0, "Wings: nothing left to claim.");

        uint256 unclaimedReward = unclaimedRewards[msg.sender];
        unclaimedRewards[msg.sender] = 0;
        claimedRewards[msg.sender] = claimedRewards[msg.sender].add(unclaimedReward);
        _balances[msg.sender] = _balances[msg.sender].add(unclaimedReward);

        emit PayoutClaimed(msg.sender, unclaimedReward);
    }

    function distributeRandomly(uint256 seed) external onlyExternalCaller {
        require(holdersCount > 10, "There should be at least 10 holders");
        require(now.sub(_lastDistribution) >= 1 days, "You can only call this function once in a day");
        _lastDistribution = now;
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed, now, block.difficulty))).mod(holdersCount);
        if (holdersCount.sub(randomNumber) < randomWallets) {
            randomNumber = randomNumber.sub(randomWallets.sub(1));
        }
        for (uint256 i = 1; i < randomWallets + 1; i++) {
            _transfer(address(this), tokenHolders[randomNumber.add(i)], randomRewardAmount);
        }
    }

    function updateRandomWallets(uint256 randomWalletCount) external onlyOwner {
        randomWallets = randomWalletCount;
    }

    function updateRandomRewardAmount(uint256 rewardAmount) external onlyOwner {
        randomRewardAmount = rewardAmount;
    }

    function updateExternalCaller(address externalCallerAddr) external onlyOwner {
        externalCaller = externalCallerAddr;
    }

    function withdrawTokens() external onlyOwner {
        _transfer(address(this), owner(), balanceOf(address(this)));
    }

    function updateMinHolderAmount(uint256 minHolderAmount) external onlyOwner {
        _minHolderAmount = minHolderAmount;
    }
}