pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;


interface IRouter {
    function f(uint id, bytes32 k) external view returns (address);
    function defaultDataContract(uint id) external view returns (address);
    function bondNr() external view returns (uint);
    function setBondNr(uint _bondNr) external;

    function setDefaultContract(uint id, address data) external;
    function addField(uint id, bytes32 field, address data) external;
}



contract Context {
    
    
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

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

library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    
    
    

    
    
    

    
    
    
    
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    
    
    
    

    
    
    
    

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    
    
    
    

    
    
    
    
    

    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    
    
    
    

    
    
}




contract ERC20Burnable is Context, ERC20 {
    
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    
    
    
    
}



contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}

enum BondStage {
        
        DefaultStage,
        
        RiskRating,
        RiskRatingFail,
        
        CrowdFunding,
        CrowdFundingSuccess,
        CrowdFundingFail,
        UnRepay,
        RepaySuccess,
        Overdue,
        
        DebtClosed
    }


enum IssuerStage {
        DefaultStage,
		UnWithdrawCrowd,
        WithdrawCrowdSuccess,
		UnWithdrawPawn,
        WithdrawPawnSuccess       
    }

interface ICore {
    function initialDepositCb(uint256 id, uint256 amount) external;
    function depositCb(address who, uint256 id, uint256 amount) external returns (bool);

    function investCb(address who, uint256 id, uint256 amount) external returns (bool);

    function interestBearingPeriod(uint256 id) external returns (bool);

    function txOutCrowdCb(address who, uint256 id) external returns (uint);

    function repayCb(address who, uint256 id) external returns (uint);

    function withdrawPawnCb(address who, uint256 id) external returns (uint);

    function withdrawPrincipalCb(address who, uint id) external returns (uint);
    function withdrawPrincipalAndInterestCb(address who, uint id) external returns (uint);
    function liquidateCb(address who, uint id, uint liquidateAmount) external returns (uint, uint, uint, uint);
    function overdueCb(uint256 id) external;

    function withdrawSysProfitCb(address who, uint256 id) external returns (uint256);
    
    
    function MonitorEventCallback(address who, address bond, bytes32 funcName, bytes calldata) external;
}


interface IERC20Detailed {
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IVote {
    function take(uint256 id, address who) external returns(uint256);
    function cast(uint256 id, address who, address proposal, uint256 amount) external;
    function profit(uint256 id, address who) external returns(uint256);
}

interface IACL {
    function accessible(address sender, address to, bytes4 sig)
        external
        view
        returns (bool);
    function enableany(address from, address to) external;
    function enableboth(address from, address to) external;
}

contract BondData is ERC20Detailed, ERC20Burnable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public logic;

    constructor(
        address _ACL,
        uint256 bondId,
        string memory _bondName,
        address _issuer,
        address _collateralToken,
        address _crowdToken,
        uint256[8] memory info,
        bool[2] memory _redeemPutback 
    ) public ERC20Detailed(_bondName, _bondName, 0) {
        ACL = _ACL;
        id = bondId;
        issuer = _issuer;
        collateralToken = _collateralToken;
        crowdToken = _crowdToken;
        totalBondIssuance = info[0];
        couponRate = info[1];
        maturity = info[2];
        issueFee = info[3];
        minIssueRatio = info[4];
        financePurposeHash = info[5];
        paymentSourceHash = info[6];
        issueTimestamp = info[7];
        supportRedeem = _redeemPutback[0];
        supportPutback = _redeemPutback[1];
        par = 100;
    }

    
    address public ACL;

    modifier auth {
        IACL _ACL = IACL(ACL);
        require(
            _ACL.accessible(msg.sender, address(this), msg.sig)
        , "access unauthorized");
        _;
    }

    

    uint256 public id;
    address public issuer; 
    address public collateralToken; 
    address public crowdToken; 

    uint256 public totalBondIssuance; 
    uint256 public actualBondIssuance; 
    uint256 public mintCnt;
    uint256 public par; 
    uint256 public couponRate; 

    uint256 public maturity; 
    uint256 public issueFee; 
    uint256 public minIssueRatio; 

