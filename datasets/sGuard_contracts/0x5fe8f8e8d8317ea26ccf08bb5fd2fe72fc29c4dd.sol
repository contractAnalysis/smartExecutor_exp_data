pragma solidity ^0.5.13;

























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


contract IChai {
    function transfer(address dst, uint wad) external returns (bool);
    
    function move(address src, address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
    function approve(address usr, uint wad) external returns (bool);
    function balanceOf(address usr) external returns (uint);

    
    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

    function dai(address usr) external returns (uint wad);
    function dai(uint chai) external returns (uint wad);

    
    function join(address dst, uint wad) external;

    
    function exit(address src, uint wad) public;

    
    function draw(address src, uint wad) external returns (uint chai);
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


contract Context {
	
	
	constructor () internal { }
	

	function _msgSender() internal view returns (address payable) {
    	return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {
    	this; 
    	return msg.data;
	}
}


interface IERC165 {
	
	function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


contract ERC165 is IERC165 {
	
	bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

	
	mapping(bytes4 => bool) private _supportedInterfaces;

	constructor () internal {
    	
    	
    	_registerInterface(_INTERFACE_ID_ERC165);
	}

	
	function supportsInterface(bytes4 interfaceId) external view returns (bool) {
    	return _supportedInterfaces[interfaceId];
	}

	
	function _registerInterface(bytes4 interfaceId) internal {
    	require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
    	_supportedInterfaces[interfaceId] = true;
	}
}


contract IERC721 is IERC165 {
	event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
	event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
	event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

	
	function balanceOf(address owner) public view returns (uint256 balance);

	
	function ownerOf(uint256 tokenId) public view returns (address owner);

	
	function safeTransferFrom(address from, address to, uint256 tokenId) public;
	
	function transferFrom(address from, address to, uint256 tokenId) public;
	function approve(address to, uint256 tokenId) public;
	function getApproved(uint256 tokenId) public view returns (address operator);

	function setApprovalForAll(address operator, bool _approved) public;
	function isApprovedForAll(address owner, address operator) public view returns (bool);


	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


contract IERC721Receiver {
	
	function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
	public returns (bytes4);
}


contract ERC721 is Context, ERC165, IERC721 {
	using SafeMath for uint256;
	using Address for address;
	using Counters for Counters.Counter;

	
	
	bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

	
	mapping (uint256 => address) private _tokenOwner;

	
	mapping (uint256 => address) private _tokenApprovals;

	
	mapping (address => Counters.Counter) private _ownedTokensCount;

	
	mapping (address => mapping (address => bool)) private _operatorApprovals;

	
	bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

	constructor () public {
    	
    	_registerInterface(_INTERFACE_ID_ERC721);
	}

	
	function balanceOf(address owner) public view returns (uint256) {
    	require(owner != address(0), "ERC721: balance query for the zero address");

    	return _ownedTokensCount[owner].current();
	}

	
	function ownerOf(uint256 tokenId) public view returns (address) {
    	address owner = _tokenOwner[tokenId];
    	require(owner != address(0), "ERC721: owner query for nonexistent token");

    	return owner;
	}

	
	function approve(address to, uint256 tokenId) public {
    	address owner = ownerOf(tokenId);
    	require(to != owner, "ERC721: approval to current owner");

    	require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
        	"ERC721: approve caller is not owner nor approved for all"
    	);

    	_tokenApprovals[tokenId] = to;
    	emit Approval(owner, to, tokenId);
	}

	
	function getApproved(uint256 tokenId) public view returns (address) {
    	require(_exists(tokenId), "ERC721: approved query for nonexistent token");

    	return _tokenApprovals[tokenId];
	}

	
	function setApprovalForAll(address to, bool approved) public {
    	require(to != _msgSender(), "ERC721: approve to caller");

    	_operatorApprovals[_msgSender()][to] = approved;
    	emit ApprovalForAll(_msgSender(), to, approved);
	}

	
	function isApprovedForAll(address owner, address operator) public view returns (bool) {
    	return _operatorApprovals[owner][operator];
	}

	
	function transferFrom(address from, address to, uint256 tokenId) public {
    	
    	require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

    	_transferFrom(from, to, tokenId);
	}

	
	function safeTransferFrom(address from, address to, uint256 tokenId) public {
    	safeTransferFrom(from, to, tokenId, "");
	}

	/**
 	* @dev Safely transfers the ownership of a given token ID to another address
 	* If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
 	* which is called upon a safe transfer, and return the magic value
 	* `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
 	* the transfer is reverted.
 	* Requires the _msgSender() to be the owner, approved, or operator
 	* @param from current owner of the token
 	* @param to address to receive the ownership of the given token ID
 	* @param tokenId uint256 ID of the token to be transferred
 	* @param _data bytes data to send along with a safe transfer check
 	*/
	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
    	require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    	_safeTransferFrom(from, to, tokenId, _data);
	}

	
	function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {
    	_transferFrom(from, to, tokenId);
    	require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
	}

	
	function _exists(uint256 tokenId) internal view returns (bool) {
    	address owner = _tokenOwner[tokenId];
    	return owner != address(0);
	}

	
	function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
    	require(_exists(tokenId), "ERC721: operator query for nonexistent token");
    	address owner = ownerOf(tokenId);
    	return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
	}

	
	function _safeMint(address to, uint256 tokenId) internal {
    	_safeMint(to, tokenId, "");
	}

	/**
 	* @dev Internal function to safely mint a new token.
 	* Reverts if the given token ID already exists.
 	* If the target address is a contract, it must implement `onERC721Received`,
 	* which is called upon a safe transfer, and return the magic value
 	* `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
 	* the transfer is reverted.
 	* @param to The address that will own the minted token
 	* @param tokenId uint256 ID of the token to be minted
 	* @param _data bytes data to send along with a safe transfer check
 	*/
	function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
    	_mint(to, tokenId);
    	require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
	}

	
	function _mint(address to, uint256 tokenId) internal {
    	require(to != address(0), "ERC721: mint to the zero address");
    	require(!_exists(tokenId), "ERC721: token already minted");

    	_tokenOwner[tokenId] = to;
    	_ownedTokensCount[to].increment();

    	emit Transfer(address(0), to, tokenId);
	}

	
	function _burn(address owner, uint256 tokenId) internal {
    	require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

    	_clearApproval(tokenId);

    	_ownedTokensCount[owner].decrement();
    	_tokenOwner[tokenId] = address(0);

    	emit Transfer(owner, address(0), tokenId);
	}

	
	function _burn(uint256 tokenId) internal {
    	_burn(ownerOf(tokenId), tokenId);
	}

	
	function _transferFrom(address from, address to, uint256 tokenId) internal {
    	require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
    	require(to != address(0), "ERC721: transfer to the zero address");

    	_clearApproval(tokenId);

    	_ownedTokensCount[from].decrement();
    	_ownedTokensCount[to].increment();

    	_tokenOwner[tokenId] = to;

    	emit Transfer(from, to, tokenId);
	}

	
	function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    	internal returns (bool)
	{
    	if (!to.isContract()) {
        	return true;
    	}
    	
    	(bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
        	IERC721Receiver(to).onERC721Received.selector,
        	_msgSender(),
        	from,
        	tokenId,
        	_data
    	));
    	if (!success) {
        	if (returndata.length > 0) {
            	
            	assembly {
                	let returndata_size := mload(returndata)
                	revert(add(32, returndata), returndata_size)
            	}
        	} else {
            	revert("ERC721: transfer to non ERC721Receiver implementer");
        	}
    	} else {
        	bytes4 retval = abi.decode(returndata, (bytes4));
        	return (retval == _ERC721_RECEIVED);
    	}
	}

	
	function _clearApproval(uint256 tokenId) private {
    	if (_tokenApprovals[tokenId] != address(0)) {
        	_tokenApprovals[tokenId] = address(0);
    	}
	}
}


