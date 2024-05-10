pragma solidity ^0.5.9;



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


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TokenSwap is Ownable{
    using SafeMath for uint256;
    address private _tokenAddress;

    event TokenAddressChanged(address indexed previousTokenAddress, address indexed newTokenAddress);
    event ReturnTokens(address indexed owner, address indexed _token, uint256 amount);

    constructor (address tokenAddress) public {
        _tokenAddress = tokenAddress;
    }

    function tokenAddress() public view returns (address) {
        return _tokenAddress;
    }

    function setTokenAddress(address newTokenAddress) public onlyOwner {
        require(newTokenAddress != address(0));
        emit TokenAddressChanged(_tokenAddress, newTokenAddress);
        _tokenAddress = newTokenAddress;
    }
     function tokenSwapAfterVerification(address[] memory _addrs, uint256[] memory _values, uint256 totalValue) public onlyOwner {
        require(_addrs.length == _values.length);
        uint256 verificationValue = 0;

        for(uint256 i = 0; i < _values.length; i++) {
            verificationValue = verificationValue.add(_values[i]);
        }

        require(verificationValue == totalValue);
        IERC20 token = IERC20(_tokenAddress);

        for(uint256 i = 0; i < _addrs.length; i++) {
            require(token.transfer(_addrs[i], _values[i]));
        }
    }

    function tokenSwap(address[] memory _addrs, uint256[] memory _values) public onlyOwner {
        require(_addrs.length == _values.length);
        IERC20 token = IERC20(_tokenAddress);

        for(uint256 i = 0; i < _addrs.length; i++) {
            require(token.transfer(_addrs[i], _values[i]));
        }
    }

    function returnTokens(address _token, uint256 amount) public onlyOwner {
        IERC20 token = IERC20(_token);
        address thisAddress = address(this);
        uint256 tokenBalance = token.balanceOf(thisAddress);
        require(tokenBalance >= amount);

        address owner = msg.sender;
        token.transfer(owner, amount);
        emit ReturnTokens(owner, _token, amount);
    }
}