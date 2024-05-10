pragma solidity ^0.5.11;

contract SynthetixInterface {
    function exchange(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey)
        external 
        returns (uint amountReceived);
    function synths(bytes32 currencyKey) public view returns (address);
}

contract SynthInterface {
    function currencyKey() public view returns (bytes32 _currencyKey);
    function transfer(address to, uint tokens) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);
}

contract ExchRatesInterface {
    function rateForCurrency(bytes32 currencyKey) external view returns (uint);
    function ratesForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint256[] memory);
}

contract marginTrade {
    
    
    bytes32 private constant sUSD = "sUSD";
    bytes32 private constant sETH = "sETH";
    uint constant IM_BUFFER_OVER_MM = 200;
    uint constant e18 = 10**18;
    uint constant SECONDS_IN_YEAR = 31557600;
    
    
    
    address constant public exchRateAddress = 0x9D7F70AF5DF5D5CC79780032d47a34615D1F1d77;
    address constant public synthetixContractAddress = 0xC011A72400E58ecD99Ee497CF89E3775d4bd732F;
    
    
    
    
    
    
    
    address payable public lender;
    address payable public trader;
    uint public APR;                             
    uint public maxDurationSecs;                 
    uint public maxLoanAmt;                     
    bytes32[] public approvedSynths;                    
    mapping(bytes32 => uint) public lenderSynthBalances; 
    uint public lenderEthBalance;
    uint public loanStartTS;                        
    uint public mm;                     
    bool public wasLiquidated = false;
    
    mapping(bytes32 => address) synthToAddress;  
    
    
    uint256 private loanBalance;
    uint private lastLoanSettleTS;
    
    
    
    
    constructor(
                address payable _lenderAddress, 
                address payable _traderAddress,
                uint256 _APR,
                uint256 _maxDurationSecs,
                uint256 _maxLoanAmt,
                uint _mm,
                bytes32[] memory _approvedSynths,
                address[] memory _approvedSynthAddresses
                )
        public
    {
        lender = _lenderAddress;
        trader = _traderAddress; 
        APR = _APR;
        maxDurationSecs = _maxDurationSecs;
        maxLoanAmt = _maxLoanAmt;
        mm = _mm;
        
        
        bool sUSDFound = false;
        for(uint i = 0; i < _approvedSynths.length; i++) {
            if (_approvedSynths[i] == sUSD) {
                sUSDFound = true;
            }
        }
        require(sUSDFound, "sUSD must be among the approved synths.");
        approvedSynths = _approvedSynths;
        
        require(approvedSynths.length == _approvedSynthAddresses.length, "lengths dont match.");
        for (uint i = 0; i < approvedSynths.length; i++) {
            synthToAddress[approvedSynths[i]] = _approvedSynthAddresses[i];
        }
        
        
        
        
    }
    
    function() external payable {}
    
    
    
    
    function setMaxLoanAmount(uint256 _maxLoanAmt)
        external
    {
        require(msg.sender == trader, "Only the Trader can change the desired max loan amt");
        maxLoanAmt = _maxLoanAmt;
    }
    
    
    
     
    function depositFunds(SynthInterface token, uint256 amount)
        public
    {
        require(token.currencyKey() == sUSD, "Loan deposit must be sUSD"); 
        require(amount > 0);
        
        uint _svPre = traderTotSynthValueUSD();
        uint _newLoanBalance = loanBalUSD() + amount;
        
        require(_newLoanBalance <= maxLoanAmt, "loan amount too high");
        
        
        require( isInitialMarginSatisfied(_svPre + amount, collValueUSD(), 
                                           _newLoanBalance, mm), "Not enough collateral in the contract.");
                                           
        require(token.transferFrom(msg.sender, address(this), amount), "token transfer failed");
        
        loanBalance = _newLoanBalance;
        lastLoanSettleTS = now;
        
        if (loanStartTS == 0) {
            loanStartTS = now;
        }
    }
    
    
    function trade(
                   bytes32 sourceCurrencyKey, 
                   uint sourceAmount,
                   bytes32 destCurrencyKey) 
                   public
                   returns (uint)
    {
        
       
        require(msg.sender == trader);
        
        
        require(synthBalanceTrader(sourceCurrencyKey) >= sourceAmount,
                "trader does not have enough balance");
        
        return SynthetixInterface( synthetixContractAddress).exchange(sourceCurrencyKey,
                   sourceAmount, destCurrencyKey);
    }
    
    
     function liquidate()
        public
        returns (bool)
    {
        require(!wasLiquidated, "already liquidated" );
        
        if (isLiquidationable()) {
            
            lenderEthBalance = address(this).balance;
            for (uint i = 0; i < approvedSynths.length; i++) {
                uint _bal = SynthInterface(synthToAddress[approvedSynths[i]]).balanceOf(address(this));
                lenderSynthBalances[approvedSynths[i]] = _bal;
            }
            wasLiquidated = true;
        } else {
            revert("not liquidation eligible");
        }
    }
    
    
    function traderWithdrawEth(uint amt) 
        public
        payable
    {
        require(msg.sender == trader, "Only trader can withdraw eth");
        require(amt <=  address(this).balance - lenderEthBalance, "withdraw amt too high");
        
        uint usdAmt = getRate(sETH) * amt / e18;
        
        if (isInitialMarginSatisfied(traderTotSynthValueUSD(), collValueUSD() - usdAmt, loanBalUSD(), mm)) {
            address(trader).transfer(amt);    
        } else {
            revert("Cant withdraw that much");
        }
    }
    
    
    function lenderWithdrawEth(uint amt) 
        public
        payable
    {
        require(msg.sender == lender, "Only lender can withdraw eth");
        require(amt <=  lenderEthBalance);
        address(lender).transfer(amt);  
        lenderEthBalance = lenderEthBalance - amt;
    }
    
    
    function traderWithdrawSynth(uint amt, bytes32 currencyKey) 
        public
        returns (bool)
    {
        require(msg.sender == trader, "Only trader can withdraw synths.");
        require(synthToAddress[currencyKey] != address(0), "currency key not in approved list");
        
        uint usdAmt = _synthValueUSD(getRate(currencyKey), amt);
        
        if (isInitialMarginSatisfied(traderTotSynthValueUSD() - usdAmt, collValueUSD(), loanBalUSD(), mm) ) {
            return  SynthInterface( synthToAddress[currencyKey]).transfer(trader, amt); 
        }
        revert("Cant withdraw that much");
    }
    
    
    function lenderWithdrawSynth(uint amt, bytes32 currencyKey) 
        public
        returns (bool)
    {
        require(msg.sender == lender, "Only lender can withdraw synths.");
        require(lenderSynthBalances[currencyKey] >= amt, "Withdraw amt is too high.");
        
        bool result = SynthInterface( synthToAddress[currencyKey]).transfer(lender, amt); 
        if (result) {
            lenderSynthBalances[currencyKey] = lenderSynthBalances[currencyKey] - amt;
        }
        return result;
    }
    
    
    function traderRepayLoan(uint amount)
        public
        returns (bool)
    {
        require(msg.sender == trader, "only trader can repay loan");
        
        uint _loanBalance = loanBalUSD();
        uint _amt;
        if (amount > _loanBalance)
            _amt = _loanBalance;
        else
            _amt = amount;
        
        require(synthBalanceTrader(sUSD) >= _amt, "Not enough sUSD to repay.");
        
        
        loanBalance = _loanBalance - _amt;
        lastLoanSettleTS = now;
        
        lenderSynthBalances[sUSD] = lenderSynthBalances[sUSD] + _amt;
        
        
        if (loanBalance == 0) {
            maxLoanAmt = 0;
        }
        
        return true;
    }
    
    
    function loanExpired_Close()
        public
        returns (bool)
    {
        require(msg.sender == lender || msg.sender == trader);
        require(isLoanExpired(), "loan has not expired");
        
        maxLoanAmt = 0;  
        
        
        
        uint totalRemainaingUSD = loanBalUSD();
        uint _usdAssigned; uint _weiAssigned;
        
        
        (_usdAssigned, _weiAssigned) = _determineAssignableAmt(totalRemainaingUSD, 
                                                            synthBalanceTrader(sUSD),
                                                            getRate(sUSD) );
        if (_weiAssigned > 0) {
            totalRemainaingUSD = sub(totalRemainaingUSD, _usdAssigned);
            lenderSynthBalances[sUSD] = lenderSynthBalances[sUSD] + _weiAssigned;
        }
        if (totalRemainaingUSD == 0) {
            loanBalance = 0;  
            lastLoanSettleTS = now;
            return true;
        }
        
        
        for (uint i = 0; i < approvedSynths.length; i++) {
            if (approvedSynths[i] != sUSD) {
                bytes32 _synth = approvedSynths[i];
                (_usdAssigned, _weiAssigned) = _determineAssignableAmt(totalRemainaingUSD, 
                                                                    synthBalanceTrader(_synth), 
                                                                    getRate(_synth));
                if (_weiAssigned > 0) {
                    totalRemainaingUSD = sub(totalRemainaingUSD, _usdAssigned);
                    lenderSynthBalances[_synth] = lenderSynthBalances[_synth] + _weiAssigned;
                }
                if (totalRemainaingUSD == 0) {
                    loanBalance = 0;  
                    lastLoanSettleTS = now;
                    return true;
                }       
            }
        }
        
        
        (_usdAssigned, _weiAssigned) = _determineAssignableAmt(totalRemainaingUSD, 
                                                            sub(address(this).balance, lenderEthBalance),
                                                            getRate(sETH));
        if (_weiAssigned > 0) {
            totalRemainaingUSD = sub(totalRemainaingUSD, _usdAssigned);
            lenderEthBalance = lenderEthBalance + _weiAssigned;
        }
        if (totalRemainaingUSD == 0) {
            loanBalance = 0;  
            lastLoanSettleTS = now;
            return true;
        }
        
        loanBalance = totalRemainaingUSD;  
        lastLoanSettleTS = now;
        return false;
    }
    
    
    
    
    function isLiquidationable()
        public
        view
        returns (bool)
    {   
        if (wasLiquidated) {
            return false;
        }
        
        uint sv = traderTotSynthValueUSD();
        uint lv = loanBalUSD();
        uint cv = collValueUSD();
        uint f = (10**18 + mm * 10*14);
        
        if ( (sv + cv) > mul(f, lv) / e18 ) 
        {
            
            return false;
        }
        return true;
    }
    
    
    function isInitialMarginSatisfied(uint _sv, uint _cv, uint _lv, uint _mm)
        public
        pure
        returns (bool)
    {
        uint f = (10**18 + (_mm + IM_BUFFER_OVER_MM) * 10**14);
        
        if ( (_sv + _cv) >= mul(f, _lv)/e18 ) 
        {
            return true; 
        }
        return false;
    }
 
    
     function getRate(bytes32 currencyKey)
        public
        view
        returns (uint)
    {
        return ExchRatesInterface(exchRateAddress).rateForCurrency(currencyKey);
    }
    
    
    
     function getRates(bytes32[] memory currencyKeys)
        public
        view
        returns (uint[] memory)
    {
        return ExchRatesInterface(exchRateAddress).ratesForCurrencies(currencyKeys);
    }
    
    
    function traderTotSynthValueUSD()
        public
        view
        returns (uint)
    {
        uint[] memory rates = getRates(approvedSynths);
        uint value = 0;
        for (uint i = 0; i < approvedSynths.length; i++) {
            value = value + _synthValueUSD(rates[i], synthBalanceTrader(approvedSynths[i]));
        }
        
        return value; 
    }

    
    function synthBalanceTrader(bytes32 currencyKey)
        public
        view
        returns (uint)
    {
        uint _bal = SynthInterface(synthToAddress[currencyKey]).balanceOf(address(this));
        
        return _bal - lenderSynthBalances[currencyKey];
    }
    
    
    function loanBalUSD() 
        public
        view
        returns (uint)
    {
        uint interest = calcInterest(APR, loanBalance, now - lastLoanSettleTS);
        return loanBalance + interest;
    }
    
    
    function collValueUSD()
        public
        view
        returns (uint)
    {
        return mul(getRate(sETH), address(this).balance - lenderEthBalance) / 1e18;
    }
    
    
    function traderEthBalance()
        public
        view
        returns (uint)
    {
        return  sub(address(this).balance, lenderEthBalance);
    }
    
    function isLoanExpired()
        public
        view
        returns (bool)
    {
        return (now - loanStartTS) > maxDurationSecs;
    }
    
    
    
    function levTimes100()
        public
        view
        returns (uint)
    {
        uint sv = traderTotSynthValueUSD();
        uint lv = loanBalUSD();
        uint cv = collValueUSD();
        return 100 * lv / (sv + cv - lv);
    }
    
    
    
    
    
      
    function calcInterest(uint256 _APR, uint256 amount, uint256 elapsedTime)
        private
        pure
        returns (uint256)
    {
        uint n = mul(elapsedTime, 1000000);
        n = mul(n, amount);
        n = mul(n, _APR);
        uint d = mul(SECONDS_IN_YEAR, 10000000000);
        return n/d;
    }
    
    
    
    
    function _determineAssignableAmt(uint maxAssignUSD, uint balWei, uint rate)
        private
        pure
        returns (uint amtAssignableUSD, uint amtAssignableSynth)
    {
        if (balWei == 0) {
            return (0, 0);
        }
        
        uint balUSD = _synthValueUSD(rate, balWei);
        
        if (maxAssignUSD >= balUSD) {
            return (maxAssignUSD - balUSD, balWei);
        } else {
            return (maxAssignUSD, mul(balWei, maxAssignUSD) / balUSD) ;
        }
    }
    
    
    
    function mul(uint256 a, uint256 b) 
        internal
        pure
        returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    
    function sub(uint256 a, uint256 b) 
        internal
        pure
        returns (uint256) 
    {
        if (b > a) {
            return 0;
        }
        uint256 c = a - b;
        return c;
    }

    
    function _synthValueUSD(uint rate, uint balance) 
        public
        pure
        returns (uint)
    {
        return mul(rate, balance) / e18;
    }    
    
}