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


contract TokenHandler {
    bytes4 private constant APPROVE_FUNC_SELECTOR = bytes4(keccak256("approve(address,uint256)"));
    bytes4 private constant TRANSFER_FUNC_SELECTOR = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 private constant TRANSFER_FROM_FUNC_SELECTOR = bytes4(keccak256("transferFrom(address,address,uint256)"));

    
    function safeApprove(IERC20Token _token, address _spender, uint256 _value) public {
       execute(_token, abi.encodeWithSelector(APPROVE_FUNC_SELECTOR, _spender, _value));
    }

    
    function safeTransfer(IERC20Token _token, address _to, uint256 _value) public {
       execute(_token, abi.encodeWithSelector(TRANSFER_FUNC_SELECTOR, _to, _value));
    }

    
    function safeTransferFrom(IERC20Token _token, address _from, address _to, uint256 _value) public {
       execute(_token, abi.encodeWithSelector(TRANSFER_FROM_FUNC_SELECTOR, _from, _to, _value));
    }

    
    function execute(IERC20Token _token, bytes memory _data) private {
        uint256[1] memory ret = [uint256(1)];

        assembly {
            let success := call(
                gas,            
                _token,         
                0,              
                add(_data, 32), 
                mload(_data),   
                ret,            
                32              
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        require(ret[0] != 0, "ERR_TRANSFER_FAILED");
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
        _ownerOnly();
        _;
    }

    
    function _ownerOnly() internal view {
        require(msg.sender == owner, "ERR_ACCESS_DENIED");
    }

    
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner, "ERR_SAME_OWNER");
        newOwner = _newOwner;
    }

    
    function acceptOwnership() public {
        require(msg.sender == newOwner, "ERR_ACCESS_DENIED");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



pragma solidity 0.4.26;


contract Utils {
    
    modifier greaterThanZero(uint256 _value) {
        _greaterThanZero(_value);
        _;
    }

    
    function _greaterThanZero(uint256 _value) internal pure {
        require(_value > 0, "ERR_ZERO_VALUE");
    }

    
    modifier validAddress(address _address) {
        _validAddress(_address);
        _;
    }

    
    function _validAddress(address _address) internal pure {
        require(_address != address(0), "ERR_INVALID_ADDRESS");
    }

    
    modifier notThis(address _address) {
        _notThis(_address);
        _;
    }

    
    function _notThis(address _address) internal view {
        require(_address != address(this), "ERR_ADDRESS_IS_SELF");
    }
}



pragma solidity 0.4.26;


contract IContractRegistry {
    function addressOf(bytes32 _contractName) public view returns (address);

    
    function getAddress(bytes32 _contractName) public view returns (address);
}



pragma solidity 0.4.26;





contract ContractRegistryClient is Owned, Utils {
    bytes32 internal constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 internal constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 internal constant BANCOR_FORMULA = "BancorFormula";
    bytes32 internal constant CONVERTER_FACTORY = "ConverterFactory";
    bytes32 internal constant CONVERSION_PATH_FINDER = "ConversionPathFinder";
    bytes32 internal constant CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 internal constant CONVERTER_REGISTRY = "BancorConverterRegistry";
    bytes32 internal constant CONVERTER_REGISTRY_DATA = "BancorConverterRegistryData";
    bytes32 internal constant BNT_TOKEN = "BNTToken";
    bytes32 internal constant BANCOR_X = "BancorX";
    bytes32 internal constant BANCOR_X_UPGRADER = "BancorXUpgrader";

    IContractRegistry public registry;      
    IContractRegistry public prevRegistry;  
    bool public onlyOwnerCanUpdateRegistry; 

    
    modifier only(bytes32 _contractName) {
        _only(_contractName);
        _;
    }

    
    function _only(bytes32 _contractName) internal view {
        require(msg.sender == addressOf(_contractName), "ERR_ACCESS_DENIED");
    }

    
    constructor(IContractRegistry _registry) internal validAddress(_registry) {
        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);
    }

    
    function updateRegistry() public {
        
        require(msg.sender == owner || !onlyOwnerCanUpdateRegistry, "ERR_ACCESS_DENIED");

        
        IContractRegistry newRegistry = IContractRegistry(addressOf(CONTRACT_REGISTRY));

        
        require(newRegistry != address(registry) && newRegistry != address(0), "ERR_INVALID_REGISTRY");

        
        require(newRegistry.addressOf(CONTRACT_REGISTRY) != address(0), "ERR_INVALID_REGISTRY");

        
        prevRegistry = registry;

        
        registry = newRegistry;
    }

    
    function restoreRegistry() public ownerOnly {
        
        registry = prevRegistry;
    }

    
    function restrictRegistryUpdate(bool _onlyOwnerCanUpdateRegistry) public ownerOnly {
        
        onlyOwnerCanUpdateRegistry = _onlyOwnerCanUpdateRegistry;
    }

    
    function addressOf(bytes32 _contractName) internal view returns (address) {
        return registry.addressOf(_contractName);
    }
}



pragma solidity 0.4.26;




contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}



