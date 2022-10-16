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

contract BZRXToken is CheckpointingToken {

    string public constant name = "bZx Protocol Token";
    string public constant symbol = "BZRX";
    uint8 public constant decimals = 18;

    uint256 internal constant totalSupply_ = 1030000000e18; 

    constructor(
        address _to)
        public
    {
        balancesHistory_[_to].addCheckpoint(_getBlockNumber(), totalSupply_);
        emit Transfer(address(0), _to, totalSupply_);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupply_;
    }
}