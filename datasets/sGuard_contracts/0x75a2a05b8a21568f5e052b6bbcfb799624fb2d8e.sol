pragma solidity ^0.4.26;







contract ERC20 {
  uint public totalSupply;

  event Transfer(address indexed from, address indexed to, uint value);  
  event Approval(address indexed owner, address indexed spender, uint value);

  function balanceOf(address who) public constant returns (uint);
  function allowance(address owner, address spender) public constant returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);  
}

contract FiatDex_protocol_v2 {

  address public owner; 
  address public daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F; 
  uint256 public version = 2; 

  constructor() public {
    owner = msg.sender; 
  }

  enum States {
    NOTOPEN, 
    INITIALIZED, 
    REFUNDED, 
    ACTIVE, 
    CLOSED, 
    FIATABORT, 
    DAIABORT 
  }

  struct Swap {
    States swapState;
    uint256 sendAmount;
    address fiatTrader;
    address daiTrader;
    uint256 openTime;
    uint256 daiTraderCollateral;
    uint256 fiatTraderCollateral;
    uint256 feeAmount;
  }

  mapping (bytes32 => Swap) private swaps; 

  event Open(bytes32 _tradeID, address _fiatTrader, uint256 _sendAmount); 
  event Close(bytes32 _tradeID, uint256 _fee);
  event Canceled(bytes32 _tradeID, uint256 _fee);
  event ChangedOwnership(address _newOwner);

  
  modifier onlyNotOpenSwaps(bytes32 _tradeID) {
    require (swaps[_tradeID].swapState == States.NOTOPEN);
    _;
  }

  
  modifier onlyInitializedSwaps(bytes32 _tradeID) {
    require (swaps[_tradeID].swapState == States.INITIALIZED);
    _;
  }

  
  modifier onlyActiveSwaps(bytes32 _tradeID) {
    require (swaps[_tradeID].swapState == States.ACTIVE);
    _;
  }

  
  function viewSwap(bytes32 _tradeID) public view returns (
    States swapState, 
    uint256 sendAmount,
    address daiTrader, 
    address fiatTrader, 
    uint256 openTime, 
    uint256 daiTraderCollateral, 
    uint256 fiatTraderCollateral,
    uint256 feeAmount
  ) {
    Swap memory swap = swaps[_tradeID];
    return (swap.swapState, swap.sendAmount, swap.daiTrader, swap.fiatTrader, swap.openTime, swap.daiTraderCollateral, swap.fiatTraderCollateral, swap.feeAmount);
  }

  function viewFiatDexSpecs() public view returns (
    uint256 _version, 
    address _owner
  ) {
    return (version, owner);
  }

  
  function changeContractOwner(address _newOwner) public {
    require (msg.sender == owner); 
    
    owner = _newOwner; 

     
    emit ChangedOwnership(_newOwner);
  }

  
  function openSwap(bytes32 _tradeID, address _fiatTrader, uint256 _erc20Value) public onlyNotOpenSwaps(_tradeID) {
    ERC20 daiContract = ERC20(daiAddress); 
    require (_erc20Value > 0); 
    require(_erc20Value <= daiContract.allowance(msg.sender, address(this))); 

    
    uint256 _sendAmount = (_erc20Value * 2) / 5; 
    require (_sendAmount > 0); 
    uint256 _daiTraderCollateral = _erc20Value - _sendAmount; 

    
    Swap memory swap = Swap({
      swapState: States.INITIALIZED,
      sendAmount: _sendAmount,
      daiTrader: msg.sender,
      fiatTrader: _fiatTrader,
      openTime: now,
      daiTraderCollateral: _daiTraderCollateral,
      fiatTraderCollateral: 0,
      feeAmount: 0
    });
    swaps[_tradeID] = swap;

    
    require(daiContract.transferFrom(msg.sender, address(this), _erc20Value)); 

    
    emit Open(_tradeID, _fiatTrader, _sendAmount);
  }

  
  function addFiatTraderCollateral(bytes32 _tradeID, uint256 _erc20Value) public onlyInitializedSwaps(_tradeID) {
    Swap storage swap = swaps[_tradeID]; 
    require (_erc20Value >= swap.daiTraderCollateral); 
    require (msg.sender == swap.fiatTrader); 
    
    ERC20 daiContract = ERC20(daiAddress); 
    require(_erc20Value <= daiContract.allowance(msg.sender, address(this))); 
    swap.fiatTraderCollateral = _erc20Value;
    swap.swapState = States.ACTIVE; 

    
    require(daiContract.transferFrom(msg.sender, address(this), _erc20Value)); 
  }

  
  function refundSwap(bytes32 _tradeID) public onlyInitializedSwaps(_tradeID) {
    
    Swap storage swap = swaps[_tradeID];
    require (msg.sender == swap.daiTrader); 
    swap.swapState = States.REFUNDED; 

    
    ERC20 daiContract = ERC20(daiAddress); 
    require(daiContract.transfer(swap.daiTrader, swap.sendAmount + swap.daiTraderCollateral));

     
    emit Canceled(_tradeID, 0);
  }

  
  
  
  function diaTraderAbort(bytes32 _tradeID, uint256 penaltyPercent) public onlyActiveSwaps(_tradeID) {
    
    require (penaltyPercent >= 75000 && penaltyPercent <= 100000); 

    Swap storage swap = swaps[_tradeID];
    require (msg.sender == swap.daiTrader); 
    swap.swapState = States.DAIABORT; 

    
    uint256 penaltyAmount = (swap.daiTraderCollateral * penaltyPercent) / 100000;
    ERC20 daiContract = ERC20(daiAddress); 
    if(penaltyAmount > 0){
      swap.feeAmount = penaltyAmount;
      require(daiContract.transfer(owner, penaltyAmount * 2));
    }   

    
    require(daiContract.transfer(swap.daiTrader, swap.sendAmount + swap.daiTraderCollateral - penaltyAmount));
  
    
    require(daiContract.transfer(swap.fiatTrader, swap.fiatTraderCollateral - penaltyAmount));

     
    emit Canceled(_tradeID, penaltyAmount);
  }

  
  
  
  function fiatTraderAbort(bytes32 _tradeID, uint256 penaltyPercent) public onlyActiveSwaps(_tradeID) {
    
    require (penaltyPercent >= 2500 && penaltyPercent <= 100000); 

    Swap storage swap = swaps[_tradeID];
    require (msg.sender == swap.fiatTrader); 
    swap.swapState = States.FIATABORT; 

    
    uint256 penaltyAmount = (swap.daiTraderCollateral * penaltyPercent) / 100000;
    ERC20 daiContract = ERC20(daiAddress); 
    if(penaltyAmount > 0){
      swap.feeAmount = penaltyAmount;
      require(daiContract.transfer(owner, penaltyAmount * 2));
    }   

    
    require(daiContract.transfer(swap.daiTrader, swap.sendAmount + swap.daiTraderCollateral - penaltyAmount));
  
    
    require(daiContract.transfer(swap.fiatTrader, swap.fiatTraderCollateral - penaltyAmount));

     
    emit Canceled(_tradeID, penaltyAmount);
  }

  
  function finalizeSwap(bytes32 _tradeID) public onlyActiveSwaps(_tradeID) {
    
    Swap storage swap = swaps[_tradeID];
    require (msg.sender == swap.daiTrader); 
    swap.swapState = States.CLOSED; 

    
    uint256 feeAmount = 0; 
    uint256 feePercent = 1000; 
    feeAmount = (swap.sendAmount * feePercent) / 100000;

    
    ERC20 daiContract = ERC20(daiAddress); 
    if(feeAmount > 0){
      swap.feeAmount = feeAmount;
      require(daiContract.transfer(owner, swap.feeAmount));
    }

    
    require(daiContract.transfer(swap.daiTrader, swap.daiTraderCollateral));

    
    require(daiContract.transfer(swap.fiatTrader, swap.sendAmount - feeAmount + swap.fiatTraderCollateral));

     
    emit Close(_tradeID, feeAmount);
  }
}