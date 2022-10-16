pragma solidity 0.4.25;



interface IMonetaryModel {
        function buy(uint256 _sdrAmount) external returns (uint256);

        function sell(uint256 _sgaAmount) external returns (uint256);
}



interface IMonetaryModelState {
        function setSdrTotal(uint256 _amount) external;

        function setSgaTotal(uint256 _amount) external;

        function getSdrTotal() external view returns (uint256);

        function getSgaTotal() external view returns (uint256);
}



interface IModelCalculator {
        function isTrivialInterval(uint256 _alpha, uint256 _beta) external pure returns (bool);

        function getValN(uint256 _valR, uint256 _maxN, uint256 _maxR) external pure returns (uint256);

        function getValR(uint256 _valN, uint256 _maxR, uint256 _maxN) external pure returns (uint256);

        function getNewN(uint256 _newR, uint256 _minR, uint256 _minN, uint256 _alpha, uint256 _beta) external pure returns (uint256);

        function getNewR(uint256 _newN, uint256 _minN, uint256 _minR, uint256 _alpha, uint256 _beta) external pure returns (uint256);
}



interface IPriceBandCalculator {
        function buy(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);

        function sell(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);
}



interface IIntervalIterator {
        function grow() external;

        function shrink() external;

        function getCurrentInterval() external view returns (uint256, uint256, uint256, uint256, uint256, uint256);

        function getCurrentIntervalCoefs() external view returns (uint256, uint256);
}



interface IContractAddressLocator {
        function getContractAddress(bytes32 _identifier) external view returns (address);

        function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);
}



contract ContractAddressLocatorHolder {
    bytes32 internal constant _IAuthorizationDataSource_ = "IAuthorizationDataSource";
    bytes32 internal constant _ISGNConversionManager_    = "ISGNConversionManager"      ;
    bytes32 internal constant _IModelDataSource_         = "IModelDataSource"        ;
    bytes32 internal constant _IPaymentHandler_          = "IPaymentHandler"            ;
    bytes32 internal constant _IPaymentManager_          = "IPaymentManager"            ;
    bytes32 internal constant _IPaymentQueue_            = "IPaymentQueue"              ;
    bytes32 internal constant _IReconciliationAdjuster_  = "IReconciliationAdjuster"      ;
    bytes32 internal constant _IIntervalIterator_        = "IIntervalIterator"       ;
    bytes32 internal constant _IMintHandler_             = "IMintHandler"            ;
    bytes32 internal constant _IMintListener_            = "IMintListener"           ;
    bytes32 internal constant _IMintManager_             = "IMintManager"            ;
    bytes32 internal constant _IPriceBandCalculator_     = "IPriceBandCalculator"       ;
    bytes32 internal constant _IModelCalculator_         = "IModelCalculator"        ;
    bytes32 internal constant _IRedButton_               = "IRedButton"              ;
    bytes32 internal constant _IReserveManager_          = "IReserveManager"         ;
    bytes32 internal constant _ISagaExchanger_           = "ISagaExchanger"          ;
    bytes32 internal constant _IMonetaryModel_               = "IMonetaryModel"              ;
    bytes32 internal constant _IMonetaryModelState_          = "IMonetaryModelState"         ;
    bytes32 internal constant _ISGAAuthorizationManager_ = "ISGAAuthorizationManager";
    bytes32 internal constant _ISGAToken_                = "ISGAToken"               ;
    bytes32 internal constant _ISGATokenManager_         = "ISGATokenManager"        ;
    bytes32 internal constant _ISGNAuthorizationManager_ = "ISGNAuthorizationManager";
    bytes32 internal constant _ISGNToken_                = "ISGNToken"               ;
    bytes32 internal constant _ISGNTokenManager_         = "ISGNTokenManager"        ;
    bytes32 internal constant _IMintingPointTimersManager_             = "IMintingPointTimersManager"            ;
    bytes32 internal constant _ITradingClasses_          = "ITradingClasses"         ;
    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = "IWalletsTLValueConverter"       ;
    bytes32 internal constant _IWalletsTradingDataSource_       = "IWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _WalletsTradingLimiter_SGATokenManager_          = "WalletsTLSGATokenManager"         ;
    bytes32 internal constant _IETHConverter_             = "IETHConverter"   ;
    bytes32 internal constant _ITransactionLimiter_      = "ITransactionLimiter"     ;
    bytes32 internal constant _ITransactionManager_      = "ITransactionManager"     ;
    bytes32 internal constant _IRateApprover_      = "IRateApprover"     ;

    IContractAddressLocator private contractAddressLocator;

        constructor(IContractAddressLocator _contractAddressLocator) internal {
        require(_contractAddressLocator != address(0), "locator is illegal");
        contractAddressLocator = _contractAddressLocator;
    }

        function getContractAddressLocator() external view returns (IContractAddressLocator) {
        return contractAddressLocator;
    }

        function getContractAddress(bytes32 _identifier) internal view returns (address) {
        return contractAddressLocator.getContractAddress(_identifier);
    }



        function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {
        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);
    }

        modifier only(bytes32 _identifier) {
        require(msg.sender == getContractAddress(_identifier), "caller is illegal");
        _;
    }

}



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




