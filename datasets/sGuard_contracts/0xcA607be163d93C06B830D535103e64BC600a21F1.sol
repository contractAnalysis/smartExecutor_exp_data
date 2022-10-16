pragma solidity 0.4.26;


contract IERC20Token {
    
    function name() public view returns (string) {this;}
    function symbol() public view returns (string) {this;}
    function decimals() public view returns (uint8) {this;}
    function totalSupply() public view returns (uint256) {this;}
    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}
    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}



pragma solidity 0.4.26;


contract IWhitelist {
    function isWhitelisted(address _address) public view returns (bool);
}



pragma solidity 0.4.26;




contract IBancorConverter {
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256);
    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256);
    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256);
    function conversionWhitelist() public view returns (IWhitelist) {this;}
    function conversionFee() public view returns (uint32) {this;}
    function reserves(address _address) public view returns (uint256, uint32, bool, bool, bool) {_address; this;}
    function getReserveBalance(IERC20Token _reserveToken) public view returns (uint256);
    function reserveTokens(uint256 _index) public view returns (IERC20Token) {_index; this;}

    
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);
    function connectorTokens(uint256 _index) public view returns (IERC20Token);
    function connectorTokenCount() public view returns (uint16);
}



pragma solidity 0.4.26;



contract IBancorConverterUpgrader {
    function upgrade(bytes32 _version) public;
    function upgrade(uint16 _version) public;
}



pragma solidity 0.4.26;


contract IBancorFormula {
    function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount) public view returns (uint256);
    function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount) public view returns (uint256);
    function calculateCrossReserveReturn(uint256 _fromReserveBalance, uint32 _fromReserveRatio, uint256 _toReserveBalance, uint32 _toReserveRatio, uint256 _amount) public view returns (uint256);
    function calculateFundCost(uint256 _supply, uint256 _reserveBalance, uint32 _totalRatio, uint256 _amount) public view returns (uint256);
    function calculateLiquidateReturn(uint256 _supply, uint256 _reserveBalance, uint32 _totalRatio, uint256 _amount) public view returns (uint256);
    
    function calculateCrossConnectorReturn(uint256 _fromConnectorBalance, uint32 _fromConnectorWeight, uint256 _toConnectorBalance, uint32 _toConnectorWeight, uint256 _amount) public view returns (uint256);
}



pragma solidity 0.4.26;



contract IBancorNetwork {
    function convert2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);

    function claimAndConvert2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public returns (uint256);

    function convertFor2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);

    function claimAndConvertFor2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public returns (uint256);

    
    function convert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public payable returns (uint256);

    
    function claimAndConvert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public returns (uint256);

    
    function convertFor(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public payable returns (uint256);

    
    function claimAndConvertFor(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public returns (uint256);

    
    function convertForPrioritized4(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256[] memory _signature,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);

    
    function convertForPrioritized3(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _customVal,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);

    
    function convertForPrioritized2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);

    
    function convertForPrioritized(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);
}



pragma solidity 0.4.26;


contract FeatureIds {
    
    uint256 public constant CONVERTER_CONVERSION_WHITELIST = 1 << 0;
}



pragma solidity 0.4.26;


library SafeMath {
    
    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        require(z >= _x);
        return z;
    }

    
    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_x >= _y);
        return _x - _y;
    }

    
    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        
        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y);
        return z;
    }

      
    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_y > 0);
        uint256 c = _x / _y;

        return c;
    }
}



pragma solidity 0.4.26;


contract IOwned {
    
    function owner() public view returns (address) {this;}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}



pragma solidity 0.4.26;



contract Owned is IOwned {
    address public owner;
    address public newOwner;

    
    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    
    constructor() public {
        owner = msg.sender;
    }

    
    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



pragma solidity 0.4.26;


contract Utils {
    
    constructor() public {
    }

    
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    
    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }

    
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

}



pragma solidity 0.4.26;


contract IContractRegistry {
    function addressOf(bytes32 _contractName) public view returns (address);

    
    function getAddress(bytes32 _contractName) public view returns (address);
}



pragma solidity 0.4.26;





