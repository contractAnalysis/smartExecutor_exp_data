pragma solidity ^0.5.4;


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
        require(isOwner(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    event ForceTransfer(address indexed from, address indexed to, uint256 value, bytes32 details);
}



contract FeeManager is Ownable {

    uint256[] public fees;
    address public awgContractAddress;

    
    modifier onlyAWG() {
        require(msg.sender == awgContractAddress, "Only AWG contract can call this function");
        _;
    }

    constructor(address _awgContractAddress) public {
        awgContractAddress = _awgContractAddress;
    }

    
    function processFee(uint256 _amount) external onlyAWG {
        fees.push(_amount);
    }

    
    function withdrawTokens() external onlyOwner {
        IERC20(awgContractAddress).transfer(msg.sender,IERC20(awgContractAddress).balanceOf(address(this)));
    }
}