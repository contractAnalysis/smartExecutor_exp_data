pragma solidity ^0.5.11;


contract IManager {
    event SetController(address controller);
    event ParameterUpdate(string param);

    function setController(address _controller) external;
}



pragma solidity ^0.5.11;



contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    
    constructor() public {
        owner = msg.sender;
    }

  
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}



pragma solidity ^0.5.11;




contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    
    modifier whenPaused() {
        require(paused);
        _;
    }

    
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}



pragma solidity ^0.5.11;



contract IController is Pausable {
    event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);

    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;
    function updateController(bytes32 _id, address _controller) external;
    function getContract(bytes32 _id) public view returns (address);
}



pragma solidity ^0.5.11;




contract Manager is IManager {
    
    IController public controller;

    
    modifier onlyController() {
        require(msg.sender == address(controller), "caller must be Controller");
        _;
    }

    
    modifier onlyControllerOwner() {
        require(msg.sender == controller.owner(), "caller must be Controller owner");
        _;
    }

    
    modifier whenSystemNotPaused() {
        require(!controller.paused(), "system is paused");
        _;
    }

    
    modifier whenSystemPaused() {
        require(controller.paused(), "system is not paused");
        _;
    }

    constructor(address _controller) public {
        controller = IController(_controller);
    }

    
    function setController(address _controller) external onlyController {
        controller = IController(_controller);

        emit SetController(_controller);
    }
}



pragma solidity ^0.5.11;




contract IMinter {
    
    event SetCurrentRewardTokens(uint256 currentMintableTokens, uint256 currentInflation);

    
    function createReward(uint256 _fracNum, uint256 _fracDenom) external returns (uint256);
    function trustedTransferTokens(address _to, uint256 _amount) external;
    function trustedBurnTokens(uint256 _amount) external;
    function trustedWithdrawETH(address payable _to, uint256 _amount) external;
    function depositETH() external payable returns (bool);
    function setCurrentRewardTokens() external;

    
    function getController() public view returns (IController);
}



pragma solidity ^0.5.0;


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



pragma solidity ^0.5.0;


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



pragma solidity ^0.5.0;




contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
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

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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



pragma solidity ^0.5.11;




contract ILivepeerToken is ERC20, Ownable {
    function mint(address _to, uint256 _amount) public returns (bool);
    function burn(uint256 _amount) public;
}



pragma solidity ^0.5.11;



contract IRoundsManager {
    
    event NewRound(uint256 indexed round, bytes32 blockHash);

    
    
    
    

    
    function initializeRound() external;

    
    function blockNum() public view returns (uint256);
    function blockHash(uint256 _block) public view returns (bytes32);
    function blockHashForRound(uint256 _round) public view returns (bytes32);
    function currentRound() public view returns (uint256);
    function currentRoundStartBlock() public view returns (uint256);
    function currentRoundInitialized() public view returns (bool);
    function currentRoundLocked() public view returns (bool);
}



pragma solidity ^0.5.11;



contract IBondingManager {
    event TranscoderUpdate(address indexed transcoder, uint256 rewardCut, uint256 feeShare);
    event TranscoderActivated(address indexed transcoder, uint256 activationRound);
    event TranscoderDeactivated(address indexed transcoder, uint256 deactivationRound);
    event TranscoderSlashed(address indexed transcoder, address finder, uint256 penalty, uint256 finderReward);
    event Reward(address indexed transcoder, uint256 amount);
    event Bond(address indexed newDelegate, address indexed oldDelegate, address indexed delegator, uint256 additionalAmount, uint256 bondedAmount);
    event Unbond(address indexed delegate, address indexed delegator, uint256 unbondingLockId, uint256 amount, uint256 withdrawRound);
    event Rebond(address indexed delegate, address indexed delegator, uint256 unbondingLockId, uint256 amount);
    event WithdrawStake(address indexed delegator, uint256 unbondingLockId, uint256 amount, uint256 withdrawRound);
    event WithdrawFees(address indexed delegator);
    event EarningsClaimed(address indexed delegate, address indexed delegator, uint256 rewards, uint256 fees, uint256 startRound, uint256 endRound);

    
    
    
    
    
    
    
    
    

    
    function updateTranscoderWithFees(address _transcoder, uint256 _fees, uint256 _round) external;
    function slashTranscoder(address _transcoder, address _finder, uint256 _slashAmount, uint256 _finderFee) external;
    function setCurrentRoundTotalActiveStake() external;

    
    function getTranscoderPoolSize() public view returns (uint256);
    function transcoderTotalStake(address _transcoder) public view returns (uint256);
    function isActiveTranscoder(address _transcoder) public view returns (bool);
    function getTotalBonded() public view returns (uint256);
}



pragma solidity ^0.5.11;



library MathUtils {
    using SafeMath for uint256;

    
    uint256 public constant PERC_DIVISOR = 1000000000;

    
    function validPerc(uint256 _amount) internal pure returns (bool) {
        return _amount <= PERC_DIVISOR;
    }

    
    function percOf(uint256 _amount, uint256 _fracNum, uint256 _fracDenom) internal pure returns (uint256) {
        return _amount.mul(percPoints(_fracNum, _fracDenom)).div(PERC_DIVISOR);
    }

    
    function percOf(uint256 _amount, uint256 _fracNum) internal pure returns (uint256) {
        return _amount.mul(_fracNum).div(PERC_DIVISOR);
    }

    
    function percPoints(uint256 _fracNum, uint256 _fracDenom) internal pure returns (uint256) {
        return _fracNum.mul(PERC_DIVISOR).div(_fracDenom);
    }
}