contract ContractRegistryClient is Owned, Utils {
    bytes32 internal constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 internal constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 internal constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 internal constant BANCOR_FORMULA = "BancorFormula";
    bytes32 internal constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";
    bytes32 internal constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY = "BancorConverterRegistry";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY_DATA = "BancorConverterRegistryData";
    bytes32 internal constant BNT_TOKEN = "BNTToken";
    bytes32 internal constant BANCOR_X = "BancorX";
    bytes32 internal constant BANCOR_X_UPGRADER = "BancorXUpgrader";

    
    bytes32 internal constant RAY_PORTFOLIO_MANAGER = keccak256('PortfolioManagerContract');
    bytes32 internal constant RAY_NAV_CALCULATOR= keccak256('NAVCalculatorContract');

    IContractRegistry public registry;      
    IContractRegistry public prevRegistry;  
    bool public onlyOwnerCanUpdateRegistry; 

    
    modifier only(bytes32 _contractName) {
        require(msg.sender == addressOf(_contractName));
        _;
    }

    
    constructor(IContractRegistry _registry) internal validAddress(_registry) {
        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);
    }

    
    function updateRegistry() public {
        
        require(msg.sender == owner || !onlyOwnerCanUpdateRegistry);

        
        address newRegistry = addressOf(CONTRACT_REGISTRY);

        
        require(newRegistry != address(registry) && newRegistry != address(0));

        
        require(IContractRegistry(newRegistry).addressOf(CONTRACT_REGISTRY) != address(0));

        
        prevRegistry = registry;

        
        registry = IContractRegistry(newRegistry);
    }

    
    function restoreRegistry() public ownerOnly {
        
        registry = prevRegistry;
    }

    
    function restrictRegistryUpdate(bool _onlyOwnerCanUpdateRegistry) ownerOnly public {
        
        onlyOwnerCanUpdateRegistry = _onlyOwnerCanUpdateRegistry;
    }

    
    function addressOf(bytes32 _contractName) internal view returns (address) {
        return registry.addressOf(_contractName);
    }
}



pragma solidity 0.4.26;


contract IContractFeatures {
    function isSupported(address _contract, uint256 _features) public view returns (bool);
    function enableFeatures(uint256 _features, bool _enable) public;
}



pragma solidity 0.4.26;




contract ISmartToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}



pragma solidity 0.4.26;



contract ISmartTokenController {
    function claimTokens(address _from, uint256 _amount) public;
    function token() public view returns (ISmartToken) {this;}
}



pragma solidity 0.4.26;




contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}



pragma solidity 0.4.26;


contract INonStandardERC20 {
    
    function name() public view returns (string) {this;}
    function symbol() public view returns (string) {this;}
    function decimals() public view returns (uint8) {this;}
    function totalSupply() public view returns (uint256) {this;}
    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}
    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}

    function transfer(address _to, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public;
    function approve(address _spender, uint256 _value) public;
}



pragma solidity 0.4.26;







contract TokenHolder is ITokenHolder, Owned, Utils {
    
    constructor() public {
    }

    
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        INonStandardERC20(_token).transfer(_to, _amount);
    }
}



pragma solidity 0.4.26;





contract SmartTokenController is ISmartTokenController, TokenHolder {
    ISmartToken public token;   
    address public bancorX;     

    
    constructor(ISmartToken _token)
        public
        validAddress(_token)
    {
        token = _token;
    }

    
    modifier active() {
        require(token.owner() == address(this));
        _;
    }

    
    modifier inactive() {
        require(token.owner() != address(this));
        _;
    }

    
    function transferTokenOwnership(address _newOwner) public ownerOnly {
        token.transferOwnership(_newOwner);
    }

    
    function acceptTokenOwnership() public ownerOnly {
        token.acceptOwnership();
    }

    
    function withdrawFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        ITokenHolder(token).withdrawTokens(_token, _to, _amount);
    }

    
    function claimTokens(address _from, uint256 _amount) public {
        
        require(msg.sender == bancorX);

        
        token.destroy(_from, _amount);
        token.issue(msg.sender, _amount);
    }

    
    function setBancorX(address _bancorX) public ownerOnly {
        bancorX = _bancorX;
    }
}



