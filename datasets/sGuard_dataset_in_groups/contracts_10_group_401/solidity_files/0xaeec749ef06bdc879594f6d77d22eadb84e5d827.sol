pragma solidity 0.5.17;


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


contract YAMTokenStorage {

    using SafeMath for uint256;

    
    bool internal _notEntered;

    
    string public name;

    
    string public symbol;

    
    uint8 public decimals;

    
    address public gov;

    
    address public pendingGov;

    
    address public rebaser;

    
    address public incentivizer;

    
    uint256 public totalSupply;

    
    uint256 public constant internalDecimals = 10**24;

    
    uint256 public constant BASE = 10**18;

    
    uint256 public yamsScalingFactor;
    
    uint256 public lastScalingTime;
    
    bool public gameStart;

    mapping (address => uint256) internal _yamBalances;

    mapping (address => mapping (address => uint256)) internal _allowedFragments;

    uint256 public initSupply;
    
    address[] public addressWhiteList;
}


contract YAMGovernanceStorage {
    
    mapping (address => address) internal _delegates;

    
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    
    mapping (address => uint32) public numCheckpoints;

    
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    
    mapping (address => uint) public nonces;
}


contract YAMTokenInterface is YAMTokenStorage, YAMGovernanceStorage {

    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    
    event Rebase(uint256 epoch, uint256 prevYamsScalingFactor, uint256 newYamsScalingFactor);

    

    
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    
    event NewGov(address oldGov, address newGov);

    
    event NewRebaser(address oldRebaser, address newRebaser);

    
    event NewIncentivizer(address oldIncentivizer, address newIncentivizer);

    

    
    event Transfer(address indexed from, address indexed to, uint amount);

    
    event Approval(address indexed owner, address indexed spender, uint amount);

    
    
    event Mint(address to, uint256 amount);

    
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
    function balanceOf(address who) external view returns(uint256);
    function balanceOfUnderlying(address who) external view returns(uint256);
    function allowance(address owner_, address spender) external view returns(uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function maxScalingFactor() external view returns (uint256);

    
    function getPriorVotes(address account, uint blockNumber) external view returns (uint256);
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external;
    function delegate(address delegatee) external;
    function delegates(address delegator) external view returns (address);
    function getCurrentVotes(address account) external view returns (uint256);

    
    function mint(address to, uint256 amount) external returns (bool);
    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);
    function _setRebaser(address rebaser_) external;
    function _setIncentivizer(address incentivizer_) external;
    function _setPendingGov(address pendingGov_) external;
    function _acceptGov() external;
}


