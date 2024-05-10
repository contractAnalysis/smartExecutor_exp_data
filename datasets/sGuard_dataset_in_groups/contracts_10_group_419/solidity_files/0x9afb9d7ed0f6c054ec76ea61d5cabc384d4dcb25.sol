pragma solidity 0.4.26;


contract IOwned {
    
    function owner() public view returns (address) {this;}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}



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


contract IContractRegistry {
    function addressOf(bytes32 _contractName) public view returns (address);

    
    function getAddress(bytes32 _contractName) public view returns (address);
}



pragma solidity 0.4.26;





contract IConverterFactory {
    function createAnchor(uint16 _type, string _name, string _symbol, uint8 _decimals) public returns (IConverterAnchor);
    function createConverter(uint16 _type, IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee) public returns (IConverter);
}



pragma solidity 0.4.26;



contract ITypedConverterAnchorFactory {
    function converterType() public pure returns (uint16);
    function createAnchor(string _name, string _symbol, uint8 _decimals) public returns (IConverterAnchor);
}



pragma solidity 0.4.26;





contract ITypedConverterFactory {
    function converterType() public pure returns (uint16);
    function createConverter(IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee) public returns (IConverter);
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


library SafeMath {
    
    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        require(z >= _x, "ERR_OVERFLOW");
        return z;
    }

    
    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_x >= _y, "ERR_UNDERFLOW");
        return _x - _y;
    }

    
    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        
        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y, "ERR_OVERFLOW");
        return z;
    }

    
    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_y > 0, "ERR_DIVIDE_BY_ZERO");
        uint256 c = _x / _y;
        return c;
    }
}



pragma solidity 0.4.26;





contract ERC20Token is IERC20Token, Utils {
    using SafeMath for uint256;


    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
        
        require(bytes(_name).length > 0, "ERR_INVALID_NAME");
        require(bytes(_symbol).length > 0, "ERR_INVALID_SYMBOL");

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
    }

    
    function transfer(address _to, uint256 _value)
        public
        validAddress(_to)
        returns (bool success)
    {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value)
        public
        validAddress(_from)
        validAddress(_to)
        returns (bool success)
    {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value)
        public
        validAddress(_spender)
        returns (bool success)
    {
        
        require(_value == 0 || allowance[msg.sender][_spender] == 0, "ERR_INVALID_AMOUNT");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}



pragma solidity 0.4.26;





contract ISmartToken is IConverterAnchor, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
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







contract TokenHolder is ITokenHolder, TokenHandler, Owned, Utils {
    
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        safeTransfer(_token, _to, _amount);
    }
}



pragma solidity 0.4.26;






contract SmartToken is ISmartToken, Owned, ERC20Token, TokenHolder {
    using SafeMath for uint256;

    uint16 public constant version = 4;

    bool public transfersEnabled = true;    

    
    event Issuance(uint256 _amount);

    
    event Destruction(uint256 _amount);

    
    constructor(string _name, string _symbol, uint8 _decimals)
        public
        ERC20Token(_name, _symbol, _decimals, 0)
    {
    }

    
    modifier transfersAllowed {
        _transfersAllowed();
        _;
    }

    
    function _transfersAllowed() internal view {
        require(transfersEnabled, "ERR_TRANSFERS_DISABLED");
    }

    
    function disableTransfers(bool _disable) public ownerOnly {
        transfersEnabled = !_disable;
    }

    
    function issue(address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_to)
        notThis(_to)
    {
        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        emit Issuance(_amount);
        emit Transfer(address(0), _to, _amount);
    }

    
    function destroy(address _from, uint256 _amount) public ownerOnly {
        balanceOf[_from] = balanceOf[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);

        emit Transfer(_from, address(0), _amount);
        emit Destruction(_amount);
    }

    

    
    function transfer(address _to, uint256 _value) public transfersAllowed returns (bool success) {
        assert(super.transfer(_to, _value));
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool success) {
        assert(super.transferFrom(_from, _to, _value));
        return true;
    }
}



pragma solidity 0.4.26;









contract ConverterFactory is IConverterFactory, Owned {
    
    event NewConverter(address indexed _converter, address indexed _owner);

    mapping (uint16 => ITypedConverterAnchorFactory) public anchorFactories;
    mapping (uint16 => ITypedConverterFactory) public converterFactories;

    
    function registerTypedConverterAnchorFactory(ITypedConverterAnchorFactory _factory) public ownerOnly {
        anchorFactories[_factory.converterType()] = _factory;
    }

    
    function registerTypedConverterFactory(ITypedConverterFactory _factory) public ownerOnly {
        converterFactories[_factory.converterType()] = _factory;
    }

    
    function createAnchor(uint16 _converterType, string _name, string _symbol, uint8 _decimals) public returns (IConverterAnchor) {
        IConverterAnchor anchor;
        ITypedConverterAnchorFactory factory = anchorFactories[_converterType];

        if (factory == address(0)) {
            
            anchor = new SmartToken(_name, _symbol, _decimals);
        }
        else {
            
            anchor = factory.createAnchor(_name, _symbol, _decimals);
            anchor.acceptOwnership();
        }

        anchor.transferOwnership(msg.sender);
        return anchor;
    }

    
    function createConverter(uint16 _type, IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee) public returns (IConverter) {
        IConverter converter = converterFactories[_type].createConverter(_anchor, _registry, _maxConversionFee);
        converter.acceptOwnership();
        converter.transferOwnership(msg.sender);

        emit NewConverter(converter, msg.sender);
        return converter;
    }
}