    uint256 public financePurposeHash;
    uint256 public paymentSourceHash;
    uint256 public issueTimestamp;
    bool public supportRedeem;
    bool public supportPutback;

    
    uint256 public partialLiquidateAmount;

    uint256 public discount; 
    uint256 public liquidateLine = 7e17;
    uint256 public gracePeriod = 1 days; 
    uint256 public depositMultiple;

    

    uint256 public voteExpired; 
    uint256 public investExpired; 
    uint256 public bondExpired; 

    

    struct Balance {
        
        
        

        
        
        
        uint256 amountGive;
        uint256 amountGet;
    }

    
    uint256 public issuerBalanceGive;
    
    mapping(address => Balance) public supplyMap; 

    

    uint256 public fee;
    uint256 public sysProfit;

    
    uint256 public liability;
    uint256 public originLiability;

    
    uint256 public bondStage;
    uint256 public issuerStage;

    function setLogics(address _logic, address _voteLogic) external auth {
        logic = _logic;
        voteLogic = _voteLogic;
    }

    function setBondParam(bytes32 k, uint256 v) external auth {
        if (k == bytes32("discount")) {
            discount = v;
            return;
        }

        if (k == bytes32("liquidateLine")) {
            liquidateLine = v;
            return;
        }

        if (k == bytes32("depositMultiple")) {
            depositMultiple = v;
            return;
        }

        if (k == bytes32("gracePeriod")) {
            gracePeriod = v;
            return;
        }

        if (k == bytes32("voteExpired")) {
            voteExpired = v;
            return;
        }

        if (k == bytes32("investExpired")) {
            investExpired = v;
            return;
        }

        if (k == bytes32("bondExpired")) {
            bondExpired = v;
            return;
        }

        if (k == bytes32("partialLiquidateAmount")) {
            partialLiquidateAmount = v;
            return;
        }
        
        if (k == bytes32("fee")) {
            fee = v;
            return;
        }
        
        if (k == bytes32("sysProfit")) {
            sysProfit = v;
            return;
        }
        
        if (k == bytes32("originLiability")) {
            originLiability = v;
            return;
        }

        if (k == bytes32("liability")) {
            liability = v;
            return;
        }

        if (k == bytes32("totalWeights")) {
            totalWeights = v;
            return;
        }

        if (k == bytes32("totalProfits")) {
            totalProfits = v;
            return;
        }

        if (k == bytes32("borrowAmountGive")) {
            issuerBalanceGive = v;
            return;
        }

        if (k == bytes32("bondStage")) {
            bondStage = v;
            return;
        }

        if (k == bytes32("issuerStage")) {
            issuerStage = v;
            return;
        }
        revert("setBondParam: invalid bytes32 key");
    }

    function setBondParamAddress(bytes32 k, address v) external auth {
        if (k == bytes32("gov")) {
            gov = v;
            return;
        }

        if (k == bytes32("top")) {
            top = v;
            return;
        }
        revert("setBondParamAddress: invalid bytes32 key");
    }


    function getSupplyAmount(address who) external view returns (uint256) {
        return supplyMap[who].amountGive;
    }

    function getBorrowAmountGive() external view returns (uint256) {
        return issuerBalanceGive;
    }



    
    uint256 public liquidateIndexes;

    
    bool public liquidating;
    function setLiquidating(bool _liquidating) external auth {
        liquidating = _liquidating;
    }

    

    address public voteLogic;
    
    struct what {
        address proposal;
        uint256 weight;
    }

    struct prwhat {
        address who;
        address proposal;
        uint256 reason;
    }

    mapping(address => uint256) public voteLedger; 
    mapping(address => what) public votes; 
    mapping(address => uint256) public weights; 
    mapping(address => uint256) public profits; 
    uint256 public totalProfits;    
    uint256 public totalWeights;
    address public gov;
    address public top;
    prwhat public pr;


    function setVotes(address who, address proposal, uint256 weight)
        external
        auth
    {
        votes[who].proposal = proposal;
        votes[who].weight = weight;
    }



    function setACL(
        address _ACL) external {
        require(msg.sender == ACL, "require ACL");
        ACL = _ACL;
    }


