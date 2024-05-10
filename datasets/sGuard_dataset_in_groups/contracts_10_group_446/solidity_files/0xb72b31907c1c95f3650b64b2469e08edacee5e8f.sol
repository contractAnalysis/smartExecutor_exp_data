pragma solidity 0.5.17;


contract IERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function approve(address _spender, uint256 _value) public returns (bool);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
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
        require(isOwner(), "unauthorized");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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



library Checkpointing {

    struct Checkpoint {
        uint256 time;
        uint256 value;
    }

    struct History {
        Checkpoint[] history;
    }

    function addCheckpoint(
        History storage _self,
        uint256 _time,
        uint256 _value)
        internal
    {
        uint256 length = _self.history.length;
        if (length == 0) {
            _self.history.push(Checkpoint(_time, _value));
        } else {
            Checkpoint storage currentCheckpoint = _self.history[length - 1];
            uint256 currentCheckpointTime = currentCheckpoint.time;

            if (_time > currentCheckpointTime) {
                _self.history.push(Checkpoint(_time, _value));
            } else if (_time == currentCheckpointTime) {
                currentCheckpoint.value = _value;
            } else { 
                revert("past-checkpoint");
            }
        }
    }

    function getValueAt(
        History storage _self,
        uint256 _time)
        internal
        view
        returns (uint256)
    {
        return _getValueAt(_self, _time);
    }

    function lastUpdated(
        History storage _self)
        internal
        view
        returns (uint256)
    {
        uint256 length = _self.history.length;
        if (length != 0) {
            return _self.history[length - 1].time;
        }
    }

    function latestValue(
        History storage _self)
        internal
        view
        returns (uint256)
    {
        uint256 length = _self.history.length;
        if (length != 0) {
            return _self.history[length - 1].value;
        }
    }

    function _getValueAt(
        History storage _self,
        uint256 _time)
        private
        view
        returns (uint256)
    {
        uint256 length = _self.history.length;

        
        
        
        if (length == 0) {
            return 0;
        }

        
        uint256 lastIndex = length - 1;
        Checkpoint storage lastCheckpoint = _self.history[lastIndex];
        if (_time >= lastCheckpoint.time) {
            return lastCheckpoint.value;
        }

        
        if (length == 1 || _time < _self.history[0].time) {
            return 0;
        }

        
        
        uint256 low = 0;
        uint256 high = lastIndex - 1;

        while (high != low) {
            uint256 mid = (high + low + 1) / 2; 
            Checkpoint storage checkpoint = _self.history[mid];
            uint256 midTime = checkpoint.time;

            if (_time > midTime) {
                low = mid;
            } else if (_time < midTime) {
                
                
                high = mid - 1;
            } else {
                
                return checkpoint.value;
            }
        }

        return _self.history[low].value;
    }
}

contract CheckpointingToken is IERC20 {
    using Checkpointing for Checkpointing.History;

    mapping (address => mapping (address => uint256)) internal allowances_;

    mapping (address => Checkpointing.History) internal balancesHistory_;

    struct Checkpoint {
        uint256 time;
        uint256 value;
    }

    struct History {
        Checkpoint[] history;
    }

    
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return 0;
    }

    function balanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balanceOfAt(_owner, block.number);
    }

    function balanceOfAt(
        address _owner,
        uint256 _blockNumber)
        public
        view
        returns (uint256)
    {
        return balancesHistory_[_owner].getValueAt(_blockNumber);
    }

    function allowance(
        address _owner,
        address _spender)
        public
        view
        returns (uint256)
    {
        return allowances_[_owner][_spender];
    }

    function approve(
        address _spender,
        uint256 _value)
        public
        returns (bool)
    {
        allowances_[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        return transferFrom(
            msg.sender,
            _to,
            _value
        );
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        uint256 previousBalanceFrom = balanceOfAt(_from, block.number);
        require(previousBalanceFrom >= _value, "insufficient-balance");

        if (_from != msg.sender && allowances_[_from][msg.sender] != uint(-1)) {
            require(allowances_[_from][msg.sender] >= _value, "insufficient-allowance");
            allowances_[_from][msg.sender] = allowances_[_from][msg.sender] - _value; 
        }

        balancesHistory_[_from].addCheckpoint(
            block.number,
            previousBalanceFrom - _value 
        );

        balancesHistory_[_to].addCheckpoint(
            block.number,
            add(
                balanceOfAt(_to, block.number),
                _value
            )
        );

        emit Transfer(_from, _to, _value);
        return true;
    }

    function _getBlockNumber()
        internal
        view
        returns (uint256)
    {
        return block.number;
    }

    function _getTimestamp()
        internal
        view
        returns (uint256)
    {
        return block.timestamp;
    }

    function add(
        uint256 x,
        uint256 y)
        internal
        pure
        returns (uint256 c)
    {
        require((c = x + y) >= x, "addition-overflow");
    }

    function sub(
        uint256 x,
        uint256 y)
        internal
        pure
        returns (uint256 c)
    {
        require((c = x - y) <= x, "subtraction-overflow");
    }

    function mul(
        uint256 a,
        uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        require((c = a * b) / a == b, "multiplication-overflow");
    }

    function div(
        uint256 a,
        uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        require(b != 0, "division by zero");
        c = a / b;
    }
}