contract IERC721Enumerable is IERC721 {
	function totalSupply() public view returns (uint256);
	function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

	function tokenByIndex(uint256 index) public view returns (uint256);
}


contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {
	
	mapping(address => uint256[]) private _ownedTokens;

	
	mapping(uint256 => uint256) private _ownedTokensIndex;

	
	uint256[] private _allTokens;

	
	mapping(uint256 => uint256) private _allTokensIndex;

	
	bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

	
	constructor () public {
    	
    	_registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
	}

	
	function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
    	require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
    	return _ownedTokens[owner][index];
	}

	
	function totalSupply() public view returns (uint256) {
    	return _allTokens.length;
	}

	
	function tokenByIndex(uint256 index) public view returns (uint256) {
    	require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
    	return _allTokens[index];
	}

	
	function _transferFrom(address from, address to, uint256 tokenId) internal {
    	super._transferFrom(from, to, tokenId);

    	_removeTokenFromOwnerEnumeration(from, tokenId);

    	_addTokenToOwnerEnumeration(to, tokenId);
	}

	
	function _mint(address to, uint256 tokenId) internal {
    	super._mint(to, tokenId);

    	_addTokenToOwnerEnumeration(to, tokenId);

    	_addTokenToAllTokensEnumeration(tokenId);
	}

	
	function _burn(address owner, uint256 tokenId) internal {
    	super._burn(owner, tokenId);

    	_removeTokenFromOwnerEnumeration(owner, tokenId);
    	
    	_ownedTokensIndex[tokenId] = 0;

    	_removeTokenFromAllTokensEnumeration(tokenId);
	}

	
	function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
    	return _ownedTokens[owner];
	}

	
	function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
    	_ownedTokensIndex[tokenId] = _ownedTokens[to].length;
    	_ownedTokens[to].push(tokenId);
	}

	
	function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
    	_allTokensIndex[tokenId] = _allTokens.length;
    	_allTokens.push(tokenId);
	}

	
	function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
    	
    	

    	uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
    	uint256 tokenIndex = _ownedTokensIndex[tokenId];

    	
    	if (tokenIndex != lastTokenIndex) {
        	uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

        	_ownedTokens[from][tokenIndex] = lastTokenId; 
        	_ownedTokensIndex[lastTokenId] = tokenIndex; 
    	}

    	
    	_ownedTokens[from].length--;

    	
    	
	}

	
	function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
    	
    	

    	uint256 lastTokenIndex = _allTokens.length.sub(1);
    	uint256 tokenIndex = _allTokensIndex[tokenId];

    	
    	
    	
    	uint256 lastTokenId = _allTokens[lastTokenIndex];

    	_allTokens[tokenIndex] = lastTokenId; 
    	_allTokensIndex[lastTokenId] = tokenIndex; 

    	
    	_allTokens.length--;
    	_allTokensIndex[tokenId] = 0;
	}
}


