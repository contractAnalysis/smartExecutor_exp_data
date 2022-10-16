pragma solidity ^0.5.16;


library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner());
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
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AutoRedDotDistrict is Ownable {

    using SafeMath for uint256;

    
    
    

    
    
    

    
    
    

    
    
    uint256 public auctionCreationReward = 10000000000000000; 

    
    
    mapping (uint256 => bool) public kittyIsWhitelisted;
    uint256 public numberOfWhitelistedKitties;

    
    
    mapping (uint256 => uint256) public startingSiringPriceForKitty;
    uint256 public globalEndingSiringPrice = 0;
    uint256 public globalAuctionDuration = 1296000; 

    
    
    

    
    
    

    address public kittyCoreAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    address public kittySiresAddress = 0xC7af99Fe5513eB6710e6D5f44F9989dA40F27F26;

    
    
    

    
    
    
    
    
    
    function createAuction(uint256 _kittyId) external {
        require(kittyIsWhitelisted[_kittyId] == true, 'kitty is not whitelisted');

        KittyCore(kittyCoreAddress).createSiringAuction(
            _kittyId,
            startingSiringPriceForKitty[_kittyId],
            globalEndingSiringPrice,
            globalAuctionDuration
        );

        uint256 contractBalance = address(this).balance;
        if(contractBalance >= auctionCreationReward){
            msg.sender.transfer(auctionCreationReward);
        }
    }

    function ownerChangeStartingSiringPrice(uint256 _kittyId, uint256 _newStartingSiringPrice) external onlyOwner {
        startingSiringPriceForKitty[_kittyId] = _newStartingSiringPrice;
    }

    function ownerChangeGlobalEndingSiringPrice(uint256 _newGlobalEndingSiringPrice) external onlyOwner {
        globalEndingSiringPrice = _newGlobalEndingSiringPrice;
    }

    function ownerChangeGlobalAuctionDuration(uint256 _newGlobalAuctionDuration) external onlyOwner {
        globalAuctionDuration = _newGlobalAuctionDuration;
    }

    function ownerChangeAuctionCreationReward(uint256 _newAuctionCreationReward) external onlyOwner {
        auctionCreationReward = _newAuctionCreationReward;
    }

    function ownerCancelSiringAuction(uint256 _kittyId) external onlyOwner {
        KittySires(kittySiresAddress).cancelAuction(_kittyId);
    }

    function ownerWithdrawKitty(address _destination, uint256 _kittyId) external onlyOwner {
        KittyCore(kittyCoreAddress).transfer(_destination, _kittyId);
    }

    function ownerWhitelistKitty(uint256 _kittyId, bool _whitelist) external onlyOwner {
        require(kittyIsWhitelisted[_kittyId] != _whitelist, 'kitty already had that value for its whitelist status');

        kittyIsWhitelisted[_kittyId] = _whitelist;
        if(_whitelist){
            numberOfWhitelistedKitties = numberOfWhitelistedKitties.add(1);
        } else {
            numberOfWhitelistedKitties = numberOfWhitelistedKitties.sub(1);
        }
    }

    
    
    
    
    function ownerWithdrawAllEarnings() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        uint256 fundsToLeaveToIncentivizeFutureCallers = auctionCreationReward.mul(numberOfWhitelistedKitties);
        if(contractBalance > fundsToLeaveToIncentivizeFutureCallers){
            uint256 earnings = contractBalance.sub(fundsToLeaveToIncentivizeFutureCallers);
            msg.sender.transfer(earnings);
        }
    }

    
    
    
    function emergencyWithdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    constructor() public {
        
        startingSiringPriceForKitty[848437] = 200000000000000000; 
        startingSiringPriceForKitty[848439] = 200000000000000000; 
        startingSiringPriceForKitty[848440] = 200000000000000000; 
        startingSiringPriceForKitty[848441] = 200000000000000000; 
        startingSiringPriceForKitty[848442] = 200000000000000000; 
        startingSiringPriceForKitty[848582] = 200000000000000000; 

        
        kittyIsWhitelisted[848437] = true;
        kittyIsWhitelisted[848439] = true;
        kittyIsWhitelisted[848440] = true;
        kittyIsWhitelisted[848441] = true;
        kittyIsWhitelisted[848442] = true;
        kittyIsWhitelisted[848582] = true;
        numberOfWhitelistedKitties = 6;

        
        
        
        transferOwnership(0xBb1e390b77Ff99f2765e78EF1A7d069c29406bee);
    }

    function() external payable {}
}

contract KittyCore {
    function transfer(address _to, uint256 _tokenId) external;
    function createSiringAuction(uint256 _kittyId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration) external;
}

contract KittySires {
    function cancelAuction(uint256 _tokenId) external;
}