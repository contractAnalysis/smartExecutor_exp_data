pragma solidity ^0.5.13;




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




contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




contract TokenRecover is Ownable {

    
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}




contract AirDrop is TokenRecover {
    using SafeMath for uint256;

    
    IERC20 private _token;

    
    uint256 private _cap;

    
    address private _wallet;

    
    uint256 private _distributedTokens;

    
    mapping(address => uint256) private _receivedTokens;

    
    constructor(IERC20 token, uint256 cap, address wallet) public {
        require(address(token) != address(0));
        require(cap > 0);
        require(wallet != address(0));

        _token = token;
        _cap = cap;
        _wallet = wallet;
    }

    
    function token() public view returns (IERC20) {
        return _token;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function wallet() public view returns (address) {
        return _wallet;
    }

    
    function distributedTokens() public view returns (uint256) {
        return _distributedTokens;
    }

    
    function receivedTokens(address account) public view returns (uint256) {
        return _receivedTokens[account];
    }

    
    function remainingTokens() public view returns (uint256) {
        return _cap.sub(_distributedTokens);
    }

    
    function multiSend(address[] memory accounts, uint256[] memory amounts) public onlyOwner {
        require(accounts.length > 0);
        require(amounts.length > 0);
        require(accounts.length == amounts.length);

        for (uint i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint256 amount = amounts[i];

            if (_receivedTokens[account] == 0) {
                _receivedTokens[account] = _receivedTokens[account].add(amount);
                _distributedTokens = _distributedTokens.add(amount);

                require(_distributedTokens <= _cap);

                _distributeTokens(account, amount);
            }
        }
    }

    
    function _distributeTokens(address account, uint256 amount) internal {
        _token.transferFrom(_wallet, account, amount);
    }
}