pragma solidity ^0.6.0;


library SafeMath {

  
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require (c / _a == _b);

    return c;
  }

  
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require (_b > 0); 
    uint256 c = _a / _b;
    

    return c;
  }

  
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require (_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require (c >= _a);

    return c;
  }
}


library AddressUtils {

  
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    
    
    
    
    
    
    
    assembly {
      size := extcodesize(addr) 
    }
    return size > 0;
  }
}

interface ERC721TokenReceiver {
    
    
    
    
    
    
    
    
    
    
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes32 _data) external returns(bytes4);
}


interface ERC721Token {
    
    
    
    
    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    
    
    
    
    
    
    function ownerOf(uint256 _tokenId) external view returns (address);
    
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function implementsERC721() external pure returns (bool);
}


contract OperationalControl {
  
  
  
  
  

  
  event ContractUpgrade(address newContract);

  
  address public managerPrimary;
  address public managerSecondary;
  address payable public bankManager;

  
  mapping(address => uint8) public otherManagers;

  
  bool public paused = false;

  
  
  bool public error = false;

  
  modifier onlyManager() {
    require (msg.sender == managerPrimary || msg.sender == managerSecondary || otherManagers[msg.sender] == 1);
    _;
  }

  
  modifier onlyBanker() {
    require (msg.sender == bankManager);
    _;
  }

  
  modifier anyOperator() {
    require (
        msg.sender == managerPrimary ||
        msg.sender == managerSecondary ||
        msg.sender == bankManager ||
        otherManagers[msg.sender] == 1
    );
    _;
  }

  
  function setPrimaryManager(address _newGM) external onlyManager {
    require (_newGM != address(0));

    managerPrimary = _newGM;
  }

  
  function setSecondaryManager(address _newGM) external onlyManager {
    require (_newGM != address(0));

    managerSecondary = _newGM;
  }

  
  function setBankManager(address payable _newBM) external onlyManager {
    require (_newBM != address(0));

    bankManager = _newBM;
  }

  
  function setOtherManager(address _newOp, uint8 _state) external onlyManager {
    require (_newOp != address(0));

    otherManagers[_newOp] = _state;
  }

  
  function batchSetOtherManager(address[] calldata _newOp, uint8[] calldata _state) external onlyManager {
	  for (uint ii = 0; ii < _newOp.length; ii++){
		require (_newOp[ii] != address(0));

    	otherManagers[_newOp[ii]] = _state[ii];
	  }
  }

  

  
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

  
  modifier whenPaused {
    require (paused);
    _;
  }

  
  modifier whenError {
    require (error);
    _;
  }

  
  function pause() external onlyManager whenNotPaused {
    paused = true;
  }

  
  function unpause() public onlyManager whenPaused {
    
    paused = false;
  }

  
  function hasError() public onlyManager whenPaused {
    error = true;
  }

  
  function noError() public onlyManager whenPaused whenError {
    error = false;
  }
}


