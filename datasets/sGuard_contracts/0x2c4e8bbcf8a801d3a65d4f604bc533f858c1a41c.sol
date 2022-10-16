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



contract Locker {
    IERC20  APIX;
    address receiver;
    uint16 unlockStartYear;
    uint256 unlockStartTime;
    uint256 unlockOffsetTime = 7884000; 
    uint256 totalLockedBalance = 0;
    uint256 unlockBalancePerRound = 0;
    uint8 lastRound = 0;
    
    
    event Lock(uint256 value);
    
    
    event Unlock(uint256 value, address receiver);
    
    
    constructor (address _APIX, address _receiver, uint256 _unlockStartTime, uint16 _unlockStartYear) public {
        APIX = IERC20(_APIX);
        receiver = _receiver;
        unlockStartTime = _unlockStartTime;
        unlockStartYear = _unlockStartYear;
    }
    
    
    function getLockedBalance() external view returns (uint256) {
        return APIX.balanceOf(address(this));
    }
    
    
    function getTotalLockedBalance() external view returns (uint256) {
        return totalLockedBalance;
    }
    
    
    function getNextRound() external view returns (uint8) {
        return lastRound + 1;
    }
    
    
    function _getNextRoundTime() internal view returns (uint256) {
        return unlockStartTime + unlockOffsetTime * (lastRound + 1);
    }
    function getNextRoundTime() external view returns (uint256) {
        return _getNextRoundTime();
    }
    
    
    function _getNextUnlockToken() internal view returns (uint256) {
        uint8 round = lastRound + 1;
        uint256 unlockAmount;
        
        if(round < 4) {
            unlockAmount = unlockBalancePerRound;
        }
        else {
            unlockAmount = APIX.balanceOf(address(this));
        }
        
        return unlockAmount;
    }
    function getNextUnlockToken() external view returns (uint256) {
        return _getNextUnlockToken();
    }
    
    
    function getLockInfo() external view returns (uint256 initLockedToken, uint256 balance, uint16 unlockYear, uint8 nextRound, uint256 nextRoundUnlockAt, uint256 nextRoundUnlockToken) {
        initLockedToken = totalLockedBalance;
        balance = APIX.balanceOf(address(this));
        nextRound = lastRound + 1;
        nextRoundUnlockAt = _getNextRoundTime();
        nextRoundUnlockToken = _getNextUnlockToken();
        unlockYear = unlockStartYear;
    }
    
    
    
    function initLockedBalance() public returns (uint256) {
        require(totalLockedBalance == 0, "Locker: There is no token stored");
        
        totalLockedBalance = APIX.balanceOf(address(this));
        unlockBalancePerRound = totalLockedBalance / 4;
        
        emit Lock (totalLockedBalance);
        
        return totalLockedBalance;
    }
    
    
    function unlock(uint8 round) public returns (bool) {
        
        require(totalLockedBalance > 0, "Locker: There is no locked token");
        
        
        
        require(round == lastRound + 1, "Locker: The round value is incorrect");
        
        
        
        
        
        
        
        
        require(block.timestamp >= _getNextRoundTime(), "Locker: It's not time to unlock yet");
        
        
        
        uint256 amount = _getNextUnlockToken();
        require(amount > 0, 'Locker: There is no unlockable token');
        require(APIX.transfer(receiver, amount));
        
        emit Unlock(amount, receiver);
        
        
        lastRound = round;
        return true;
    }
}