pragma solidity 0.4.26;




contract IConverterAnchor is IOwned, ITokenHolder {
}



pragma solidity 0.4.26;


contract IWhitelist {
    function isWhitelisted(address _address) public view returns (bool);
}



pragma solidity 0.4.26;






contract IConverter is IOwned {
    function converterType() public pure returns (uint16);
    function anchor() public view returns (IConverterAnchor) {this;}
    function isActive() public view returns (bool);

    function rateAndFee(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount) public view returns (uint256, uint256);
    function convert(IERC20Token _sourceToken,
                     IERC20Token _targetToken,
                     uint256 _amount,
                     address _trader,
                     address _beneficiary) public payable returns (uint256);

    function conversionWhitelist() public view returns (IWhitelist) {this;}
    function conversionFee() public view returns (uint32) {this;}
    function maxConversionFee() public view returns (uint32) {this;}
    function reserveBalance(IERC20Token _reserveToken) public view returns (uint256);
    function() external payable;

    function transferAnchorOwnership(address _newOwner) public;
    function acceptAnchorOwnership() public;
    function setConversionFee(uint32 _conversionFee) public;
    function setConversionWhitelist(IWhitelist _whitelist) public;
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
    function withdrawETH(address _to) public;
    function addReserve(IERC20Token _token, uint32 _ratio) public;

    
    function token() public view returns (IConverterAnchor);
    function transferTokenOwnership(address _newOwner) public;
    function acceptTokenOwnership() public;
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);
    function connectorTokens(uint256 _index) public view returns (IERC20Token);
    function connectorTokenCount() public view returns (uint16);
}



pragma solidity 0.4.26;





contract IConverterFactory {
    function createAnchor(uint16 _type, string _name, string _symbol, uint8 _decimals) public returns (IConverterAnchor);
    function createConverter(uint16 _type, IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee) public returns (IConverter);
}



pragma solidity 0.4.26;

contract IConverterRegistry {
    function getAnchorCount() public view returns (uint256);
    function getAnchors() public view returns (address[]);
    function getAnchor(uint256 _index) public view returns (address);
    function isAnchor(address _value) public view returns (bool);
    function getLiquidityPoolCount() public view returns (uint256);
    function getLiquidityPools() public view returns (address[]);
    function getLiquidityPool(uint256 _index) public view returns (address);
    function isLiquidityPool(address _value) public view returns (bool);
    function getConvertibleTokenCount() public view returns (uint256);
    function getConvertibleTokens() public view returns (address[]);
    function getConvertibleToken(uint256 _index) public view returns (address);
    function isConvertibleToken(address _value) public view returns (bool);
    function getConvertibleTokenAnchorCount(address _convertibleToken) public view returns (uint256);
    function getConvertibleTokenAnchors(address _convertibleToken) public view returns (address[]);
    function getConvertibleTokenAnchor(address _convertibleToken, uint256 _index) public view returns (address);
    function isConvertibleTokenAnchor(address _convertibleToken, address _value) public view returns (bool);
}



pragma solidity 0.4.26;

interface IConverterRegistryData {
    function addSmartToken(address _smartToken) external;
    function removeSmartToken(address _smartToken) external;
    function addLiquidityPool(address _liquidityPool) external;
    function removeLiquidityPool(address _liquidityPool) external;
    function addConvertibleToken(address _convertibleToken, address _smartToken) external;
    function removeConvertibleToken(address _convertibleToken, address _smartToken) external;
    function getSmartTokenCount() external view returns (uint256);
    function getSmartTokens() external view returns (address[]);
    function getSmartToken(uint256 _index) external view returns (address);
    function isSmartToken(address _value) external view returns (bool);
    function getLiquidityPoolCount() external view returns (uint256);
    function getLiquidityPools() external view returns (address[]);
    function getLiquidityPool(uint256 _index) external view returns (address);
    function isLiquidityPool(address _value) external view returns (bool);
    function getConvertibleTokenCount() external view returns (uint256);
    function getConvertibleTokens() external view returns (address[]);
    function getConvertibleToken(uint256 _index) external view returns (address);
    function isConvertibleToken(address _value) external view returns (bool);
    function getConvertibleTokenSmartTokenCount(address _convertibleToken) external view returns (uint256);
    function getConvertibleTokenSmartTokens(address _convertibleToken) external view returns (address[]);
    function getConvertibleTokenSmartToken(address _convertibleToken, uint256 _index) external view returns (address);
    function isConvertibleTokenSmartToken(address _convertibleToken, address _value) external view returns (bool);
}



