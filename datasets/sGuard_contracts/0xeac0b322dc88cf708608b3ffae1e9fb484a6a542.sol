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

contract TraderCompensation is Ownable {

    IERC20 public constant vBZRX = IERC20(0xB72B31907C1C95F3650b64b2469e08EdACeE5e8F);

    uint256 public optinStartTimestamp;
    uint256 public optinEndTimestamp;
    uint256 public claimStartTimestamp;
    uint256 public claimEndTimestamp;

    bool public isActive;
    uint256 public vBZRXDistributed;

    mapping (address => uint256) public whitelist;
    mapping (address => bool) public optinlist;

    constructor(
        uint256 _optinDuration,
        uint256 _claimDuration)
        public
    {
        setTimestamps(
            _getTimestamp(),
            _getTimestamp() + _optinDuration,
            _getTimestamp() + _optinDuration + _claimDuration
        );

        isActive = true;
    }

    function optin()
        external
    {
        require(_getTimestamp() < optinEndTimestamp, "opt-in has ended");
        optinlist[msg.sender] = true;
    }

    function claim()
        external
    {
        require(_getTimestamp() >= claimStartTimestamp, "claim not started");
        require(_getTimestamp() < claimEndTimestamp, "claim has ended");

        uint256 whitelistAmount = whitelist[msg.sender];
        require(isActive && whitelistAmount != 0, "unauthorized");
        require(optinlist[msg.sender], "no opt-in found");

        vBZRX.transfer(
            msg.sender,
            whitelistAmount
        );

        
        vBZRXDistributed += whitelistAmount;
        whitelist[msg.sender] = 0;
    }

    function setWhitelist(
        address[] memory addrs,
        uint256[] memory amounts)
        public
        onlyOwner
    {
        require(addrs.length == amounts.length, "count mismatch");

        for (uint256 i = 0; i < addrs.length; i++) {
            whitelist[addrs[i]] = amounts[i];
        }
    }

    function setOptin(
        address addr,
        bool val)
        public
        onlyOwner
    {
        optinlist[addr] = val;
    }

    function setActive(
        bool _isActive)
        public
        onlyOwner
    {
        isActive = _isActive;
    }

    function setTimestamps(
        uint256 _optinStartTimestamp,
        uint256 _optinEndTimestamp,
        uint256 _claimEndTimestamp)
        public
        onlyOwner
    {
        require(_optinEndTimestamp > _optinStartTimestamp && _claimEndTimestamp > _optinEndTimestamp, "invalid params");
        optinStartTimestamp = _optinStartTimestamp;
        optinEndTimestamp = _optinEndTimestamp;
        claimStartTimestamp = _optinEndTimestamp;
        claimEndTimestamp = _claimEndTimestamp;
    }

    function withdrawVBZRX(
        uint256 _amount)
        public
        onlyOwner
    {
        uint256 balance = vBZRX.balanceOf(address(this));
        if (_amount > balance) {
            _amount = balance;
        }

        if (_amount != 0) {
            vBZRX.transfer(
                msg.sender,
                _amount
            );
        }
    }

    function canOptin(
        address _user)
        external
        view
        returns (bool)
    {
        return _getTimestamp() < optinEndTimestamp &&
            !optinlist[_user] &&
            whitelist[_user] != 0 &&
            isActive;
    }

    function claimable(
        address _user)
        external
        view
        returns (uint256)
    {
        uint256 whitelistAmount = whitelist[_user];
        if (whitelistAmount != 0 &&
            _getTimestamp() >= claimStartTimestamp &&
            _getTimestamp() < claimEndTimestamp &&
            optinlist[_user] &&
            isActive) {
            return whitelistAmount;
        }
    }

    function _getTimestamp()
        internal
        view
        returns (uint256)
    {
        return block.timestamp;
    }
}