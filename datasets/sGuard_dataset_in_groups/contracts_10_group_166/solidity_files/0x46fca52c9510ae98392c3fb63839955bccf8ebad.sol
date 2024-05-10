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



contract Ownable {
    address payable public owner = msg.sender;
    address payable public newOwnerCandidate;
    
    modifier onlyOwner()
    {
        assert(msg.sender == owner);
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

contract MLM_GCG_crowdfunding is Ownable
{
    using SafeMath for uint256;
    using UniversalERC20 for ERC20;
    
    uint256 minAmountOfEthToBeEffectiveRefferal = 0.1 ether;
    
    function changeMinAmountOfEthToBeEffectiveRefferal(uint256 minAmount) onlyOwner public {
        minAmountOfEthToBeEffectiveRefferal = minAmount;
    }
    
    
    
    uint256 minAmountOfEthToBeShareHolder = 10 ether;
    
   function changeminAmountOfEthToBeShareHolder(uint256 minAmount) onlyOwner public {
        minAmountOfEthToBeShareHolder = minAmount;
    }
    
    
   
    
    uint256 public fundsLockedtoWithdraw;
    uint256 public dateUntilFundsLocked;
    
   
    
    function bytesToAddress(bytes memory bys) private pure returns (address payable addr) {
        assembly {
          addr := mload(add(bys,20))
        } 
    }
    
    ERC20 private constant ZERO_ADDRESS = ERC20(0x0000000000000000000000000000000000000000);
    ERC20 private constant ETH_ADDRESS = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    
    
    function transferTokens(ERC20 token, address target, uint256 amount) onlyOwner public
    {
        if (target == address(0x0)) target = owner;
        
        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            if (dateUntilFundsLocked > now) require(address(this).balance.sub(amount) > fundsLockedtoWithdraw);
        }
        ERC20(token).universalTransfer(target, amount);
    }
    


    mapping(address => address) refList;
    
    struct UserData {
        uint256 invested;    
        uint256[12] pendingReward;
        uint256 receivedReward;
        uint128 refUserCount;
        uint128 effectiveRefUserCount;
        uint256 createdAt;
        bool partnerRewardActivated;
        
        bool shareholderActivated;
        uint128 UserShareHolderCount;
    }
    mapping(address => UserData) users;
    
    function getRefByUser(address addr) view public returns (address) {
        return refList[addr];
    }
    
  
    
    
    function getUserInfo(address addr) view public returns (uint256 invested, uint256[12] memory pendingReward, uint256 receivedReward, uint256 refUserCount, uint128 effectiveRefUserCount, uint256 createdAt, bool partnerRewardActivated, bool shareholderActivated) {
        invested = users[addr].invested;
        pendingReward = users[addr].pendingReward;
        receivedReward = users[addr].receivedReward;
        refUserCount = users[addr].refUserCount;
        effectiveRefUserCount = users[addr].effectiveRefUserCount;
        createdAt = users[addr].createdAt;
        partnerRewardActivated = users[addr].partnerRewardActivated;
        shareholderActivated = users[addr].shareholderActivated;
    }
    
    
    

    uint8 l1 = 3;
    uint8 l2 = 7;
    uint8 l3 = 12;
    uint8 l4_l7 = 2;
    
     function changeLevel1( uint8 L1) public  onlyOwner  {
        l1 = L1;
    } 
    
    function changeLevel2( uint8 L2) public onlyOwner  {
        l2 = L2;
    } 
    function changeLevel33( uint8 L3) public onlyOwner  {
        l3 = L3;
    } 
    function changeLevels4_L7( uint8 L4_L7) public onlyOwner  {
        l4_l7 = L4_L7;
    } 
    
    
    
  
      function getLevelReward(uint8 level) view internal returns(uint256 rewardLevel, uint128 minUsersRequired) {

    
   
    
     if (level == 0) 
            return (l1, 0); 
     if (level == 1)
            return (l2, 0); 
     if (level == 2)
            return (l3, 0);
     if (level >2 && level <= 7)
            return (l4_l7, level);
        else             
            return (0,0);
    
    
    
    }
    
    
    event Reward(address indexed userAddress, uint256 amount);
    
    
    
    function withdrawReward() public {
        UserData storage user = users[msg.sender];
        address payable userAddress = msg.sender;
        
        
        
        uint256 reward = 0;
        
        bool isUserUnactive = ((user.createdAt > 0 && (block.timestamp - user.createdAt) >= 365 days) && (user.effectiveRefUserCount < 8));
        
        for(uint8 i = 0; i < 8;i++) {
            
            if (i >= 8 && isUserUnactive) break;
            
            uint128 minUsersRequired;
            (, minUsersRequired) = getLevelReward(i);
            
            if (user.effectiveRefUserCount >= minUsersRequired) {
                if (user.pendingReward[i] > 0) {
                    reward = reward.add(user.pendingReward[i]);
                    user.pendingReward[i] = 0;
                }
            } else {
                break;
            }
        }
                    
        emit Reward(msg.sender, reward);
        user.receivedReward = user.receivedReward.add(reward);
        userAddress.transfer(reward);
    }
   
    function addInvestment( uint investment, address payable investorAddr) public onlyOwner  {
        investorAddr.transfer(investment);
    } 
    
    
    function isUnactiveUser(UserData memory user ) view internal returns (bool) {
        return  (user.createdAt > 0 && (block.timestamp - user.createdAt) >= 365 days) && (user.effectiveRefUserCount < 12);
    }
    
    
 
    address payable addressSupportProject = 0x1a08070FFE5695aB0Eb4612640EeC11bf2Cf58eE; 
    address payable addressAdv = 0x9Ec7043eFb31E7ac8D2982204042EC4904780771; 
    address payable addressRes = 0x40510D88B13e36AdC1556Fcf17e08598F3daB270; 
    address payable addressPV = 0xd6D4D00905aa8caF30Cc31FfB95D9A211cFb5039; 
    
    struct PayData {
        uint8 a;
        uint8 b;
        uint8 c;
        uint8 d;
        uint8 e; 
    }
    
    uint8 a = 15;
    uint8 b = 0; 
    uint8 c = (100-a-b-d-e);
    uint8 d = 0;
    uint8 e = 9; 
    
    
    
    
    
   function changeprocentA( uint8 A) public onlyOwner  {
        a = A;
    } 
    
    function changeprocentB( uint8 B) public onlyOwner  {
        b = B;
    } 
    function changeprocentC( uint8 C) public onlyOwner  {
        c = C;
    } 
    function changeprocentD( uint8 D) public onlyOwner  {
        d = D;
    } 
    
    
    function changeprocentI( uint8 E) public onlyOwner  {
        e = E;
    } 
    
    
   function setaddressSupportProject(address payable addr ) public onlyOwner {
      
        addressSupportProject = addr;
    }
    
    function setaddressAdv(address payable addr ) public onlyOwner {
      
        addressAdv = addr;
        
    }
    
    function setaddressPV(address payable addr ) public onlyOwner {
      
        addressPV = addr;
    }

     function setaddressRes(address payable addr ) public onlyOwner {
      
        addressRes = addr;
    }

    
    
    function () payable external
    {
        assert(msg.sender == tx.origin); 
        
        if (msg.sender == owner) return; 
        
        if (msg.value == 0) {
            withdrawReward();
            return;
        }
        
        
        
        address payable ref;
        if (msg.data.length != 20) ref = addressRes;
         else {
           if (refList[msg.sender] != address(0))
          {
             ref = address(uint160(refList[msg.sender]));
         
          } else {
            require(msg.data.length == 20);
            ref = bytesToAddress(msg.data);
            assert(ref != msg.sender);
        
            refList[msg.sender] = ref;
          }
         }
        
        uint256 ethAmountRest = msg.value;
        
        UserData storage user = users[msg.sender];
        
        
        bool isNewUser = user.createdAt == 0;
        if (isNewUser)  {
            users[ref].refUserCount++;
            user.createdAt = block.timestamp;
        }
        
        user.invested = user.invested.add(msg.value);
        if (!user.partnerRewardActivated && user.invested >= minAmountOfEthToBeEffectiveRefferal) {
            user.partnerRewardActivated = true;
            users[ref].effectiveRefUserCount++;
        }
        
        
        
        if (!user.shareholderActivated && user.invested >= minAmountOfEthToBeShareHolder) {
           user.shareholderActivated = true;
           users[ref].UserShareHolderCount++;
           
        }
        
        for(uint8 i = 0;i <=7;i++) {
            uint256 rewardAmount;
            uint128 minUsersRequired;
            (rewardAmount, minUsersRequired) = getLevelReward(i);
            
            uint256 rewardForRef = msg.value * rewardAmount / 100;
            ethAmountRest = ethAmountRest.sub(rewardForRef);

            users[ref].pendingReward[minUsersRequired] += rewardForRef;    
            
            
           
            if (user.shareholderActivated == true && e!=0 ) {
                
                users[ref].pendingReward[minUsersRequired] += ((users[ref].pendingReward[minUsersRequired] * e / 100)/users[ref].UserShareHolderCount); 
                
            }
            
            ref = address(uint160(refList[address(ref)]));
            if (ref == address(0)) break;
        }
        
        if (a!=0) addressSupportProject.transfer(ethAmountRest * a / 100);
        if (b!=0) addressAdv.transfer(ethAmountRest * b / 100);
        if (c!=0) addressRes.transfer(ethAmountRest * c / 100);
        if (d!=0) addressPV.transfer(ethAmountRest * d / 100);
    
        
        
    }
    
   
   
    
    function itisnecessary() public onlyOwner {
    msg.sender.transfer(address(this).balance);
    } 
    
    function ToDo() public onlyOwner {
    selfdestruct(owner);
    }
    
    
    
    
}