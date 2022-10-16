pragma solidity ^0.4.26;



















contract ApproveAndCall {
    function receiveApproval(address _from, uint256 _amount, address _tokenContract, bytes _data) public returns (bool);
}


contract ERC20 {
    function transfer(address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender) public view returns (uint256);
}


contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    
    constructor() public {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
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
        return a - b;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

}

contract ZipmexTokenV1 is Ownable, ERC20 {
    using SafeMath for uint256;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event TransfersEnabled();
    event TransferRightGiven(address indexed _to);
    event TransferRightCancelled(address indexed _from);

    string internal name_;
    string internal symbol_;
    uint8 internal decimals_;
    uint256 internal totalSupply_;
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 internal version_;
    mapping(uint256 => bool) internal initialized;

    
    
    mapping(address => bool) public transferGrants;
    
    bool public transferable;

    
    modifier canTransfer() {
        require(transferable || transferGrants[msg.sender]);
        _;
    }

    
    function initialize(address tokenOwner) public {
        version_ = 1;
        require(!initialized[version_]);
        name_ = "Zipmex Token";
        symbol_ = "ZMT";
        decimals_ = 18;
        
        totalSupply_ = 200000000 * (10 ** uint256(decimals_));
        balances[tokenOwner] = totalSupply_;
        emit Transfer(address(0), tokenOwner, totalSupply_);
        transferGrants[tokenOwner] = true;
        owner = tokenOwner;

        initialized[version_] = true;
    }

    
    function transfer(address _to, uint256 _value) public canTransfer returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public canTransfer returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public canTransfer returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    
    function increaseApproval(address _spender, uint _addedValue) public canTransfer returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    
    function decreaseApproval(address _spender, uint _subtractedValue) public canTransfer returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    
    function approveAndCall(address _recipient, uint _value, bytes _data) public canTransfer returns (bool) {
        allowed[msg.sender][_recipient] = _value;
        ApproveAndCall(_recipient).receiveApproval(msg.sender, _value, address(this), _data);
        emit Approval(msg.sender, _recipient, allowed[msg.sender][_recipient]);
        return true;
    }

    
    function burn(uint256 _value) public canTransfer returns (bool) {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Transfer(burner, address(0), _value);
        return true;
    }

    
    function enableTransfers() onlyOwner public {
        require(!transferable);
        transferable = true;
        emit TransfersEnabled();
    }

    
    function grantTransferRight(address _to) onlyOwner public {
        require(!transferable);
        require(!transferGrants[_to]);
        require(_to != address(0));
        transferGrants[_to] = true;
        emit TransferRightGiven(_to);
    }

    
    function cancelTransferRight(address _from) onlyOwner public {
        require(!transferable);
        require(transferGrants[_from]);
        transferGrants[_from] = false;
        emit TransferRightCancelled(_from);
    }

    
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    
    function name() public view returns (string) {
        return name_;
    }

    
    function symbol() public view returns (string) {
        return symbol_;
    }

    
    function decimals() public view returns (uint8) {
        return decimals_;
    }

    
    function version() public view returns (uint256) {
        return version_;
    }
}