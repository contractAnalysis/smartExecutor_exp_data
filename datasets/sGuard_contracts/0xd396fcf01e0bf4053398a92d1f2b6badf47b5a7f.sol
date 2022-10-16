pragma solidity ^0.5.15;

interface ERC20 {
  function totalSupply()  external view returns (uint supply);
  function balanceOf(address _owner)  external view returns (uint balance);
  function transfer(address _to, uint _value)  external returns (bool success);
  function transferFrom(address _from, address _to, uint _value)  external returns (bool success);
  function approve(address _spender, uint _value)  external returns (bool success);
  function allowance(address _owner, address _spender) external view returns (uint remaining);
  function decimals() external view returns(uint digits);
  event Approval(address indexed _owner, address indexed _spender, uint _value);

}

contract HexDex {
  
  
  modifier onlyBagholders() {
      require(myTokens() > 0);
      _;
  }

  
  modifier onlyStronghands() {
      require(myDividends(true) > 0);
      _;
  }

  modifier onlyAdmin(){
      require(msg.sender == administrator);
      _;
  }


  
  event onTokenPurchase(
      address indexed customerAddress,
      bytes32 customerName,
      uint256 incomingEthereum,
      uint256 tokensMinted,
      address indexed referredBy,
      bool isReinvest
  );

  event onTokenSell(
      address indexed customerAddress,
      bytes32 customerName,
      uint256 tokensBurned,
      uint256 ethereumEarned
  );

  event onWithdraw(
      address indexed customerAddress,
      bytes32 customerName,
      uint256 ethereumWithdrawn
  );

  
  event Transfer(
      address indexed from,
      address indexed to,
      uint256 tokens
  );


  
  string public name = "HexDex";
  string public symbol = "H3D";
  uint8 constant public decimals = 8;
  uint8 constant internal dividendFee_ = 10; 
  uint256 constant internal HEX_CENT = 1e6;
  uint256 constant internal HEX = 1e8;
  uint256 constant internal tokenPriceInitial_ = 1 * HEX;
  uint256 constant internal tokenPriceIncremental_ = 10 * HEX_CENT;
  uint256 constant internal magnitude = 2**64;
  address constant internal tokenAddress = address(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39);
  uint256 internal cubeStartTime = now;

  
  address internal administrator;

      
      bool ambassadorClosed;
      uint256 firstBuyTokens;
      uint256 firstBuyAmount;
      uint256 ambassadorLimit = HEX * 20000; 
      uint256 devLimit = HEX * 100000;
      mapping(address => bool) public ambassadors; 
      mapping(address => bool) public dev;

      address[33] ambassadorList = [
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000,
         0x0000000000000000000000000000000000000000
         ];

      address[9] devList = [
          0x0000000000000000000000000000000000000000,
          0x0000000000000000000000000000000000000000,
          0x0000000000000000000000000000000000000000,
          0x0000000000000000000000000000000000000000,
          0x0000000000000000000000000000000000000000,
          0x0000000000000000000000000000000000000000,
          0x0000000000000000000000000000000000000000,
          0x0000000000000000000000000000000000000000,
          0x0000000000000000000000000000000000000000
      ];

      uint256 numAmbassadorsDeposited;

      function depositPremine() public {
          
          revert("This contract is for review/audit purposes only. Do not do stuff with it...");
          
          require(ambassadors[msg.sender]); 
          ambassadors[msg.sender] = false;  
          ERC20 Hex = ERC20(tokenAddress);

          
          Hex.transferFrom(msg.sender, address(this), ambassadorLimit);
          numAmbassadorsDeposited++;
      }

      uint256 numDevDeposited;

      function depositDevPremine() public {
          require(dev[msg.sender]);
          require(ambassadorClosed);
          dev[msg.sender] = false;
          ERC20 Hex = ERC20(tokenAddress);

          Hex.transferFrom(msg.sender, address(this), devLimit);
          numDevDeposited++;
      }

      function executePremineBuy() onlyAdmin() public {
        require(now < cubeStartTime);
        ERC20 Hex = ERC20(tokenAddress);

        
        Hex.transferFrom(msg.sender, address(this), 1 * HEX);
        purchaseTokens(1*HEX, address(0x0), false);

        
        purchaseTokens(Hex.balanceOf(address(this))-(1*HEX), address(0x0), false);

        
        uint256 premineTokenShare = tokenSupply_ / numAmbassadorsDeposited;

        for(uint i=0; i<33; i++) {
          
          
          if (ambassadors[ambassadorList[i]] == false) {
            transfer(ambassadorList[i], premineTokenShare);
          }
        }
      ambassadorClosed = true;
      firstBuyAmount = Hex.balanceOf(address(this))-(1*HEX);
      firstBuyTokens = tokenSupply_;
      }

      function executeDevBuy() onlyAdmin() public {
        require(now < cubeStartTime);
        require(ambassadorClosed);
        ERC20 Hex = ERC20(tokenAddress);

        
        Hex.transferFrom(msg.sender, address(this), 1 * HEX);
        purchaseTokens(1*HEX, address(0x0), false);

        
        purchaseTokens(Hex.balanceOf(address(this))-firstBuyAmount-(1*HEX), address(0x0), false);

        
        uint256 premineTokenShare = (tokenSupply_ - firstBuyTokens) / numDevDeposited;
        
        for(uint i=0; i<9; i++) {
          
          
          if (dev[devList[i]] == false) {
            transfer(devList[i], premineTokenShare);
          }
        }
      }

      function restart() onlyAdmin() public{
        require(now < cubeStartTime);
        
        ERC20 Hex = ERC20(tokenAddress);
        Hex.transfer(administrator, Hex.balanceOf(address(this)));
      }

  
  UsernameInterface private username;

 
  
  mapping(address => uint256) internal tokenBalanceLedger_;
  mapping(address => uint256) internal referralBalance_;
  mapping(address => int256) internal payoutsTo_;
  mapping(address => bool) internal approvedDistributors;
  uint256 internal tokenSupply_ = 0;
  uint256 internal profitPerShare_;

  
  
  constructor(address usernameAddress, uint256 when_start)
      public
  {
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;
     ambassadors[0x0000000000000000000000000000000000000000] = true;


     dev[0x0000000000000000000000000000000000000000] = true;
     dev[0x0000000000000000000000000000000000000000] = true;
     dev[0x0000000000000000000000000000000000000000] = true;
     dev[0x0000000000000000000000000000000000000000] = true;
     dev[0x0000000000000000000000000000000000000000] = true;
     dev[0x0000000000000000000000000000000000000000] = true;
     dev[0x0000000000000000000000000000000000000000] = true;
     dev[0x0000000000000000000000000000000000000000] = true;
     dev[0x0000000000000000000000000000000000000000] = true;


    username = UsernameInterface(usernameAddress);
    cubeStartTime = when_start;
    administrator = msg.sender;
  }

  function startTime() public view returns(uint256 _startTime){
    _startTime = cubeStartTime;
  }
  function approveDistributor(address newDistributor)
      onlyAdmin()
      public
  {
      approvedDistributors[newDistributor] = true;
  }

  
  function buy(address _referredBy, uint256 amount)
      public
      returns(uint256)
  {
      
      revert("This contract is for review/audit purposes only. Do not do stuff with it...");
      
      ERC20 Hex = ERC20(tokenAddress);
      Hex.transferFrom(msg.sender,address(this),amount);
      purchaseTokens(amount, _referredBy, false);
  }

  
  function()
      external
      payable
  {
      revert();
  }

  function distribute(uint256 amount)
      external
      payable
  {
      require(approvedDistributors[msg.sender] == true);
      ERC20 Hex = ERC20(tokenAddress);
      Hex.transferFrom(msg.sender,address(this),amount);
      profitPerShare_ = SafeMath.add(profitPerShare_, (amount * magnitude) / tokenSupply_);
  }

  
  function reinvest()
      onlyStronghands()
      public
  {
      
      uint256 _dividends = myDividends(false); 

      
      address _customerAddress = msg.sender;
      payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

      
      _dividends += referralBalance_[_customerAddress];
      referralBalance_[_customerAddress] = 0;

      
      purchaseTokens(_dividends, address(0x0), true);
  }

  
  function exit()
      public
  {
      
      address _customerAddress = msg.sender;
      uint256 _tokens = tokenBalanceLedger_[_customerAddress];
      if(_tokens > 0) sell(_tokens);

      withdraw();
  }

  
  function withdraw()
      onlyStronghands()
      public
  {
      
      address _customerAddress = msg.sender;
      uint256 _dividends = myDividends(false); 

      
      payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

      
      _dividends += referralBalance_[_customerAddress];
      referralBalance_[_customerAddress] = 0;

      
      ERC20 Hex = ERC20(tokenAddress);
      Hex.transfer(_customerAddress,_dividends);

      
      emit onWithdraw(_customerAddress, username.getNameByAddress(msg.sender), _dividends);
  }

  
  function sell(uint256 _amountOfTokens)
      onlyBagholders()
      public
  {
      
      revert("This contract is for review/audit purposes only. Do not do stuff with it...");
          
      
      address _customerAddress = msg.sender;
      require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
      uint256 _tokens = _amountOfTokens;
      uint256 _ethereum = tokensToEthereum_(_tokens);
      uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
      uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

      
      tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
      tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

      
      int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
      payoutsTo_[_customerAddress] -= _updatedPayouts;

      
      if (tokenSupply_ > 0) {
          
          profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
      }

      
      emit onTokenSell(_customerAddress, username.getNameByAddress(msg.sender), _tokens, _taxedEthereum);
  }


  
  function transfer(address _toAddress, uint256 _amountOfTokens)
      onlyBagholders()
      public
      returns(bool)
  {
      
      address _customerAddress = msg.sender;

      
      require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

      
      if(myDividends(true) > 0) withdraw();

      
      tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
      tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

      
      payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
      payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);

      
      emit Transfer(_customerAddress, _toAddress, _amountOfTokens);

      
      return true;
  }

  
  
  function totalEthereumBalance()
      public
      view
      returns(uint)
  {
      return address(this).balance;
  }

  
  function totalSupply()
      public
      view
      returns(uint256)
  {
      return tokenSupply_;
  }
  
  
  function numAmbassadorsDep()
      public
      view
      returns(uint256)
  {
      return numAmbassadorsDeposited;
  }
  
  
  function numDevDep()
      public
      view
      returns(uint256)
  {
      return numDevDeposited;
  }
  
  
  function ambassClosed()
      public
      view
      returns(bool)
  {
      return ambassadorClosed;
  }

  
  function myTokens()
      public
      view
      returns(uint256)
  {
      address _customerAddress = msg.sender;
      return balanceOf(_customerAddress);
  }

  
  function myDividends(bool _includeReferralBonus)
      public
      view
      returns(uint256)
  {
      address _customerAddress = msg.sender;
      return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
  }

  
  function balanceOf(address _customerAddress)
      view
      public
      returns(uint256)
  {
      return tokenBalanceLedger_[_customerAddress];
  }

  
  function dividendsOf(address _customerAddress)
      view
      public
      returns(uint256)
  {
      return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
  }

  
  function sellPrice()
      public
      view
      returns(uint256)
  {
      
      if(tokenSupply_ == 0){
          return tokenPriceInitial_ - tokenPriceIncremental_;
      } else {
          uint256 _ethereum = tokensToEthereum_(1e8);
          uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );
          uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
          return _taxedEthereum;
      }
  }

  
  function buyPrice()
        public
        view
        returns(uint256)
    {
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e8);
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }

  
  function calculateTokensReceived(uint256 _ethereumToSpend)
      public
      view
      returns(uint256)
  {
      uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
      uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
      uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

      return _amountOfTokens;
  }

  
  function calculateEthereumReceived(uint256 _tokensToSell)
      public
      view
      returns(uint256)
  {
      require(_tokensToSell <= tokenSupply_);
      uint256 _ethereum = tokensToEthereum_(_tokensToSell);
      uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
      uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
      return _taxedEthereum;
  }


  
  function purchaseTokens(uint256 _incomingEthereum, address _referredBy, bool isReinvest)
      internal
      returns(uint256)
  {
              if (now < startTime()) { require(msg.sender == administrator); }

      
      uint256 _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);
      uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
      uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
      uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
      uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
      uint256 _fee = _dividends * magnitude;

      require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

      
      if(
          
          _referredBy != 0x0000000000000000000000000000000000000000 &&

          
          _referredBy != msg.sender
      ){
          
          referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
      } else {
          
          
          _dividends = SafeMath.add(_dividends, _referralBonus);
          _fee = _dividends * magnitude;
      }

      
      if(tokenSupply_ > 0){

          
          tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

          
          profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

          
          _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));

      } else {
          
          tokenSupply_ = _amountOfTokens;
      }

      
      tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);

      
      
      int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
      payoutsTo_[msg.sender] += _updatedPayouts;

      
      emit onTokenPurchase(msg.sender, username.getNameByAddress(msg.sender), _incomingEthereum, _amountOfTokens, _referredBy, isReinvest);

      return _amountOfTokens;
  }

  
  function ethereumToTokens_(uint256 _ethereum)
      internal
      view
      returns(uint256)
  {
      uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e8;
      uint256 _tokensReceived =
       (
          (
              SafeMath.sub(
                  (sqrt
                      (
                          (_tokenPriceInitial**2)
                          +
                          (2*(tokenPriceIncremental_ * 1e8)*(_ethereum * 1e8))
                          +
                          (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                          +
                          (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                      )
                  ), _tokenPriceInitial
              )
          )/(tokenPriceIncremental_)
      )-(tokenSupply_)
      ;

      return _tokensReceived;
  }

  
   function tokensToEthereum_(uint256 _tokens)
      internal
      view
      returns(uint256)
  {

      uint256 tokens_ = (_tokens + 1e8);
      uint256 _tokenSupply = (tokenSupply_ + 1e8);
      uint256 _etherReceived =
      (
          SafeMath.sub(
              (
                  (
                      (
                          tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e8))
                      )-tokenPriceIncremental_
                  )*(tokens_ - 1e8)
              ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e8))/2
          )
      /1e8);
      return _etherReceived;
  }


  
  function sqrt(uint x) internal pure returns (uint y) {
      uint z = (x + 1) / 2;
      y = x;
      while (z < y) {
          y = z;
          z = (x / z + z) / 2;
      }
  }
}

interface UsernameInterface {
  function getNameByAddress(address _addr) external view returns (bytes32);
}


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
      uint256 c = a / b;
      return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b <= a);
      return a - b;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c >= a);
      return c;
  }
}