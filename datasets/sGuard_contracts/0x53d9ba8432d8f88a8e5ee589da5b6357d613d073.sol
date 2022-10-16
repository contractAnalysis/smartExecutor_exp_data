pragma solidity 0.4.25;



interface IWalletsTradingLimiter {
        function updateWallet(address _wallet, uint256 _value) external;
}



interface IWalletsTradingDataSource {
        function updateWallet(address _wallet, uint256 _value, uint256 _limit) external;
}



interface IWalletsTradingLimiterValueConverter {
        function toLimiterValue(uint256 _sgaAmount) external view returns (uint256);
}



interface ITradingClasses {
        function getInfo(uint256 _id) external view returns (uint256, uint256, uint256);

        function getActionRole(uint256 _id) external view returns (uint256);

        function getSellLimit(uint256 _id) external view returns (uint256);

        function getBuyLimit(uint256 _id) external view returns (uint256);
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
    bytes32 internal constant _BuyWalletsTradingDataSource_       = "BuyWalletsTradingDataSource"      ;
    bytes32 internal constant _SellWalletsTradingDataSource_       = "SellWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _BuyWalletsTradingLimiter_SGATokenManager_          = "BuyWalletsTLSGATokenManager"         ;
    bytes32 internal constant _SellWalletsTradingLimiter_SGATokenManager_          = "SellWalletsTLSGATokenManager"         ;
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



interface IAuthorizationDataSource {
        function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);

        function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256);

        function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256);


        function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);

        function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);
}



contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


    constructor() public {
    owner = msg.sender;
  }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

    function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

    function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

    function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}



contract Claimable is Ownable {
  address public pendingOwner;

    modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

    function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

    function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}




contract WalletsTradingLimiterBase is IWalletsTradingLimiter, ContractAddressLocatorHolder, Claimable {
    string public constant VERSION = "1.1.0";

    bytes32 public walletsTradingDataSourceIdentifier;

        constructor(IContractAddressLocator _contractAddressLocator, bytes32 _walletsTradingDataSourceIdentifier) ContractAddressLocatorHolder(_contractAddressLocator) public {
        walletsTradingDataSourceIdentifier = _walletsTradingDataSourceIdentifier;
    }

        function getAuthorizationDataSource() public view returns (IAuthorizationDataSource) {
        return IAuthorizationDataSource(getContractAddress(_IAuthorizationDataSource_));
    }

        function getTradingClasses() public view returns (ITradingClasses) {
        return ITradingClasses(getContractAddress(_ITradingClasses_));
    }

        function getWalletsTradingDataSource() public view returns (IWalletsTradingDataSource) {
        return IWalletsTradingDataSource(getContractAddress(walletsTradingDataSourceIdentifier));
    }

        function getWalletsTradingLimiterValueConverter() public view returns (IWalletsTradingLimiterValueConverter) {
        return IWalletsTradingLimiterValueConverter(getContractAddress(_IWalletsTradingLimiterValueConverter_));
    }

        function getUpdateWalletPermittedContractLocatorIdentifier() public pure returns (bytes32);

        function getOverrideTradeLimitAndClass(address _wallet) public view returns (uint256, uint256);

        function getTradeLimit(uint256 _tradeClassId) public view returns (uint256);

        function getLimiterValue(uint256 _value) public view returns (uint256);


        function updateWallet(address _wallet, uint256 _value) external only(getUpdateWalletPermittedContractLocatorIdentifier()) {
        uint256 limiterValue = getLimiterValue(_value);

        (uint256 overrideTradeLimit, uint256 tradeClassId) = getOverrideTradeLimitAndClass(_wallet);

        uint256 tradeLimit = overrideTradeLimit > 0 ? overrideTradeLimit : getTradeLimit(tradeClassId);

        getWalletsTradingDataSource().updateWallet(_wallet, limiterValue, tradeLimit);
    }
}




contract SGAWalletsTradingLimiter is WalletsTradingLimiterBase {
    string public constant VERSION = "1.1.0";

        constructor(IContractAddressLocator _contractAddressLocator, bytes32 _walletsTradingDataSourceIdentifier) WalletsTradingLimiterBase(_contractAddressLocator, _walletsTradingDataSourceIdentifier) public {}


        function getUpdateWalletPermittedContractLocatorIdentifier() public pure returns (bytes32){
        return _ISGATokenManager_;
    }

        function getLimiterValue(uint256 _value) public view returns (uint256){
        return getWalletsTradingLimiterValueConverter().toLimiterValue(_value);
    }
}




contract SGABuyWalletsTradingLimiter is SGAWalletsTradingLimiter {
    string public constant VERSION = "1.1.0";

        constructor(IContractAddressLocator _contractAddressLocator) SGAWalletsTradingLimiter(_contractAddressLocator, _BuyWalletsTradingDataSource_) public {}

        function getOverrideTradeLimitAndClass(address _wallet) public view returns (uint256, uint256){
        return getAuthorizationDataSource().getBuyTradeLimitAndClass(_wallet);

    }

        function getTradeLimit(uint256 _tradeClassId) public view returns (uint256){
        return getTradingClasses().getBuyLimit(_tradeClassId);
    }
}