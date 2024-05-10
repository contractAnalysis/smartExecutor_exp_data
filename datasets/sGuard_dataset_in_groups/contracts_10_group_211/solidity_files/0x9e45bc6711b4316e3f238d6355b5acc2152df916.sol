pragma solidity ^0.5.16;




contract Initializable {

    
    bool private initialized;

    
    bool private initializing;

    
    modifier initializer() {
        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    
    function isConstructor() private view returns (bool) {
        
        
        
        
        
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }

    
    uint256[50] private ______gap;
}

contract ERC20Token
{
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
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

    uint256 constant WAD = 10 ** 18;

    function wdiv(uint x, uint y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function wmul(uint x, uint y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
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

contract Ownable {
    address payable public owner = msg.sender;
    address payable public newOwnerCandidate;

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    function changeOwnerCandidate(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate);
        owner = newOwnerCandidate;
    }
}

contract ShareholderVomer is Initializable
{
    using SafeMath for *;

    struct InvestorData {
        uint96 lastDatetime;
        uint96 totalDepositedVMR;   
        uint96 totalWithdrawnVMR;   
        uint96 totalWithdrawnEther; 
        
        uint96 totalPartnerWithdrawnEther;
        uint96 pendingPartnerRewardEther;
        uint96 specialPartnerRewardEther;
        uint8 specialPartnerPercent;
    }
    
    address payable public owner;
    address payable public newOwnerCandidate;
    
    ERC20Token VMR_Token;
    
    uint256 public minEtherAmount;
    
    mapping (address => InvestorData) investors;
    mapping(address => address) refList;
    mapping(address => bool) public admins;
    
    uint256 VMR_ETH_RATE_IN;
    uint256 VMR_ETH_RATE_OUT;
    
    address payable public supportAddress;
    uint256 public fundsLockedtoWithdraw;
    uint256 public dateUntilFundsLocked;
    
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyAdmin()
    {
        require(admins[msg.sender]);
        _;
    }

    function initialize() initializer public {
        VMR_Token = ERC20Token(0x063b98a414EAA1D4a5D4fC235a22db1427199024); 
        
        minEtherAmount = 0.0001 ether;
        owner = 0xBeEF483F3dbBa7FC428ebe37060e5b9561219E3d;
        VMR_ETH_RATE_IN = 1e18;             
        VMR_ETH_RATE_OUT = 1e18 * 90 / 100; 
    }

    function getPaymentInfo() view public returns (uint256 rateIn, uint256 rateOut) {
        rateIn = VMR_ETH_RATE_IN;
        rateOut = VMR_ETH_RATE_OUT;
    }

    function setNewEthRateIn(uint256 newVMR_ETH_RATE_IN_Wei) onlyOwner public {
        require(newVMR_ETH_RATE_IN_Wei > 0);
        VMR_ETH_RATE_IN = newVMR_ETH_RATE_IN_Wei;
    }
    
    function setNewEthRateOut(uint256 newVMR_ETH_RATE_OUT_Wei) onlyOwner public {
        require(newVMR_ETH_RATE_OUT_Wei > 0);
        VMR_ETH_RATE_OUT = newVMR_ETH_RATE_OUT_Wei;
    }

    function setSupportAddress(address payable newSupportAddress) onlyOwner public {
        require(newSupportAddress != address(0));
        supportAddress = newSupportAddress;
    }
    
    function safeEthTransfer(address target, uint256 amount) internal {
        address payable payableTarget = address(uint160(target));
        (bool ok, ) = payableTarget.call.value(amount)("");
        require(ok);
    }

    function setAdmin(address newAdmin, bool activate) onlyOwner public {
        admins[newAdmin] = activate;
    }
    
    function withdraw(uint256 amount)  public onlyOwner {
        if (dateUntilFundsLocked > now) require(address(this).balance.sub(amount) > fundsLockedtoWithdraw);
        owner.transfer(amount);
    }
    
    function lockFunds(uint256 amount) public onlyOwner {
        // funds lock is active
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
    
    function bytesToAddress(bytes memory bys) private pure returns (address payable addr) {
        assembly {
          addr := mload(add(bys,20))
        } 
    }
    // function for transfer any token from contract
    function transferTokens (address token, address target, uint256 amount) onlyOwner public
    {
        ERC20Token(token).transfer(target, amount);
    }
    
    function getInfo(address userAddress) view public returns (uint256 contractBalance, uint96 pendingUserRewardVMR, uint96 pendingUserRewardEther, uint96 totalDepositedVMR, uint96 totalWithdrawnVMR, uint96 totalWithdrawnEther, uint96 totalPartnerWithdrawnEther,
            uint96 pendingPartnerRewardEther, uint96 specialPartnerRewardEther, uint96 specialPartnerPercent, address partner) 
    {
        contractBalance = address(this).balance;
        
        InvestorData memory data = investors[userAddress];
        
        totalDepositedVMR = data.totalDepositedVMR;
        totalWithdrawnVMR = data.totalWithdrawnVMR;
        totalWithdrawnEther = data.totalWithdrawnEther;
        totalPartnerWithdrawnEther = data.totalPartnerWithdrawnEther;
        pendingPartnerRewardEther = data.pendingPartnerRewardEther;
        specialPartnerRewardEther = data.specialPartnerRewardEther;
        specialPartnerPercent = uint96(data.specialPartnerPercent);
        
        pendingUserRewardVMR = uint96(data.totalDepositedVMR.mul(20).div(100).mul(block.timestamp - data.lastDatetime).div(30 days));
        pendingUserRewardEther = uint96(pendingUserRewardVMR.mul(VMR_ETH_RATE_OUT) / 1e18);
        
        partner = refList[userAddress];
    }
    
    function setupRef() internal returns (address) {
        
        address partner = refList[msg.sender];
        if (partner == address(0))
        {
            if (msg.data.length == 20) {
                partner = bytesToAddress(msg.data);
                
                require(partner != msg.sender, "You can't ref yourself");

                refList[msg.sender] = partner;
            }
        }
        return partner;
    }

    function setSpecialPartner(address userAddress, uint96 specialPartnerRewardEther, uint8 specialPartnerPercent) public onlyAdmin 
    {
        InvestorData storage data = investors[userAddress];
        data.specialPartnerRewardEther = specialPartnerRewardEther;
        data.specialPartnerPercent = specialPartnerPercent;
    }

    function setUserData(address userAddress, uint96 lastDatetime, uint96 totalDepositedVMR, uint96 totalWithdrawnVMR, uint96 totalWithdrawnEther, uint96 totalPartnerWithdrawnEther,  uint96 pendingPartnerRewardEther) public onlyAdmin 
    {
        InvestorData storage data = investors[userAddress];
        if (lastDatetime > 0) data.lastDatetime = lastDatetime;
        if (totalDepositedVMR > 0) data.totalDepositedVMR = totalDepositedVMR;
        if (totalWithdrawnVMR > 0) data.totalWithdrawnVMR = totalWithdrawnVMR;
        if (totalWithdrawnEther > 0) data.totalWithdrawnEther = totalWithdrawnEther;
        if (totalPartnerWithdrawnEther > 0) data.totalPartnerWithdrawnEther = totalPartnerWithdrawnEther;
        if (pendingPartnerRewardEther > 0) data.pendingPartnerRewardEther = pendingPartnerRewardEther;
    }
    
    
    function () payable external
    {
        require(msg.sender == tx.origin); 
        
        if (msg.sender == owner) return; 
        
        InvestorData storage data = investors[msg.sender];
        
        address partnerAddress = setupRef();
        require(partnerAddress != address(0)); 
        
        if (msg.value > 0)
        {
            require(msg.value > minEtherAmount);
            
            InvestorData storage partnerData = investors[partnerAddress];
            uint8 p = partnerData.specialPartnerPercent;
            uint96 specialPartnerRewardEther = partnerData.specialPartnerRewardEther;
            if (p > 0) {
                uint96 reward = uint96(msg.value.mul(p).div(100));
                if (specialPartnerRewardEther > reward) {
                    specialPartnerRewardEther -= reward;
                } else {
                    reward = uint96(specialPartnerRewardEther + (100 - specialPartnerRewardEther * 100 / reward) * msg.value.mul(25).div(100) / 100);
                    specialPartnerRewardEther = 0;
                    partnerData.specialPartnerPercent = 0;
                }
                
                partnerData.specialPartnerRewardEther = specialPartnerRewardEther;
                partnerData.pendingPartnerRewardEther += reward;
            } else {
                partnerData.pendingPartnerRewardEther += uint96(msg.value.mul(25).div(100)); 
                if (supportAddress != address(0)) safeEthTransfer(supportAddress, msg.value.mul(5).div(100));
            }
        }
        
        
        if (data.pendingPartnerRewardEther > 0) {
            uint96 reward = data.pendingPartnerRewardEther;
            data.pendingPartnerRewardEther = 0;
            data.totalPartnerWithdrawnEther += reward;
            safeEthTransfer(msg.sender, reward);
        }

        
        if (data.totalDepositedVMR != 0 && data.lastDatetime > 0) {
            
            uint96 rewardVMR = uint96(data.totalDepositedVMR.mul(20).div(100).mul(block.timestamp - data.lastDatetime).div(30 days));
            uint96 rewardEther = uint96(rewardVMR.mul(VMR_ETH_RATE_OUT) / 1e18);
            data.totalWithdrawnEther += rewardEther;
            data.totalWithdrawnVMR += rewardVMR;
            
            safeEthTransfer(msg.sender, rewardEther);
        }

        data.lastDatetime = uint96(block.timestamp);
        if (msg.value > 0) data.totalDepositedVMR = uint96(data.totalDepositedVMR.add(msg.value.mul(70).div(100) * VMR_ETH_RATE_IN / 1e18));
    }
}