pragma solidity ^0.5.16;



contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


interface IAddressResolver {
    function getAddress(bytes32 name) external view returns (address);

    function getSynth(bytes32 key) external view returns (address);

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);
}


interface ISynth {
    
    function currencyKey() external view returns (bytes32);

    function transferableSynths(address account) external view returns (uint);

    
    function transferAndSettle(address to, uint value) external returns (bool);

    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);

    
    function burn(address account, uint amount) external;

    function issue(address account, uint amount) external;
}


interface IIssuer {
    
    function anySynthOrSNXRateIsStale() external view returns (bool anyRateStale);

    function availableCurrencyKeys() external view returns (bytes32[] memory);

    function availableSynthCount() external view returns (uint);

    function availableSynths(uint index) external view returns (ISynth);

    function canBurnSynths(address account) external view returns (bool);

    function collateral(address account) external view returns (uint);

    function collateralisationRatio(address issuer) external view returns (uint);

    function collateralisationRatioAndAnyRatesStale(address _issuer)
        external
        view
        returns (uint cratio, bool anyRateIsStale);

    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint debtBalance);

    function lastIssueEvent(address account) external view returns (uint);

    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);

    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );

    function synths(bytes32 currencyKey) external view returns (ISynth);

    function synthsByAddress(address synthAddress) external view returns (bytes32);

    function totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral) external view returns (uint);

    function transferableSynthetixAndAnyRateIsStale(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsStale);

    
    function issueSynths(address from, uint amount) external;

    function issueSynthsOnBehalf(
        address issueFor,
        address from,
        uint amount
    ) external;

    function issueMaxSynths(address from) external;

    function issueMaxSynthsOnBehalf(address issueFor, address from) external;

    function burnSynths(address from, uint amount) external;

    function burnSynthsOnBehalf(
        address burnForAddress,
        address from,
        uint amount
    ) external;

    function burnSynthsToTarget(address from) external;

    function burnSynthsToTargetOnBehalf(address burnForAddress, address from) external;

    function liquidateDelinquentAccount(address account, uint susdAmount, address liquidator) external returns (uint totalRedeemed, uint amountToLiquidate);
}






contract AddressResolver is Owned, IAddressResolver {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}

    

    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }

    

    function getAddress(bytes32 name) external view returns (address) {
        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {
        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getSynth(bytes32 key) external view returns (address) {
        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.synths(key));
    }
}









contract MixinResolver is Owned {
    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    bytes32[] public resolverAddressesRequired;

    uint public constant MAX_ADDRESSES_FROM_RESOLVER = 24;

    constructor(address _resolver, bytes32[MAX_ADDRESSES_FROM_RESOLVER] memory _addressesToCache) internal {
        
        require(owner != address(0), "Owner must be set");

        for (uint i = 0; i < _addressesToCache.length; i++) {
            if (_addressesToCache[i] != bytes32(0)) {
                resolverAddressesRequired.push(_addressesToCache[i]);
            } else {
                
                
                break;
            }
        }
        resolver = AddressResolver(_resolver);
        
    }

    
    function setResolverAndSyncCache(AddressResolver _resolver) external onlyOwner {
        resolver = _resolver;

        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            
            addressCache[name] = resolver.requireAndGetAddress(name, "Resolver missing target");
        }
    }

    

    function requireAndGetAddress(bytes32 name, string memory reason) internal view returns (address) {
        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    
    
    function isResolverCached(AddressResolver _resolver) external view returns (bool) {
        if (resolver != _resolver) {
            return false;
        }

        
        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    
    function getResolverAddressesRequired()
        external
        view
        returns (bytes32[MAX_ADDRESSES_FROM_RESOLVER] memory addressesRequired)
    {
        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            addressesRequired[i] = resolverAddressesRequired[i];
        }
    }

    
    function appendToAddressCache(bytes32 name) internal {
        resolverAddressesRequired.push(name);
        require(resolverAddressesRequired.length < MAX_ADDRESSES_FROM_RESOLVER, "Max resolver cache size met");
        
        
        addressCache[name] = resolver.getAddress(name);
    }
}


interface IBinaryOptionMarketManager {
    

    function fees() external view returns (uint poolFee, uint creatorFee, uint refundFee);
    function durations() external view returns (uint maxOraclePriceAge, uint expiryDuration, uint maxTimeToMaturity);
    function creatorLimits() external view returns (uint capitalRequirement, uint skewLimit);

    function marketCreationEnabled() external view returns (bool);
    function totalDeposited() external view returns (uint);

    function numActiveMarkets() external view returns (uint);
    function activeMarkets(uint index, uint pageSize) external view returns (address[] memory);
    function numMaturedMarkets() external view returns (uint);
    function maturedMarkets(uint index, uint pageSize) external view returns (address[] memory);

    

    function createMarket(
        bytes32 oracleKey, uint strikePrice, bool refundsEnabled,
        uint[2] calldata times, 
        uint[2] calldata bids 
    ) external returns (IBinaryOptionMarket);
    function resolveMarket(address market) external;
    function cancelMarket(address market) external;
    function expireMarkets(address[] calldata market) external;
}


interface IERC20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    
    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    
    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


interface IBinaryOption {
    

    function market() external view returns (IBinaryOptionMarket);

    function bidOf(address account) external view returns (uint);
    function totalBids() external view returns (uint);

    function balanceOf(address account) external view returns (uint);
    function totalSupply() external view returns (uint);

    function claimableBalanceOf(address account) external view returns (uint);
    function totalClaimableSupply() external view returns (uint);
}


interface IBinaryOptionMarket {
    

    enum Phase { Bidding, Trading, Maturity, Expiry }
    enum Side { Long, Short }

    

    function options() external view returns (IBinaryOption long, IBinaryOption short);
    function prices() external view returns (uint long, uint short);
    function times() external view returns (uint biddingEnd, uint maturity, uint destructino);
    function oracleDetails() external view returns (bytes32 key, uint strikePrice, uint finalPrice);
    function fees() external view returns (uint poolFee, uint creatorFee, uint refundFee);
    function creatorLimits() external view returns (uint capitalRequirement, uint skewLimit);

    function deposited() external view returns (uint);
    function creator() external view returns (address);
    function resolved() external view returns (bool);
    function refundsEnabled() external view returns (bool);

