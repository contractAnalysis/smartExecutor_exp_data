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



interface IKyberStaking is IEpochUtils {
    event Delegated(
        address indexed staker,
        address indexed representative,
        uint256 indexed epoch,
        bool isDelegated
    );
    event Deposited(uint256 curEpoch, address indexed staker, uint256 amount);
    event Withdraw(uint256 indexed curEpoch, address indexed staker, uint256 amount);

    function initAndReturnStakerDataForCurrentEpoch(address staker)
        external
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );

    function deposit(uint256 amount) external;

    function delegate(address dAddr) external;

    function withdraw(uint256 amount) external;

    
    function getStakerData(address staker, uint256 epoch)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );

    function getLatestStakerData(address staker)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );

    
    function getStakerRawData(address staker, uint256 epoch)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );
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



contract EpochUtils is IEpochUtils {
    using SafeMath for uint256;

    uint256 public override epochPeriodInSeconds;
    uint256 public override firstEpochStartTimestamp;

    function getCurrentEpochNumber() public view override returns (uint256) {
        return getEpochNumber(now);
    }

    function getEpochNumber(uint256 timestamp) public view override returns (uint256) {
        if (timestamp < firstEpochStartTimestamp || epochPeriodInSeconds == 0) {
            return 0;
        }
        
        return ((timestamp.sub(firstEpochStartTimestamp)).div(epochPeriodInSeconds)).add(1);
    }
}



pragma solidity 0.6.6;








