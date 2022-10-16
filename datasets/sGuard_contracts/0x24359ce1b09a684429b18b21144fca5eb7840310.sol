pragma solidity ^0.6.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract CalculatorInterface {
    function calculateNumTokens(uint256 balance, uint256 daysStaked, address stakerAddress, uint256 totalSupply) public virtual returns (uint256);
    function randomness() public view virtual returns (uint256);
}

abstract contract DepoToken {
    function balanceOf(address account) public view virtual returns (uint256);
    function _burn(address account, uint256 amount) external virtual;
}




contract StakeDepoToken is Ownable {
    using SafeMath for uint256;
    
    struct staker {
        uint startTimestamp;
        uint lastTimestamp;
    }
    
    struct update {
        uint timestamp;
        uint numerator;
        uint denominator;
        uint price;         
        uint volume;        
    }
    
    struct seller {
        address addr;
        uint256 burnAmount;
    }
    
    DepoToken public token;
    
    modifier onlyToken() {
        require(_msgSender() == address(token), "Caller must be DEPO token contract.");
        _;
    }

    
    mapping (address => staker) public _stakers;
    
    mapping (address => string) public _whitelist;
    
    mapping (address => uint256) public _blacklist;
    
    bool private _enableDelayedSellBurns;
    
    bool private _enableBurns;
    
    bool private _priceTarget1Hit;
    
    bool private _priceTarget2Hit;
    
    address private _uniswapV2Pair;
    
    address private _uniswapV1Pair;
    
    seller[] private _delayedBurns;
    
    uint8 private _uniswapSellerBurnPercent;

    
    uint256 private _minStake;
    
    uint8 private _minStakeDurationDays;
    
    uint8 private _minPercentIncrease;
    
    uint256 private _inflationAdjustmentFactor;
    
    uint256 private _streak;
    
    update public _lastUpdate;
    
    CalculatorInterface private _externalCalculator;
    
    bool private _useExternalCalc;
    
    bool private _freeze;
    
    bool private _enableHoldersDay;
    
    event StakerRemoved(address StakerAddress);
    
    event StakerAdded(address StakerAddress);
    
    event StakesUpdated(uint Amount);
    
    event MassiveCelebration();
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    
    constructor (DepoToken newToken) public {
        token = newToken;
        _minStake = 500E18;
        _inflationAdjustmentFactor = 100;
        _streak = 0;
        _minStakeDurationDays = 1;
        _useExternalCalc = false;
        _uniswapSellerBurnPercent = 5;
        _enableDelayedSellBurns = true;
        _enableBurns = false;
        _freeze = false;
        _minPercentIncrease = 10; 
    }
    
    
    function updateState(uint numerator, uint denominator, uint256 price, uint256 volume) external onlyOwner {  
    
        require(numerator != 0 && denominator != 0 && price != 0 && volume != 0, "Parameters cannot be zero");
        
        if (numerator < 2 && denominator == 100 || numerator < 20 && denominator == 1000) {
            require(mulDiv(1000, numerator, denominator) >= _minPercentIncrease, "Increase must be at least _minPercentIncrease to count");
        }
        
        
        
        uint8 daysSinceLastUpdate = uint8((block.timestamp - _lastUpdate.timestamp) / 86400);
        
        if (daysSinceLastUpdate == 0) {
            
            _streak++;
        } else if (daysSinceLastUpdate == 1) {
            _streak++;
        } else {
            _streak = 1;
        }
        
        if (price >= 1000 && _priceTarget1Hit == false) { 
            _priceTarget1Hit = true;
            _streak = 50;
            emit MassiveCelebration();
            
        } else if (price >= 10000 && _priceTarget2Hit == false) {   
            _priceTarget2Hit = true;
            _streak = 100;
             _minStake = 100;        
            emit MassiveCelebration();
        }
        
        _lastUpdate = update(block.timestamp, numerator, denominator, price, volume);

    }
    
    function updateMyStakes(address stakerAddress, uint256 balance, uint256 totalSupply) external onlyToken returns (uint256) {
        
        require((block.timestamp.sub(_lastUpdate.timestamp)) / 86400 == 0, "Stakes must be updated the same day of the latest update");
        
    
        staker memory thisStaker = _stakers[stakerAddress];
        
        require(block.timestamp > thisStaker.lastTimestamp, "Error: block timestamp is not greater than your last timestamp!");
        
        require(_lastUpdate.timestamp > thisStaker.lastTimestamp, "Error: you can only update stakes once per day. You also cannot update stakes on the same day that you purchased them.");
        require(thisStaker.lastTimestamp != 0, "Error: your last timestamp cannot be zero.");
        require(thisStaker.startTimestamp != 0, "Error: your start timestamp cannot be zero.");
        
        uint daysStaked = block.timestamp.sub(thisStaker.startTimestamp) / 86400;
        
        require(daysStaked >= _minStakeDurationDays, "You must stake for at least minStakeDurationDays to claim rewards");
        require(balance >= _minStake, "You must have a balance of at least minStake to claim rewards");
        require(thisStaker.startTimestamp > 0, "Your start timestamp must be greater than 0");

            
        uint numTokens = calculateNumTokens(balance, daysStaked, stakerAddress, totalSupply);
        if (_enableHoldersDay && daysStaked >= 30) {
            numTokens = mulDiv(balance, daysStaked, 600);   
        }
        
        _stakers[stakerAddress].lastTimestamp = block.timestamp;
        emit StakesUpdated(numTokens);
        
        return numTokens;
    
        
    }
    
    function calculateNumTokens(uint256 balance, uint256 daysStaked, address stakerAddress, uint256 totalSupply) internal returns (uint256) {
        
        if (_useExternalCalc) {
            return _externalCalculator.calculateNumTokens(balance, daysStaked, stakerAddress, totalSupply);
        }
        
        uint256 inflationAdjustmentFactor = _inflationAdjustmentFactor;
        
        if (_streak > 1) {
            inflationAdjustmentFactor /= _streak;
        }
        
        if (daysStaked > 60) {
            daysStaked = 60;
        } 
        
        uint marketCap = totalSupply.mul(_lastUpdate.price);
        
        uint ratio = marketCap.div(_lastUpdate.volume);
        
        if (ratio > 50) {  
            inflationAdjustmentFactor = inflationAdjustmentFactor.mul(10);
        } else if (ratio > 25) { 
            inflationAdjustmentFactor = _inflationAdjustmentFactor;
        }
        
        uint numTokens = mulDiv(balance, _lastUpdate.numerator * daysStaked, _lastUpdate.denominator * inflationAdjustmentFactor);
        uint tenPercent = mulDiv(balance, 1, 10);
        
        if (numTokens > tenPercent) {
            numTokens = tenPercent;
        }
        
        return numTokens;
    }
    
    function updateTokenAddress(DepoToken newToken) external onlyOwner {
        token = newToken;
    }
    
    function updateCalculator(CalculatorInterface calc) external {
       _externalCalculator = calc;
       _useExternalCalc = true;
    }
    
    
    function updateInflationAdjustmentFactor(uint256 inflationAdjustmentFactor) external onlyOwner {
        _inflationAdjustmentFactor = inflationAdjustmentFactor;
    }
    
    function updateStreak(uint streak) external onlyOwner {
        _streak = streak;
    }
    
    function updateMinStakeDurationDays(uint8 minStakeDurationDays) external onlyOwner {
        _minStakeDurationDays = minStakeDurationDays;
    }
    
    function updateMinStakes(uint minStake) external onlyOwner {
        _minStake = minStake;
    }
    function updateMinPercentIncrease(uint8 minIncrease) external onlyOwner {
        _minPercentIncrease = minIncrease;
    }
    
    function enableBurns(bool enabledBurns) external onlyOwner {
        _enableBurns = enabledBurns;
    }
    function updateHoldersDay(bool enableHoldersDay)   external onlyOwner {
        _enableHoldersDay = enableHoldersDay;
    }
    
    function updateWhitelist(address addr, string calldata reason, bool remove) external onlyOwner returns (bool) {
        if (remove) {
            delete _whitelist[addr];
            return true;
        } else {
            _whitelist[addr] = reason;
            return true;
        }
        return false;        
    }
    
    function updateBlacklist(address addr, uint256 fee, bool remove) external onlyOwner returns (bool) {
        if (remove) {
            delete _blacklist[addr];
            return true;
        } else {
            _blacklist[addr] = fee;
            return true;
        }
        return false;
    }
    
    function updateUniswapPair(address addr, bool V1) external onlyOwner returns (bool) {
        if (V1) {
            _uniswapV1Pair = addr;
            return true;
        } else {
            _uniswapV2Pair = addr;
            return true;
        }
        return false;
    }
    
    function updateDelayedSellBurns(bool enableDelayedSellBurns) external onlyOwner {
        _enableDelayedSellBurns = enableDelayedSellBurns;
    }
    
    function updateUniswapSellerBurnPercent(uint8 sellerBurnPercent) external onlyOwner {
        _uniswapSellerBurnPercent = sellerBurnPercent;
    }
    
    function freeze(bool enableFreeze) external onlyOwner {
        _freeze = enableFreeze;
    }
    

    function mulDiv (uint x, uint y, uint z) public pure returns (uint) {
          (uint l, uint h) = fullMul (x, y);
          require (h < z);
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
    
    function streak() public view returns (uint) {
        return _streak;
    }


    
    function transferHook(address sender, address recipient, uint256 amount, uint256 senderBalance, uint256 recipientBalance) external onlyToken returns (uint256, uint256, uint256) {
        
        require(_freeze == false, "Contract is frozen.");
        
        uint totalAmount = amount;
        bool shouldAddStaker = true;
        bool addedToDelayedBurns = false;
        uint burnedAmount = 0;
        
        if (_enableBurns && bytes(_whitelist[sender]).length == 0 && bytes(_whitelist[recipient]).length == 0 && bytes(_whitelist[_msgSender()]).length == 0) {
                
            burnedAmount = mulDiv(amount, _randomness(), 100);
            
            
            if (_blacklist[recipient] != 0) {   
                burnedAmount = mulDiv(amount, _blacklist[recipient], 100);
                shouldAddStaker = false;
            }
            
            
            
            if (burnedAmount > 0) {
                if (burnedAmount > amount) {
                    totalAmount = 0;
                } else {
                    totalAmount = amount.sub(burnedAmount);
                }
                senderBalance = senderBalance.sub(burnedAmount, "ERC20: burn amount amount exceeds balance");
            }
        } else if (recipient == _uniswapV2Pair || recipient == _uniswapV1Pair) {    
            shouldAddStaker = false;
            if (_enableDelayedSellBurns && bytes(_whitelist[sender]).length == 0) { 
                uint delayedBurnAmount = mulDiv(amount, _uniswapSellerBurnPercent, 100);     
                seller memory _seller;
                _seller.addr = sender;
                _seller.burnAmount = delayedBurnAmount;
                _delayedBurns.push(_seller);
                addedToDelayedBurns = true;
            }
        
        }
        
        if (bytes(_whitelist[recipient]).length != 0) {
            shouldAddStaker = false;
        }
        
        
        if (shouldAddStaker && _stakers[recipient].startTimestamp != 0 && recipientBalance != 0) {  
            uint percent = mulDiv(1000000, totalAmount, recipientBalance);
            require(percent > 0, "The amount you are transferring is too low as a percentage of the total balance.");
            if(percent.add(_stakers[recipient].startTimestamp) > block.timestamp) {         
                _stakers[recipient].startTimestamp = block.timestamp;
            } else {
                _stakers[recipient].startTimestamp = _stakers[recipient].startTimestamp.add(percent);               
            }
            if(percent.add(_stakers[recipient].lastTimestamp) > block.timestamp) {
                _stakers[recipient].lastTimestamp = block.timestamp;
            } else {
                _stakers[recipient].lastTimestamp = _stakers[recipient].lastTimestamp.add(percent);                 
            }
        }
        

        senderBalance = senderBalance.sub(totalAmount, "ERC20: transfer amount exceeds balance");
        recipientBalance = recipientBalance.add(totalAmount);
        
        if (shouldAddStaker && _stakers[recipient].startTimestamp == 0 && (totalAmount >= _minStake || recipientBalance >= _minStake)) {
            _stakers[recipient] = staker(block.timestamp, block.timestamp);
            emit StakerAdded(recipient);
        }
        
        if (senderBalance < _minStake) {
            
            delete _stakers[sender];
            emit StakerRemoved(sender);
        } else {
            _stakers[sender].startTimestamp = block.timestamp;
            if (_stakers[sender].lastTimestamp == 0) {
                _stakers[sender].lastTimestamp = block.timestamp;
            }
        }
        
        if (_enableDelayedSellBurns && _delayedBurns.length > 0 && !addedToDelayedBurns) {
            
             seller memory _seller = _delayedBurns[_delayedBurns.length - 1];
             _delayedBurns.pop();
             
             uint balance = token.balanceOf(_seller.addr);
             
             if(balance >= _seller.burnAmount) {
                 
                 balance = balance.sub(_seller.burnAmount);
                 token._burn(_seller.addr, _seller.burnAmount);
                 
                 if (_stakers[_seller.addr].startTimestamp != 0 && balance < _minStake) {
                     
                    delete _stakers[_seller.addr];
                    emit StakerRemoved(_seller.addr);
                 }
             } else if (balance != 0) {
                token._burn(_seller.addr, balance);
                delete _stakers[_seller.addr];
             }
        }
        
        return (senderBalance, recipientBalance, burnedAmount);
    }
    
    
    function _randomness() internal view returns (uint256) {
        if(_useExternalCalc) {
            return _externalCalculator.randomness();
        }
        return 1 + uint256(keccak256(abi.encodePacked(blockhash(block.number-1), _msgSender())))%4;
    }



}