    function phase() external view returns (Phase);
    function oraclePriceAndTimestamp() external view returns (uint price, uint updatedAt);
    function canResolve() external view returns (bool);
    function result() external view returns (Side);

    function pricesAfterBidOrRefund(Side side, uint value, bool refund) external view returns (uint long, uint short);
    function bidOrRefundForPrice(Side bidSide, Side priceSide, uint price, bool refund) external view returns (uint);

    function bidsOf(address account) external view returns (uint long, uint short);
    function totalBids() external view returns (uint long, uint short);
    function claimableBalancesOf(address account) external view returns (uint long, uint short);
    function totalClaimableSupplies() external view returns (uint long, uint short);
    function balancesOf(address account) external view returns (uint long, uint short);
    function totalSupplies() external view returns (uint long, uint short);
    function exercisableDeposits() external view returns (uint);

    

    function bid(Side side, uint value) external;
    function refund(Side side, uint value) external returns (uint refundMinusFee);

    function claimOptions() external returns (uint longClaimed, uint shortClaimed);
    function exerciseOptions() external returns (uint);
}



library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}






library SafeDecimalMath {
    using SafeMath for uint;

    
    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    
    uint public constant UNIT = 10**uint(decimals);

    
    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    
    function unit() external pure returns (uint) {
        return UNIT;
    }

    
    function preciseUnit() external pure returns (uint) {
        return PRECISE_UNIT;
    }

    
    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {
        
        return x.mul(y) / UNIT;
    }

    
    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {
        
        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    
    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    
    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, UNIT);
    }

    
    function divideDecimal(uint x, uint y) internal pure returns (uint) {
        
        return x.mul(UNIT).div(y);
    }

    
    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {
        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    
    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, UNIT);
    }

    
    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    
    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {
        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    
    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {
        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }
}






contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;

    constructor() internal {
        
        require(owner != address(0), "Owner must be set");
        
    }

    
    function setPaused(bool _paused) external onlyOwner {
        
        if (_paused == paused) {
            return;
        }

        
        paused = _paused;

        
        if (paused) {
            lastPauseTime = now;
        }

        
        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}






contract SelfDestructible is Owned {
    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    uint public initiationTime;
    bool public selfDestructInitiated;

    address public selfDestructBeneficiary;

    constructor() internal {
        
        require(owner != address(0), "Owner must be set");
        selfDestructBeneficiary = owner;
        emit SelfDestructBeneficiaryUpdated(owner);
    }

    
    function setSelfDestructBeneficiary(address payable _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary must not be zero");
        selfDestructBeneficiary = _beneficiary;
        emit SelfDestructBeneficiaryUpdated(_beneficiary);
    }

    
    function initiateSelfDestruct() external onlyOwner {
        initiationTime = now;
        selfDestructInitiated = true;
        emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
    }

    
    function terminateSelfDestruct() external onlyOwner {
        initiationTime = 0;
        selfDestructInitiated = false;
        emit SelfDestructTerminated();
    }

    
    function selfDestruct() external onlyOwner {
        require(selfDestructInitiated, "Self Destruct not yet initiated");
        require(initiationTime + SELFDESTRUCT_DELAY < now, "Self destruct delay not met");
        emit SelfDestructed(selfDestructBeneficiary);
        selfdestruct(address(uint160(selfDestructBeneficiary)));
    }

    event SelfDestructTerminated();
    event SelfDestructed(address beneficiary);
    event SelfDestructInitiated(uint selfDestructDelay);
    event SelfDestructBeneficiaryUpdated(address newBeneficiary);
}


library AddressListLib {
    struct AddressList {
        address[] elements;
        mapping(address => uint) indices;
    }

    function contains(AddressList storage list, address candidate) internal view returns (bool) {
        if (list.elements.length == 0) {
            return false;
        }
        uint index = list.indices[candidate];
        return index != 0 || list.elements[0] == candidate;
    }

    function getPage(
        AddressList storage list,
        uint index,
        uint pageSize
    ) internal view returns (address[] memory) {
        
        uint endIndex = index + pageSize; 

        
        if (endIndex > list.elements.length) {
            endIndex = list.elements.length;
        }
        if (endIndex <= index) {
            return new address[](0);
        }

        uint n = endIndex - index; 
        address[] memory page = new address[](n);
        for (uint i; i < n; i++) {
            page[i] = list.elements[i + index];
        }
        return page;
    }

    function push(AddressList storage list, address element) internal {
        list.indices[element] = list.elements.length;
        list.elements.push(element);
    }

    function remove(AddressList storage list, address element) internal {
        require(contains(list, element), "Element not in list.");
        
        uint index = list.indices[element];
        uint lastIndex = list.elements.length - 1; 
        if (index != lastIndex) {
            
            address shiftedElement = list.elements[lastIndex];
            list.elements[index] = shiftedElement;
            list.indices[shiftedElement] = index;
        }
        list.elements.pop();
        delete list.indices[element];
    }
}








contract BinaryOptionMarketFactory is Owned, SelfDestructible, MixinResolver {
    

    

    bytes32 internal constant CONTRACT_BINARYOPTIONMARKETMANAGER = "BinaryOptionMarketManager";

    bytes32[24] internal addressesToCache = [CONTRACT_BINARYOPTIONMARKETMANAGER];

    

    constructor(address _owner, address _resolver)
        public
        Owned(_owner)
        SelfDestructible()
        MixinResolver(_resolver, addressesToCache)
    {}

    

    

    function _manager() internal view returns (address) {
        return requireAndGetAddress(CONTRACT_BINARYOPTIONMARKETMANAGER, "Missing BinaryOptionMarketManager address");
    }

    

    function createMarket(
        address creator,
        uint[2] calldata creatorLimits,
        bytes32 oracleKey,
        uint strikePrice,
        bool refundsEnabled,
        uint[3] calldata times, 
        uint[2] calldata bids, 
        uint[3] calldata fees 
    ) external returns (BinaryOptionMarket) {
        address manager = _manager();
        require(address(manager) == msg.sender, "Only permitted by the manager.");

        return new BinaryOptionMarket(manager, creator, creatorLimits, oracleKey, strikePrice, refundsEnabled, times, bids, fees);
    }
}



interface IExchangeRates {
    
    function aggregators(bytes32 currencyKey) external view returns (address);

