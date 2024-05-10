pragma solidity 0.5.16;


interface MassetStructs {

    
    struct Basket {

        
        Basset[] bassets;

        
        uint8 maxBassets;

        
        bool undergoingRecol;

        
        bool failed;
        uint256 collateralisationRatio;

    }

    
    struct Basset {

        
        address addr;

        
        BassetStatus status; 

        
        bool isTransferFeeCharged; 

        
        uint256 ratio;

        
        uint256 maxWeight;

        
        uint256 vaultBalance;

    }

    
    enum BassetStatus {
        Default,
        Normal,
        BrokenBelowPeg,
        BrokenAbovePeg,
        Blacklisted,
        Liquidating,
        Liquidated,
        Failed
    }

    
    struct BassetDetails {
        Basset bAsset;
        address integrator;
        uint8 index;
    }

    
    struct ForgePropsMulti {
        bool isValid; 
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }

    
    struct RedeemPropsMulti {
        uint256 colRatio;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
}

contract IMasset is MassetStructs {

    
    function collectInterest() external returns (uint256 massetMinted, uint256 newTotalSupply);

    
    function mint(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetMinted);
    function mintTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);
    function mintMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);

    
    function swap( address _input, address _output, uint256 _quantity, address _recipient)
        external returns (uint256 output);
    function getSwapOutput( address _input, address _output, uint256 _quantity)
        external view returns (bool, string memory, uint256 output);

    
    function redeem(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetRedeemed);
    function redeemTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetRedeemed);
    function redeemMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantities, address _recipient)
        external returns (uint256 massetRedeemed);
    function redeemMasset(uint256 _mAssetQuantity, address _recipient) external;

    
    function upgradeForgeValidator(address _newForgeValidator) external;

    
    function setSwapFee(uint256 _swapFee) external;

    
    function getBasketManager() external view returns(address);
}

interface ISavingsContract {

    
    function depositInterest(uint256 _amount) external;

    
    function depositSavings(uint256 _amount) external returns (uint256 creditsIssued);
    function redeem(uint256 _amount) external returns (uint256 massetReturned);

}

interface ISavingsManager {

    
    function withdrawUnallocatedInterest(address _mAsset, address _recipient) external;

    
    function collectAndDistributeInterest(address _mAsset) external;

}

contract ModuleKeys {

    
    
                                                
    
    bytes32 internal constant KEY_GOVERNANCE = 0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    
    bytes32 internal constant KEY_STAKING = 0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    
    bytes32 internal constant KEY_PROXY_ADMIN = 0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    
    
    
    bytes32 internal constant KEY_ORACLE_HUB = 0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    
    bytes32 internal constant KEY_MANAGER = 0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    
    bytes32 internal constant KEY_RECOLLATERALISER = 0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    
    bytes32 internal constant KEY_META_TOKEN = 0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    
    bytes32 internal constant KEY_SAVINGS_MANAGER = 0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
}

interface INexus {
    function governor() external view returns (address);
    function getModule(bytes32 key) external view returns (address);

    function proposeModule(bytes32 _key, address _addr) external;
    function cancelProposedModule(bytes32 _key) external;
    function acceptProposedModule(bytes32 _key) external;
    function acceptProposedModules(bytes32[] calldata _keys) external;

    function requestLockModule(bytes32 _key) external;
    function cancelLockModule(bytes32 _key) external;
    function lockModule(bytes32 _key) external;
}

