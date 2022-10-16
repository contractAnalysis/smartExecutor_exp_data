pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


contract EIP20 is ERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
}

contract WETHInterface is EIP20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}


library SafeMath {

  
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  
  function divCeil(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
      return 0;
    }

    return ((_a - 1) / _b) + 1;
  }

  
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


contract Ownable {
  address public owner;


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

  
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract ReentrancyGuard {

  
  
  uint256 internal constant REENTRANCY_GUARD_FREE = 1;

  
  uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;

  
  uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;

  
  modifier nonReentrant() {
    require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");
    reentrancyLock = REENTRANCY_GUARD_LOCKED;
    _;
    reentrancyLock = REENTRANCY_GUARD_FREE;
  }

}

contract LoanTokenization is ReentrancyGuard, Ownable {

    uint256 internal constant MAX_UINT = 2**256 - 1;

    string public name;
    string public symbol;
    uint8 public decimals;

    address public bZxContract;
    address public bZxVault;
    address public bZxOracle;
    address public wethContract;

    address public loanTokenAddress;

    
    mapping (address => uint256) internal checkpointPrices_;
}

contract LoanTokenStorage is LoanTokenization {

    struct ListIndex {
        uint256 index;
        bool isSet;
    }

    struct LoanData {
        bytes32 loanOrderHash;
        uint256 leverageAmount;
        uint256 initialMarginAmount;
        uint256 maintenanceMarginAmount;
        uint256 maxDurationUnixTimestampSec;
        uint256 index;
        uint256 marginPremiumAmount;
        address collateralTokenAddress;
    }

    struct TokenReserves {
        address lender;
        uint256 amount;
    }

    event Borrow(
        address indexed borrower,
        uint256 borrowAmount,
        uint256 interestRate,
        address collateralTokenAddress,
        address tradeTokenToFillAddress,
        bool withdrawOnOpen
    );

    event Repay(
        bytes32 indexed loanOrderHash,
        address indexed borrower,
        address closer,
        uint256 amount,
        bool isLiquidation
    );

    event Claim(
        address indexed claimant,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 remainingTokenAmount,
        uint256 price
    );

    bool internal isInitialized_ = false;

    address public tokenizedRegistry;

    uint256 public baseRate = 1000000000000000000; 
    uint256 public rateMultiplier = 18750000000000000000; 

    
    

    
    uint256 public spreadMultiplier;

    mapping (uint256 => bytes32) public loanOrderHashes; 
    mapping (bytes32 => LoanData) public loanOrderData; 
    uint256[] public leverageList;

    TokenReserves[] public burntTokenReserveList; 
    mapping (address => ListIndex) public burntTokenReserveListIndex; 
    uint256 public burntTokenReserved; 
    address internal nextOwedLender_;

    uint256 public totalAssetBorrow; 

    uint256 public checkpointSupply;

    uint256 internal lastSettleTime_;

    uint256 public initialPrice;
}

contract AdvancedTokenStorage is LoanTokenStorage {
    using SafeMath for uint256;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Mint(
        address indexed minter,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 price
    );
    event Burn(
        address indexed burner,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 price
    );

    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 internal totalSupply_;

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupply_;
    }

    function balanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
}

contract AdvancedToken is AdvancedTokenStorage {
    using SafeMath for uint256;

    function approve(
        address _spender,
        uint256 _value)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _mint(
        address _to,
        uint256 _tokenAmount,
        uint256 _assetAmount,
        uint256 _price)
        internal
    {
        require(_to != address(0), "15");
        totalSupply_ = totalSupply_.add(_tokenAmount);
        balances[_to] = balances[_to].add(_tokenAmount);

        emit Mint(_to, _tokenAmount, _assetAmount, _price);
        emit Transfer(address(0), _to, _tokenAmount);
    }

    function _burn(
        address _who,
        uint256 _tokenAmount,
        uint256 _assetAmount,
        uint256 _price)
        internal
    {
        require(_tokenAmount <= balances[_who], "16");
        
        

        balances[_who] = balances[_who].sub(_tokenAmount);
        if (balances[_who] <= 10) { 
            _tokenAmount = _tokenAmount.add(balances[_who]);
            balances[_who] = 0;
        }

        totalSupply_ = totalSupply_.sub(_tokenAmount);

        emit Burn(_who, _tokenAmount, _assetAmount, _price);
        emit Transfer(_who, address(0), _tokenAmount);
    }
}

contract BZxObjects {

    struct LoanOrder {
        address loanTokenAddress;
        address interestTokenAddress;
        address collateralTokenAddress;
        address oracleAddress;
        uint256 loanTokenAmount;
        uint256 interestAmount;
        uint256 initialMarginAmount;
        uint256 maintenanceMarginAmount;
        uint256 maxDurationUnixTimestampSec;
        bytes32 loanOrderHash;
    }

    struct LoanPosition {
        address trader;
        address collateralTokenAddressFilled;
        address positionTokenAddressFilled;
        uint256 loanTokenAmountFilled;
        uint256 loanTokenAmountUsed;
        uint256 collateralTokenAmountFilled;
        uint256 positionTokenAmountFilled;
        uint256 loanStartUnixTimestampSec;
        uint256 loanEndUnixTimestampSec;
        bool active;
        uint256 positionId;
    }
}

