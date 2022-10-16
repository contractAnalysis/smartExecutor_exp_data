pragma solidity 0.5.16;  








library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}





    
contract owned {
    address payable public owner;
    address payable internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
 

    



    
contract ReynaFoundationCoin is owned {
    

    

    
    using SafeMath for uint256;
    string constant private _name = "Reyna Foundation Coin";
    string constant private _symbol = "REY2";
    uint256 constant private _decimals = 18;
    uint256 private _totalSupply = 999000000000 * (10**_decimals);         
    uint256 constant public maxSupply = 999000000000 * (10**_decimals);    
    bool public safeguard;  

    
    mapping (address => uint256) private _balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;
    mapping (address => bool) public frozenAccount;


    

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Burn(address indexed from, uint256 value);
        
    
    event FrozenAccounts(address target, bool frozen);
    
    
    event Approval(address indexed from, address indexed spender, uint256 value);



    
    
    
    function name() public pure returns(string memory){
        return _name;
    }
    
    
    function symbol() public pure returns(string memory){
        return _symbol;
    }
    
    
    function decimals() public pure returns(uint256){
        return _decimals;
    }
    
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    
    function balanceOf(address user) public view returns(uint256){
        return _balanceOf[user];
    }
    
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }
    
    
    function _transfer(address _from, address _to, uint _value) internal {
        
        
        require(!safeguard);
        require (_to != address(0));                      
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        
        
        _balanceOf[_from] = _balanceOf[_from].sub(_value);    
        _balanceOf[_to] = _balanceOf[_to].add(_value);        
        
        
        emit Transfer(_from, _to, _value);
    }

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        
        _transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!safeguard);
        
        
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    
    function increase_allowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    
    function decrease_allowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].sub(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }


    
    
    constructor() public{
        
        _balanceOf[owner] = _totalSupply;
        
        
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    function () external payable {
      buyTokens();
    }

    
    function burn(uint256 _value) public returns (bool success) {
        require(!safeguard);
        
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);  
        _totalSupply = _totalSupply.sub(_value);                      
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(!safeguard);
        
        _balanceOf[_from] = _balanceOf[_from].sub(_value);                         
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value); 
        _totalSupply = _totalSupply.sub(_value);                                   
        emit  Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }
        
    
    
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit  FrozenAccounts(target, freeze);
    }
    
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        require(_totalSupply.add(mintedAmount) <= maxSupply, "Cannot Mint more than maximum supply");
        _balanceOf[target] = _balanceOf[target].add(mintedAmount);
        _totalSupply = _totalSupply.add(mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
    }

        

    
    
    function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner{
        
        _transfer(address(this), owner, tokenAmount);
    }
    
    
    function manualWithdrawEther()onlyOwner public{
        address(owner).transfer(address(this).balance);
    }
    
    
    function changeSafeguardStatus() onlyOwner public{
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;    
        }
    }
    

    
    
    
    
    
    bool public passiveAirdropStatus;
    uint256 public passiveAirdropTokensAllocation;
    uint256 public airdropAmount;  
    uint256 public passiveAirdropTokensSold;
    mapping(uint256 => mapping(address => bool)) public airdropClaimed;
    uint256 internal airdropClaimedIndex;
    uint256 public airdropFee = 0.05 ether;
    
    
    function startNewPassiveAirDrop(uint256 passiveAirdropTokensAllocation_, uint256 airdropAmount_  ) public onlyOwner {
        passiveAirdropTokensAllocation = passiveAirdropTokensAllocation_;
        airdropAmount = airdropAmount_;
        passiveAirdropStatus = true;
    } 
    
    
    function stopPassiveAirDropCompletely() public onlyOwner{
        passiveAirdropTokensAllocation = 0;
        airdropAmount = 0;
        airdropClaimedIndex++;
        passiveAirdropStatus = false;
    }
    
    
    function claimPassiveAirdrop() public payable returns(bool) {
        require(airdropAmount > 0, 'Token amount must not be zero');
        require(passiveAirdropStatus, 'Air drop is not active');
        require(passiveAirdropTokensSold <= passiveAirdropTokensAllocation, 'Air drop sold out');
        require(!airdropClaimed[airdropClaimedIndex][msg.sender], 'user claimed air drop already');
        require(!isContract(msg.sender),  'No contract address allowed to claim air drop');
        require(msg.value >= airdropFee, 'Not enough ether to claim this airdrop');
        
        _transfer(address(this), msg.sender, airdropAmount);
        passiveAirdropTokensSold += airdropAmount;
        airdropClaimed[airdropClaimedIndex][msg.sender] = true; 
        return true;
    }
    
    
    
    function changePassiveAirdropAmount(uint256 newAmount) public onlyOwner{
        airdropAmount = newAmount;
    }
    
    
    
    function isContract(address _address) public view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
    
    
    
    function updateAirdropFee(uint256 newFee) public onlyOwner{
        airdropFee = newFee;
    }
    
    
    function airdropACTIVE(address[] memory recipients,uint256[] memory tokenAmount) public returns(bool) {
        uint256 totalAddresses = recipients.length;
        require(totalAddresses <= 150,"Too many recipients");
        for(uint i = 0; i < totalAddresses; i++)
        {
          
          
          transfer(recipients[i], tokenAmount[i]);
        }
        return true;
    }
    
    
    
    
    
    
    
    bool public whitelistingStatus;
    mapping (address => bool) public whitelisted;
    
    
    function changeWhitelistingStatus() onlyOwner public{
        if (whitelistingStatus == false){
            whitelistingStatus = true;
        }
        else{
            whitelistingStatus = false;    
        }
    }
    
    
    function whitelistUser(address userAddress) onlyOwner public{
        require(whitelistingStatus == true);
        require(userAddress != address(0));
        whitelisted[userAddress] = true;
    }
    
    
    function whitelistManyUsers(address[] memory userAddresses) onlyOwner public{
        require(whitelistingStatus == true);
        uint256 addressCount = userAddresses.length;
        require(addressCount <= 150,"Too many addresses");
        for(uint256 i = 0; i < addressCount; i++){
            whitelisted[userAddresses[i]] = true;
        }
    }
    
    
    
    
    
    
    uint256 public sellPrice;
    uint256 public buyPrice;
    
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;   
        buyPrice = newBuyPrice;     
    }

    
    
    function buyTokens() payable public {
        uint amount = msg.value * buyPrice;                 
        _transfer(address(this), msg.sender, amount);       
    }

    
    function sellTokens(uint256 amount) public {
        uint256 etherAmount = amount * sellPrice/(10**_decimals);
        require(address(this).balance >= etherAmount);   
        _transfer(msg.sender, address(this), amount);           
        msg.sender.transfer(etherAmount);                
    }
    
    
    

}