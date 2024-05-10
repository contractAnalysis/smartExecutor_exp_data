pragma solidity ^0.6.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

pragma solidity ^0.6.0;


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



pragma solidity ^0.6.0;


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



pragma solidity ^0.6.0;


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



pragma solidity ^0.6.0;


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

pragma solidity >=0.6.0 <0.7.0;

interface ICryptoPunksMarket {

    struct Offer {
        bool isForSale;
        uint punkIndex;
        address seller;
        uint minValue;
        address onlySellTo;
    }

    struct Bid {
        bool hasBid;
        uint punkIndex;
        address bidder;
        uint value;
    }

    event Assign(address indexed to, uint256 punkIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event PunkTransfer(address indexed from, address indexed to, uint256 punkIndex);
    event PunkOffered(uint indexed punkIndex, uint minValue, address indexed toAddress);
    event PunkBidEntered(uint indexed punkIndex, uint value, address indexed fromAddress);
    event PunkBidWithdrawn(uint indexed punkIndex, uint value, address indexed fromAddress);
    event PunkBought(uint indexed punkIndex, uint value, address indexed fromAddress, address indexed toAddress);
    event PunkNoLongerForSale(uint indexed punkIndex);

    function setInitialOwner(address to, uint punkIndex) external;
    function setInitialOwners(address[] calldata addresses, uint[] calldata indices) external;
    function allInitialOwnersAssigned() external;
    function getPunk(uint punkIndex) external;
    function transferPunk(address to, uint punkIndex) external;
    function punkNoLongerForSale(uint punkIndex) external;
    function offerPunkForSale(uint punkIndex, uint minSalePriceInWei) external;
    function offerPunkForSaleToAddress(uint punkIndex, uint minSalePriceInWei, address toAddress) external;
    function buyPunk(uint punkIndex) external;
    function withdraw() external;
    function enterBidForPunk(uint punkIndex) external;
    function acceptBidForPunk(uint punkIndex, uint minPrice) external;
    function withdrawBidForPunk(uint punkIndex) external;
    function punkIndexToAddress(uint punkIndex) external returns (address);
}

pragma solidity >=0.6.0 <0.7.0;

contract Punkology is Ownable {

  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.UintSet;

  bool private isInitialized;
  bool private isPaused;
  ICryptoPunksMarket private cpm;
  IERC20 private pt;
  mapping (uint => address) private whoStaged;
  EnumerableSet.UintSet private cryptoPunksDeposited;
  uint private randNonce = 0;

  event CryptoPunkStaged(uint256 punkIndex, address indexed from);
  event CryptoPunkDeposited(uint256 punkIndex, address indexed from);
  event CryptoPunkRedeemed(uint256 punkIndex, address indexed to);

  modifier whenNotPaused {
    require(!isPaused, "Contract is paused");
    _;
  }

  function getWhoStaged(uint cryptoPunkId) public view returns (address) {
    return whoStaged[cryptoPunkId];
  }

  function getCryptoPunkAtIndex(uint index) public view returns (uint) {
    return cryptoPunksDeposited.at(index);
  }

  function getNumCryptoPunksDeposited() public view returns (uint) {
    return cryptoPunksDeposited.length();
  }

  function genPseudoRand(uint modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % modulus;
  }

  function init(address cryptoPunksAddress, address punkTokenAddress) public {
    require(!isInitialized);
    cpm = ICryptoPunksMarket(cryptoPunksAddress);
    pt = IERC20(punkTokenAddress);
    isInitialized = true;
  }

  function pause() public onlyOwner {
    isPaused = true;
  }

  function unpause() public onlyOwner {
    isPaused = false;
  }

  function migrate(address to) public onlyOwner {
    uint punkBalance = pt.balanceOf(address(this));
    pt.transfer(to, punkBalance);
    uint numCryptoPunks = cryptoPunksDeposited.length();
    for (uint i = 0; i < numCryptoPunks; i++) {
      uint cryptoPunkIndex = cryptoPunksDeposited.at(i);
      cpm.transferPunk(to, cryptoPunkIndex);
    }
  }

  function stageCryptoPunk(uint punkIndex) public whenNotPaused {
    require(cpm.punkIndexToAddress(punkIndex) == msg.sender);
    whoStaged[punkIndex] = msg.sender;
    emit CryptoPunkStaged(punkIndex, msg.sender);
  }

  function withdrawPunkToken(uint punkIndex) public whenNotPaused {
    require(whoStaged[punkIndex] == msg.sender);
    require(cpm.punkIndexToAddress(punkIndex) == address(this));
    cryptoPunksDeposited.add(punkIndex);
    emit CryptoPunkDeposited(punkIndex, msg.sender);
    pt.transfer(msg.sender, 10**18);
  }

  function redeemCryptoPunk() public whenNotPaused {
    uint cpLength = cryptoPunksDeposited.length();
    require(cpLength > 0);
    require(pt.transferFrom(msg.sender, address(this), 10**18));
    uint randomIndex = genPseudoRand(cpLength);
    uint selectedPunk = cryptoPunksDeposited.at(randomIndex);
    cryptoPunksDeposited.remove(selectedPunk);
    emit CryptoPunkRedeemed(selectedPunk, msg.sender);
    cpm.transferPunk(msg.sender, selectedPunk);
  }
}