contract BZRXVestingToken is CheckpointingToken, Ownable {

    event Claim(
        address indexed owner,
        uint256 value
    );

    string public constant name = "bZx Vesting Token";
    string public constant symbol = "vBZRX";
    uint8 public constant decimals = 18;

    uint256 public constant cliffDuration =                  15768000; 
    uint256 public constant vestingDuration =               126144000; 
    uint256 internal constant vestingDurationAfterCliff_ =  110376000; 

    uint256 public constant vestingStartTimestamp =         1594648800; 
    uint256 public constant vestingCliffTimestamp =         vestingStartTimestamp + cliffDuration;
    uint256 public constant vestingEndTimestamp =           vestingStartTimestamp + vestingDuration;
    uint256 public constant vestingLastClaimTimestamp =     vestingEndTimestamp + 86400 * 365;

    uint256 public totalClaimed; 

    IERC20 public constant BZRX = IERC20(0x56d811088235F11C8920698a204A5010a788f4b3);

    uint256 internal constant startingBalance_ = 889389933e18; 

    Checkpointing.History internal totalSupplyHistory_;

    mapping (address => uint256) internal lastClaimTime_;
    mapping (address => uint256) internal userTotalClaimed_;

    bool internal isInitialized_;


    
    function initialize()
        external
    {
        require(!isInitialized_, "already initialized");

        balancesHistory_[msg.sender].addCheckpoint(_getBlockNumber(), startingBalance_);
        totalSupplyHistory_.addCheckpoint(_getBlockNumber(), startingBalance_);

        emit Transfer(
            address(0),
            msg.sender,
            startingBalance_
        );

        BZRX.transferFrom(
            msg.sender,
            address(this),
            startingBalance_
        );

        isInitialized_ = true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        _claim(_from);
        if (_from != _to) {
            _claim(_to);
        }

        return super.transferFrom(
            _from,
            _to,
            _value
        );
    }

    
    function claim()
        public
    {
        _claim(msg.sender);
    }

    
    function burn()
        external
    {
        require(_getTimestamp() >= vestingEndTimestamp, "not fully vested");

        _claim(msg.sender);

        uint256 _blockNumber = _getBlockNumber();
        uint256 balanceBefore = balanceOfAt(msg.sender, _blockNumber);
        balancesHistory_[msg.sender].addCheckpoint(_blockNumber, 0);
        totalSupplyHistory_.addCheckpoint(_blockNumber, totalSupplyAt(_blockNumber) - balanceBefore); 

        emit Transfer(
            msg.sender,
            address(0),
            balanceBefore
        );
    }

    
    function rescue(
        address _receiver,
        uint256 _amount)
        external
        onlyOwner
    {
        require(_getTimestamp() > vestingLastClaimTimestamp, "unauthorized");

        BZRX.transfer(
            _receiver,
            _amount
        );
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupplyAt(_getBlockNumber());
    }

    function totalSupplyAt(
        uint256 _blockNumber)
        public
        view
        returns (uint256)
    {
        return totalSupplyHistory_.getValueAt(_blockNumber);
    }

    
    function vestedBalanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        uint256 lastClaim = lastClaimTime_[_owner];
        if (lastClaim < _getTimestamp()) {
            return _totalVested(
                balanceOfAt(_owner, _getBlockNumber()),
                lastClaim
            );
        }
    }

    
    function vestingBalanceOf(
        address _owner)
        public
        view
        returns (uint256 balance)
    {
        balance = balanceOfAt(_owner, _getBlockNumber());
        if (balance != 0) {
            uint256 lastClaim = lastClaimTime_[_owner];
            if (lastClaim < _getTimestamp()) {
                balance = sub(
                    balance,
                    _totalVested(
                        balance,
                        lastClaim
                    )
                );
            }
        }
    }

    
    function claimedBalanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return userTotalClaimed_[_owner];
    }

    
    function totalVested()
        external
        view
        returns (uint256)
    {
        return _totalVested(startingBalance_, 0);
    }

    
    function totalUnclaimed()
        external
        view
        returns (uint256)
    {
        return sub(
            _totalVested(startingBalance_, 0),
            totalClaimed
        );
    }

    function _claim(
        address _owner)
        internal
    {
        uint256 vested = vestedBalanceOf(_owner);
        if (vested != 0) {
            userTotalClaimed_[_owner] = add(userTotalClaimed_[_owner], vested);
            totalClaimed = add(totalClaimed, vested);

            BZRX.transfer(
                _owner,
                vested
            );

            emit Claim(
                _owner,
                vested
            );
        }

        lastClaimTime_[_owner] = _getTimestamp();
    }

    function _totalVested(
        uint256 _proportionalSupply,
        uint256 _lastClaimTime)
        internal
        view
        returns (uint256)
    {
        uint256 currentTimeForVesting = _getTimestamp();

        if (currentTimeForVesting <= vestingCliffTimestamp ||
            _lastClaimTime >= vestingEndTimestamp ||
            currentTimeForVesting > vestingLastClaimTimestamp) {
            
            
            
            return 0;
        }
        if (_lastClaimTime < vestingCliffTimestamp) {
            
            _lastClaimTime = vestingCliffTimestamp;
        }
        if (currentTimeForVesting > vestingEndTimestamp) {
            
            currentTimeForVesting = vestingEndTimestamp;
        }

        uint256 timeSinceClaim = sub(currentTimeForVesting, _lastClaimTime);
        return mul(_proportionalSupply, timeSinceClaim) / vestingDurationAfterCliff_; 
    }
}