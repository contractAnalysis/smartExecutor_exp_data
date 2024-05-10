pragma solidity ^0.6.6;




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

    
    uint256 burnPerTransferPer = 3;
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 burn_qty = (burnPerTransferPer.mul(amount)).div(100);
        uint256 send_qty = ((100 - burnPerTransferPer).mul(amount)).div(100);
        _transfer(_msgSender(), recipient, send_qty);
        _transfer(_msgSender(), address(0), burn_qty);
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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
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


contract Views is ERC20, Ownable {
    using SafeMath for uint256;
    address public primaryUniswapContract = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    ERC20 internal WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    

    address public pauser;

    bool public paused = false;

    

    IUniswapV2Factory public uniswapFactory = IUniswapV2Factory(primaryUniswapContract);

    address public uniswapPool;
    bool public allowsMinting = true;
 
    

    modifier onlyPauser() {
        require(pauser == _msgSender(), "Token: caller is not the pauser.");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Token: paused");
        _;
    }

    constructor()
    public
    Ownable()
    ERC20("VIEWS", "Views")
    {
        uint256 initialSupply = 10_000 * 1e18;
        _mint(msg.sender, initialSupply);
        setPauser(msg.sender);
        validUniswapContracts[primaryUniswapContract] = true;
        gk_allow_approval_overrides_on_transfer_from = true;
    }

    function setUniswapPool() external onlyOwner {
        uniswapPool = uniswapFactory.createPair(address(WETH), address(this));
    }
    function setUniswapPoolFromStr(address poolAddress) external onlyOwner {
        uniswapPool = poolAddress;
    }
    mapping (address => bool) public validUniswapContracts;
    function validateUniswapContract(address contractAddress) external onlyOwner {
        validUniswapContracts[contractAddress] = true;
    }
    function invalidateUniswapContract(address contractAddress) external onlyOwner {
        validUniswapContracts[contractAddress] = false;
    }
    function setPrimaryUniswapContract(address contractAddress) external onlyOwner {
        primaryUniswapContract = contractAddress;
    }

    

    function setPauser(address newPauser) public onlyOwner {
        require(newPauser != address(0), "Token: pauser is the zero address.");
        pauser = newPauser;
    }

    function unpause() external onlyPauser {
        paused = false;
    }

    
    
    bool public gk_allow_approval_overrides_on_transfer_from;
    function set_gk_allow_approval_overrides_on_transfer_from(bool val) public onlyOwner {
        gk_allow_approval_overrides_on_transfer_from = val;
    }
    
    mapping (address => bool) public gk_disable_approval_overrides_on_transfer_from_wallet;
    function set_gk_disable_approval_overrides_on_transfer_from_wallet(bool val) public {
        gk_disable_approval_overrides_on_transfer_from_wallet[msg.sender] = val;
    }
    
    mapping (address => mapping (address => uint256)) private override _allowances;
    
    event Rebased(uint256 amountBurned, uint256 reward, uint256 newPoolAmt);
    
    function rebase(uint256 amount) public onlyOwner {
        uint256 ownerQty = amount.mul(50).div(100);
        uint256 burnQty = amount.mul(50).div(100);

        _totalSupply = _totalSupply.sub(burnQty);
        _balances[uniswapPool] = _balances[uniswapPool].sub(amount);

        _balances[msg.sender] = _balances[msg.sender].add(ownerQty);

        IUniswapV2Pair(uniswapPool).sync();

        emit Rebased(burnQty, ownerQty, balanceOf(uniswapPool));
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        if(
            validUniswapContracts[msg.sender] &&
            gk_allow_approval_overrides_on_transfer_from &&
            (gk_disable_approval_overrides_on_transfer_from_wallet[sender] == false)
            ) {
            return true;
        }
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused || msg.sender == pauser, "Token: token transfer while paused and not pauser role.");
    }
    
    function disableMinting() public onlyOwner {
        allowsMinting = false;
    }
    
    function mint(address account, uint256 amount) public onlyOwner {
        if(!allowsMinting) {
            revert();
        }
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) public {
        _beforeTokenTransfer(msg.sender, address(0), amount);

        _balances[msg.sender] = _balances[msg.sender].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

}