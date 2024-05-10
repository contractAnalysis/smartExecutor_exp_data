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




contract ManagerProxyTarget is Manager {
    
    bytes32 public targetContractId;
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



pragma solidity ^0.5.11;



library MathUtils {
    using SafeMath for uint256;

    
    uint256 public constant PERC_DIVISOR = 1000000;

    
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









contract RoundsManager is ManagerProxyTarget, IRoundsManager {
    using SafeMath for uint256;

    
    uint256 public roundLength;
    
    
    
    
    uint256 public roundLockAmount;
    
    uint256 public lastInitializedRound;
    
    uint256 public lastRoundLengthUpdateRound;
    
    uint256 public lastRoundLengthUpdateStartBlock;

    
    mapping (uint256 => bytes32) internal _blockHashForRound;

    
    constructor(address _controller) public Manager(_controller) {}

    
    function setRoundLength(uint256 _roundLength) external onlyControllerOwner {
        require(_roundLength > 0, "round length cannot be 0");

        if (roundLength == 0) {
            
            
            roundLength = _roundLength;
            lastRoundLengthUpdateRound = currentRound();
            lastRoundLengthUpdateStartBlock = currentRoundStartBlock();
        } else {
            
            
            lastRoundLengthUpdateRound = currentRound();
            lastRoundLengthUpdateStartBlock = currentRoundStartBlock();
            roundLength = _roundLength;
        }

        emit ParameterUpdate("roundLength");
    }

    
    function setRoundLockAmount(uint256 _roundLockAmount) external onlyControllerOwner {
        require(MathUtils.validPerc(_roundLockAmount), "round lock amount must be a valid percentage");

        roundLockAmount = _roundLockAmount;

        emit ParameterUpdate("roundLockAmount");
    }

    
    function initializeRound() external whenSystemNotPaused {
        uint256 currRound = currentRound();

        
        require(lastInitializedRound < currRound, "round already initialized");

        
        lastInitializedRound = currRound;
        
        bytes32 roundBlockHash = blockHash(blockNum().sub(1));
        _blockHashForRound[currRound] = roundBlockHash;
        
        bondingManager().setCurrentRoundTotalActiveStake();
        
        minter().setCurrentRewardTokens();

        emit NewRound(currRound, roundBlockHash);
    }

    
    function blockNum() public view returns (uint256) {
        return block.number;
    }

    
    function blockHash(uint256 _block) public view returns (bytes32) {
        uint256 currentBlock = blockNum();
        require(_block < currentBlock, "can only retrieve past block hashes");
        require(currentBlock < 256 || _block >= currentBlock - 256, "can only retrieve hashes for last 256 blocks");

        return blockhash(_block);
    }

    
    function blockHashForRound(uint256 _round) public view returns (bytes32) {
        return _blockHashForRound[_round];
    }

    
    function currentRound() public view returns (uint256) {
        
        uint256 roundsSinceUpdate = blockNum().sub(lastRoundLengthUpdateStartBlock).div(roundLength);
        
        return lastRoundLengthUpdateRound.add(roundsSinceUpdate);
    }

    
    function currentRoundStartBlock() public view returns (uint256) {
        
        uint256 roundsSinceUpdate = blockNum().sub(lastRoundLengthUpdateStartBlock).div(roundLength);
        
        return lastRoundLengthUpdateStartBlock.add(roundsSinceUpdate.mul(roundLength));
    }

    
    function currentRoundInitialized() public view returns (bool) {
        return lastInitializedRound == currentRound();
    }

    
    function currentRoundLocked() public view returns (bool) {
        uint256 lockedBlocks = MathUtils.percOf(roundLength, roundLockAmount);
        return blockNum().sub(currentRoundStartBlock()) >= roundLength.sub(lockedBlocks);
    }

    
    function bondingManager() internal view returns (IBondingManager) {
        return IBondingManager(controller.getContract(keccak256("BondingManager")));
    }

    
    function minter() internal view returns (IMinter) {
        return IMinter(controller.getContract(keccak256("Minter")));
    }
}