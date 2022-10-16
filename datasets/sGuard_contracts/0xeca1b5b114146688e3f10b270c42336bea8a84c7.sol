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


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



interface ICurveModule {
    
    function calculateEnter(uint256 liquidAssets, uint256 debtCommitments, uint256 lAmount) external view returns (uint256);

    
    function calculateExit(uint256 liquidAssets, uint256 lAmount) external view returns (uint256);

    
    function calculateExitWithFee(uint256 liquidAssets, uint256 lAmount) external view returns(uint256);

    
    function calculateExitInverseWithFee(uint256 liquidAssets, uint256 pAmount) external view returns (uint256 withdraw, uint256 withdrawU, uint256 withdrawP);

    
    function calculateExitFee(uint256 lAmount) external view returns(uint256);
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


interface ILoanProposalsModule {
    event DebtProposalCreated(address indexed sender, uint256 proposal, uint256 lAmount, uint256 interest, bytes32 descriptionHash);
    event PledgeAdded(address indexed sender, address indexed borrower, uint256 proposal, uint256 lAmount, uint256 pAmount);
    event PledgeWithdrawn(address indexed sender, address indexed borrower, uint256 proposal, uint256 lAmount, uint256 pAmount);
    event DebtProposalCanceled(address indexed sender, uint256 proposal);
    event DebtProposalExecuted(address indexed sender, uint256 proposal, uint256 debt, uint256 lAmount);

    
    function createDebtProposal(uint256 debtLAmount, uint256 interest, uint256 pAmountMax, bytes32 descriptionHash) external returns(uint256);

    
    function addPledge(address borrower, uint256 proposal, uint256 pAmount, uint256 lAmountMin) external;

    
    function withdrawPledge(address borrower, uint256 proposal, uint256 pAmount) external;

    
    function executeDebtProposal(uint256 proposal) external returns(uint256);


    
    function totalLProposals() external view returns(uint256);

    
    function getProposalAndPledgeInfo(address borrower, uint256 proposal, address supporter) external view
    returns(uint256 lAmount, uint256 lCovered, uint256 pCollected, uint256 interest, uint256 lPledge, uint256 pPledge);

    
    function getProposalInterestRate(address borrower, uint256 proposal) external view returns(uint256);
}


interface IPToken {
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    function mint(address account, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;

    
    function distribute(uint256 amount) external;
    function claimDistributions(address account) external returns(uint256);
    function claimDistributions(address account, uint256 lastDistribution) external returns(uint256);
    function claimDistributions(address[] calldata accounts) external;
    function claimDistributions(address[] calldata accounts, uint256 toDistribution) external;
    function fullBalanceOf(address account) external view returns(uint256);
    function calculateDistributedAmount(uint256 startDistribution, uint256 nextDistribution, uint256 initialBalance) external view returns(uint256);
    function nextDistribution() external view returns(uint256);

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


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract FundsOperatorRole is Initializable, Context {
    using Roles for Roles.Role;

    event FundsOperatorAdded(address indexed account);
    event FundsOperatorRemoved(address indexed account);

    Roles.Role private _operators;

    function initialize(address sender) public initializer {
        if (!isFundsOperator(sender)) {
            _addFundsOperator(sender);
        }
    }

    modifier onlyFundsOperator() {
        require(isFundsOperator(_msgSender()), "FundsOperatorRole: caller does not have the FundsOperator role");
        _;
    }

    function addFundsOperator(address account) public onlyFundsOperator {
        _addFundsOperator(account);
    }

    function renounceFundsOperator() public {
        _removeFundsOperator(_msgSender());
    }

    function isFundsOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function _addFundsOperator(address account) internal {
        _operators.add(account);
        emit FundsOperatorAdded(account);
    }

    function _removeFundsOperator(address account) internal {
        _operators.remove(account);
        emit FundsOperatorRemoved(account);
    }

}

contract FundsModule is Module, IFundsModule, FundsOperatorRole {
    using SafeMath for uint256;
    uint256 private constant STATUS_PRICE_AMOUNT = 10**18;  

    uint256 public lBalance;    
    mapping(address=>uint256) pBalances;    

    function initialize(address _pool) public initializer {
        Module.initialize(_pool);
        FundsOperatorRole.initialize(_msgSender());
        
    }

    
    function depositLTokens(address from, uint256 amount) public onlyFundsOperator {
        lBalance = lBalance.add(amount);
        require(lToken().transferFrom(from, address(this), amount), "FundsModule: deposit failed");
        emitStatus();
    }

    
    function withdrawLTokens(address to, uint256 amount) public onlyFundsOperator {
        withdrawLTokens(to, amount, 0);
    }

    
    function withdrawLTokens(address to, uint256 amount, uint256 poolFee) public onlyFundsOperator {
        lBalance = lBalance.sub(amount);
        if (amount > 0) { 
            require(lToken().transfer(to, amount), "FundsModule: withdraw failed");
        }
        if (poolFee > 0) {
            lBalance = lBalance.sub(poolFee);
            require(lToken().transfer(owner(), poolFee), "FundsModule: fee transfer failed");
        }
        emitStatus();
    }

    
    function depositPTokens(address from, uint256 amount) public onlyFundsOperator {
        require(pToken().transferFrom(from, address(this), amount), "FundsModule: deposit failed"); 
        pBalances[from] = pBalances[from].add(amount);
    }

    
    function withdrawPTokens(address to, uint256 amount) public onlyFundsOperator {
        require(pToken().transfer(to, amount), "FundsModule: withdraw failed");  
        pBalances[to] = pBalances[to].sub(amount);
    }

    
    function mintPTokens(address to, uint256 amount) public onlyFundsOperator {
        assert(to != address(this)); 
        require(pToken().mint(to, amount), "FundsModule: mint failed");
    }

    function distributePTokens(uint256 amount) public onlyFundsOperator {
        pToken().distribute(amount);    
    }
    
    
    function burnPTokens(address from, uint256 amount) public onlyFundsOperator {
        assert(from != address(this)); 
        pToken().burnFrom(from, amount); 
    }

    
    function lockPTokens(address[] calldata from, uint256[] calldata amount) external onlyFundsOperator {
        require(from.length == amount.length, "FundsModule: from and amount length should match");
        
        pToken().claimDistributions(from);
        uint256 lockAmount;
        for (uint256 i=0; i < from.length; i++) {
            address account = from[i];
            pBalances[account] = pBalances[account].sub(amount[i]);                
            lockAmount = lockAmount.add(amount[i]);
        }
        pBalances[address(this)] = pBalances[address(this)].add(lockAmount);
    }

    function mintAndLockPTokens(uint256 amount) public onlyFundsOperator {
        require(pToken().mint(address(this), amount), "FundsModule: mint failed"); 
        pBalances[address(this)] = pBalances[address(this)].add(amount);
    }

    function unlockAndWithdrawPTokens(address to, uint256 amount) public onlyFundsOperator {
        require(pToken().transfer(to, amount), "FundsModule: withdraw failed"); 
        pBalances[address(this)] = pBalances[address(this)].sub(amount);
    }

    function burnLockedPTokens(uint256 amount) public onlyFundsOperator {
        pToken().burn(amount); 
        pBalances[address(this)] = pBalances[address(this)].sub(amount);
    }

    
    function refundLTokens(address to, uint256 amount) public onlyFundsOperator {
        uint256 realLBalance = lToken().balanceOf(address(this));
        require(realLBalance.sub(amount) >= lBalance, "FundsModule: not enough tokens to refund");
        require(lToken().transfer(to, amount), "FundsModule: refund failed");
    }

    
    function pBalanceOf(address account) public view returns(uint256){
        return pBalances[account];
    }

    
    function calculatePoolEnter(uint256 lAmount) public view returns(uint256) {
        uint256 lDebts = loanModule().totalLDebts();
        return curveModule().calculateEnter(lBalance, lDebts, lAmount);
    }

    
    function calculatePoolEnter(uint256 lAmount, uint256 liquidityCorrection) public view returns(uint256) {
        uint256 lDebts = loanModule().totalLDebts();
        return curveModule().calculateEnter(lBalance.sub(liquidityCorrection), lDebts, lAmount);
    }

    
    function calculatePoolExit(uint256 lAmount) public view returns(uint256) {
        uint256 lProposals = loanProposalsModule().totalLProposals();
        return curveModule().calculateExit(lBalance.sub(lProposals), lAmount);
    }

    
    function calculatePoolExitWithFee(uint256 lAmount) public view returns(uint256) {
        uint256 lProposals = loanProposalsModule().totalLProposals();
        return curveModule().calculateExitWithFee(lBalance.sub(lProposals), lAmount);
    }

    
    function calculatePoolExitWithFee(uint256 lAmount, uint256 liquidityCorrection) public view returns(uint256) {
        uint256 lProposals = loanProposalsModule().totalLProposals();
        return curveModule().calculateExitWithFee(lBalance.sub(liquidityCorrection).sub(lProposals), lAmount);
    }

    
    function calculatePoolExitInverse(uint256 pAmount) public view returns(uint256, uint256, uint256) {
        uint256 lProposals = loanProposalsModule().totalLProposals();
        return curveModule().calculateExitInverseWithFee(lBalance.sub(lProposals), pAmount);
    }

    function emitStatus() private {
        uint256 lDebts = loanModule().totalLDebts();
        uint256 lProposals = loanProposalsModule().totalLProposals();
        uint256 pEnterPrice = curveModule().calculateEnter(lBalance, lDebts, STATUS_PRICE_AMOUNT);
        uint256 pExitPrice; 
        if (lBalance >= STATUS_PRICE_AMOUNT) {
            pExitPrice = curveModule().calculateExit(lBalance.sub(lProposals), STATUS_PRICE_AMOUNT);
        } else {
            pExitPrice = 0;
        }
        emit Status(lBalance, lDebts, lProposals, pEnterPrice, pExitPrice);
    }

    function curveModule() private view returns(ICurveModule) {
        return ICurveModule(getModuleAddress(MODULE_CURVE));
    }
    
    function loanModule() private view returns(ILoanModule) {
        return ILoanModule(getModuleAddress(MODULE_LOAN));
    }

    function loanProposalsModule() private view returns(ILoanProposalsModule) {
        return ILoanProposalsModule(getModuleAddress(MODULE_LOAN_PROPOSALS));
    }

    function pToken() private view returns(IPToken){
        return IPToken(getModuleAddress(MODULE_PTOKEN));
    }
    
    function lToken() private view returns(IERC20){
        return IERC20(getModuleAddress(MODULE_LTOKEN));
    }

}