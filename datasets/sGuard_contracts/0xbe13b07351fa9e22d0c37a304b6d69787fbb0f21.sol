pragma solidity 0.5.16;

interface IPriceOracle {
    function getExpectedReturn(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 parts,
        uint256 disableFlags 
    ) external view returns(
        uint256 returnAmount,
        uint[4] memory distribution 
    );
}



interface ISoftETHToken {
    function burn(uint256 _amount) external;
    function mint(address _account, uint256 _amount) external returns(bool);
    function totalSupply() external view returns(uint256);
}



interface IExitToken {
    function mint(address _account, uint256 _amount) external returns(bool);
    function totalSupply() external view returns(uint256);
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
    
    
    
    
    
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}



contract Reward is Initializable {
    using SafeMath for uint256;

    

    
    

    
    uint256 public lastStakingEpochFinished;

    
    
    address public staker;

    
    address public currencyRateChanger;

    
    IExitToken public exitToken;

    
    ISoftETHToken public softETHToken;

    
    
    uint256 public ethUsd;

    
    
    uint256 public stakeUsd;

    

    
    
    uint256 public constant EXIT_MINT_RATE = 10; 

    
    
    uint256 public constant COLLATERAL_MULTIPLIER = 2;

    

    
    
    
    event Rebalanced(uint256 newTotalSupply, address indexed caller);

    
    
    
    
    
    event StakingEpochFinished(
        uint256 indexed stakingEpoch,
        uint256 totalStakeAmount,
        uint256 exitMintAmount,
        address indexed caller
    );

    

    
    modifier ifCurrencyRateChanger() {
        require(msg.sender == currencyRateChanger);
        _;
    }

    

    
    
    
    
    
    
    function finishStakingEpoch(uint256 _totalStakeAmount) public {
        require(exitToken != IExitToken(0));
        require(staker != address(0));
        require(stakeUsd != 0);

        uint256 usdAmount = _totalStakeAmount.mul(stakeUsd).div(100);
        uint256 mintAmount = usdAmount.mul(EXIT_MINT_RATE).div(100);
        exitToken.mint(staker, mintAmount);
        rebalance();

        lastStakingEpochFinished++;

        emit StakingEpochFinished(lastStakingEpochFinished, _totalStakeAmount, mintAmount, msg.sender);
    }

    
    
    
    
    
    function initialize(
        address _staker,
        address _currencyRateChanger,
        IExitToken _exitToken,
        ISoftETHToken _softETHToken
    ) public initializer {
        require(_admin() != address(0)); 
        require(_staker != address(0));
        require(_currencyRateChanger != address(0));
        require(_exitToken != IExitToken(0));
        require(_softETHToken != ISoftETHToken(0));
        staker = _staker;
        currencyRateChanger = _currencyRateChanger;
        exitToken = _exitToken;
        softETHToken = _softETHToken;
    }

    
    
    
    function rebalance() public {
        require(exitToken != IExitToken(0));
        require(softETHToken != ISoftETHToken(0));

        uint256 ethInUSD = usdEthCurrent(); 
        require(ethInUSD != 0);
        
        
        uint256 currentSupply = softETHCurrentSupply();
        uint256 expectedSupply = _softETHExpectedSupply(ethInUSD);

        if (expectedSupply > currentSupply) {
            
            softETHToken.mint(address(this), expectedSupply - currentSupply);
        } else if (expectedSupply < currentSupply) {
            
            softETHToken.burn(currentSupply - expectedSupply);
        }

        ethUsd = 100 ether / ethInUSD;

        emit Rebalanced(expectedSupply, msg.sender);
    }

    
    
    
    
    function setSTAKEUSD(uint256 _cents) public ifCurrencyRateChanger {
        require(_cents != 0);
        stakeUsd = _cents;
    }

    

    
    
    function ethUsdCurrent() public view returns(uint256) {
        uint256 ethers = usdEthCurrent();
        if (ethers == 0) return 0;
        return 100 ether / ethers;
    }

    
    function exitCurrentSupply() public view returns(uint256) {
        return exitToken.totalSupply();
    }

    
    
    function usdEthCurrent() public view returns(uint256) {
        (uint256 returnAmount,) = IPriceOracle(PRICE_ORACLE).getExpectedReturn(
            0xdAC17F958D2ee523a2206206994597C13D831ec7, 
            0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 
            1000000, 
            1, 
            0  
        );
        return returnAmount;
    }

    
    function softETHCurrentSupply() public view returns(uint256) {
        return softETHToken.totalSupply();
    }

    
    
    
    function softETHExpectedSupply() public view returns(uint256) {
        return _softETHExpectedSupply(usdEthCurrent());
    }

    
    function getCurrentDataBatch() public view returns(
        uint256 _ethUsd,
        uint256 _ethUsdCurrent,
        uint256 _exitCurrentSupply,
        uint256 _lastStakingEpochFinished,
        uint256 _softETHCurrentSupply,
        uint256 _softETHExpectedSupply,
        uint256 _stakeUsd
    ) {
        _ethUsd = ethUsd;
        _ethUsdCurrent = ethUsdCurrent();
        _exitCurrentSupply = exitCurrentSupply();
        _lastStakingEpochFinished = lastStakingEpochFinished;
        _softETHCurrentSupply = softETHCurrentSupply();
        _softETHExpectedSupply = softETHExpectedSupply();
        _stakeUsd = stakeUsd;
    }

    

    
    address internal constant PRICE_ORACLE = 0xAd13fE330B0aE312bC51d2E5B9Ca2ae3973957C7;

    
    function _admin() internal view returns(address adm) {
        
        
        bytes32 slot = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
        assembly {
            adm := sload(slot)
        }
    }

    
    
    
    
    function _softETHExpectedSupply(uint256 _ethInUSD) internal view returns(uint256) {
        return exitToken.totalSupply().mul(COLLATERAL_MULTIPLIER).mul(_ethInUSD).div(1 ether);
    }

}