contract IERC721Metadata is IERC721 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {
	
	string private _name;

	
	string private _symbol;

	
	string private _baseURI;

	
	mapping(uint256 => string) private _tokenURIs;

	
	bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

	
	constructor (string memory name, string memory symbol) public {
    	_name = name;
    	_symbol = symbol;

    	
    	_registerInterface(_INTERFACE_ID_ERC721_METADATA);
	}

	
	function name() external view returns (string memory) {
    	return _name;
	}

	
	function symbol() external view returns (string memory) {
    	return _symbol;
	}

	
	function tokenURI(uint256 tokenId) external view returns (string memory) {
    	require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    	string memory _tokenURI = _tokenURIs[tokenId];

    	
    	if (bytes(_tokenURI).length == 0) {
        	return "";
    	} else {
        	// abi.encodePacked is being used to concatenate strings
        	return string(abi.encodePacked(_baseURI, _tokenURI));
    	}
	}

	/**
 	* @dev Internal function to set the token URI for a given token.
 	*
 	* Reverts if the token ID does not exist.
 	*
 	* TIP: if all token IDs share a prefix (e.g. if your URIs look like
 	* `http://api.myproject.com/token/<id>`), use {_setBaseURI} to store
 	* it and save gas.
 	*/
	function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
    	require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
    	_tokenURIs[tokenId] = _tokenURI;
	}

	
	function _setBaseURI(string memory baseURI) internal {
    	_baseURI = baseURI;
	}

	
	function baseURI() external view returns (string memory) {
    	return _baseURI;
	}

	
	function _burn(address owner, uint256 tokenId) internal {
    	super._burn(owner, tokenId);

    	
    	if (bytes(_tokenURIs[tokenId]).length != 0) {
        	delete _tokenURIs[tokenId];
    	}
	}
}


