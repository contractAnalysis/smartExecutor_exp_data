pragma solidity 0.6.12;




library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        assert(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        assert(b != 0);
        return a % b;
    }
}



abstract contract CalculatorInterface {
    function calculateNumTokens(uint numerator, uint denominator, uint price, uint volume, uint _streak, uint256 balance, uint256 daysStaked, address stakerAddress, uint256 totalSupply) public view virtual returns (uint256);
    function negativeDayCallback(int numerator, uint denominator, uint256 price, uint256 volume) public virtual;
    function iterativelyCalculateOwedRewards(uint stakerLastTimestamp, uint stakerStartTimestamp, uint balance, address stakerAddress, uint totalSupply) public virtual view returns (uint256);
}



abstract contract PampToken {
    function balanceOf(address account) public view virtual returns (uint256);
    function _burn(address account, uint256 amount) external virtual;
    function mint(address account, uint256 amount) public virtual;
}

abstract contract PreviousContract {
    function resetStakeTimeMigrateState(address addr) external virtual returns (uint256 startTimestamp, uint256 lastTimestamp);
    function getWhitelist(address addr) external virtual view returns (string memory);
}




contract PampStaking {
    using SafeMath for uint256;
    
    address public owner;
    
    
    
    struct staker {
        uint startTimestamp;    
        uint lastTimestamp;     
        bool hasMigrated;       
    }
    
    struct update {             
        uint timestamp;         
        uint numerator;         
        uint denominator;       
        uint price;         
        uint volume;        
        uint streak;        
    }
    
    PampToken public token;     
    
    modifier onlyToken() {
        assert(msg.sender == address(token));
        _;
    }
    
    modifier onlyNextStakingContract() {    
        assert(msg.sender == nextStakingContract);
        _;
    }
    
    modifier onlyOracle() {
        assert(msg.sender == oracle);
        _;
    }
    
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }

    
    mapping (address => staker) public stakers;        
    
    mapping (address => string) public whitelist;      
    
    mapping (address => uint256) public blacklist;     
    
    mapping (address => string) public uniwhitelist; 
    

    bool public enableBurns; 
    
    bool public priceTarget1Hit;  
    
    bool public priceTarget2Hit;
    
    address public uniswapV2Pair;      
    
    uint public uniswapSellerBurnPercent;        
    
    uint public transferBurnPercent;
    
    bool public enableUniswapDirectBurns;         
    
    uint256 public minStake;                      
        
    uint8 public minStakeDurationDays;            
    
    uint8 public minPercentIncrease;              
    
    uint256 public inflationAdjustmentFactor;     
    
    uint256 public streak;                        
    
    uint public maxStreak;                          
        
    uint public negativeStreak;                     
    
    update public lastUpdate;                      

    uint public lastNegativeUpdate;                 
    
    CalculatorInterface public externalCalculator;    
    
    address public nextStakingContract;                
    
    bool public useExternalCalc;                      
    
    bool public useExternalCalcIterative;
    
    bool public freeze;                               
    
    bool public enableHoldersDay;                     
    
    mapping (bytes32 => bool) public holdersDayRewarded; 
    
    event StakerRemoved(address StakerAddress);     
    
    event StakerAdded(address StakerAddress);       
    
    event StakesUpdated(uint Amount);               
    
    event HoldersDayEnabled();
    
    event HoldersDayRewarded(uint Amount);
    
    event Migration(address StakerAddress);
    
    event MassiveCelebration();                     
    
    event Transfer(address indexed from, address indexed to, uint256 value);        
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    uint public maxStakingDays;
    
    uint public holdersDayRewardDenominator;
    
    update[] public updates;
    
    address public liquidityStakingContract;
    
    address public oracle;
    
    PreviousContract public previousStakingContract;
    
    uint public numStakers;
    
    bool public increaseTransferFees;

    bool public checkPreviousStakingContractWhitelist;
    
    constructor () public {
        owner = msg.sender;
        token = PampToken(0xF0FAC7104aAC544e4a7CE1A55ADF2B5a25c65bD1);
        minStake = 200E18;
        inflationAdjustmentFactor = 800;
        streak = 0;
        minStakeDurationDays = 1;
        useExternalCalc = false; 
        useExternalCalcIterative = false;
        uniswapSellerBurnPercent = 8;
        enableBurns = true;
        freeze = false;
        minPercentIncrease = 10; 
        enableUniswapDirectBurns = true;
        transferBurnPercent = 8;
        priceTarget1Hit = true;
        oracle = msg.sender;
        maxStreak = 7;
        holdersDayRewardDenominator = 600;
        maxStakingDays = 100;
        increaseTransferFees = false;
        checkPreviousStakingContractWhitelist = true;
        previousStakingContract = PreviousContract(0x1d2121Efe25535850d1FDB65F930FeAB093416E0);
        uniswapV2Pair = 0x1C608235E6A946403F2a048a38550BefE41e1B85;
        liquidityStakingContract = 0x5CECDbdfB96463045b07d07aAa4fc2F1316F7e47;
    }
    
    
    
    function updateState(uint numerator, uint denominator, uint256 price, uint256 volume) external onlyOracle {  
    
        require(numerator > 0 && denominator > 0 && price > 0 && volume > 0, "Parameters cannot be negative or zero");
        
        if ((numerator < 2 && denominator == 100) || (numerator < 20 && denominator == 1000)) {
            require(mulDiv(1000, numerator, denominator) >= minPercentIncrease, "Increase must be at least minPercentIncrease to count");
        }
        
        uint secondsSinceLastUpdate = (block.timestamp - lastUpdate.timestamp);       
        
        if (secondsSinceLastUpdate < 129600) { 
            streak++;
        } else {
            streak = 1;
        }
        
        if (streak > maxStreak) {
            streak = maxStreak;
        }
        
        if (price >= 1000 && priceTarget1Hit == false) { 
            priceTarget1Hit = true;
            streak = 50;
            emit MassiveCelebration();
            
        } else if (price >= 10000 && priceTarget2Hit == false) {   
            priceTarget2Hit = true;
            streak = maxStreak;
            minStake = 100E18;        
            emit MassiveCelebration();
        }
        
        if(negativeStreak > 0) {
            uniswapSellerBurnPercent = uniswapSellerBurnPercent - (negativeStreak * 2);
            if(increaseTransferFees) {
                transferBurnPercent = transferBurnPercent - (negativeStreak * 2);
            }
            negativeStreak = 0;
        }
        
        
        lastUpdate = update(block.timestamp, numerator, denominator, price, volume, streak);
        
        updates.push(lastUpdate);

    }
    
    
    function updateStateNegative(int numerator, uint denominator, uint256 price, uint256 volume) external onlyOracle { 
        require(numerator < minPercentIncrease);
        
        uint secondsSinceLastUpdate = (block.timestamp - lastNegativeUpdate);       
        
        if (secondsSinceLastUpdate < 129600) { 
            negativeStreak++;
        } else {
            negativeStreak = 0;
        }
        
        streak = 1;
        
        uniswapSellerBurnPercent = uniswapSellerBurnPercent + (negativeStreak * 2);     
        
        if(increaseTransferFees) {
            transferBurnPercent = transferBurnPercent + (negativeStreak * 2);       
        }
        
        lastNegativeUpdate = block.timestamp;

        if(useExternalCalc) {
            externalCalculator.negativeDayCallback(numerator, denominator, price, volume);
        }
        
    }
    
    
    function resetStakeTimeMigrateState(address addr) external onlyNextStakingContract returns (uint256 startTimestamp, uint256 lastTimestamp) {
        startTimestamp = stakers[addr].startTimestamp;
        lastTimestamp = stakers[addr].lastTimestamp;
        stakers[addr].lastTimestamp = block.timestamp;
        stakers[addr].startTimestamp = block.timestamp;
    }
    
    function migratePreviousState() external {      
        
        require(stakers[msg.sender].lastTimestamp == 0, "Last timestamp must be zero");
        require(stakers[msg.sender].startTimestamp == 0, "Start timestamp must be zero");
        require(!stakers[msg.sender].hasMigrated);
        
        (uint startTimestamp, uint lastTimestamp) = previousStakingContract.resetStakeTimeMigrateState(msg.sender);
        
        if(startTimestamp == 0) {
            stakers[msg.sender].startTimestamp = block.timestamp;
        } else {
            stakers[msg.sender].startTimestamp = startTimestamp;
        }
        if(lastTimestamp == 0) {
            stakers[msg.sender].lastTimestamp = block.timestamp;
        } else {
            stakers[msg.sender].lastTimestamp = lastTimestamp;
        }
        
        if(stakers[msg.sender].startTimestamp > stakers[msg.sender].lastTimestamp) {
            stakers[msg.sender].lastTimestamp = block.timestamp;
        }
        
        stakers[msg.sender].hasMigrated = true;
        
        numStakers++;
        
        emit Migration(msg.sender);
    }
    
    function updateMyStakes(address stakerAddress, uint256 balance, uint256 totalSupply) external onlyToken returns (uint256) {     
        
        assert(balance > 0);
        
        staker memory thisStaker = stakers[stakerAddress];
        
        assert(thisStaker.lastTimestamp > 0); 
        
        assert(thisStaker.startTimestamp > 0);
        
        assert(thisStaker.hasMigrated);     
        
        assert(block.timestamp > thisStaker.lastTimestamp);
        assert(lastUpdate.timestamp > thisStaker.lastTimestamp);
        
        uint daysStaked = block.timestamp.sub(thisStaker.startTimestamp) / 86400;  
        
        assert(daysStaked >= minStakeDurationDays);
        assert(balance >= minStake);
        
        assert(thisStaker.lastTimestamp >= thisStaker.startTimestamp); 
        
        uint numTokens = iterativelyCalculateOwedRewards(thisStaker.lastTimestamp, thisStaker.startTimestamp, balance, stakerAddress, totalSupply);
        
        stakers[stakerAddress].lastTimestamp = block.timestamp;        
        emit StakesUpdated(numTokens);
        
        return numTokens;       
    }
    
    struct iterativeCalculationVariables {
        uint index;
        uint bound;
        uint numTokens;
        uint calculatedTokens;
    }
    
    
    
    function iterativelyCalculateOwedRewards(uint stakerLastTimestamp, uint stakerStartTimestamp, uint balance, address stakerAddress, uint totalSupply) public view returns (uint256) {
        
        if(useExternalCalcIterative) {
            return externalCalculator.iterativelyCalculateOwedRewards(stakerLastTimestamp, stakerStartTimestamp, balance, stakerAddress, totalSupply);
        }
        
        iterativeCalculationVariables memory vars;    
         
        vars.index = updates.length.sub(1); 
        
        if(vars.index > 60) {
            vars.bound = vars.index.sub(60);        
        } else {
            vars.bound = vars.index.add(1);                    
        }

        vars.numTokens = 0;
        
        for(bool end = false; end == false;) {
            
            update memory nextUpdate = updates[vars.index];      
            if(stakerLastTimestamp > nextUpdate.timestamp || stakerStartTimestamp > nextUpdate.timestamp || vars.index == vars.bound) { 
                end = true;
            } else {
                uint estimatedDaysStaked = nextUpdate.timestamp.sub(stakerStartTimestamp) / 86400; 
                
                vars.calculatedTokens = calculateNumTokens(nextUpdate.numerator, nextUpdate.denominator, nextUpdate.price, nextUpdate.volume, nextUpdate.streak, balance, estimatedDaysStaked, stakerAddress, totalSupply); 
                
                vars.numTokens = vars.numTokens.add(vars.calculatedTokens);
                
                balance = balance.add(vars.calculatedTokens); 
            }
            
            if (vars.index > 0) {
                vars.index = vars.index.sub(1);     
            } else {
                end = true;
            }
            
        }
        return vars.numTokens;
    }

    function calculateNumTokens(uint numerator, uint denominator, uint price, uint volume, uint _streak, uint256 balance, uint256 daysStaked, address stakerAddress, uint256 totalSupply) public view returns (uint256) { 
        
        if (useExternalCalc) {
            return externalCalculator.calculateNumTokens(numerator, denominator, price, volume, _streak, balance, daysStaked, stakerAddress, totalSupply); 
        }
        
        uint256 _inflationAdjustmentFactor = inflationAdjustmentFactor;
        
        if (_streak > 1) {
            _inflationAdjustmentFactor = _inflationAdjustmentFactor.sub(mulDiv(_inflationAdjustmentFactor, _streak*10, 100));       
        }
        
        if (daysStaked > maxStakingDays) {      
            daysStaked = maxStakingDays;
        } else if (daysStaked == 0) {   
            daysStaked = 1;
        }
        
        uint ratio = mulDiv(totalSupply, price, 1000E18).div(volume);       
        
        if (ratio > 50) {  
            _inflationAdjustmentFactor = _inflationAdjustmentFactor.mul(10);
        } else if (ratio > 25) { 
            _inflationAdjustmentFactor = inflationAdjustmentFactor;
        }
        
        uint numTokens = mulDiv(balance, numerator * daysStaked, denominator * _inflationAdjustmentFactor);      
        uint tenPercent = mulDiv(balance, 1, 10);
        
        if (numTokens > tenPercent) {       
            numTokens = tenPercent;
        }
        
        return numTokens;
    }

    function getDaysStaked(address _staker) external view returns(uint) {
        return block.timestamp.sub(stakers[_staker].startTimestamp) / 86400;
    }    
        
    
    function claimHoldersDay() external {
        
        require(!getHoldersDayRewarded(msg.sender), "You've already claimed Holder's Day");
        require(enableHoldersDay, "Holder's Day is not enabled");

        staker memory thisStaker = stakers[msg.sender];
        uint daysStaked = block.timestamp.sub(thisStaker.startTimestamp) / 86400;  
        require(daysStaked >= 30, "You must stake for 30 days to claim holder's day rewards");
        if (enableHoldersDay && daysStaked >= 30) {
            if (daysStaked > maxStakingDays) {      
                daysStaked = maxStakingDays;
            }
            setHoldersDayRewarded(msg.sender);
            uint numTokens = mulDiv(token.balanceOf(msg.sender), daysStaked, holdersDayRewardDenominator);   
            token.mint(msg.sender, numTokens);
            emit HoldersDayRewarded(numTokens);
        }
        
    }

    uint32 public currentHoldersDayRewardedVersion;

    function getHoldersDayRewarded(address holder) internal view returns(bool) {
        bytes32 key = keccak256(abi.encodePacked(currentHoldersDayRewardedVersion, holder));
        return holdersDayRewarded[key];
    }

    function setHoldersDayRewarded(address holder) internal {
        bytes32 key = keccak256(abi.encodePacked(currentHoldersDayRewardedVersion, holder));
        holdersDayRewarded[key] = true;
    }

    function deleteHoldersDayRewarded() internal {
        currentHoldersDayRewardedVersion++;
    }
        
    function updateHoldersDay(bool _enableHoldersDay) external onlyOwner {
        enableHoldersDay = _enableHoldersDay;
        if(enableHoldersDay) {
            deleteHoldersDayRewarded();
            emit HoldersDayEnabled();
        }
    }
    
    
    
    function updateTokenAddress(PampToken newToken) external onlyOwner {
        require(address(newToken) != address(0));
        token = newToken;
    }
    
    function updateCalculator(CalculatorInterface calc) external onlyOwner {
        if(address(calc) == address(0)) {
            externalCalculator = CalculatorInterface(address(0));
            useExternalCalc = false;
        } else {
            externalCalculator = calc;
            useExternalCalc = true;
        }
    }
    
    function updateUseExternalCalcIterative(bool _useExternalCalcIterative) external onlyOwner {
        useExternalCalcIterative = _useExternalCalcIterative;
    }
    
    
    function updateInflationAdjustmentFactor(uint256 _inflationAdjustmentFactor) external onlyOwner {
        inflationAdjustmentFactor = _inflationAdjustmentFactor;
    }
    
    function updateStreak(bool negative, uint _streak) external onlyOwner {
        if(negative) {
            negativeStreak = _streak;
        } else {
            streak = _streak;
        }
    }
    
    function updateMinStakeDurationDays(uint8 _minStakeDurationDays) external onlyOwner {
        minStakeDurationDays = _minStakeDurationDays;
    }
    
    function updateMinStakes(uint _minStake) external onlyOwner {
        minStake = _minStake;
    }
    function updateMinPercentIncrease(uint8 _minIncrease) external onlyOwner {
        minPercentIncrease = _minIncrease;
    }
    
    function updateEnableBurns(bool _enabledBurns) external onlyOwner {
        enableBurns = _enabledBurns;
    }
    
    function updateWhitelist(address addr, string calldata reason, bool remove) external onlyOwner {
        if (remove) {
            delete whitelist[addr];
        } else {
            whitelist[addr] = reason;
        }
    }
    
    function updateUniWhitelist(address addr, string calldata reason, bool remove) external onlyOwner {
        if (remove) {
            delete uniwhitelist[addr];
        } else {
            uniwhitelist[addr] = reason;
        }     
    }
    
    function updateBlacklist(address addr, uint256 fee, bool remove) external onlyOwner {
        if (remove) {
            delete blacklist[addr];
        } else {
            blacklist[addr] = fee;
        }
    }
    
    function updateUniswapPair(address addr) external onlyOwner {
        require(addr != address(0));
        uniswapV2Pair = addr;
    }
    
    function updateEnableUniswapSellBurns(bool _enableDirectSellBurns) external onlyOwner {
        enableUniswapDirectBurns = _enableDirectSellBurns;
    }
    
    function updateUniswapSellBurnPercent(uint8 _sellerBurnPercent) external onlyOwner {
        uniswapSellerBurnPercent = _sellerBurnPercent;
    }
    
    function updateFreeze(bool _enableFreeze) external onlyOwner {
        freeze = _enableFreeze;
    }
    
    function updateNextStakingContract(address nextContract) external onlyOwner {
        nextStakingContract = nextContract;
    }
    
    function updateLiquidityStakingContract(address _liquidityStakingContract) external onlyOwner {
        liquidityStakingContract = _liquidityStakingContract;
    }
    
    function updateOracle(address _oracle) external onlyOwner {
        oracle = _oracle;
    }
    
    function updatePreviousStakingContract(PreviousContract previousContract) external onlyOwner {
        previousStakingContract = previousContract;
    }

    function updateTransferBurnFee(uint _transferBurnFee) external onlyOwner {
        transferBurnPercent = _transferBurnFee;
    }

    function updateMaxStreak(uint _maxStreak) external onlyOwner {
        maxStreak = _maxStreak;
    }

    function updateMaxStakingDays(uint _maxStakingDays) external onlyOwner {
        maxStakingDays = _maxStakingDays;
    }

    function updateHoldersDayRewardDenominator(uint _holdersDayRewardDenominator) external onlyOwner {
        holdersDayRewardDenominator = _holdersDayRewardDenominator;
    }

    function updateIncreaseTransferFees(bool _increaseTransferFees) external onlyOwner {
        increaseTransferFees = _increaseTransferFees;
    }

    function updateCheckPreviousContractWhitelist(bool _checkPreviousStakingContractWhitelist) external onlyOwner {
        checkPreviousStakingContractWhitelist = _checkPreviousStakingContractWhitelist;
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        assert(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function getStaker(address _staker) external view returns (uint256, uint256, bool) {
        return (stakers[_staker].startTimestamp, stakers[_staker].lastTimestamp, stakers[_staker].hasMigrated);
    }
    
    
    function removeLatestUpdate() external onlyOwner {
        delete updates[updates.length - 1];
    }

    
    
    
    
    

    function mulDiv (uint x, uint y, uint z) public pure returns (uint) {
          (uint l, uint h) = fullMul (x, y);
          assert (h < z);
          uint mm = mulmod (x, y, z);
          if (mm > l) h -= 1;
          l -= mm;
          uint pow2 = z & -z;
          z /= pow2;
          l /= pow2;
          l += h * ((-pow2) / pow2 + 1);
          uint r = 1;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          return l * r;
    }
    
    function fullMul (uint x, uint y) private pure returns (uint l, uint h) {
          uint mm = mulmod (x, y, uint (-1));
          l = x * y;
          h = mm - l;
          if (mm < l) h -= 1;
    }

    
    function transferHook(address sender, address recipient, uint256 amount, uint256 senderBalance, uint256 recipientBalance) external onlyToken returns (uint256, uint256, uint256) {
        
        if(sender == liquidityStakingContract) {
            
            token.mint(recipient, amount);
            return (senderBalance, recipientBalance, 0);
        }

        if(checkPreviousStakingContractWhitelist){      
            string memory whitelistSender = previousStakingContract.getWhitelist(sender);
            string memory whitelistRecipient = previousStakingContract.getWhitelist(recipient);
            
            if(bytes(whitelistSender).length > 0) {
                whitelist[sender] = whitelistSender;
            }
            if(bytes(whitelistRecipient).length > 0) {
                whitelist[recipient] = whitelistRecipient;
            }
        }
        
        assert(freeze == false);
        assert(sender != recipient);
        assert(amount > 0);
        assert(senderBalance >= amount);
        
        
        uint totalAmount = amount;
        bool shouldAddStaker = true;    
        uint burnedAmount = 0;
        
        if (enableBurns && bytes(whitelist[sender]).length == 0 && bytes(whitelist[recipient]).length == 0) { 
                
            burnedAmount = mulDiv(amount, burnFee(), 100); 
            
            
            if (blacklist[recipient] > 0) {   
                burnedAmount = mulDiv(amount, blacklist[recipient], 100);      
                shouldAddStaker = false;            
            }
            
            
            
            if (burnedAmount > 0) {
                if (burnedAmount > amount) {
                    totalAmount = 0;
                } else {
                    totalAmount = amount.sub(burnedAmount);
                }
                senderBalance = senderBalance.sub(burnedAmount, "ERC20: burn amount exceeds balance");  
            }
        } else if (recipient == uniswapV2Pair) {    
            shouldAddStaker = false;
            if (enableUniswapDirectBurns && bytes(uniwhitelist[sender]).length == 0) { 
                burnedAmount = mulDiv(amount, uniswapSellerBurnPercent, 100);     
                if (burnedAmount > 0) {
                    if (burnedAmount > amount) {
                        totalAmount = 0;
                    } else {
                        totalAmount = amount.sub(burnedAmount);
                    }
                    senderBalance = senderBalance.sub(burnedAmount, "ERC20: burn amount exceeds balance");
                }
            }
        
        }
        
        if (bytes(whitelist[recipient]).length > 0) {
            shouldAddStaker = false;
        } else if (recipientBalance >= minStake && checkPreviousStakingContractWhitelist) { 
            assert(stakers[recipient].hasMigrated);  
        }
        
        
        
        
        if (shouldAddStaker && stakers[recipient].startTimestamp > 0 && recipientBalance > 0) {  
        
            assert(stakers[recipient].hasMigrated);    
            
            uint percent = mulDiv(1000000, totalAmount, recipientBalance);      
            if(percent == 0) {
                percent == 2;
            }
            percent = percent.div(2);       

            if(percent.add(stakers[recipient].startTimestamp) > block.timestamp) {         
                stakers[recipient].startTimestamp = block.timestamp;
            } else {
                stakers[recipient].startTimestamp = stakers[recipient].startTimestamp.add(percent);               
            }
            if(percent.add(stakers[recipient].lastTimestamp) > block.timestamp) {
                stakers[recipient].lastTimestamp = block.timestamp;
            } else {
                stakers[recipient].lastTimestamp = stakers[recipient].lastTimestamp.add(percent);                 
            }
        } else if (shouldAddStaker && recipientBalance == 0 && (stakers[recipient].startTimestamp > 0 || stakers[recipient].lastTimestamp > 0)) { 
            delete stakers[recipient];
            numStakers--;
            emit StakerRemoved(recipient);
        }
        
        senderBalance = senderBalance.sub(totalAmount, "ERC20: transfer amount exceeds balance");       
        recipientBalance = recipientBalance.add(totalAmount);
        
        if (shouldAddStaker && stakers[recipient].startTimestamp == 0 && (totalAmount >= minStake || recipientBalance >= minStake)) {        
            numStakers++;
            stakers[recipient] = staker(block.timestamp, block.timestamp, true);
            emit StakerAdded(recipient);
        }
        
        if (senderBalance < minStake) {        
            
            delete stakers[sender];
            numStakers--;
            emit StakerRemoved(sender);
        } else {
            stakers[sender].startTimestamp = block.timestamp;      
            stakers[sender].lastTimestamp = block.timestamp;       
            stakers[sender].hasMigrated = true;       
        }
    
        return (senderBalance, recipientBalance, burnedAmount);
    }
    
    
    function burnFee() internal view returns (uint256) {        
        return transferBurnPercent;
    }
    
    function burn(address account, uint256 amount) external onlyOwner {     
        token._burn(account, amount);
    }
    
    function liquidityRewards(address recipient, uint amount) external {    
        require(msg.sender == liquidityStakingContract);
        token.mint(recipient, amount);
    }
    
    function resetStakeTimeDebug(address account, uint startTimestamp, uint lastTimestamp, bool migrated) external onlyOwner {      
        stakers[account].lastTimestamp = startTimestamp;
        stakers[account].startTimestamp = lastTimestamp;
        stakers[account].hasMigrated = migrated;
    }



}