pragma solidity 0.4.26;



contract IEtherToken is IERC20Token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
    function depositTo(address _to) public payable;
    function withdrawTo(address _to, uint256 _amount) public;
}



pragma solidity 0.4.26;

contract IBancorX {
    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public;
    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256);
}



pragma solidity 0.4.26;















contract BancorConverter is IBancorConverter, SmartTokenController, ContractRegistryClient, FeatureIds {
    using SafeMath for uint256;

    uint32 private constant RATIO_RESOLUTION = 1000000;
    uint64 private constant CONVERSION_FEE_RESOLUTION = 1000000;

    struct Reserve {
        uint256 virtualBalance;         
        uint32 ratio;                   
        bool isVirtualBalanceEnabled;   
        bool isSaleEnabled;             
        bool isSet;                     
    }

    
    uint16 public version = 26;

    IWhitelist public conversionWhitelist;          
    IERC20Token[] public reserveTokens;             
    mapping (address => Reserve) public reserves;   
    uint32 public totalReserveRatio = 0;            
                                                    
    uint32 public maxConversionFee = 0;             
                                                    
    uint32 public conversionFee = 0;                
    bool public conversionsEnabled = true;          

    
    event Conversion(
        address indexed _fromToken,
        address indexed _toToken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionFee
    );

    
    event PriceDataUpdate(
        address indexed _connectorToken,
        uint256 _tokenSupply,
        uint256 _connectorBalance,
        uint32 _connectorWeight
    );

    
    event ConversionFeeUpdate(uint32 _prevFee, uint32 _newFee);

    
    constructor(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee,
        IERC20Token _reserveToken,
        uint32 _reserveRatio
    )   ContractRegistryClient(_registry)
        public
        SmartTokenController(_token)
        validConversionFee(_maxConversionFee)
    {
        IContractFeatures features = IContractFeatures(addressOf(CONTRACT_FEATURES));

        
        if (features != address(0))
            features.enableFeatures(FeatureIds.CONVERTER_CONVERSION_WHITELIST, true);

        maxConversionFee = _maxConversionFee;

        if (_reserveToken != address(0))
            addReserve(_reserveToken, _reserveRatio);
    }

    
    modifier validReserve(IERC20Token _address) {
        require(reserves[_address].isSet);
        _;
    }

    
    modifier validConversionFee(uint32 _conversionFee) {
        require(_conversionFee >= 0 && _conversionFee <= CONVERSION_FEE_RESOLUTION);
        _;
    }

    
    modifier validReserveRatio(uint32 _ratio) {
        require(_ratio > 0 && _ratio <= RATIO_RESOLUTION);
        _;
    }

    
    modifier totalSupplyGreaterThanZeroOnly {
        require(token.totalSupply() > 0);
        _;
    }

    
    modifier multipleReservesOnly {
        require(reserveTokens.length > 1);
        _;
    }

    
    function reserveTokenCount() public view returns (uint16) {
        return uint16(reserveTokens.length);
    }

    
    function setConversionWhitelist(IWhitelist _whitelist)
        public
        ownerOnly
        notThis(_whitelist)
    {
        conversionWhitelist = _whitelist;
    }

    
    function transferTokenOwnership(address _newOwner)
        public
        ownerOnly
        only(BANCOR_CONVERTER_UPGRADER)
    {
        super.transferTokenOwnership(_newOwner);
    }

    
    function acceptTokenOwnership()
        public
        ownerOnly
        totalSupplyGreaterThanZeroOnly
    {
        super.acceptTokenOwnership();
    }

    
    function setConversionFee(uint32 _conversionFee)
        public
        ownerOnly
    {
        require(_conversionFee >= 0 && _conversionFee <= maxConversionFee);
        emit ConversionFeeUpdate(conversionFee, _conversionFee);
        conversionFee = _conversionFee;
    }

    
    function getFinalAmount(uint256 _amount, uint8 _magnitude) public view returns (uint256) {
        return _amount.mul((CONVERSION_FEE_RESOLUTION - conversionFee) ** _magnitude).div(CONVERSION_FEE_RESOLUTION ** _magnitude);
    }

    
    function depositTokens(
      IERC20Token _reserveToken,
      uint256 _depositAmount
    )
      public
      ownerOnly
      inactive
    {
      
      ensureTransferFrom(_reserveToken, msg.sender, this, _depositAmount);

      onBuy(_reserveToken, _depositAmount);
    }

    
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public {
        address converterUpgrader = addressOf(BANCOR_CONVERTER_UPGRADER);

        
        
        require(!reserves[_token].isSet || token.owner() != address(this) || owner == converterUpgrader);
        super.withdrawTokens(_token, _to, _amount);
    }

    
    function upgrade() public ownerOnly {
        IBancorConverterUpgrader converterUpgrader = IBancorConverterUpgrader(addressOf(BANCOR_CONVERTER_UPGRADER));

        transferOwnership(converterUpgrader);
        converterUpgrader.upgrade(version);
        acceptOwnership();
    }

    
    function addReserve(IERC20Token _token, uint32 _ratio)
        public
        ownerOnly
        inactive
        validAddress(_token)
        notThis(_token)
        validReserveRatio(_ratio)
    {
        require(_token != token && !reserves[_token].isSet && totalReserveRatio + _ratio <= RATIO_RESOLUTION); 

        reserves[_token].ratio = _ratio;
        reserves[_token].isVirtualBalanceEnabled = false;
        reserves[_token].virtualBalance = 0;
        reserves[_token].isSaleEnabled = true;
        reserves[_token].isSet = true;
        reserveTokens.push(_token);
        totalReserveRatio += _ratio;
    }

    
    function updateReserveVirtualBalance(IERC20Token _reserveToken, uint256 _virtualBalance)
        public
        ownerOnly
        only(BANCOR_CONVERTER_UPGRADER)
        validReserve(_reserveToken)
    {
        Reserve storage reserve = reserves[_reserveToken];
        reserve.isVirtualBalanceEnabled = _virtualBalance != 0;
        reserve.virtualBalance = _virtualBalance;
    }

    
    function getReserveRatio(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {
        return reserves[_reserveToken].ratio;
    }

    
    function getReserveBalance(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {
        return _reserveToken.balanceOf(this);
    }

    
    function _getReserveBalance(IERC20Token _reserveToken)
        internal
        view
        returns (uint256)
    {
        return _reserveToken.balanceOf(this);
    }

    
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256) {
        require(_fromToken != _toToken); 

        
        if (_toToken == token)
            return getPurchaseReturn(_fromToken, _amount);
        else if (_fromToken == token)
            return getSaleReturn(_toToken, _amount);

        
        return getCrossReserveReturn(_fromToken, _toToken, _amount);
    }

    
    function getPurchaseReturn(IERC20Token _reserveToken, uint256 _depositAmount)
        public
        view
        active
        validReserve(_reserveToken)
        returns (uint256, uint256)
    {
        Reserve storage reserve = reserves[_reserveToken];

        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = _getReserveBalance(_reserveToken);
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 amount = formula.calculatePurchaseReturn(tokenSupply, reserveBalance, reserve.ratio, _depositAmount);
        uint256 finalAmount = getFinalAmount(amount, 1);

        
        return (finalAmount, amount - finalAmount);
    }

    
    function getSaleReturn(IERC20Token _reserveToken, uint256 _sellAmount)
        public
        view
        active
        validReserve(_reserveToken)
        returns (uint256, uint256)
    {
        Reserve storage reserve = reserves[_reserveToken];
        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = _getReserveBalance(_reserveToken);
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 amount = formula.calculateSaleReturn(tokenSupply, reserveBalance, reserve.ratio, _sellAmount);
        uint256 finalAmount = getFinalAmount(amount, 1);

        
        return (finalAmount, amount - finalAmount);
    }

    
    function getCrossReserveReturn(IERC20Token _fromReserveToken, IERC20Token _toReserveToken, uint256 _amount)
        public
        view
        active
        validReserve(_fromReserveToken)
        validReserve(_toReserveToken)
        returns (uint256, uint256)
    {
        Reserve storage fromReserve = reserves[_fromReserveToken];
        Reserve storage toReserve = reserves[_toReserveToken];

        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 amount = formula.calculateCrossReserveReturn(
            getReserveBalance(_fromReserveToken),
            fromReserve.ratio,
            getReserveBalance(_toReserveToken),
            toReserve.ratio,
            _amount);
        uint256 finalAmount = getFinalAmount(amount, 2);

        
        
        return (finalAmount, amount - finalAmount);
    }

    
    function convertInternal(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn)
        public
        only(BANCOR_NETWORK)
        greaterThanZero(_minReturn)
        returns (uint256)
    {
        require(_fromToken != _toToken); 

        
        if (_toToken == token)
            return buy(_fromToken, _amount, _minReturn);
        else if (_fromToken == token)
            return sell(_toToken, _amount, _minReturn);

        uint256 amount;
        uint256 feeAmount;

        
        (amount, feeAmount) = getCrossReserveReturn(_fromToken, _toToken, _amount);
        
        require(amount != 0 && amount >= _minReturn);

        Reserve storage fromReserve = reserves[_fromToken];
        Reserve storage toReserve = reserves[_toToken];

        
        uint256 toReserveBalance = getReserveBalance(_toToken);
        assert(amount < toReserveBalance);

        
        ensureTransferFrom(_fromToken, msg.sender, this, _amount);
        
        ensureTransferFrom(_toToken, this, msg.sender, amount);

        
        
        dispatchConversionEvent(_fromToken, _toToken, _amount, amount, feeAmount);

        
        emit PriceDataUpdate(_fromToken, token.totalSupply(), _fromToken.balanceOf(this), fromReserve.ratio);
        emit PriceDataUpdate(_toToken, token.totalSupply(), _toToken.balanceOf(this), toReserve.ratio);
        return amount;
    }

    
    function buy(IERC20Token _reserveToken, uint256 _depositAmount, uint256 _minReturn) internal returns (uint256) {
        uint256 amount;
        uint256 feeAmount;
        (amount, feeAmount) = getPurchaseReturn(_reserveToken, _depositAmount);
        
        require(amount != 0 && amount >= _minReturn);

        Reserve storage reserve = reserves[_reserveToken];

        
        ensureTransferFrom(_reserveToken, msg.sender, this, _depositAmount);
        
        token.issue(msg.sender, amount);

        
        onBuy(_reserveToken, _depositAmount);

        
        dispatchConversionEvent(_reserveToken, token, _depositAmount, amount, feeAmount);

        
        emit PriceDataUpdate(_reserveToken, token.totalSupply(), _getReserveBalance(_reserveToken), reserve.ratio);
        return amount;
    }

    
    function sell(IERC20Token _reserveToken, uint256 _sellAmount, uint256 _minReturn) internal returns (uint256) {
        require(_sellAmount <= token.balanceOf(msg.sender)); 
        uint256 amount;
        uint256 feeAmount;
        (amount, feeAmount) = getSaleReturn(_reserveToken, _sellAmount);
        
        require(amount != 0 && amount >= _minReturn);

        
        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance =  _getReserveBalance(_reserveToken);
        assert(amount < reserveBalance || (amount == reserveBalance && _sellAmount == tokenSupply));

        Reserve storage reserve = reserves[_reserveToken];

        
        onSale(_reserveToken, amount);

        
        token.destroy(msg.sender, _sellAmount);
        
        ensureTransferFrom(_reserveToken, this, msg.sender, amount);

        
        dispatchConversionEvent(token, _reserveToken, _sellAmount, amount, feeAmount);

        
        emit PriceDataUpdate(_reserveToken, token.totalSupply(), _getReserveBalance(_reserveToken), reserve.ratio);
        return amount;
    }

    
    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256) {
        IERC20Token[] memory path = new IERC20Token[](3);
        (path[0], path[1], path[2]) = (_fromToken, token, _toToken);
        return quickConvert2(path, _amount, _minReturn, _affiliateAccount, _affiliateFee);
    }

    
    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee)
        public
        payable
        returns (uint256)
    {
        IBancorNetwork bancorNetwork = IBancorNetwork(addressOf(BANCOR_NETWORK));

        
        
        if (msg.value == 0) {
            
            
            
            if (_path[0] == token) {
                token.destroy(msg.sender, _amount); 
                token.issue(bancorNetwork, _amount); 
            } else {
                
                ensureTransferFrom(_path[0], msg.sender, bancorNetwork, _amount);
            }
        }

        
        return bancorNetwork.convertFor2.value(msg.value)(_path, _amount, _minReturn, msg.sender, _affiliateAccount, _affiliateFee);
    }

    
    function completeXConversion2(
        IERC20Token[] _path,
        uint256 _minReturn,
        uint256 _conversionId
    )
        public
        returns (uint256)
    {
        IBancorX bancorX = IBancorX(addressOf(BANCOR_X));
        IBancorNetwork bancorNetwork = IBancorNetwork(addressOf(BANCOR_NETWORK));

        
        require(_path[0] == addressOf(BNT_TOKEN));

        
        uint256 amount = bancorX.getXTransferAmount(_conversionId, msg.sender);

        
        token.destroy(msg.sender, amount);
        token.issue(bancorNetwork, amount);

        return bancorNetwork.convertFor2(_path, amount, _minReturn, msg.sender, address(0), 0);
    }

    
    function ensureTransferFrom(IERC20Token _token, address _from, address _to, uint256 _amount) internal {
        
        
        
        
        uint256 prevBalance = _token.balanceOf(_to);
        if (_from == address(this))
            INonStandardERC20(_token).transfer(_to, _amount);
        else
            INonStandardERC20(_token).transferFrom(_from, _to, _amount);
        uint256 postBalance = _token.balanceOf(_to);
        require(postBalance > prevBalance);
    }

    
    function fund(uint256 _amount)
        public
        multipleReservesOnly
    {
        uint256 supply = token.totalSupply();
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));

        
        
        IERC20Token reserveToken;
        uint256 reserveBalance;
        uint256 reserveAmount;
        for (uint16 i = 0; i < reserveTokens.length; i++) {
            reserveToken = reserveTokens[i];
            reserveBalance = _getReserveBalance(reserveToken);
            reserveAmount = formula.calculateFundCost(supply, reserveBalance, totalReserveRatio, _amount);

            Reserve storage reserve = reserves[reserveToken];

            
            ensureTransferFrom(reserveToken, msg.sender, this, reserveAmount);

            
            onBuy(reserveToken, reserveAmount);

            
            emit PriceDataUpdate(reserveToken, supply + _amount, reserveBalance + reserveAmount, reserve.ratio);
        }

        
        token.issue(msg.sender, _amount);
    }

    
    function liquidate(uint256 _amount)
        public
        multipleReservesOnly
    {
        uint256 supply = token.totalSupply();
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));

        
        token.destroy(msg.sender, _amount);

        
        
        IERC20Token reserveToken;
        uint256 reserveBalance;
        uint256 reserveAmount;
        for (uint16 i = 0; i < reserveTokens.length; i++) {
            reserveToken = reserveTokens[i];
            reserveBalance = _getReserveBalance(reserveToken);
            reserveAmount = formula.calculateLiquidateReturn(supply, reserveBalance, totalReserveRatio, _amount);

            Reserve storage reserve = reserves[reserveToken];

            
            onSale(reserveToken, reserveAmount);

            
            ensureTransferFrom(reserveToken, this, msg.sender, reserveAmount);

            
            emit PriceDataUpdate(reserveToken, supply - _amount, reserveBalance - reserveAmount, reserve.ratio);
        }
    }

    
    function dispatchConversionEvent(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _returnAmount, uint256 _feeAmount) internal {
        
        
        
        
        assert(_feeAmount < 2 ** 255);
        emit Conversion(_fromToken, _toToken, msg.sender, _amount, _returnAmount, int256(_feeAmount));
    }

    
    function onBuy(IERC20Token _reserveToken, uint256 _amount) internal {
      return;
    }

    
    function onSale(IERC20Token _reserveToken, uint256 _amount) internal {
      return;
    }

    
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256) {
        return convertInternal(_fromToken, _toToken, _amount, _minReturn);
    }

    
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256) {
        return convert2(_fromToken, _toToken, _amount, _minReturn, address(0), 0);
    }

    
    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256) {
        return quickConvert2(_path, _amount, _minReturn, address(0), 0);
    }

    
    function quickConvertPrioritized2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, uint256[] memory, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256) {
        return quickConvert2(_path, _amount, _minReturn, _affiliateAccount, _affiliateFee);
    }

    
    function quickConvertPrioritized(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, uint256, uint8, bytes32, bytes32) public payable returns (uint256) {
        return quickConvert2(_path, _amount, _minReturn, address(0), 0);
    }

    
    function completeXConversion(IERC20Token[] _path, uint256 _minReturn, uint256 _conversionId, uint256, uint8, bytes32, bytes32) public returns (uint256) {
        return completeXConversion2(_path, _minReturn, _conversionId);
    }

    
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool) {
        Reserve storage reserve = reserves[_address];
        return(reserve.virtualBalance, reserve.ratio, reserve.isVirtualBalanceEnabled, reserve.isSaleEnabled, reserve.isSet);
    }

    
    function connectorTokens(uint256 _index) public view returns (IERC20Token) {
        return BancorConverter.reserveTokens[_index];
    }

    
    function connectorTokenCount() public view returns (uint16) {
        return reserveTokenCount();
    }

    
    function addConnector(IERC20Token _token, uint32 _weight, bool ) public {
        addReserve(_token, _weight);
    }

    
    function updateConnector(IERC20Token _connectorToken, uint32 , bool , uint256 _virtualBalance) public {
        updateReserveVirtualBalance(_connectorToken, _virtualBalance);
    }

    
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256) {
        return getReserveBalance(_connectorToken);
    }

    
    function getCrossConnectorReturn(IERC20Token _fromConnectorToken, IERC20Token _toConnectorToken, uint256 _amount) public view returns (uint256, uint256) {
        return getCrossReserveReturn(_fromConnectorToken, _toConnectorToken, _amount);
    }
}





