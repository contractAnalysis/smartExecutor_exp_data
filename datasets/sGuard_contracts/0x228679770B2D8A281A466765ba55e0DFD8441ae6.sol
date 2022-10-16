pragma solidity ^0.5.7;
pragma experimental ABIEncoderV2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0)
            return 0;
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


contract ERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 internal _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _allowed[msg.sender][to] = _allowed[msg.sender][to].sub(value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

}

interface ITokenizedCDP {
    function debt() external returns(uint256);
    function migrate() external;
}

library Account {
    enum Status {Normal, Liquid, Vapor}
    struct Info {
        address owner; 
        uint256 number; 
    }
    struct Storage {
        mapping(uint256 => Types.Par) balances; 
        Status status;
    }
}


library Actions {
    enum ActionType {
        Deposit, 
        Withdraw, 
        Transfer, 
        Buy, 
        Sell, 
        Trade, 
        Liquidate, 
        Vaporize, 
        Call 
    }

    enum AccountLayout {OnePrimary, TwoPrimary, PrimaryAndSecondary}

    enum MarketLayout {ZeroMarkets, OneMarket, TwoMarkets}

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct DepositArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address from;
    }

    struct WithdrawArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address to;
    }

    struct TransferArgs {
        Types.AssetAmount amount;
        Account.Info accountOne;
        Account.Info accountTwo;
        uint256 market;
    }

    struct BuyArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 makerMarket;
        uint256 takerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    struct SellArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 takerMarket;
        uint256 makerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    struct TradeArgs {
        Types.AssetAmount amount;
        Account.Info takerAccount;
        Account.Info makerAccount;
        uint256 inputMarket;
        uint256 outputMarket;
        address autoTrader;
        bytes tradeData;
    }

    struct LiquidateArgs {
        Types.AssetAmount amount;
        Account.Info solidAccount;
        Account.Info liquidAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    struct VaporizeArgs {
        Types.AssetAmount amount;
        Account.Info solidAccount;
        Account.Info vaporAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    struct CallArgs {
        Account.Info account;
        address callee;
        bytes data;
    }
}


library Decimal {
    struct D256 {
        uint256 value;
    }
}


library Interest {
    struct Rate {
        uint256 value;
    }

    struct Index {
        uint96 borrow;
        uint96 supply;
        uint32 lastUpdate;
    }
}


library Monetary {
    struct Price {
        uint256 value;
    }
    struct Value {
        uint256 value;
    }
}


library Storage {
    
    struct Market {
        
        address token;
        
        Types.TotalPar totalPar;
        
        Interest.Index index;
        
        address priceOracle;
        
        address interestSetter;
        
        Decimal.D256 marginPremium;
        
        Decimal.D256 spreadPremium;
        
        bool isClosing;
    }

    
    struct RiskParams {
        
        Decimal.D256 marginRatio;
        
        Decimal.D256 liquidationSpread;
        
        Decimal.D256 earningsRate;
        
        
        Monetary.Value minBorrowedValue;
    }

    
    struct RiskLimits {
        uint64 marginRatioMax;
        uint64 liquidationSpreadMax;
        uint64 earningsRateMax;
        uint64 marginPremiumMax;
        uint64 spreadPremiumMax;
        uint128 minBorrowedValueMax;
    }

    
    struct State {
        
        uint256 numMarkets;
        
        mapping(uint256 => Market) markets;
        
        mapping(address => mapping(uint256 => Account.Storage)) accounts;
        
        mapping(address => mapping(address => bool)) operators;
        
        mapping(address => bool) globalOperators;
        
        RiskParams riskParams;
        
        RiskLimits riskLimits;
    }
}


library Types {
    enum AssetDenomination {
        Wei, 
        Par 
    }

    enum AssetReference {
        Delta, 
        Target 
    }

    struct AssetAmount {
        bool sign; 
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    struct Par {
        bool sign; 
        uint128 value;
    }

    struct Wei {
        bool sign; 
        uint256 value;
    }
}


contract ISoloMargin {
    struct OperatorArg {
        address operator;
        bool trusted;
    }

    function ownerSetSpreadPremium(
        uint256 marketId,
        Decimal.D256 memory spreadPremium
    ) public;

    function getIsGlobalOperator(address operator) public view returns (bool);

    function getMarketTokenAddress(uint256 marketId)
        public
        view
        returns (address);

    function ownerSetInterestSetter(uint256 marketId, address interestSetter)
        public;

    function getAccountValues(Account.Info memory account)
        public
        view
        returns (Monetary.Value memory, Monetary.Value memory);

    function getMarketPriceOracle(uint256 marketId)
        public
        view
        returns (address);

    function getMarketInterestSetter(uint256 marketId)
        public
        view
        returns (address);

    function getMarketSpreadPremium(uint256 marketId)
        public
        view
        returns (Decimal.D256 memory);

    function getNumMarkets() public view returns (uint256);

    function ownerWithdrawUnsupportedTokens(address token, address recipient)
        public
        returns (uint256);

    function ownerSetMinBorrowedValue(Monetary.Value memory minBorrowedValue)
        public;

    function ownerSetLiquidationSpread(Decimal.D256 memory spread) public;

    function ownerSetEarningsRate(Decimal.D256 memory earningsRate) public;

    function getIsLocalOperator(address owner, address operator)
        public
        view
        returns (bool);

    function getAccountPar(Account.Info memory account, uint256 marketId)
        public
        view
        returns (Types.Par memory);

    function ownerSetMarginPremium(
        uint256 marketId,
        Decimal.D256 memory marginPremium
    ) public;

    function getMarginRatio() public view returns (Decimal.D256 memory);

    function getMarketCurrentIndex(uint256 marketId)
        public
        view
        returns (Interest.Index memory);

    function getMarketIsClosing(uint256 marketId) public view returns (bool);

    function getRiskParams() public view returns (Storage.RiskParams memory);

    function getAccountBalances(Account.Info memory account)
        public
        view
        returns (address[] memory, Types.Par[] memory, Types.Wei[] memory);

    function renounceOwnership() public;

    function getMinBorrowedValue() public view returns (Monetary.Value memory);

    function setOperators(OperatorArg[] memory args) public;

    function getMarketPrice(uint256 marketId) public view returns (address);

    function owner() public view returns (address);

    function isOwner() public view returns (bool);

    function ownerWithdrawExcessTokens(uint256 marketId, address recipient)
        public
        returns (uint256);

    function ownerAddMarket(
        address token,
        address priceOracle,
        address interestSetter,
        Decimal.D256 memory marginPremium,
        Decimal.D256 memory spreadPremium
    ) public;

    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    ) public;

    function getMarketWithInfo(uint256 marketId)
        public
        view
        returns (
            Storage.Market memory,
            Interest.Index memory,
            Monetary.Price memory,
            Interest.Rate memory
        );

    function ownerSetMarginRatio(Decimal.D256 memory ratio) public;

    function getLiquidationSpread() public view returns (Decimal.D256 memory);

    function getAccountWei(Account.Info memory account, uint256 marketId)
        public
        view
        returns (Types.Wei memory);

    function getMarketTotalPar(uint256 marketId)
        public
        view
        returns (Types.TotalPar memory);

    function getLiquidationSpreadForPair(
        uint256 heldMarketId,
        uint256 owedMarketId
    ) public view returns (Decimal.D256 memory);

    function getNumExcessTokens(uint256 marketId)
        public
        view
        returns (Types.Wei memory);

    function getMarketCachedIndex(uint256 marketId)
        public
        view
        returns (Interest.Index memory);

    function getAccountStatus(Account.Info memory account)
        public
        view
        returns (uint8);

    function getEarningsRate() public view returns (Decimal.D256 memory);

    function ownerSetPriceOracle(uint256 marketId, address priceOracle) public;

    function getRiskLimits() public view returns (Storage.RiskLimits memory);

    function getMarket(uint256 marketId)
        public
        view
        returns (Storage.Market memory);

    function ownerSetIsClosing(uint256 marketId, bool isClosing) public;

    function ownerSetGlobalOperator(address operator, bool approved) public;

    function transferOwnership(address newOwner) public;

    function getAdjustedAccountValues(Account.Info memory account)
        public
        view
        returns (Monetary.Value memory, Monetary.Value memory);

    function getMarketMarginPremium(uint256 marketId)
        public
        view
        returns (Decimal.D256 memory);

    function getMarketInterestRate(uint256 marketId)
        public
        view
        returns (Interest.Rate memory);
}


contract ICallee {

    

    
    function callFunction(
        address sender,
        Account.Info memory accountInfo,
        bytes memory data
    )
        public;
}

contract DydxFlashloanBase {
    using SafeMath for uint256;

    

    function _getMarketIdFromTokenAddress(address _solo, address token)
        internal
        view
        returns (uint256)
    {
        ISoloMargin solo = ISoloMargin(_solo);

        uint256 numMarkets = solo.getNumMarkets();

        address curToken;
        for (uint256 i = 0; i < numMarkets; i++) {
            curToken = solo.getMarketTokenAddress(i);

            if (curToken == token) {
                return i;
            }
        }

        revert("No marketId found for provided token");
    }

    function _getRepaymentAmountInternal(uint256 amount)
        internal
        view
        returns (uint256)
    {
        
        
        return amount.add(2);
    }

    function _getAccountInfo() internal view returns (Account.Info memory) {
        return Account.Info({owner: address(this), number: 1});
    }

    function _getWithdrawAction(uint marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Withdraw,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }

    function _getCallAction(bytes memory data)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Call,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: 0
                }),
                primaryMarketId: 0,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: data
            });
    }

    function _getDepositAction(uint marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Deposit,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: true,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }
}


