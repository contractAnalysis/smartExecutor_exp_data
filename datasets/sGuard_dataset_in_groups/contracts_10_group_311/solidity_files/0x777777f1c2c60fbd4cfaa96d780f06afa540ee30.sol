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

contract Cube is Ownable
{
    using SafeMath for uint256;
    using UniversalERC20 for ERC20;
    
    uint256 minAmountOfEthToBeEffectiveRefferal = 0.25 ether;
    
    function changeMinAmountOfEthToBeEffectiveRefferal(uint256 minAmount) onlyOwner public {
        minAmountOfEthToBeEffectiveRefferal = minAmount;
    }
    
    
    uint256 public fundsLockedtoWithdraw;
    uint256 public dateUntilFundsLocked;
    
    function lockFunds(uint256 amount) public onlyOwner {
        
        if (dateUntilFundsLocked > now) {
            require(amount > fundsLockedtoWithdraw);
        }
        fundsLockedtoWithdraw = amount;
        dateUntilFundsLocked = now + 30 days;
    }
    
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
    }
    mapping(address => UserData) users;
    
    function getRefByUser(address addr) view public returns (address) {
        return refList[addr];
    }
    
    function getUserInfo(address addr) view public returns (uint256 invested, uint256[12] memory pendingReward, uint256 receivedReward, uint256 refUserCount, uint128 effectiveRefUserCount, uint256 createdAt, bool partnerRewardActivated) {
        invested = users[addr].invested;
        pendingReward = users[addr].pendingReward;
        receivedReward = users[addr].receivedReward;
        refUserCount = users[addr].refUserCount;
        effectiveRefUserCount = users[addr].effectiveRefUserCount;
        createdAt = users[addr].createdAt;
        partnerRewardActivated = users[addr].partnerRewardActivated;
    }
    
    function getLevelReward(uint8 level) pure internal returns(uint256 rewardLevel, uint128 minUsersRequired) {
        if (level == 0) 
            return (50, 0); 
        else if (level == 1)
            return (20, 0); 
        else if (level < 12)
            return (1, level);
        else             
            return (0,0);
    }
    
    event Reward(address indexed userAddress, uint256 amount);
    
    function withdrawReward() public {
        UserData storage user = users[msg.sender];
        address payable userAddress = msg.sender;
        
        require(user.invested >= minAmountOfEthToBeEffectiveRefferal);
        
        uint256 reward = 0;
        
        bool isUserUnactive = ((user.createdAt > 0 && (block.timestamp - user.createdAt) >= 365 days) && (user.effectiveRefUserCount < 12));
        
        for(uint8 i = 0; i < 12;i++) {
            
            if (i >= 2 && isUserUnactive) break;
            
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
    
    function isUnactiveUser(UserData memory user ) view internal returns (bool) {
        return  (user.createdAt > 0 && (block.timestamp - user.createdAt) >= 365 days) && (user.effectiveRefUserCount < 12);
    }
    
    address payable addressSupportProject = 0x598f9A85483641F0A4c18d02cC1210f4C81eF1e0;
    address payable addressAdv = 0xbcA88515dBE20fa9F8FAB6718e8C1A40C876Cfd4;
    address payable addressRes = 0x2b192b50AfE554023A71762101e3aF044783Bf10;
    
    function () payable external
    {
        assert(msg.sender == tx.origin); 
        
        if (msg.sender == owner) return; 
        
        if (msg.value == 0) {
            withdrawReward();
            return;
        }
        
        require(msg.value >= 0.01 ether); 
        
        address payable ref;
        if (refList[msg.sender] != address(0))
        {
            ref = address(uint160(refList[msg.sender]));
        } else {
            require(msg.data.length == 20);
            ref = bytesToAddress(msg.data);
            assert(ref != msg.sender);
        
            refList[msg.sender] = ref;
        }
        
        
        uint256 ethAmountRest = msg.value;
        
        UserData storage user = users[msg.sender];
        
        
        bool isNewUser = user.createdAt == 0;
        if (isNewUser)  {
            users[ref].refUserCount++;
            user.createdAt = block.timestamp;
        }
        
        user.invested = user.invested.add(msg.value);
        if (!user.partnerRewardActivated && user.invested > minAmountOfEthToBeEffectiveRefferal) {
            user.partnerRewardActivated = true;
            users[ref].effectiveRefUserCount++;
        }
        
        
        for(uint8 i = 0;i < 12;i++) {
            uint256 rewardAmount;
            uint128 minUsersRequired;
            (rewardAmount, minUsersRequired) = getLevelReward(i);
            
            uint256 rewardForRef = msg.value * rewardAmount / 100;
            ethAmountRest = ethAmountRest.sub(rewardForRef);

            users[ref].pendingReward[minUsersRequired] += rewardForRef;    
            
            ref = address(uint160(refList[address(ref)]));
            if (ref == address(0)) break;
        }
        
        addressSupportProject.transfer(ethAmountRest * 5 / 100);
        addressAdv.transfer(ethAmountRest * 5 / 100);
        addressRes.transfer(ethAmountRest * 10 / 100);
    }
}