contract KyberStaking is IKyberStaking, EpochUtils, ReentrancyGuard {
    struct StakerData {
        uint256 stake;
        uint256 delegatedStake;
        address representative;
    }

    IERC20 public immutable kncToken;
    IKyberDao public immutable kyberDao;

    
    mapping(uint256 => mapping(address => StakerData)) internal stakerPerEpochData;
    
    mapping(address => StakerData) internal stakerLatestData;
    
    mapping(uint256 => mapping(address => bool)) internal hasInited;

    
    
    event WithdrawDataUpdateFailed(uint256 curEpoch, address staker, uint256 amount);

    constructor(
        IERC20 _kncToken,
        uint256 _epochPeriod,
        uint256 _startTimestamp,
        IKyberDao _kyberDao
    ) public {
        require(_epochPeriod > 0, "ctor: epoch period is 0");
        require(_startTimestamp >= now, "ctor: start in the past");
        require(_kncToken != IERC20(0), "ctor: kncToken 0");
        require(_kyberDao != IKyberDao(0), "ctor: kyberDao 0");

        epochPeriodInSeconds = _epochPeriod;
        firstEpochStartTimestamp = _startTimestamp;
        kncToken = _kncToken;
        kyberDao = _kyberDao;
    }

    
    function delegate(address newRepresentative) external override {
        require(newRepresentative != address(0), "delegate: representative 0");
        address staker = msg.sender;
        uint256 curEpoch = getCurrentEpochNumber();

        initDataIfNeeded(staker, curEpoch);

        address curRepresentative = stakerPerEpochData[curEpoch + 1][staker].representative;
        
        if (newRepresentative == curRepresentative) {
            return;
        }

        uint256 updatedStake = stakerPerEpochData[curEpoch + 1][staker].stake;

        
        if (curRepresentative != staker) {
            initDataIfNeeded(curRepresentative, curEpoch);

            stakerPerEpochData[curEpoch + 1][curRepresentative].delegatedStake =
                stakerPerEpochData[curEpoch + 1][curRepresentative].delegatedStake.sub(updatedStake);
            stakerLatestData[curRepresentative].delegatedStake =
                stakerLatestData[curRepresentative].delegatedStake.sub(updatedStake);

            emit Delegated(staker, curRepresentative, curEpoch, false);
        }

        stakerLatestData[staker].representative = newRepresentative;
        stakerPerEpochData[curEpoch + 1][staker].representative = newRepresentative;

        
        if (newRepresentative != staker) {
            initDataIfNeeded(newRepresentative, curEpoch);
            stakerPerEpochData[curEpoch + 1][newRepresentative].delegatedStake =
                stakerPerEpochData[curEpoch + 1][newRepresentative].delegatedStake.add(updatedStake);
            stakerLatestData[newRepresentative].delegatedStake =
                stakerLatestData[newRepresentative].delegatedStake.add(updatedStake);
            emit Delegated(staker, newRepresentative, curEpoch, true);
        }
    }

    
    function deposit(uint256 amount) external override {
        require(amount > 0, "deposit: amount is 0");

        uint256 curEpoch = getCurrentEpochNumber();
        address staker = msg.sender;

        
        require(
            kncToken.transferFrom(staker, address(this), amount),
            "deposit: can not get token"
        );

        initDataIfNeeded(staker, curEpoch);

        stakerPerEpochData[curEpoch + 1][staker].stake =
            stakerPerEpochData[curEpoch + 1][staker].stake.add(amount);
        stakerLatestData[staker].stake =
            stakerLatestData[staker].stake.add(amount);

        
        address representative = stakerPerEpochData[curEpoch + 1][staker].representative;
        if (representative != staker) {
            initDataIfNeeded(representative, curEpoch);
            stakerPerEpochData[curEpoch + 1][representative].delegatedStake =
                stakerPerEpochData[curEpoch + 1][representative].delegatedStake.add(amount);
            stakerLatestData[representative].delegatedStake =
                stakerLatestData[representative].delegatedStake.add(amount);
        }

        emit Deposited(curEpoch, staker, amount);
    }

    
    function withdraw(uint256 amount) external override nonReentrant {
        require(amount > 0, "withdraw: amount is 0");

        uint256 curEpoch = getCurrentEpochNumber();
        address staker = msg.sender;

        require(
            stakerLatestData[staker].stake >= amount,
            "withdraw: latest amount staked < withdrawal amount"
        );

        (bool success, ) = address(this).call(
            abi.encodeWithSignature(
                "handleWithdrawal(address,uint256,uint256)",
                staker,
                amount,
                curEpoch
            )
        );
        if (!success) {
            
            emit WithdrawDataUpdateFailed(curEpoch, staker, amount);
        }

        stakerLatestData[staker].stake = stakerLatestData[staker].stake.sub(amount);

        
        require(kncToken.transfer(staker, amount), "withdraw: can not transfer knc");
        emit Withdraw(curEpoch, staker, amount);
    }

    
    function initAndReturnStakerDataForCurrentEpoch(address staker)
        external
        override
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        )
    {
        require(
            msg.sender == address(kyberDao),
            "initAndReturnData: only kyberDao"
        );

        uint256 curEpoch = getCurrentEpochNumber();
        initDataIfNeeded(staker, curEpoch);

        StakerData memory stakerData = stakerPerEpochData[curEpoch][staker];
        stake = stakerData.stake;
        delegatedStake = stakerData.delegatedStake;
        representative = stakerData.representative;
    }

    
    function getStakerRawData(address staker, uint256 epoch)
        external
        view
        override
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        )
    {
        StakerData memory stakerData = stakerPerEpochData[epoch][staker];
        stake = stakerData.stake;
        delegatedStake = stakerData.delegatedStake;
        representative = stakerData.representative;
    }

    
    function getStake(address staker, uint256 epoch) external view returns (uint256) {
        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch > curEpoch + 1) {
            return 0;
        }
        uint256 i = epoch;
        while (true) {
            if (hasInited[i][staker]) {
                return stakerPerEpochData[i][staker].stake;
            }
            if (i == 0) {
                break;
            }
            i--;
        }
        return 0;
    }

    
    function getDelegatedStake(address staker, uint256 epoch) external view returns (uint256) {
        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch > curEpoch + 1) {
            return 0;
        }
        uint256 i = epoch;
        while (true) {
            if (hasInited[i][staker]) {
                return stakerPerEpochData[i][staker].delegatedStake;
            }
            if (i == 0) {
                break;
            }
            i--;
        }
        return 0;
    }

    
    function getRepresentative(address staker, uint256 epoch) external view returns (address) {
        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch > curEpoch + 1) {
            return address(0);
        }
        uint256 i = epoch;
        while (true) {
            if (hasInited[i][staker]) {
                return stakerPerEpochData[i][staker].representative;
            }
            if (i == 0) {
                break;
            }
            i--;
        }
        
        return staker;
    }

    
    function getStakerData(address staker, uint256 epoch)
        external view override
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        )
    {
        stake = 0;
        delegatedStake = 0;
        representative = address(0);

        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch > curEpoch + 1) {
            return (stake, delegatedStake, representative);
        }
        uint256 i = epoch;
        while (true) {
            if (hasInited[i][staker]) {
                stake = stakerPerEpochData[i][staker].stake;
                delegatedStake = stakerPerEpochData[i][staker].delegatedStake;
                representative = stakerPerEpochData[i][staker].representative;
                return (stake, delegatedStake, representative);
            }
            if (i == 0) {
                break;
            }
            i--;
        }
        
        representative = staker;
    }

    function getLatestRepresentative(address staker) external view returns (address) {
        return
            stakerLatestData[staker].representative == address(0)
                ? staker
                : stakerLatestData[staker].representative;
    }

    function getLatestDelegatedStake(address staker) external view returns (uint256) {
        return stakerLatestData[staker].delegatedStake;
    }

    function getLatestStakeBalance(address staker) external view returns (uint256) {
        return stakerLatestData[staker].stake;
    }

    function getLatestStakerData(address staker)
        external view override
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        )
    {
        stake = stakerLatestData[staker].stake;
        delegatedStake = stakerLatestData[staker].delegatedStake;
        representative = stakerLatestData[staker].representative == address(0)
                ? staker
                : stakerLatestData[staker].representative;
    }

    
    function handleWithdrawal(
        address staker,
        uint256 amount,
        uint256 curEpoch
    ) external {
        require(msg.sender == address(this), "only staking contract");
        initDataIfNeeded(staker, curEpoch);
        
        
        stakerPerEpochData[curEpoch + 1][staker].stake =
            stakerPerEpochData[curEpoch + 1][staker].stake.sub(amount);

        address representative = stakerPerEpochData[curEpoch][staker].representative;
        uint256 curStake = stakerPerEpochData[curEpoch][staker].stake;
        uint256 lStakeBal = stakerLatestData[staker].stake.sub(amount);
        uint256 newStake = curStake.min(lStakeBal);
        uint256 reduceAmount = curStake.sub(newStake); 

        if (reduceAmount > 0) {
            if (representative != staker) {
                initDataIfNeeded(representative, curEpoch);
                
                stakerPerEpochData[curEpoch][representative].delegatedStake =
                    stakerPerEpochData[curEpoch][representative].delegatedStake.sub(reduceAmount);
            }
            stakerPerEpochData[curEpoch][staker].stake = newStake;
            
            if (address(kyberDao) != address(0)) {
                
                (bool success, ) = address(kyberDao).call(
                    abi.encodeWithSignature(
                        "handleWithdrawal(address,uint256)",
                        representative,
                        reduceAmount
                    )
                );
                if (!success) {
                    emit WithdrawDataUpdateFailed(curEpoch, staker, amount);
                }
            }
        }
        representative = stakerPerEpochData[curEpoch + 1][staker].representative;
        if (representative != staker) {
            initDataIfNeeded(representative, curEpoch);
            stakerPerEpochData[curEpoch + 1][representative].delegatedStake =
                stakerPerEpochData[curEpoch + 1][representative].delegatedStake.sub(amount);
            stakerLatestData[representative].delegatedStake =
                stakerLatestData[representative].delegatedStake.sub(amount);
        }
    }

    
    function initDataIfNeeded(address staker, uint256 epoch) internal {
        address representative = stakerLatestData[staker].representative;
        if (representative == address(0)) {
            
            stakerLatestData[staker].representative = staker;
            representative = staker;
        }

        uint256 ldStake = stakerLatestData[staker].delegatedStake;
        uint256 lStakeBal = stakerLatestData[staker].stake;

        if (!hasInited[epoch][staker]) {
            hasInited[epoch][staker] = true;
            StakerData storage stakerData = stakerPerEpochData[epoch][staker];
            stakerData.representative = representative;
            stakerData.delegatedStake = ldStake;
            stakerData.stake = lStakeBal;
        }

        
        
        if (!hasInited[epoch + 1][staker]) {
            hasInited[epoch + 1][staker] = true;
            StakerData storage nextEpochStakerData = stakerPerEpochData[epoch + 1][staker];
            nextEpochStakerData.representative = representative;
            nextEpochStakerData.delegatedStake = ldStake;
            nextEpochStakerData.stake = lStakeBal;
        }
    }
}