pragma solidity 0.5.16; 


interface IDaiBackstopSyndicate {
  event AuctionEntered(uint256 auctionId, uint256 mkrAsk, uint256 daiBid);
  event AuctionFinalized(uint256 auctionId);

  enum Status {
    ACCEPTING_DEPOSITS,
    ACTIVATED,
    DEACTIVATED
  }

  
  function enlist(uint256 daiAmount) external returns (uint256 backstopTokensMinted);

  
  function defect(uint256 backstopTokenAmount) external returns (uint256 daiRedeemed, uint256 mkrRedeemed);

  
  function enterAuction(uint256 auctionId) external;

  
  function finalizeAuction(uint256 auctionId) external;

  
  function ceaseFire() external;
  
  
  function getDaiBalance() external view returns (uint256 combinedDaiInVat);

  
  function getDaiBalanceForAuctions() external view returns (uint256 daiInVatForAuctions);

  
  function getAvailableDaiBalance() external view returns (uint256 daiInVat);

  
  function getMKRBalance() external view returns (uint256 mkr);

  
  function getDefectAmount(
    uint256 backstopTokenAmount
  ) external view returns (
    uint256 daiRedeemed, uint256 mkrRedeemed, bool redeemable
  );

  
  function getStatus() external view returns (Status status);

  
  function getActiveAuctions() external view returns (uint256[] memory activeAuctions);
}


interface IJoin {
    function join(address, uint256) external;
    function exit(address, uint256) external;
}


interface IVat {
    function dai(address) external view returns (uint256);
    function hope(address) external;
    function move(address, address, uint256) external;
}


interface IFlopper {
    
    
    function wards(address) external view returns (uint256);
    
    function rely(address usr) external;
    
    function deny(address usr) external;

    
    function bids(uint256) external view returns (
        uint256 bid,
        uint256 lot,
        address guy,
        uint48 tic,
        uint48 end
    );

    
    function vat() external view returns (address);
    
    function gem() external view returns (address);

    
    function ONE() external pure returns (uint256);

    
    function beg() external view returns (uint256);
    
    function pad() external view returns (uint256);
    
    function ttl() external view returns (uint48);
    
    function tau() external view returns (uint48);

    
    function kicks() external view returns (uint256);
    
    function live() external view returns (uint256);
    
    function vow() external view returns (address);

    
    event Kick(uint256 id, uint256 lot, uint256 bid, address indexed gal);

    
    function file(bytes32 what, uint256 data) external;

    

    
    
    
    
    
    
    
    function kick(address gal, uint256 lot, uint256 bid) external returns (uint256 id);

    
    
    
    
    function tick(uint256 id) external;

    
    
    
    
    
    
    function dent(uint256 id, uint256 lot, uint256 bid) external;

    
    
    
    
    function deal(uint256 id) external;

    

    
    
    
    function cage() external;

    
    
    
    function yank(uint256 id) external;
}



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



contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


contract SimpleFlopper {

  
  IFlopper internal constant _auction = IFlopper(
    0x4D95A049d5B0b7d32058cd3F2163015747522e99
  );

  

  
  
  function isEnabled() public view returns (bool status) {
    return (_auction.live() == 1) ? true : false;
  }

  
  
  function getTotalNumberOfAuctions() public view returns (uint256 auctionID) {
    return _auction.kicks();
  }

  
  
  function getFlopperAddress() public pure returns (address flopper) {
    return address(_auction);
  }

  
  
  
  
  
  function getAuctionInformation() public view returns (
    uint256 bidIncrement,
    uint256 repriceIncrement,
    uint256 bidDuration,
    uint256 auctionDuration
  ) {
    return (_auction.beg(), _auction.pad(), _auction.ttl(), _auction.tau());
  }

  
  
  
  
  
  
  function getCurrentBid(uint256 auctionID) public view returns (
    uint256 amountDAI,
    uint256 amountMKR,
    address bidder,
    uint48 bidDeadline,
    uint48 auctionDeadline
  ) {
    return _auction.bids(auctionID);
  }

  

  
  
  
  function _reprice(uint256 auctionID) internal {
    _auction.tick(auctionID);
  }

  
  
  
  function _bid(uint256 auctionID, uint256 amountMKR, uint256 amountDAI) internal {
    _auction.dent(auctionID, amountMKR, amountDAI);
  }

  
  
  
  function _finalize(uint256 auctionID) internal {
    _auction.deal(auctionID);
  }
}



