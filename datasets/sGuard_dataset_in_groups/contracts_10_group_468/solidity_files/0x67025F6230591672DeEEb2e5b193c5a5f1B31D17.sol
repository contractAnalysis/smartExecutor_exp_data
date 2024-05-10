pragma solidity ^0.5.12;

contract    Token
{
    

    address public              owner;          
    address public              admin;          

    mapping(address => uint256)                         balances;       
    mapping(address => mapping (address => uint256))    allowances;     

    

    string  public  constant    name       = "QCLR Token";
    string  public  constant    symbol     = "QCLR";
    uint256 public  constant    decimals   = 18;      

    uint256 public              totalSupply = 800000000 * 10**decimals;        

    

    uint256 public              icoDeadLine = 0;     

    

    modifier duringIcoOnlyTheOwner()  
    {
        require( now>icoDeadLine || msg.sender==owner );
        _;
    }

    modifier onlyOwner()            { require(msg.sender==owner);           _; }
    modifier onlyAdmin()            { require(msg.sender==admin);           _; }

    

    event Transfer(address indexed fromAddr, address indexed toAddr,   uint256 amount);
    event Approval(address indexed _owner,   address indexed _spender, uint256 amount);

            

    event onAdminUserChanged(   address oldAdmin,  address newAdmin);
    event onOwnershipTransfered(address oldOwner,  address newOwner);
    event onAdminUserChange(    address oldAdmin,  address newAdmin);

    event onIcoDeadlineChanged( uint256 previousDeadline,  uint256 newDeadline);

    
    
    constructor()   public
    {
        owner = msg.sender;
        admin = owner;

        balances[owner] = totalSupply;
    }
    
    
    
    
    
    function balanceOf(address walletAddress) public view returns (uint256 balance)
    {
        return balances[walletAddress];
    }
    
    function transfer(address toAddr, uint256 amountInWei)  public   duringIcoOnlyTheOwner   returns (bool)     
    {
        require(toAddr!=address(0x0) && toAddr!=msg.sender && amountInWei>0);     

        uint256 balanceFrom = balances[msg.sender] - amountInWei;
        uint256 balanceTo   = balances[toAddr]     + amountInWei;
       
        assert(balanceFrom <= balances[msg.sender]);
        assert(balanceTo   >= balances[toAddr]);
       
        balances[msg.sender] = balanceFrom;
        balances[toAddr]     = balanceTo;

        emit Transfer(msg.sender, toAddr, amountInWei);

        return true;
    }
    
    function    allowance(address walletAddress, address spender) public view returns (uint remaining)
    {
        return allowances[walletAddress][spender];
    }
    
    function    transferFrom(address fromAddr, address toAddr, uint256 amountInWei)  public  returns (bool)
    {
        require(amountInWei!=0                                   &&
                balances[fromAddr]               >= amountInWei  &&
                allowances[fromAddr][msg.sender] >= amountInWei);
       
        uint256 balanceFrom  = balances[fromAddr]               - amountInWei;
        uint256 balanceTo    = balances[toAddr]                 + amountInWei;
        uint256 newAllowance = allowances[fromAddr][msg.sender] - amountInWei;

        assert(balanceFrom  <= balances[fromAddr]);
        assert(balanceTo    >= balances[toAddr]);
        assert(newAllowance <= allowances[fromAddr][msg.sender]);

        balances[fromAddr]               = balanceFrom;
        balances[toAddr]                 = balanceTo;
        allowances[fromAddr][msg.sender] = newAllowance;

        emit Transfer(fromAddr, toAddr, amountInWei);
        return true;
    }
    
    function    approve(address spender, uint256 amountInWei) public returns (bool)
    {
        require((amountInWei == 0) || (allowances[msg.sender][spender] == 0));
       
        allowances[msg.sender][spender] = amountInWei;
        emit Approval(msg.sender, spender, amountInWei);

        return true;
    }
    
    function()   external                
    {
        assert(true == false);      
    }
    
    
    
    function    transferOwnership(address newOwner) public onlyOwner               
    {
        require(newOwner != address(0x0));

        emit onOwnershipTransfered(owner, newOwner);
        owner = newOwner;
    }
    
    
    
    
    function    changeAdminUser(address newAdminAddress) public onlyOwner
    {
        require(newAdminAddress!=address(0x0));

        emit onAdminUserChange(admin, newAdminAddress);
        admin = newAdminAddress;
    }
    
    
    function    changeIcoDeadLine(uint256 newIcoDeadline) public onlyAdmin
    {
        require(newIcoDeadline!=0);

        emit onIcoDeadlineChanged(icoDeadLine, newIcoDeadline);
        icoDeadLine = newIcoDeadline;
    }
    
    
    
    function destroySomeTokens(uint256 amountToBurnInWei) public onlyAdmin  returns(uint)
    {
        require(msg.sender==owner && balances[owner]>=amountToBurnInWei);

        address   toAddr = 0x0000000000000000000000000000000000000000;

        balances[owner]  = balances[owner]  - amountToBurnInWei;
        balances[toAddr] = balances[toAddr] + amountToBurnInWei;      

        emit Transfer(msg.sender, toAddr, amountToBurnInWei);

        totalSupply = totalSupply - amountToBurnInWei;

        return 1;
    }
    
    function addSomeTokens(uint256 amountToAddInWei) public onlyAdmin  returns(uint)
    {
        require(msg.sender==owner);

        uint256     newOwnerBalance = balances[owner] + amountToAddInWei;
        uint256     newTotalSupply  = totalSupply     + amountToAddInWei;

        assert(newOwnerBalance >= totalSupply);
        assert(newTotalSupply  >= totalSupply);

        balances[owner] = balances[owner] + amountToAddInWei;

        emit Transfer(msg.sender, owner, amountToAddInWei);

        totalSupply = totalSupply + amountToAddInWei;

        return 1;
    }
    
    
    
}