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



contract IConversionPathFinder {
    function findPath(address _sourceToken, address _targetToken) public view returns (address[] memory);
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







contract ConversionPathFinder is IConversionPathFinder, ContractRegistryClient {
    address public anchorToken;

    
    constructor(IContractRegistry _registry) ContractRegistryClient(_registry) public {
    }

    
    function setAnchorToken(address _anchorToken) public ownerOnly {
        anchorToken = _anchorToken;
    }

    
    function findPath(address _sourceToken, address _targetToken) public view returns (address[] memory) {
        IConverterRegistry converterRegistry = IConverterRegistry(addressOf(CONVERTER_REGISTRY));
        address[] memory sourcePath = getPath(_sourceToken, converterRegistry);
        address[] memory targetPath = getPath(_targetToken, converterRegistry);
        return getShortestPath(sourcePath, targetPath);
    }

    
    function getPath(address _token, IConverterRegistry _converterRegistry) private view returns (address[] memory) {
        if (_token == anchorToken)
            return getInitialArray(_token);

        address[] memory anchors;
        if (_converterRegistry.isAnchor(_token))
            anchors = getInitialArray(_token);
        else
            anchors = _converterRegistry.getConvertibleTokenAnchors(_token);

        for (uint256 n = 0; n < anchors.length; n++) {
            IConverter converter = IConverter(IConverterAnchor(anchors[n]).owner());
            uint256 connectorTokenCount = converter.connectorTokenCount();
            for (uint256 i = 0; i < connectorTokenCount; i++) {
                address connectorToken = converter.connectorTokens(i);
                if (connectorToken != _token) {
                    address[] memory path = getPath(connectorToken, _converterRegistry);
                    if (path.length > 0)
                        return getExtendedArray(_token, anchors[n], path);
                }
            }
        }

        return new address[](0);
    }

    
    function getShortestPath(address[] memory _sourcePath, address[] memory _targetPath) private pure returns (address[] memory) {
        if (_sourcePath.length > 0 && _targetPath.length > 0) {
            uint256 i = _sourcePath.length;
            uint256 j = _targetPath.length;
            while (i > 0 && j > 0 && _sourcePath[i - 1] == _targetPath[j - 1]) {
                i--;
                j--;
            }

            address[] memory path = new address[](i + j + 1);
            for (uint256 m = 0; m <= i; m++)
                path[m] = _sourcePath[m];
            for (uint256 n = j; n > 0; n--)
                path[path.length - n] = _targetPath[n - 1];

            uint256 length = 0;
            for (uint256 p = 0; p < path.length; p += 1) {
                for (uint256 q = p + 2; q < path.length - p % 2; q += 2) {
                    if (path[p] == path[q])
                        p = q;
                }
                path[length++] = path[p];
            }

            return getPartialArray(path, length);
        }

        return new address[](0);
    }

    
    function getInitialArray(address _item) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = _item;
        return array;
    }

    
    function getExtendedArray(address _item0, address _item1, address[] memory _array) private pure returns (address[] memory) {
        address[] memory array = new address[](2 + _array.length);
        array[0] = _item0;
        array[1] = _item1;
        for (uint256 i = 0; i < _array.length; i++)
            array[2 + i] = _array[i];
        return array;
    }

    
    function getPartialArray(address[] memory _array, uint256 _length) private pure returns (address[] memory) {
        address[] memory array = new address[](_length);
        for (uint256 i = 0; i < _length; i++)
            array[i] = _array[i];
        return array;
    }
}