contract MonetaryModel is IMonetaryModel, ContractAddressLocatorHolder {
    string public constant VERSION = "1.0.0";

    using SafeMath for uint256;

    event MonetaryModelBuyCompleted(uint256 _input, uint256 _output);
    event MonetaryModelSellCompleted(uint256 _input, uint256 _output);

        constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

        function getMonetaryModelState() public view returns (IMonetaryModelState) {
        return IMonetaryModelState(getContractAddress(_IMonetaryModelState_));
    }

        function getModelCalculator() public view returns (IModelCalculator) {
        return IModelCalculator(getContractAddress(_IModelCalculator_));
    }

        function getPriceBandCalculator() public view returns (IPriceBandCalculator) {
        return IPriceBandCalculator(getContractAddress(_IPriceBandCalculator_));
    }

        function getIntervalIterator() public view returns (IIntervalIterator) {
        return IIntervalIterator(getContractAddress(_IIntervalIterator_));
    }

        function buy(uint256 _sdrAmount) external only(_ITransactionManager_) returns (uint256) {
        IMonetaryModelState monetaryModelState = getMonetaryModelState();
        IIntervalIterator intervalIterator = getIntervalIterator();

        uint256 sgaTotal = monetaryModelState.getSgaTotal();
        (uint256 alpha, uint256 beta) = intervalIterator.getCurrentIntervalCoefs();
        uint256 sdrAmountAfterFee = getPriceBandCalculator().buy(_sdrAmount, sgaTotal, alpha, beta);
        uint256 sgaAmount = buyFunc(sdrAmountAfterFee, monetaryModelState, intervalIterator);

        emit MonetaryModelBuyCompleted(_sdrAmount, sgaAmount);
        return sgaAmount;
    }

        function sell(uint256 _sgaAmount) external only(_ITransactionManager_) returns (uint256) {
        IMonetaryModelState monetaryModelState = getMonetaryModelState();
        IIntervalIterator intervalIterator = getIntervalIterator();

        uint256 sgaTotal = monetaryModelState.getSgaTotal();
        (uint256 alpha, uint256 beta) = intervalIterator.getCurrentIntervalCoefs();
        uint256 sdrAmountBeforeFee = sellFunc(_sgaAmount, monetaryModelState, intervalIterator);
        uint256 sdrAmount = getPriceBandCalculator().sell(sdrAmountBeforeFee, sgaTotal, alpha, beta);

        emit MonetaryModelSellCompleted(_sgaAmount, sdrAmount);
        return sdrAmount;
    }

        function buyFunc(uint256 _sdrAmount, IMonetaryModelState _monetaryModelState, IIntervalIterator _intervalIterator) private returns (uint256) {
        uint256 sgaCount = 0;
        uint256 sdrCount = _sdrAmount;

        uint256 sdrDelta;
        uint256 sgaDelta;

        uint256 sdrTotal = _monetaryModelState.getSdrTotal();
        uint256 sgaTotal = _monetaryModelState.getSgaTotal();

        
        (uint256 minN, uint256 maxN, uint256 minR, uint256 maxR, uint256 alpha, uint256 beta) = _intervalIterator.getCurrentInterval();
        while (sdrCount >= maxR.sub(sdrTotal)) {
            sdrDelta = maxR.sub(sdrTotal);
            sgaDelta = maxN.sub(sgaTotal);
            _intervalIterator.grow();
            (minN, maxN, minR, maxR, alpha, beta) = _intervalIterator.getCurrentInterval();
            sdrTotal = minR;
            sgaTotal = minN;
            sdrCount = sdrCount.sub(sdrDelta);
            sgaCount = sgaCount.add(sgaDelta);
        }

        if (sdrCount > 0) {
            if (getModelCalculator().isTrivialInterval(alpha, beta))
                sgaDelta = getModelCalculator().getValN(sdrCount, maxN, maxR);
            else
                sgaDelta = getModelCalculator().getNewN(sdrTotal.add(sdrCount), minR, minN, alpha, beta).sub(sgaTotal);
            sdrTotal = sdrTotal.add(sdrCount);
            sgaTotal = sgaTotal.add(sgaDelta);
            sgaCount = sgaCount.add(sgaDelta);
        }

        _monetaryModelState.setSdrTotal(sdrTotal);
        _monetaryModelState.setSgaTotal(sgaTotal);

        return sgaCount;
    }

        function sellFunc(uint256 _sgaAmount, IMonetaryModelState _monetaryModelState, IIntervalIterator _intervalIterator) private returns (uint256) {
        uint256 sdrCount = 0;
        uint256 sgaCount = _sgaAmount;

        uint256 sgaDelta;
        uint256 sdrDelta;

        uint256 sgaTotal = _monetaryModelState.getSgaTotal();
        uint256 sdrTotal = _monetaryModelState.getSdrTotal();

        
        (uint256 minN, uint256 maxN, uint256 minR, uint256 maxR, uint256 alpha, uint256 beta) = _intervalIterator.getCurrentInterval();
        while (sgaCount > sgaTotal.sub(minN)) {
            sgaDelta = sgaTotal.sub(minN);
            sdrDelta = sdrTotal.sub(minR);
            _intervalIterator.shrink();
            (minN, maxN, minR, maxR, alpha, beta) = _intervalIterator.getCurrentInterval();
            sgaTotal = maxN;
            sdrTotal = maxR;
            sgaCount = sgaCount.sub(sgaDelta);
            sdrCount = sdrCount.add(sdrDelta);
        }

        if (sgaCount > 0) {
            if (getModelCalculator().isTrivialInterval(alpha, beta))
                sdrDelta = getModelCalculator().getValR(sgaCount, maxR, maxN);
            else
                sdrDelta = sdrTotal.sub(getModelCalculator().getNewR(sgaTotal.sub(sgaCount), minN, minR, alpha, beta));
            sgaTotal = sgaTotal.sub(sgaCount);
            sdrTotal = sdrTotal.sub(sdrDelta);
            sdrCount = sdrCount.add(sdrDelta);
        }

        _monetaryModelState.setSgaTotal(sgaTotal);
        _monetaryModelState.setSdrTotal(sdrTotal);

        return sdrCount;
    }
}