    function anyRateIsStale(bytes32[] calldata currencyKeys) external view returns (bool);

    function currentRoundForRate(bytes32 currencyKey) external view returns (uint);

    function effectiveValue(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external view returns (uint value);

    function effectiveValueAndRates(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint value,
            uint sourceRate,
            uint destinationRate
        );

    function effectiveValueAtRound(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external view returns (uint value);

    function getCurrentRoundId(bytes32 currencyKey) external view returns (uint);

    function getLastRoundIdBeforeElapsedSecs(
        bytes32 currencyKey,
        uint startingRoundId,
        uint startingTimestamp,
        uint timediff
    ) external view returns (uint);

    function inversePricing(bytes32 currencyKey)
        external
        view
        returns (
            uint entryPoint,
            uint upperLimit,
            uint lowerLimit,
            bool frozen
        );

    function lastRateUpdateTimes(bytes32 currencyKey) external view returns (uint256);

    function oracle() external view returns (address);

    function rateAndTimestampAtRound(bytes32 currencyKey, uint roundId) external view returns (uint rate, uint time);

    function rateAndUpdatedTime(bytes32 currencyKey) external view returns (uint rate, uint time);

    function rateForCurrency(bytes32 currencyKey) external view returns (uint);

    function rateIsFrozen(bytes32 currencyKey) external view returns (bool);

    function rateIsStale(bytes32 currencyKey) external view returns (bool);

    function rateStalePeriod() external view returns (uint);

    function ratesAndUpdatedTimeForCurrencyLastNRounds(bytes32 currencyKey, uint numRounds)
        external
        view
        returns (uint[] memory rates, uint[] memory times);

    function ratesAndStaleForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint[] memory, bool);

    function ratesForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint[] memory);
}


interface ISystemStatus {
    
    function requireSystemActive() external view;

    function requireIssuanceActive() external view;

    function requireExchangeActive() external view;

    function requireSynthActive(bytes32 currencyKey) external view;

    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;
}











