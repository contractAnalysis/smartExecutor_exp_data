pragma solidity ^0.5.0;


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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = _msgSender();
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
        return _msgSender() == _owner;
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


interface INEC {

    function burningEnabled() external returns(bool);

    function controller() external returns(address);

    function enableBurning(bool _burningEnabled) external;

    function burnAndRetrieve(uint256 _tokensToBurn) external returns (bool success);

    function totalPledgedFees() external view returns (uint);

    function totalSupply() external view returns (uint);

    function destroyTokens(address _owner, uint _amount
      ) external returns (bool);

    function generateTokens(address _owner, uint _amount
      ) external returns (bool);

    function changeController(address _newController) external;

    function balanceOf(address owner) external returns(uint256);

    function transfer(address owner, uint amount) external returns(bool);
}

contract TokenController {

    function proxyPayment(address _owner) public payable returns(bool);

    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);

    function onBurn(address payable _owner, uint _amount) public returns(bool);
}


contract NectarController is TokenController, Ownable {
    using SafeMath for uint256;

    INEC public tokenContract;   


    
    

    constructor (
        address _tokenAddress
    ) public {
        tokenContract = INEC(_tokenAddress); 
    }





    
    
    
    function proxyPayment(address _owner) public payable returns(bool) {
        return true;
    }


    
    
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool) {
        return true;
    }

    
    
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool)
    {
        return true;
    }

    
    
    
    
    
    function onBurn(address payable _owner, uint _tokensToBurn) public
        returns(bool)
    {
        
        require(msg.sender == address(tokenContract));

        require (tokenContract.destroyTokens(_owner, _tokensToBurn));

        return true;
    }

    
    
    function upgradeController(address _newControllerAddress) public onlyOwner {
        tokenContract.changeController(_newControllerAddress);
        emit UpgradedController(_newControllerAddress);
    }

    
    function enableBurning(bool _burningEnabled) public onlyOwner{
        tokenContract.enableBurning(_burningEnabled);
    }






    
    
    
    function claimTokens(address _token) public onlyOwner {

        INEC token = INEC(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
        emit ClaimedTokens(_token, owner(), balance);
    }

    
    function claimEther() public onlyOwner{
        address payable to = address(uint160(owner()));
        to.transfer(address(this).balance);
        emit ClaimedTokens(address(0), owner(), address(this).balance);
    }





    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event UpgradedController (address newAddress);

}