pragma solidity ^0.5.0;





interface ERC20 {
  function transfer( address to, uint256 value ) external returns (bool);
  function transferFrom( address from, address to, uint256 value )
    external returns (bool);
}

interface ERC721 {
  function transferFrom( address _from, address _to, uint256 _tokenId )
    external payable;
}

interface ENS {
  function setOwner( bytes32 _node, address _owner ) external;
}










contract Admin {
  modifier isAdmin {
    require( msg.sender == admin, "!admin" );
    _;
  }
  address payable public admin;
  constructor() public {
    admin = msg.sender;
  }
  function setAdmin( address payable _newAdmin ) public isAdmin {
    admin = _newAdmin;
  }
}











































contract escrobot is Admin {

  event UIReleased( string version, string link, string sig );

  event Submitted( bytes32 indexed orderId, address indexed seller );

  event Canceled( bytes32 indexed orderId, address indexed seller );

  event Paid( bytes32 indexed orderId, address indexed buyer );

  event TimedOut( bytes32 indexed orderId, address indexed buyer );

  event Shipped( bytes32 indexed orderId,
                 string shipRef,
                 address indexed seller );

  event Completed( bytes32 indexed orderId, address indexed buyer );

  event Noted( bytes32 indexed orderId, string note, address indexed noter );

  enum State { SUBMITTED, CANCELED, PAID, TIMEDOUT, SHIPPED, COMPLETED }

  struct Order {
    address payable seller;
    address payable buyer;
    string description;
    uint256 price;        
    address token;        
    uint256 bond;         
    uint256 timeoutBlocks;
    uint256 takenBlock;
    string shipRef;
    State status;
  }

  string public externalLink;
  string public hexSignature;

  mapping( bytes32 => Order ) public orders;
  uint256 public fee;
  uint256 public counter;
  bytes4 public magic; 

  
  
  

  modifier isSeller( bytes32 _orderId ) {
    require( msg.sender == orders[_orderId].seller, "only seller" );
    _;
  }
  modifier isBuyer( bytes32 _orderId ) {
    require( msg.sender == orders[_orderId].buyer, "only buyer" );
    _;
  }

  function isContract( address _addr ) private view returns (bool) {
    uint32 size;
    assembly {
      size := extcodesize(_addr)
    }
    return (size > 0);
  }

  function status( bytes32 _orderId ) public view returns (State) {
    return orders[_orderId].status;
  }

  
  
  

  

  function submit( string memory _desc,
                   uint256 _price,
                   address _token,
                   uint256 _bond,
                   uint256 _timeoutBlocks ) payable public {

    require( bytes(_desc).length > 1, "needs description" );
    require( _price > 0, "needs price" );
    require( _token == address(0x0) || isContract(_token), "bad token" );
    require( _price + _bond >= _price, "safemath" );
    require( _timeoutBlocks > 0, "needs timeout" );
    require( msg.value >= fee, "needs fee" );

    bytes32 orderId = keccak256( abi.encodePacked(
      counter++, _desc, _price, _token, _bond, _timeoutBlocks, now) );

    orders[orderId].seller = msg.sender;
    orders[orderId].description = _desc;
    orders[orderId].price = _price;
    orders[orderId].token = _token;
    orders[orderId].bond = _bond;
    orders[orderId].timeoutBlocks = _timeoutBlocks;
    orders[orderId].status = State.SUBMITTED;

    emit Submitted( orderId, msg.sender );
    admin.transfer( msg.value );
  }

  

  function cancel( bytes32 _orderId ) public isSeller(_orderId) {

    require( orders[_orderId].status == State.SUBMITTED, "not SUBMITTED" );
    orders[_orderId].status = State.CANCELED;
    emit Canceled( _orderId, msg.sender );
  }

  
  

  function buy( bytes32 _orderId ) payable public {

    require( orders[_orderId].status == State.SUBMITTED, "not SUBMITTED" );

    uint256 needed = orders[_orderId].price + orders[_orderId].bond;

    if (orders[_orderId].token == address(0x0)) {
      require( msg.value >= needed, "insufficient ETH" );
      if (msg.value > needed)
        admin.transfer( msg.value - needed );
    }
    else {
      require( ERC20(orders[_orderId].token).transferFrom(msg.sender,
        address(this), needed), "transferFrom()" );
    }

    orders[_orderId].buyer = msg.sender;
    orders[_orderId].takenBlock = block.number;
    orders[_orderId].status = State.PAID;
    emit Paid( _orderId, msg.sender );
  }

  
  

  function timeout( bytes32 _orderId ) public isBuyer(_orderId) {

    require( orders[_orderId].status == State.PAID, "not PAID" );
    require( block.number > orders[_orderId].takenBlock +
                            orders[_orderId].timeoutBlocks, "too early" );
    require( bytes(orders[_orderId].shipRef).length == 0, "shipped already" );

    uint256 total = orders[_orderId].price + orders[_orderId].bond;

    if ( orders[_orderId].token == address(0x0) ) {
      orders[_orderId].buyer.transfer( total );
    }
    else {
      ERC20(orders[_orderId].token).transfer( orders[_orderId].buyer, total );
    }

    orders[_orderId].buyer = address(0x0);
    orders[_orderId].takenBlock = 0;
    orders[_orderId].status = State.TIMEDOUT;
    emit TimedOut( _orderId, msg.sender );
  }

  

  function ship( bytes32 _orderId, string memory _shipRef )
  public isSeller(_orderId) {

    require(   orders[_orderId].status == State.PAID
            || orders[_orderId].status == State.SHIPPED, "ship state invalid" );

    require( bytes(_shipRef).length > 1, "Ref invalid" );

    orders[_orderId].shipRef = _shipRef;
    orders[_orderId].status = State.SHIPPED;
    emit Shipped( _orderId, _shipRef, msg.sender );
  }

  

  function confirm( bytes32 _orderId ) public isBuyer(_orderId) {

    require( orders[_orderId].status == State.SHIPPED, "not SHIPPED" );

    

    if ( orders[_orderId].token == address(0x0) ) {
      orders[_orderId].seller.transfer( orders[_orderId].price );
      orders[_orderId].buyer.transfer( orders[_orderId].bond );
    }
    else {
      ERC20( orders[_orderId].token )
      .transfer( orders[_orderId].buyer, orders[_orderId].bond );

      ERC20( orders[_orderId].token )
      .transfer( orders[_orderId].seller, orders[_orderId].price );
    }

    orders[_orderId].status = State.COMPLETED;
    emit Completed( _orderId, msg.sender );
  }

  

  function note( bytes32 _orderId, string memory _noteplaintxt ) public {

    require(    msg.sender == orders[_orderId].buyer
             || msg.sender == orders[_orderId].seller, "parties only" );

    emit Noted( _orderId, _noteplaintxt, msg.sender );
  }

  
  
  

  constructor () public {
    fee = 2000 szabo;

    magic = bytes4( keccak256(
      abi.encodePacked("onERC721Received(address,address,uint256,bytes)")) );
  }

  function setFee( uint256 _newfee ) public isAdmin {
    fee = _newfee;
  }

  function publish( string memory _version, string memory _link,
    string memory _sig ) public isAdmin {

    externalLink = _link;
    hexSignature = _sig;
    emit UIReleased( _version, _link, _sig );
  }

  function changeENSOwner( address _ens, bytes32 _node, address payable _to )
  external isAdmin {
    ENS(_ens).setOwner( _node, _to );
  }

  
  
  

  function() external payable {
    admin.transfer( msg.value );
  }

  function tokenFallback( address _from, uint _value, bytes calldata _data )
  external {

    if (_from == address(0x0) || _data.length > 0) {
      
    }

    ERC20(msg.sender).transfer( admin, _value );
  }

  function onERC721Received(address _operator, address _from, uint256 _tokenId,
    bytes calldata _data) external returns(bytes4) {

    if (   _operator == address(0x0)
        || _from == address(0x0)
        || _data.length > 0 ) {
      
    }

    ERC721(msg.sender).transferFrom( address(this), admin, _tokenId );
    return magic;
  }

}