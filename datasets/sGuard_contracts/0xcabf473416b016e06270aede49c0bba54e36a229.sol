pragma solidity 0.4.25;



interface IRedButton {
        function isEnabled() external view returns (bool);
}



interface IPaymentManager {
        function getNumOfPayments() external view returns (uint256);

        function getPaymentsSum() external view returns (uint256);

        function computeDifferPayment(uint256 _ethAmount, uint256 _ethBalance) external view returns (uint256);

        function registerDifferPayment(address _wallet, uint256 _ethAmount) external;
}



interface IReserveManager {
        function getDepositParams(uint256 _balance) external view returns (address, uint256);

        function getWithdrawParams(uint256 _balance) external view returns (address, uint256);
}



interface ISGATokenManager {
        function exchangeEthForSga(address _sender, uint256 _ethAmount) external returns (uint256);

        function exchangeSgaForEth(address _sender, uint256 _sgaAmount) external returns (uint256);

        function uponTransfer(address _sender, address _to, uint256 _value) external;

        function uponTransferFrom(address _sender, address _from, address _to, uint256 _value) external;

        function uponDeposit(address _sender, uint256 _balance, uint256 _amount) external returns (address, uint256);

        function uponWithdraw(address _sender, uint256 _balance) external returns (address, uint256);

        function uponMintSgaForSgnHolders(uint256 _value) external;

        function uponTransferSgaToSgnHolder(address _to, uint256 _value) external;

        function postTransferEthToSgaHolder(address _to, uint256 _value, bool _status) external;

        function getDepositParams() external view returns (address, uint256);

        function getWithdrawParams() external view returns (address, uint256);
}



interface ITransactionManager {
        function buy(uint256 _ethAmount) external returns (uint256);

        function sell(uint256 _sgaAmount) external returns (uint256);
}



interface ISGAAuthorizationManager {
        function isAuthorizedToBuy(address _sender) external view returns (bool);

        function isAuthorizedToSell(address _sender) external view returns (bool);

        function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool);

        function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool);

        function isAuthorizedForPublicOperation(address _sender) external view returns (bool);
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



