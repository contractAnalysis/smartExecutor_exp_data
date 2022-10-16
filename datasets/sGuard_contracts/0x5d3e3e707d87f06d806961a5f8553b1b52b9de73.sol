pragma solidity ^0.5.10;




library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
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




contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
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
        return msg.sender == _owner;
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



contract OperatorRole {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    constructor() internal {
        _addOperator(msg.sender);
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function addOperator(address account) public onlyOperator {
        _addOperator(account);
    }

    function renounceOperator() public {
        _removeOperator(msg.sender);
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}




contract Contributions is OperatorRole, TokenRecover {
    using SafeMath for uint256;

    struct Contributor {
        uint256 weiAmount;
        uint256 tokenAmount;
        bool exists;
    }

    
    uint256 private _totalSoldTokens;

    
    uint256 private _totalWeiRaised;

    
    address[] private _addresses;

    
    mapping(address => Contributor) private _contributors;

    constructor() public {} 

    
    function totalSoldTokens() public view returns (uint256) {
        return _totalSoldTokens;
    }

    
    function totalWeiRaised() public view returns (uint256) {
        return _totalWeiRaised;
    }

    
    function getContributorAddress(uint256 index) public view returns (address) {
        return _addresses[index];
    }

    
    function getContributorsLength() public view returns (uint) {
        return _addresses.length;
    }

    
    function weiContribution(address account) public view returns (uint256) {
        return _contributors[account].weiAmount;
    }

    
    function tokenBalance(address account) public view returns (uint256) {
        return _contributors[account].tokenAmount;
    }

    
    function contributorExists(address account) public view returns (bool) {
        return _contributors[account].exists;
    }

    
    function addBalance(address account, uint256 weiAmount, uint256 tokenAmount) public onlyOperator {
        if (!_contributors[account].exists) {
            _addresses.push(account);
            _contributors[account].exists = true;
        }

        _contributors[account].weiAmount = _contributors[account].weiAmount.add(weiAmount);
        _contributors[account].tokenAmount = _contributors[account].tokenAmount.add(tokenAmount);

        _totalWeiRaised = _totalWeiRaised.add(weiAmount);
        _totalSoldTokens = _totalSoldTokens.add(tokenAmount);
    }

    
    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }
}