contract Module is ModuleKeys {

    INexus public nexus;

    
    constructor(address _nexus) internal {
        require(_nexus != address(0), "Nexus is zero address");
        nexus = INexus(_nexus);
    }

    
    modifier onlyGovernor() {
        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    
    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    
    modifier onlyProxyAdmin() {
        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    
    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    
    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    
    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    
    function _staking() internal view returns (address) {
        return nexus.getModule(KEY_STAKING);
    }

    
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    
    function _metaToken() internal view returns (address) {
        return nexus.getModule(KEY_META_TOKEN);
    }

    
    function _oracleHub() internal view returns (address) {
        return nexus.getModule(KEY_ORACLE_HUB);
    }

    
    function _manager() internal view returns (address) {
        return nexus.getModule(KEY_MANAGER);
    }

    
    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    
    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }
}

contract PausableModule is Module {

    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused = false;

    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    constructor (address _nexus) internal Module(_nexus) {
        _paused = false;
    }

    
    function paused() external view returns (bool) {
        return _paused;
    }

    
    function pause() external onlyGovernor whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function unpause() external onlyGovernor whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
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

    
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

library StableMath {

    using SafeMath for uint256;

    
    uint256 private constant FULL_SCALE = 1e18;

    
    uint256 private constant RATIO_SCALE = 1e8;

    
    function getFullScale() internal pure returns (uint256) {
        return FULL_SCALE;
    }

    
    function getRatioScale() internal pure returns (uint256) {
        return RATIO_SCALE;
    }

    
    function scaleInteger(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return x.mul(FULL_SCALE);
    }

    

    
    function mulTruncate(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return mulTruncateScale(x, y, FULL_SCALE);
    }

    
    function mulTruncateScale(uint256 x, uint256 y, uint256 scale)
        internal
        pure
        returns (uint256)
    {
        
        
        uint256 z = x.mul(y);
        
        return z.div(scale);
    }

    
    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        
        uint256 scaled = x.mul(y);
        
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        
        return ceil.div(FULL_SCALE);
    }

    
    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        
        uint256 z = x.mul(FULL_SCALE);
        
        return z.div(y);
    }


    

    
    function mulRatioTruncate(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {
        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    
    function mulRatioTruncateCeil(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256)
    {
        
        
        uint256 scaled = x.mul(ratio);
        
        uint256 ceil = scaled.add(RATIO_SCALE.sub(1));
        
        return ceil.div(RATIO_SCALE);
    }


    
    function divRatioPrecisely(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {
        
        uint256 y = x.mul(RATIO_SCALE);
        
        return y.div(ratio);
    }

    

    
    function min(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return x > y ? y : x;
    }

    
    function max(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return x > y ? x : y;
    }

    
    function clamp(uint256 x, uint256 upperBound)
        internal
        pure
        returns (uint256)
    {
        return x > upperBound ? upperBound : x;
    }
}


contract SavingsManager is ISavingsManager, PausableModule {

    using SafeMath for uint256;
    using StableMath for uint256;
    using SafeERC20 for IERC20;

    
    event SavingsContractAdded(address indexed mAsset, address savingsContract);
    event SavingsContractUpdated(address indexed mAsset, address savingsContract);
    event SavingsRateChanged(uint256 newSavingsRate);
    
    event InterestCollected(address indexed mAsset, uint256 interest, uint256 newTotalSupply, uint256 apy);
    event InterestDistributed(address indexed mAsset, uint256 amountSent);
    event InterestWithdrawnByGovernor(address indexed mAsset, address recipient, uint256 amount);

    
    mapping(address => ISavingsContract) public savingsContracts;
    struct SupplyLog {
        uint256 timestamp;
        uint256 supply;
    }
    
    mapping(address => SupplyLog) public recentSupplyLog; 
    mapping(address => SupplyLog) public benchmarkSupplyLog; 

    
    uint256 private savingsRate = 1e18;
    
    uint256 constant private SECONDS_IN_YEAR = 365 days;
    
    uint256 constant private MAX_APY = 2e18;

    constructor(
        address _nexus,
        address _mUSD,
        address _savingsContract
    )
        public
        PausableModule(_nexus)
    {
        _updateSavingsContract(_mUSD, _savingsContract);

        uint256 totalSupply = IERC20(_mUSD).totalSupply();
        recentSupplyLog[_mUSD] = SupplyLog({ timestamp: block.timestamp, supply: totalSupply});
        benchmarkSupplyLog[_mUSD] = SupplyLog({ timestamp: block.timestamp, supply: totalSupply});

        emit SavingsContractAdded(_mUSD, _savingsContract);
    }

    

    
    function addSavingsContract(address _mAsset, address _savingsContract)
        external
        onlyGovernor
    {
        require(address(savingsContracts[_mAsset]) == address(0), "Savings contract already exists");
        _updateSavingsContract(_mAsset, _savingsContract);

        uint256 totalSupply = IERC20(_mAsset).totalSupply();
        recentSupplyLog[_mAsset] = SupplyLog({ timestamp: block.timestamp, supply: totalSupply});
        benchmarkSupplyLog[_mAsset] = SupplyLog({ timestamp: block.timestamp, supply: totalSupply});

        emit SavingsContractAdded(_mAsset, _savingsContract);
    }

    
    function updateSavingsContract(address _mAsset, address _savingsContract)
        external
        onlyGovernor
    {
        require(address(savingsContracts[_mAsset]) != address(0), "Savings contract does not exist");
        _updateSavingsContract(_mAsset, _savingsContract);
        emit SavingsContractUpdated(_mAsset, _savingsContract);
    }

    function _updateSavingsContract(address _mAsset, address _savingsContract)
        internal
    {
        require(_mAsset != address(0) && _savingsContract != address(0), "Must be valid address");
        savingsContracts[_mAsset] = ISavingsContract(_savingsContract);

        IERC20(_mAsset).safeApprove(address(_savingsContract), 0);
        IERC20(_mAsset).safeApprove(address(_savingsContract), uint256(-1));
    }

    
    function setSavingsRate(uint256 _savingsRate)
        external
        onlyGovernor
    {
        
        require(_savingsRate > 9e17 && _savingsRate <= 1e18, "Must be a valid rate");
        savingsRate = _savingsRate;
        emit SavingsRateChanged(_savingsRate);
    }

    

    
    function collectAndDistributeInterest(address _mAsset)
        external
        whenNotPaused
    {
        ISavingsContract savingsContract = savingsContracts[_mAsset];
        require(address(savingsContract) != address(0), "Must have a valid savings contract");

        SupplyLog memory recentSupply = recentSupplyLog[_mAsset];

        
        IMasset mAsset = IMasset(_mAsset);
        (uint256 interestCollected, uint256 totalSupply) = mAsset.collectInterest();

        
        if(block.timestamp > recentSupply.timestamp.add(24 hours)) {
            recentSupplyLog[_mAsset] = SupplyLog({timestamp: block.timestamp, supply: totalSupply});
            benchmarkSupplyLog[_mAsset] = recentSupply;
        }

        if(interestCollected > 0) {

            
            require(
                IERC20(_mAsset).balanceOf(address(this)) >= interestCollected,
                "Must receive mUSD"
            );

            SupplyLog memory benchmarkSupply = benchmarkSupplyLog[_mAsset];

            
            uint256 secondsSinceBenchmark = now.sub(benchmarkSupply.timestamp);
            
            
            uint256 yearsSinceBenchmark =
                secondsSinceBenchmark.divPrecisely(SECONDS_IN_YEAR);
            
            
            
            uint256 benchmarkSupplyUnits = benchmarkSupply.supply;
            uint256 supplyIncreaseSinceBenchmark = totalSupply.sub(benchmarkSupplyUnits);
            uint256 percentageIncrease = supplyIncreaseSinceBenchmark.divPrecisely(benchmarkSupplyUnits);
            
            
            uint256 extrapolatedAPY = percentageIncrease.divPrecisely(yearsSinceBenchmark);

            require(extrapolatedAPY < MAX_APY, "Interest protected from inflating past maxAPY");

            emit InterestCollected(_mAsset, interestCollected, totalSupply, extrapolatedAPY);

            
            
            uint256 saversShare = interestCollected.mulTruncate(savingsRate);

            
            savingsContract.depositInterest(saversShare);

            emit InterestDistributed(_mAsset, saversShare);
        } else {
            emit InterestCollected(_mAsset, 0, totalSupply, 0);
        }
    }

    

    
    function withdrawUnallocatedInterest(address _mAsset, address _recipient)
        external
        onlyGovernor
    {
        IERC20 mAsset = IERC20(_mAsset);
        uint256 balance = mAsset.balanceOf(address(this));

        emit InterestWithdrawnByGovernor(_mAsset, _recipient, balance);

        mAsset.safeTransfer(_recipient, balance);
    }
}