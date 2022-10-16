pragma solidity ^0.6.0;



abstract contract Proxy {
	
	receive() external payable virtual {
		_fallback();
	}

	
	fallback() external payable {
		_fallback();
	}

	
	function _implementation() internal virtual view returns (address impl);

	
	function _delegate(address implementation) internal {
		assembly {
			
			
			
			calldatacopy(0, 0, calldatasize())

			
			
			let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

			
			returndatacopy(0, 0, returndatasize())

			switch result
			
			case 0 { revert(0, returndatasize()) }
			default { return(0, returndatasize()) }
		}
	}

	
	function _willFallback() internal virtual {
	}

	
	function _fallback() internal {
		_willFallback();
		_delegate(_implementation());
	}
}

interface IERC1538 {
	event CommitMessage(string message);
	event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);
}


contract Context {
	
	
	constructor () internal { }

	function _msgSender() internal view virtual returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes memory) {
		this; 
		return msg.data;
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
		_transferOwnership(newOwner);
	}

	
	function _transferOwnership(address newOwner) internal virtual {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

library LibSet_bytes4 {
	struct set
	{
		bytes4[] values;
		mapping(bytes4 => uint256) indexes;
	}

	function length(set storage _set)
	internal view returns (uint256)
	{
		return _set.values.length;
	}

	function at(set storage _set, uint256 _index)
	internal view returns (bytes4 )
	{
		return _set.values[_index - 1];
	}

	function indexOf(set storage _set, bytes4  _value)
	internal view returns (uint256)
	{
		return _set.indexes[_value];
	}

	function contains(set storage _set, bytes4  _value)
	internal view returns (bool)
	{
		return indexOf(_set, _value) != 0;
	}

	function content(set storage _set)
	internal view returns (bytes4[] memory)
	{
		return _set.values;
	}

	function add(set storage _set, bytes4  _value)
	internal returns (bool)
	{
		if (contains(_set, _value))
		{
			return false;
		}
		_set.values.push(_value);
		_set.indexes[_value] = _set.values.length;
		return true;
	}

	function remove(set storage _set, bytes4  _value)
	internal returns (bool)
	{
		if (!contains(_set, _value))
		{
			return false;
		}

		uint256 i    = indexOf(_set, _value);
		uint256 last = length(_set);

		if (i != last)
		{
			bytes4  swapValue = _set.values[last - 1];
			_set.values[i - 1] = swapValue;
			_set.indexes[swapValue] = i;
		}

		delete _set.indexes[_value];
		_set.values.pop();

		return true;
	}

	function clear(set storage _set)
	internal returns (bool)
	{
		for (uint256 i = _set.values.length; i > 0; --i)
		{
			delete _set.indexes[_set.values[i-1]];
		}
		_set.values = new bytes4[](0);
		return true;
	}
}

library LibMap2_bytes4_address_bytes {
	using LibSet_bytes4 for LibSet_bytes4.set;

	struct map
	{
		LibSet_bytes4.set keyset;
		mapping(bytes4 => address) values1;
		mapping(bytes4 => bytes) values2;
	}

	function length(map storage _map)
	internal view returns (uint256)
	{
		return _map.keyset.length();
	}

	function value1(map storage _map, bytes4  _key)
	internal view returns (address )
	{
		return _map.values1[_key];
	}

	function value2(map storage _map, bytes4  _key)
	internal view returns (bytes memory)
	{
		return _map.values2[_key];
	}

	function keyAt(map storage _map, uint256 _index)
	internal view returns (bytes4 )
	{
		return _map.keyset.at(_index);
	}

	function at(map storage _map, uint256 _index)
	internal view returns (bytes4 , address , bytes memory)
	{
		bytes4  key = keyAt(_map, _index);
		return (key, value1(_map, key), value2(_map, key));
	}

	function indexOf(map storage _map, bytes4  _key)
	internal view returns (uint256)
	{
		return _map.keyset.indexOf(_key);
	}

	function contains(map storage _map, bytes4  _key)
	internal view returns (bool)
	{
		return _map.keyset.contains(_key);
	}

	function keys(map storage _map)
	internal view returns (bytes4[] memory)
	{
		return _map.keyset.content();
	}

	function set(
		map storage _map,
		bytes4  _key,
		address  _value1,
		bytes memory _value2)
	internal returns (bool)
	{
		_map.keyset.add(_key);
		_map.values1[_key] = _value1;
		_map.values2[_key] = _value2;
		return true;
	}

	function del(map storage _map, bytes4  _key)
	internal returns (bool)
	{
		_map.keyset.remove(_key);
		delete _map.values1[_key];
		delete _map.values2[_key];
		return true;
	}

	function clear(map storage _map)
	internal returns (bool)
	{
		for (uint256 i = _map.keyset.length(); i > 0; --i)
		{
			bytes4  key = keyAt(_map, i);
			delete _map.values1[key];
			delete _map.values2[key];
		}
		_map.keyset.clear();
		return true;
	}
}

contract ERC1538Store is Ownable
{
	using LibMap2_bytes4_address_bytes for LibMap2_bytes4_address_bytes.map;

	LibMap2_bytes4_address_bytes.map internal m_funcs;
}

contract ERC1538Core is IERC1538, ERC1538Store
{
	bytes4 constant internal RECEIVE  = 0xd217fcc6; 
	bytes4 constant internal FALLBACK = 0xb32cdf4d; 

	event CommitMessage(string message);
	event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);

	function _setFunc(string memory funcSignature, address funcDelegate)
	internal
	{
		bytes4 funcId = bytes4(keccak256(bytes(funcSignature)));
		if (funcId == RECEIVE ) { funcId = bytes4(0x00000000); }
		if (funcId == FALLBACK) { funcId = bytes4(0xFFFFFFFF); }

		address oldDelegate = m_funcs.value1(funcId);

		if (funcDelegate == oldDelegate) 
		{
			return;
		}
		else if (funcDelegate == address(0)) 
		{
			m_funcs.del(funcId);
		}
		else 
		{
			m_funcs.set(funcId, funcDelegate, bytes(funcSignature));
		}

		emit FunctionUpdate(funcId, oldDelegate, funcDelegate, funcSignature);
	}
}

contract ERC1538Proxy is ERC1538Core, Proxy
{
	constructor(address _erc1538Delegate)
	public
	{
		_transferOwnership(msg.sender);
		_setFunc("updateContract(address,string,string)", _erc1538Delegate);
		emit CommitMessage("Added ERC1538 updateContract function at contract creation");
	}

	function _implementation() internal override view returns (address)
	{
		address delegateFunc = m_funcs.value1(msg.sig);

		if (delegateFunc != address(0))
		{
			return delegateFunc;
		}
		else
		{
			return m_funcs.value1(0xFFFFFFFF);
		}
	}
}