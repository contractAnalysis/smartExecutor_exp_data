pragma solidity ^0.5.0;

contract MultiSigWallet {
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Deposit(address indexed sender, uint256 value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint256 required);

    
    uint256 public constant MAX_OWNER_COUNT = 50;

    
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public required;
    uint256 public transactionCount;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }

    
    modifier onlyWallet() {
        require(msg.sender == address(this), "ONLY_WALLET");
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner], "OWNER_ALREADY_EXISTS");
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner], "INVALID_OWNER");
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        require(
            transactions[transactionId].destination != address(0),
            "TRANSACTION_DOES_NOT_EXISTS"
        );
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {
        require(confirmations[transactionId][owner], "NOT_CONFIRMED");
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {
        require(!confirmations[transactionId][owner], "ALREADY_CONFIRMED");
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed, "ALREADY_EXECUTED");
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0), "ADDRESS_NULL");
        _;
    }

    modifier validRequirement(uint256 ownerCount, uint256 _required) {
        require(
            ownerCount <= MAX_OWNER_COUNT &&
                _required <= ownerCount &&
                _required != 0 &&
                ownerCount != 0,
            "INVALID_REQUIREMENTS"
        );
        _;
    }

    function() external payable {}

    
    
    
    
    constructor(address[] memory _owners, uint256 _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint256 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }

        owners = _owners;
        required = _required;
    }

    
    
    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;

        owners.push(owner);

        emit OwnerAddition(owner);
    }

    
    
    function removeOwner(address owner) public onlyWallet ownerExists(owner) {
        isOwner[owner] = false;

        for (uint256 i = 0; i < owners.length - 1; i++) {
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        }

        owners.length -= 1;

        if (required > owners.length) {
            changeRequirement(owners.length);
        }

        emit OwnerRemoval(owner);
    }

    
    
    
    function replaceOwner(address owner, address newOwner)
        public
        onlyWallet
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        }

        isOwner[owner] = false;

        isOwner[newOwner] = true;

        emit OwnerRemoval(owner);

        emit OwnerAddition(newOwner);
    }

    
    
    function changeRequirement(uint256 _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

    
    
    
    
    
    function submitTransaction(address destination, uint256 value, bytes memory data)
        public
        returns (uint256 transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    
    
    function confirmTransaction(uint256 transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;

        emit Confirmation(msg.sender, transactionId);

        executeTransaction(transactionId);
    }

    
    
    function revokeConfirmation(uint256 transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    
    
    function executeTransaction(uint256 transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];

            txn.executed = true;

            if (
                external_call(
                    txn.destination,
                    txn.value,
                    txn.data.length,
                    txn.data
                )
            ) {
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    
    
    function external_call(
        address destination,
        uint256 value,
        uint256 dataLength,
        bytes memory data
    ) internal returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40) 
            let d := add(data, 32) 
            result := call(
                sub(gas, 34710), 
                
                
                destination,
                value,
                d,
                dataLength, 
                x,
                0 
            )
        }
        return result;
    }

    
    
    
    function isConfirmed(uint256 transactionId) public view returns (bool) {
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) count += 1;
            if (count == required) return true;
        }
    }

    
    
    
    
    
    
    function addTransaction(address destination, uint256 value, bytes memory data)
        internal
        notNull(destination)
        returns (uint256 transactionId)
    {
        transactionId = transactionCount;

        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });

        transactionCount += 1;

        emit Submission(transactionId);
    }

    
    
    
    
    function getConfirmationCount(uint256 transactionId)
        public
        view
        returns (uint256 count)
    {
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

    
    
    
    
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint256 count)
    {
        for (uint256 i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) count += 1;
    }

    
    
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    
    
    
    function getConfirmations(uint256 transactionId)
        public
        view
        returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) _confirmations[i] = confirmationsTemp[i];
    }

    
    
    
    
    
    
    function getTransactionIds(
        uint256 from,
        uint256 to,
        bool pending,
        bool executed
    ) public view returns (uint256[] memory _transactionIds) {
        uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint256[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
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

    
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract AESCollateralMultisig is MultiSigWallet {
    event DepositCollateral(
        uint256 amount,
        address indexed sender,
        address indexed token,
        string aeAddress
    );

    event WithdrawCollateral(
        uint256 amount,
        address indexed receiver,
        address indexed token,
        string burnTxHash
    );

    using SafeERC20 for IERC20;

    mapping(address => bool) public collateral;

    
    
    function deposit(uint256 amount, address token, string calldata aeAddress) external {
        require(collateral[token], "INVALID_COLLATERAL");

        require(amount > 0, "INVALID_AMOUNT");

        address sender = msg.sender;

        IERC20(token).safeTransferFrom(sender, address(this), amount);

        emit DepositCollateral(amount, sender, token, aeAddress);
    }
    
    
    constructor(address[] memory _owners, uint256 _required) MultiSigWallet(_owners, _required) public {
        collateral[address(0x6B175474E89094C44Da98b954EedeAC495271d0F)] = true;
    }

    
    
    function withdraw(
        uint256 amount,
        address token,
        address receiver,
        string calldata burnTxHash
    ) external onlyWallet {
        IERC20(token).safeTransfer(receiver, amount);
        emit WithdrawCollateral(amount, receiver, token, burnTxHash);
    }

    
    
    function addCollateralToken(address token) external onlyWallet {
        collateral[token] = true;
    }

    
    
    function removeCollateralToken(address token) external onlyWallet {
        collateral[token] = false;
    }

    function collateralBalance(address token) public view returns(uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}