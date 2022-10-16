pragma solidity 0.5.16;










contract ShareToken {
    using SafeMath for uint256;

    
    
    

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event DividendWithdrawal(address indexed account, uint256 amount);

    event Announce(string message);

    
    
    

    string  constant private _name = "Shares";

    string  constant private _symbol = "SHARE";

    uint8   constant private _decimals = 18;

    uint256 constant private _totalSupply = 1e8 * (10 ** uint256(_decimals));

    address constant private _speaker = 0x13f194f9141325c3C8c25b36772Ee5CF35c2ef3a;

    
    
    

    struct Dividend {
        uint256 checkpoint; 
        uint256 dividendBalance; 
    }

    uint256 private _totalEthWithdrawals; 

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => Dividend) private _dividends;

    
    
    

    function() external payable {}

    constructor () public {
        
        _balances[0x6Da435A99877EB20b00DF4fD8Ea80A67Ecf39ADb] = _totalSupply.div(4);
        emit Transfer(address(0), 0x6Da435A99877EB20b00DF4fD8Ea80A67Ecf39ADb, _totalSupply.div(4));

        _balances[0xfcC65D8B75a902D0e25e968B003fcbAd4EeA9616] = _totalSupply.div(4);
        emit Transfer(address(0), 0xfcC65D8B75a902D0e25e968B003fcbAd4EeA9616, _totalSupply.div(4));

        _balances[0x036aF49114C79f3c87DaFe847dD2fF2e566cf7A9] = _totalSupply.div(4);
        emit Transfer(address(0), 0x036aF49114C79f3c87DaFe847dD2fF2e566cf7A9, _totalSupply.div(4));

        _balances[0x3504f5ea9E4AF3a31054Fb2Fe680Af65AAb92d74] = _totalSupply.div(4);
        emit Transfer(address(0), 0x3504f5ea9E4AF3a31054Fb2Fe680Af65AAb92d74, _totalSupply.div(4));
    }

    
    
    

    function _earnedSinceCheckpoint(address account) internal view returns (uint256) {
        uint256 incomeSinceLastUpdate = totalIncome().sub(_dividends[account].checkpoint);
        return incomeSinceLastUpdate.mul(_balances[account]).div(_totalSupply);
    }

    function _updateDividend(address account) internal {
        _dividends[account].dividendBalance = _dividends[account].dividendBalance.add(_earnedSinceCheckpoint(account));
        _dividends[account].checkpoint = totalIncome();
    }
   function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _updateDividend(sender);
        _updateDividend(recipient);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function _withdrawDividends(address payable account, uint256 amount) internal {
        _updateDividend(account);
        _dividends[account].dividendBalance = _dividends[account].dividendBalance.sub(amount);
        _totalEthWithdrawals = _totalEthWithdrawals.add(amount);

        emit DividendWithdrawal(account, amount);
        address(account).transfer(amount);
    }

    
    
    

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function withdrawDividends(uint256 amount) external returns (bool) {
        _withdrawDividends(msg.sender, amount);
        return true;
    }

    function announce(bytes memory b) public {
        require(msg.sender == _speaker);
        emit Announce(bytesToString(b));
    }

    function pay() external payable {}

    
    
    
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

    function totalEthWithdrawals() public view returns (uint256) {
        return _totalEthWithdrawals;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function dividendBalanceOf(address account) public view returns (uint256) {
        return _dividends[account].dividendBalance.add(_earnedSinceCheckpoint(account));
    }

    
    
    function totalIncome() public view returns (uint256) {
        return address(this).balance.add(_totalEthWithdrawals);
    }

    function stringToBytes(string memory m) public pure returns (bytes memory) {
        bytes memory b = abi.encode(m);
        return b;
    }

    function bytesToString(bytes memory b) public pure returns (string memory) {
        string memory s = abi.decode(b, (string));
        return s;
    }
}




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