pragma solidity 0.4.26;

interface IRAY {


  
  
  
  
  
  
  
  function mint(bytes32 portfolioId, address beneficiary, uint value) external payable returns(bytes32);


  
  
  
  
  
  
  function deposit(bytes32 tokenId, uint value) external payable;


  
  
  
  
  
  
  
  
  
  
  
  
  
  function redeem(bytes32 tokenId, uint valueToWithdraw, address originalCaller) external returns (uint);


  
  
  
  
  
  
  
  
  
  function getTokenValue(bytes32 portfolioId, bytes32 tokenId) external view returns (uint, uint);

}





pragma solidity 0.4.26;

interface IRAYStorage {

  
  
  
  
  
  
  function getContractAddress(bytes32 contractId) external view returns (address);

  
  
  
  
  
  function getPrincipalAddress(bytes32 rayPortfolioId) external view returns (address);

}



pragma solidity 0.4.26;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



























pragma solidity 0.4.26;


contract IERC721Receiver {
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) public returns (bytes4);
}



pragma solidity 0.4.26;












contract RAYBancorConverter is BancorConverter, IERC721Receiver  {
    using SafeMath for uint256;

     
    bytes32 internal constant NULL_BYTES = bytes32(0);
    
    bytes32 internal constant RAY_PORTFOLIO_MANAGER = keccak256('PortfolioManagerContract');
    bytes32 internal constant RAY_NAV_CALCULATOR = keccak256('NAVCalculatorContract');

    
    mapping (address => bytes32) internal rayTokens;
    
    mapping (address => bytes32) internal rayPortfolioIds;

    address internal rayStorage;

    
    constructor(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee,
        IERC20Token _reserveToken,
        uint32 _reserveRatio,
        address _rayStorage,
        bytes32 _rayPortfolioId
    )
        BancorConverter(_token, _registry, _maxConversionFee, _reserveToken, _reserveRatio)
        public
    {
        rayStorage = _rayStorage;

        
        
        _addRAYReserve(_reserveToken, _rayPortfolioId);
    }

    
    function addRAYReserve(IERC20Token _token, uint32 _ratio, bytes32 _rayPortfolioId)
        public
    {

        
        
        
        super.addReserve(_token, _ratio);

        _addRAYReserve(_token, _rayPortfolioId);
    }

    
    function _addRAYReserve(IERC20Token _token, bytes32 _rayPortfolioId) internal {

      
      
      

      
      
      
      require(
        IRAYStorage(rayStorage).getPrincipalAddress(_rayPortfolioId) == address(_token),
        "#addRAYReserve modifier: This is not a valid RAY portfolio for this token"
      );

      rayPortfolioIds[_token] = _rayPortfolioId;

    }

    
    function upgrade() public ownerOnly {
      revert("No upgrade functionality for this converter implementation.");
    }

    
    function getReserveBalance(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {
        return _reserveToken.balanceOf(this) + getReserveRAYBalance(_reserveToken);
    }

    
    function _getReserveBalance(IERC20Token _reserveToken)
        internal
        view
        returns (uint256)
    {
        return _reserveToken.balanceOf(this) + getReserveRAYBalance(_reserveToken);
    }

    
    function getReserveRAYBalance(IERC20Token _reserveToken)
        internal
        view
        returns (uint256)
    {

      bytes32 rayTokenId = rayTokens[_reserveToken];

      
      if (rayTokenId == NULL_BYTES) {
        return 0;
      }

      
      
      
      bytes32 rayPortfolioId = rayPortfolioIds[_reserveToken];

      
      
      address rayNavCalculator = IRAYStorage(rayStorage).getContractAddress(RAY_NAV_CALCULATOR);

      uint256 tokenValue;
      uint256 nav;

      (tokenValue, nav) = IRAY(rayNavCalculator).getTokenValue(rayPortfolioId, rayTokenId);

      return tokenValue;

    }

    

    
   function onERC721Received
   (
       address ,
       address ,
       uint256 ,
       bytes 
   )
       public
       returns(bytes4)
   {
     
     return this.onERC721Received.selector;
   }

    
    function onBuy(IERC20Token _reserveToken, uint256 _amount) internal {

      
      bytes32 rayPortfolioId = rayPortfolioIds[_reserveToken];

      
      
      
      
      if (rayPortfolioId != NULL_BYTES) {

        
        bytes32 rayTokenId = rayTokens[_reserveToken];
        
        address rayContract = IRAYStorage(rayStorage).getContractAddress(RAY_PORTFOLIO_MANAGER);

        
        
        
        
        
        
        
        
        
        
        require(
          IERC20(_reserveToken).approve(rayContract, _amount),
          "#RAYBancorConverter onBuy(): Approval of ERC20 Token failed"
        );

        
        
        
        
        if (rayTokenId == NULL_BYTES) {
          
          
          bytes32 newRayTokenId = mintRAYToken(rayContract, rayPortfolioId, _amount);
          
          rayTokens[_reserveToken] = newRayTokenId;
        } else {
          
          depositToRAY(rayContract, rayTokenId, _amount);
        }

      }

    }

    
    function onSale(IERC20Token _reserveToken, uint256 _amount) internal {

      
      bytes32 rayTokenId = rayTokens[_reserveToken];

      
      
      if (rayTokenId != NULL_BYTES) {
        
        withdrawFromRAY(rayTokenId, _amount);
      }

    }

    
    function mintRAYToken(address rayContract, bytes32 rayPortfolioId, uint256 _amount) internal returns (bytes32) {

      
      bytes32 rayTokenId = IRAY(rayContract).mint(rayPortfolioId, this, _amount);

      return rayTokenId;

    }

    
    function depositToRAY(address rayContract, bytes32 rayTokenId, uint256 _amount) internal {

      IRAY(rayContract).deposit(rayTokenId, _amount); 

    }

    
    function withdrawFromRAY(bytes32 rayTokenId, uint256 _amount) internal {

      
      
      address rayPortfolioManager = IRAYStorage(rayStorage).getContractAddress(RAY_PORTFOLIO_MANAGER);

      IRAY(rayPortfolioManager).redeem(rayTokenId, _amount, this); 

    }

}