    function setPr(address who, address proposal, uint256 reason) external auth {
        pr.who = who;
        pr.proposal = proposal;
        pr.reason = reason;
    }

    
    function setBondParamMapping(bytes32 name, address k, uint256 v) external auth {
        if (name == bytes32("weights")) {
            weights[k] = v;
            return;
        }

        if (name == bytes32("profits")) {
            profits[k] = v;
            return;
        }
        revert("setBondParamMapping: invalid bytes32 name");
    }


    function vote(address proposal, uint256 amount) external nonReentrant {
        IVote(voteLogic).cast(id, msg.sender, proposal, amount);
        voteLedger[msg.sender] = voteLedger[msg.sender].add(amount);
        IERC20(gov).safeTransferFrom(msg.sender, address(this), amount);

        ICore(logic).MonitorEventCallback(msg.sender, address(this), "vote", abi.encodePacked(
            proposal,
            amount, 
            govTokenCash()
        ));
    }

    function take() external nonReentrant {
        uint256 amount = IVote(voteLogic).take(id, msg.sender);
        voteLedger[msg.sender] = voteLedger[msg.sender].sub(amount);
        IERC20(gov).safeTransfer(msg.sender, amount);

        ICore(logic).MonitorEventCallback(msg.sender, address(this), "take", abi.encodePacked(
            amount, 
            govTokenCash()
        ));
    }

    function profit() external nonReentrant {
        uint256 _profit = IVote(voteLogic).profit(id, msg.sender);
        IERC20(crowdToken).safeTransfer(msg.sender, _profit);

        ICore(logic).MonitorEventCallback(msg.sender, address(this), "profit", abi.encodePacked(
            _profit, 
            crowdTokenCash()
        ));
    }

    function withdrawSysProfit() external nonReentrant auth {
        uint256 _sysProfit = ICore(logic).withdrawSysProfitCb(msg.sender, id);
        require(_sysProfit <= totalFee() && (bondStage == uint(BondStage.RepaySuccess) || bondStage == uint(BondStage.DebtClosed)), "> totalFee");

        IERC20(crowdToken).safeTransfer(msg.sender, _sysProfit);
        ICore(logic).MonitorEventCallback(msg.sender, address(this), "withdrawSysProfit", abi.encodePacked(
            _sysProfit,
            crowdTokenCash()
        ));
    }

    function burnBond(address who, uint256 amount) external auth {
        _burn(who, amount);
        actualBondIssuance = actualBondIssuance.sub(amount);
    }

    function mintBond(address who, uint256 amount) external auth {
        _mint(who, amount);
        mintCnt = mintCnt.add(amount);
        actualBondIssuance = actualBondIssuance.add(amount);
    }

    function txn(address sender, address recipient, uint256 bondAmount, bytes32 name) internal {
        uint256 txAmount = bondAmount.mul(par).mul(10**uint256(crowdDecimals()));
        supplyMap[sender].amountGive = supplyMap[sender].amountGive.sub(txAmount);
        supplyMap[sender].amountGet = supplyMap[sender].amountGet.sub(bondAmount);
        supplyMap[recipient].amountGive = supplyMap[recipient].amountGive.add(txAmount);
        supplyMap[recipient].amountGet = supplyMap[recipient].amountGet.add(bondAmount);

        ICore(logic).MonitorEventCallback(sender, address(this), name, abi.encodePacked(
            recipient,
            bondAmount
        ));
    }

    function transfer(address recipient, uint256 bondAmount) 
        public override(IERC20, ERC20) nonReentrant
        returns (bool)
    {
        txn(msg.sender, recipient, bondAmount, "transfer");
        return ERC20.transfer(recipient, bondAmount);
    }

    function transferFrom(address sender, address recipient, uint256 bondAmount)
        public override(IERC20, ERC20) nonReentrant
        returns (bool)
    {
        txn(sender, recipient, bondAmount, "transferFrom");
        return ERC20.transferFrom(sender, recipient, bondAmount);
    }

    mapping(address => uint256) public depositLedger;
    function crowdDecimals() public view returns (uint8) {
        return ERC20Detailed(crowdToken).decimals();
    }

    
    function transferableAmount() public view returns (uint256) {
        uint256 baseDec = 18;
        uint256 _1 = 1 ether;
        
        return
            mintCnt.mul(par).mul((_1).sub(issueFee)).div(
                10**baseDec.sub(uint256(crowdDecimals()))
            );
    }

