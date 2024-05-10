pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;




abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}



interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



interface IERC721 is IERC165 {
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) external view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) external view returns (address owner);

    
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    
    function transferFrom(address from, address to, uint256 tokenId) external;

    
    function approve(address to, uint256 tokenId) external;

    
    function getApproved(uint256 tokenId) external view returns (address operator);

    
    function setApprovalForAll(address operator, bool _approved) external;

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}



interface IERC721Metadata is IERC721 {

    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function tokenURI(uint256 tokenId) external view returns (string memory);
}



interface IERC721Enumerable is IERC721 {

    
    function totalSupply() external view returns (uint256);

    
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    
    function tokenByIndex(uint256 index) external view returns (uint256);
}



interface IERC721Receiver {
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}



contract ERC165 is IERC165 {
    
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        
        
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
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



library EnumerableSet {
    
    
    
    
    
    
    
    

    struct Set {
        
        bytes32[] _values;

        
        
        mapping (bytes32 => uint256) _indexes;
    }

    
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            
            
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { 
            
            
            

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            
            

            bytes32 lastvalue = set._values[lastIndex];

            
            set._values[toDeleteIndex] = lastvalue;
            
            set._indexes[lastvalue] = toDeleteIndex + 1; 

            
            set._values.pop();

            
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    

    struct AddressSet {
        Set _inner;
    }

    
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    

    struct UintSet {
        Set _inner;
    }

    
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}



library EnumerableMap {
    
    
    
    
    
    
    
    

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        
        MapEntry[] _entries;

        
        
        mapping (bytes32 => uint256) _indexes;
    }

    
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { 
            map._entries.push(MapEntry({ _key: key, _value: value }));
            
            
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { 
            
            
            

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            
            

            MapEntry storage lastEntry = map._entries[lastIndex];

            
            map._entries[toDeleteIndex] = lastEntry;
            
            map._indexes[lastEntry._key] = toDeleteIndex + 1; 

            
            map._entries.pop();

            
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); 
        return map._entries[keyIndex - 1]._value; 
    }

    

    struct UintToAddressMap {
        Map _inner;
    }

    
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key))));
    }

    
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}



library Strings {
    
    function toString(uint256 value) internal pure returns (string memory) {
        
        

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}



contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    
    EnumerableMap.UintToAddressMap private _tokenOwners;

    
    mapping (uint256 => address) private _tokenApprovals;

    
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    
    string private _name;

    
    string private _symbol;

    
    mapping(uint256 => string) private _tokenURIs;

    
    string private _baseURI;

    
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    
    function name() public view override returns (string memory) {
        return _name;
    }

    
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    
    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    
    function totalSupply() public view override returns (uint256) {
        
        return _tokenOwners.length();
    }

    
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        
        _approve(address(0), tokenId);

        
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}



abstract contract ERC721Burnable is Context, ERC721 {
    
    function burn(uint256 tokenId) public virtual {
        
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}

interface IDSSRegistry {


    event Resolve(uint256 indexed tokenId, address indexed to);


    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);
    
    function resolveTo(address to, uint256 tokenId) external;

    
    function resolverOf(uint256 tokenId) external view returns (address);

    function mint(address to,bytes32 extensionHash,string calldata uri,string calldata label) external;

    function mintMany(address[] calldata to,bytes32 extensionHash,string[] calldata uris,string[] calldata labels) external;

    function setResolver(address resolver) external;

    function getTokenExtensionHash(uint256 tokenId) external view returns(bytes32);

}



abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

contract Controller is AccessControl {
  bytes32 public constant ADMIN_ROLE = keccak256("admin");
  modifier onlyAdmin {
      require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
              "Sender is not admin");
      _;
  }
}