contract SEAuction is OperationalControl {
  using SafeMath for uint256;
  using AddressUtils for address;

  
  
  
  event SEBidPlaced(address userWallet, uint256 ethBid);

  
  event SEAuctionETHWinner(address userAddress, uint256 buyingPrice, uint256 assetId);

  
  
  event SEAuctionGFCWinner(bytes32 userAddress, uint256 buyingPrice, uint256 assetId);

  
  event SEAuctionRefund(address to, uint256 ethValue);

  mapping(address => uint256) public userETHBalance;
  address[] private allBidders;
  
  
  uint256 public auctionId;
  
  address public winner;
  
  uint256 public winningBid;
  
  address public nftAddress;
  
  uint256 public startingPrice;
  
  uint256 public duration;
  
  
  uint256 public startedAt;
  
  uint256 public assetId;
  
  bytes32 public dAppName;
  
  bool public transferToken;

  uint256 private maxBid;

  
  constructor (uint256 _auctionId, address payable _owner, uint256 _startingPrice, uint256 _startedAt, 
    uint256 _duration, uint256 _assetId, bytes32 _dAppName, address _nftAddress) public {
    require (_owner != address(0));
    paused = true;
    error = false;
    managerPrimary = _owner;
    managerSecondary = _owner;
    bankManager = _owner;
    otherManagers[_owner] = 1;
    
    auctionId = _auctionId;
    startingPrice = _startingPrice;
    maxBid = _startingPrice;
    duration = _duration;
    assetId = _assetId;
    dAppName = _dAppName;
    startedAt = _startedAt;
    nftAddress = _nftAddress;
    transferToken = false;
  }
  
  function isAuctionActive() external view returns(bool){
      return (now <= (startedAt.add(duration)) && winner == address(0));
  }

    
    
    
    
    
    fallback() external payable {  }

    
    receive() external payable {
	    
      require (this.isAuctionActive());
      
      uint256 _potentialUserBalance = userETHBalance[msg.sender].add(msg.value);
      
      require (address(msg.sender) != address(0));
      require (_potentialUserBalance > maxBid);
      
      _incrementBalance(msg.sender, msg.value);
      uint256 _userBalance = userETHBalance[msg.sender];
      maxBid = _userBalance;
    
	  emit SEBidPlaced(msg.sender, msg.value);
    }

  function _incrementBalance(address bidder, uint256 ethValue) private {
    if(userETHBalance[bidder] == 0){
      userETHBalance[bidder] = ethValue;
      allBidders.push(bidder);
    }else{
      uint256 _userBalance = userETHBalance[bidder];
      userETHBalance[bidder] = _userBalance.add(ethValue);
    }
  }

  function auctionWinner(address _winner, address _nftAddress) external anyOperator {
    require(address(_winner) != address(0), "Winner cannot be 0x0");
    
    uint256 _userBalance = userETHBalance[_winner];
    userETHBalance[_winner] = 0;
    bankManager.transfer(_userBalance);
    winner = _winner;
    if(transferToken){
      require(address(_nftAddress) != address(0), "NFT Address cannot be 0x0");
      ERC721Token _nft = ERC721Token(_nftAddress);
      require(_nft.ownerOf(assetId) == address(this));
	  _nft.transferFrom(address(this), _winner, assetId);
    }
    emit SEAuctionETHWinner(_winner, _userBalance, assetId);
  }

  function auctionWinnerWithGFC(bytes32 winnerBytes32, uint256 gfcToETH) external anyOperator {
    require(gfcToETH > 0, "Winning GFC-ETH cannot be 0");
    winner = address(bankManager);
    emit SEAuctionGFCWinner(winnerBytes32, gfcToETH, assetId);
  }
  
  function refundETH(address payable [] calldata refundAddresses) external anyOperator{
    for(uint i=0;i< refundAddresses.length;i++){
        require(refundAddresses[i] != address(0));
        uint256 _userBalance = userETHBalance[refundAddresses[i]];
        userETHBalance[refundAddresses[i]] = 0;
        refundAddresses[i].transfer(_userBalance);
        emit SEAuctionRefund(refundAddresses[i], _userBalance);
    }
  }
  
  function getAuctionDetails() external view returns(address winnerAddress, uint256 startPrice, uint256 startingTime, 
    uint256 endingTime, uint256 auctionDuration, uint256 assetID, bytes32 dApp, address nftContractAddress){
    return (
        winner,
        startingPrice,
        startedAt, 
        startedAt.add(duration), 
        duration,
        assetId, 
        dAppName, 
        nftAddress
    );
  }
  
  function totalNumberOfBidders() external view returns(uint256){
      return allBidders.length;
  }
  
  function updateTransferBool(bool flag) external anyOperator {
      transferToken = flag;
  }
  
  function getMaxBidValue() external view returns(uint256){
      return maxBid;
  }
  
  function transferAssetFromContract(address to, address nftAddress, uint256 assetId) external anyOperator{
    require(nftAddress != address(0), "NFT Contract Cannot be 0x0");
    
    ERC721Token _nft = ERC721Token(nftAddress);
    
    _nft.transferFrom(address(this), to, assetId);
  }
  
  function withdrawBalance() public onlyBanker {
      bankManager.transfer(address(this).balance);
  }
}