contract TwoStepOwnable {
  address private _owner;

  address private _newPotentialOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  
  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }

  
  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    require(
      newOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  
  function cancelOwnershipTransfer() public onlyOwner {
    delete _newPotentialOwner;
  }

  
  function acceptOwnership() public {
    require(
      msg.sender == _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }
}



library EnumerableSet {

  struct AuctionIDSet {
    
    
    mapping (uint256 => uint256) index;
    uint256[] values;
  }

  
  function add(AuctionIDSet storage set, uint256 value)
    internal
    returns (bool)
  {
    if (!contains(set, value)) {
      set.values.push(value);
      
      
      set.index[value] = set.values.length;
      return true;
    } else {
      return false;
    }
  }

  
  function remove(AuctionIDSet storage set, uint256 value)
    internal
    returns (bool)
  {
    if (contains(set, value)){
      uint256 toDeleteIndex = set.index[value] - 1;
      uint256 lastIndex = set.values.length - 1;

      
      if (lastIndex != toDeleteIndex) {
        uint256 lastValue = set.values[lastIndex];

        
        set.values[toDeleteIndex] = lastValue;
        
        set.index[lastValue] = toDeleteIndex + 1; 
      }

      
      delete set.index[value];

      
      set.values.pop();

      return true;
    } else {
      return false;
    }
  }

  
  function contains(AuctionIDSet storage set, uint256 value)
    internal
    view
    returns (bool)
  {
    return set.index[value] != 0;
  }

  
  function enumerate(AuctionIDSet storage set)
    internal
    view
    returns (uint256[] memory)
  {
    uint256[] memory output = new uint256[](set.values.length);
    for (uint256 i; i < set.values.length; i++){
      output[i] = set.values[i];
    }
    return output;
  }

  
  function length(AuctionIDSet storage set)
    internal
    view
    returns (uint256)
  {
    return set.values.length;
  }

   
  function get(AuctionIDSet storage set, uint256 index)
    internal
    view
    returns (uint256)
  {
    return set.values[index];
  }
}



contract DaiBackstopSyndicateV3 is
  IDaiBackstopSyndicate,
  SimpleFlopper,
  TwoStepOwnable,
  ERC20
{
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AuctionIDSet;

  
  Status internal _status;

  
  EnumerableSet.AuctionIDSet internal _activeAuctions;

  IERC20 internal constant _DAI = IERC20(
    0x6B175474E89094C44Da98b954EedeAC495271d0F
  );

  IERC20 internal constant _MKR = IERC20(
    0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2
  );

  IJoin internal constant _DAI_JOIN = IJoin(
    0x9759A6Ac90977b93B58547b4A71c78317f391A28
  );

  IVat internal constant _VAT = IVat(
    0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B
  );

  constructor() public {
    
    _status = Status.ACCEPTING_DEPOSITS;
 
    
    _VAT.hope(address(_DAI_JOIN));

    
    _DAI.approve(address(_DAI_JOIN), uint256(-1));

    
    _VAT.hope(SimpleFlopper.getFlopperAddress());
  }

  
  
  
  function enlist(
    uint256 daiAmount
  ) external notWhenDeactivated returns (uint256 backstopTokensMinted) {
    require(daiAmount > 0, "DaiBackstopSyndicate/enlist: No Dai amount supplied.");  
      
    require(
      _status == Status.ACCEPTING_DEPOSITS,
      "DaiBackstopSyndicate/enlist: Cannot deposit once the first auction bid has been made."
    );

    require(
      _DAI.transferFrom(msg.sender, address(this), daiAmount),
      "DaiBackstopSyndicate/enlist: Could not transfer Dai amount from caller."
    );

    
    _DAI_JOIN.join(address(this), daiAmount);

    
    backstopTokensMinted = daiAmount;
    _mint(msg.sender, backstopTokensMinted);
  }

  
  
  
  
  function defect(
    uint256 backstopTokenAmount
  ) external returns (uint256 daiRedeemed, uint256 mkrRedeemed) {
    require(
      backstopTokenAmount > 0, "DaiBackstopSyndicate/defect: No token amount supplied."
    );
      
    
    uint256 shareFloat = (backstopTokenAmount.mul(1e18)).div(totalSupply());

    
    _burn(msg.sender, backstopTokenAmount);

    
    uint256 vatDaiLockedInAuctions = _getActiveAuctionVatDaiTotal();

    
    uint256 vatDaiBalance = _VAT.dai(address(this));

    
    uint256 combinedVatDai = vatDaiLockedInAuctions.add(vatDaiBalance);

    
    uint256 makerBalance = _MKR.balanceOf(address(this));

    
    uint256 vatDaiRedeemed = combinedVatDai.mul(shareFloat) / 1e18;
    mkrRedeemed = makerBalance.mul(shareFloat) / 1e18;

    
    
    daiRedeemed = vatDaiRedeemed / 1e27;

    
    require(
      mkrRedeemed != 0 || daiRedeemed != 0,
      "DaiBackstopSyndicate/defect: Nothing returned after burning tokens."
    );

    
    require(
      vatDaiRedeemed <= vatDaiBalance,
      "DaiBackstopSyndicate/defect: Insufficient Dai (in use in auctions)"
    );

    
    if (vatDaiRedeemed > 0) {
      if (SimpleFlopper.isEnabled()) {
        _DAI_JOIN.exit(msg.sender, daiRedeemed);
      } else {
        _VAT.move(address(this), msg.sender, vatDaiRedeemed);
      }
    }

    if (mkrRedeemed > 0) {
      require(
        _MKR.transfer(msg.sender, mkrRedeemed),
        "DaiBackstopSyndicate/defect: MKR redemption failed."
      );      
    }
  }

  
  
  function enterAuction(uint256 auctionId) external notWhenDeactivated {
    require(
      !_activeAuctions.contains(auctionId),
      "DaiBackstopSyndicate/enterAuction: Auction already active."
    );

    
    (uint256 amountDai, , , , ) = SimpleFlopper.getCurrentBid(auctionId);

    
    uint256 expectedLot = (amountDai / 1e27) / 100;

    
    SimpleFlopper._bid(auctionId, expectedLot, amountDai);

    
    if (_status != Status.ACTIVATED) {
      _status = Status.ACTIVATED;
    }

    
    _activeAuctions.add(auctionId);

    
    emit AuctionEntered(auctionId, expectedLot, amountDai);
  }

  
  function finalizeAuction(uint256 auctionId) external {
    require(
      _activeAuctions.contains(auctionId),
      "DaiBackstopSyndicate/finalizeAuction: Auction already finalized"
    );

    
    (,, address bidder,, uint48 end) = SimpleFlopper.getCurrentBid(auctionId);

    
    if (end != 0) {
      
      
      if (bidder == address(this)) {
        SimpleFlopper._finalize(auctionId);
      }
    }

    
    _activeAuctions.remove(auctionId);

    
    emit AuctionFinalized(auctionId);
  }

  
  
  function ceaseFire() external onlyOwner {
    _status = Status.DEACTIVATED;
  }

  function getStatus() external view returns (Status status) {
    status = _status;
  }

  function getActiveAuctions() external view returns (
    uint256[] memory activeAuctions
  ) {
    activeAuctions = _activeAuctions.enumerate();
  }

  
  function name() external view returns (string memory) {
    return "Dai Backstop Syndicate v3-100";
  }

  
  function symbol() external view returns (string memory) {
    return "DBSv3-100";
  }

  
  function decimals() external view returns (uint8) {
    return 18;
  }

  
  function getDaiBalance() external view returns (uint256 combinedDaiInVat) {
    
    uint256 vatDaiLockedInAuctions = _getActiveAuctionVatDaiTotal();

    
    uint256 vatDaiBalance = _VAT.dai(address(this));

    
    combinedDaiInVat = vatDaiLockedInAuctions.add(vatDaiBalance) / 1e27;
  }

  
  function getDaiBalanceForAuctions() external view returns (uint256 daiInVatForAuctions) {
    
    daiInVatForAuctions = _getActiveAuctionVatDaiTotal() / 1e27;
  }

  
  function getAvailableDaiBalance() external view returns (uint256 daiInVat) {
    
    daiInVat = _VAT.dai(address(this)) / 1e27;
  }

  
  function getMKRBalance() external view returns (uint256 mkr) {
    
    mkr = _MKR.balanceOf(address(this));
  }

  
  
  
  
  
  function getDefectAmount(
    uint256 backstopTokenAmount
  ) external view returns (
    uint256 daiRedeemed, uint256 mkrRedeemed, bool redeemable
  ) {
    if (backstopTokenAmount == 0) {
      return (0, 0, false);
    }

    if (backstopTokenAmount > totalSupply()) {
      revert("Supplied token amount is greater than total supply.");
    }

    
    uint256 shareFloat = (backstopTokenAmount.mul(1e18)).div(totalSupply());

    
    uint256 vatDaiLockedInAuctions = _getActiveAuctionVatDaiTotal();

    
    uint256 vatDaiBalance = _VAT.dai(address(this));

    
    uint256 combinedVatDai = vatDaiLockedInAuctions.add(vatDaiBalance);

    
    uint256 makerBalance = _MKR.balanceOf(address(this));

    
    uint256 vatDaiRedeemed = combinedVatDai.mul(shareFloat) / 1e18;
    mkrRedeemed = makerBalance.mul(shareFloat) / 1e18;

    
    
    daiRedeemed = vatDaiRedeemed / 1e27;

    
    redeemable = (vatDaiRedeemed <= vatDaiBalance);
  }

  function _getActiveAuctionVatDaiTotal() internal view returns (uint256 vatDai) {
    vatDai = 0;
    uint256[] memory activeAuctions = _activeAuctions.enumerate();

    uint256 auctionVatDai;
    address bidder;
    for (uint256 i = 0; i < activeAuctions.length; i++) {
      
      (auctionVatDai,, bidder,,) = SimpleFlopper.getCurrentBid(activeAuctions[i]);
      if (bidder == address(this)) {
        
        vatDai = vatDai.add(auctionVatDai);
      }
    }
  }

  modifier notWhenDeactivated() {
    require(
      _status != Status.DEACTIVATED,
      "DaiBackstopSyndicate/notWhenDeactivated: Syndicate is deactivated, please withdraw."
    );
    _;
  }
}