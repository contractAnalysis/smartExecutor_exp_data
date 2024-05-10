pragma solidity 0.5.4;


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



contract BurnerRole {

    using Roles for Roles.Role;

    Roles.Role private _burners;

    
    event BurnerAdded(address indexed account);

    
    event BurnerRemoved(address indexed account);

    
    constructor () internal {
        _addBurner(msg.sender);
    }

    
    modifier onlyBurner() {
        require(isBurner(msg.sender), "BurnerRole: caller does not have the Burner role");
        _;
    }

    
    function renounceBurner() public {
        _removeBurner(msg.sender);
    }

    
    function isBurner(address account) public view returns (bool) {
        return _burners.has(account);
    }

    
    function _addBurner(address account) internal {
        _burners.add(account);
        emit BurnerAdded(account);
    }

    
    function _removeBurner(address account) internal {
        _burners.remove(account);
        emit BurnerRemoved(account);
    }

}



contract MinterRole {
    
    using Roles for Roles.Role;

    Roles.Role private _minters;

    
    event MinterAdded(address indexed account);

    
    event MinterRemoved(address indexed account);

    
    constructor () internal {
        _addMinter(msg.sender);
    }

    
    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    
    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    
    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    
    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    
    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
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

    
    event ForceTransfer(address indexed from, address indexed to, uint256 value, bytes32 details);
}



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



contract ERC20Fee is IERC20 {
    using SafeMath for uint256;


    mapping (address => uint256) private _balances;

    
    mapping (address => uint8) public whitelist;

    
    uint256 public feeStartTimestamp;

    
    uint[] public dailyStorageFee = [uint32(0), uint32(0), uint32(0)];

    
    uint[] public fixedTransferFee = [uint32(0), uint32(0), uint32(0)];

    
    uint[] public dynamicTransferFee = [uint32(0), uint32(0), uint32(0)];

    
    uint256 public mintingFee = 0;

    
    uint256 private constant mpipDivider = 10000000;

    
    mapping (address => uint256) public storageFees;

    
    address public feeManager;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    address public oldAWGContract = 0x32310F5Cf83BA8Ebb45cAe9454e072A08850e057;

    
    function getStorageDay() public view returns (uint256) {
        return (block.timestamp - feeStartTimestamp).div(86400);
    }

    
    function _migrateBalance(address account) internal {
        uint256 amount = ERC20Fee(oldAWGContract).balanceOf(account);
        emit Transfer(address(0), account, amount);
        _balances[account] = amount;
        _totalSupply = _totalSupply.add(amount);
    }

    
    function _forceTransfer(address sender, address recipient, uint256 amount, bytes32 details) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        emit ForceTransfer(sender, recipient, amount, details);
    }

    
    function calculateStorageFees(address account) public view returns (uint256) {
        return (((getStorageDay().sub(storageFees[account])).mul(_balances[account])).mul(dailyStorageFee[whitelist[account]])).div(mpipDivider);
    }

    
    function _retrieveStorageFee(address account) internal {
        uint256 storageFee = calculateStorageFees(account);
        storageFees[account] = getStorageDay();
        if (storageFee > 0) {
            _transfer(account,feeManager,storageFee);
        }
    }

    
    function _resetStorageFee(address account) internal {
        storageFees[account] = getStorageDay();
    }

    
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

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint8 level = whitelist[sender];
        require(level != 3, "Sender is blacklisted");

        uint256 senderFee = calculateStorageFees(sender) + fixedTransferFee[level] + ((dynamicTransferFee[level].mul(amount)).div(mpipDivider));
        uint256 receiverStorageFee = calculateStorageFees(recipient);
        uint256 totalFee = senderFee.add(receiverStorageFee);

        _balances[sender] = (_balances[sender].sub(amount)).sub(senderFee);
        _balances[recipient] = (_balances[recipient].add(amount)).sub(receiverStorageFee);

        storageFees[sender] = getStorageDay();
        storageFees[recipient] = getStorageDay();
        emit Transfer(sender, recipient, amount);

        if (totalFee > 0) {
            _balances[feeManager] = _balances[feeManager].add(totalFee);
            emit Transfer(sender, feeManager, senderFee);
            emit Transfer(recipient, feeManager, receiverStorageFee);
            (bool success, ) = feeManager.call(abi.encodeWithSignature("processFee(uint256)",totalFee));
            require(success, "Fee Manager is not responding.");
        }
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        uint256 mintingFeeAmount = amount.mul(mintingFee).div(mpipDivider);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount).sub(mintingFeeAmount);
        emit Transfer(address(0), account, (amount.sub(mintingFeeAmount)));

        if (mintingFeeAmount > 0) {
            _balances[feeManager] = _balances[feeManager].add(mintingFeeAmount);
            emit Transfer(address(0), feeManager, mintingFeeAmount);
            (bool success, ) = feeManager.call(abi.encodeWithSignature("processFee(uint256)",mintingFeeAmount));
            require(success, "Fee Manager is not responding.");
        }
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }

}


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}



