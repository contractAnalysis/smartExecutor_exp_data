pragma solidity ^0.5.0;


library SafeMath {
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
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
    
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    

    return c;
  }

  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}



pragma solidity ^0.5.0;

contract ENSResolver {
  function addr(bytes32 node) public view returns (address);
}



pragma solidity ^0.5.0;

interface PointerInterface {
  function getAddress() external view returns (address);
}



pragma solidity ^0.5.0;

interface ChainlinkRequestInterface {
  function oracleRequest(
    address sender,
    uint256 requestPrice,
    bytes32 serviceAgreementID,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 nonce,
    uint256 dataVersion, 
    bytes calldata data
  ) external;

  function cancelOracleRequest(
    bytes32 requestId,
    uint256 payment,
    bytes4 callbackFunctionId,
    uint256 expiration
  ) external;
}



pragma solidity ^0.5.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external returns (uint256 remaining);
  function approve(address spender, uint256 value) external returns (bool success);
  function balanceOf(address owner) external returns (uint256 balance);
  function decimals() external returns (uint8 decimalPlaces);
  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);
  function increaseApproval(address spender, uint256 subtractedValue) external;
  function name() external returns (string memory tokenName);
  function symbol() external returns (string memory tokenSymbol);
  function totalSupply() external returns (uint256 totalTokensIssued);
  function transfer(address to, uint256 value) external returns (bool success);
  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}



pragma solidity ^0.5.0;

interface ENSInterface {

  
  event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

  
  event Transfer(bytes32 indexed node, address owner);

  
  event NewResolver(bytes32 indexed node, address resolver);

  
  event NewTTL(bytes32 indexed node, uint64 ttl);


  function setSubnodeOwner(bytes32 node, bytes32 label, address _owner) external;
  function setResolver(bytes32 node, address _resolver) external;
  function setOwner(bytes32 node, address _owner) external;
  function setTTL(bytes32 node, uint64 _ttl) external;
  function owner(bytes32 node) external view returns (address);
  function resolver(bytes32 node) external view returns (address);
  function ttl(bytes32 node) external view returns (uint64);

}



pragma solidity ^0.5.0;