contract OracleNotifierInterface {

    function closeLoanNotifier(
        BZxObjects.LoanOrder memory loanOrder,
        BZxObjects.LoanPosition memory loanPosition,
        address loanCloser,
        uint256 closeAmount,
        bool isLiquidation)
        public
        returns (bool);
}

interface IBZx {
    function takeOrderFromiToken(
        bytes32 loanOrderHash, 
        address[4] calldata sentAddresses,
            
            
            
            
        uint256[7] calldata sentAmounts,
            
            
            
            
            
            
            
        bytes calldata loanDataBytes)
        external
        payable
        returns (uint256);

    function payInterestForOracle(
        address oracleAddress,
        address interestTokenAddress)
        external
        returns (uint256);

    function forgiveLoan(
        uint256 forgivenAmount)
        external;

    function getLenderInterestForOracle(
        address lender,
        address oracleAddress,
        address interestTokenAddress)
        external
        view
        returns (
            uint256 interestPaid,
            uint256 interestPaidDate,
            uint256 interestOwedPerDay,
            uint256 interestUnPaid);

    function oracleAddresses(
        address oracleAddress)
        external
        view
        returns (address);

    function getRequiredCollateral(
        address loanTokenAddress,
        address collateralTokenAddress,
        address oracleAddress,
        uint256 newLoanAmount,
        uint256 marginAmount)
        external
        view
        returns (uint256 collateralTokenAmount);

    function getBorrowAmount(
        address loanTokenAddress,
        address collateralTokenAddress,
        address oracleAddress,
        uint256 collateralTokenAmount,
        uint256 marginAmount)
        external
        view
        returns (uint256 borrowAmount);
}

interface IBZxOracle {
    function getTradeData(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount)
        external
        view
        returns (
            uint256 sourceToDestRate,
            uint256 sourceToDestPrecision,
            uint256 destTokenAmount
        );
}

interface IWethHelper {
    function claimEther(
        address receiver,
        uint256 amount)
        external
        returns (uint256 claimAmount);
}

