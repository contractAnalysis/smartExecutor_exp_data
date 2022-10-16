pragma solidity ^0.5.16;

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

contract ERC20 {
    uint public decimals;
    function allowance(address, address) public view returns (uint);
    function balanceOf(address) public view returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


library SafeERC20 {
    
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ERC20 private constant ZERO_ADDRESS = ERC20(0x0000000000000000000000000000000000000000);
    ERC20 private constant ETH_ADDRESS = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(ERC20 token, address to, uint256 amount) internal {
        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(ERC20 token, address to, uint256 amount, bool mayFail) internal returns(bool) {
        if (amount == 0) {
            return true;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            if (mayFail) {
                return address(uint160(to)).send(amount);
            } else {
                address(uint160(to)).transfer(amount);
                return true;
            }
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalApprove(ERC20 token, address to, uint256 amount) internal {
        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(ERC20 token, address from, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(uint256(msg.value).sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalBalanceOf(ERC20 token, address who) internal view returns (uint256) {
        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}

contract ERC20Token
{
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract ShareholderVomer 
{
    function takeEth(address targetAddr, uint256 amount) public;
    function giveBackEth() payable public;
}
    
contract VomerPartner
{
    using SafeMath for uint256;

    address payable public owner;
    address payable public newOwnerCandidate;

    uint256 MinBalanceVMR;
    ERC20Token VMR_Token;
    
    ShareholderVomer partnerContract;
    address payable supportAddress;

    struct InvestorData {
        uint256 funds;
        uint256 lastDatetime;
        uint256 totalProfit;
        uint256 totalVMR;
        uint256 pendingReward;
        
        uint256 totalReferralProfit;
        uint256 pendingReferralReward;
    }
    mapping (address => InvestorData) investors;
    
    mapping(address => address) refList;

    mapping(address => bool) public admins;

    modifier onlyOwner()
    {
        assert(msg.sender == owner);
        _;
    }

    modifier onlyAdminOrOwner()
    {
        require(admins[msg.sender] || msg.sender == owner);
        _;
    }

    event Reward(address indexed userAddress, uint256 amount);
    event ReferralReward(address indexed userAddress, uint256 amount);
    
    constructor() public {
        VMR_Token = ERC20Token(0x063b98a414EAA1D4a5D4fC235a22db1427199024); 
        partnerContract = ShareholderVomer(0xE1f5c6FD86628E299955a84f44E2DFCA47aAaaa4);
        MinBalanceVMR = 0;
        supportAddress = 0x4B7b1878338251874Ad8Dace56D198e31278676d;
        newOwnerCandidate = 0x4B7b1878338251874Ad8Dace56D198e31278676d;
        owner = msg.sender;
        admins[0x6Ecb917AfD0611F8Ab161f992a12c82e29dc533c] = true;
    }

    function changeSupportAddress(address newSupportAddress) onlyOwner public 
    {
        require(newSupportAddress != address(0));
        supportAddress = address(uint160(newSupportAddress));
    }
    
    function safeEthTransfer(address target, uint256 amount) internal {
        address payable payableTarget = address(uint160(target));
        (bool ok, ) = payableTarget.call.value(amount)("");
        require(ok, "can't send eth to address");
    }

    function setAdmin(address newAdmin, bool activate) onlyOwner public {
        admins[newAdmin] = activate;
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
        MinBalanceVMR = newMinBalance * 10**18;
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

    function getInfo(address investor) view public returns (uint256 totalFunds, uint256 pendingReward, uint256 totalProfit, uint256 contractBalance, uint256 totalVMR, uint256 minVMR, uint256 totalReferralProfit, uint256 pendingReferralReward)
    {
        contractBalance = address(this).balance;
        minVMR = MinBalanceVMR;
        InvestorData memory data = investors[investor];
        totalFunds = data.funds;
        if (data.funds > 0) {
            pendingReward = data.pendingReward + data.funds.mul(20).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
        }
        totalProfit = data.totalProfit;
        totalVMR = data.totalVMR;
        
        
        totalReferralProfit = data.totalReferralProfit;
        pendingReferralReward = data.pendingReferralReward;
    }

    function getLevelReward(uint8 level) pure internal returns(uint256 rewardLevel) {
        if (level == 0) 
            return 5; 
        else if (level == 1)
            return 2; 
        else             
            return 1;
    }
    
    function setDepositTokens(address[] calldata userAddress, uint256[] calldata amountTokens) onlyAdminOrOwner external {
        uint256 len = userAddress.length;
        require(len == amountTokens.length);

        for(uint16 i = 0;i < len; i++) {
            investors[userAddress[i]].totalVMR = amountTokens[i];
        }
    }
    
    function getRefByUser(address addr) view public returns (address) {
        return refList[addr];
    }
    
    function withdrawReward(InvestorData storage data) internal {
        uint256 reward;
        
        require(data.totalVMR >= MinBalanceVMR, "Not enough VMR");
        
        require(data.funds > 0);
        
        
        reward = data.pendingReward + data.funds.mul(20).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
        data.pendingReward = 0;
        data.lastDatetime = block.timestamp;

        data.totalProfit = data.totalProfit.add(reward);
        data.totalReferralProfit = data.totalReferralProfit.add(data.pendingReferralReward);
        
        uint256 _pendingReferralReward = data.pendingReferralReward;
        data.pendingReferralReward = 0;
        
        address payable payableUser = address(uint160(msg.sender));
        
        if (reward > 0) {
            partnerContract.takeEth(payableUser, reward);
            emit Reward(payableUser, reward);
        }
        
        if (_pendingReferralReward > 0) {
            partnerContract.takeEth(payableUser, _pendingReferralReward);
            emit ReferralReward(payableUser, _pendingReferralReward);
        }
    }
    
    function () payable external
    {
        if (msg.sender == address(partnerContract)) return;
        
        require(msg.sender == tx.origin); 

        if (msg.sender == owner) return;

        InvestorData storage data = investors[msg.sender];
        
        if (msg.value == 0) {
            withdrawReward(data);
            return;
        }
        
        require(msg.value >= 0.1 ether);
        
        address ref;
        if (refList[msg.sender] != address(0))
        {
            ref = refList[msg.sender];
        } else {
            require(msg.data.length == 20, "first interaction with contract should be with referral address");
            ref = bytesToAddress(msg.data);
            require(ref != msg.sender, "You can't ref yourself");
        
            refList[msg.sender] = ref;
        }
        
        supportAddress.transfer(msg.value.mul(5).div(100));  
        
        if (data.funds > 0) data.pendingReward += data.funds.mul(20).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
        data.lastDatetime = block.timestamp;
        data.funds = data.funds.add(msg.value * 95 / 100); 
        
        partnerContract.giveBackEth.value(address(this).balance)();
    }
}