library Buffer {
  
  struct buffer {
    bytes buf;
    uint capacity;
  }

  
  function init(buffer memory buf, uint capacity) internal pure returns(buffer memory) {
    if (capacity % 32 != 0) {
      capacity += 32 - (capacity % 32);
    }
    
    buf.capacity = capacity;
    assembly {
      let ptr := mload(0x40)
      mstore(buf, ptr)
      mstore(ptr, 0)
      mstore(0x40, add(32, add(ptr, capacity)))
    }
    return buf;
  }

  
  function fromBytes(bytes memory b) internal pure returns(buffer memory) {
    buffer memory buf;
    buf.buf = b;
    buf.capacity = b.length;
    return buf;
  }

  function resize(buffer memory buf, uint capacity) private pure {
    bytes memory oldbuf = buf.buf;
    init(buf, capacity);
    append(buf, oldbuf);
  }

  function max(uint a, uint b) private pure returns(uint) {
    if (a > b) {
      return a;
    }
    return b;
  }

  
  function truncate(buffer memory buf) internal pure returns (buffer memory) {
    assembly {
      let bufptr := mload(buf)
      mstore(bufptr, 0)
    }
    return buf;
  }

  
  function write(buffer memory buf, uint off, bytes memory data, uint len) internal pure returns(buffer memory) {
    require(len <= data.length);

    if (off + len > buf.capacity) {
      resize(buf, max(buf.capacity, len + off) * 2);
    }

    uint dest;
    uint src;
    assembly {
      
      let bufptr := mload(buf)
      
      let buflen := mload(bufptr)
      
      dest := add(add(bufptr, 32), off)
      
      if gt(add(len, off), buflen) {
        mstore(bufptr, add(len, off))
      }
      src := add(data, 32)
    }

    
    for (; len >= 32; len -= 32) {
      assembly {
        mstore(dest, mload(src))
      }
      dest += 32;
      src += 32;
    }

    
    uint mask = 256 ** (32 - len) - 1;
    assembly {
      let srcpart := and(mload(src), not(mask))
      let destpart := and(mload(dest), mask)
      mstore(dest, or(destpart, srcpart))
    }

    return buf;
  }

  
  function append(buffer memory buf, bytes memory data, uint len) internal pure returns (buffer memory) {
    return write(buf, buf.buf.length, data, len);
  }

  
  function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {
    return write(buf, buf.buf.length, data, data.length);
  }

  
  function writeUint8(buffer memory buf, uint off, uint8 data) internal pure returns(buffer memory) {
    if (off >= buf.capacity) {
      resize(buf, buf.capacity * 2);
    }

    assembly {
      
      let bufptr := mload(buf)
      
      let buflen := mload(bufptr)
      
      let dest := add(add(bufptr, off), 32)
      mstore8(dest, data)
      
      if eq(off, buflen) {
        mstore(bufptr, add(buflen, 1))
      }
    }
    return buf;
  }

  
  function appendUint8(buffer memory buf, uint8 data) internal pure returns(buffer memory) {
    return writeUint8(buf, buf.buf.length, data);
  }

  
  function write(buffer memory buf, uint off, bytes32 data, uint len) private pure returns(buffer memory) {
    if (len + off > buf.capacity) {
      resize(buf, (len + off) * 2);
    }

    uint mask = 256 ** len - 1;
    
    data = data >> (8 * (32 - len));
    assembly {
      
      let bufptr := mload(buf)
      
      let dest := add(add(bufptr, off), len)
      mstore(dest, or(and(mload(dest), not(mask)), data))
      
      if gt(add(off, len), mload(bufptr)) {
        mstore(bufptr, add(off, len))
      }
    }
    return buf;
  }

  
  function writeBytes20(buffer memory buf, uint off, bytes20 data) internal pure returns (buffer memory) {
    return write(buf, off, bytes32(data), 20);
  }

  
  function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {
    return write(buf, buf.buf.length, bytes32(data), 20);
  }

  
  function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {
    return write(buf, buf.buf.length, data, 32);
  }

  
  function writeInt(buffer memory buf, uint off, uint data, uint len) private pure returns(buffer memory) {
    if (len + off > buf.capacity) {
      resize(buf, (len + off) * 2);
    }

    uint mask = 256 ** len - 1;
    assembly {
      
      let bufptr := mload(buf)
      
      let dest := add(add(bufptr, off), len)
      mstore(dest, or(and(mload(dest), not(mask)), data))
      
      if gt(add(off, len), mload(bufptr)) {
        mstore(bufptr, add(off, len))
      }
    }
    return buf;
  }

  
  function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {
    return writeInt(buf, buf.buf.length, data, len);
  }
}


pragma solidity ^0.5.0;


library CBOR {
  using Buffer for Buffer.buffer;

  uint8 private constant MAJOR_TYPE_INT = 0;
  uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
  uint8 private constant MAJOR_TYPE_BYTES = 2;
  uint8 private constant MAJOR_TYPE_STRING = 3;
  uint8 private constant MAJOR_TYPE_ARRAY = 4;
  uint8 private constant MAJOR_TYPE_MAP = 5;
  uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

  function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {
    if(value <= 23) {
      buf.appendUint8(uint8((major << 5) | value));
    } else if(value <= 0xFF) {
      buf.appendUint8(uint8((major << 5) | 24));
      buf.appendInt(value, 1);
    } else if(value <= 0xFFFF) {
      buf.appendUint8(uint8((major << 5) | 25));
      buf.appendInt(value, 2);
    } else if(value <= 0xFFFFFFFF) {
      buf.appendUint8(uint8((major << 5) | 26));
      buf.appendInt(value, 4);
    } else if(value <= 0xFFFFFFFFFFFFFFFF) {
      buf.appendUint8(uint8((major << 5) | 27));
      buf.appendInt(value, 8);
    }
  }

  function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {
    buf.appendUint8(uint8((major << 5) | 31));
  }

  function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {
    encodeType(buf, MAJOR_TYPE_INT, value);
  }

  function encodeInt(Buffer.buffer memory buf, int value) internal pure {
    if(value >= 0) {
      encodeType(buf, MAJOR_TYPE_INT, uint(value));
    } else {
      encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));
    }
  }

  function encodeBytes(Buffer.buffer memory buf, bytes memory value) internal pure {
    encodeType(buf, MAJOR_TYPE_BYTES, value.length);
    buf.append(value);
  }

  function encodeString(Buffer.buffer memory buf, string memory value) internal pure {
    encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);
    buf.append(bytes(value));
  }

  function startArray(Buffer.buffer memory buf) internal pure {
    encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
  }

  function startMap(Buffer.buffer memory buf) internal pure {
    encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
  }

  function endSequence(Buffer.buffer memory buf) internal pure {
    encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
  }
}


