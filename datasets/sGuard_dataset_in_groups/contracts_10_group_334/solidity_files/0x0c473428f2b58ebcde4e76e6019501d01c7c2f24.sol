pragma solidity 0.4.25;



interface IModelDataSource {
        function getInterval(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);

        function getIntervalCoefs(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256);

        function getRequiredMintAmount(uint256 _rowNum) external view returns (uint256);
}



interface IMintingPointTimersManager {
        function start(uint256 _id) external;

        function reset(uint256 _id) external;

        function running(uint256 _id) external view returns (bool);

        function expired(uint256 _id) external view returns (bool);
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




contract IntervalIterator is IIntervalIterator, ContractAddressLocatorHolder {
    string public constant VERSION = "1.0.0";

    uint256 public row;
    uint256 public col;

        constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

        function getModelDataSource() public view returns (IModelDataSource) {
        return IModelDataSource(getContractAddress(_IModelDataSource_));
    }

        function getMintingPointTimersManager() public view returns (IMintingPointTimersManager) {
        return IMintingPointTimersManager(getContractAddress(_IMintingPointTimersManager_));
    }

        function grow() external only(_IMonetaryModel_) {
        if (col == 0) {
            row += 1;
            getMintingPointTimersManager().start(row);
        }
        else {
            col -= 1;
        }
    }

        function shrink() external only(_IMonetaryModel_) {
        IMintingPointTimersManager mintingPointTimersManager = getMintingPointTimersManager();
        if (mintingPointTimersManager.running(row)) {
            mintingPointTimersManager.reset(row);
            assert(row > 0);
            row -= 1;
        }
        else {
            col += 1;
        }
    }

        function getCurrentInterval() external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return getModelDataSource().getInterval(row, col);
    }

        function getCurrentIntervalCoefs() external view returns (uint256, uint256) {
        return getModelDataSource().getIntervalCoefs(row, col);
    }
}