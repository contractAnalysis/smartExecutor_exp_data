pragma solidity ^0.5.16;



contract ERC20Token
{
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ShareholderVomer
{
    using SafeMath for uint256;
    
    address payable public owner = msg.sender;
    address payable public newOwnerCandidate;
    
    uint256 minBalance = 1000;
    ERC20Token VMR_Token = ERC20Token(0x063b98a414EAA1D4a5D4fC235a22db1427199024);
    
    struct InvestorData {
        uint256 funds;
        uint256 lastDatetime;
        uint256 totalProfit;
    }
    mapping (address => InvestorData) investors;
    
    modifier onlyOwner()
    {
        assert(msg.sender == owner);
        _;
    }
    
    constructor() public {
        migrateDone[0x12A09763eC6e5B7cbc4feb7178db8C91A79E456a] = true;
        migrateDone[0xB7722517f410914fFf62DF357A0c14B88EFb9369] = true;
    }
    
    uint256 public fundsLockedtoWithdraw;
    uint256 public dateUntilFundsLocked;
    
    function withdraw(uint256 amount)  public onlyOwner {
        if (dateUntilFundsLocked > now) require(address(this).balance.sub(amount) > fundsLockedtoWithdraw);
        owner.transfer(amount);
    }
    
    function lockFunds(uint256 amount) public onlyOwner {
        
        if (dateUntilFundsLocked > now) {
            require(amount > fundsLockedtoWithdraw);
        }
        fundsLockedtoWithdraw = amount;
        dateUntilFundsLocked = now + 30 days;
    }
    
    function changeOwnerCandidate(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }
    
    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate);
        owner = newOwnerCandidate;
    }
    
    function changeMinBalance(uint256 newMinBalance) public onlyOwner {
        minBalance = newMinBalance;
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address payable addr) {
        assembly {
          addr := mload(add(bys,20))
        } 
    }
    
    function transferTokens (address token, address target, uint256 amount) onlyOwner public
    {
        ERC20Token(token).transfer(target, amount);
    }
    
    ShareholderVomer oldContract = ShareholderVomer(0x9C235ac2C33077A30593A3fd27A0087c687A80A3); 
    
    mapping (address => bool) migrateDone;
    
    function migrateDataFromOldContract() internal 
    {
        if (!migrateDone[msg.sender]) {
            uint256 totalFunds;
            uint256 pendingReward; 
            uint256 totalProfit;
            (totalFunds, pendingReward, totalProfit,) = oldContract.getInfo(msg.sender);
            if (totalFunds > 0) {
                uint256 lastDatetime = block.timestamp - pendingReward.mul(30 days).mul(100).div(20).div(totalFunds);
                investors[msg.sender] = InvestorData(totalFunds, lastDatetime, totalProfit);
            }
            migrateDone[msg.sender] = true;
        }
    }
    
    function getInfo(address investor) view public returns (uint256 totalFunds, uint256 pendingReward, uint256 totalProfit, uint256 contractBalance)
    {
        contractBalance = address(this).balance;
        if (!migrateDone[investor]) {
            (totalFunds, pendingReward, totalProfit,) = oldContract.getInfo(investor);
        } else {
            InvestorData memory data = investors[investor];
            totalFunds = data.funds;
            if (data.funds > 0) pendingReward = data.funds.mul(20).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
            totalProfit = data.totalProfit;
        }
        
    }
    
    function () payable external
    {
        assert(msg.sender == tx.origin); 
        
        if (msg.sender == owner) return;
        
        assert(VMR_Token.balanceOf(msg.sender) >= minBalance * 10**18);
        
        migrateDataFromOldContract();
        
        InvestorData storage data = investors[msg.sender];
        
        if (msg.value > 0)
        {
            
            assert(msg.value >= 2 ether || (data.funds != 0 && msg.value >= 0.01 ether));
            if (msg.data.length == 20) {
                address payable ref = bytesToAddress(msg.data);
                assert(ref != msg.sender);
                ref.transfer(msg.value.mul(25).div(100));   
                owner.transfer(msg.value.mul(5).div(100));  
            } else if (msg.data.length == 0) {
                owner.transfer(msg.value.mul(30).div(100));
            } else {
                assert(false); 
            }
        }
        
        
        if (data.funds != 0) {
            
            uint256 reward = data.funds.mul(20).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
            data.totalProfit = data.totalProfit.add(reward);
            
            address payable user = msg.sender;
            user.transfer(reward);
        }

        data.lastDatetime = block.timestamp;
        data.funds = data.funds.add(msg.value.mul(70).div(100));
        
    }
}