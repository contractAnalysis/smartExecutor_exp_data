pragma solidity ^0.5.0;


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


interface ILoanLimitsModule {
    
    enum LoanLimitType {
        L_DEBT_AMOUNT_MIN,
        DEBT_INTEREST_MIN,
        PLEDGE_PERCENT_MIN,
        L_MIN_PLEDGE_MAX,    
        DEBT_LOAD_MAX,       
        MAX_OPEN_PROPOSALS_PER_USER,
        MIN_CANCEL_PROPOSAL_TIMEOUT
    }

    function set(LoanLimitType limit, uint256 value) external;
    function get(LoanLimitType limit) external view returns(uint256);

    function lDebtAmountMin() external view returns(uint256);
    function debtInterestMin() external view returns(uint256);
    function pledgePercentMin() external view returns(uint256);
    function lMinPledgeMax() external view returns(uint256);
    function debtLoadMax() external view returns(uint256);
    function maxOpenProposalsPerUser() external view returns(uint256);
    function minCancelProposalTimeout() external view returns(uint256);
}

contract LoanLimitsModule is Module, ILoanLimitsModule{
    
    uint256 public constant INTEREST_MULTIPLIER = 10**3;
    uint256 public constant PLEDGE_PERCENT_MULTIPLIER = 10**3;
    uint256 public constant DEBT_LOAD_MULTIPLIER = 10**3;



    
    
    
    
    
    
    
    
    
    

    uint256[7] limits;

    function initialize(address _pool) public initializer {
        Module.initialize(_pool);
        
        
        
        
        
        
        
        
        
        limits[uint256(LoanLimitType.L_DEBT_AMOUNT_MIN)] = 100*10**18;                           
        limits[uint256(LoanLimitType.DEBT_INTEREST_MIN)] = INTEREST_MULTIPLIER*10/100;           
        limits[uint256(LoanLimitType.PLEDGE_PERCENT_MIN)] = PLEDGE_PERCENT_MULTIPLIER*10/100;     
        limits[uint256(LoanLimitType.L_MIN_PLEDGE_MAX)] = 500*10**18;                           
        limits[uint256(LoanLimitType.DEBT_LOAD_MAX)] = DEBT_LOAD_MULTIPLIER*50/100;          
        limits[uint256(LoanLimitType.MAX_OPEN_PROPOSALS_PER_USER)] = 1;                           
        limits[uint256(LoanLimitType.MIN_CANCEL_PROPOSAL_TIMEOUT)] = 7*24*60*60;                   
    }

    function set(LoanLimitType limit, uint256 value) public onlyOwner {
        limits[uint256(limit)] = value;
    }

    function get(LoanLimitType limit) public view returns(uint256) {
        return limits[uint256(limit)];
    }

    function lDebtAmountMin() public view returns(uint256){
        return limits[uint256(LoanLimitType.L_DEBT_AMOUNT_MIN)];
    }     

    function debtInterestMin() public view returns(uint256){
        return limits[uint256(LoanLimitType.DEBT_INTEREST_MIN)];
    }

    function pledgePercentMin() public view returns(uint256){
        return limits[uint256(LoanLimitType.PLEDGE_PERCENT_MIN)];
    }

    function lMinPledgeMax() public view returns(uint256){
        return limits[uint256(LoanLimitType.L_MIN_PLEDGE_MAX)];
    }

    function debtLoadMax() public view returns(uint256){
        return limits[uint256(LoanLimitType.DEBT_LOAD_MAX)];
    }

    function maxOpenProposalsPerUser() public view returns(uint256){
        return limits[uint256(LoanLimitType.MAX_OPEN_PROPOSALS_PER_USER)];
    }

    function minCancelProposalTimeout() public view returns(uint256){
        return limits[uint256(LoanLimitType.MIN_CANCEL_PROPOSAL_TIMEOUT)];
    }

}