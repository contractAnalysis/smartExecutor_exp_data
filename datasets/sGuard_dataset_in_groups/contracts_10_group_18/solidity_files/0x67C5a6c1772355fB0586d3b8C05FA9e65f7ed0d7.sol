library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}












library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        
        
        

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}








abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}












library ExplicitERC20 {
    using SafeMath for uint256;

    
    function transferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        internal
    {
        
        if (_quantity > 0) {
            uint256 existingBalance = _token.balanceOf(_to);

            SafeERC20.safeTransferFrom(
                _token,
                _from,
                _to,
                _quantity
            );

            uint256 newBalance = _token.balanceOf(_to);

            
            require(
                newBalance == existingBalance.add(_quantity),
                "Invalid post transfer balance"
            );
        }
    }
}








library AddressArrayUtils {

    
    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    
    function contains(address[] memory A, address a) internal pure returns (bool) {
        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

    
    function hasDuplicate(address[] memory A) internal pure returns(bool) {
        for (uint256 i = 0; i < A.length - 1; i++) {
            address current = A[i];
            for (uint256 j = i + 1; j < A.length; j++) {
                if (current == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    
    function append(address[] memory A, address a) internal pure returns (address[] memory) {
        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

    
    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("Address not in array.");
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    
    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {
        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }
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









contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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



pragma solidity 0.6.10;








contract Controller is Ownable {

    using SafeMath for uint256;
    using AddressArrayUtils for address[];

    

    event FactoryAdded(address _factory);
    event FactoryRemoved(address _factory);
    event FeeEdited(address indexed _module, uint256 indexed _feeType, uint256 _feePercentage);
    event FeeRecipientChanged(address _newFeeRecipient);
    event ModuleAdded(address _module);
    event ModuleRemoved(address _module);
    event ResourceAdded(address _resource, uint256 _id);
    event ResourceRemoved(address _resource, uint256 _id);
    event SetAdded(address _setToken, address _factory);
    event SetRemoved(address _setToken);

    

    
    modifier onlyFactory() {
        require(isFactory[msg.sender], "Only valid factories can call");
        _;
    }

    
    modifier onlyModuleOrResource() {
        require(
            isResource[msg.sender] || isModule[msg.sender],
            "Only valid resources or modules can call"
        );
        _;
    }

    modifier onlyIfInitialized() {
        require(isInitialized, "Contract must be initialized.");
        _;
    }

    

    
    address[] public sets;
    
    address[] public factories;
    
    address[] public modules;
    
    
    address[] public resources;

    
    mapping(address => bool) public isSet;
    mapping(address => bool) public isFactory;
    mapping(address => bool) public isModule;
    mapping(address => bool) public isResource;

    
    
    mapping(address => mapping(uint256 => uint256)) public fees;

    
    
    mapping(uint256 => address) public resourceId;

    
    address public feeRecipient;

    
    bool public isInitialized;

    

    
    constructor(address _feeRecipient) public {
        feeRecipient = _feeRecipient;
    }

    

    
    function initialize(
        address[] memory _factories,
        address[] memory _modules,
        address[] memory _resources,
        uint256[] memory _resourceIds
    )
        external
        onlyOwner
    {
        
        require(
            !isInitialized,
            "Controller is already initialized"
        );

        factories = _factories;
        modules = _modules;
        resources = _resources;

        
        for (uint256 i = 0; i < _factories.length; i++) {
            require(_factories[i] != address(0), "Zero address submitted.");
            isFactory[_factories[i]] = true;
        }
        for (uint256 i = 0; i < _modules.length; i++) {
            require(_modules[i] != address(0), "Zero address submitted.");
            isModule[_modules[i]] = true;
        }
        for (uint256 i = 0; i < _resources.length; i++) {
            require(_resources[i] != address(0), "Zero address submitted.");
            require(_resources.length == _resourceIds.length, "Array lengths do not match.");
            isResource[_resources[i]] = true;
            resourceId[_resourceIds[i]] = _resources[i];
        }

        
        isInitialized = true;
    }

    
    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        external
        onlyIfInitialized
        onlyModuleOrResource
    {
        if (_quantity > 0) {
            ExplicitERC20.transferFrom(
                IERC20(_token),
                _from,
                _to,
                _quantity
            );
        }
    }

    
    function batchTransferFrom(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external
        onlyIfInitialized
        onlyModuleOrResource
    {
        
        uint256 tokenCount = _tokens.length;

        
        require(
            tokenCount > 0,
            "Tokens must not be empty"
        );

        
        require(
            tokenCount == _quantities.length,
            "Tokens and quantities lengths mismatch"
        );

        for (uint256 i = 0; i < tokenCount; i++) {
            if (_quantities[i] > 0) {
                ExplicitERC20.transferFrom(
                    IERC20(_tokens[i]),
                    _from,
                    _to,
                    _quantities[i]
                );
            }
        }
    }

    
    function addSet(address _setToken) external onlyIfInitialized onlyFactory {
        require(!isSet[_setToken], "Set already exists");

        isSet[_setToken] = true;

        sets.push(_setToken);

        emit SetAdded(_setToken, msg.sender);
    }

    
    function removeSet(address _setToken) external onlyIfInitialized onlyOwner {
        require(isSet[_setToken], "Set does not exist");

        sets = sets.remove(_setToken);

        isSet[_setToken] = false;

        emit SetRemoved(_setToken);
    }

    
    function addFactory(address _factory) external onlyIfInitialized onlyOwner {
        require(!isFactory[_factory], "Factory already exists");

        isFactory[_factory] = true;

        factories.push(_factory);

        emit FactoryAdded(_factory);
    }

    
    function removeFactory(address _factory) external onlyIfInitialized onlyOwner {
        require(isFactory[_factory], "Factory does not exist");

        factories = factories.remove(_factory);

        isFactory[_factory] = false;

        emit FactoryRemoved(_factory);
    }

    
    function addModule(address _module) external onlyIfInitialized onlyOwner {
        require(!isModule[_module], "Module already exists");

        isModule[_module] = true;

        modules.push(_module);

        emit ModuleAdded(_module);
    }

    
    function removeModule(address _module) external onlyIfInitialized onlyOwner {
        require(isModule[_module], "Module does not exist");

        modules = modules.remove(_module);

        isModule[_module] = false;

        emit ModuleRemoved(_module);
    }

    
    function addResource(address _resource, uint256 _id) external onlyIfInitialized onlyOwner {
        require(!isResource[_resource], "Resource already exists");

        require(resourceId[_id] == address(0), "Resource ID already exists");

        isResource[_resource] = true;

        resourceId[_id] = _resource;

        resources.push(_resource);

        emit ResourceAdded(_resource, _id);
    }

    
    function removeResource(uint256 _id) external onlyIfInitialized onlyOwner {
        address resourceToRemove = resourceId[_id];

        require(resourceToRemove != address(0), "Resource does not exist");

        resources = resources.remove(resourceToRemove);

        resourceId[_id] = address(0);

        isResource[resourceToRemove] = false;

        emit ResourceRemoved(resourceToRemove, _id);
    }

    
    function addFee(address _module, uint256 _feeType, uint256 _newFeePercentage) external onlyIfInitialized onlyOwner {
        require(isModule[_module], "Module does not exist");

        require(fees[_module][_feeType] == 0, "Fee type already exists on module");

        fees[_module][_feeType] = _newFeePercentage;

        emit FeeEdited(_module, _feeType, _newFeePercentage);
    }

    
    function editFee(address _module, uint256 _feeType, uint256 _newFeePercentage) external onlyIfInitialized onlyOwner {
        require(isModule[_module], "Module does not exist");

        require(fees[_module][_feeType] != 0, "Fee type does not exist on module");

        fees[_module][_feeType] = _newFeePercentage;

        emit FeeEdited(_module, _feeType, _newFeePercentage);
    }

    
    function editFeeRecipient(address _newFeeRecipient) external onlyIfInitialized onlyOwner {
        feeRecipient = _newFeeRecipient;

        emit FeeRecipientChanged(_newFeeRecipient);
    }

    

    function getModuleFee(
        address _moduleAddress,
        uint256 _feeType
    )
        external
        view
        returns (uint256)
    {
        return fees[_moduleAddress][_feeType];
    }

    function getFactories() external view returns (address[] memory) {
        return factories;
    }

    function getModules() external view returns (address[] memory) {
        return modules;
    }

    function getResources() external view returns (address[] memory) {
        return resources;
    }

    function getSets() external view returns (address[] memory) {
        return sets;
    }

    
    function isSystemContract(address _contractAddress) external view returns (bool) {
        return (
            isSet[_contractAddress] ||
            isModule[_contractAddress] ||
            isResource[_contractAddress] ||
            isFactory[_contractAddress] ||
            _contractAddress == address(this)
        );
    }
}