contract Pausable is PauserRole {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    
    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}



contract ERC20StorageFee is ERC20Fee, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
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



interface IToken {

    function burn(uint256 amount) external ;

    function mint(address account, uint256 amount) external ;

}



library ECRecovery {

    
    function recover(bytes32 hash, bytes memory sig)
        internal
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        
        if (sig.length != 65) {
            return (address(0));
        }

        
        
        
        
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        
        if (v < 27) {
            v += 27;
        }

        
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            
            return ecrecover(hash, v, r, s);
        }
    }

    
    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        
        
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }
}



contract Feeless {

     
    address internal msgSender;

     
    mapping(address => uint256) public nonces;

    
    modifier feeless() {
        if (msgSender == address(0)) {
            msgSender = msg.sender;
            _;
            msgSender = address(0);
        } else {
            _;
        }
    }

    struct CallResult {
        bool success;
        bytes payload;
    }

    
    
    function performFeelessTransaction(
        address sender, 
        address target, 
        bytes memory data, 
        uint256 nonce, 
        bytes memory sig) public payable {
        require(address(this) == target, "Feeless: Target should be the extended contract");
    
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(abi.encodePacked(prefix, keccak256(abi.encodePacked(target, data, nonce))));
        msgSender = ECRecovery.recover(hash, sig);
        require(msgSender == sender, "Feeless: Unexpected sender");
        require(nonces[msgSender]++ == nonce, "Feeless: nonce does not comply");
        (bool _success, bytes memory _payload) = target.call.value(msg.value)(data);
        CallResult memory callResult = CallResult(_success, _payload);
        require(callResult.success, "Feeless: Call failed");
        msgSender = address(0);
    }
    
}



contract AWG is ERC20StorageFee, MinterRole, BurnerRole, Ownable, Feeless, IToken {

    
    event TransferFeeless(address indexed account, uint256 indexed value);

    
    event ApproveFeeless(address indexed spender, uint256 indexed value);

    
    uint8 public constant decimals = 18;

    
    string public constant name = "AurusGOLD";
    
    
    string public constant symbol = "AWG";

    
    bool private _migrationOpen = true;

    constructor() public {
        feeStartTimestamp = block.timestamp;
    }

    
    function stopMigration() public onlyOwner {
        _migrationOpen = false;
    }

    
    modifier whenMigration() {
        require(_migrationOpen, "Migration: stopped");
        _;
    }

    
    function migrateBalances(address[] calldata _accounts) external whenPaused whenMigration onlyOwner {
        require(AWG(oldAWGContract).paused(), "Pausable: not paused");
        for (uint i=0; i<_accounts.length; i++) {
            _migrateBalance(_accounts[i]);
        }
    }

    
    function forceTransfer(address sender, address recipient, uint256 amount, bytes32 details) external onlyOwner {
        _forceTransfer(sender,recipient,amount,details);
    }

    
    function whitelistAddress(address account, uint8 level) external onlyOwner {
        require(level<=3, "Level: Please use level 0 to 3.");
        whitelist[account] = level;
    }

    
    function setFees(uint256 _dailyStorageFee, uint256 _fixedTransferFee, uint256 _dynamicTransferFee, uint256 _mintingFee, uint8 level) external onlyOwner {
        require(level<=2, "Level: Please use level 0 to 2.");
        dailyStorageFee[level] = _dailyStorageFee;
        fixedTransferFee[level] = _fixedTransferFee;
        dynamicTransferFee[level] = _dynamicTransferFee;
        mintingFee = _mintingFee;
    }

    
    function setFeeManager(address account) external onlyOwner {
        (bool success, ) = feeManager.call(abi.encodeWithSignature("processFee(uint256)",0));
        require(success);
        feeManager = account;
    }

    
    function retrieveStorageFee(address account) external onlyOwner {
        _retrieveStorageFee(account);
    }

    
    function resetStorageFees(address[] calldata _accounts) external onlyOwner {
        for (uint i=0; i<_accounts.length; i++) {
            _resetStorageFee(_accounts[i]);
        }
    }

    
    function addMinter(address account) external onlyOwner {
        _addMinter(account);
    }

    
    function removeMinter(address account) external onlyOwner {
        _removeMinter(account);
    }

    
    function addBurner(address account) external onlyOwner {
        _addBurner(account);
    }

    
    function removeBurner(address account) external onlyOwner {
        _removeBurner(account);
    }

    
    function burn(uint256 amount) external onlyBurner {
        _burn(msg.sender, amount);
    }

    
    function mint(address account, uint256 amount) external onlyMinter {
        _mint(account, amount);
    }

    
    function transferFeeless(address account, uint256 value) feeless whenNotPaused external {
        _transfer(msgSender, account, value);
        emit TransferFeeless(account, value);
    }

    
    function approveFeeless(address spender, uint256 value) feeless whenNotPaused external {
        _approve(msgSender, spender, value);
        emit ApproveFeeless(spender, value);
    }
}