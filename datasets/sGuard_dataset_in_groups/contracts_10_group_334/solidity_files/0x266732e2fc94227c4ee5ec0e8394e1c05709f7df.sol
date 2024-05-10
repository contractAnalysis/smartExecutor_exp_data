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

contract BZRXv1Converter is Ownable {

    event ConvertBZRX(
        address indexed sender,
        uint256 amount
    );

    IERC20 public constant BZRXv1 = IERC20(0x1c74cFF0376FB4031Cd7492cD6dB2D66c3f2c6B9);
    IERC20 public constant BZRX = IERC20(0x56d811088235F11C8920698a204A5010a788f4b3);

    uint256 public totalConverted;
    uint256 public terminationTimestamp;

    function convert(
        uint256 _tokenAmount)
        external
    {
        require((
            _getTimestamp() < terminationTimestamp &&
            msg.sender != address(1)) ||
            msg.sender == owner(), "convert not allowed");

        BZRXv1.transferFrom(
            msg.sender,
            address(1), 
            _tokenAmount
        );

        BZRX.transfer(
            msg.sender,
            _tokenAmount
        );

        
        totalConverted += _tokenAmount;

        emit ConvertBZRX(
            msg.sender,
            _tokenAmount
        );
    }

    
    function initialize()
        external
        onlyOwner
    {
        require(terminationTimestamp == 0, "already initialized");
        terminationTimestamp = _getTimestamp() + 60 * 60 * 24 * 365; 
    }

    
    function rescue(
        address _receiver,
        uint256 _amount)
        external
        onlyOwner
    {
        require(_getTimestamp() > terminationTimestamp, "unauthorized");

        BZRX.transfer(
            _receiver,
            _amount
        );
    }

    function _getTimestamp()
        internal
        view
        returns (uint256)
    {
        return block.timestamp;
    }
}