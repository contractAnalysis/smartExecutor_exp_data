pragma solidity ^0.5.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IAccessModule {
    enum Operation {
        
        Deposit,
        Withdraw,
        
        CreateDebtProposal,
        AddPledge,
        WithdrawPledge,
        CancelDebtProposal,
        ExecuteDebtProposal,
        Repay,
        ExecuteDebtDefault,
        WithdrawUnlockedPledge
    }
    
    
    function isOperationAllowed(Operation operation, address sender) external view returns(bool);
}


interface IFundsModule {
    event Status(uint256 lBalance, uint256 lDebts, uint256 lProposals, uint256 pEnterPrice, uint256 pExitPrice);

    
    function depositLTokens(address from, uint256 amount) external;
    
    function withdrawLTokens(address to, uint256 amount) external;

    
    function withdrawLTokens(address to, uint256 amount, uint256 poolFee) external;

    
    function depositPTokens(address from, uint256 amount) external;

    
    function withdrawPTokens(address to, uint256 amount) external;

    
    function mintPTokens(address to, uint256 amount) external;

    
    function distributePTokens(uint256 amount) external;

    
    function burnPTokens(address from, uint256 amount) external;

    function lockPTokens(address[] calldata from, uint256[] calldata amount) external;

    function mintAndLockPTokens(uint256 amount) external;

    function unlockAndWithdrawPTokens(address to, uint256 amount) external;

    function burnLockedPTokens(uint256 amount) external;

    
    function calculatePoolEnter(uint256 lAmount) external view returns(uint256);

    
    function calculatePoolEnter(uint256 lAmount, uint256 liquidityCorrection) external view returns(uint256);
    
    
    function calculatePoolExit(uint256 lAmount) external view returns(uint256);

    
    function calculatePoolExitInverse(uint256 pAmount) external view returns(uint256, uint256, uint256);

    
    function calculatePoolExitWithFee(uint256 lAmount) external view returns(uint256);

    
    function calculatePoolExitWithFee(uint256 lAmount, uint256 liquidityCorrection) external view returns(uint256);

    
    function lBalance() external view returns(uint256);

    
    function pBalanceOf(address account) external view returns(uint256);

}


interface ILoanModule {
    event Repay(address indexed sender, uint256 debt, uint256 lDebtLeft, uint256 lFullPaymentAmount, uint256 lInterestPaid, uint256 pInterestPaid, uint256 newlastPayment);
    event UnlockedPledgeWithdraw(address indexed sender, address indexed borrower, uint256 proposal, uint256 debt, uint256 pAmount);
    event DebtDefaultExecuted(address indexed borrower, uint256 debt, uint256 pBurned);

    
    function createDebt(address borrower, uint256 proposal, uint256 lAmount) external returns(uint256);

    
    function repay(uint256 debt, uint256 lAmount) external;

    function repayPTK(uint256 debt, uint256 pAmount, uint256 lAmountMin) external;

    function repayAllInterest(address borrower) external;

    
    function executeDebtDefault(address borrower, uint256 debt) external;

    
    function withdrawUnlockedPledge(address borrower, uint256 debt) external;

    
    function isDebtDefaultTimeReached(address borrower, uint256 debt) external view returns(bool);

    
    function hasActiveDebts(address borrower) external view returns(bool);

    
    function totalLDebts() external view returns(uint256);

}


interface ILiquidityModule {

    event Deposit(address indexed sender, uint256 lAmount, uint256 pAmount);
    event Withdraw(address indexed sender, uint256 lAmountTotal, uint256 lAmountUser, uint256 pAmount);

     
    function deposit(uint256 lAmount, uint256 pAmountMin) external;

    
    function withdraw(uint256 pAmount, uint256 lAmountMin) external;

    
    function withdrawForRepay(address borrower, uint256 pAmount) external;
}


contract Initializable {

  
  bool private initialized;

  
  bool private initializing;

  
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
    
    
    
    
    
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}