contract BinaryOptionMarketManager is Owned, Pausable, SelfDestructible, MixinResolver, IBinaryOptionMarketManager {
    

    using SafeMath for uint;
    using AddressListLib for AddressListLib.AddressList;

    

    struct Fees {
        uint poolFee;
        uint creatorFee;
        uint refundFee;
    }

    struct Durations {
        uint maxOraclePriceAge;
        uint expiryDuration;
        uint maxTimeToMaturity;
    }

    struct CreatorLimits {
        uint capitalRequirement;
        uint skewLimit;
    }

    

    Fees public fees;
    Durations public durations;
    CreatorLimits public creatorLimits;

    bool public marketCreationEnabled = true;
    uint public totalDeposited;

    AddressListLib.AddressList internal _activeMarkets;
    AddressListLib.AddressList internal _maturedMarkets;

    BinaryOptionMarketManager internal _migratingManager;

    

    bytes32 internal constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 internal constant CONTRACT_SYNTHSUSD = "SynthsUSD";
    bytes32 internal constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 internal constant CONTRACT_BINARYOPTIONMARKETFACTORY = "BinaryOptionMarketFactory";

    bytes32[24] internal addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_SYNTHSUSD,
        CONTRACT_EXRATES,
        CONTRACT_BINARYOPTIONMARKETFACTORY
    ];

    

    constructor(
        address _owner,
        address _resolver,
        uint _maxOraclePriceAge,
        uint _expiryDuration,
        uint _maxTimeToMaturity,
        uint _creatorCapitalRequirement,
        uint _creatorSkewLimit,
        uint _poolFee,
        uint _creatorFee,
        uint _refundFee
    ) public Owned(_owner) Pausable() SelfDestructible() MixinResolver(_resolver, addressesToCache) {
        
        owner = msg.sender;
        setExpiryDuration(_expiryDuration);
        setMaxOraclePriceAge(_maxOraclePriceAge);
        setMaxTimeToMaturity(_maxTimeToMaturity);
        setCreatorCapitalRequirement(_creatorCapitalRequirement);
        setCreatorSkewLimit(_creatorSkewLimit);
        setPoolFee(_poolFee);
        setCreatorFee(_creatorFee);
        setRefundFee(_refundFee);
        owner = _owner;
    }

    

    

    function _systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function _sUSD() internal view returns (IERC20) {
        return IERC20(requireAndGetAddress(CONTRACT_SYNTHSUSD, "Missing SynthsUSD address"));
    }

    function _exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES, "Missing ExchangeRates"));
    }

    function _factory() internal view returns (BinaryOptionMarketFactory) {
        return
            BinaryOptionMarketFactory(
                requireAndGetAddress(CONTRACT_BINARYOPTIONMARKETFACTORY, "Missing BinaryOptionMarketFactory address")
            );
    }

    

    function _isKnownMarket(address candidate) internal view returns (bool) {
        return _activeMarkets.contains(candidate) || _maturedMarkets.contains(candidate);
    }

    function numActiveMarkets() external view returns (uint) {
        return _activeMarkets.elements.length;
    }

    function activeMarkets(uint index, uint pageSize) external view returns (address[] memory) {
        return _activeMarkets.getPage(index, pageSize);
    }

    function numMaturedMarkets() external view returns (uint) {
        return _maturedMarkets.elements.length;
    }

    function maturedMarkets(uint index, uint pageSize) external view returns (address[] memory) {
        return _maturedMarkets.getPage(index, pageSize);
    }

    function _isValidKey(bytes32 oracleKey) internal view returns (bool) {
        IExchangeRates exchangeRates = _exchangeRates();

        
        if (exchangeRates.rateForCurrency(oracleKey) != 0) {
            
            if (oracleKey == "sUSD") {
                return false;
            }

            
            (uint entryPoint, , , ) = exchangeRates.inversePricing(oracleKey);
            if (entryPoint != 0) {
                return false;
            }

            return true;
        }

        return false;
    }

    

    

    function setMaxOraclePriceAge(uint _maxOraclePriceAge) public onlyOwner {
        durations.maxOraclePriceAge = _maxOraclePriceAge;
        emit MaxOraclePriceAgeUpdated(_maxOraclePriceAge);
    }

    function setExpiryDuration(uint _expiryDuration) public onlyOwner {
        durations.expiryDuration = _expiryDuration;
        emit ExpiryDurationUpdated(_expiryDuration);
    }

    function setMaxTimeToMaturity(uint _maxTimeToMaturity) public onlyOwner {
        durations.maxTimeToMaturity = _maxTimeToMaturity;
        emit MaxTimeToMaturityUpdated(_maxTimeToMaturity);
    }

    function setPoolFee(uint _poolFee) public onlyOwner {
        uint totalFee = _poolFee + fees.creatorFee;
        require(totalFee < SafeDecimalMath.unit(), "Total fee must be less than 100%.");
        require(0 < totalFee, "Total fee must be nonzero.");
        fees.poolFee = _poolFee;
        emit PoolFeeUpdated(_poolFee);
    }

    function setCreatorFee(uint _creatorFee) public onlyOwner {
        uint totalFee = _creatorFee + fees.poolFee;
        require(totalFee < SafeDecimalMath.unit(), "Total fee must be less than 100%.");
        require(0 < totalFee, "Total fee must be nonzero.");
        fees.creatorFee = _creatorFee;
        emit CreatorFeeUpdated(_creatorFee);
    }

    function setRefundFee(uint _refundFee) public onlyOwner {
        require(_refundFee <= SafeDecimalMath.unit(), "Refund fee must be no greater than 100%.");
        fees.refundFee = _refundFee;
        emit RefundFeeUpdated(_refundFee);
    }

    function setCreatorCapitalRequirement(uint _creatorCapitalRequirement) public onlyOwner {
        creatorLimits.capitalRequirement = _creatorCapitalRequirement;
        emit CreatorCapitalRequirementUpdated(_creatorCapitalRequirement);
    }

    function setCreatorSkewLimit(uint _creatorSkewLimit) public onlyOwner {
        require(_creatorSkewLimit <= SafeDecimalMath.unit(), "Creator skew limit must be no greater than 1.");
        creatorLimits.skewLimit = _creatorSkewLimit;
        emit CreatorSkewLimitUpdated(_creatorSkewLimit);
    }

    

    function incrementTotalDeposited(uint delta) external onlyActiveMarkets notPaused {
        _systemStatus().requireSystemActive();
        totalDeposited = totalDeposited.add(delta);
    }

    function decrementTotalDeposited(uint delta) external onlyKnownMarkets notPaused {
        _systemStatus().requireSystemActive();
        
        
        
        totalDeposited = totalDeposited.sub(delta);
    }

    

    function createMarket(
        bytes32 oracleKey,
        uint strikePrice,
        bool refundsEnabled,
        uint[2] calldata times, 
        uint[2] calldata bids 
    )
        external
        notPaused
        returns (
            IBinaryOptionMarket 
        )
    {
        _systemStatus().requireSystemActive();
        require(marketCreationEnabled, "Market creation is disabled");
        require(_isValidKey(oracleKey), "Invalid key");

        (uint biddingEnd, uint maturity) = (times[0], times[1]);
        require(maturity <= now + durations.maxTimeToMaturity, "Maturity too far in the future");
        uint expiry = maturity.add(durations.expiryDuration);

        uint initialDeposit = bids[0].add(bids[1]);
        require(now < biddingEnd, "End of bidding has passed");
        require(biddingEnd < maturity, "Maturity predates end of bidding");
        
        
        

        BinaryOptionMarket market = _factory().createMarket(
            msg.sender,
            [creatorLimits.capitalRequirement, creatorLimits.skewLimit],
            oracleKey,
            strikePrice,
            refundsEnabled,
            [biddingEnd, maturity, expiry],
            bids,
            [fees.poolFee, fees.creatorFee, fees.refundFee]
        );
        market.setResolverAndSyncCache(resolver);
        _activeMarkets.push(address(market));

        
        
        totalDeposited = totalDeposited.add(initialDeposit);
        _sUSD().transferFrom(msg.sender, address(market), initialDeposit);

        emit MarketCreated(address(market), msg.sender, oracleKey, strikePrice, biddingEnd, maturity, expiry);
        return market;
    }

    function resolveMarket(address market) external {
        require(_activeMarkets.contains(market), "Not an active market");
        BinaryOptionMarket(market).resolve();
        _activeMarkets.remove(market);
        _maturedMarkets.push(market);
    }

    function cancelMarket(address market) external notPaused {
        require(_activeMarkets.contains(market), "Not an active market");
        address creator = BinaryOptionMarket(market).creator();
        require(msg.sender == creator, "Sender not market creator");
        BinaryOptionMarket(market).cancel(msg.sender);
        _activeMarkets.remove(market);
        emit MarketCancelled(market);
    }

    function expireMarkets(address[] calldata markets) external notPaused {
        for (uint i = 0; i < markets.length; i++) {
            address market = markets[i];

            
            BinaryOptionMarket(market).expire(msg.sender);
            
            
            _maturedMarkets.remove(market);
            emit MarketExpired(market);
        }
    }

    

    function setResolverAndSyncCacheOnMarkets(AddressResolver _resolver, BinaryOptionMarket[] calldata marketsToSync)
        external
        onlyOwner
    {
        for (uint i = 0; i < marketsToSync.length; i++) {
            marketsToSync[i].setResolverAndSyncCache(_resolver);
        }
    }

    function setMarketCreationEnabled(bool enabled) public onlyOwner {
        if (enabled != marketCreationEnabled) {
            marketCreationEnabled = enabled;
            emit MarketCreationEnabledUpdated(enabled);
        }
    }

    function setMigratingManager(BinaryOptionMarketManager manager) public onlyOwner {
        _migratingManager = manager;
    }

    function migrateMarkets(
        BinaryOptionMarketManager receivingManager,
        bool active,
        BinaryOptionMarket[] calldata marketsToMigrate
    ) external onlyOwner {
        uint _numMarkets = marketsToMigrate.length;
        if (_numMarkets == 0) {
            return;
        }
        AddressListLib.AddressList storage markets = active ? _activeMarkets : _maturedMarkets;

        uint runningDepositTotal;
        for (uint i; i < _numMarkets; i++) {
            BinaryOptionMarket market = marketsToMigrate[i];
            require(_isKnownMarket(address(market)), "Market unknown.");

            
            markets.remove(address(market));
            runningDepositTotal = runningDepositTotal.add(market.deposited());

            
            market.nominateNewOwner(address(receivingManager));
        }
        
        totalDeposited = totalDeposited.sub(runningDepositTotal);
        emit MarketsMigrated(receivingManager, marketsToMigrate);

        
        receivingManager.receiveMarkets(active, marketsToMigrate);
    }

    function receiveMarkets(bool active, BinaryOptionMarket[] calldata marketsToReceive) external {
        require(msg.sender == address(_migratingManager), "Only permitted for migrating manager.");

        uint _numMarkets = marketsToReceive.length;
        if (_numMarkets == 0) {
            return;
        }
        AddressListLib.AddressList storage markets = active ? _activeMarkets : _maturedMarkets;

        uint runningDepositTotal;
        for (uint i; i < _numMarkets; i++) {
            BinaryOptionMarket market = marketsToReceive[i];
            require(!_isKnownMarket(address(market)), "Market already known.");

            market.acceptOwnership();
            markets.push(address(market));
            
            runningDepositTotal = runningDepositTotal.add(market.deposited());
        }
        totalDeposited = totalDeposited.add(runningDepositTotal);
        emit MarketsReceived(_migratingManager, marketsToReceive);
    }

    

    modifier onlyActiveMarkets() {
        require(_activeMarkets.contains(msg.sender), "Permitted only for active markets.");
        _;
    }

    modifier onlyKnownMarkets() {
        require(_isKnownMarket(msg.sender), "Permitted only for known markets.");
        _;
    }

    

    event MarketCreated(
        address market,
        address indexed creator,
        bytes32 indexed oracleKey,
        uint strikePrice,
        uint biddingEndDate,
        uint maturityDate,
        uint expiryDate
    );
    event MarketExpired(address market);
    event MarketCancelled(address market);
    event MarketsMigrated(BinaryOptionMarketManager receivingManager, BinaryOptionMarket[] markets);
    event MarketsReceived(BinaryOptionMarketManager migratingManager, BinaryOptionMarket[] markets);
    event MarketCreationEnabledUpdated(bool enabled);
    event MaxOraclePriceAgeUpdated(uint duration);
    event ExerciseDurationUpdated(uint duration);
    event ExpiryDurationUpdated(uint duration);
    event MaxTimeToMaturityUpdated(uint duration);
    event CreatorCapitalRequirementUpdated(uint value);
    event CreatorSkewLimitUpdated(uint value);
    event PoolFeeUpdated(uint fee);
    event CreatorFeeUpdated(uint fee);
    event RefundFeeUpdated(uint fee);
}