pragma solidity ^0.5.0;



library Chainlink {
  uint256 internal constant defaultBufferSize = 256; 

  using CBOR for Buffer.buffer;

  struct Request {
    bytes32 id;
    address callbackAddress;
    bytes4 callbackFunctionId;
    uint256 nonce;
    Buffer.buffer buf;
  }

  
  function initialize(
    Request memory self,
    bytes32 _id,
    address _callbackAddress,
    bytes4 _callbackFunction
  ) internal pure returns (Chainlink.Request memory) {
    Buffer.init(self.buf, defaultBufferSize);
    self.id = _id;
    self.callbackAddress = _callbackAddress;
    self.callbackFunctionId = _callbackFunction;
    return self;
  }

  
  function setBuffer(Request memory self, bytes memory _data)
    internal pure
  {
    Buffer.init(self.buf, _data.length);
    Buffer.append(self.buf, _data);
  }

  
  function add(Request memory self, string memory _key, string memory _value)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.encodeString(_value);
  }

  
  function addBytes(Request memory self, string memory _key, bytes memory _value)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.encodeBytes(_value);
  }

  
  function addInt(Request memory self, string memory _key, int256 _value)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.encodeInt(_value);
  }

  
  function addUint(Request memory self, string memory _key, uint256 _value)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.encodeUInt(_value);
  }

  
  function addStringArray(Request memory self, string memory _key, string[] memory _values)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.startArray();
    for (uint256 i = 0; i < _values.length; i++) {
      self.buf.encodeString(_values[i]);
    }
    self.buf.endSequence();
  }
}



pragma solidity ^0.5.0;









