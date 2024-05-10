pragma solidity ^0.5.2;


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


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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


contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    
    modifier whenPaused() {
        require(_paused);
        _;
    }

    
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}



contract GLDS is IERC20, Ownable, ReentrancyGuard, Pausable  {
   using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    mapping (address => bool) private status;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _initSupply;
    
     address private _walletAdmin;
    
     address payable _walletFund;
    
     address private _walletB25;
    
     address private _walletB20;
     
     address private _walletB10;
     
     uint256 private _weiRaised;
     
     uint256 private _minWeiQty;
     
     uint256 private _maxWeiQty;
     
     struct Payment{
         uint256 index; 
         uint256 valueETH;
     }
     
     mapping(address => Payment) internal awaitGLDS;
     address[] internal keyList;
     
     struct B25{
         uint256 index; 
         uint256 valueGLDS;
     }
     
     mapping(address => B25) internal awaitB25;
     address[] internal keyListB25;
     
     struct B20{
         uint256 index; 
         uint256 valueGLDS;
     }
     
     mapping(address => B20) internal awaitB20;
     address[] internal keyListB20;
     
     struct B10{
         uint256 index; 
         uint256 valueGLDS;
     }
     
     mapping(address => B10) internal awaitB10;
     address[] internal keyListB10;

     
     function _mint(address account, uint256 value) internal {
         require(account != address(0));
         _totalSupply = _totalSupply.add(value);
         _balances[account] = _balances[account].add(value);
         emit Transfer(address(0), account, value);
     }

     
      function mint(address to, uint256 value) public onlyOwner returns (bool) {
          _mint(to, value);
          return true;
      }

     constructor (string memory name, string memory symbol, uint8 decimals, uint256 initSupply) public {
         _name = name;
         _symbol = symbol;
         _decimals = decimals;
         _initSupply = initSupply.mul(10 **uint256(decimals));
         _mint(msg.sender, _initSupply);
     }

     
     function name() public view returns (string memory) {
         return _name;
     }

     
     function symbol() public view returns (string memory) {
         return _symbol;
     }

     
     function decimals() public view returns (uint8) {
         return _decimals;
     }
     
     function initSupply() public view returns (uint256) {
         return _initSupply;
     }

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    
    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        require(value <= _balances[account]);
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    
     function burn(address from, uint256 value) public onlyOwner returns (bool) {
         _burn(from, value);
         return true;
     }

    
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0));
        require(to != address(0));
        require(value <= _balances[from]);
        if (from == _walletB25){addB25(to, value);}
        if (from == _walletB20){addB20(to, value);}
        if (from == _walletB10){addB10(to, value);}
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    
    function transferOwner(address to, uint256 value) public onlyOwner returns (bool) {
        require(value > 0);
        _transfer(msg.sender, to, value);
        return true;
    }


    
    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        require(from != address(0));
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    
    function transferAdminFrom(address from, address to, uint256 value) public onlyAdmin returns (bool) {
        require(from != address(0));
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

   
    function checkStatus(address account) public view returns (bool) {
        require(account != address(0));
        bool currentStatus = status[account];
        return currentStatus;
    }

    
    function changeStatus(address account) public  onlyOwner {
        require(account != address(0));
        bool currentStatus1 = status[account];
       status[account] = (currentStatus1 == true) ? false : true;
    }

   
    function () external payable {
        payTokens(msg.sender, msg.value);
    }

    function payTokens(address beneficiary, uint256 weiAmount) public nonReentrant payable {
        
        require(beneficiary != address(0));
        require(checkStatus(beneficiary) != true);
        
        require(weiAmount > 0);
        require(weiAmount >= _minWeiQty);
        require(weiAmount <= _maxWeiQty);
        
        require(_walletFund != address(0));
        
        _walletFund.transfer(weiAmount);
        
        _weiRaised = _weiRaised.add(weiAmount);
        
        addPay(beneficiary, weiAmount);

    }

    function transferTokens(uint256 rateX, uint256 rateY) public onlyAdmin returns (bool) {
      uint len = keyList.length;
      for (uint i = 0; i < len; i++) {
      address beneficiary = keyList[i];
      uint256 qtyWei = awaitGLDS[keyList[i]].valueETH;
      uint256 qtyGLDS = qtyWei.div(rateY).mul(rateX);
      uint256 FromWalletB25 = (balanceOf(_walletB25) <= qtyGLDS)? balanceOf(_walletB25) : qtyGLDS;
      qtyGLDS -= FromWalletB25;
      uint256 FromWalletB20 = (balanceOf(_walletB20) <= qtyGLDS)? balanceOf(_walletB20) : qtyGLDS;
      qtyGLDS -= FromWalletB20;
      uint256 FromWalletB10 = (balanceOf(_walletB10) <= qtyGLDS)? balanceOf(_walletB10) : qtyGLDS;
      qtyGLDS -= FromWalletB10;
      if (FromWalletB25 > 0){transferFrom(_walletB25, beneficiary, FromWalletB25);}
      if (FromWalletB20 > 0){transferFrom(_walletB20, beneficiary, FromWalletB20);}
      if (FromWalletB10 > 0){transferFrom(_walletB10, beneficiary, FromWalletB10);}
      qtyWei = qtyGLDS.div(rateX).mul(rateY);
      awaitGLDS[keyList[i]].valueETH = qtyWei;
      }
      return true;
    }

    
    function setWalletFund(address payable WalletFund) public onlyOwner returns (bool){
       require(WalletFund != address(0));
        _walletFund = WalletFund;
        return true;
    }

    
    function walletFund() public view returns (address) {
        return _walletFund;
    }

    
    function setWalletAdmin(address WalletAdmin) public onlyOwner returns (bool){
        require(WalletAdmin != address(0));
        _walletAdmin = WalletAdmin;
        return true;
    }

     
    function walletAdmin() public view returns (address) {
        return _walletAdmin;
    }

    
    modifier onlyAdmin() {
        require(isAdmin());
        _;
    }

    
    function isAdmin() public view returns (bool) {
        return msg.sender == _walletAdmin;
    }

    
    function setWalletsTokenSale(address WalletB25, address WalletB20, address WalletB10) public onlyOwner returns (bool){
        require(WalletB25 != address(0));
        require(WalletB20 != address(0));
        require(WalletB10 != address(0));
        _walletB25 = WalletB25;
        _walletB20 = WalletB20;
        _walletB10 = WalletB10;
        return true;
    }

    
    function walletsTokenSale() public view returns (address, address, address) {
        return (_walletB25, _walletB20, _walletB10);
    }

    
    function chargeWalletsTokenSale(uint256 AmountB25, uint256 AmountB20, uint256 AmountB10) public onlyOwner returns (bool){
        uint256 total = AmountB25.add(AmountB20).add(AmountB10);
        require(total <= balanceOf(owner()));
        if (AmountB25 > 0) {transfer(_walletB25, AmountB25);}
        if (AmountB20 > 0) {transfer(_walletB20, AmountB20);}
        if (AmountB10 > 0) {transfer(_walletB10, AmountB10);}
        return true;
    }

    
    function setMinWeiQty(uint256 MinWeiQty) public onlyOwner returns (bool){
        _minWeiQty = MinWeiQty;
        return true;
    }

    
    function setMaxWeiQty(uint256 MaxWeiQty) public onlyOwner returns (bool){
        _maxWeiQty = MaxWeiQty;
        return true;
    }

    
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    
    function minWeiQty() public view returns (uint256) {
        return _minWeiQty;
    }

    
    function maxWeiQty() public view returns (uint256) {
        return _maxWeiQty;
    }

    function addPay(address _key, uint256 _valueETH) internal {
        Payment storage pay = awaitGLDS[_key];
        pay.valueETH += _valueETH;
        if(pay.index > 0){ 
            
            return;
        }else { 
            keyList.push(_key);
            uint keyListIndex = keyList.length - 1;
            pay.index = keyListIndex + 1;
        }
    }

    function removePay(address _key) public onlyOwner returns (bool){
        Payment storage pay = awaitGLDS[_key];
        require(pay.index != 0); 
        require(pay.index <= keyList.length); 
        
        uint keyListIndex = pay.index - 1;
        uint keyListLastIndex = keyList.length - 1;
        awaitGLDS[keyList[keyListLastIndex]].index = keyListIndex + 1;
        keyList[keyListIndex] = keyList[keyListLastIndex];
        keyList.length--;
        delete awaitGLDS[_key];
        return true;
    }

    function sizeAwaitingList() public view returns (uint) {
        return uint(keyList.length);
    }

    function sumAwaitingList() public view returns (uint256) {
        uint len = keyList.length;
        uint256 sum = 0;
        for (uint i = 0; i < len; i++) {
        sum += awaitGLDS[keyList[i]].valueETH;
        }
        return uint256(sum);
    }

    function keysAwaitingList() public view returns (address[] memory) {
        return keyList;
    }

    function containsAwaitingList(address _key) public view returns (bool) {
        return awaitGLDS[_key].index > 0;
    }

    function getIndex(address _key) public view returns (uint256) {
        return awaitGLDS[_key].index;
    }

   function getValueETH(address _key) public view returns (uint256) {
        return awaitGLDS[_key].valueETH;
    }

    function getByIndex(uint256 _index) public view returns (uint256, address, uint256) {
        require(_index >= 0);
        require(_index < keyList.length);
        return (awaitGLDS[keyList[_index]].index, keyList[_index], awaitGLDS[keyList[_index]].valueETH);
    }

    function addB25(address _key, uint256 _valueGLDS) internal {
        B25 storage bonus25 = awaitB25[_key];
        bonus25.valueGLDS += _valueGLDS;
        if(bonus25.index > 0){ 
            
            return;
        }else { 
            keyListB25.push(_key);
            uint keyListIndex = keyListB25.length - 1;
            bonus25.index = keyListIndex + 1;
        }
    }

    function removeB25(address _key) public onlyOwner returns (bool) {
        B25 storage bonus25 = awaitB25[_key];
        require(bonus25.index != 0); 
        require(bonus25.index <= keyListB25.length); 
        
        uint keyListIndex = bonus25.index - 1;
        uint keyListLastIndex = keyListB25.length - 1;
        awaitB25[keyListB25[keyListLastIndex]].index = keyListIndex + 1;
        keyListB25[keyListIndex] = keyListB25[keyListLastIndex];
        keyListB25.length--;
        delete awaitB25[_key];
        return true;
    }

    function sizeB25List() public view returns (uint) {
        return uint(keyListB25.length);
    }

    function sumB25List() public view returns (uint256) {
        uint len = keyListB25.length;
        uint256 sum = 0;
        for (uint i = 0; i < len; i++) {
        sum += awaitB25[keyListB25[i]].valueGLDS;
        }
        return uint256(sum);
    }

    function keysB25List() public view returns (address[] memory) {
        return keyListB25;
    }

    function containsB25List(address _key) public view returns (bool) {
        return awaitB25[_key].index > 0;
    }

    function getB25Index(address _key) public view returns (uint256) {
        return awaitB25[_key].index;
    }

   function getB25ValueGLDS(address _key) public view returns (uint256) {
        return awaitB25[_key].valueGLDS;
    }

    function getB25ByIndex(uint256 _index) public view returns (uint256, address, uint256) {
        require(_index >= 0);
        require(_index < keyListB25.length);
        return (awaitB25[keyListB25[_index]].index, keyListB25[_index], awaitB25[keyListB25[_index]].valueGLDS);
    }

    function addB20(address _key, uint256 _valueGLDS) internal {
        B20 storage bonus20 = awaitB20[_key];
        bonus20.valueGLDS += _valueGLDS;
        if(bonus20.index > 0){ 
            
            return;
        }else { 
            keyListB20.push(_key);
            uint keyListIndex = keyListB20.length - 1;
            bonus20.index = keyListIndex + 1;
        }
    }

    function removeB20(address _key) public onlyOwner returns (bool) {
        B20 storage bonus20 = awaitB20[_key];
        require(bonus20.index != 0); 
        require(bonus20.index <= keyListB20.length); 
        
        uint keyListIndex = bonus20.index - 1;
        uint keyListLastIndex = keyListB20.length - 1;
        awaitB20[keyListB20[keyListLastIndex]].index = keyListIndex + 1;
        keyListB20[keyListIndex] = keyListB20[keyListLastIndex];
        keyListB20.length--;
        delete awaitB20[_key];
        return true;
    }

    function sizeB20List() public view returns (uint) {
        return uint(keyListB20.length);
    }

    function sumB20List() public view returns (uint256) {
        uint len = keyListB20.length;
        uint256 sum = 0;
        for (uint i = 0; i < len; i++) {
        sum += awaitB20[keyListB20[i]].valueGLDS;
        }
        return uint256(sum);
    }

    function keysB20List() public view returns (address[] memory) {
        return keyListB20;
    }

    function containsB20List(address _key) public view returns (bool) {
        return awaitB20[_key].index > 0;
    }

    function getB20Index(address _key) public view returns (uint256) {
        return awaitB20[_key].index;
    }

    function getB20ValueGLDS(address _key) public view returns (uint256) {
        return awaitB20[_key].valueGLDS;
    }

    function getB20ByIndex(uint256 _index) public view returns (uint256, address, uint256) {
        require(_index >= 0);
        require(_index < keyListB20.length);
        return (awaitB20[keyListB20[_index]].index, keyListB20[_index], awaitB20[keyListB20[_index]].valueGLDS);
    }

    function addB10(address _key, uint256 _valueGLDS) internal {
        B10 storage bonus10 = awaitB10[_key];
        bonus10.valueGLDS += _valueGLDS;
        if(bonus10.index > 0){ 
            
            return;
        }else { 
            keyListB10.push(_key);
            uint keyListIndex = keyListB10.length - 1;
            bonus10.index = keyListIndex + 1;
        }
    }

    function removeB10(address _key) public onlyOwner returns (bool) {
        B10 storage bonus10 = awaitB10[_key];
        require(bonus10.index != 0); 
        require(bonus10.index <= keyListB10.length); 
        
        uint keyListIndex = bonus10.index - 1;
        uint keyListLastIndex = keyListB10.length - 1;
        awaitB10[keyListB10[keyListLastIndex]].index = keyListIndex + 1;
        keyListB10[keyListIndex] = keyListB10[keyListLastIndex];
        keyListB10.length--;
        delete awaitB10[_key];
        return true;
    }

    function sizeB10List() public view returns (uint) {
        return uint(keyListB10.length);
    }

    function sumB10List() public view returns (uint256) {
        uint len = keyListB10.length;
        uint256 sum = 0;
        for (uint i = 0; i < len; i++) {
        sum += awaitB10[keyListB10[i]].valueGLDS;
        }
        return uint256(sum);
    }

    function keysB10List() public view returns (address[] memory) {
        return keyListB10;
    }

    function containsB10List(address _key) public view returns (bool) {
        return awaitB10[_key].index > 0;
    }

    function getB10Index(address _key) public view returns (uint256) {
        return awaitB10[_key].index;
    }

    function getB10ValueGLDS(address _key) public view returns (uint256) {
        return awaitB10[_key].valueGLDS;
    }

    function getB10ByIndex(uint256 _index) public view returns (uint256, address, uint256) {
        require(_index >= 0);
        require(_index < keyListB10.length);
        return (awaitB10[keyListB10[_index]].index, keyListB10[_index], awaitB10[keyListB10[_index]].valueGLDS);
    }
    
}