    function totalFee() public view returns (uint256) {
        uint256 baseDec = 18;
        uint256 delta = baseDec.sub(
            uint256(crowdDecimals())
        );
        
        return mintCnt.mul(par).mul(issueFee).div(10**delta);
    }

    
    function deposit(uint256 amount) external nonReentrant payable {
        require(ICore(logic).depositCb(msg.sender, id, amount), "deposit err");
        depositLedger[msg.sender] = depositLedger[msg.sender].add(amount);
        if (collateralToken != address(0)) {
            IERC20(collateralToken).safeTransferFrom(msg.sender, address(this), amount);
        } else {
            require(amount == msg.value && msg.value > 0, "deposit eth err");
        }

        ICore(logic).MonitorEventCallback(msg.sender, address(this), "deposit", abi.encodePacked(
            amount, 
            collateralTokenCash()
        ));
    }

    function collateralTokenCash() internal view returns (uint256) {
        return collateralToken != address(0) ? IERC20(collateralToken).balanceOf(address(this)) : address(this).balance;
    }

    function crowdTokenCash() internal view returns (uint256) {
        return IERC20(crowdToken).balanceOf(address(this));
    }

    function govTokenCash() internal view returns (uint256) {
        return IERC20(gov).balanceOf(address(this));
    }

    
    function initialDeposit(address who, uint256 amount) external auth nonReentrant payable {
        depositLedger[who] = depositLedger[who].add(amount);
        if (collateralToken != address(0)) {
            IERC20(collateralToken).safeTransferFrom(msg.sender, address(this), amount);
        } else {
	        require(amount == msg.value && msg.value > 0, "initDeposit eth err");
	    }

        ICore(logic).initialDepositCb(id, amount);

        ICore(logic).MonitorEventCallback(who, address(this), "initialDeposit", abi.encodePacked(
            amount, 
            collateralTokenCash()
        ));
    }

    function invest(uint256 amount) external nonReentrant {
        if (ICore(logic).investCb(msg.sender, id, amount)) {
            supplyMap[msg.sender].amountGive = supplyMap[msg.sender].amountGive.add(amount);
            supplyMap[msg.sender].amountGet = supplyMap[msg.sender].amountGet.add(amount.div(par.mul(10**uint256(crowdDecimals()))));

            
            IERC20(crowdToken).safeTransferFrom(msg.sender, address(this), amount);
        }

        ICore(logic).MonitorEventCallback(msg.sender, address(this), "invest", abi.encodePacked(
            amount, 
            crowdTokenCash()
        ));
    }

    function txOutCrowd() external nonReentrant {
        uint256 balance = ICore(logic).txOutCrowdCb(msg.sender, id);
        require(balance <= transferableAmount(), "exceed max tx amount");


        IERC20(crowdToken).safeTransfer(msg.sender, balance);



        ICore(logic).MonitorEventCallback(msg.sender, address(this), "txOutCrowd", abi.encodePacked(
            balance, 
            crowdTokenCash()
        ));
    }

    function overdue() external {
        ICore(logic).overdueCb(id);
    }

    function repay() external nonReentrant {
        uint repayAmount = ICore(logic).repayCb(msg.sender, id);

        IERC20(crowdToken).safeTransferFrom(msg.sender, address(this), repayAmount);

        ICore(logic).MonitorEventCallback(msg.sender, address(this), "repay", abi.encodePacked(
            repayAmount, 
            crowdTokenCash()
        ));
    }

    function withdrawPawn() external nonReentrant {
        uint amount = ICore(logic).withdrawPawnCb(msg.sender, id);
        depositLedger[msg.sender] = depositLedger[msg.sender].sub(amount);
        if (collateralToken != address(0)) {

            IERC20(collateralToken).safeTransfer(msg.sender, amount);
        } else {
            msg.sender.transfer(amount);
        }

        ICore(logic).MonitorEventCallback(msg.sender, address(this), "withdrawPawn", abi.encodePacked(
            amount, 
            collateralTokenCash()
        ));
    }

