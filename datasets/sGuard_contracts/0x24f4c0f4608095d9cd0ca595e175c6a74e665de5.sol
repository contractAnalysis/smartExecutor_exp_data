pragma solidity ^0.5.0;


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
    
    
    
    
    
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}


contract Context is Initializable {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


contract Base is Initializable, Context, Ownable {
    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {
        Ownable.initialize(_msgSender());
    }

}

contract CoreInterface {

    

    event ModuleAdded(string name, address indexed module);

    event ModuleRemoved(string name, address indexed module);

    event ModuleReplaced(string name, address indexed from, address indexed to);


    

    function set(string memory  _name, address _module, bool _constant) public;

    function setMetadata(string memory _name, string  memory _description) public;

    function remove(string memory _name) public;
    
    function contains(address _module)  public view returns (bool);

    function size() public view returns (uint);

    function isConstant(string memory _name) public view returns (bool);

    function get(string memory _name)  public view returns (address);

    function getName(address _module)  public view returns (string memory);

    function first() public view returns (address);

    function next(address _current)  public view returns (address);
}


library AddressList {

    address constant  ZERO_ADDRESS = address(0);

    struct Data {
        address head;
        address tail;
        uint    length;
        mapping(address => bool)    isContain;
        mapping(address => address) nextOf;
        mapping(address => address) prevOf;
    }

    
    function append(Data storage _data, address _item) internal
    {
        append(_data, _item, _data.tail);
    }

    
    function append(Data storage _data, address _item, address _to) internal {
        
        require(!_data.isContain[_item], "Unable to contain double element");

        
        if (_data.head == ZERO_ADDRESS) {
            _data.head = _data.tail = _item;
        } else {
            require(_data.isContain[_to], "Append target not contained");

            address  nextTo = _data.nextOf[_to];
            if (nextTo != ZERO_ADDRESS) {
                _data.prevOf[nextTo] = _item;
            } else {
                _data.tail = _item;
            }

            _data.nextOf[_to] = _item;
            _data.prevOf[_item] = _to;
            _data.nextOf[_item] = nextTo;
        }
        _data.isContain[_item] = true;
        ++_data.length;
    }

    
    function prepend(Data storage _data, address _item) internal
    {
        prepend(_data, _item, _data.head);
    }

    
    function prepend(Data storage _data, address _item, address _to) internal {
        require(!_data.isContain[_item], "Unable to contain double element");

        
        if (_data.head == ZERO_ADDRESS) {
            _data.head = _data.tail = _item;
        } else {
            require(_data.isContain[_to], "Preppend target is not contained");

            address  prevTo = _data.prevOf[_to];
            if (prevTo != ZERO_ADDRESS) {
                _data.nextOf[prevTo] = _item;
            } else {
                _data.head = _item;
            }

            _data.prevOf[_item] = prevTo;
            _data.nextOf[_item] = _to;
            _data.prevOf[_to] = _item;
        }
        _data.isContain[_item] = true;
        ++_data.length;
    }

    
    function remove(Data storage _data, address _item) internal {
        require(_data.isContain[_item], "Item is not contained");

        address  elemPrev = _data.prevOf[_item];
        address  elemNext = _data.nextOf[_item];

        if (elemPrev != ZERO_ADDRESS) {
            _data.nextOf[elemPrev] = elemNext;
        } else {
            _data.head = elemNext;
        }

        if (elemNext != ZERO_ADDRESS) {
            _data.prevOf[elemNext] = elemPrev;
        } else {
            _data.tail = elemPrev;
        }

        _data.isContain[_item] = false;
        --_data.length;
    }

    
    function replace(Data storage _data, address _from, address _to) internal {

        require(_data.isContain[_from], "Old element not contained");
        require(!_data.isContain[_to], "New element is already contained");

        address  elemPrev = _data.prevOf[_from];
        address  elemNext = _data.nextOf[_from];

        if (elemPrev != ZERO_ADDRESS) {
            _data.nextOf[elemPrev] = _to;
        } else {
            _data.head = _to;
        }

        if (elemNext != ZERO_ADDRESS) {
            _data.prevOf[elemNext] = _to;
        } else {
            _data.tail = _to;
        }

        _data.prevOf[_to] = elemPrev;
        _data.nextOf[_to] = elemNext;
        _data.isContain[_from] = false;
        _data.isContain[_to] = true;
    }

    
    function swap(Data storage _data, address _a, address _b) internal {
        require(_data.isContain[_a] && _data.isContain[_b], "Can not swap element which is not contained");

        address prevA = _data.prevOf[_a];

        remove(_data, _a);
        replace(_data, _b, _a);

        if (prevA == ZERO_ADDRESS) {
            prepend(_data, _b);
        } else if (prevA != _b) {
            append(_data, _b, prevA);
        } else {
            append(_data, _b, _a);
        }
    }

    function first(Data storage _data)  internal view returns (address)
    { 
        return _data.head; 
    }

    function last(Data storage _data)  internal view returns (address)
    { 
        return _data.tail; 
    }

    
    function contains(Data storage _data, address _item)  internal view returns (bool)
    { 
        return _data.isContain[_item]; 
    }

    
    function next(Data storage _data, address _item)  internal view returns (address)
    { 
        return _data.nextOf[_item]; 
    }

    
    function prev(Data storage _data, address _item) internal view returns (address)
    { 
        return _data.prevOf[_item]; 
    }
}


library AddressMap {

    address constant  ZERO_ADDRESS = address(0);

    struct Data {
        mapping(bytes32 => address) valueOf;
        mapping(address => string)  keyOf;
        AddressList.Data            items;
    }

    using AddressList for AddressList.Data;

    
    function set(Data storage _data, string memory _key, address _value) internal {
        address replaced = get(_data, _key);
        if (replaced != ZERO_ADDRESS) {
            _data.items.replace(replaced, _value);
        } else {
            _data.items.append(_value);
        }
        _data.valueOf[keccak256(abi.encodePacked(_key))] = _value;
        _data.keyOf[_value] = _key;
    }

    
    function remove(Data storage _data, string memory _key) internal {
        address  value = get(_data, _key);
        _data.items.remove(value);
        _data.valueOf[keccak256(abi.encodePacked(_key))] = ZERO_ADDRESS;
        _data.keyOf[value] = "";
    }

    /**
     * @dev Get size of map
     * @return count of elements
     */
    function size(Data storage _data) internal view returns (uint)
    { return _data.items.length; }

    /**
     * @dev Get element by name
     * @param _data is an map storage ref
     * @param _key is a item key
     * @return item value
     */
    function get(Data storage _data, string memory _key) internal view returns (address)
    { return _data.valueOf[keccak256(abi.encodePacked(_key))]; }

    /** Get key of element
     * @param _data is an map storage ref
     * @param _item is a item
     * @return item key
     */
    function getKey(Data storage _data, address _item) internal view returns (string memory)
    { 
        return _data.keyOf[_item]; 
    }

}

contract Pool is Base, CoreInterface {

    /* Short description */
    string  public name;
    string  public description;
    address public founder;

    /* Modules map */
    AddressMap.Data modules;

    using AddressList for AddressList.Data;
    using AddressMap for AddressMap.Data;

    /* Module constant mapping */
    mapping(bytes32 => bool) public is_constant;

    /**
     * @dev Contract ABI storage
     *      the contract interface contains source URI
     */
    mapping(address => string) public abiOf;
    
    function initialize() public initializer {
        Base.initialize();
        founder = _msgSender();
    }

    function setMetadata(string memory _name, string  memory _description) public onlyOwner {
        name = _name;
        description = _description;
    }
      
    /**
     * @dev Set new module for given name
     * @param _name infrastructure node name
     * @param _module infrastructure node address
     * @param _constant have a `true` value when you create permanent name of module
     */
    function set(string memory _name, address _module, bool _constant) public onlyOwner {
        
        require(!isConstant(_name), "Pool: module address can not be replaced");

        
        if (modules.get(_name) != ZERO_ADDRESS)
            emit ModuleReplaced(_name, modules.get(_name), _module);
        else
            emit ModuleAdded(_name, _module);
 
        
        modules.set(_name, _module);

        
        is_constant[keccak256(abi.encodePacked(_name))] = _constant;
    }

     
    function remove(string memory _name)  public onlyOwner {
        require(!isConstant(_name), "Pool: module can not be removed");

        
        emit ModuleRemoved(_name, modules.get(_name));

        
        modules.remove(_name);
    }

    
    function contains(address _module) public view returns (bool)
    {
        return modules.items.contains(_module);
    }

    
    function size() public view returns (uint)
    {
        return modules.size();
    }

    
    function isConstant(string memory _name) public view returns (bool)
    {
        return is_constant[keccak256(abi.encodePacked(_name))];
    }

    
    function get(string memory _name) public view returns (address)
    {
        return modules.get(_name);
    }

    
    function getName(address _module) public view returns (string memory)
    {
        return modules.keyOf[_module];
    }

    
    function first() public view returns (address)
    {
        return modules.items.head;
    }

    
    function next(address _current) public view returns (address)
    {
        return modules.items.next(_current);
    }

}