pragma solidity 0.4.26;








contract ConverterRegistry is IConverterRegistry, ContractRegistryClient, TokenHandler {
    address private constant ETH_RESERVE_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    
    event ConverterAnchorAdded(address indexed _anchor);

    
    event ConverterAnchorRemoved(address indexed _anchor);

    
    event LiquidityPoolAdded(address indexed _liquidityPool);

    
    event LiquidityPoolRemoved(address indexed _liquidityPool);

    
    event ConvertibleTokenAdded(address indexed _convertibleToken, address indexed _smartToken);

    
    event ConvertibleTokenRemoved(address indexed _convertibleToken, address indexed _smartToken);

    
    event SmartTokenAdded(address indexed _smartToken);

    
    event SmartTokenRemoved(address indexed _smartToken);

    
    constructor(IContractRegistry _registry) ContractRegistryClient(_registry) public {
    }

    
    function newConverter(
        uint16 _type,
        string _name,
        string _symbol,
        uint8 _decimals,
        uint32 _maxConversionFee,
        IERC20Token[] memory _reserveTokens,
        uint32[] memory _reserveWeights
    )
    public returns (IConverter)
    {
        uint256 length = _reserveTokens.length;
        require(length == _reserveWeights.length, "ERR_INVALID_RESERVES");
        require(getLiquidityPoolByConfig(_type, _reserveTokens, _reserveWeights) == IConverterAnchor(0), "ERR_ALREADY_EXISTS");

        IConverterFactory factory = IConverterFactory(addressOf(CONVERTER_FACTORY));
        IConverterAnchor anchor = IConverterAnchor(factory.createAnchor(_type, _name, _symbol, _decimals));
        IConverter converter = IConverter(factory.createConverter(_type, anchor, registry, _maxConversionFee));

        anchor.acceptOwnership();
        converter.acceptOwnership();

        for (uint256 i = 0; i < length; i++)
            converter.addReserve(_reserveTokens[i], _reserveWeights[i]);

        anchor.transferOwnership(converter);
        converter.acceptAnchorOwnership();
        converter.transferOwnership(msg.sender);

        addConverterInternal(converter);
        return converter;
    }

    
    function addConverter(IConverter _converter) public ownerOnly {
        require(isConverterValid(_converter), "ERR_INVALID_CONVERTER");
        addConverterInternal(_converter);
    }

    
    function removeConverter(IConverter _converter) public {
        require(msg.sender == owner || !isConverterValid(_converter), "ERR_ACCESS_DENIED");
        removeConverterInternal(_converter);
    }

    
    function getAnchorCount() public view returns (uint256) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getSmartTokenCount();
    }

    
    function getAnchors() public view returns (address[]) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getSmartTokens();
    }

    
    function getAnchor(uint256 _index) public view returns (address) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getSmartToken(_index);
    }

    
    function isAnchor(address _value) public view returns (bool) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).isSmartToken(_value);
    }

    
    function getLiquidityPoolCount() public view returns (uint256) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getLiquidityPoolCount();
    }

    
    function getLiquidityPools() public view returns (address[]) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getLiquidityPools();
    }

    
    function getLiquidityPool(uint256 _index) public view returns (address) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getLiquidityPool(_index);
    }

    
    function isLiquidityPool(address _value) public view returns (bool) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).isLiquidityPool(_value);
    }

    
    function getConvertibleTokenCount() public view returns (uint256) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getConvertibleTokenCount();
    }

    
    function getConvertibleTokens() public view returns (address[]) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getConvertibleTokens();
    }

    
    function getConvertibleToken(uint256 _index) public view returns (address) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getConvertibleToken(_index);
    }

    
    function isConvertibleToken(address _value) public view returns (bool) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).isConvertibleToken(_value);
    }

    
    function getConvertibleTokenAnchorCount(address _convertibleToken) public view returns (uint256) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getConvertibleTokenSmartTokenCount(_convertibleToken);
    }

    
    function getConvertibleTokenAnchors(address _convertibleToken) public view returns (address[]) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getConvertibleTokenSmartTokens(_convertibleToken);
    }

    
    function getConvertibleTokenAnchor(address _convertibleToken, uint256 _index) public view returns (address) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).getConvertibleTokenSmartToken(_convertibleToken, _index);
    }

    
    function isConvertibleTokenAnchor(address _convertibleToken, address _value) public view returns (bool) {
        return IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA)).isConvertibleTokenSmartToken(_convertibleToken, _value);
    }

    
    function getConvertersByAnchors(address[] _anchors) public view returns (address[]) {
        address[] memory converters = new address[](_anchors.length);

        for (uint256 i = 0; i < _anchors.length; i++)
            converters[i] = IConverterAnchor(_anchors[i]).owner();

        return converters;
    }

    
    function isConverterValid(IConverter _converter) public view returns (bool) {
        
        return _converter.token().owner() == address(_converter);
    }

    
    function isSimilarLiquidityPoolRegistered(IConverter _converter) public view returns (bool) {
        uint256 reserveTokenCount = _converter.connectorTokenCount();
        IERC20Token[] memory reserveTokens = new IERC20Token[](reserveTokenCount);
        uint32[] memory reserveWeights = new uint32[](reserveTokenCount);

        
        for (uint256 i = 0; i < reserveTokenCount; i++) {
            IERC20Token reserveToken = _converter.connectorTokens(i);
            reserveTokens[i] = reserveToken;
            reserveWeights[i] = getReserveWeight(_converter, reserveToken);
        }

        
        return getLiquidityPoolByConfig(_converter.converterType(), reserveTokens, reserveWeights) != IConverterAnchor(0);
    }

    
    function getLiquidityPoolByConfig(uint16 _type, IERC20Token[] memory _reserveTokens, uint32[] memory _reserveWeights) public view returns (IConverterAnchor) {
        
        if (_reserveTokens.length == _reserveWeights.length && _reserveTokens.length > 1) {
            
            address[] memory convertibleTokenAnchors = getLeastFrequentTokenAnchors(_reserveTokens);
            
            for (uint256 i = 0; i < convertibleTokenAnchors.length; i++) {
                IConverterAnchor anchor = IConverterAnchor(convertibleTokenAnchors[i]);
                IConverter converter = IConverter(anchor.owner());
                if (isConverterReserveConfigEqual(converter, _type, _reserveTokens, _reserveWeights))
                    return anchor;
            }
        }

        return IConverterAnchor(0);
    }

    
    function addAnchor(IConverterRegistryData _converterRegistryData, address _anchor) internal {
        _converterRegistryData.addSmartToken(_anchor);
        emit ConverterAnchorAdded(_anchor);
        emit SmartTokenAdded(_anchor);
    }

    
    function removeAnchor(IConverterRegistryData _converterRegistryData, address _anchor) internal {
        _converterRegistryData.removeSmartToken(_anchor);
        emit ConverterAnchorRemoved(_anchor);
        emit SmartTokenRemoved(_anchor);
    }

    
    function addLiquidityPool(IConverterRegistryData _converterRegistryData, address _liquidityPool) internal {
        _converterRegistryData.addLiquidityPool(_liquidityPool);
        emit LiquidityPoolAdded(_liquidityPool);
    }

    
    function removeLiquidityPool(IConverterRegistryData _converterRegistryData, address _liquidityPool) internal {
        _converterRegistryData.removeLiquidityPool(_liquidityPool);
        emit LiquidityPoolRemoved(_liquidityPool);
    }

    
    function addConvertibleToken(IConverterRegistryData _converterRegistryData, address _convertibleToken, address _anchor) internal {
        _converterRegistryData.addConvertibleToken(_convertibleToken, _anchor);
        emit ConvertibleTokenAdded(_convertibleToken, _anchor);
    }

    
    function removeConvertibleToken(IConverterRegistryData _converterRegistryData, address _convertibleToken, address _anchor) internal {
        _converterRegistryData.removeConvertibleToken(_convertibleToken, _anchor);
        emit ConvertibleTokenRemoved(_convertibleToken, _anchor);
    }

    function addConverterInternal(IConverter _converter) private {
        IConverterRegistryData converterRegistryData = IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA));
        IConverterAnchor anchor = IConverter(_converter).token();
        uint256 reserveTokenCount = _converter.connectorTokenCount();

        
        addAnchor(converterRegistryData, anchor);
        if (reserveTokenCount > 1)
            addLiquidityPool(converterRegistryData, anchor);
        else
            addConvertibleToken(converterRegistryData, anchor, anchor);

        
        for (uint256 i = 0; i < reserveTokenCount; i++)
            addConvertibleToken(converterRegistryData, _converter.connectorTokens(i), anchor);
    }

    function removeConverterInternal(IConverter _converter) private {
        IConverterRegistryData converterRegistryData = IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA));
        IConverterAnchor anchor = IConverter(_converter).anchor();
        uint256 reserveTokenCount = _converter.connectorTokenCount();

        
        removeAnchor(converterRegistryData, anchor);
        if (reserveTokenCount > 1)
            removeLiquidityPool(converterRegistryData, anchor);
        else
            removeConvertibleToken(converterRegistryData, anchor, anchor);

        
        for (uint256 i = 0; i < reserveTokenCount; i++)
            removeConvertibleToken(converterRegistryData, _converter.connectorTokens(i), anchor);
    }

    function getLeastFrequentTokenAnchors(IERC20Token[] memory _reserveTokens) private view returns (address[] memory) {
        IConverterRegistryData converterRegistryData = IConverterRegistryData(addressOf(CONVERTER_REGISTRY_DATA));
        uint256 minAnchorCount = converterRegistryData.getConvertibleTokenSmartTokenCount(_reserveTokens[0]);
        uint256 index = 0;

        
        for (uint256 i = 1; i < _reserveTokens.length; i++) {
            uint256 convertibleTokenAnchorCount = converterRegistryData.getConvertibleTokenSmartTokenCount(_reserveTokens[i]);
            if (minAnchorCount > convertibleTokenAnchorCount) {
                minAnchorCount = convertibleTokenAnchorCount;
                index = i;
            }
        }

        return converterRegistryData.getConvertibleTokenSmartTokens(_reserveTokens[index]);
    }

    function isConverterReserveConfigEqual(IConverter _converter, uint16 _type, IERC20Token[] memory _reserveTokens, uint32[] memory _reserveWeights) private view returns (bool) {
        if (_type != _converter.converterType())
            return false;

        if (_reserveTokens.length != _converter.connectorTokenCount())
            return false;

        for (uint256 i = 0; i < _reserveTokens.length; i++) {
            if (_reserveWeights[i] != getReserveWeight(_converter, _reserveTokens[i]))
                return false;
        }

        return true;
    }

    bytes4 private constant CONNECTORS_FUNC_SELECTOR = bytes4(keccak256("connectors(address)"));

    
    
    
    function getReserveWeight(address _converter, address _reserveToken) private view returns (uint32) {
        uint256[2] memory ret;
        bytes memory data = abi.encodeWithSelector(CONNECTORS_FUNC_SELECTOR, _reserveToken);

        assembly {
            let success := staticcall(
                gas,           
                _converter,    
                add(data, 32), 
                mload(data),   
                ret,           
                64             
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        return uint32(ret[1]);
    }

    
    function getSmartTokenCount() public view returns (uint256) {
        return getAnchorCount();
    }

    
    function getSmartTokens() public view returns (address[]) {
        return getAnchors();
    }

    
    function getSmartToken(uint256 _index) public view returns (address) {
        return getAnchor(_index);
    }

    
    function isSmartToken(address _value) public view returns (bool) {
        return isAnchor(_value);
    }

    
    function getConvertibleTokenSmartTokenCount(address _convertibleToken) public view returns (uint256) {
        return getConvertibleTokenAnchorCount(_convertibleToken);
    }

    
    function getConvertibleTokenSmartTokens(address _convertibleToken) public view returns (address[]) {
        return getConvertibleTokenAnchors(_convertibleToken);
    }

    
    function getConvertibleTokenSmartToken(address _convertibleToken, uint256 _index) public view returns (address) {
        return getConvertibleTokenAnchor(_convertibleToken, _index);
    }

    
    function isConvertibleTokenSmartToken(address _convertibleToken, address _value) public view returns (bool) {
        return isConvertibleTokenAnchor(_convertibleToken, _value);
    }

    
    function getConvertersBySmartTokens(address[] _smartTokens) public view returns (address[]) {
        return getConvertersByAnchors(_smartTokens);
    }

    
    function getLiquidityPoolByReserveConfig(IERC20Token[] memory _reserveTokens, uint32[] memory _reserveWeights) public view returns (IConverterAnchor) {
        return getLiquidityPoolByConfig(1, _reserveTokens, _reserveWeights);
    }
}