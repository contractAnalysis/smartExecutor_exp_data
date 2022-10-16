pragma solidity ^0.5.16;


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
    
    
    
    
    
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
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


contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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

    uint256[50] private ______gap;
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


library Math {
    
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


library Arrays {
   
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            
            
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}


library Counters {
    using SafeMath for uint256;

    struct Counter {
        
        
        
        uint256 _value; 
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


contract ERC20 is Initializable, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

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

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}


contract ERC20Snapshot is Initializable, ERC20 {

    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    
    
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    
    Counters.Counter private _currentSnapshotId;

    
    event Snapshot(uint256 id);

    
    function _snapshot() internal returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    
    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    
    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    
    
    
    function _transfer(address from, address to, uint256 value) internal {
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);

        super._transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._mint(account, value);
    }

    function _burn(address account, uint256 value) internal {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._burn(account, value);
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        
        require(snapshotId <= _currentSnapshotId.current(), "ERC20Snapshot: nonexistent id");

        
        
        
        
        
        
        
        
        
        
        
        
        

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}




library ECDSA {
    
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        
        if (signature.length != 65) {
            return (address(0));
        }

        
        bytes32 r;
        bytes32 s;
        uint8 v;

        
        
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        
        
        
        
        
        
        
        
        
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        
        return ecrecover(hash, v, r, s);
    }

    
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        
        
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract ERC20Delegatable is
    Initializable,
    ERC20
{
    using ECDSA for bytes32;

    struct DelegateBalance {
        uint128 delegatedBalance;       
        uint128 receivedBalance;        
        mapping(address => uint128) receivedFromBalances;   
    }

    

    
    mapping(address => DelegateBalance) public delegates;

    

    event Delegated(address indexed owner, address indexed recipient, uint256 amount);
    event Undelegated(address indexed owner, address indexed recipient, uint256 amount);

    

    modifier checkDelegates(address _tokenSpender, uint _amountToSpend) {
        uint balance = balanceOf(_tokenSpender);
        uint receivedBalance = delegates[_tokenSpender].receivedBalance;
        require(balance.sub(receivedBalance) >= _amountToSpend, "not enough undelgated tokens");
        _;
    }

    modifier onlyVerified(
        address delegator,
        address recipient,
        uint256 amount,
        uint256 maxAllowedTimestamp,
        bytes memory _signature 
    ) {
        require(now < maxAllowedTimestamp, "sign is expired");

        bytes32 hash = keccak256(abi.encodePacked(
            address(this),
            recipient,
            amount,
            maxAllowedTimestamp
        ));
        require(delegator == hash.recover(_signature), "This action is not verified");
        _;
    }

    

    function balanceOfWithDelegated(address account) public view returns (uint256) {
        return balanceOf(account).add(delegates[account].delegatedBalance);
    }

    function balanceOfWithoutReceived(address account) public view returns (uint256) {
        return balanceOf(account).sub(delegates[account].receivedBalance);
    }

    

    function delgate(address recipient, uint256 amount) public returns(bool) {
        _delegate(msg.sender, recipient, amount);
        return true;
    }

    function undelgate(address recipient, uint256 amount) public returns(bool) {
        _undelegate(msg.sender, recipient, amount);
        return true;
    }

    

    function delgateWithSign(
        address delegator,
        address recipient,
        uint256 amount,
        uint256 maxAllowedTimestamp,
        bytes memory _signature 
    ) public
        onlyVerified(delegator, recipient, amount, maxAllowedTimestamp, _signature)
    returns(
        bool
    ) {
        _delegate(delegator, recipient, amount);
        return true;
    }

    function undelgateWithSign(
        address delegator,
        address recipient,
        uint256 amount,
        uint256 maxAllowedTimestamp,
        bytes memory _signature 
    ) public
        onlyVerified(delegator, recipient, amount, maxAllowedTimestamp, _signature)
    returns(
        bool
    ) {
        _undelegate(delegator, recipient, amount);
        return true;
    }

    

    function _delegate(address owner, address recipient, uint256 amount) internal {
        require(owner != recipient, "Unable to delegate to delegator address");

        
        delegates[owner].delegatedBalance = uint128(uint256(delegates[owner].delegatedBalance).add(amount));
        delegates[recipient].receivedBalance = uint128(uint256(delegates[recipient].receivedBalance).add(amount));
        delegates[recipient].receivedFromBalances[owner] = uint128(uint256(delegates[recipient].receivedFromBalances[owner]).add(amount));

        
        _transfer(owner, recipient, amount);

        emit Delegated(owner, recipient, amount);
    }

    function _undelegate(address owner, address recipient, uint256 amount) internal {
        
        delegates[owner].delegatedBalance = uint128(uint256(delegates[owner].delegatedBalance).sub(amount));
        delegates[recipient].receivedBalance = uint128(uint256(delegates[recipient].receivedBalance).sub(amount));
        delegates[recipient].receivedFromBalances[owner] = uint128(uint256(delegates[recipient].receivedFromBalances[owner]).sub(amount));

        
        _transfer(recipient, owner, amount);

        emit Undelegated(owner, recipient, amount);
    }

    

    function _transfer(address sender, address recipient, uint256 amount) internal checkDelegates(sender, amount) {
        super._transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal checkDelegates(account, amount) {
        super._burn(account, amount);
    }

}



contract OwnableUpgradable is Initializable {
    address payable public owner;
    address payable internal newOwnerCandidate;

    modifier onlyOwner {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    

    function initialize() public initializer {
        owner = msg.sender;
    }

    function initialize(address payable newOwner) public initializer {
        owner = newOwner;
    }

    function changeOwner(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }

    uint256[50] private ______gap;
}

contract DfDepositToken is
    Initializable,
    ERC20Detailed,
    ERC20Snapshot,
    OwnableUpgradable,
    ERC20Delegatable
{

    

    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address payable _controller
    ) public initializer {
        
        ERC20Detailed.initialize(_name, _symbol, _decimals);
        OwnableUpgradable.initialize(_controller);
    }

    

    
    function transfer(address[] memory recipients, uint256[] memory amounts) public returns(bool) {
        require(recipients.length == amounts.length, "Arrays lengths not equal");

        
        for (uint i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }

        return true;
    }

    

    function snapshot() public onlyOwner returns(uint256 currentId) {
        currentId = _snapshot();
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burnFrom(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}