contract BinaryOption is IERC20, IBinaryOption {
    

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    

    string public constant name = "SNX Binary Option";
    string public constant symbol = "sOPT";
    uint8 public constant decimals = 18;

    BinaryOptionMarket public market;

    mapping(address => uint) public bidOf;
    uint public totalBids;

    mapping(address => uint) public balanceOf;
    uint public totalSupply;

    
    mapping(address => mapping(address => uint)) public allowance;

    
    uint internal constant _MINIMUM_BID = 1e16;

    

    constructor(address initialBidder, uint initialBid) public {
        market = BinaryOptionMarket(msg.sender);
        bidOf[initialBidder] = initialBid;
        totalBids = initialBid;
    }

    

    function _claimableBalanceOf(
        uint _bid,
        uint price,
        uint exercisableDeposits
    ) internal view returns (uint) {
        uint owed = _bid.divideDecimal(price);
        uint supply = _totalClaimableSupply(exercisableDeposits);

        
        if ((_bid == totalBids && _bid != 0) || supply == 0) {
            return supply;
        }

        
        require(owed <= supply, "supply < claimable");
        return owed;
    }

    function claimableBalanceOf(address account) external view returns (uint) {
        (uint price, uint exercisableDeposits) = market.senderPriceAndExercisableDeposits();
        return _claimableBalanceOf(bidOf[account], price, exercisableDeposits);
    }

    function _totalClaimableSupply(uint exercisableDeposits) internal view returns (uint) {
        uint _totalSupply = totalSupply;
        
        
        if (exercisableDeposits <= _totalSupply) {
            return 0;
        }
        return exercisableDeposits.sub(_totalSupply);
    }

    function totalClaimableSupply() external view returns (uint) {
        (, uint exercisableDeposits) = market.senderPriceAndExercisableDeposits();
        return _totalClaimableSupply(exercisableDeposits);
    }

    

    function _requireMinimumBid(uint bid) internal pure returns (uint) {
        require(bid >= _MINIMUM_BID || bid == 0, "Balance < $0.01");
        return bid;
    }

    
    function bid(address bidder, uint newBid) external onlyMarket {
        bidOf[bidder] = _requireMinimumBid(bidOf[bidder].add(newBid));
        totalBids = totalBids.add(newBid);
    }

    
    function refund(address bidder, uint newRefund) external onlyMarket {
        
        bidOf[bidder] = _requireMinimumBid(bidOf[bidder].sub(newRefund));
        totalBids = totalBids.sub(newRefund);
    }

    
    function claim(
        address claimant,
        uint price,
        uint depositsRemaining
    ) external onlyMarket returns (uint optionsClaimed) {
        uint _bid = bidOf[claimant];
        uint claimable = _claimableBalanceOf(_bid, price, depositsRemaining);
        
        if (claimable == 0) {
            return 0;
        }

        totalBids = totalBids.sub(_bid);
        bidOf[claimant] = 0;

        totalSupply = totalSupply.add(claimable);
        balanceOf[claimant] = balanceOf[claimant].add(claimable); 

        emit Transfer(address(0), claimant, claimable);
        emit Issued(claimant, claimable);

        return claimable;
    }

    
    function exercise(address claimant) external onlyMarket {
        uint balance = balanceOf[claimant];

        if (balance == 0) {
            return;
        }

        balanceOf[claimant] = 0;
        totalSupply = totalSupply.sub(balance);

        emit Transfer(claimant, address(0), balance);
        emit Burned(claimant, balance);
    }

    
    
    function expire(address payable beneficiary) external onlyMarket {
        selfdestruct(beneficiary);
    }

    

    
    
    
    function _transfer(
        address _from,
        address _to,
        uint _value
    ) internal returns (bool success) {
        market.requireActiveAndUnpaused();
        require(_to != address(0) && _to != address(this), "Invalid address");

        uint fromBalance = balanceOf[_from];
        require(_value <= fromBalance, "Insufficient balance");

        balanceOf[_from] = fromBalance.sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) external returns (bool success) {
        uint fromAllowance = allowance[_from][msg.sender];
        require(_value <= fromAllowance, "Insufficient allowance");

        allowance[_from][msg.sender] = fromAllowance.sub(_value);
        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint _value) external returns (bool success) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    

    modifier onlyMarket() {
        require(msg.sender == address(market), "Only market allowed");
        _;
    }

    

    event Issued(address indexed account, uint value);
    event Burned(address indexed account, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


interface IFeePool {
    
    function getExchangeFeeRateForSynth(bytes32 synthKey) external view returns (uint);

    
    function FEE_ADDRESS() external view returns (address);

    function feesAvailable(address account) external view returns (uint, uint);

    function isFeesClaimable(address account) external view returns (bool);

    function totalFeesAvailable() external view returns (uint);

    function totalRewardsAvailable() external view returns (uint);

    
    function claimFees() external returns (bool);

    function claimOnBehalf(address claimingForAddress) external returns (bool);

    function closeCurrentFeePeriod() external;

    
    function appendAccountIssuanceRecord(
        address account,
        uint lockedAmount,
        uint debtEntryIndex
    ) external;

    function recordFeePaid(uint sUSDAmount) external;

    function setRewardsToDistribute(uint amount) external;
}











contract BinaryOptionMarket is Owned, MixinResolver, IBinaryOptionMarket {
    

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    

    struct Options {
        BinaryOption long;
        BinaryOption short;
    }

    struct Prices {
        uint long;
        uint short;
    }

    struct Times {
        uint biddingEnd;
        uint maturity;
        uint expiry;
    }

    struct OracleDetails {
        bytes32 key;
        uint strikePrice;
        uint finalPrice;
    }

    

    Options public options;
    Prices public prices;
    Times public times;
    OracleDetails public oracleDetails;
    BinaryOptionMarketManager.Fees public fees;
    BinaryOptionMarketManager.CreatorLimits public creatorLimits;

    
    
    uint public deposited;
    address public creator;
    bool public resolved;
    bool public refundsEnabled;

    uint internal _feeMultiplier;

    

    bytes32 internal constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 internal constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 internal constant CONTRACT_SYNTHSUSD = "SynthsUSD";
    bytes32 internal constant CONTRACT_FEEPOOL = "FeePool";

    bytes32[24] internal addressesToCache = [CONTRACT_SYSTEMSTATUS, CONTRACT_EXRATES, CONTRACT_SYNTHSUSD, CONTRACT_FEEPOOL];

    

    constructor(
        address _owner,
        address _creator,
        uint[2] memory _creatorLimits, 
        bytes32 _oracleKey,
        uint _strikePrice,
        bool _refundsEnabled,
        uint[3] memory _times, 
        uint[2] memory _bids, 
        uint[3] memory _fees 
    )
        public
        Owned(_owner)
        MixinResolver(_owner, addressesToCache) 
    {
        creator = _creator;
        creatorLimits = BinaryOptionMarketManager.CreatorLimits(_creatorLimits[0], _creatorLimits[1]);

        oracleDetails = OracleDetails(_oracleKey, _strikePrice, 0);
        times = Times(_times[0], _times[1], _times[2]);

        refundsEnabled = _refundsEnabled;

        (uint longBid, uint shortBid) = (_bids[0], _bids[1]);
        _checkCreatorLimits(longBid, shortBid);
        emit Bid(Side.Long, _creator, longBid);
        emit Bid(Side.Short, _creator, shortBid);

        
        
        
        uint initialDeposit = longBid.add(shortBid);
        deposited = initialDeposit;

        (uint poolFee, uint creatorFee) = (_fees[0], _fees[1]);
        fees = BinaryOptionMarketManager.Fees(poolFee, creatorFee, _fees[2]);
        _feeMultiplier = SafeDecimalMath.unit().sub(poolFee.add(creatorFee));

        
        _updatePrices(longBid, shortBid, initialDeposit);

        
        options.long = new BinaryOption(_creator, longBid);
        options.short = new BinaryOption(_creator, shortBid);
    }

    

    

    function _systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus"));
    }

    function _exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES, "Missing ExchangeRates"));
    }

    function _sUSD() internal view returns (IERC20) {
        return IERC20(requireAndGetAddress(CONTRACT_SYNTHSUSD, "Missing SynthsUSD"));
    }

    function _feePool() internal view returns (IFeePool) {
        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL, "Missing FeePool"));
    }

    function _manager() internal view returns (BinaryOptionMarketManager) {
        return BinaryOptionMarketManager(owner);
    }

    

    function _biddingEnded() internal view returns (bool) {
        return times.biddingEnd < now;
    }

    function _matured() internal view returns (bool) {
        return times.maturity < now;
    }

    function _expired() internal view returns (bool) {
        return resolved && (times.expiry < now || deposited == 0);
    }

    function phase() external view returns (Phase) {
        if (!_biddingEnded()) {
            return Phase.Bidding;
        }
        if (!_matured()) {
            return Phase.Trading;
        }
        if (!_expired()) {
            return Phase.Maturity;
        }
        return Phase.Expiry;
    }

    

    function _oraclePriceAndTimestamp() internal view returns (uint price, uint updatedAt) {
        return _exchangeRates().rateAndUpdatedTime(oracleDetails.key);
    }

    function oraclePriceAndTimestamp() external view returns (uint price, uint updatedAt) {
        return _oraclePriceAndTimestamp();
    }

    function _isFreshPriceUpdateTime(uint timestamp) internal view returns (bool) {
        (uint maxOraclePriceAge, , ) = _manager().durations();
        return (times.maturity.sub(maxOraclePriceAge)) <= timestamp;
    }

    function canResolve() external view returns (bool) {
        (, uint updatedAt) = _oraclePriceAndTimestamp();
        return !resolved && _matured() && _isFreshPriceUpdateTime(updatedAt);
    }

    function _result() internal view returns (Side) {
        uint price;
        if (resolved) {
            price = oracleDetails.finalPrice;
        } else {
            (price, ) = _oraclePriceAndTimestamp();
        }

        return oracleDetails.strikePrice <= price ? Side.Long : Side.Short;
    }

    function result() external view returns (Side) {
        return _result();
    }

    

    function _computePrices(
        uint longBids,
        uint shortBids,
        uint _deposited
    ) internal view returns (uint long, uint short) {
        require(longBids != 0 && shortBids != 0, "Bids must be nonzero");
        uint optionsPerSide = _exercisableDeposits(_deposited);

        
        
        return (longBids.divideDecimalRound(optionsPerSide), shortBids.divideDecimalRound(optionsPerSide));
    }

    function senderPriceAndExercisableDeposits() external view returns (uint price, uint exercisable) {
        
        
        exercisable = 0;
        if (!resolved || address(_option(_result())) == msg.sender) {
            exercisable = _exercisableDeposits(deposited);
        }

        
        if (msg.sender == address(options.long)) {
            price = prices.long;
        } else if (msg.sender == address(options.short)) {
            price = prices.short;
        } else {
            revert("Sender is not an option");
        }
    }

    function pricesAfterBidOrRefund(
        Side side,
        uint value,
        bool refund
    ) external view returns (uint long, uint short) {
        (uint longTotalBids, uint shortTotalBids) = _totalBids();
        
        function(uint, uint) pure returns (uint) operation = refund ? SafeMath.sub : SafeMath.add;

        if (side == Side.Long) {
            longTotalBids = operation(longTotalBids, value);
        } else {
            shortTotalBids = operation(shortTotalBids, value);
        }

        if (refund) {
            value = value.multiplyDecimalRound(SafeDecimalMath.unit().sub(fees.refundFee));
        }
        return _computePrices(longTotalBids, shortTotalBids, operation(deposited, value));
    }

    
    function bidOrRefundForPrice(
        Side bidSide,
        Side priceSide,
        uint price,
        bool refund
    ) external view returns (uint) {
        uint adjustedPrice = price.multiplyDecimalRound(_feeMultiplier);
        uint bids = _option(priceSide).totalBids();
        uint _deposited = deposited;
        uint unit = SafeDecimalMath.unit();
        uint refundFeeMultiplier = unit.sub(fees.refundFee);

        if (bidSide == priceSide) {
            uint depositedByPrice = _deposited.multiplyDecimalRound(adjustedPrice);

            
            
            if (refund) {
                (depositedByPrice, bids) = (bids, depositedByPrice);
                adjustedPrice = adjustedPrice.multiplyDecimalRound(refundFeeMultiplier);
            }

            
            return _subToZero(depositedByPrice, bids).divideDecimalRound(unit.sub(adjustedPrice));
        } else {
            uint bidsPerPrice = bids.divideDecimalRound(adjustedPrice);

            
            if (refund) {
                (bidsPerPrice, _deposited) = (_deposited, bidsPerPrice);
            }

            uint value = _subToZero(bidsPerPrice, _deposited);
            return refund ? value.divideDecimalRound(refundFeeMultiplier) : value;
        }
    }

    

    function _bidsOf(address account) internal view returns (uint long, uint short) {
        return (options.long.bidOf(account), options.short.bidOf(account));
    }

    function bidsOf(address account) external view returns (uint long, uint short) {
        return _bidsOf(account);
    }

    function _totalBids() internal view returns (uint long, uint short) {
        return (options.long.totalBids(), options.short.totalBids());
    }

    function totalBids() external view returns (uint long, uint short) {
        return _totalBids();
    }

    function _claimableBalancesOf(address account) internal view returns (uint long, uint short) {
        return (options.long.claimableBalanceOf(account), options.short.claimableBalanceOf(account));
    }

    function claimableBalancesOf(address account) external view returns (uint long, uint short) {
        return _claimableBalancesOf(account);
    }

    function totalClaimableSupplies() external view returns (uint long, uint short) {
        return (options.long.totalClaimableSupply(), options.short.totalClaimableSupply());
    }

    function _balancesOf(address account) internal view returns (uint long, uint short) {
        return (options.long.balanceOf(account), options.short.balanceOf(account));
    }

    function balancesOf(address account) external view returns (uint long, uint short) {
        return _balancesOf(account);
    }

    function totalSupplies() external view returns (uint long, uint short) {
        return (options.long.totalSupply(), options.short.totalSupply());
    }

    function _exercisableDeposits(uint _deposited) internal view returns (uint) {
        
        return resolved ? _deposited : _deposited.multiplyDecimalRound(_feeMultiplier);
    }

    function exercisableDeposits() external view returns (uint) {
        return _exercisableDeposits(deposited);
    }

    

    function _chooseSide(
        Side side,
        uint longValue,
        uint shortValue
    ) internal pure returns (uint) {
        if (side == Side.Long) {
            return longValue;
        }
        return shortValue;
    }

    function _option(Side side) internal view returns (BinaryOption) {
        if (side == Side.Long) {
            return options.long;
        }
        return options.short;
    }

    
    function _subToZero(uint a, uint b) internal pure returns (uint) {
        return a < b ? 0 : a.sub(b);
    }

    function _checkCreatorLimits(uint longBid, uint shortBid) internal view {
        uint totalBid = longBid.add(shortBid);
        require(creatorLimits.capitalRequirement <= totalBid, "Insufficient capital");
        uint skewLimit = creatorLimits.skewLimit;
        require(
            skewLimit <= longBid.divideDecimal(totalBid) && skewLimit <= shortBid.divideDecimal(totalBid),
            "Bids too skewed"
        );
    }

    function _incrementDeposited(uint value) internal returns (uint _deposited) {
        _deposited = deposited.add(value);
        deposited = _deposited;
        _manager().incrementTotalDeposited(value);
    }

    function _decrementDeposited(uint value) internal returns (uint _deposited) {
        _deposited = deposited.sub(value);
        deposited = _deposited;
        _manager().decrementTotalDeposited(value);
    }

    function _requireManagerNotPaused() internal view {
        require(!_manager().paused(), "This action cannot be performed while the contract is paused");
    }

    function requireActiveAndUnpaused() external view {
        _systemStatus().requireSystemActive();
        _requireManagerNotPaused();
    }

    

    

    function _updatePrices(
        uint longBids,
        uint shortBids,
        uint _deposited
    ) internal {
        (uint256 longPrice, uint256 shortPrice) = _computePrices(longBids, shortBids, _deposited);
        prices = Prices(longPrice, shortPrice);
        emit PricesUpdated(longPrice, shortPrice);
    }

    function bid(Side side, uint value) external duringBidding {
        if (value == 0) {
            return;
        }

        _option(side).bid(msg.sender, value);
        emit Bid(side, msg.sender, value);

        uint _deposited = _incrementDeposited(value);
        _sUSD().transferFrom(msg.sender, address(this), value);

        (uint longTotalBids, uint shortTotalBids) = _totalBids();
        _updatePrices(longTotalBids, shortTotalBids, _deposited);
    }

    function refund(Side side, uint value) external duringBidding returns (uint refundMinusFee) {
        require(refundsEnabled, "Refunds disabled");
        if (value == 0) {
            return 0;
        }

        
        if (msg.sender == creator) {
            (uint thisBid, uint thatBid) = _bidsOf(msg.sender);
            if (side == Side.Short) {
                (thisBid, thatBid) = (thatBid, thisBid);
            }
            _checkCreatorLimits(thisBid.sub(value), thatBid);
        }

        
        
        refundMinusFee = value.multiplyDecimalRound(SafeDecimalMath.unit().sub(fees.refundFee));

        _option(side).refund(msg.sender, value);
        emit Refund(side, msg.sender, refundMinusFee, value.sub(refundMinusFee));

        uint _deposited = _decrementDeposited(refundMinusFee);
        _sUSD().transfer(msg.sender, refundMinusFee);

        (uint longTotalBids, uint shortTotalBids) = _totalBids();
        _updatePrices(longTotalBids, shortTotalBids, _deposited);
    }

    

    function resolve() external onlyOwner afterMaturity systemActive managerNotPaused {
        require(!resolved, "Market already resolved");

        
        
        (uint price, uint updatedAt) = _oraclePriceAndTimestamp();
        require(_isFreshPriceUpdateTime(updatedAt), "Price is stale");

        oracleDetails.finalPrice = price;
        resolved = true;

        
        
        
        IERC20 sUSD = _sUSD();

        uint _deposited = deposited;
        uint poolFees = _deposited.multiplyDecimalRound(fees.poolFee);
        uint creatorFees = _deposited.multiplyDecimalRound(fees.creatorFee);
        _decrementDeposited(creatorFees.add(poolFees));
        sUSD.transfer(_feePool().FEE_ADDRESS(), poolFees);
        sUSD.transfer(creator, creatorFees);

        emit MarketResolved(_result(), price, updatedAt, deposited, poolFees, creatorFees);
    }

    

    function _claimOptions()
        internal
        systemActive
        managerNotPaused
        afterBidding
        returns (uint longClaimed, uint shortClaimed)
    {
        uint exercisable = _exercisableDeposits(deposited);
        Side outcome = _result();
        bool _resolved = resolved;

        
        uint longOptions;
        uint shortOptions;
        if (!_resolved || outcome == Side.Long) {
            longOptions = options.long.claim(msg.sender, prices.long, exercisable);
        }
        if (!_resolved || outcome == Side.Short) {
            shortOptions = options.short.claim(msg.sender, prices.short, exercisable);
        }

        require(longOptions != 0 || shortOptions != 0, "Nothing to claim");
        emit OptionsClaimed(msg.sender, longOptions, shortOptions);
        return (longOptions, shortOptions);
    }

    function claimOptions() external returns (uint longClaimed, uint shortClaimed) {
        return _claimOptions();
    }

    function exerciseOptions() external returns (uint) {
        
        if (!resolved) {
            _manager().resolveMarket(address(this));
        }

        
        (uint claimableLong, uint claimableShort) = _claimableBalancesOf(msg.sender);
        if (claimableLong != 0 || claimableShort != 0) {
            _claimOptions();
        }

        
        (uint longBalance, uint shortBalance) = _balancesOf(msg.sender);
        require(longBalance != 0 || shortBalance != 0, "Nothing to exercise");

        
        if (longBalance != 0) {
            options.long.exercise(msg.sender);
        }
        if (shortBalance != 0) {
            options.short.exercise(msg.sender);
        }

        
        uint payout = _chooseSide(_result(), longBalance, shortBalance);
        emit OptionsExercised(msg.sender, payout);
        if (payout != 0) {
            _decrementDeposited(payout);
            _sUSD().transfer(msg.sender, payout);
        }
        return payout;
    }

    

    function _selfDestruct(address payable beneficiary) internal {
        uint _deposited = deposited;
        if (_deposited != 0) {
            _decrementDeposited(_deposited);
        }

        
        
        IERC20 sUSD = _sUSD();
        uint balance = sUSD.balanceOf(address(this));
        if (balance != 0) {
            sUSD.transfer(beneficiary, balance);
        }

        
        options.long.expire(beneficiary);
        options.short.expire(beneficiary);
        selfdestruct(beneficiary);
    }

    function cancel(address payable beneficiary) external onlyOwner duringBidding {
        (uint longTotalBids, uint shortTotalBids) = _totalBids();
        (uint creatorLongBids, uint creatorShortBids) = _bidsOf(creator);
        bool cancellable = longTotalBids == creatorLongBids && shortTotalBids == creatorShortBids;
        require(cancellable, "Not cancellable");
        _selfDestruct(beneficiary);
    }

    function expire(address payable beneficiary) external onlyOwner {
        require(_expired(), "Unexpired options remaining");
        _selfDestruct(beneficiary);
    }

    

    modifier duringBidding() {
        require(!_biddingEnded(), "Bidding inactive");
        _;
    }

    modifier afterBidding() {
        require(_biddingEnded(), "Bidding incomplete");
        _;
    }

    modifier afterMaturity() {
        require(_matured(), "Not yet mature");
        _;
    }

    modifier systemActive() {
        _systemStatus().requireSystemActive();
        _;
    }

    modifier managerNotPaused() {
        _requireManagerNotPaused();
        _;
    }

    

    event Bid(Side side, address indexed account, uint value);
    event Refund(Side side, address indexed account, uint value, uint fee);
    event PricesUpdated(uint longPrice, uint shortPrice);
    event MarketResolved(
        Side result,
        uint oraclePrice,
        uint oracleTimestamp,
        uint deposited,
        uint poolFees,
        uint creatorFees
    );
    event OptionsClaimed(address indexed account, uint longOptions, uint shortOptions);
    event OptionsExercised(address indexed account, uint value);
}