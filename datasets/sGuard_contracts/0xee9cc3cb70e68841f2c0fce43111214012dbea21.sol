pragma solidity 0.4.25;



interface IMonetaryModel {
        function buy(uint256 _sdrAmount) external returns (uint256);

        function sell(uint256 _sgaAmount) external returns (uint256);
}



interface IReconciliationAdjuster {
        function adjustBuy(uint256 _sdrAmount) external view returns (uint256);

        function adjustSell(uint256 _sdrAmount) external view returns (uint256);
}



interface ITransactionManager {
        function buy(uint256 _ethAmount) external returns (uint256);

        function sell(uint256 _sgaAmount) external returns (uint256);
}



interface ITransactionLimiter {
        function resetTotal() external;

        function incTotalBuy(uint256 _amount) external;

        function incTotalSell(uint256 _amount) external;
}



interface IETHConverter {
        function toSdrAmount(uint256 _ethAmount) external view returns (uint256);

        function toEthAmount(uint256 _sdrAmount) external view returns (uint256);

        function fromEthAmount(uint256 _ethAmount) external view returns (uint256);
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




contract TransactionManager is ITransactionManager, ContractAddressLocatorHolder {
    string public constant VERSION = "1.0.0";

    event TransactionManagerBuyCompleted(uint256 _amount);
    event TransactionManagerSellCompleted(uint256 _amount);

        constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

        function getMonetaryModel() public view returns (IMonetaryModel) {
        return IMonetaryModel(getContractAddress(_IMonetaryModel_));
    }

        function getReconciliationAdjuster() public view returns (IReconciliationAdjuster) {
        return IReconciliationAdjuster(getContractAddress(_IReconciliationAdjuster_));
    }

        function getTransactionLimiter() public view returns (ITransactionLimiter) {
        return ITransactionLimiter(getContractAddress(_ITransactionLimiter_));
    }

        function getETHConverter() public view returns (IETHConverter) {
        return IETHConverter(getContractAddress(_IETHConverter_));
    }

        function buy(uint256 _ethAmount) external only(_ISGATokenManager_) returns (uint256) {
        uint256 sdrAmount = getETHConverter().toSdrAmount(_ethAmount);
        uint256 newAmount = getReconciliationAdjuster().adjustBuy(sdrAmount);
        uint256 sgaAmount = getMonetaryModel().buy(newAmount);
        getTransactionLimiter().incTotalBuy(sdrAmount);
        emit TransactionManagerBuyCompleted(sdrAmount);
        return sgaAmount;
    }

        function sell(uint256 _sgaAmount) external only(_ISGATokenManager_) returns (uint256) {
        uint256 sdrAmount = getMonetaryModel().sell(_sgaAmount);
        uint256 newAmount = getReconciliationAdjuster().adjustSell(sdrAmount);
        uint256 ethAmount = getETHConverter().toEthAmount(newAmount);
        getTransactionLimiter().incTotalSell(sdrAmount);
        emit TransactionManagerSellCompleted(newAmount);
        return ethAmount;
    }
}