    function withdrawInvest(address who, uint amount, bytes32 name) internal {
        IERC20(crowdToken).safeTransfer(who, amount);
        ICore(logic).MonitorEventCallback(who, address(this), name, abi.encodePacked(
            amount, 
            crowdTokenCash()
        ));
    }

    function withdrawPrincipal() external nonReentrant {
        uint256 supplyGive = ICore(logic).withdrawPrincipalCb(msg.sender, id);
        supplyMap[msg.sender].amountGive = supplyMap[msg.sender].amountGet = 0;
        withdrawInvest(msg.sender, supplyGive, "withdrawPrincipal");
    }

    function withdrawPrincipalAndInterest() external nonReentrant {
        uint256 amount = ICore(logic).withdrawPrincipalAndInterestCb(msg.sender, id);
        uint256 _1 = 1 ether;
        require(amount <= supplyMap[msg.sender].amountGive.mul(_1.add(couponRate)).div(_1) && supplyMap[msg.sender].amountGive != 0, "exceed max invest amount or not an invester");
        supplyMap[msg.sender].amountGive = supplyMap[msg.sender].amountGet = 0;

        withdrawInvest(msg.sender, amount, "withdrawPrincipalAndInterest");
    }

    
    function liquidate(uint liquidateAmount) external nonReentrant {
        (uint y1, uint x1, uint y, uint x) = ICore(logic).liquidateCb(msg.sender, id, liquidateAmount);

        if (collateralToken != address(0)) {

            IERC20(collateralToken).safeTransfer(msg.sender, x1);
        } else {
            msg.sender.transfer(x1);
        }



        IERC20(crowdToken).safeTransferFrom(msg.sender, address(this), y1);

        ICore(logic).MonitorEventCallback(msg.sender, address(this), "liquidate", abi.encodePacked(
            liquidateIndexes, 
            x1, 
            y1,
            x,
            y,
            now, 
            collateralTokenCash(),
            crowdTokenCash()
        ));
        liquidateIndexes = liquidateIndexes.add(1);
    }
}


interface INameGen {
    function gen(address token, uint id) external view returns (string memory);
}

interface IVerify {
    function verify(address[2] calldata, uint256[8] calldata) external view returns (bool);
}

contract BondFactory {
    using SafeERC20 for IERC20;

    address public router;
    address public verify;
    address public vote;
    address public core;
    address public nameGen;
    address public ACL;

    constructor(
        address _ACL,
        address _router,
        address _verify,
        address _vote,
        address _core,
	    address _nameGen
    ) public {
        ACL = _ACL;
        router = _router;
        verify = _verify;
        vote = _vote;
        core = _core;
        nameGen = _nameGen;
    }

    function setACL(address _ACL) external {
        require(msg.sender == ACL, "require ACL");
        ACL = _ACL;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    function issue(
        address[2] calldata tokens,
        uint256 _minCollateralAmount,
        uint256[8] calldata info,
        bool[2] calldata _redeemPutback
    ) external payable returns (uint256)  {
        require(IVerify(verify).verify(tokens, info), "verify error");

        uint256 nr = IRouter(router).bondNr();
        string memory bondName = INameGen(nameGen).gen(tokens[0], nr);

        BondData b = new BondData(
            ACL,
            nr,
            bondName,
            msg.sender,
            tokens[0],
            tokens[1],
            info,
            _redeemPutback
        );
        IRouter(router).setDefaultContract(nr, address(b));
        IRouter(router).setBondNr(nr + 1);

        IACL(ACL).enableany(address(this), address(b));
        IACL(ACL).enableboth(core, address(b));
        IACL(ACL).enableboth(vote, address(b));

        b.setLogics(core, vote);

        if (tokens[0] == address(0)) {
            b.initialDeposit.value(msg.value)(msg.sender, msg.value);
	        require(msg.value == _minCollateralAmount, "invalid issue eth amount");
        } else {
            
            IERC20(tokens[0]).safeTransferFrom(msg.sender, address(this), _minCollateralAmount);
            IERC20(tokens[0]).safeApprove(address(b), _minCollateralAmount);
            b.initialDeposit(msg.sender, _minCollateralAmount);
        }

        return nr;
    }
}