contract Context is Initializable {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


contract Base is Initializable, Context, Ownable {
    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {
        Ownable.initialize(_msgSender());
    }

}


contract ModuleNames {
    
    string public constant MODULE_ACCESS            = "access";
    string public constant MODULE_PTOKEN            = "ptoken";
    string public constant MODULE_CURVE             = "curve";
    string public constant MODULE_FUNDS             = "funds";
    string public constant MODULE_LIQUIDITY         = "liquidity";
    string public constant MODULE_LOAN              = "loan";
    string public constant MODULE_LOAN_LIMTS        = "loan_limits";
    string public constant MODULE_LOAN_PROPOSALS    = "loan_proposals";

    
    string public constant MODULE_LTOKEN            = "ltoken";
}


contract Module is Base, ModuleNames {
    event PoolAddressChanged(address newPool);
    address public pool;

    function initialize(address _pool) public initializer {
        Base.initialize();
        setPool(_pool);
    }

    function setPool(address _pool) public onlyOwner {
        require(_pool != ZERO_ADDRESS, "Module: pool address can't be zero");
        pool = _pool;
        emit PoolAddressChanged(_pool);        
    }

    function getModuleAddress(string memory module) public view returns(address){
        require(pool != ZERO_ADDRESS, "Module: no pool");
        (bool success, bytes memory result) = pool.staticcall(abi.encodeWithSignature("get(string)", module));
        
        
        if (!success) assembly {
            revert(add(result, 32), result)
        }

        address moduleAddress = abi.decode(result, (address));
        require(moduleAddress != ZERO_ADDRESS, "Module: requested module not found");
        return moduleAddress;
    }

}

contract LiquidityModule is Module, ILiquidityModule {
    struct LiquidityLimits {
        uint256 lDepositMin;     
        uint256 pWithdrawMin;    
    }

    LiquidityLimits public limits;

    modifier operationAllowed(IAccessModule.Operation operation) {
        IAccessModule am = IAccessModule(getModuleAddress(MODULE_ACCESS));
        require(am.isOperationAllowed(operation, _msgSender()), "LiquidityModule: operation not allowed");
        _;
    }

    function initialize(address _pool) public initializer {
        Module.initialize(_pool);
        setLimits(10*10**18, 0);    
    }

     
    function deposit(uint256 lAmount, uint256 pAmountMin) public operationAllowed(IAccessModule.Operation.Deposit) {
        require(lAmount > 0, "LiquidityModule: lAmount should not be 0");
        require(lAmount >= limits.lDepositMin, "LiquidityModule: amount should be >= lDepositMin");
        uint pAmount = fundsModule().calculatePoolEnter(lAmount);
        require(pAmount >= pAmountMin, "LiquidityModule: Minimal amount is too high");
        fundsModule().depositLTokens(_msgSender(), lAmount);
        fundsModule().mintPTokens(_msgSender(), pAmount);
        emit Deposit(_msgSender(), lAmount, pAmount);
    }

    
    function withdraw(uint256 pAmount, uint256 lAmountMin) public operationAllowed(IAccessModule.Operation.Withdraw) {
        require(pAmount > 0, "LiquidityModule: pAmount should not be 0");
        require(pAmount >= limits.pWithdrawMin, "LiquidityModule: amount should be >= pWithdrawMin");
        loanModule().repayAllInterest(_msgSender());
        (uint256 lAmountT, uint256 lAmountU, uint256 lAmountP) = fundsModule().calculatePoolExitInverse(pAmount);
        require(lAmountU >= lAmountMin, "LiquidityModule: Minimal amount is too high");
        uint256 availableLiquidity = fundsModule().lBalance();
        require(lAmountT <= availableLiquidity, "LiquidityModule: not enough liquidity");
        fundsModule().burnPTokens(_msgSender(), pAmount);
        fundsModule().withdrawLTokens(_msgSender(), lAmountU, lAmountP);
        emit Withdraw(_msgSender(), lAmountT, lAmountU, pAmount);
    }

    
    function withdrawForRepay(address borrower, uint256 pAmount) public {
        require(_msgSender() == getModuleAddress(MODULE_LOAN), "LiquidityModule: call only allowed from LoanModule");
        require(pAmount > 0, "LiquidityModule: pAmount should not be 0");
        
        (uint256 lAmountT, uint256 lAmountU, uint256 lAmountP) = fundsModule().calculatePoolExitInverse(pAmount);
        uint256 availableLiquidity = fundsModule().lBalance();
        require(lAmountP <= availableLiquidity, "LiquidityModule: not enough liquidity");
        fundsModule().burnPTokens(borrower, pAmount);           
        fundsModule().withdrawLTokens(borrower, 0, lAmountP);   
        emit Withdraw(borrower, lAmountT, lAmountU, pAmount);
    }

    function setLimits(uint256 lDepositMin, uint256 pWithdrawMin) public onlyOwner {
        limits.lDepositMin = lDepositMin;
        limits.pWithdrawMin = pWithdrawMin;
    }

    function fundsModule() internal view returns(IFundsModule) {
        return IFundsModule(getModuleAddress(MODULE_FUNDS));
    }

    function loanModule() internal view returns(ILoanModule) {
        return ILoanModule(getModuleAddress(MODULE_LOAN));
    }
}