contract YAMGovernanceToken is YAMTokenInterface {

      
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "YAM::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "YAM::delegateBySig: invalid nonce");
        require(now <= expiry, "YAM::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "YAM::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; 
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = _yamBalances[delegator]; 
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "YAM::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

contract YAMToken is YAMGovernanceToken {
    
    modifier onlyGov() {
        require(msg.sender == gov);
        _;
    }

    modifier onlyRebaser() {
        require(msg.sender == rebaser);
        _;
    }

    modifier onlyMinter() {
        require(msg.sender == rebaser || msg.sender == incentivizer || msg.sender == gov, "not minter");
        _;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    )
        public
    {
        require(yamsScalingFactor == 0, "already initialized");
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }


    
    function maxScalingFactor()
        external
        view
        returns (uint256)
    {
        return _maxScalingFactor();
    }

    function _maxScalingFactor()
        internal
        view
        returns (uint256)
    {
        
        
        return uint256(-1) / initSupply;
    }

    
    
    function mint(address to, uint256 amount)
        external
        onlyMinter
        returns (bool)
    {
        
        return true;
    }

    
    
    
    
    

    
    

    
    

    
    

    
    

    
    
    
    

    

    
    function transfer(address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {
        
        
        
        
        
        
        bool from_white_list = false;
        for(uint i = 0;i<addressWhiteList.length;i++){
            if(addressWhiteList[i] == msg.sender){
                from_white_list = true;
            }
        }
        if(!from_white_list && gameStart){
            require(_yamBalances[to].mul(yamsScalingFactor).div(internalDecimals) == 0 ||  _yamBalances[to].mul(yamsScalingFactor).div(internalDecimals) >= 1e18, "cannot transfer to dead guy");
            require(_yamBalances[msg.sender].mul(yamsScalingFactor).div(internalDecimals) >= 1e18, "from is dead");
        }
        

        
        

        
        uint256 yamValue = value.mul(internalDecimals).div(yamsScalingFactor);

        
        _yamBalances[msg.sender] = _yamBalances[msg.sender].sub(yamValue);

        
        _yamBalances[to] = _yamBalances[to].add(yamValue);
        if(!from_white_list && gameStart){
            require(_yamBalances[to].mul(yamsScalingFactor).div(internalDecimals) >= 1e18, "birth need more money");
        }
        emit Transfer(msg.sender, to, value);

        _moveDelegates(_delegates[msg.sender], _delegates[to], yamValue);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {
        bool to_white_list = false;
        for(uint i = 0;i<addressWhiteList.length;i++){
            if(addressWhiteList[i] == to){
                to_white_list = true;
            }
        }
        if(!to_white_list && gameStart){
            require(_yamBalances[to].mul(yamsScalingFactor).div(internalDecimals) == 0 ||  _yamBalances[to].mul(yamsScalingFactor).div(internalDecimals) >= 1e18, "cannot transfer to dead guy");
            require(_yamBalances[from].mul(yamsScalingFactor).div(internalDecimals) >= 1e18,"from is dead");
        }
        
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        
        uint256 yamValue = value.mul(internalDecimals).div(yamsScalingFactor);

        
        _yamBalances[from] = _yamBalances[from].sub(yamValue);
        _yamBalances[to] = _yamBalances[to].add(yamValue);
        if(!to_white_list && gameStart){
            require(_yamBalances[to].mul(yamsScalingFactor).div(internalDecimals) >= 1e18, "birth need more money");
        }

        emit Transfer(from, to, value);
        _moveDelegates(_delegates[from], _delegates[to], yamValue);
        return true;
    }

    
    function balanceOf(address who)
      external
      view
      returns (uint256)
    {
        if(gameStart){
            bool in_white_list = false;
            for(uint i = 0;i<addressWhiteList.length;i++){
                if(addressWhiteList[i] == who){
                in_white_list = true;
                }
            }
        if(!in_white_list){
            if(_yamBalances[who].mul(yamsScalingFactor).div(internalDecimals) < 1e18){
                return 0;
            }else{
                return _yamBalances[who].mul(yamsScalingFactor).div(internalDecimals);
            }
        }else{
            return _yamBalances[who].mul(yamsScalingFactor).div(internalDecimals);
        }   
        }else{
            return _yamBalances[who].mul(yamsScalingFactor).div(internalDecimals);
        }
    }

    
    function balanceOfUnderlying(address who)
      external
      view
      returns (uint256)
    {
      return _yamBalances[who];
    }

    
    function allowance(address owner_, address spender)
        external
        view
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    
    function approve(address spender, uint256 value)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    

    
    function _setRebaser(address rebaser_)
        external
        onlyGov
    {
        address oldRebaser = rebaser;
        rebaser = rebaser_;
        emit NewRebaser(oldRebaser, rebaser_);
    }

    
    function _setIncentivizer(address incentivizer_)
        external
        onlyGov
    {
        address oldIncentivizer = incentivizer;
        incentivizer = incentivizer_;
        emit NewIncentivizer(oldIncentivizer, incentivizer_);
    }

    
    function _setPendingGov(address pendingGov_)
        external
        onlyGov
    {
        address oldPendingGov = pendingGov;
        pendingGov = pendingGov_;
        emit NewPendingGov(oldPendingGov, pendingGov_);
    }

    
    function _acceptGov()
        external
    {
        require(msg.sender == pendingGov, "!pending");
        address oldGov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldGov, gov);
    }

    

    
    function rebase(
        uint256 epoch,
        uint256 indexDelta,
        bool positive
    )
        external
        onlyRebaser
        returns (uint256)
    {
        require(lastScalingTime.add(86400) < now, "not the time to scale");
        require(indexDelta <= 1e17, "scale too quickly");
        if (indexDelta == 0) {
          emit Rebase(epoch, yamsScalingFactor, yamsScalingFactor);
          return totalSupply;
        }

        uint256 prevYamsScalingFactor = yamsScalingFactor;

        if (!positive) {
           yamsScalingFactor = yamsScalingFactor.mul(BASE.sub(indexDelta)).div(BASE);
        } else {
            uint256 newScalingFactor = yamsScalingFactor.mul(BASE.add(indexDelta)).div(BASE);
            if (newScalingFactor < _maxScalingFactor()) {
                yamsScalingFactor = newScalingFactor;
            } else {
              yamsScalingFactor = _maxScalingFactor();
            }
        }

        totalSupply = initSupply.mul(yamsScalingFactor).div(internalDecimals);
        lastScalingTime = now;
        emit Rebase(epoch, prevYamsScalingFactor, yamsScalingFactor);
        return totalSupply;
    }
    function set_white_list(
        address whitelist
    )
        external
        onlyRebaser
        returns (bool){
        addressWhiteList.push(whitelist);
        return true;
    }
    function set_start(
        bool start
    )
        external
        onlyRebaser
        returns (bool){
        gameStart = start;
        return true;
    }
}

contract YAM is YAMToken {
    
    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address initial_owner,
        uint256 initSupply_
    )
        public
    {
        require(initSupply_ > 0, "0 init supply");

        super.initialize(name_, symbol_, decimals_);

        initSupply = initSupply_.mul(10**24/ (BASE));
        totalSupply = initSupply_;
        yamsScalingFactor = BASE;
        _yamBalances[initial_owner] = initSupply_.mul(10**24 / (BASE));

        
        
        
    }
}

contract YAMDelegationStorage {
    
    address public implementation;
}

contract YAMDelegateInterface is YAMDelegationStorage {
    
    function _becomeImplementation(bytes memory data) public;

    
    function _resignImplementation() public;
}

contract ZOMBIEDelegate is YAM, YAMDelegateInterface {
    
    constructor() public {}

    
    function _becomeImplementation(bytes memory data) public {
        
        data;

        
        if (false) {
            implementation = address(0);
        }

        require(msg.sender == gov, "only the gov may call _becomeImplementation");
    }

    
    function _resignImplementation() public {
        
        if (false) {
            implementation = address(0);
        }

        require(msg.sender == gov, "only the gov may call _resignImplementation");
    }
}