contract SEAuctionMaster is OperationalControl {
  using SafeMath for uint256;
  using AddressUtils for address;
  
  
  event SEAuctionCreated(address newAuctionContract, uint256 assetId, uint256 startPrice, bytes32 indexed dAppName, uint256 startDate, uint256 endDate, uint256 seAuctionID);

  
  constructor () public {
    require (msg.sender != address(0));
    paused = true;
    error = false;
    managerPrimary = msg.sender;
    managerSecondary = msg.sender;
    bankManager = msg.sender;
    otherManagers[msg.sender] = 1;
  }
  
  struct Auction {
    uint256 auctionId;
    address payable contractAddress;
    uint256 assetId;
    address nftAddress;
    uint256 startPrice;
    uint256 startedAt;
    uint256 duration;
    bytes32 dAppName;
    uint256 winningPrice;
  }
  
  bool public canTransferOnAuction = false;
  Auction[] public auctions;
  
  function createAuction(uint256 assetId, address nftAddress, uint256 startPrice, uint256 duration, bytes32 dAppName) external onlyManager{
    require(nftAddress != address(0), "NFT Contract Cannot be 0x0");
    
    ERC721Token _nft = ERC721Token(nftAddress);
    require(duration != 0, "Duration cannot be zero");
    
    uint256 _currentTime = now;
    SEAuction _itemAuctionContract = new SEAuction(auctions.length, msg.sender, startPrice, _currentTime, duration, assetId, dAppName, nftAddress);
    
    address payable _contractAddress = address(_itemAuctionContract);
    
    Auction memory _itemAuction = Auction(
      auctions.length,
      _contractAddress,
      assetId,
      nftAddress,
      startPrice,
      _currentTime,
      duration,
      dAppName,
      0
    );

    auctions.push(_itemAuction);
    
    if(canTransferOnAuction){
        require(_nft.ownerOf(assetId) == address(this), "Auction Contract is not the owner");
        _nft.transferFrom(address(this), _contractAddress, assetId);
    }
    emit SEAuctionCreated(_contractAddress, assetId, startPrice, dAppName, _currentTime, _currentTime.add(duration), auctions.length - 1);
  }
  
  function refundFromAuction(address payable auctionContract, address payable [] calldata refundAddresses) external anyOperator {
    require(auctionContract != address(0));
    SEAuction _auctionContract = SEAuction(auctionContract);
    _auctionContract.refundETH(refundAddresses);
  }
  
  function getAuctionDetail(uint256 auctionID) external view returns(address winnerAddress, uint256 startPrice, uint256 startingTime, 
    uint256 endingTime, uint256 auctionDuration, uint256 assetId, bytes32 dApp, bytes32 auctionData, address nftContractAddress){
      Auction memory _auctionData = auctions[auctionID];
      SEAuction _auctionContract = SEAuction(_auctionData.contractAddress);
      _auctionContract.getAuctionDetails();
  }
  
  function updateAssetTransferForAuction(uint256 auctionID, bool flag) external {
      Auction memory _auctionData = auctions[auctionID];
      SEAuction _auctionContract = SEAuction(_auctionData.contractAddress);
      _auctionContract.updateTransferBool(flag);
  }
  
  function batchUpdateAssetTransferForAuction(uint256 [] calldata auctionIDs, bool flag) external {
      for(uint8 i=0;i<auctionIDs.length;i++){
        Auction memory _auctionData = auctions[auctionIDs[i]];
        SEAuction _auctionContract = SEAuction(_auctionData.contractAddress);
        _auctionContract.updateTransferBool(flag);
      }
  }
  
  function approveManager(uint256 auctionID, address approvedAddress) external anyOperator {
    Auction memory _auctionData = auctions[auctionID];
    ERC721Token _nft = ERC721Token(_auctionData.nftAddress);
    _nft.approve(approvedAddress, _auctionData.assetId);
  }
  
  function updateCanTransferOnAuction(bool flag) external anyOperator{
      canTransferOnAuction = flag;
  }
  
  function checkOwner(uint256 assetId, address nftAddress) external view returns (address){
    require(nftAddress != address(0), "NFT Contract Cannot be 0x0");
    
    ERC721Token _nft = ERC721Token(nftAddress);
    
    return _nft.ownerOf(assetId);
  }
  
  function transferStuckAsset(address to, address nftAddress, uint256 assetId) external anyOperator{
    require(nftAddress != address(0), "NFT Contract Cannot be 0x0");
    
    ERC721Token _nft = ERC721Token(nftAddress);
    
    _nft.transferFrom(address(this), to, assetId);
  }
    
  function withdrawBalance() public onlyBanker {
      bankManager.transfer(address(this).balance);
  }
}