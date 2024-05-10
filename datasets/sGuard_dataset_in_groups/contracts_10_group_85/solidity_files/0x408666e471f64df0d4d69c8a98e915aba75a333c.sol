pragma solidity 0.5.14;


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


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract LexDAORole is Context {
    using Roles for Roles.Role;

    event LexDAOAdded(address indexed account);
    event LexDAORemoved(address indexed account);

    Roles.Role private _lexDAOs;

    modifier onlyLexDAO() {
        require(isLexDAO(_msgSender()), "LexDAORole: caller does not have the LexDAO role");
        _;
    }
    
    function isLexDAO(address account) public view returns (bool) {
        return _lexDAOs.has(account);
    }

    function addLexDAO(address account) public onlyLexDAO {
        _addLexDAO(account);
    }

    function renounceLexDAO() public {
        _removeLexDAO(_msgSender());
    }

    function _addLexDAO(address account) internal {
        _lexDAOs.add(account);
        emit LexDAOAdded(account);
    }

    function _removeLexDAO(address account) internal {
        _lexDAOs.remove(account);
        emit LexDAORemoved(account);
    }
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

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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

    
    function _setupDecimals(uint8 decimals_) internal {
        require(!address(this).isContract(), "ERC20: decimals cannot be changed after construction");
        _decimals = decimals_;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }
}


contract ERC20Burnable is Context, ERC20 {
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    
    function burnFrom(address account, uint256 amount) public {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


contract ERC20Capped is ERC20 {
    uint256 private _cap;

    
    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { 
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
    }
}

contract OfferToken is LexDAORole, ERC20Burnable, ERC20Capped {
    using SafeMath for uint256;
    
    
    address payable private _owner; 
    uint256 public min; 
    uint256 public rate; 
    bool public closed; 
    
    
    uint256 public RR; 
    string public offer; 
    
    mapping (uint256 => requests) public redemptions; 
    
    event Redeemed(address indexed redeemer, uint256 indexed index);
    event Responded(address indexed responder, uint256 indexed index);
    event Reviewed(address indexed reviewer, uint256 indexed index);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    struct requests { 
        address requester; 
        uint256 rNumber; 
        uint256 timeStamp; 
        string details; 
        string response; 
        string review;
        bool responded;
    }
    
    constructor(
        address _lexDAO,
        address payable _offeror,
        uint8 _decimals,
        uint256 cap,
        uint256 _init, 
        uint256 _min,
        uint256 _rate,
        string memory _name, 
        string memory _symbol, 
        string memory _offer) public ERC20(_name, _symbol) ERC20Capped(cap) {
        min = _min;
        rate = _rate;
        offer = _offer;
        _addLexDAO(_lexDAO); 
        _mint(_offeror, _init); 
        _setupDecimals(_decimals); 
        _transferOwnership(_offeror); 
    }

    
    function buyOfferToken() public payable { 
        require(closed == false); 
        
        _mint(msg.sender, msg.value.mul(rate)); 
        _owner.transfer(msg.value); 
    }
    
    function redeemOfferToken(string memory details) public {
        uint256 rNumber = RR.add(1); 
        RR = RR.add(1); 
        
        redemptions[rNumber] = requests( 
            msg.sender,
            rNumber,
            now,
            details,
            "PENDING",
            "RESERVED",
            false);
            
        _burn(_msgSender(), min); 
        emit Redeemed(msg.sender, rNumber);
    }
    
    function writeRedemptionReview(uint256 rNumber, string memory review) public {
        requests storage rr = redemptions[rNumber]; 
        require(msg.sender == rr.requester); 
        require(rr.responded == true); 

        rr.review = review; 
        emit Reviewed(msg.sender, rNumber);
   }
    
    
    
    
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

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    
    function adjustOfferRate(uint256 newRate) public onlyOwner { 
        rate = newRate;
    }
    
    function updateOfferStatus(bool offerClosed) public onlyOwner { 
        closed = offerClosed;
    }
    
    function writeRedemptionResponse(uint256 rNumber, string memory response) public onlyOwner { 
        requests storage rr = redemptions[rNumber]; 
        
        rr.response = response;
        rr.responded = true;
        emit Responded(msg.sender, rNumber);
    }
    
    
    function lexDAOburn(address account, uint256 amount) public onlyLexDAO returns (bool) {
        _burn(account, amount); 
        return true;
    }
    
    function lexDAOmint(address account, uint256 amount) public onlyLexDAO returns (bool) {
        _mint(account, amount); 
        return true;
    }
    
    function lexDAOtransfer(address from, address to, uint256 amount) public onlyLexDAO returns (bool) {
        _transfer(from, to, amount); 
        return true;
    }
}