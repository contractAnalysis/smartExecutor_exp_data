pragma solidity 0.6.6;


interface IERC20 {
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function decimals() external view returns (uint8 digits);

    function totalSupply() external view returns (uint256 supply);
}



abstract contract ERC20 is IERC20 {

}



pragma solidity 0.6.6;




contract Utils5 {
    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); 
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); 
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 constant BPS = 10000; 
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); 

    mapping(IERC20 => uint256) internal decimals;

    function getUpdateDecimals(IERC20 token) internal returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; 
        uint256 tokenDecimals = decimals[token];
        
        
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }

        return tokenDecimals;
    }

    function setDecimals(IERC20 token) internal {
        if (decimals[token] != 0) return; 

        if (token == ETH_TOKEN_ADDRESS) {
            decimals[token] = ETH_DECIMALS;
        } else {
            decimals[token] = token.decimals();
        }
    }

    
    
    
    function getBalance(IERC20 token, address user) internal view returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    function getDecimals(IERC20 token) internal view returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; 
        uint256 tokenDecimals = decimals[token];
        
        
        if (tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDestAmount(
        IERC20 src,
        IERC20 dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20 src,
        IERC20 dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        
        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; 
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {
        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}



pragma solidity 0.6.6;


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



pragma solidity 0.6.6;

interface IEpochUtils {
    function epochPeriodInSeconds() external view returns (uint256);

    function firstEpochStartTimestamp() external view returns (uint256);

    function getCurrentEpochNumber() external view returns (uint256);

    function getEpochNumber(uint256 timestamp) external view returns (uint256);
}



pragma solidity 0.6.6;



interface IKyberDao is IEpochUtils {
    event Voted(address indexed staker, uint indexed epoch, uint indexed campaignID, uint option);

    function getLatestNetworkFeeDataWithCache()
        external
        returns (uint256 feeInBps, uint256 expiryTimestamp);

    function getLatestBRRDataWithCache()
        external
        returns (
            uint256 burnInBps,
            uint256 rewardInBps,
            uint256 rebateInBps,
            uint256 epoch,
            uint256 expiryTimestamp
        );

    function handleWithdrawal(address staker, uint256 penaltyAmount) external;

    function vote(uint256 campaignID, uint256 option) external;

    function getLatestNetworkFeeData()
        external
        view
        returns (uint256 feeInBps, uint256 expiryTimestamp);

    function shouldBurnRewardForEpoch(uint256 epoch) external view returns (bool);

    
    function getPastEpochRewardPercentageInPrecision(address staker, uint256 epoch)
        external
        view
        returns (uint256);

    
    function getCurrentEpochRewardPercentageInPrecision(address staker)
        external
        view
        returns (uint256);
}



pragma solidity 0.6.6;



interface IKyberFeeHandler {
    event RewardPaid(address indexed staker, uint256 indexed epoch, IERC20 indexed token, uint256 amount);
    event RebatePaid(address indexed rebateWallet, IERC20 indexed token, uint256 amount);
    event PlatformFeePaid(address indexed platformWallet, IERC20 indexed token, uint256 amount);
    event KncBurned(uint256 kncTWei, IERC20 indexed token, uint256 amount);

    function handleFees(
        IERC20 token,
        address[] calldata eligibleWallets,
        uint256[] calldata rebatePercentages,
        address platformWallet,
        uint256 platformFee,
        uint256 networkFee
    ) external payable;

    function claimReserveRebate(address rebateWallet) external returns (uint256);

    function claimPlatformFee(address platformWallet) external returns (uint256);

    function claimStakerReward(
        address staker,
        uint256 epoch
    ) external returns(uint amount);
}



pragma solidity 0.6.6;



interface IKyberNetworkProxy {

    event ExecuteTrade(
        address indexed trader,
        IERC20 src,
        IERC20 dest,
        address destAddress,
        uint256 actualSrcAmount,
        uint256 actualDestAmount,
        address platformWallet,
        uint256 platformFeeBps
    );

    
    function tradeWithHint(
        ERC20 src,
        uint256 srcAmount,
        ERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable walletId,
        bytes calldata hint
    ) external payable returns (uint256);

    function tradeWithHintAndFee(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount);

    function trade(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet
    ) external payable returns (uint256);

    
    
    function getExpectedRate(
        ERC20 src,
        ERC20 dest,
        uint256 srcQty
    ) external view returns (uint256 expectedRate, uint256 worstRate);

    function getExpectedRateAfterFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external view returns (uint256 expectedRate);
}



pragma solidity 0.6.6;




interface ISimpleKyberProxy {
    function swapTokenToEther(
        IERC20 token,
        uint256 srcAmount,
        uint256 minConversionRate
    ) external returns (uint256 destAmount);

    function swapEtherToToken(IERC20 token, uint256 minConversionRate)
        external
        payable
        returns (uint256 destAmount);

    function swapTokenToToken(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        uint256 minConversionRate
    ) external returns (uint256 destAmount);
}



pragma solidity 0.6.6;


interface IBurnableToken {
    function burn(uint256 _value) external returns (bool);
}



pragma solidity 0.6.6;




interface ISanityRate {
    
    function latestAnswer() external view returns (uint256);
}



pragma solidity 0.6.6;


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

    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}



pragma solidity 0.6.6;


contract DaoOperator {
    address public daoOperator;

    constructor(address _daoOperator) public {
        require(_daoOperator != address(0), "daoOperator is 0");
        daoOperator = _daoOperator;
    }

    modifier onlyDaoOperator() {
        require(msg.sender == daoOperator, "only daoOperator");
        _;
    }
}



pragma solidity 0.6.6;












interface IKyberProxy is IKyberNetworkProxy, ISimpleKyberProxy {
    
}



contract KyberFeeHandler is IKyberFeeHandler, Utils5, DaoOperator, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 internal constant DEFAULT_REWARD_BPS = 3000;
    uint256 internal constant DEFAULT_REBATE_BPS = 3000;
    uint256 internal constant SANITY_RATE_DIFF_BPS = 1000; 

    struct BRRData {
        uint64 expiryTimestamp;
        uint32 epoch;
        uint16 rewardBps;
        uint16 rebateBps;
    }

    struct BRRWei {
        uint256 rewardWei;
        uint256 fullRebateWei;
        uint256 paidRebateWei;
        uint256 burnWei;
    }

    IKyberDao public kyberDao;
    IKyberProxy public kyberProxy;
    address public kyberNetwork;
    IERC20 public immutable knc;

    uint256 public immutable burnBlockInterval;
    uint256 public lastBurnBlock;

    BRRData public brrAndEpochData;
    address public daoSetter;

    
    uint256 public weiToBurn = 2 ether;

    mapping(address => uint256) public feePerPlatformWallet;
    mapping(address => uint256) public rebatePerWallet;
    mapping(uint256 => uint256) public rewardsPerEpoch;
    mapping(uint256 => uint256) public rewardsPaidPerEpoch;
    
    mapping(address => mapping (uint256 => bool)) public hasClaimedReward;
    uint256 public totalPayoutBalance; 

    
    
    ISanityRate[] internal sanityRateContract;

    event FeeDistributed(
        IERC20 indexed token,
        address indexed platformWallet,
        uint256 platformFeeWei,
        uint256 rewardWei,
        uint256 rebateWei,
        address[] rebateWallets,
        uint256[] rebatePercentBpsPerWallet,
        uint256 burnAmtWei
    );

    event BRRUpdated(
        uint256 rewardBps,
        uint256 rebateBps,
        uint256 burnBps,
        uint256 expiryTimestamp,
        uint256 indexed epoch
    );

    event EthReceived(uint256 amount);
    event KyberDaoAddressSet(IKyberDao kyberDao);
    event BurnConfigSet(ISanityRate sanityRate, uint256 weiToBurn);
    event RewardsRemovedToBurn(uint256 indexed epoch, uint256 rewardsWei);
    event KyberNetworkUpdated(address kyberNetwork);
    event KyberProxyUpdated(IKyberProxy kyberProxy);

    constructor(
        address _daoSetter,
        IKyberProxy _kyberProxy,
        address _kyberNetwork,
        IERC20 _knc,
        uint256 _burnBlockInterval,
        address _daoOperator
    ) public DaoOperator(_daoOperator) {
        require(_daoSetter != address(0), "daoSetter 0");
        require(_kyberProxy != IKyberProxy(0), "kyberNetworkProxy 0");
        require(_kyberNetwork != address(0), "kyberNetwork 0");
        require(_knc != IERC20(0), "knc 0");
        require(_burnBlockInterval != 0, "_burnBlockInterval 0");

        daoSetter = _daoSetter;
        kyberProxy = _kyberProxy;
        kyberNetwork = _kyberNetwork;
        knc = _knc;
        burnBlockInterval = _burnBlockInterval;

        
        updateBRRData(DEFAULT_REWARD_BPS, DEFAULT_REBATE_BPS, now, 0);
    }

    modifier onlyKyberDao {
        require(msg.sender == address(kyberDao), "only kyberDao");
        _;
    }

    modifier onlyKyberNetwork {
        require(msg.sender == address(kyberNetwork), "only kyberNetwork");
        _;
    }

    modifier onlyNonContract {
        require(tx.origin == msg.sender, "only non-contract");
        _;
    }

    receive() external payable {
        emit EthReceived(msg.value);
    }

    
    
    
    
    
    
    
    function handleFees(
        IERC20 token,
        address[] calldata rebateWallets,
        uint256[] calldata rebateBpsPerWallet,
        address platformWallet,
        uint256 platformFee,
        uint256 networkFee
    ) external payable override onlyKyberNetwork nonReentrant {
        require(token == ETH_TOKEN_ADDRESS, "token not eth");
        require(msg.value == platformFee.add(networkFee), "msg.value not equal to total fees");

        
        feePerPlatformWallet[platformWallet] = feePerPlatformWallet[platformWallet].add(
            platformFee
        );

        if (networkFee == 0) {
            
            totalPayoutBalance = totalPayoutBalance.add(platformFee);
            emit FeeDistributed(
                ETH_TOKEN_ADDRESS,
                platformWallet,
                platformFee,
                0,
                0,
                rebateWallets,
                rebateBpsPerWallet,
                0
            );
            return;
        }

        BRRWei memory brrAmounts;
        uint256 epoch;

        
        (brrAmounts.rewardWei, brrAmounts.fullRebateWei, epoch) = getRRWeiValues(networkFee);

        brrAmounts.paidRebateWei = updateRebateValues(
            brrAmounts.fullRebateWei, rebateWallets, rebateBpsPerWallet
        );
        brrAmounts.rewardWei = brrAmounts.rewardWei.add(
            brrAmounts.fullRebateWei.sub(brrAmounts.paidRebateWei)
        );

        rewardsPerEpoch[epoch] = rewardsPerEpoch[epoch].add(brrAmounts.rewardWei);

        
        totalPayoutBalance = totalPayoutBalance.add(
            platformFee).add(brrAmounts.rewardWei).add(brrAmounts.paidRebateWei
        );

        brrAmounts.burnWei = networkFee.sub(brrAmounts.rewardWei).sub(brrAmounts.paidRebateWei);
        emit FeeDistributed(
            ETH_TOKEN_ADDRESS,
            platformWallet,
            platformFee,
            brrAmounts.rewardWei,
            brrAmounts.paidRebateWei,
            rebateWallets,
            rebateBpsPerWallet,
            brrAmounts.burnWei
        );
    }

    
    
    
    
    
    
    function claimStakerReward(
        address staker,
        uint256 epoch
    ) external override nonReentrant returns(uint256 amountWei) {
        if (hasClaimedReward[staker][epoch]) {
            
            return 0;
        }

        
        
        
        uint256 percentageInPrecision = kyberDao.getPastEpochRewardPercentageInPrecision(staker, epoch);
        if (percentageInPrecision == 0) {
            return 0; 
        }
        require(percentageInPrecision <= PRECISION, "percentage too high");

        
        amountWei = rewardsPerEpoch[epoch].mul(percentageInPrecision).div(PRECISION);

        
        assert(totalPayoutBalance >= amountWei);
        assert(rewardsPaidPerEpoch[epoch].add(amountWei) <= rewardsPerEpoch[epoch]);
        
        rewardsPaidPerEpoch[epoch] = rewardsPaidPerEpoch[epoch].add(amountWei);
        totalPayoutBalance = totalPayoutBalance.sub(amountWei);

        hasClaimedReward[staker][epoch] = true;

        
        (bool success, ) = staker.call{value: amountWei}("");
        require(success, "staker rewards transfer failed");

        emit RewardPaid(staker, epoch, ETH_TOKEN_ADDRESS, amountWei);
    }

    
    
    
    function claimReserveRebate(address rebateWallet) 
        external 
        override 
        nonReentrant 
        returns (uint256 amountWei) 
    {
        require(rebatePerWallet[rebateWallet] > 1, "no rebate to claim");
        
        amountWei = rebatePerWallet[rebateWallet].sub(1);

        
        assert(totalPayoutBalance >= amountWei);
        totalPayoutBalance = totalPayoutBalance.sub(amountWei);

        rebatePerWallet[rebateWallet] = 1; 

        
        (bool success, ) = rebateWallet.call{value: amountWei}("");
        require(success, "rebate transfer failed");

        emit RebatePaid(rebateWallet, ETH_TOKEN_ADDRESS, amountWei);

        return amountWei;
    }

    
    
    
    function claimPlatformFee(address platformWallet)
        external
        override
        nonReentrant
        returns (uint256 amountWei)
    {
        require(feePerPlatformWallet[platformWallet] > 1, "no fee to claim");
        
        amountWei = feePerPlatformWallet[platformWallet].sub(1);

        
        assert(totalPayoutBalance >= amountWei);
        totalPayoutBalance = totalPayoutBalance.sub(amountWei);

        feePerPlatformWallet[platformWallet] = 1; 

        (bool success, ) = platformWallet.call{value: amountWei}("");
        require(success, "platform fee transfer failed");

        emit PlatformFeePaid(platformWallet, ETH_TOKEN_ADDRESS, amountWei);
        return amountWei;
    }

    
    
    function setDaoContract(IKyberDao _kyberDao) external {
        require(msg.sender == daoSetter, "only daoSetter");
        require(_kyberDao != IKyberDao(0));
        kyberDao = _kyberDao;
        emit KyberDaoAddressSet(kyberDao);

        daoSetter = address(0);
    }

    
    
    function setNetworkContract(address _kyberNetwork) external onlyDaoOperator {
        require(_kyberNetwork != address(0), "kyberNetwork 0");
        if (_kyberNetwork != kyberNetwork) {
            kyberNetwork = _kyberNetwork;
            emit KyberNetworkUpdated(kyberNetwork);
        }
    }

    
    
    function setKyberProxy(IKyberProxy _newProxy) external onlyDaoOperator {
        require(_newProxy != IKyberProxy(0), "kyberNetworkProxy 0");
        if (_newProxy != kyberProxy) {
            kyberProxy = _newProxy;
            emit KyberProxyUpdated(_newProxy);
        }
    }

    
    
    
    function setBurnConfigParams(ISanityRate _sanityRate, uint256 _weiToBurn)
        external
        onlyDaoOperator
    {
        require(_weiToBurn > 0, "_weiToBurn is 0");

        if (sanityRateContract.length == 0 || (_sanityRate != sanityRateContract[0])) {
            
            if (sanityRateContract.length == 0) {
                sanityRateContract.push(_sanityRate);
            } else {
                sanityRateContract.push(sanityRateContract[0]);
                sanityRateContract[0] = _sanityRate;
            }
        }

        weiToBurn = _weiToBurn;

        emit BurnConfigSet(_sanityRate, _weiToBurn);
    }


    
    
    
    function burnKnc() external onlyNonContract returns (uint256 kncBurnAmount) {
        
        require(block.number > lastBurnBlock + burnBlockInterval, "wait more blocks to burn");

        
        lastBurnBlock = block.number;

        
        uint256 balance = address(this).balance;

        
        assert(balance >= totalPayoutBalance);
        uint256 srcAmount = balance.sub(totalPayoutBalance);
        srcAmount = srcAmount > weiToBurn ? weiToBurn : srcAmount;

        
        uint256 kyberEthKncRate = kyberProxy.getExpectedRateAfterFee(
            ETH_TOKEN_ADDRESS,
            knc,
            srcAmount,
            0,
            ""
        );
        validateEthToKncRateToBurn(kyberEthKncRate);

        // Buy some knc and burn
        kncBurnAmount = kyberProxy.swapEtherToToken{value: srcAmount}(
            knc,
            kyberEthKncRate
        );

        require(IBurnableToken(address(knc)).burn(kncBurnAmount), "knc burn failed");

        emit KncBurned(kncBurnAmount, ETH_TOKEN_ADDRESS, srcAmount);
        return kncBurnAmount;
    }

    
    
    
    
    function makeEpochRewardBurnable(uint256 epoch) external {
        require(kyberDao != IKyberDao(0), "kyberDao not set");

        require(kyberDao.shouldBurnRewardForEpoch(epoch), "should not burn reward");

        uint256 rewardAmount = rewardsPerEpoch[epoch];
        require(rewardAmount > 0, "reward is 0");

        
        require(totalPayoutBalance >= rewardAmount, "total reward less than epoch reward");
        totalPayoutBalance = totalPayoutBalance.sub(rewardAmount);

        rewardsPerEpoch[epoch] = 0;

        emit RewardsRemovedToBurn(epoch, rewardAmount);
    }

    
    
    
    function getSanityRateContracts() external view returns (ISanityRate[] memory sanityRates) {
        sanityRates = sanityRateContract;
    }

    
    function getLatestSanityRate() external view returns (uint256 kncToEthSanityRate) {
        if (sanityRateContract.length > 0 && sanityRateContract[0] != ISanityRate(0)) {
            kncToEthSanityRate = sanityRateContract[0].latestAnswer();
        } else {
            kncToEthSanityRate = 0; 
        }
    }

    function getBRR()
        public
        returns (
            uint256 rewardBps,
            uint256 rebateBps,
            uint256 epoch
        )
    {
        uint256 expiryTimestamp;
        (rewardBps, rebateBps, expiryTimestamp, epoch) = readBRRData();

        
        if (now > expiryTimestamp && kyberDao != IKyberDao(0)) {
            uint256 burnBps;

            (burnBps, rewardBps, rebateBps, epoch, expiryTimestamp) = kyberDao
                .getLatestBRRDataWithCache();
            require(burnBps.add(rewardBps).add(rebateBps) == BPS, "Bad BRR values");
            
            emit BRRUpdated(rewardBps, rebateBps, burnBps, expiryTimestamp, epoch);

            
            updateBRRData(rewardBps, rebateBps, expiryTimestamp, epoch);
        }
    }

    function readBRRData()
        public
        view
        returns (
            uint256 rewardBps,
            uint256 rebateBps,
            uint256 expiryTimestamp,
            uint256 epoch
        )
    {
        rewardBps = uint256(brrAndEpochData.rewardBps);
        rebateBps = uint256(brrAndEpochData.rebateBps);
        epoch = uint256(brrAndEpochData.epoch);
        expiryTimestamp = uint256(brrAndEpochData.expiryTimestamp);
    }

    function updateBRRData(
        uint256 reward,
        uint256 rebate,
        uint256 expiryTimestamp,
        uint256 epoch
    ) internal {
        
        require(expiryTimestamp < 2**64, "expiry timestamp overflow");
        require(epoch < 2**32, "epoch overflow");

        brrAndEpochData.rewardBps = uint16(reward);
        brrAndEpochData.rebateBps = uint16(rebate);
        brrAndEpochData.expiryTimestamp = uint64(expiryTimestamp);
        brrAndEpochData.epoch = uint32(epoch);
    }

    function getRRWeiValues(uint256 RRAmountWei)
        internal
        returns (
            uint256 rewardWei,
            uint256 rebateWei,
            uint256 epoch
        )
    {
        
        uint256 rewardInBps;
        uint256 rebateInBps;
        (rewardInBps, rebateInBps, epoch) = getBRR();

        rebateWei = RRAmountWei.mul(rebateInBps).div(BPS);
        rewardWei = RRAmountWei.mul(rewardInBps).div(BPS);
    }

    function updateRebateValues(
        uint256 rebateWei,
        address[] memory rebateWallets,
        uint256[] memory rebateBpsPerWallet
    ) internal returns (uint256 totalRebatePaidWei) {
        uint256 totalRebateBps;
        uint256 walletRebateWei;

        for (uint256 i = 0; i < rebateWallets.length; i++) {
            require(rebateWallets[i] != address(0), "rebate wallet address 0");

            walletRebateWei = rebateWei.mul(rebateBpsPerWallet[i]).div(BPS);
            rebatePerWallet[rebateWallets[i]] = rebatePerWallet[rebateWallets[i]].add(
                walletRebateWei
            );

            
            totalRebatePaidWei = totalRebatePaidWei.add(walletRebateWei);
            totalRebateBps = totalRebateBps.add(rebateBpsPerWallet[i]);
        }

        require(totalRebateBps <= BPS, "rebates more then 100%");
    }

    function validateEthToKncRateToBurn(uint256 rateEthToKnc) internal view {
        require(rateEthToKnc <= MAX_RATE, "ethToKnc rate out of bounds");
        require(rateEthToKnc > 0, "ethToKnc rate is 0");
        require(sanityRateContract.length > 0, "no sanity rate contract");
        require(sanityRateContract[0] != ISanityRate(0), "sanity rate is 0x0, burning is blocked");

        
        uint256 kncToEthRate = sanityRateContract[0].latestAnswer();
        require(kncToEthRate > 0, "sanity rate is 0");
        require(kncToEthRate <= MAX_RATE, "sanity rate out of bounds");

        uint256 sanityEthToKncRate = PRECISION.mul(PRECISION).div(kncToEthRate);

        
        require(
            rateEthToKnc.mul(BPS) >= sanityEthToKncRate.mul(BPS.sub(SANITY_RATE_DIFF_BPS)),
            "kyberNetwork eth to knc rate too low"
        );
    }
}