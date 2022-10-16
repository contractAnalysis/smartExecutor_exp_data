pragma solidity ^0.4.25;



contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    
    constructor() public {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Token {
    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function transfer(address to, uint256 value) public returns (bool);

    function balanceOf(address who) public view returns (uint256);
}

contract UniSwapV2LiteRouter {

    
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] path, address to, uint deadline) external returns (uint[] amounts);

    function getAmountsOut(uint amountIn, address[] path) external returns (uint[] amounts);
}




contract BankrollNetworkStackPlus is Ownable {

    using SafeMath for uint;

    

    
    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }

    
    modifier onlyStronghands {
        require(myDividends() > 0);
        _;
    }



    


    event onLeaderBoard(
        address indexed customerAddress,
        uint256 invested,
        uint256 tokens,
        uint256 soldTokens,
        uint256 claims,
        uint256 timestamp
    );

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingeth,
        uint256 tokensMinted,
        uint timestamp
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethEarned,
        uint timestamp
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethReinvested,
        uint256 tokensMinted,
        uint256 timestamp
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethWithdrawn,
        uint256 timestamp
    );

    event onClaim(
        address indexed customerAddress,
        uint256 tokens,
        uint256 timestamp
    );

    event onTransfer(
        address indexed from,
        address indexed to,
        uint256 tokens,
        uint256 timestamp
    );

    event onBuyBack(
        uint ethAmount,
        uint tokenAmount,
        uint256 timestamp
    );


    event onBalance(
        uint256 balance,
        uint256 timestamp
    );

    event onDonation(
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );

    event onRouterUpdate(
        address oldAddress,
        address newAddress
    );

    event onFlushUpdate(
        uint oldFlushSize,
        uint newFlushSize
    );

    
    struct Stats {
        uint invested;
        uint reinvested;
        uint withdrawn;
        uint claims;
        uint rewarded;
        uint contributed;
        uint transferredTokens;
        uint receivedTokens;
        int256 tokenPayoutsTo;
        uint xInvested;
        uint xReinvested;
        uint xRewarded;
        uint xContributed;
        uint xWithdrawn;
        uint xTransferredTokens;
        uint xReceivedTokens;
        uint xClaimed;
    }


    

    
    uint8 constant internal entryFee_ = 10;


    
    uint8 constant internal exitFee_ = 10;

    uint8 constant internal dripFee = 60;  

    uint8 constant internal instantFee = 20;

    uint8 constant payoutRate_ = 2;

    uint256 constant internal magnitude = 2 ** 64;

    

    
    mapping(address => uint256) private tokenBalanceLedger_;
    mapping(address => int256) private payoutsTo_;
    mapping(address => Stats) private stats;
    
    uint256 private tokenSupply_;
    uint256 private profitPerShare_;
    uint256 private rewardsProfitPerShare_;
    uint256 public totalDeposits;
    uint256 internal lastBalance_;

    uint public players;
    uint public totalTxs;
    uint public dividendBalance_;
    uint public swapCollector_;
    uint public swapBalance_;
    uint public lastPayout;
    uint public lastBuyback;
    uint public totalClaims;

    uint256 public balanceInterval = 6 hours;
    uint256 public distributionInterval = 2 seconds;
    uint256 public depotFlushSize = 0.01 ether;


    address public swapAddress;
    address public vltAddress;
    address public collateralAddress;

    Token private vltToken;
    Token private cToken;
    UniSwapV2LiteRouter private swap;


    

    constructor(address _collateralAddress, address _vltAddress, address _swapAddress) Ownable() public {

        vltAddress = _vltAddress;
        vltToken = Token(_vltAddress);

        collateralAddress = _collateralAddress;
        cToken = Token(_collateralAddress);

        swapAddress = _swapAddress;
        swap = UniSwapV2LiteRouter(_swapAddress);

        lastPayout = now;

    }


    
    function donatePool(uint _amount) public returns (uint256) {
        require(cToken.transferFrom(msg.sender, address(this), _amount), "Transferred failed");

        dividendBalance_ += _amount;

        emit onDonation(msg.sender, _amount, now);
    }

    
    function buy(uint _buy_amount) public returns (uint256)  {
        return buyFor(msg.sender, _buy_amount);
    }


    
    function buyFor(address _customerAddress, uint _buy_amount) public returns (uint256)  {
        require(cToken.transferFrom(_customerAddress, address(this), _buy_amount), "Transferred failed");
        totalDeposits += _buy_amount;
        uint amount = purchaseTokens(_customerAddress, _buy_amount);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        
        distribute();

        return amount;
    }




    
    function() public payable  {
        
        require(false, "This contract does not except ETH");
    }

    
    function reinvest() public onlyStronghands  {
        
        uint256 _dividends = myDividends();
        

        
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);

        
        uint256 _tokens = purchaseTokens(msg.sender, _dividends);

        
        emit onReinvestment(_customerAddress, _dividends, _tokens, now);

        
        stats[_customerAddress].reinvested = SafeMath.add(stats[_customerAddress].reinvested, _dividends);
        stats[_customerAddress].xReinvested += 1;

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        
        distribute();
    }

    
    function withdraw() public onlyStronghands  {
        
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends();

        
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);


        
        cToken.transfer(_customerAddress, _dividends);

        
        stats[_customerAddress].withdrawn = SafeMath.add(stats[_customerAddress].withdrawn, _dividends);
        stats[_customerAddress].xWithdrawn += 1;
        totalTxs += 1;

        
        emit onWithdraw(_customerAddress, _dividends, now);

        
        distribute();
    }

    
    function claim() public {
        
        address _customerAddress = msg.sender;
        uint256 _dividends = myClaims();

        
        require(_dividends > 0, "No dividends to claim");

        
        stats[_customerAddress].tokenPayoutsTo += (int256) (_dividends * magnitude);


        
        vltToken.transfer(_customerAddress, _dividends);

        
        stats[_customerAddress].claims = SafeMath.add(stats[_customerAddress].claims, _dividends);
        stats[_customerAddress].xClaimed += 1;
        totalTxs += 1;

        
        emit onClaim(_customerAddress, _dividends, now);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        
        distribute();
    }

    
    function sell(uint256 _amountOfTokens) onlyBagholders public {
        
        address _customerAddress = msg.sender;

        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress], "Amount of tokens is greater than balance");


        
        uint256 _undividedDividends = SafeMath.mul(_amountOfTokens, exitFee_) / 100;
        uint256 _taxedeth = SafeMath.sub(_amountOfTokens, _undividedDividends);

        
        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens + (_taxedeth * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        
        stats[_customerAddress].tokenPayoutsTo -= (int256) (rewardsProfitPerShare_ * _amountOfTokens);


        
        allocateFees(_undividedDividends);

        
        emit onTokenSell(_customerAddress, _amountOfTokens, _taxedeth, now);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        
        distribute();
    }

    
    function transfer(address _toAddress, uint256 _amountOfTokens) external onlyBagholders  returns (bool) {
        
        address _customerAddress = msg.sender;

        
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress], "Amount of tokens is greater than balance");

        
        if (myDividends() > 0) {
            withdraw();
        }


        
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

        
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);

        
        stats[_customerAddress].tokenPayoutsTo -= (int256) (rewardsProfitPerShare_ * _amountOfTokens);
        stats[_toAddress].tokenPayoutsTo += (int256) (rewardsProfitPerShare_ * _amountOfTokens);


        
        if (stats[_toAddress].invested == 0 && stats[_toAddress].receivedTokens == 0) {
            players += 1;
        }

        
        stats[_customerAddress].xTransferredTokens += 1;
        stats[_customerAddress].transferredTokens += _amountOfTokens;
        stats[_toAddress].receivedTokens += _amountOfTokens;
        stats[_toAddress].xReceivedTokens += 1;
        totalTxs += 1;

        
        emit onTransfer(_customerAddress, _toAddress, _amountOfTokens, now);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        emit onLeaderBoard(_toAddress,
            stats[_toAddress].invested,
            tokenBalanceLedger_[_toAddress],
            stats[_toAddress].withdrawn,
            stats[_toAddress].claims,
            now
        );

        
        return true;
    }


    

    
    function totalTokenBalance() public view returns (uint256) {
        return cToken.balanceOf(address(this));
    }

    
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    
    function myDividends() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return dividendsOf(_customerAddress);
    }

    
    function myClaims() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return claimsOf(_customerAddress);
    }



    
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    
    function tokenBalance(address _customerAddress) public view returns (uint256) {
        return _customerAddress.balance;
    }

    
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    
    function claimsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (rewardsProfitPerShare_ * tokenBalanceLedger_[_customerAddress]) - stats[_customerAddress].tokenPayoutsTo) / magnitude;
    }

    
    function sellPrice() public pure returns (uint256) {
        uint256 _eth = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, exitFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_eth, _dividends);

        return _taxedeth;

    }

    
    function buyPrice() public pure returns (uint256) {
        uint256 _eth = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, entryFee_), 100);
        uint256 _taxedeth = SafeMath.add(_eth, _dividends);

        return _taxedeth;

    }

    
    function calculateTokensReceived(uint256 _ethToSpend) public pure returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethToSpend, entryFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_ethToSpend, _dividends);
        uint256 _amountOfTokens = _taxedeth;

        return _amountOfTokens;
    }

    
    function calculateethReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_, "Tokens to sell greater than supply");
        uint256 _eth = _tokensToSell;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, exitFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_eth, _dividends);
        return _taxedeth;
    }


    
    function statsOf(address _customerAddress) public view returns (uint256[16] memory){
        Stats memory s = stats[_customerAddress];
        uint256[16] memory statArray = [s.invested, s.withdrawn, s.rewarded, s.contributed, s.transferredTokens, s.receivedTokens, s.xInvested, s.xRewarded, s.xContributed, s.xWithdrawn, s.xTransferredTokens, s.xReceivedTokens, s.reinvested, s.xReinvested, s.claims, s.xClaimed];
        return statArray;
    }

    
    function dailyEstimate(address _customerAddress) public view returns (uint256){
        uint256 share = dividendBalance_.mul(payoutRate_).div(100);

        return (tokenSupply_ > 0) ? share.mul(tokenBalanceLedger_[_customerAddress]).div(tokenSupply_) : 0;
    }

    
    function dailyClaimEstimate(address _customerAddress) public view returns (uint256){
        uint256 share = swapBalance_.mul(payoutRate_).div(100);

        return (tokenSupply_ > 0) ? share.mul(tokenBalanceLedger_[_customerAddress]).div(tokenSupply_) : 0;
    }


    

    
    function allocateFees(uint fee) private {
        uint _share = fee.div(100);
        uint _drip = _share.mul(dripFee);
        uint _instant = _share.mul(instantFee);
        uint _swap = fee.safeSub(_drip + _instant);

        
        profitPerShare_ = SafeMath.add(profitPerShare_, (_instant * magnitude) / tokenSupply_);

        
        dividendBalance_ += _drip;
        swapCollector_ += _swap;
    }

    
    function distribute() private {

        if (now.safeSub(lastBalance_) > balanceInterval) {
            emit onBalance(totalTokenBalance(), now);
            lastBalance_ = now;
        }


        if (SafeMath.safeSub(now, lastPayout) > distributionInterval && tokenSupply_ > 0) {

            
            uint256 share = dividendBalance_.mul(payoutRate_).div(100).div(24 hours);
            
            uint256 profit = share * now.safeSub(lastPayout);
            
            dividendBalance_ = dividendBalance_.safeSub(profit);

            
            profitPerShare_ = SafeMath.add(profitPerShare_, (profit * magnitude) / tokenSupply_);


            
            
            share = swapBalance_.mul(payoutRate_).div(100).div(24 hours);
            
            profit = share * now.safeSub(lastPayout);

            
            swapBalance_ = swapBalance_.safeSub(profit);

            
            rewardsProfitPerShare_ = SafeMath.add(rewardsProfitPerShare_, (profit * magnitude) / tokenSupply_);

            processBuyBacks();

            lastPayout = now;

        }


    }


    
    function processBuyBacks() private {

        
        if (SafeMath.safeSub(now, lastBuyback) > 1 hours) {

            
            address[] memory path = new address[](2);
            path[0] = collateralAddress;
            path[1] = swap.WETH();

            uint[] memory amounts = swap.getAmountsOut(swapCollector_, path);

            if (amounts[1] >= depotFlushSize) {

                uint amount = swapCollector_;

                
                swapCollector_ = 0;

                
                uint _tokens = buyback(amount);

                totalClaims += _tokens;

                
                swapBalance_ += _tokens;

                lastBuyback = now;

            }
        }
    }

    
    function buyback(uint amount) private returns (uint) {
        address[] memory path = new address[](3);
        path[0] = collateralAddress;
        path[1] = swap.WETH();
        path[2] = vltAddress;

        
        require(cToken.approve(swapAddress, amount), "Amount approved not available");

        uint[] memory amounts = swap.swapExactTokensForTokens(amount, 1, path, address(this), now + 24 hours);

        
        emit onBuyBack(amount, amounts[2], now);

        return amounts[2];

    }

    
    function purchaseTokens(address _customerAddress, uint256 _incomingtokens) internal returns (uint256) {

        
        if (stats[_customerAddress].invested == 0 && stats[_customerAddress].receivedTokens == 0) {
            players += 1;
        }

        totalTxs += 1;

        
        uint256 _undividedDividends = SafeMath.mul(_incomingtokens, entryFee_) / 100;
        uint256 _amountOfTokens = SafeMath.sub(_incomingtokens, _undividedDividends);

        
        emit onTokenPurchase(_customerAddress, _incomingtokens, _amountOfTokens, now);

        
        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_, "Tokens need to be positive");


        
        if (tokenSupply_ > 0) {
            
            tokenSupply_ += _amountOfTokens;

        } else {
            
            tokenSupply_ = _amountOfTokens;
        }

        
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        
        
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        _updatedPayouts = (int256) (rewardsProfitPerShare_ * _amountOfTokens);
        stats[_customerAddress].tokenPayoutsTo += _updatedPayouts;

        
        allocateFees(_undividedDividends);

        
        stats[_customerAddress].invested += _incomingtokens;
        stats[_customerAddress].xInvested += 1;

        return _amountOfTokens;
    }

    


    
    function updateSwapRouter(address _swapAddress) onlyOwner() public {

        emit onRouterUpdate(swapAddress, _swapAddress);
        swapAddress = _swapAddress;
        swap = UniSwapV2LiteRouter(_swapAddress);
    }

    
    function updateFlushSize(uint _flushSize) onlyOwner() public {
        require(_flushSize >= 0.01 ether && _flushSize <= 5 ether, "Flush size is out of range");

        emit onFlushUpdate(depotFlushSize, _flushSize);
        depotFlushSize = _flushSize;
    }

}


library SafeMath {

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    
    function safeSub(uint a, uint b) internal pure returns (uint) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}