contract MoneyStampsERC721 is ERC721Metadata, ERC721Enumerable {
    using SafeMath for uint256;

    

    IERC20 internal dai;
    IChai internal chai;

    mapping(uint256 => uint256) internal chaiBalanceByTokenId; 

    uint256 internal totalMintedTokens;
    uint256 internal mintFee;
    uint256 internal collectedFees;
    uint256 internal requiredFunding; 

    address private owner; 

    bytes16 public version = "v0.0.1";

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    

    
    modifier onlyOwner() {
        require(msg.sender == owner, "E102");
        _;
    }

    

    constructor() ERC721Metadata("$TAMP", "$TAMP") public {
        
        

        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    

    
    function getContractOwner() public view returns (address) {
        return owner;
    }

    

    
    function baseStampWeight() public view returns (uint256) {
        return requiredFunding;
    }

    
    function currentStampLoot(uint256 _tokenId) public returns (uint256) {
        require(_exists(_tokenId), "E402");

        uint256 currentLoot = chai.dai(chaiBalanceByTokenId[_tokenId]);
        if (requiredFunding >= currentLoot) { return 0; }
        return currentLoot.sub(requiredFunding);
    }

    
    function peelStamp(uint256 _tokenId) public returns (uint256) {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "E103");

        uint256 _currentLootInDai = currentStampLoot(_tokenId);
        require(_currentLootInDai > 0, "E403");

        uint256 _paidChai = _payoutStampedDai(msg.sender, _currentLootInDai);
        chaiBalanceByTokenId[_tokenId] = chaiBalanceByTokenId[_tokenId].sub(_paidChai);

        return _currentLootInDai;
    }

    

    
    function mintStamps(address _to, uint256 _amount, string memory _stamp) public returns (uint256[] memory) {
        address _self = address(this);
        uint256 i;
        uint256 _tokenId;
        uint256 _totalDai;
        uint256[] memory _tokenIds = new uint256[](_amount);

        for (i = 0; i < _amount; ++i) {
            _totalDai = requiredFunding.add(_totalDai);

            _tokenId = (totalMintedTokens.add(i+1));
            _tokenIds[i] = _tokenId;
            _mint(_to, _tokenId);
    	    _setTokenURI(_tokenId, _stamp);
        }
        totalMintedTokens = totalMintedTokens.add(_amount);

        if (_totalDai > 0) {
            
            _collectRequiredDai(msg.sender, _totalDai);

            uint256 _balance = chai.balanceOf(_self);
            for (i = 0; i < _amount; ++i) {
                _tokenId = _tokenIds[i];

                
                chai.join(_self, requiredFunding);

                
                 chaiBalanceByTokenId[_tokenId] = _totalChaiForToken(chai.balanceOf(_self).sub(_balance));
                _balance = chai.balanceOf(_self);
            }
        }
        return _tokenIds;
    }

    

    
    function burnStamp(uint256 _tokenId) public {
        
        _burn(msg.sender, _tokenId);

        
        uint256 _tokenChai = chaiBalanceByTokenId[_tokenId];
        chaiBalanceByTokenId[_tokenId] = 0;
        _payoutFundedDai(msg.sender, _tokenChai);
    }

    
    function burnStamps(uint256[] memory _tokenIds) public {
        uint256 _tokenId;
        uint256 _totalChai;
        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            _tokenId = _tokenIds[i];

            
            _burn(msg.sender, _tokenId);

            
            _totalChai = chaiBalanceByTokenId[_tokenId].add(_totalChai);
            chaiBalanceByTokenId[_tokenId] = 0;
        }
        _payoutFundedDai(msg.sender, _totalChai);
    }

    

    
    function setup(address _daiAddress, address _chaiAddress, uint256 _mintFee, uint256 _requiredFunding) public onlyOwner {
        
        dai = IERC20(_daiAddress);
        chai = IChai(_chaiAddress);

        
        dai.approve(_chaiAddress, uint(-1));

        mintFee = _mintFee;
        requiredFunding = _requiredFunding;
    }

    
    function withdrawFees() public onlyOwner {
        uint256 _balance = address(this).balance;
        if (_balance > 0) {
            msg.sender.transfer(_balance);
        }
        if (collectedFees > 0) {
            _payoutFundedDai(msg.sender, collectedFees);
            collectedFees = 0;
        }
    }

    
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "E101");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    

    
    function _collectRequiredDai(address _from, uint256 _requiredDai) internal {
        
        uint256 _userDaiBalance = dai.balanceOf(_from);
        require(_requiredDai <= _userDaiBalance, "E404");
        require(dai.transferFrom(_from, address(this), _requiredDai), "E405");
    }

    
    function _payoutFundedDai(address _to, uint256 _totalChai) internal {
        address _self = address(this);

        
        chai.exit(_self, _totalChai);

        
        uint256 _receivedDai = dai.balanceOf(_self);
        require(dai.transferFrom(_self, _to, _receivedDai), "E405");
    }

    
    function _payoutStampedDai(address _to, uint256 _totalDai) internal returns (uint256) {
        address _self = address(this);

        
        uint256 _chai = chai.draw(_self, _totalDai);

        
        uint256 _receivedDai = dai.balanceOf(_self);
        require(dai.transferFrom(_self, _to, _receivedDai), "E405");
        return _chai;
    }

    
    function _totalChaiForToken(uint256 _tokenChai) internal returns (uint256) {
        if (mintFee == 0) { return _tokenChai; }
        uint256 _mintFee = _tokenChai.mul(mintFee).div(1e4);
        collectedFees = collectedFees.add(_mintFee);
        return _tokenChai.sub(_mintFee);
    }
}