contract FlashMigrator is ICallee, DydxFlashloanBase {
    struct LoanInfo {
        address token;
        uint256 repayAmount;
    }

    ITokenizedCDP tCDP;
    ERC20 DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    constructor(ITokenizedCDP _tCDP) public {
        tCDP = _tCDP;
        DAI.approve(address(_tCDP), uint256(-1));
    }

    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public {
        LoanInfo memory loan = abi.decode(data, (LoanInfo));
        uint256 balOfLoanedToken = ERC20(loan.token).balanceOf(address(this));
        uint256 debt = tCDP.debt();

        require(balOfLoanedToken >= debt, "Loaned balance not enough for debt");

        tCDP.migrate();
    }

    
    function flashMigrate(address _solo)
        external
    {
        uint256 amount = tCDP.debt();
        ISoloMargin solo = ISoloMargin(_solo);

        
        uint256 marketId = _getMarketIdFromTokenAddress(_solo, address(DAI));

        
        
        uint256 repayAmount = _getRepaymentAmountInternal(amount);
        DAI.approve(_solo, repayAmount);

        
        
        
        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, amount);
        operations[1] = _getCallAction(
            
            abi.encode(LoanInfo({token: address(DAI), repayAmount: repayAmount}))
        );
        operations[2] = _getDepositAction(marketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        solo.operate(accountInfos, operations);
    }
}