library Counters {
    using SafeMath for uint256;

    struct Counter {
        
        
        
        uint256 _value; 
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

contract DSSExtensionCreator is Controller {

    using Counters for Counters.Counter;
    struct Extension {
      mapping(address => bool) extensionMinters;
      mapping(address => bool) extensionSuperAdmins;
      Counters.Counter totalSU;
      string extension;
      bool added;
    }

    mapping(bytes32 => Extension) internal extensions;


    event ExtensionCreated(address indexed owner,bytes32 extensionHash,string extension);
    event AdminAdded(address indexed addr,bytes32 indexed extensionHash,string extension,bool indexed su);
    event AdminRemoved(address indexed addr,bytes32 indexed extensionHash,string extension,bool indexed su);

    modifier onlyExtensionMinter(bytes32 extensionHash) {
      require(extensions[extensionHash].extensionMinters[msg.sender],
              "Sender is not allowed to mint token from that extension");
      _;
    }

    modifier onlyExtensionSuperAdmin(bytes32 extensionHash) {
      require(extensions[extensionHash].extensionSuperAdmins[msg.sender],
              "Sender is not super admin of that extension");
      _;
    }


    constructor() public {
      _setupRole(DEFAULT_ADMIN_ROLE,msg.sender);
    }

    function createExtension(string memory extension) public onlyAdmin {
        bytes32 extensionHash = keccak256(abi.encodePacked(extension));
        require(!_isExtensionUsed(extensionHash),
                "Extension already used");
        _addSuperAdminRole(extensionHash,msg.sender);
        _addMinter(extensionHash,msg.sender);
        extensions[extensionHash].extension = extension;
        extensions[extensionHash].added = true;
        emit ExtensionCreated(msg.sender,extensionHash,extension);
    }

    function createExtensions(string[] memory exts) public onlyAdmin {
        for(uint256 i = 0;i<exts.length; i++){
          createExtension(exts[i]);
        }
    }

    function addMinter(bytes32 extensionHash,address minter) public onlyExtensionSuperAdmin(extensionHash) {
      require(!extensions[extensionHash].extensionMinters[minter],
              "Address is minter of that extension");
      _addMinter(extensionHash,minter);
    }

    function removeMinter(bytes32 extensionHash,address minter) public onlyExtensionSuperAdmin(extensionHash) {
      require(extensions[extensionHash].extensionMinters[minter],
              "Address is not minter of that extension");
      _removeMinter(extensionHash,minter);
    }

    function renounceMinterRole(bytes32 extensionHash) public onlyExtensionMinter(extensionHash) {
      _removeMinter(extensionHash,msg.sender);
    }

    function addSuperAdminRole(bytes32 extensionHash,address admin) public onlyExtensionSuperAdmin(extensionHash) {
      require(extensions[extensionHash].extensionSuperAdmins[msg.sender],
              "Address is already super admin of that extension");
      _addSuperAdminRole(extensionHash,admin);
    }
    function renounceSuperAdminRole(bytes32 extensionHash) public onlyExtensionSuperAdmin(extensionHash) {
      _renounceSuperAdminRole(extensionHash);
    }
    function transferSuperAdminRole(bytes32 extensionHash,address admin) public onlyExtensionSuperAdmin(extensionHash) {
      _addSuperAdminRole(extensionHash,admin);
      _renounceSuperAdminRole(extensionHash);
    }


    function getExtensionName(bytes32 extensionHash) public view returns(string memory){
        return(extensions[extensionHash].extension);
    }

    function _isExtensionUsed(bytes32 extensionHash) private view returns(bool){
        return(extensions[extensionHash].added);
    }

    function _addMinter(bytes32 extensionHash,address minter) private {
      extensions[extensionHash].extensionMinters[minter] = true;
      emit AdminAdded(minter,extensionHash,getExtensionName(extensionHash),false);
    }

    function _removeMinter(bytes32 extensionHash,address minter) private {
      extensions[extensionHash].extensionMinters[minter] = false;
      emit AdminRemoved(minter,extensionHash,getExtensionName(extensionHash),false);
    }

    function _addSuperAdminRole(bytes32 extensionHash,address admin) private {
      extensions[extensionHash].totalSU.increment();
      extensions[extensionHash].extensionSuperAdmins[admin] = true;
      emit AdminAdded(admin,extensionHash,getExtensionName(extensionHash),true);
    }
    function _renounceSuperAdminRole(bytes32 extensionHash) private {
      require(extensions[extensionHash].totalSU.current() > 1,
              "Can not leave extension without any super admin");
      extensions[extensionHash].totalSU.decrement();
      extensions[extensionHash].extensionSuperAdmins[msg.sender] = false;
      if(extensions[extensionHash].extensionMinters[msg.sender]){
        _removeMinter(extensionHash,msg.sender);
      }
      emit AdminRemoved(msg.sender,extensionHash,getExtensionName(extensionHash),true);
    }

    function isExtensionMinter(bytes32 extensionHash,address addr) public view returns(bool) {
      return(extensions[extensionHash].extensionMinters[addr]);
    }

    function isExtensionSuperAdmin(bytes32 extensionHash,address addr) public view returns(bool) {
      return(extensions[extensionHash].extensionSuperAdmins[addr]);
    }

}


contract DSSRegistry is DSSExtensionCreator,IDSSRegistry,ERC721Burnable {





    mapping (uint256 => address) internal _tokenResolvers;
    mapping(uint256 => bytes32) internal _tokenExtension;
    mapping(bytes32 => mapping(bytes32 => bool)) internal _labelUsed;

    Counters.Counter private _tokenIds;

    
    bytes32 public DSS_HASH;
    address public RESOLVER_ADDRESS;
    event ResolverDefined(address resolver);
    event Minted(address from,address indexed to,bytes32 indexed extensionHash,
                 string extension,bytes32 indexed labelHash,string label,
                 uint256 tokenId);

    modifier onlyApprovedOrOwner(uint256 tokenId) {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) public {

      _setBaseURI("ipfs://ipfs/");
      _setupRole(DEFAULT_ADMIN_ROLE,msg.sender);
      DSS_HASH = keccak256(abi.encodePacked(uint256(0x0), keccak256(abi.encodePacked(name))));

    }


    

    function isApprovedOrOwner(address spender, uint256 tokenId) external override view returns (bool) {
        return _isApprovedOrOwner(spender, tokenId);
    }



    

    function mint(address to,bytes32 extensionHash,string memory uri,string memory label) public override onlyExtensionMinter(extensionHash) {
      bytes32 hashLabel = keccak256(abi.encodePacked(label));
      require(extensions[extensionHash].added,"Extension was not created yet");
      require(!_labelUsed[extensionHash][hashLabel],"Domain already registered");
      require(uint256(RESOLVER_ADDRESS) != 0,"Need to set default resolver address to be able to mint");
      _tokenIds.increment();
      uint256 newItemId = uint256(keccak256(abi.encodePacked(uint256(_tokenIds.current()), keccak256(abi.encodePacked("blockchains-domains")))));
      _mint(to, newItemId);
      _setTokenURI(newItemId, uri);
      _resolveTo(RESOLVER_ADDRESS,newItemId);
      _labelUsed[extensionHash][hashLabel] = true;
      _tokenExtension[newItemId] = extensionHash;
      emit Minted(msg.sender,to,extensionHash,getExtensionName(extensionHash),hashLabel,label,newItemId);
    }

    function mintMany(address[] memory to,bytes32 extensionHash,string[] memory uris,string[] memory labels) public override onlyExtensionMinter(extensionHash){
      for (uint256 i = 0; i < uris.length; i++) {
        mint(to[i],extensionHash,uris[i],labels[i]);
      }
    }

    

    function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721)  {
      _resetResolver(tokenId);
      super.transferFrom(from,to,tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721) {
      _resetResolver(tokenId);
      super.safeTransferFrom(from,to,tokenId);
    }

    

    function burn(uint256 tokenId) public virtual override onlyApprovedOrOwner(tokenId) {
        super.burn(tokenId);
        
        if (_tokenResolvers[tokenId] != address(0x0)) {
          delete _tokenResolvers[tokenId];
        }
    }


    

    function getTokenExtensionHash(uint256 tokenId) public view override returns(bytes32){
      return(_tokenExtension[tokenId]);
    }

    

    function setResolver(address resolver) public override {
      require(hasRole(DEFAULT_ADMIN_ROLE,msg.sender),"Sender must be super admin");
      RESOLVER_ADDRESS = resolver;
      emit ResolverDefined(resolver);
    }

    function resolverOf(uint256 tokenId) external override view returns (address) {
      return(_tokenResolvers[tokenId]);
    }

    function resolveTo(address to, uint256 tokenId) external override onlyApprovedOrOwner(tokenId) {
        _resolveTo(to, tokenId);
    }

    function _resolveTo(address to, uint256 tokenId) private {
        require(_exists(tokenId));
        emit Resolve(tokenId, to);
        _tokenResolvers[tokenId] = to;
    }

    function _resetResolver(uint256 tokenId) private {
      Resolver resolver = Resolver(RESOLVER_ADDRESS);
      resolver.reset(tokenId);
    }

}

contract Resolver {

    DSSRegistry internal _registry;

    event Set(uint256 indexed preset, string indexed key, string value, uint256 indexed tokenId);
    event SetPreset(uint256 indexed preset, uint256 indexed tokenId);

    
    mapping (uint256 => mapping (uint256 =>  mapping (string => string))) internal _records;

    
    mapping (uint256 => uint256) _tokenPresets;


    constructor(DSSRegistry registry) public {
      _registry = registry;
    }


    function registry() external view returns (address) {
        return address(_registry);
    }

    
    modifier whenResolver(uint256 tokenId) {
        require(address(this) == _registry.resolverOf(tokenId),
                "Resolver: is not the resolver");
        _;
    }

    function presetOf(uint256 tokenId) external view returns (uint256) {
        return _tokenPresets[tokenId];
    }


    function reset(uint256 tokenId) external {
        require(_registry.isApprovedOrOwner(msg.sender, tokenId) || msg.sender == address(_registry),
                "Not aproved, owner or ERC721 contract to reset presets");
        _setPreset(now, tokenId);
    }

    
    function get(string memory key, uint256 tokenId) public view whenResolver(tokenId) returns (string memory) {
        return _records[tokenId][_tokenPresets[tokenId]][key];
    }



    
    function getMany(string[] calldata keys, uint256 tokenId) external view whenResolver(tokenId) returns (string[] memory) {
        uint256 keyCount = keys.length;
        string[] memory values = new string[](keyCount);
        uint256 preset = _tokenPresets[tokenId];
        for (uint256 i = 0; i < keyCount; i++) {
            values[i] = _records[tokenId][preset][keys[i]];
        }
        return values;
    }

    function setMany(
        string[] memory keys,
        string[] memory values,
        uint256 tokenId
    ) public {
        require(_registry.isApprovedOrOwner(msg.sender, tokenId));
        _setMany(_tokenPresets[tokenId], keys, values, tokenId);
    }

    function _setPreset(uint256 presetId, uint256 tokenId) internal {
        _tokenPresets[tokenId] = presetId;
        emit SetPreset(presetId, tokenId);
    }

    
    function _set(uint256 preset, string memory key, string memory value, uint256 tokenId) internal {
        _records[tokenId][preset][key] = value;
        emit Set(preset, key, value, tokenId);
    }

    
    function _setMany(uint256 preset, string[] memory keys, string[] memory values, uint256 tokenId) internal {
        uint256 keyCount = keys.length;
        for (uint256 i = 0; i < keyCount; i++) {
            _set(preset, keys[i], values[i], tokenId);
        }
    }
}

contract DSSResolver is Resolver {

  
  mapping(uint256 => mapping(uint256 => mapping(bytes32 => address))) internal authorized;

  event Authorized(address indexed authorized,bytes32 indexed keyHash,string key);



  constructor(DSSRegistry registry) public Resolver(registry){

  }


  
  function set(string calldata key, string calldata value, uint256 tokenId) external {
      bytes32 keyHash = keccak256(abi.encodePacked(key));
      require(_registry.isApprovedOrOwner(msg.sender, tokenId) || msg.sender == authorized[tokenId][_tokenPresets[tokenId]][keyHash],
              "Sender is not authorized to change value of that key");
      _set(_tokenPresets[tokenId], key, value, tokenId);
  }
  
  function authorize(string memory key,uint256 tokenId,address target) public {
    require(_registry.isApprovedOrOwner(msg.sender, tokenId),
            "Sender is not authorized to change value of that key");
    bytes32 keyHash = keccak256(abi.encodePacked(key));
    require(authorized[tokenId][_tokenPresets[tokenId]][keyHash] != target,
            "Target address is already authorized to change that key value");
    authorized[tokenId][_tokenPresets[tokenId]][keyHash] = target;
    Authorized(target,keyHash,key);
  }
}