interface IWalletsTradingLimiter {
        function updateWallet(address _wallet, uint256 _value) external;
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




contract SGATokenManager is ISGATokenManager, ContractAddressLocatorHolder {
    string public constant VERSION = "1.0.0";

    using SafeMath for uint256;

    event ExchangeEthForSgaCompleted(address indexed _user, uint256 _input, uint256 _output);
    event ExchangeSgaForEthCompleted(address indexed _user, uint256 _input, uint256 _output);
    event MintSgaForSgnHoldersCompleted(uint256 _value);
    event TransferSgaToSgnHolderCompleted(address indexed _to, uint256 _value);
    event TransferEthToSgaHolderCompleted(address indexed _to, uint256 _value, bool _status);
    event DepositCompleted(address indexed _sender, uint256 _balance, uint256 _amount);
    event WithdrawCompleted(address indexed _sender, uint256 _balance, uint256 _amount);

        constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

        function getSGAAuthorizationManager() public view returns (ISGAAuthorizationManager) {
        return ISGAAuthorizationManager(getContractAddress(_ISGAAuthorizationManager_));
    }

        function getTransactionManager() public view returns (ITransactionManager) {
        return ITransactionManager(getContractAddress(_ITransactionManager_));
    }

        function getWalletsTradingLimiter() public view returns (IWalletsTradingLimiter) {
        return IWalletsTradingLimiter(getContractAddress(_WalletsTradingLimiter_SGATokenManager_));
    }

        function getReserveManager() public view returns (IReserveManager) {
        return IReserveManager(getContractAddress(_IReserveManager_));
    }

        function getPaymentManager() public view returns (IPaymentManager) {
        return IPaymentManager(getContractAddress(_IPaymentManager_));
    }

        function getRedButton() public view returns (IRedButton) {
        return IRedButton(getContractAddress(_IRedButton_));
    }

        modifier onlyIfRedButtonIsNotEnabled() {
        require(!getRedButton().isEnabled(), "red button is enabled");
        _;
    }

        function exchangeEthForSga(address _sender, uint256 _ethAmount) external only(_ISGAToken_) onlyIfRedButtonIsNotEnabled returns (uint256) {
        require(getSGAAuthorizationManager().isAuthorizedToBuy(_sender), "exchanging ETH for SGA is not authorized");
        uint256 sgaAmount = getTransactionManager().buy(_ethAmount);
        emit ExchangeEthForSgaCompleted(_sender, _ethAmount, sgaAmount);
        getWalletsTradingLimiter().updateWallet(_sender, sgaAmount);
        return sgaAmount;
    }

        function exchangeSgaForEth(address _sender, uint256 _sgaAmount) external only(_ISGAToken_) onlyIfRedButtonIsNotEnabled returns (uint256) {
        require(getSGAAuthorizationManager().isAuthorizedToSell(_sender), "exchanging SGA for ETH is not authorized");
        uint256 ethAmount = getTransactionManager().sell(_sgaAmount);
        emit ExchangeSgaForEthCompleted(_sender, _sgaAmount, ethAmount);
        IPaymentManager paymentManager = getPaymentManager();
        uint256 paymentETHAmount = paymentManager.computeDifferPayment(ethAmount, msg.sender.balance);
        if (paymentETHAmount > 0)
            paymentManager.registerDifferPayment(_sender, paymentETHAmount);
        assert(ethAmount >= paymentETHAmount);
        return ethAmount - paymentETHAmount;
    }

        function uponTransfer(address _sender, address _to, uint256 _value) external only(_ISGAToken_) {
        require(getSGAAuthorizationManager().isAuthorizedToTransfer(_sender, _to), "direct-transfer of SGA is not authorized");
        getWalletsTradingLimiter().updateWallet(_to, _value);
    }

        function uponTransferFrom(address _sender, address _from, address _to, uint256 _value) external only(_ISGAToken_) {
        require(getSGAAuthorizationManager().isAuthorizedToTransferFrom(_sender, _from, _to), "custodian-transfer of SGA is not authorized");
        getWalletsTradingLimiter().updateWallet(_to, _value);
    }

        function uponDeposit(address _sender, uint256 _balance, uint256 _amount) external only(_ISGAToken_) returns (address, uint256) {
        uint256 ethBalancePriorToDeposit = _balance.sub(_amount);
        (address wallet, uint256 recommendationAmount) = getReserveManager().getDepositParams(ethBalancePriorToDeposit);
        require(wallet == _sender, "caller is illegal");
        require(recommendationAmount > 0, "operation is not required");
        emit DepositCompleted(_sender, ethBalancePriorToDeposit, _amount);
        return (wallet, recommendationAmount);
    }

        function uponWithdraw(address _sender, uint256 _balance) external only(_ISGAToken_) returns (address, uint256) {
        require(getSGAAuthorizationManager().isAuthorizedForPublicOperation(_sender), "withdraw is not authorized");
        (address wallet, uint256 amount) = getReserveManager().getWithdrawParams(_balance);
        require(wallet != address(0), "caller is illegal");
        require(amount > 0, "operation is not required");
        emit WithdrawCompleted(_sender, _balance, amount);
        return (wallet, amount);
    }

        function uponMintSgaForSgnHolders(uint256 _value) external only(_ISGAToken_) {
        emit MintSgaForSgnHoldersCompleted(_value);
    }

        function uponTransferSgaToSgnHolder(address _to, uint256 _value) external only(_ISGAToken_) onlyIfRedButtonIsNotEnabled {
        emit TransferSgaToSgnHolderCompleted(_to, _value);
    }

        function postTransferEthToSgaHolder(address _to, uint256 _value, bool _status) external only(_ISGAToken_) {
        emit TransferEthToSgaHolderCompleted(_to, _value, _status);
    }

        function getDepositParams() external view only(_ISGAToken_) returns (address, uint256) {
        return getReserveManager().getDepositParams(msg.sender.balance);
    }

        function getWithdrawParams() external view only(_ISGAToken_) returns (address, uint256) {
        return getReserveManager().getWithdrawParams(msg.sender.balance);
    }
}