contract LoanTokenLogicV4 is AdvancedToken, OracleNotifierInterface {
    using SafeMath for uint256;

    address internal target_;

    modifier onlyOracle() {
        require(msg.sender == IBZx(bZxContract).oracleAddresses(bZxOracle), "1");
        _;
    }


    function()
        external
    {}


    

    function mintWithEther(
        address receiver)
        external
        payable
        nonReentrant
        returns (uint256 mintAmount)
    {
        require(loanTokenAddress == wethContract, "2");
        return _mintToken(
            receiver,
            msg.value
        );
    }

    function mint(
        address receiver,
        uint256 depositAmount)
        external
        nonReentrant
        returns (uint256 mintAmount)
    {
        return _mintToken(
            receiver,
            depositAmount
        );
    }

    function burnToEther(
        address receiver,
        uint256 burnAmount)
        external
        nonReentrant
        returns (uint256 loanAmountPaid)
    {
        require(loanTokenAddress == wethContract, "3");
        loanAmountPaid = _burnToken(
            burnAmount
        );

        if (loanAmountPaid != 0) {
            IWethHelper wethHelper = IWethHelper(0x3b5bDCCDFA2a0a1911984F203C19628EeB6036e0);

            _transfer(loanTokenAddress, address(wethHelper), loanAmountPaid, "4");
            require(loanAmountPaid == wethHelper.claimEther(receiver, loanAmountPaid), "4");
        }
    }

    function burn(
        address receiver,
        uint256 burnAmount)
        external
        nonReentrant
        returns (uint256 loanAmountPaid)
    {
        loanAmountPaid = _burnToken(
            burnAmount
        );

        if (loanAmountPaid != 0) {
            _transfer(loanTokenAddress, receiver, loanAmountPaid, "5");
        }
    }

    function burnWithLoanPayback(
        uint256 burnAmount)
        public
        onlyOwner
    {
        require(burnAmount != 0, "19");

        if (burnAmount > balanceOf(msg.sender)) {
            burnAmount = balanceOf(msg.sender);
        }

        _settleInterest();

        uint256 currentPrice = _tokenPrice(_totalAssetSupply(0));

        uint256 ethLoanAmount = burnAmount.mul(currentPrice).div(10**18);

        IBZx(bZxContract).forgiveLoan(ethLoanAmount);

        _burn(msg.sender, burnAmount, ethLoanAmount, currentPrice);

        if (balances[msg.sender] != 0) {
            checkpointPrices_[msg.sender] = currentPrice;
        } else {
            checkpointPrices_[msg.sender] = 0;
        }
    }

    function borrowTokenFromDeposit(
        uint256 borrowAmount,
        uint256 leverageAmount,
        uint256 initialLoanDuration,    
        uint256 collateralTokenSent,    
        address borrower,
        address receiver,
        address collateralTokenAddress, 
        bytes memory ) 
        public
        payable
        returns (bytes32 loanOrderHash)
    {
        require(tx.origin == owner, "unauthorized");

        require(
            ((msg.value == 0 && collateralTokenAddress != address(0) && collateralTokenSent != 0) ||
            (msg.value != 0 && (collateralTokenAddress == address(0) || collateralTokenAddress == wethContract) && collateralTokenSent == 0)),
            "6"
        );

        if (msg.value != 0) {
            collateralTokenAddress = wethContract;
            collateralTokenSent = msg.value;
        }

        uint256 _borrowAmount = borrowAmount;

        leverageAmount = uint256(keccak256(abi.encodePacked(leverageAmount,collateralTokenAddress)));
        loanOrderHash = loanOrderHashes[leverageAmount];
        require(loanOrderHash != 0, "7");

        _settleInterest();

        uint256[7] memory sentAmounts;

        LoanData memory loanOrder = loanOrderData[loanOrderHash];
        bool useFixedInterestModel = loanOrder.maxDurationUnixTimestampSec == 0;

        if (_borrowAmount == 0) {
            _borrowAmount = _getBorrowAmountForDeposit(
                collateralTokenSent,
                leverageAmount,
                initialLoanDuration,
                collateralTokenAddress
            );
            require(_borrowAmount != 0, "35");

            
            sentAmounts[6] = _borrowAmount;
        } else {
            
            sentAmounts[6] = _borrowAmount;
        }

        
        (sentAmounts[0], sentAmounts[2], _borrowAmount) = _getInterestRateAndAmount(
            _borrowAmount,
            _totalAssetSupply(0), 
            initialLoanDuration,
            useFixedInterestModel
        );

        sentAmounts[6] = _borrowTokenAndUseFinal(
            loanOrderHash,
            [
                borrower,
                collateralTokenAddress,
                address(0), 
                receiver
            ],
            [
                sentAmounts[0],         
                _borrowAmount,
                sentAmounts[2],         
                0,                      
                collateralTokenSent,
                0,                      
                sentAmounts[6]          
            ],
            ""                          // loanDataBytes
        );
        require(sentAmounts[6] == _borrowAmount, "8");
    }

    
    
    
    
    function marginTradeFromDeposit(
        uint256 depositAmount,
        uint256 leverageAmount,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        uint256 tradeTokenSent,
        address trader,
        address depositTokenAddress,
        address collateralTokenAddress,
        address tradeTokenAddress,
        bytes memory loanDataBytes)
        public
        payable
        returns (bytes32 loanOrderHash)
    {
        require(tx.origin == owner, "unauthorized");

        require(tradeTokenAddress != address(0) &&
            tradeTokenAddress != loanTokenAddress,
            "10"
        );

        uint256 amount = depositAmount;
        
        if (depositTokenAddress == tradeTokenAddress) {
            (,,amount) = IBZxOracle(bZxOracle).getTradeData(
                tradeTokenAddress,
                loanTokenAddress,
                amount
            );
        } else if (depositTokenAddress != loanTokenAddress) {
            
            revert("11");
        }

        loanOrderHash = _borrowTokenAndUse(
            leverageAmount,
            [
                trader,
                collateralTokenAddress,     
                tradeTokenAddress,          
                trader                      
            ],
            [
                0,                      
                amount,                 
                0,                      
                loanTokenSent,
                collateralTokenSent,
                tradeTokenSent,
                0
            ],
            true,                       
            loanDataBytes
        );
    }

    function transfer(
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        require(_value <= balances[msg.sender] &&
            _to != address(0),
            "13"
        );

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        
        uint256 currentPrice = tokenPrice();
        if (balances[msg.sender] != 0) {
            checkpointPrices_[msg.sender] = currentPrice;
        } else {
            checkpointPrices_[msg.sender] = 0;
        }
        if (balances[_to] != 0) {
            checkpointPrices_[_to] = currentPrice;
        } else {
            checkpointPrices_[_to] = 0;
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        uint256 allowanceAmount = allowed[_from][msg.sender];
        require(_value <= balances[_from] &&
            _value <= allowanceAmount &&
            _to != address(0),
            "14"
        );

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (allowanceAmount < MAX_UINT) {
            allowed[_from][msg.sender] = allowanceAmount.sub(_value);
        }

        
        uint256 currentPrice = tokenPrice();
        if (balances[_from] != 0) {
            checkpointPrices_[_from] = currentPrice;
        } else {
            checkpointPrices_[_from] = 0;
        }
        if (balances[_to] != 0) {
            checkpointPrices_[_to] = currentPrice;
        } else {
            checkpointPrices_[_to] = 0;
        }

        emit Transfer(_from, _to, _value);
        return true;
    }


    

    function tokenPrice()
        public
        view
        returns (uint256 price)
    {
        uint256 interestUnPaid;
        if (lastSettleTime_ != block.timestamp) {
            (,interestUnPaid) = _getAllInterest();
        }

        return _tokenPrice(_totalAssetSupply(interestUnPaid));
    }

    function checkpointPrice(
        address _user)
        public
        view
        returns (uint256 price)
    {
        return checkpointPrices_[_user];
    }

    function marketLiquidity()
        public
        view
        returns (uint256)
    {
        uint256 totalSupply = totalAssetSupply();
        if (totalSupply > totalAssetBorrow) {
            return totalSupply.sub(totalAssetBorrow);
        }
    }

    function protocolInterestRate()
        public
        view
        returns (uint256)
    {
        return _protocolInterestRate(totalAssetBorrow);
    }

    
    function borrowInterestRate()
        public
        view
        returns (uint256)
    {
        return _nextBorrowInterestRate(
            0,              
            false           
        );
    }

    function nextBorrowInterestRate(
        uint256 borrowAmount)
        public
        view
        returns (uint256)
    {
        return _nextBorrowInterestRate(
            borrowAmount,
            false           
        );
    }

    function nextBorrowInterestRateWithOption(
        uint256 borrowAmount,
        bool useFixedInterestModel)
        public
        view
        returns (uint256)
    {
        return _nextBorrowInterestRate(
            borrowAmount,
            useFixedInterestModel
        );
    }

    
    function avgBorrowInterestRate()
        public
        view
        returns (uint256)
    {
        uint256 assetBorrow = totalAssetBorrow;
        if (assetBorrow != 0) {
            return _protocolInterestRate(assetBorrow)
                .mul(checkpointSupply)
                .div(totalAssetSupply());
        } else {
            return _getLowUtilBaseRate();
        }
    }

    
    function supplyInterestRate()
        public
        view
        returns (uint256)
    {
        return totalSupplyInterestRate(totalAssetSupply());
    }

    function nextSupplyInterestRate(
        uint256 supplyAmount)
        public
        view
        returns (uint256)
    {
        return totalSupplyInterestRate(totalAssetSupply().add(supplyAmount));
    }

    function totalSupplyInterestRate(
        uint256 assetSupply)
        public
        view
        returns (uint256)
    {
        uint256 assetBorrow = totalAssetBorrow;
        if (assetBorrow != 0) {
            return _supplyInterestRate(
                assetBorrow,
                assetSupply
            );
        }
    }

    function totalAssetSupply()
        public
        view
        returns (uint256)
    {
        uint256 interestUnPaid;
        if (lastSettleTime_ != block.timestamp) {
            (,interestUnPaid) = _getAllInterest();
        }

        return _totalAssetSupply(interestUnPaid);
    }

    function getMaxEscrowAmount(
        uint256 leverageAmount)
        public
        view
        returns (uint256)
    {
        LoanData memory loanData = loanOrderData[loanOrderHashes[leverageAmount]];
        if (loanData.initialMarginAmount == 0)
            return 0;

        return marketLiquidity()
            .mul(loanData.initialMarginAmount)
            .div(_adjustValue(
                10**20, 
                loanData.maxDurationUnixTimestampSec,
                loanData.initialMarginAmount));
    }

    function getLeverageList()
        public
        view
        returns (uint256[] memory)
    {
        return leverageList;
    }

    function getLoanData(
        bytes32 loanOrderHash)
        public
        view
        returns (LoanData memory)
    {
        return loanOrderData[loanOrderHash];
    }

    
    function assetBalanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balanceOf(_owner)
            .mul(tokenPrice())
            .div(10**18);
    }

    function getDepositAmountForBorrow(
        uint256 borrowAmount,
        uint256 leverageAmount,             
        uint256 initialLoanDuration,        
        address collateralTokenAddress)     
        public
        view
        returns (uint256 depositAmount)
    {
        if (borrowAmount != 0) {
            leverageAmount = uint256(keccak256(abi.encodePacked(leverageAmount,collateralTokenAddress)));
            LoanData memory loanOrder = loanOrderData[loanOrderHashes[leverageAmount]];
            uint256 marginAmount = loanOrder.initialMarginAmount
                .add(10**20); 
                

            
            borrowAmount = borrowAmount
                .mul(_getTargetNextRateMultiplierValue(initialLoanDuration))
                .div(10**22);

            if (borrowAmount <= ERC20(loanTokenAddress).balanceOf(address(this))) {
                return IBZx(bZxContract).getRequiredCollateral(
                    loanTokenAddress,
                    collateralTokenAddress != address(0) ? collateralTokenAddress : wethContract,
                    bZxOracle,
                    borrowAmount,
                    marginAmount
                ).add(10); 
            }
        }
    }

    function getBorrowAmountForDeposit(
        uint256 depositAmount,
        uint256 leverageAmount,             
        uint256 initialLoanDuration,        
        address collateralTokenAddress)     
        public
        view
        returns (uint256 borrowAmount)
    {
        leverageAmount = uint256(keccak256(abi.encodePacked(leverageAmount,collateralTokenAddress)));
        borrowAmount = _getBorrowAmountForDeposit(
            depositAmount,
            leverageAmount,
            initialLoanDuration,
            collateralTokenAddress
        );
    }


    

    function _mintToken(
        address receiver,
        uint256 depositAmount)
        internal
        returns (uint256 mintAmount)
    {
        require (depositAmount != 0, "17");

        _settleInterest();

        uint256 currentPrice = _tokenPrice(_totalAssetSupply(0));
        mintAmount = depositAmount.mul(10**18).div(currentPrice);

        if (msg.value == 0) {
            _transferFrom(loanTokenAddress, msg.sender, address(this), depositAmount, "18");
        } else {
            WETHInterface(wethContract).deposit.value(depositAmount)();
        }

        _mint(receiver, mintAmount, depositAmount, currentPrice);

        checkpointPrices_[receiver] = currentPrice;
    }

    function _burnToken(
        uint256 burnAmount)
        internal
        returns (uint256 loanAmountPaid)
    {
        require(burnAmount != 0, "19");

        if (burnAmount > balanceOf(msg.sender)) {
            burnAmount = balanceOf(msg.sender);
        }

        _settleInterest();

        uint256 currentPrice = _tokenPrice(_totalAssetSupply(0));

        uint256 loanAmountOwed = burnAmount.mul(currentPrice).div(10**18);
        uint256 loanAmountAvailableInContract = ERC20(loanTokenAddress).balanceOf(address(this));

        loanAmountPaid = loanAmountOwed;
        require(loanAmountPaid <= loanAmountAvailableInContract, "37");

        _burn(msg.sender, burnAmount, loanAmountPaid, currentPrice);

        if (balances[msg.sender] != 0) {
            checkpointPrices_[msg.sender] = currentPrice;
        } else {
            checkpointPrices_[msg.sender] = 0;
        }
    }

    function _settleInterest()
        internal
    {
        if (lastSettleTime_ != block.timestamp) {
            IBZx(bZxContract).payInterestForOracle(
                bZxOracle, 
                loanTokenAddress 
            );

            lastSettleTime_ = block.timestamp;
        }
    }

    function _getBorrowAmountForDeposit(
        uint256 depositAmount,
        uint256 leverageAmount,             
        uint256 initialLoanDuration,        
        address collateralTokenAddress)     
        internal
        view
        returns (uint256 borrowAmount)
    {
        if (depositAmount != 0) {
            LoanData memory loanOrder = loanOrderData[loanOrderHashes[leverageAmount]];
            uint256 marginAmount = loanOrder.initialMarginAmount
                .add(10**20); 
                

            borrowAmount = IBZx(bZxContract).getBorrowAmount(
                loanTokenAddress,
                collateralTokenAddress != address(0) ? collateralTokenAddress : wethContract,
                bZxOracle,
                depositAmount,
                marginAmount
            );

            
            borrowAmount = borrowAmount
                .mul(10**22)
                .div(_getTargetNextRateMultiplierValue(initialLoanDuration));

            if (borrowAmount > ERC20(loanTokenAddress).balanceOf(address(this))) {
                borrowAmount = 0;
            }
        }
    }

    function _getTargetNextRateMultiplierValue(
        uint256 initialLoanDuration)
        internal
        view
        returns (uint256)
    {
        return rateMultiplier
            .mul(80 ether)
            .div(10**20)
            .add(baseRate)
            .mul(initialLoanDuration)
            .div(315360) 
            .add(10**22);
    }

    function _getInterestRateAndAmount(
        uint256 borrowAmount,
        uint256 assetSupply,
        uint256 initialLoanDuration,        
        bool useFixedInterestModel)         
        internal
        view
        returns (uint256 interestRate, uint256 interestInitialAmount, uint256 newBorrowAmount)
    {
        (,interestInitialAmount) = _getInterestRateAndAmount2(
            borrowAmount,
            assetSupply,
            initialLoanDuration,
            useFixedInterestModel
        );

        (interestRate, interestInitialAmount) = _getInterestRateAndAmount2(
            borrowAmount
                .add(interestInitialAmount),
            assetSupply,
            initialLoanDuration,
            useFixedInterestModel
        );

        newBorrowAmount = borrowAmount
            .add(interestInitialAmount);
    }

    function _getInterestRateAndAmount2(
        uint256 borrowAmount,
        uint256 assetSupply,
        uint256 initialLoanDuration,
        bool useFixedInterestModel)
        internal
        view
        returns (uint256 interestRate, uint256 interestInitialAmount)
    {
        interestRate = _nextBorrowInterestRate2(
            borrowAmount,
            assetSupply,
            useFixedInterestModel
        );

        
        interestInitialAmount = borrowAmount
            .mul(interestRate)
            .mul(initialLoanDuration)
            .div(31536000 * 10**20); 
    }

    function _borrowTokenAndUse(
        uint256 leverageAmount,
        address[4] memory sentAddresses,
        uint256[7] memory sentAmounts,
        bool amountIsADeposit,
        bytes memory loanDataBytes)
        internal
        returns (bytes32 loanOrderHash)
    {
        require(sentAmounts[1] != 0, "21"); 

        loanOrderHash = loanOrderHashes[leverageAmount];
        require(loanOrderHash != 0, "22");

        _settleInterest();

        LoanData memory loanOrder = loanOrderData[loanOrderHash];
        bool useFixedInterestModel = loanOrder.maxDurationUnixTimestampSec == 0;
        

        if (amountIsADeposit) {
            (sentAmounts[1], sentAmounts[0]) = _getBorrowAmountAndRate( 
                loanOrderHash,
                sentAmounts[1], 
                useFixedInterestModel
            );

            
            sentAmounts[6] = sentAmounts[1]; 
        } else {
            
            sentAmounts[0] = _nextBorrowInterestRate2( 
                sentAmounts[1], 
                _totalAssetSupply(0),
                useFixedInterestModel
            );
        }

        if (sentAddresses[2] == address(0)) { 
            
            sentAmounts[5] = 0;
        }

        uint256 borrowAmount = _borrowTokenAndUseFinal(
            loanOrderHash,
            sentAddresses,
            sentAmounts,
            loanDataBytes
        );
        require(borrowAmount == sentAmounts[1], "23");
    }

    
    function _borrowTokenAndUseFinal(
        bytes32 loanOrderHash,
        address[4] memory sentAddresses,
        uint256[7] memory sentAmounts,
        bytes memory loanDataBytes)
        internal
        returns (uint256)
    {
        _checkPause();

        require (sentAmounts[1] <= ERC20(loanTokenAddress).balanceOf(address(this)) && 
            sentAddresses[0] != address(0), 
            "24"
        );

	    if (sentAddresses[3] == address(0)) {
            sentAddresses[3] = sentAddresses[0]; 
        }

        
        _verifyTransfers(
            sentAddresses,
            sentAmounts
        );

        
        sentAmounts[3] = sentAmounts[3]
            .add(sentAmounts[1]); 

        uint256 msgValue;
        if (msg.value != 0) {
            msgValue = address(this).balance;
            if (msgValue > msg.value) {
                msgValue = msg.value;
            }
        }
        sentAmounts[1] = IBZx(bZxContract).takeOrderFromiToken.value(msgValue)( 
            loanOrderHash,
            sentAddresses,
            sentAmounts,
            loanDataBytes
        );
        require (sentAmounts[1] != 0, "25");

        
        totalAssetBorrow = totalAssetBorrow
            .add(sentAmounts[1]); 

        
        checkpointSupply = _totalAssetSupply(0);

        emit Borrow(
            sentAddresses[0],               
            sentAmounts[1],                 
            sentAmounts[0],                 
            sentAddresses[1],               
            sentAddresses[2],               
            sentAddresses[2] == address(0)  
        );

        return sentAmounts[1]; 
    }

    
    
    
    
    
    
    
    
    
    
    
    function _verifyTransfers(
        address[4] memory sentAddresses,
        uint256[7] memory sentAmounts)
        internal
    {
        address collateralTokenAddress = sentAddresses[1];
        address tradeTokenAddress = sentAddresses[2];
        address receiver = sentAddresses[3];
        uint256 borrowAmount = sentAmounts[1];
        uint256 loanTokenSent = sentAmounts[3];
        uint256 collateralTokenSent = sentAmounts[4];
        uint256 tradeTokenSent = sentAmounts[5];
        uint256 withdrawalAmount = sentAmounts[6];

        bool success;
        if (tradeTokenAddress == address(0)) { 
            if (loanTokenAddress == wethContract) {
                IWethHelper wethHelper = IWethHelper(0x3b5bDCCDFA2a0a1911984F203C19628EeB6036e0);

                _transfer(loanTokenAddress, address(wethHelper), withdrawalAmount, "");
                success = withdrawalAmount == wethHelper.claimEther(receiver, withdrawalAmount);
            } else {
                _transfer(loanTokenAddress, receiver, withdrawalAmount, "");
                success = true;
            }

            if (success && borrowAmount > withdrawalAmount) {
                _transfer(loanTokenAddress, bZxVault, borrowAmount - withdrawalAmount, "");
            }
            require(success, "26");
        } else {
            _transfer(loanTokenAddress, bZxVault, borrowAmount, "26");
        }

        if (collateralTokenSent != 0) {
            if (collateralTokenAddress == wethContract && msg.value != 0 && collateralTokenSent == msg.value) {
                WETHInterface(wethContract).deposit.value(collateralTokenSent)();
                _transfer(collateralTokenAddress, bZxVault, collateralTokenSent, "27");
            } else {
                if (collateralTokenAddress == loanTokenAddress) {
                    loanTokenSent = loanTokenSent.add(collateralTokenSent);
                } else if (collateralTokenAddress == tradeTokenAddress) {
                    tradeTokenSent = tradeTokenSent.add(collateralTokenSent);
                } else {
                    _transferFrom(collateralTokenAddress, msg.sender, bZxVault, collateralTokenSent, "27");
                }
            }
        }

        if (loanTokenSent != 0) {
            if (loanTokenAddress == tradeTokenAddress) {
                tradeTokenSent = tradeTokenSent.add(loanTokenSent);
            } else {
                _transferFrom(loanTokenAddress, msg.sender, bZxVault, loanTokenSent, "31");
            }
        }

        if (tradeTokenSent != 0) {
            _transferFrom(tradeTokenAddress, msg.sender, bZxVault, tradeTokenSent, "32");
        }
    }

    function _transfer(
        address token,
        address to,
        uint256 amount,
        string memory errorMsg)
        internal
    {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(ERC20(token).transfer.selector, to, amount),
            errorMsg
        );
    }

    function _transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        string memory errorMsg)
        internal
    {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(ERC20(token).transferFrom.selector, from, to, amount),
            errorMsg
        );
    }

    function _callOptionalReturn(
        address token,
        bytes memory data,
        string memory errorMsg)
        internal
    {
        (bool success, bytes memory returndata) = token.call(data);
        require(success, errorMsg);

        if (returndata.length != 0) {
            require(abi.decode(returndata, (bool)), errorMsg);
        }
    }

    

    function _tokenPrice(
        uint256 assetSupply)
        internal
        view
        returns (uint256)
    {
        uint256 totalTokenSupply = totalSupply_;

        return totalTokenSupply != 0 ?
            assetSupply
                .mul(10**18)
                .div(totalTokenSupply) : initialPrice;
    }

    function _protocolInterestRate(
        uint256 assetBorrow)
        internal
        view
        returns (uint256)
    {
        if (assetBorrow != 0) {
            (uint256 interestOwedPerDay,) = _getAllInterest();
            return interestOwedPerDay
                .mul(10**20)
                .div(assetBorrow)
                .mul(365);
        }
    }

    
    function _supplyInterestRate(
        uint256 assetBorrow,
        uint256 assetSupply)
        public
        view
        returns (uint256)
    {
        if (assetBorrow != 0 && assetSupply >= assetBorrow) {
            return _protocolInterestRate(assetBorrow)
                .mul(_utilizationRate(assetBorrow, assetSupply))
                .mul(spreadMultiplier)
                .div(10**40);
        }
    }

    function _nextBorrowInterestRate(
        uint256 borrowAmount,
        bool useFixedInterestModel)
        internal
        view
        returns (uint256)
    {
        uint256 interestUnPaid;
        if (borrowAmount != 0) {
            if (lastSettleTime_ != block.timestamp) {
                (,interestUnPaid) = _getAllInterest();
            }

            uint256 balance = ERC20(loanTokenAddress).balanceOf(address(this))
                .add(interestUnPaid);
            if (borrowAmount > balance) {
                borrowAmount = balance;
            }
        }

        return _nextBorrowInterestRate2(
            borrowAmount,
            _totalAssetSupply(interestUnPaid),
            useFixedInterestModel
        );
    }

    function _nextBorrowInterestRate2(
        uint256 newBorrowAmount,
        uint256 assetSupply,
        bool useFixedInterestModel)
        internal
        view
        returns (uint256 nextRate)
    {
        uint256 utilRate = _utilizationRate(
            totalAssetBorrow.add(newBorrowAmount),
            assetSupply
        );

        uint256 minRate;
        uint256 maxRate;
        uint256 thisBaseRate;
        uint256 thisRateMultiplier;

        if (useFixedInterestModel) {
            if (utilRate < 80 ether) {
                
                utilRate = 80 ether;
            }

            
            
            assembly {
                thisBaseRate := sload(0x185a40c6b6d3f849f72c71ea950323d21149c27a9d90f7dc5e5ea2d332edcf7f)
                thisRateMultiplier := sload(0x9ff54bc0049f5eab56ca7cd14591be3f7ed6355b856d01e3770305c74a004ea2)
            }
        } else if (utilRate < 50 ether) {
            thisBaseRate = _getLowUtilBaseRate();

            
            assembly {
                thisRateMultiplier := sload(0x2b4858b1bc9e2d14afab03340ce5f6c81b703c86a0c570653ae586534e095fb1)
            }
        } else {
            thisBaseRate = baseRate;
            thisRateMultiplier = rateMultiplier;
        }

        if (utilRate > 90 ether) {
            

            utilRate = utilRate.sub(90 ether);
            if (utilRate > 10 ether)
                utilRate = 10 ether;

            maxRate = thisRateMultiplier
                .add(thisBaseRate)
                .mul(90)
                .div(100);

            nextRate = utilRate
                .mul(SafeMath.sub(100 ether, maxRate))
                .div(10 ether)
                .add(maxRate);
        } else {
            nextRate = utilRate
                .mul(thisRateMultiplier)
                .div(10**20)
                .add(thisBaseRate);

            minRate = thisBaseRate;
            maxRate = thisRateMultiplier
                .add(thisBaseRate);

            if (nextRate < minRate)
                nextRate = minRate;
            else if (nextRate > maxRate)
                nextRate = maxRate;
        }
    }

    function _getAllInterest()
        internal
        view
        returns (
            uint256 interestOwedPerDay,
            uint256 interestUnPaid)
    {
        (,,interestOwedPerDay,interestUnPaid) = IBZx(bZxContract).getLenderInterestForOracle(
            address(this),
            bZxOracle, 
            loanTokenAddress 
        );

        interestUnPaid = interestUnPaid
            .mul(spreadMultiplier)
            .div(10**20);
    }

    function _getBorrowAmountAndRate(
        bytes32 loanOrderHash,
        uint256 depositAmount,
        bool useFixedInterestModel)
        internal
        view
        returns (uint256 borrowAmount, uint256 interestRate)
    {
        LoanData memory loanData = loanOrderData[loanOrderHash];
        require(loanData.initialMarginAmount != 0, "33");

        interestRate = _nextBorrowInterestRate2(
            depositAmount
                .mul(10**20)
                .div(loanData.initialMarginAmount),
            totalAssetSupply(),
            useFixedInterestModel
        );

        
        borrowAmount = depositAmount
            .mul(10**40)
            .div(_adjustValue(
                interestRate,
                loanData.maxDurationUnixTimestampSec,
                loanData.initialMarginAmount))
            .div(loanData.initialMarginAmount);
    }

    function _totalAssetSupply(
        uint256 interestUnPaid)
        internal
        view
        returns (uint256 assetSupply)
    {
        if (totalSupply_ != 0) {
            uint256 assetsBalance = burntTokenReserved; 
            if (assetsBalance == 0) {
                assetsBalance = ERC20(loanTokenAddress).balanceOf(address(this))
                    .add(totalAssetBorrow);
            }

            return assetsBalance
                .add(interestUnPaid);
        }
    }

    function _getLowUtilBaseRate()
        internal
        view
        returns (uint256 lowUtilBaseRate)
    {
        
        assembly {
            lowUtilBaseRate := sload(0x3d82e958c891799f357c1316ae5543412952ae5c423336f8929ed7458039c995)
        }
    }

    function _checkPause()
        internal
        view
    {
        
        bytes32 slot = keccak256(abi.encodePacked(msg.sig, uint256(0xd46a704bc285dbd6ff5ad3863506260b1df02812f4f857c8cc852317a6ac64f2)));
        bool isPaused;
        assembly {
            isPaused := sload(slot)
        }
        require(!isPaused, "unauthorized");
    }

    function _adjustValue(
        uint256 interestRate,
        uint256 maxDuration,
        uint256 marginAmount)
        internal
        pure
        returns (uint256)
    {
        return maxDuration != 0 ?
            interestRate
                .mul(10**20)
                .div(31536000) 
                .mul(maxDuration)
                .div(marginAmount)
                .add(10**20) :
            10**20;
    }

    function _utilizationRate(
        uint256 assetBorrow,
        uint256 assetSupply)
        internal
        pure
        returns (uint256)
    {
        if (assetBorrow != 0 && assetSupply != 0) {
            
            return assetBorrow
                .mul(10**20)
                .div(assetSupply);
        }
    }


    

    
    function closeLoanNotifier(
        BZxObjects.LoanOrder memory loanOrder,
        BZxObjects.LoanPosition memory loanPosition,
        address loanCloser,
        uint256 closeAmount,
        bool isLiquidation)
        public
        onlyOracle
        returns (bool)
    {
        _settleInterest();

        LoanData memory loanData = loanOrderData[loanOrder.loanOrderHash];
        if (loanData.loanOrderHash == loanOrder.loanOrderHash) {
            totalAssetBorrow = totalAssetBorrow > closeAmount ?
                totalAssetBorrow.sub(closeAmount) : 0;

            emit Repay(
                loanOrder.loanOrderHash,    
                loanPosition.trader,        
                loanCloser,                 
                closeAmount,                
                isLiquidation               
            );

            if (closeAmount == 0)
                return true;

            
            checkpointSupply = _totalAssetSupply(0);

            return true;
        } else {
            return false;
        }
    }


    

    function updateSettings(
        address settingsTarget,
        bytes memory callData)
        public
    {
        if (msg.sender != owner) {
            address _lowerAdmin;
            address _lowerAdminContract;

            
            
            assembly {
                _lowerAdmin := sload(0x7ad06df6a0af6bd602d90db766e0d5f253b45187c3717a0f9026ea8b10ff0d4b)
                _lowerAdminContract := sload(0x34b31cff1dbd8374124bd4505521fc29cab0f9554a5386ba7d784a4e611c7e31)
            }
            require(msg.sender == _lowerAdmin && settingsTarget == _lowerAdminContract);
        }

        address currentTarget = target_;
        target_ = settingsTarget;

        (bool result,) = address(this).call(callData);

        uint256 size;
        uint256 ptr;
        assembly {
            size := returndatasize
            ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            if eq(result, 0) { revert(ptr, size) }
        }

        target_ = currentTarget;

        assembly {
            return(ptr, size)
        }
    }
}