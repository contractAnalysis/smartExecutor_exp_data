pragma solidity ^0.5.12;


library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract ReentrancyGuard {
    
    uint256 private _guardCounter;

    constructor () internal {
        
        
        _guardCounter = 1;
    }

    
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

contract minterests is Ownable, ReentrancyGuard {

  using SafeMath for uint256;

  
  struct Balance {
    
    uint256 previousBalance;
    
    uint256 currentBalance;
    
    uint256 previousHolding;
    
    uint256 currentHolding;
    
    uint256 refereeBalance;
  }

  
  struct Claiming {
    
    bool claiming;
    
    bytes32 currency;
    
    bytes32 partitionNameInHex;
  }

  
  struct Info {
    
    
    uint256 balanceInterests;
    
    Claiming claimingInterests;
    
    Claiming claimingBonds;
    
    Balance mid;
    
    Balance lng;
    
    Balance per;
  }
  
  mapping (address => Info) investors;

  
  
  
  mapping (address => bool) _isInterestsController;

  
  uint256 DECIMALS = 1000000000000000000;


  

  
  event Refered (
    address indexed referer,
    address indexed referee,
    uint256 midAmount,
    uint256 lngAmount,
    uint256 perAmount
  );

  
  
  event ModifiedReferee (
    address indexed investor,
    uint256 midAmount,
    uint256 lngAmount,
    uint256 perAmount
  );

  
  event UpdatedInterests (
    address indexed investor,
    uint256 interests
  );

  
  
  event ModifiedInterests (
    address indexed investor,
    uint256 value
  );

  
  event ModifiedInterestsController (
    address indexed controller,
    bool value
  );

  
  event ModifiedClaimingInterests (
    address indexed investor,
    bool claiming,
    bytes32 currency
  );

  
  
  event WillBePaidInterests (
    address indexed investor,
    uint256 balanceInterests
  );

  
  event ModifiedClaimingBonds (
    address indexed investor,
    bool claiming,
    bytes32 currency,
    bytes32 partitionNameInHex
  );

  
  
  event WillBePaidBonds (
    address indexed investor,
    bytes32 partitionNameInHex,
    uint256 claimedAmount
  );

  
  
  
  
  event ModifiedHoldings (
    address indexed investor,
    uint256 midHolding,
    uint256 lngHolding,
    uint256 perHolding
  );

  
  
  
  
  event ModifiedHoldingsAndBalanceError (
    address indexed investor,
    bytes32 partitionNameInHex,
    uint256 holding,
    uint256 balance
  );

  
  
  
  event ModifiedBalances (
    address indexed investor,
    uint256 midBalance,
    uint256 lngBalance,
    uint256 perBalance
  );


  

  
  function interestsOf (address investor) external view returns (uint256) {
    return (investors[investor].balanceInterests);
  }

  
  function isInterestsController (address _address) external view returns (bool) {
    return (_isInterestsController[_address]);
  }

  
  function isClaimingInterests (address investor) external view returns (bool, bytes32) {
    return (investors[investor].claimingInterests.claiming, investors[investor].claimingInterests.currency);
  }

  
  function isClaimingBonds (address investor) external view returns (bool, bytes32, bytes32) {
    return (
      investors[investor].claimingBonds.claiming,
      investors[investor].claimingBonds.currency,
      investors[investor].claimingBonds.partitionNameInHex
    );
  }

  
  function midtermBondInfosOf (address investor) external view returns (
    uint256,
    uint256,
    uint256
  ) {
    return (
      investors[investor].mid.currentBalance,
      investors[investor].mid.currentHolding,
      investors[investor].mid.refereeBalance
    );
  }

  
  function longtermBondInfosOf (address investor) external view returns (
    uint256,
    uint256,
    uint256
  ) {
    return (
      investors[investor].lng.currentBalance,
      investors[investor].lng.currentHolding,
      investors[investor].lng.refereeBalance
    );
  }

  
  function perpetualBondInfosOf (address investor) external view returns (
    uint256,
    uint256,
    uint256
  ) {
    return (
      investors[investor].per.currentBalance,
      investors[investor].per.currentHolding,
      investors[investor].per.refereeBalance
    );
  }



  

  
  function claimInterests (bool claiming, bytes32 _currency) external {
    bytes32 currency = _currency;
    require (currency == "eur" || currency == "eth", "A8"); 
    uint256 minimum = currency == "eth" ? 10 : 100; 

    require (investors[msg.sender].balanceInterests >= minimum.mul(DECIMALS), "A6"); 
    if (!claiming) {
      currency = "";
    }

    investors[msg.sender].claimingInterests.claiming = claiming;
    investors[msg.sender].claimingInterests.currency = currency;

    emit ModifiedClaimingInterests (msg.sender, claiming, currency);
  }

  /**
    * @dev This function updates interests balance for several investors, so that they can be paid by the third party.
    */
  function payInterests (address[] calldata investorsAddresses) external nonReentrant {
    require (_isInterestsController[msg.sender], "A5"); 

    for (uint i = 0; i < investorsAddresses.length; i++) {
      require (investors[investorsAddresses[i]].claimingInterests.claiming, "A6"); 

      investors[investorsAddresses[i]].claimingInterests.claiming = false;
      investors[investorsAddresses[i]].claimingInterests.currency = "";

      emit ModifiedClaimingInterests(investorsAddresses[i], false, "");
      emit WillBePaidInterests(investorsAddresses[i], investors[investorsAddresses[i]].balanceInterests);
      investors[investorsAddresses[i]].balanceInterests = 0;
      emit UpdatedInterests(investorsAddresses[i], investors[investorsAddresses[i]].balanceInterests);
    }
  }

  /**
    * @dev Allows an investor to claim one of its bonds.
    */
  function claimBond (bool claiming, bytes32 _currency, bytes32 partition) external {
    uint256 bondYear = 0;
    uint256 bondMonth = 0;
    bytes32 currency = _currency;

    require (currency == "eur" || currency == "eth", "A8"); 
    
    
    
    
    require ((partition[0] == "m" && partition[1] == "i" && partition[2] == "d")
              || (partition[0] == "l" && partition[1] == "n" && partition[2] == "g"), "A6");

    
    for (uint i = 4; i < 10; i++) {
      
      require ((uint8(partition[i]) >= 48) && (uint8(partition[i]) <= 57), "A6"); 
    }

    
    bondYear = bondYear.add(uint256(uint8(partition[4])).sub(48).mul(1000));
    
    bondYear = bondYear.add(uint256(uint8(partition[5])).sub(48).mul(100));
    
    bondYear = bondYear.add(uint256(uint8(partition[6])).sub(48).mul(10));
    
    bondYear = bondYear.add(uint256(uint8(partition[7])).sub(48));
    
    bondMonth = bondMonth.add(uint256(uint8(partition[8])).sub(48).mul(10));
    bondMonth = bondMonth.add(uint256(uint8(partition[9])).sub(48));

    
    require (bondYear >= 2000);
    require (bondMonth >= 0 && bondMonth <= 12);

    
    uint256 elapsedMonths = (bondYear * 12 + bondMonth) - 23640;
    uint256 currentTime;
    assembly {
      currentTime := timestamp()
    }

    
    uint256 currentMonth = currentTime / 2630016;
    uint256 deltaMonths = currentMonth - elapsedMonths;

    if (partition[0] == "m" && partition[1] == "i" && partition[2] == "d") {
      
      require (deltaMonths >= 60, "A6"); 
    } else if (partition[0] == "l" && partition[1] == "n" && partition[2] == "g") {
      
      require (deltaMonths >= 120, "A6"); 
    } else {
      
      assert (false);
    }

    investors[msg.sender].claimingBonds.claiming = claiming;
    investors[msg.sender].claimingBonds.currency = claiming ? currency : bytes32("");
    investors[msg.sender].claimingBonds.partitionNameInHex = claiming ? partition : bytes32("");

    emit ModifiedClaimingBonds(
      msg.sender,
      claiming,
      investors[msg.sender].claimingBonds.currency,
      investors[msg.sender].claimingBonds.partitionNameInHex
    );
  }

  /**
    * @dev This functions is called after the investor expressed its desire to redeem its bonds using the above
    *      function (claimBonds). It needs to be called __before__ the third party pays the investor its bonds
    *      in fiat.
    *
    * @param claimedAmount The balance of the investor on the redeemed partition.
    */
  function payBonds (address investor, uint256 claimedAmount) external nonReentrant {
    require (_isInterestsController[msg.sender], "A5"); 
    require (investors[investor].claimingBonds.claiming, "A6"); 
    investors[investor].claimingBonds.claiming = false;

    
    
    
    
    bytes32 partition = investors[investor].claimingBonds.partitionNameInHex;
    require ((partition[0] == "m" && partition[1] == "i" && partition[2] == "d")
              || (partition[0] == "l" && partition[1] == "n" && partition[2] == "g"), "A6");

    
    uint256 midLeft = 0;
    uint256 lngLeft = 0;
    bool emitHoldingEvent = false;
    if (partition[0] == "m" && partition[1] == "i" && partition[2] == "d") {
      
      if (claimedAmount < investors[investor].mid.currentBalance) {
        
        midLeft = investors[investor].mid.currentBalance.sub(claimedAmount);
      } else if (claimedAmount == investors[investor].mid.currentBalance) {
        
        
        
        
        
        
        
        
        investors[investor].mid.previousHolding = 0;
        investors[investor].mid.currentHolding = 0;
        emitHoldingEvent = true;
      } else {
        
        
        
        
        
        emit ModifiedHoldingsAndBalanceError(
          investor,
          investors[investor].claimingBonds.partitionNameInHex,
          investors[investor].mid.currentHolding,
          investors[investor].mid.currentBalance
        );
        investors[investor].mid.previousHolding = 0;
        investors[investor].mid.currentHolding = 0;
        emitHoldingEvent = true;
      }
      
      investors[investor].mid.previousBalance = midLeft;
      investors[investor].mid.currentBalance = midLeft;
    } else if (partition[0] == "l" && partition[1] == "n" && partition[2] == "g") {
      if (claimedAmount < investors[investor].lng.currentBalance) {
        
        lngLeft = investors[investor].lng.currentBalance.sub(claimedAmount);
      } else if (claimedAmount == investors[investor].lng.currentBalance) {
        
        investors[investor].lng.previousHolding = 0;
        investors[investor].lng.currentHolding = 0;
        emitHoldingEvent = true;
      } else {
        
        emit ModifiedHoldingsAndBalanceError(
          investor,
          investors[investor].claimingBonds.partitionNameInHex,
          investors[investor].lng.currentHolding,
          investors[investor].lng.currentBalance
        );
        investors[investor].lng.previousHolding = 0;
        investors[investor].lng.currentHolding = 0;
        emitHoldingEvent = true;
      }
      
      investors[investor].lng.previousBalance = lngLeft;
      investors[investor].lng.currentBalance = lngLeft;
    } else {
      
      assert (false);
    }

    emit WillBePaidBonds(
      investor,
      partition,
      claimedAmount
    );

    investors[investor].claimingBonds.currency = "";
    investors[investor].claimingBonds.partitionNameInHex = "";
    emit ModifiedClaimingBonds(
      investor,
      false,
      investors[investor].claimingBonds.currency,
      investors[investor].claimingBonds.partitionNameInHex
    );

    if (emitHoldingEvent) {
      emit ModifiedHoldings(
        investor,
        investors[investor].mid.currentHolding,
        investors[investor].lng.currentHolding,
        investors[investor].per.currentHolding
      );
    }

    emit ModifiedBalances(
      investor,
      investors[investor].mid.currentBalance,
      investors[investor].lng.currentBalance,
      investors[investor].per.currentBalance
    );

  }

  /**
    * @dev Set how much time an investor has been holding each bond.
    */
  function setHoldings (address investor, uint256 midHolding, uint256 lngHolding, uint256 perHolding) external onlyOwner {
    investors[investor].mid.previousHolding = midHolding;
    investors[investor].mid.currentHolding = midHolding;
    investors[investor].lng.previousHolding = lngHolding;
    investors[investor].lng.currentHolding = lngHolding;
    investors[investor].per.previousHolding = perHolding;
    investors[investor].per.currentHolding = perHolding;

    emit ModifiedHoldings(investor, midHolding, lngHolding, perHolding);
  }

  /**
    * @dev Set custom balances for an investor.
    */
  function setBalances (address investor, uint256 midBalance, uint256 lngBalance, uint256 perBalance) external onlyOwner {
    investors[investor].mid.previousBalance = midBalance;
    investors[investor].mid.currentBalance = midBalance;
    investors[investor].lng.previousBalance = lngBalance;
    investors[investor].lng.currentBalance = lngBalance;
    investors[investor].per.previousBalance = perBalance;
    investors[investor].per.currentBalance = perBalance;

    emit ModifiedBalances(investor, midBalance, lngBalance, perBalance);
  }

  /**
    * @dev Set the interests balance of an investor.
    */
  function setInterests (address investor, uint256 value) external onlyOwner {
    investors[investor].balanceInterests = value;

    emit ModifiedInterests(investor, value);
    emit UpdatedInterests(investor, investors[investor].balanceInterests);
  }

  /**
    * @dev Add or remove an address from the InterestsController mapping.
    */
  function setInterestsController (address controller, bool value) external onlyOwner {
    _isInterestsController[controller] = value;

    emit ModifiedInterestsController(controller, value);
  }

  /**
    * @dev Increases the referer interests balance of a given amount.
    *
    * @param referer The address of the referal initiator
    * @param referee The address of the referal consumer
    * @param percent The percentage of interests earned by the referer
    * @param midAmount How many mid term bonds the referee bought through this referal
    * @param lngAmount How many long term bonds the referee bought through this referal
    * @param perAmount How many perpetual tokens the referee bought through this referal
    */
  function updateReferralInfos (
    address referer,
    address referee,
    uint256 percent,
    uint256 midAmount,
    uint256 lngAmount,
    uint256 perAmount
  ) external onlyOwner {
    // Referee and/or referer address(es) is(/are) not valid.
    require (referer != referee && referer != address(0) && referee != address(0), "A7");
    
    require (percent >= 1 && percent <= 100, "A8");

    
    investors[referer].balanceInterests = investors[referer].balanceInterests.add(midAmount.mul(percent).div(100));
    investors[referer].balanceInterests = investors[referer].balanceInterests.add(lngAmount.mul(percent).div(100));
    investors[referer].balanceInterests = investors[referer].balanceInterests.add(perAmount.mul(percent).div(100));
    emit UpdatedInterests(referer, investors[referer].balanceInterests);

    investors[referee].mid.refereeBalance = investors[referee].mid.refereeBalance.add(midAmount);
    investors[referee].lng.refereeBalance = investors[referee].lng.refereeBalance.add(lngAmount);
    investors[referee].per.refereeBalance = investors[referee].per.refereeBalance.add(perAmount);
    emit ModifiedReferee(
      referee,
      investors[referee].mid.refereeBalance,
      investors[referee].lng.refereeBalance,
      investors[referee].per.refereeBalance
    );
    emit Refered(referer, referee, midAmount, lngAmount, perAmount);
  }

  
  function setRefereeAmount (
    address investor,
    uint256 midAmount,
    uint256 lngAmount,
    uint256 perAmount
  ) external onlyOwner {
    investors[investor].mid.refereeBalance = midAmount;
    investors[investor].lng.refereeBalance = lngAmount;
    investors[investor].per.refereeBalance = perAmount;
    emit ModifiedReferee(investor, midAmount, lngAmount, perAmount);
  }

  
  function updateInterests (address investor, uint256 midBalance, uint256 lngBalance, uint256 perBalance) external onlyOwner {
    
    investors[investor].mid.currentBalance = midBalance;
    investors[investor].lng.currentBalance = lngBalance;
    investors[investor].per.currentBalance = perBalance;

    
    bool adjustedReferee = false;
    if (investors[investor].mid.refereeBalance > investors[investor].mid.currentBalance) {
      investors[investor].mid.refereeBalance = investors[investor].mid.currentBalance;
      adjustedReferee = true;
    }
    if (investors[investor].lng.refereeBalance > investors[investor].lng.currentBalance) {
      investors[investor].lng.refereeBalance = investors[investor].lng.currentBalance;
      adjustedReferee = true;
    }
    if (investors[investor].per.refereeBalance > investors[investor].per.currentBalance) {
      investors[investor].per.refereeBalance = investors[investor].per.currentBalance;
      adjustedReferee = true;
    }
    if (adjustedReferee) {
      emit ModifiedReferee(
        investor,
        investors[investor].mid.refereeBalance,
        investors[investor].lng.refereeBalance,
        investors[investor].per.refereeBalance
      );
    }

    
    
    
    if (investors[investor].mid.currentBalance > 0) {
        investors[investor].mid.currentHolding = investors[investor].mid.currentHolding.add(DECIMALS);
    }
    if (investors[investor].lng.currentBalance > 0) {
        if (investors[investor].lng.currentBalance > investors[investor].lng.previousBalance
            && investors[investor].lng.previousBalance > 0) {
            uint256 adjustmentRate = (((investors[investor].lng.currentBalance
                                        .sub(investors[investor].lng.previousBalance))
                                        .mul(DECIMALS))
                                        .div(investors[investor].lng.currentBalance));
            investors[investor].lng.currentHolding = (((DECIMALS
                                                        .sub(adjustmentRate))
                                                        .mul(investors[investor].lng.previousHolding
                                                             .add(DECIMALS)))
                                                        .div(DECIMALS));
        }
        else {
            investors[investor].lng.currentHolding = investors[investor].lng.currentHolding.add(DECIMALS);
        }
    }
    if (investors[investor].per.currentBalance > 0) {
        if (investors[investor].per.currentBalance > investors[investor].per.previousBalance
            && investors[investor].per.previousBalance > 0) {
            uint256 adjustmentRate = (((investors[investor].per.currentBalance
                                        .sub(investors[investor].per.previousBalance))
                                        .mul(DECIMALS))
                                        .div(investors[investor].per.currentBalance));
            investors[investor].per.currentHolding = (((DECIMALS.sub(adjustmentRate))
                                                        .mul(investors[investor].per.previousHolding
                                                             .add(DECIMALS)))
                                                        .div(DECIMALS));
        }
        else {
            investors[investor].per.currentHolding = investors[investor].per.currentHolding.add(DECIMALS);
        }
    }

    

    _minterest(investor);

    
    investors[investor].mid.previousHolding = investors[investor].mid.currentHolding;
    investors[investor].lng.previousHolding = investors[investor].lng.currentHolding;
    investors[investor].per.previousHolding = investors[investor].per.currentHolding;

    
    investors[investor].mid.previousBalance = investors[investor].mid.currentBalance;
    investors[investor].lng.previousBalance = investors[investor].lng.currentBalance;
    investors[investor].per.previousBalance = investors[investor].per.currentBalance;

    emit ModifiedBalances(
      investor,
      investors[investor].mid.currentBalance,
      investors[investor].lng.currentBalance,
      investors[investor].per.currentBalance
    );

    
    if (investors[investor].per.currentBalance == 0) {
      investors[investor].per.previousHolding = 0;
      investors[investor].per.currentHolding = 0;
    }
    if (investors[investor].mid.currentBalance == 0) {
      investors[investor].mid.previousHolding = 0;
      investors[investor].mid.currentHolding = 0;
    }
    if (investors[investor].lng.currentBalance == 0) {
      investors[investor].lng.previousHolding = 0;
      investors[investor].lng.currentHolding = 0;
    }

    emit ModifiedHoldings(
      investor,
      investors[investor].mid.currentHolding,
      investors[investor].lng.currentHolding,
      investors[investor].per.currentHolding
    );

    emit UpdatedInterests(investor, investors[investor].balanceInterests);
  }



  

  
  function _minterest (address investor) internal {
    
    uint256 rateFactor = 10000; 

    
    uint256 bonusFactor = 100;

    
    uint256 midRate = 575;

    
    uint256 lngRate = 0;
    if (investors[investor].lng.currentBalance > 0) {
      if (investors[investor].lng.currentHolding < DECIMALS.mul(12)) {
        if (investors[investor].lng.currentBalance < DECIMALS.mul(800)) {
          lngRate = 700;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(2400)) {
          lngRate = 730;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(7200)) {
          lngRate = 749;
        }
        else {
          lngRate = 760;
        }
      }
      else if (investors[investor].lng.currentHolding < DECIMALS.mul(36)) {
        if (investors[investor].lng.currentBalance < DECIMALS.mul(800)) {
          lngRate = 730;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(2400)) {
          lngRate = 745;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(7200)) {
          lngRate = 756;
        }
        else {
          lngRate = 764;
        }
      }
      else if (investors[investor].lng.currentHolding < DECIMALS.mul(72)) {
        if (investors[investor].lng.currentBalance < DECIMALS.mul(800)) {
          lngRate = 749;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(2400)) {
          lngRate = 757;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(7200)) {
          lngRate = 763;
        }
        else {
          lngRate = 767;
        }
      }
      else if (investors[investor].lng.currentHolding >= DECIMALS.mul(72)) {
        if (investors[investor].lng.currentBalance < DECIMALS.mul(800)) {
          lngRate = 760;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(2400)) {
          lngRate = 764;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(7200)) {
          lngRate = 767;
        }
        else if (investors[investor].lng.currentBalance >= DECIMALS.mul(7200)) {
          lngRate = 770;
        }
      }
      assert (lngRate != 0);
    }

    
    uint256 perRate = 0;
    if (investors[investor].per.currentBalance > 0) {
      if (investors[investor].per.currentHolding < DECIMALS.mul(12)) {
        if (investors[investor].per.currentBalance < DECIMALS.mul(800)) {
          perRate = 850;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(2400)) {
          perRate = 888;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(7200)) {
          perRate = 911;
        }
        else if (investors[investor].per.currentBalance >= DECIMALS.mul(7200)) {
          perRate = 925;
        }
      }
      else if (investors[investor].per.currentHolding < DECIMALS.mul(36)) {
        if (investors[investor].per.currentBalance < DECIMALS.mul(800)) {
          perRate = 888;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(2400)) {
          perRate = 906;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(7200)) {
          perRate = 919;
        }
        else if (investors[investor].per.currentBalance >= DECIMALS.mul(7200)) {
          perRate = 930;
        }
      }
      else if (investors[investor].per.currentHolding < DECIMALS.mul(72)) {
        if (investors[investor].per.currentBalance < DECIMALS.mul(800)) {
          perRate = 911;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(2400)) {
          perRate = 919;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(7200)) {
          perRate = 927;
        }
        else if (investors[investor].per.currentBalance >= DECIMALS.mul(7200)) {
          perRate = 934;
        }
      }
      else if (investors[investor].per.currentHolding >= DECIMALS.mul(72)) {
        if (investors[investor].per.currentBalance < DECIMALS.mul(800)) {
          perRate = 925;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(2400)) {
          perRate = 930;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(7200)) {
          perRate = 934;
        }
        else if (investors[investor].per.currentBalance >= DECIMALS.mul(7200)) {
          perRate = 937;
        }
      }
      assert (perRate != 0);
    }

    
    
    
    
    

    
    if (investors[investor].mid.refereeBalance > 0) {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((midRate.mul(105) 
        .mul(investors[investor].mid.refereeBalance))
        .div(12))
        .div(rateFactor)
        .div(bonusFactor)
      );
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((midRate
        .mul(investors[investor].mid.currentBalance.sub(investors[investor].mid.refereeBalance)))
        .div(12))
        .div(rateFactor)
      );
    } else {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((midRate
        .mul(investors[investor].mid.currentBalance))
        .div(12))
        .div(rateFactor)
      );
    }
    
    if (investors[investor].lng.refereeBalance > 0) {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((lngRate.mul(105) 
        .mul(investors[investor].lng.refereeBalance))
        .div(12))
        .div(rateFactor)
        .div(bonusFactor)
      );
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((lngRate.mul(investors[investor].lng.currentBalance.sub(investors[investor].lng.refereeBalance)))
        .div(12))
        .div(rateFactor)
      );
    } else {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((lngRate.mul(investors[investor].lng.currentBalance))
        .div(12))
        .div(rateFactor)
      );
    }
    
    if (investors[investor].per.refereeBalance > 0) {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((perRate.mul(105) 
        .mul(investors[investor].per.refereeBalance))
        .div(12))
        .div(rateFactor)
        .div(bonusFactor)
      );
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((perRate.mul(investors[investor].per.currentBalance.sub(investors[investor].per.refereeBalance)))
        .div(12))
        .div(rateFactor)
      );
    } else {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((perRate.mul(investors[investor].per.currentBalance))
        .div(12))
        .div(rateFactor)
      );
    }
  }
}