contract ChainlinkClient {
  using Chainlink for Chainlink.Request;
  using SafeMath for uint256;

  uint256 constant internal LINK = 10**18;
  uint256 constant private AMOUNT_OVERRIDE = 0;
  address constant private SENDER_OVERRIDE = address(0);
  uint256 constant private ARGS_VERSION = 1;
  bytes32 constant private ENS_TOKEN_SUBNAME = keccak256("link");
  bytes32 constant private ENS_ORACLE_SUBNAME = keccak256("oracle");
  address constant private LINK_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

  ENSInterface private ens;
  bytes32 private ensNode;
  LinkTokenInterface private link;
  ChainlinkRequestInterface private oracle;
  uint256 private requestCount = 1;
  mapping(bytes32 => address) private pendingRequests;

  event ChainlinkRequested(bytes32 indexed id);
  event ChainlinkFulfilled(bytes32 indexed id);
  event ChainlinkCancelled(bytes32 indexed id);

  
  function buildChainlinkRequest(
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionSignature
  ) internal pure returns (Chainlink.Request memory) {
    Chainlink.Request memory req;
    return req.initialize(_specId, _callbackAddress, _callbackFunctionSignature);
  }

  
  function sendChainlinkRequest(Chainlink.Request memory _req, uint256 _payment)
    internal
    returns (bytes32)
  {
    return sendChainlinkRequestTo(address(oracle), _req, _payment);
  }

  
  function sendChainlinkRequestTo(address _oracle, Chainlink.Request memory _req, uint256 _payment)
    internal
    returns (bytes32 requestId)
  {
    requestId = keccak256(abi.encodePacked(this, requestCount));
    _req.nonce = requestCount;
    pendingRequests[requestId] = _oracle;
    emit ChainlinkRequested(requestId);
    require(link.transferAndCall(_oracle, _payment, encodeRequest(_req)), "unable to transferAndCall to oracle");
    requestCount += 1;

    return requestId;
  }

  
  function cancelChainlinkRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunc,
    uint256 _expiration
  )
    internal
  {
    ChainlinkRequestInterface requested = ChainlinkRequestInterface(pendingRequests[_requestId]);
    delete pendingRequests[_requestId];
    emit ChainlinkCancelled(_requestId);
    requested.cancelOracleRequest(_requestId, _payment, _callbackFunc, _expiration);
  }

  
  function setChainlinkOracle(address _oracle) internal {
    oracle = ChainlinkRequestInterface(_oracle);
  }

  
  function setChainlinkToken(address _link) internal {
    link = LinkTokenInterface(_link);
  }

  
  function setPublicChainlinkToken() internal {
    setChainlinkToken(PointerInterface(LINK_TOKEN_POINTER).getAddress());
  }

  
  function chainlinkTokenAddress()
    internal
    view
    returns (address)
  {
    return address(link);
  }

  
  function chainlinkOracleAddress()
    internal
    view
    returns (address)
  {
    return address(oracle);
  }

  
  function addChainlinkExternalRequest(address _oracle, bytes32 _requestId)
    internal
    notPendingRequest(_requestId)
  {
    pendingRequests[_requestId] = _oracle;
  }

  
  function useChainlinkWithENS(address _ens, bytes32 _node)
    internal
  {
    ens = ENSInterface(_ens);
    ensNode = _node;
    bytes32 linkSubnode = keccak256(abi.encodePacked(ensNode, ENS_TOKEN_SUBNAME));
    ENSResolver resolver = ENSResolver(ens.resolver(linkSubnode));
    setChainlinkToken(resolver.addr(linkSubnode));
    updateChainlinkOracleWithENS();
  }

  
  function updateChainlinkOracleWithENS()
    internal
  {
    bytes32 oracleSubnode = keccak256(abi.encodePacked(ensNode, ENS_ORACLE_SUBNAME));
    ENSResolver resolver = ENSResolver(ens.resolver(oracleSubnode));
    setChainlinkOracle(resolver.addr(oracleSubnode));
  }

  
  function encodeRequest(Chainlink.Request memory _req)
    private
    view
    returns (bytes memory)
  {
    return abi.encodeWithSelector(
      oracle.oracleRequest.selector,
      SENDER_OVERRIDE, 
      AMOUNT_OVERRIDE, 
      _req.id,
      _req.callbackAddress,
      _req.callbackFunctionId,
      _req.nonce,
      ARGS_VERSION,
      _req.buf.buf);
  }

  
  function validateChainlinkCallback(bytes32 _requestId)
    internal
    recordChainlinkFulfillment(_requestId)
    
  {}

  
  modifier recordChainlinkFulfillment(bytes32 _requestId) {
    require(msg.sender == pendingRequests[_requestId],
            "Source must be the oracle of the request");
    delete pendingRequests[_requestId];
    emit ChainlinkFulfilled(_requestId);
    _;
  }

  
  modifier notPendingRequest(bytes32 _requestId) {
    require(pendingRequests[_requestId] == address(0), "Request is already pending");
    _;
  }
}



pragma solidity ^0.5.0;


