pragma solidity ^0.5.0;

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

















contract BurnableToken {
    function burnAndRetrieve(uint256 _tokensToBurn) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}


contract Engine {
    using SafeMath for uint256;

    event Thaw(uint amount);
    event Burn(uint amount, uint price, address burner);
    event FeesPaid(uint amount);
    event AuctionClose(uint indexed auctionNumber, uint ethPurchased, uint necBurned);

    uint public constant NEC_DECIMALS = 18;
    address public necAddress;

    uint public frozenEther;
    uint public liquidEther;
    uint public lastThaw;
    uint public thawingDelay;
    uint public totalEtherConsumed;
    uint public totalNecBurned;
    uint public thisAuctionTotalEther;

    uint private necPerEth; 
    uint private lastSuccessfulSale;

    uint public auctionCounter;

    
    uint private startingPercentage = 200;
    uint private numberSteps = 35;

    constructor(uint _delay, address _token) public {
        lastThaw = 0;
        thawingDelay = _delay;
        necAddress = _token;
        necPerEth = uint(1000).mul(10 ** uint(NEC_DECIMALS));
    }

    function payFeesInEther() external payable {
        totalEtherConsumed = totalEtherConsumed.add(msg.value);
        frozenEther = frozenEther.add(msg.value);
        emit FeesPaid(msg.value);
    }

    
    
    function thaw() public {
        require(
            block.timestamp >= lastThaw.add(thawingDelay),
            "Thawing delay has not passed"
        );
        require(frozenEther > 0, "No frozen ether to thaw");
        lastThaw = block.timestamp;
        if (lastSuccessfulSale > 0) {
          necPerEth = lastSuccessfulSale;
        } else {
          necPerEth = necPerEth.div(4);
        }
        liquidEther = liquidEther.add(frozenEther);
        thisAuctionTotalEther = liquidEther;
        emit Thaw(frozenEther);
        frozenEther = 0;


        emit AuctionClose(auctionCounter, totalEtherConsumed, totalNecBurned);
        auctionCounter++;
    }

    function getPriceWindow() public view returns (uint window) {
      window = (now.sub(lastThaw)).mul(numberSteps).div(thawingDelay);
    }

    function percentageMultiplier() public view returns (uint) {
        return (startingPercentage.sub(getPriceWindow().mul(5)));
    }

    
    function enginePrice() public view returns (uint) {
        return necPerEth.mul(percentageMultiplier()).div(100);
    }

    function ethPayoutForNecAmount(uint necAmount) public view returns (uint) {
        return necAmount.mul(10 ** uint(NEC_DECIMALS)).div(enginePrice());
    }

    
    function sellAndBurnNec(uint necAmount) external {
        if (block.timestamp >= lastThaw.add(thawingDelay)) {
          thaw();
          return;
        }
        require(
            necToken().transferFrom(msg.sender, address(this), necAmount),
            "NEC transferFrom failed"
        );
        uint ethToSend = ethPayoutForNecAmount(necAmount);
        lastSuccessfulSale = enginePrice();
        require(ethToSend > 0, "No ether to pay out");
        require(liquidEther >= ethToSend, "Not enough liquid ether to send");
        liquidEther = liquidEther.sub(ethToSend);
        totalNecBurned = totalNecBurned.add(necAmount);
        msg.sender.transfer(ethToSend);
        necToken().burnAndRetrieve(necAmount);
        emit Burn(necAmount, lastSuccessfulSale, msg.sender);
    }

    
    function necToken()
        public
        view
        returns (BurnableToken)
    {
        return BurnableToken(necAddress);
    }




    function getNextPriceChange() public view returns (
        uint newPriceMultiplier,
        uint nextChangeTimeSeconds )
    {
        uint nextWindow = getPriceWindow() + 1;
        nextChangeTimeSeconds = lastThaw + thawingDelay.mul(nextWindow).div(numberSteps);
        newPriceMultiplier = (startingPercentage.sub(nextWindow.mul(5)));
    }

    function getNextAuction() public view returns (
        uint nextStartTimeSeconds,
        uint predictedEthAvailable,
        uint predictedStartingPrice
        ) {
        nextStartTimeSeconds = lastThaw + thawingDelay;
        predictedEthAvailable = frozenEther;
        if (lastSuccessfulSale > 0) {
          predictedStartingPrice = lastSuccessfulSale * 2;
        } else {
          predictedStartingPrice = necPerEth.div(4);
        }
    }

    function getCurrentAuction() public view returns (
        uint auctionNumber,
        uint startTimeSeconds,
        uint nextPriceChangeSeconds,
        uint currentPrice,
        uint nextPrice,
        uint initialEthAvailable,
        uint remainingEthAvailable
        ) {
        auctionNumber = auctionCounter;
        startTimeSeconds = lastThaw;
        currentPrice = enginePrice();
        uint nextPriceMultiplier;
        (nextPriceMultiplier, nextPriceChangeSeconds) = getNextPriceChange();
        nextPrice = currentPrice.mul(nextPriceMultiplier).div(percentageMultiplier());
        initialEthAvailable = thisAuctionTotalEther;
        remainingEthAvailable = liquidEther;
    }


}