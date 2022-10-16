pragma solidity 0.5.16;




contract SelfDestructingSender {
    constructor(address payable payee) public payable {
        selfdestruct(payee);
    }
}















































contract Game {
    using SafeMath for uint256;

    
    
    

    event Action(
        uint256 indexed gameNumber,
        uint256 indexed depositNumber,
        address indexed depositorAddress,
        uint256 block,
        uint256 time,
        address payoutProof, 
        bool gameOver
    );

    
    
    
    
    

    uint256 constant internal DEPOSIT_INCREMENT_PERCENT = 15;
    uint256 constant internal BIG_REWARD_PERCENT = 20;
    uint256 constant internal SMALL_REWARD_PERCENT = 10;
    uint256 constant internal MAX_TIME = 30 minutes;
    uint256 constant internal NEVER = uint256(-1);
    uint256 constant internal INITIAL_INCENTIVE = 0.0435 ether;
    address payable constant internal _designers = 0xBea62796855548154464F6C8E7BC92672C9F87b8; 

    
    
    

    uint256 public endTime; 
    uint256 public escrow; 
    uint256 public currentGameNumber;
    uint256 public currentDepositNumber;
    address payable[2] public topDepositors; 
    
    mapping (uint256 => uint256) public requiredDeposit; 
    
    uint256[] internal _startBlocks; 
    bool internal _gameStarted;

    
    
    

    
    enum GameState {NEEDS_DONATION, READY_FOR_FIRST_PLAY, IN_PROGRESS, GAME_OVER}

    
    
    

    
    modifier currentGame(uint256 gameNumber) {
        require(gameNumber == currentGameNumber, "Wrong game number.");
        _;
    }

    
    modifier exactDeposit() {
        require(
            msg.value == requiredDeposit[currentDepositNumber],
            "Incorrect deposit amount. Perhaps another player got their txn mined before you. Try again."
        );
        _;
    }

    
    
    

    
    
    
    
    function() external { }

    constructor() public {
        endTime = NEVER;
        currentGameNumber = 1;
        currentDepositNumber = 1;
        _startBlocks.push(0);

        
        
        
        
        
        
        
        
        
        
        
        
        uint256 value = INITIAL_INCENTIVE;
        uint256 r = DEPOSIT_INCREMENT_PERCENT;
        requiredDeposit[0] = INITIAL_INCENTIVE;
        for (uint256 i = 1; i <= 200; i++) { 
            value += value * r / 100;
            requiredDeposit[i] = value / 1e14 * 1e14; 
        }
        
        
    }

    
    
    

    
    
    
    
    
    
    
    
    
    
    
    function _forceTransfer(address payable payee, uint256 amount) internal returns (address) {
        return address((new SelfDestructingSender).value(amount)(payee));
    }

    
    
    function _gameState() private view returns (GameState) {
        if (!_gameStarted) {
            
            if (escrow < INITIAL_INCENTIVE) {
                return GameState.NEEDS_DONATION;
            } else {
                return GameState.READY_FOR_FIRST_PLAY;
            }
        } else {
            
            if (now >= endTime) {
                return GameState.GAME_OVER;
            } else {
                return GameState.IN_PROGRESS;
            }
        }
    }

    
    
    

    
    
    
    
    
    
    function donate() external payable {
        require(_gameState() == GameState.NEEDS_DONATION, "No donations needed.");
        
        uint256 maxAmountToPutInEscrow = INITIAL_INCENTIVE.sub(escrow);
        if (msg.value > maxAmountToPutInEscrow) {
            escrow = escrow.add(maxAmountToPutInEscrow);
        } else {
            escrow = escrow.add(msg.value);
        }
    }

    
    
    
    
    function firstPlay(uint256 gameNumber) external payable currentGame(gameNumber) exactDeposit {
        require(_gameState() == GameState.READY_FOR_FIRST_PLAY, "Game not ready for first play.");

        emit Action(currentGameNumber, currentDepositNumber, msg.sender, block.number, now, address(0), false);

        topDepositors[0] = msg.sender;
        endTime = now.add(MAX_TIME);
        escrow = escrow.add(msg.value);
        currentDepositNumber++;
        _gameStarted = true;
        _startBlocks.push(block.number);
    }

    
    
    
    
    function play(uint256 gameNumber) external payable currentGame(gameNumber) exactDeposit {
        require(_gameState() == GameState.IN_PROGRESS, "Game is not in progress.");

        
        address payable addressToPay = topDepositors[1];
        
        
        
        uint256 amountToPay = requiredDeposit[currentDepositNumber.sub(2)].mul(SMALL_REWARD_PERCENT.add(100)).div(100);

        address payoutProof = address(0);
        if (addressToPay != address(0)) { 
            payoutProof = _forceTransfer(addressToPay, amountToPay);
        }

        
        emit Action(currentGameNumber, currentDepositNumber, msg.sender, block.number, now, payoutProof, false);

        
        topDepositors[1] = topDepositors[0];
        topDepositors[0] = msg.sender;
        
        endTime = now.add(MAX_TIME);
        
        
        
        
        escrow = escrow.sub(amountToPay).add(msg.value);
        currentDepositNumber++;
    }

    
    
    function reset() external {
        require(_gameState() == GameState.GAME_OVER, "Game is not over.");
        
        address payable addressToPay = topDepositors[0];

        
        uint256 amountToPay = requiredDeposit[currentDepositNumber.sub(1)].mul(BIG_REWARD_PERCENT.add(100)).div(100);
        address payoutProof = _forceTransfer(addressToPay, amountToPay);

        
        escrow = escrow.sub(amountToPay);

        
        emit Action(currentGameNumber, currentDepositNumber, address(0), block.number, now, payoutProof, true);

        
        if (escrow > 0) {
            _forceTransfer(_designers, escrow);
        }

        
        endTime = NEVER;
        escrow = 0;
        currentGameNumber++;
        currentDepositNumber = 1;
        _gameStarted = false;
        topDepositors[0] = address(0);
        topDepositors[1] = address(0);

        
        
        if (address(this).balance > INITIAL_INCENTIVE) {
            escrow = INITIAL_INCENTIVE;
        } else {
            escrow = address(this).balance;
        }
    }

    
    
    

    
    function currentRequiredDeposit() external view returns (uint256) {
        return requiredDeposit[currentDepositNumber];
    }

    
    function gameState() external view returns (GameState) {
        return _gameState();
    }

    
    
    function startBlocks(uint256 index) external view returns (uint256) {
        if (index >= _startBlocks.length) {
            return 0; 
        } else {
            return _startBlocks[index];
        }
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