pragma solidity ^0.5.11;










contract Minter is Manager, IMinter {
    using SafeMath for uint256;

    
    uint256 public inflation;
    
    uint256 public inflationChange;
    
    uint256 public targetBondingRate;

    
    uint256 public currentMintableTokens;
    
    uint256 public currentMintedTokens;

    
    modifier onlyBondingManager() {
        require(msg.sender == controller.getContract(keccak256("BondingManager")), "msg.sender not BondingManager");
        _;
    }

    
    modifier onlyRoundsManager() {
        require(msg.sender == controller.getContract(keccak256("RoundsManager")), "msg.sender not RoundsManager");
        _;
    }

    
    modifier onlyBondingManagerOrJobsManager() {
        require(
            msg.sender == controller.getContract(keccak256("BondingManager")) || msg.sender == controller.getContract(keccak256("JobsManager")),
            "msg.sender not BondingManager or JobsManager"
        );
        _;
    }

    
    modifier onlyMinterOrJobsManager() {
        require(
            msg.sender == controller.getContract(keccak256("Minter")) || msg.sender == controller.getContract(keccak256("JobsManager")),
            "msg.sender not Minter or JobsManager"
        );
        _;
    }

    
    constructor(address _controller, uint256 _inflation, uint256 _inflationChange, uint256 _targetBondingRate) public Manager(_controller) {
        
        require(MathUtils.validPerc(_inflation), "_inflation is invalid percentage");
        
        require(MathUtils.validPerc(_inflationChange), "_inflationChange is invalid percentage");
        
        require(MathUtils.validPerc(_targetBondingRate), "_targetBondingRate is invalid percentage");

        inflation = _inflation;
        inflationChange = _inflationChange;
        targetBondingRate = _targetBondingRate;
    }

    
    function setTargetBondingRate(uint256 _targetBondingRate) external onlyControllerOwner {
        
        require(MathUtils.validPerc(_targetBondingRate), "_targetBondingRate is invalid percentage");

        targetBondingRate = _targetBondingRate;

        emit ParameterUpdate("targetBondingRate");
    }

    
    function setInflationChange(uint256 _inflationChange) external onlyControllerOwner {
        
        require(MathUtils.validPerc(_inflationChange), "_inflationChange is invalid percentage");

        inflationChange = _inflationChange;

        emit ParameterUpdate("inflationChange");
    }

    
    function migrateToNewMinter(IMinter _newMinter) external onlyControllerOwner whenSystemPaused {
        
        require(_newMinter != this, "new Minter cannot be current Minter");
        
        require(address(_newMinter) != address(0), "new Minter cannot be null address");

        IController newMinterController = _newMinter.getController();
        
        require(newMinterController == controller, "new Minter Controller must be current Controller");
        
        require(newMinterController.getContract(keccak256("Minter")) == address(this), "new Minter must be registered");

        
        livepeerToken().transferOwnership(address(_newMinter));
        
        livepeerToken().transfer(address(_newMinter), livepeerToken().balanceOf(address(this)));
        
        _newMinter.depositETH.value(address(this).balance)();
    }

    
    function createReward(uint256 _fracNum, uint256 _fracDenom) external onlyBondingManager whenSystemNotPaused returns (uint256) {
        
        uint256 mintAmount = MathUtils.percOf(currentMintableTokens, _fracNum, _fracDenom);
        
        currentMintedTokens = currentMintedTokens.add(mintAmount);
        
        require(currentMintedTokens <= currentMintableTokens, "minted tokens cannot exceed mintable tokens");
        
        livepeerToken().mint(address(this), mintAmount);

        
        return mintAmount;
    }

    
    function trustedTransferTokens(address _to, uint256 _amount) external onlyBondingManager whenSystemNotPaused {
        livepeerToken().transfer(_to, _amount);
    }

    
    function trustedBurnTokens(uint256 _amount) external onlyBondingManager whenSystemNotPaused {
        livepeerToken().burn(_amount);
    }

    
    function trustedWithdrawETH(address payable _to, uint256 _amount) external onlyBondingManagerOrJobsManager whenSystemNotPaused {
        _to.transfer(_amount);
    }

    
    function depositETH() external payable onlyMinterOrJobsManager returns (bool) {
        return true;
    }

    
    function setCurrentRewardTokens() external onlyRoundsManager whenSystemNotPaused {
        setInflation();

        
        currentMintableTokens = MathUtils.percOf(livepeerToken().totalSupply(), inflation);
        currentMintedTokens = 0;

        emit SetCurrentRewardTokens(currentMintableTokens, inflation);
    }

    
    function getController() public view returns (IController) {
        return controller;
    }

    
    function setInflation() internal {
        uint256 currentBondingRate = 0;
        uint256 totalSupply = livepeerToken().totalSupply();

        if (totalSupply > 0) {
            uint256 totalBonded = bondingManager().getTotalBonded();
            currentBondingRate = MathUtils.percPoints(totalBonded, totalSupply);
        }

        if (currentBondingRate < targetBondingRate) {
            
            inflation = inflation.add(inflationChange);
        } else if (currentBondingRate > targetBondingRate) {
            
            if (inflationChange > inflation) {
                inflation = 0;
            } else {
                inflation = inflation.sub(inflationChange);
            }
        }
    }

    
    function livepeerToken() internal view returns (ILivepeerToken) {
        return ILivepeerToken(controller.getContract(keccak256("LivepeerToken")));
    }

    
    function bondingManager() internal view returns (IBondingManager) {
        return IBondingManager(controller.getContract(keccak256("BondingManager")));
    }
}