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

contract TokenSale is Ownable {
    
    event TokensBought(uint256 amount);
    
    event Withdrawal(uint256 amount);
    
    mapping(address => uint256) commissionRate;
    IERC20 public token;
    uint256 public rate;
    
    uint256 public constant COMMISSION_PERCENT = 5;
    
    constructor(address _token) public {
        token = IERC20(_token);
    }
    
    
    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }
    
    function setReferalCommission(address referral, uint256 percent) public onlyOwner {
        require(percent > COMMISSION_PERCENT);
        require(percent < 95);
        
        percent = percent - COMMISSION_PERCENT;
        
        commissionRate[referral] = percent;
    }
    
    
    function withdraw(uint256 amount) public onlyOwner {
        uint256 balance = address(this).balance;

        require(amount <= balance, "Requested to much");
        
        address payable _owner = address(uint160(owner()));
        
        _owner.transfer(amount);

        emit Withdrawal(amount);
    }
    
    
    function tokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    
    function buy(address referral) public payable returns (uint256) {
        uint256 tokens = msg.value * rate;
        
        require(tokens <= tokenBalance());
        
        token.transfer(msg.sender, tokens);
        
        if (referral != address(0)) {
            require(referral != msg.sender, "The referral cannot be the sender");
            require(referral != tx.origin, "The referral cannot be the tranaction origin");

            
            uint256 totalCommision = COMMISSION_PERCENT + commissionRate[referral];

            uint256 commision = (msg.value * totalCommision) / 100;
            
            address payable _referal = address(uint160(referral));

            _referal.transfer(commision);
        }
        
        emit TokensBought(tokens);
    }
}