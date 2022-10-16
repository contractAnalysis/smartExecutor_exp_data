pragma solidity 0.5.7;



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
    address private _nominatedOwner;

    event NewOwnerNominated(address indexed previousOwner, address indexed nominee);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    function nominatedOwner() external view returns (address) {
        return _nominatedOwner;
    }

    
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(_msgSender() == _owner, "caller is not owner");
    }

    
    function nominateNewOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "new owner is 0 address");
        emit NewOwnerNominated(_owner, newOwner);
        _nominatedOwner = newOwner;
    }

    
    function acceptOwnership() external {
        require(_nominatedOwner == _msgSender(), "unauthorized");
        emit OwnershipTransferred(_owner, _nominatedOwner);
        _owner = _nominatedOwner;
    }

    
    function renounceOwnership(string calldata declaration) external onlyOwner {
        string memory requiredDeclaration = "I hereby renounce ownership of this contract forever.";
        require(
            keccak256(abi.encodePacked(declaration)) ==
            keccak256(abi.encodePacked(requiredDeclaration)),
            "declaration incorrect");

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract ReserveEternalStorage is Ownable {

    using SafeMath for uint256;


    

    address public reserveAddress;

    event ReserveAddressTransferred(
        address indexed oldReserveAddress,
        address indexed newReserveAddress
    );

    
    constructor() public {
        reserveAddress = _msgSender();
        emit ReserveAddressTransferred(address(0), reserveAddress);
    }

    
    modifier onlyReserveAddress() {
        require(_msgSender() == reserveAddress, "onlyReserveAddress");
        _;
    }

    
    function updateReserveAddress(address newReserveAddress) external {
        require(newReserveAddress != address(0), "zero address");
        require(_msgSender() == reserveAddress || _msgSender() == owner(), "not authorized");
        emit ReserveAddressTransferred(reserveAddress, newReserveAddress);
        reserveAddress = newReserveAddress;
    }



    

    mapping(address => uint256) public balance;

    
    
    
    
    
    function addBalance(address key, uint256 value) external onlyReserveAddress {
        balance[key] = balance[key].add(value);
    }

    
    function subBalance(address key, uint256 value) external onlyReserveAddress {
        balance[key] = balance[key].sub(value);
    }

    
    function setBalance(address key, uint256 value) external onlyReserveAddress {
        balance[key] = value;
    }



    

    mapping(address => mapping(address => uint256)) public allowed;

    
    function setAllowed(address from, address to, uint256 value) external onlyReserveAddress {
        allowed[from][to] = value;
    }
}