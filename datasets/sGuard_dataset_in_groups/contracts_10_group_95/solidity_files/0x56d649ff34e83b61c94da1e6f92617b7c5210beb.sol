pragma solidity 0.6.10;


library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) internal {
        require(initialOwner != address(0), "Ownable: initial owner is the zero address");
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_isOwner(msg.sender), "Ownable: caller is not the owner");
        _;
    }

    function _isOwner(address account) internal view returns (bool) {
        return account == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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


contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

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
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0));

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }

}


contract ERC20Burnable is ERC20 {

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

}


abstract contract ERC20Mintable is ERC20Burnable, Ownable {

    address[] internal _minters;

    mapping (address => Minter) public minterInfo;
    struct Minter {
        bool active;
        uint256 limit;
        uint256 minted;
    }

    modifier canMint(uint256 amount) virtual {
        require(isMinter(msg.sender), "Caller has no permission");
        require(minterInfo[msg.sender].minted.add(amount) <= minterInfo[msg.sender].limit, "Minter limit overflow");
        minterInfo[msg.sender].minted = minterInfo[msg.sender].minted.add(amount);
        _;
    }

    function mint(address account, uint256 amount) public canMint(amount) returns (bool) {
        _mint(account, amount);
        return true;
    }

    function setMinter(address account, uint256 limit) public onlyOwner {
        require(account != address(0));

        if (!minterInfo[account].active && limit > 0) {
            _minters.push(account);
            minterInfo[account].active = true;
        }

        if (limit > minterInfo[account].minted) {
            minterInfo[account].limit = limit;
        } else {
            minterInfo[account].limit = minterInfo[account].minted;
        }
    }

    function isMinter(address account) public view returns (bool) {
        return(minterInfo[account].active);
    }

    function getMinters() public view returns(address[] memory) {
        return _minters;
    }

    function getMintersInfo() public view returns(uint256 amountOfMinters, uint256 totalLimit, uint256 totalMinted) {
        amountOfMinters = _minters.length;
        for (uint256 i = 0; i < amountOfMinters; i++) {
            totalLimit += minterInfo[_minters[i]].limit;
            totalMinted += minterInfo[_minters[i]].minted;
        }
        return (amountOfMinters, totalLimit, totalMinted);
    }

}


abstract contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) virtual external;
}


contract FinandyToken is ERC20Mintable {

    
    uint256 public INITIAL_SUPPLY = 100000000 * 10 ** 8;

    
    uint256 public MAXIMUM_SUPPLY = 200000000 * 10 ** 8;

    
    mapping (address => bool) private _contracts;

    
    modifier canMint(uint256 amount) override {
        require(isMinter(msg.sender), "Caller has no permission");
        require(minterInfo[msg.sender].minted.add(amount) <= minterInfo[msg.sender].limit, "Minter limit overflow");
        require(totalSupply().add(amount) <= MAXIMUM_SUPPLY, "Total supply cannot exceed the cap");
        minterInfo[msg.sender].minted = minterInfo[msg.sender].minted.add(amount);
        _;
    }

    
    constructor(address initialOwner, address recipient) public Ownable(initialOwner) {

        
        _name = "Finandy";
        
        _symbol = "FIN";
        
        _decimals = 8;

        
        _mint(recipient, INITIAL_SUPPLY);

    }

    
    function transfer(address to, uint256 value) public override returns (bool) {

        if (_contracts[to]) {
            approveAndCall(to, value, new bytes(0));
        } else {
            super.transfer(to, value);
        }

        return true;

    }

    
    function approveAndCall(address spender, uint256 amount, bytes memory extraData) public returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    
    function registerContract(address account) external onlyOwner {
        require(_isContract(account), "DigexToken: account is not a smart-contract");
        _contracts[account] = true;
    }

    
    function unregisterContract(address account) external onlyOwner {
        require(isRegistered(account), "DigexToken: account is not registered yet");
        _contracts[account] = false;
    }

    
    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {

        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        IERC20(ERC20Token).transfer(recipient, amount);

    }

    
    function isRegistered(address account) public view returns (bool) {
        return _contracts[account];
    }

    
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

}