library SafeMath2 {
    
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


pragma solidity >=0.4.24 <0.7.0;



contract Ticketh is ChainlinkClient {
    using SafeMath2 for uint256;

    uint256 oraclePrice;
    bytes32 jobId;
    address oracleAddress;

    struct Lottery {
        uint256 lotteryId;
        uint256 ticketPrice;
        uint256 currentSum;
        uint256 blockNumber;
        uint256 endBlocks;
        bool lotteryStatus;
        address payable[] participatingPlayers;
        address[] roundWinners;
    }

    mapping(uint256 => Lottery) lotteries;

    struct ChainlinkCallbackDetails {
        uint256 lotteryId;
    }

    mapping(bytes32 => ChainlinkCallbackDetails) chainlinkDetails;

    address payable public ownerAddress;
    address self = address(this);

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Not authorized.");
        _;
    }

    constructor() public payable {
        setPublicChainlinkToken();
        ownerAddress = msg.sender;

        oraclePrice = 100000000000000000;
        jobId = "85e21af0bcfb45d5888851286d57ce0c";
        oracleAddress = 0x89f70fA9F439dbd0A1BC22a09BEFc56adA04d9b4;

        lotteries[0] = Lottery(
            0,
            0.001 ether,
            0,
            0,
            10,
            true,
            new address payable[](0),
            new address[](0)
        );
        lotteries[1] = Lottery(
            1,
            0.05 ether,
            0,
            0,
            17280,
            true,
            new address payable[](0),
            new address[](0)
        );
        lotteries[2] = Lottery(
            2,
            0.1 ether,
            0,
            0,
            28800,
            true,
            new address payable[](0),
            new address[](0)
        );
        lotteries[3] = Lottery(
            3,
            0.5 ether,
            0,
            0,
            40320,
            true,
            new address payable[](0),
            new address[](0)
        );
    }

    function buyTicket(uint256 lotteryId) public payable {
        Lottery storage lottery = lotteries[lotteryId];

        require(
            msg.value >= lottery.ticketPrice && lottery.lotteryStatus == true,
            "Error on buying a ticket!"
        );

        lottery.participatingPlayers.push(msg.sender);
        lottery.currentSum = lottery.currentSum + msg.value;

        if (lottery.participatingPlayers.length == 1) {
            lottery.blockNumber = block.number + lottery.endBlocks;
        }

        if (lottery.blockNumber != 0 && block.number >= lottery.blockNumber) {
            lottery.lotteryStatus = false;
            requestRandomNumber(lotteryId);
        }
    }

    function requestRandomNumber(uint256 lotteryId) internal {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.distributePrize.selector
        );
        req.addUint("min", 0);
        req.addUint(
            "max",
            (lotteries[lotteryId].participatingPlayers.length - 1)
        );
        bytes32 requestId = sendChainlinkRequestTo(oracleAddress, req, oraclePrice);
        chainlinkDetails[requestId] = ChainlinkCallbackDetails(lotteryId);
    }

    function distributePrize(bytes32 _requestId, uint256 _number)
        public
        recordChainlinkFulfillment(_requestId)
    {
        ChainlinkCallbackDetails storage details = chainlinkDetails[_requestId];
        Lottery storage lottery = lotteries[details.lotteryId];

        lottery.participatingPlayers[_number].transfer(
            lottery.currentSum - ((lottery.currentSum * 10) / 100)
        );
        lottery.roundWinners.push(lottery.participatingPlayers[_number]);
        resetLottery(lottery);
    }

    function resetLottery(Lottery storage lottery) internal {
        lottery.participatingPlayers = new address payable[](0);
        lottery.currentSum = 0;
        lottery.blockNumber = 0;
        lottery.lotteryStatus = true;
    }

    
    function withdraw(uint256 amount) public onlyOwner {
        uint256 totalSum = 0;
        for (uint256 i = 0; i < 3; i++) {
            totalSum = totalSum + lotteries[i].currentSum;
        }

        require(amount <= (self.balance - totalSum), "Wrong amount!");
        ownerAddress.transfer(amount);
    }

    function endManually(uint256 lotteryId) public onlyOwner {
        requestRandomNumber(lotteryId);
    }

    
    function changeEndBlocks(uint256 lotteryId, uint256 numberOfBlocks)
        public
        onlyOwner
    {
        lotteries[lotteryId].endBlocks = numberOfBlocks;
    }
    
    function changeTicketPrice(uint256 lotteryId, uint256 ticketPrice)
        public
        onlyOwner
    {
        lotteries[lotteryId].ticketPrice = ticketPrice;
    }

    
    function changeOraclePrice(uint256 newPrice)
        public
        onlyOwner
    {
        oraclePrice = newPrice;
    }

    function changeOracleAddress(address newAddress)
        public
        onlyOwner
    {
        oracleAddress = newAddress;
    }

    function changeJobId(bytes32 newJobId)
        public
        onlyOwner
    {
        jobId = newJobId;
    }

    
    function getPlayers(uint256 lotteryId)
        public
        view
        returns (address payable[] memory)
    {
        return lotteries[lotteryId].participatingPlayers;
    }

    function getWinners(uint256 lotteryId)
        public
        view
        returns (address[] memory)
    {
        return lotteries[lotteryId].roundWinners;
    }

    function getStatus(uint256 lotteryId) public view returns (bool) {
        return lotteries[lotteryId].lotteryStatus;
    }

    function getBlockNum(uint256 lotteryId) public view returns (uint256) {
        return lotteries[lotteryId].blockNumber;
    }

    function getOraclePrice() public view returns (uint256) {
        return oraclePrice;
    }

    function getOracleAddress() public view returns (address) {
        return oracleAddress;
    }

    function getJobId() public view returns (bytes32) {
        return jobId;
    }

    function getLotteryTicketPrice(uint256 lotteryId) public view returns (uint256) {
        return lotteries[lotteryId].ticketPrice;
    }

    function getLotteryEndBlocks(uint256 lotteryId) public view returns (uint256) {
        return lotteries[lotteryId].endBlocks;
    }
}