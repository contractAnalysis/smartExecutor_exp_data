pragma solidity 0.5.12;



contract Ownable {

    
    address public owner;

    
    
    address public newOwner;

    
    
    
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Restricted to owner");
        _;
    }

    
    constructor() public {
        owner = msg.sender;
    }

    
    
    
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0x0), "New owner is zero");

        newOwner = _newOwner;
    }

    
    
    
    
    function transferOwnershipUnsafe(address _newOwner) public onlyOwner {
        require(_newOwner != address(0x0), "New owner is zero");

        _transferOwnership(_newOwner);
    }

    
    function claimOwnership() public {
        require(msg.sender == newOwner, "Restricted to new owner");

        _transferOwnership(msg.sender);
    }

    
    
    function _transferOwnership(address _newOwner) private {
        if (_newOwner != owner) {
            emit OwnershipTransferred(owner, _newOwner);

            owner = _newOwner;
        }
        newOwner = address(0x0);
    }

}



pragma solidity 0.5.12;





contract Whitelist is Ownable {

    
    mapping(address => bool) public admins;

    
    mapping(address => bool) public isWhitelisted;

    
    
    event AdminAdded(address indexed admin);

    
    
    event AdminRemoved(address indexed admin);

    
    
    
    event InvestorAdded(address indexed admin, address indexed investor);

    
    
    
    event InvestorRemoved(address indexed admin, address indexed investor);

    
    modifier onlyAdmin() {
        require(admins[msg.sender], "Restricted to whitelist admin");
        _;
    }

    
    
    function addAdmin(address _admin) public onlyOwner {
        require(_admin != address(0x0), "Whitelist admin is zero");

        if (!admins[_admin]) {
            admins[_admin] = true;

            emit AdminAdded(_admin);
        }
    }

    
    
    function removeAdmin(address _admin) public onlyOwner {
        require(_admin != address(0x0), "Whitelist admin is zero");  

        if (admins[_admin]) {
            admins[_admin] = false;

            emit AdminRemoved(_admin);
        }
    }

    
    
    function addToWhitelist(address[] calldata _investors) external onlyAdmin {
        for (uint256 i = 0; i < _investors.length; i++) {
            if (!isWhitelisted[_investors[i]]) {
                isWhitelisted[_investors[i]] = true;

                emit InvestorAdded(msg.sender, _investors[i]);
            }
        }
    }

    
    
    function removeFromWhitelist(address[] calldata _investors) external onlyAdmin {
        for (uint256 i = 0; i < _investors.length; i++) {
            if (isWhitelisted[_investors[i]]) {
                isWhitelisted[_investors[i]] = false;

                emit InvestorRemoved(msg.sender, _investors[i]);
            }
        }
    }

}



pragma solidity 0.5.12;






contract Whitelisted is Ownable {

    Whitelist public whitelist;

    
    
    
    event WhitelistChange(address indexed previous, address indexed current);

    
    modifier onlyWhitelisted(address _address) {
        require(whitelist.isWhitelisted(_address), "Address is not whitelisted");
        _;
    }

    
    
    constructor(Whitelist _whitelist) public {
        setWhitelist(_whitelist);
    }

    
    
    function setWhitelist(Whitelist _newWhitelist) public onlyOwner {
        require(address(_newWhitelist) != address(0x0), "Whitelist address is zero");

        if (address(_newWhitelist) != address(whitelist)) {
            emit WhitelistChange(address(whitelist), address(_newWhitelist));

            whitelist = Whitelist(_newWhitelist);
        }
    }

}



pragma solidity 0.5.12;





contract TokenRecoverable is Ownable {

    
    address public tokenRecoverer;

    
    
    
    event TokenRecovererChange(address indexed previous, address indexed current);

    
    
    
    event TokenRecovery(address indexed oldAddress, address indexed newAddress);

    
    modifier onlyTokenRecoverer() {
        require(msg.sender == tokenRecoverer, "Restricted to token recoverer");
        _;
    }

    
    
    constructor(address _tokenRecoverer) public {
        setTokenRecoverer(_tokenRecoverer);
    }

    
    
    function setTokenRecoverer(address _newTokenRecoverer) public onlyOwner {
        require(_newTokenRecoverer != address(0x0), "New token recoverer is zero");

        if (_newTokenRecoverer != tokenRecoverer) {
            emit TokenRecovererChange(tokenRecoverer, _newTokenRecoverer);

            tokenRecoverer = _newTokenRecoverer;
        }
    }

    
    
    
    function recoverToken(address _oldAddress, address _newAddress) public;

}



pragma solidity 0.5.12;




interface ERC20 {

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function totalSupply() external view returns (uint);
    function balanceOf(address _owner) external view returns (uint);
    function allowance(address _owner, address _spender) external view returns (uint);
    function approve(address _spender, uint _value) external returns (bool);
    function transfer(address _to, uint _value) external returns (bool);
    function transferFrom(address _from, address _to, uint _value) external returns (bool);

}



pragma solidity 0.5.12;




library SafeMath {

    
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;

        assert(c >= a);

        return c;
    }

    
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);

        return a - b;
    }

    
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;

        assert(c / a == b);

        return c;
    }

    
    function div(uint a, uint b) internal pure returns (uint) {
        return a / b;
    }

}



pragma solidity 0.5.12;






contract ProfitSharing is Ownable {

    using SafeMath for uint;


    
    
    
    
    
    
    
    
    
    struct InvestorAccount {
        uint balance;           
        uint lastTotalProfits;  
        uint profitShare;       
    }


    
    mapping(address => InvestorAccount) public accounts;

    
    address public profitDepositor;

    
    
    address public profitDistributor;

    
    
    
    uint public totalProfits;

    
    
    bool public totalSupplyIsFixed;

    
    uint internal totalSupply_;


    
    
    
    event ProfitDepositorChange(
        address indexed previous,
        address indexed current
    );

    
    
    
    event ProfitDistributorChange(
        address indexed previous,
        address indexed current
    );

    
    
    
    event ProfitDeposit(
        address indexed depositor,
        uint amount
    );

    
    
    
    event ProfitShareUpdate(
        address indexed investor,
        uint amount
    );

    
    
    
    event ProfitShareWithdrawal(
        address indexed investor,
        address indexed beneficiary,
        uint amount
    );


    
    modifier onlyProfitDepositor() {
        require(msg.sender == profitDepositor, "Restricted to profit depositor");
        _;
    }

    
    modifier onlyProfitDistributor() {
        require(msg.sender == profitDistributor, "Restricted to profit distributor");
        _;
    }

    
    modifier onlyWhenTotalSupplyIsFixed() {
        require(totalSupplyIsFixed, "Total supply may change");
        _;
    }

    
    
    constructor(address _profitDepositor, address _profitDistributor) public {
        setProfitDepositor(_profitDepositor);
        setProfitDistributor(_profitDistributor);
    }

    
    function () external payable {
        require(msg.data.length == 0, "Fallback call with data");

        depositProfit();
    }

    
    
    function setProfitDepositor(address _newProfitDepositor) public onlyOwner {
        require(_newProfitDepositor != address(0x0), "New profit depositor is zero");

        if (_newProfitDepositor != profitDepositor) {
            emit ProfitDepositorChange(profitDepositor, _newProfitDepositor);

            profitDepositor = _newProfitDepositor;
        }
    }

    
    
    function setProfitDistributor(address _newProfitDistributor) public onlyOwner {
        require(_newProfitDistributor != address(0x0), "New profit distributor is zero");

        if (_newProfitDistributor != profitDistributor) {
            emit ProfitDistributorChange(profitDistributor, _newProfitDistributor);

            profitDistributor = _newProfitDistributor;
        }
    }

    
    function depositProfit() public payable onlyProfitDepositor onlyWhenTotalSupplyIsFixed {
        require(totalSupply_ > 0, "Total supply is zero");

        totalProfits = totalProfits.add(msg.value);

        emit ProfitDeposit(msg.sender, msg.value);
    }

    
    
    
    function profitShareOwing(address _investor) public view returns (uint) {
        if (!totalSupplyIsFixed || totalSupply_ == 0) {
            return 0;
        }

        InvestorAccount memory account = accounts[_investor];

        return totalProfits.sub(account.lastTotalProfits)
                           .mul(account.balance)
                           .div(totalSupply_)
                           .add(account.profitShare);
    }

    
    
    function updateProfitShare(address _investor) public onlyWhenTotalSupplyIsFixed {
        uint newProfitShare = profitShareOwing(_investor);

        accounts[_investor].lastTotalProfits = totalProfits;
        accounts[_investor].profitShare = newProfitShare;

        emit ProfitShareUpdate(_investor, newProfitShare);
    }

    
    function withdrawProfitShare() public {
        _withdrawProfitShare(msg.sender, msg.sender);
    }

    function withdrawProfitShareTo(address payable _beneficiary) public {
        _withdrawProfitShare(msg.sender, _beneficiary);
    }

    
    function withdrawProfitShares(address payable[] calldata _investors)
        external
        onlyProfitDistributor
    {
        for (uint i = 0; i < _investors.length; ++i) {
            _withdrawProfitShare(_investors[i], _investors[i]);
        }
    }

    
    function _withdrawProfitShare(address _investor, address payable _beneficiary) internal {
        updateProfitShare(_investor);

        uint withdrawnProfitShare = accounts[_investor].profitShare;

        accounts[_investor].profitShare = 0;
        _beneficiary.transfer(withdrawnProfitShare);

        emit ProfitShareWithdrawal(_investor, _beneficiary, withdrawnProfitShare);
    }

}



pragma solidity 0.5.12;










contract MintableToken is ERC20, ProfitSharing, Whitelisted {

    address public minter;
    uint public numberOfInvestors = 0;

    
    
    
    event Minted(address indexed to, uint amount);

    
    event MintFinished();

    
    modifier onlyMinter() {
        require(msg.sender == minter, "Restricted to minter");
        _;
    }

    
    modifier canMint() {
        require(!totalSupplyIsFixed, "Total supply has been fixed");
        _;
    }

    
    
    function setMinter(address _minter) public onlyOwner {
        require(minter == address(0x0), "Minter has already been set");
        require(_minter != address(0x0), "Minter is zero");

        minter = _minter;
    }

    
    
    
    function mint(address _to, uint _amount) public onlyMinter canMint onlyWhitelisted(_to) {
        if (accounts[_to].balance == 0) {
            numberOfInvestors++;
        }

        totalSupply_ = totalSupply_.add(_amount);
        accounts[_to].balance = accounts[_to].balance.add(_amount);

        emit Minted(_to, _amount);
        emit Transfer(address(0x0), _to, _amount);
    }

    
    function finishMinting() public onlyMinter canMint {
        totalSupplyIsFixed = true;

        emit MintFinished();
    }

}



pragma solidity 0.5.12;







contract StokrToken is MintableToken, TokenRecoverable {

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    mapping(address => mapping(address => uint)) internal allowance_;

    
    event TokenDestroyed();

    
    
    
    constructor(
        string memory _name,
        string memory _symbol,
        Whitelist _whitelist,
        address _profitDepositor,
        address _profitDistributor,
        address _tokenRecoverer
    )
        public
        Whitelisted(_whitelist)
        ProfitSharing(_profitDepositor, _profitDistributor)
        TokenRecoverable(_tokenRecoverer)
    {
        name = _name;
        symbol = _symbol;
    }

    
    function destruct() public onlyMinter {
        emit TokenDestroyed();
        selfdestruct(address(uint160(owner)));
    }

    
    
    
    function recoverToken(address _oldAddress, address _newAddress)
        public
        onlyTokenRecoverer
        onlyWhitelisted(_newAddress)
    {
        
        
        
        require(accounts[_newAddress].balance == 0 && accounts[_newAddress].lastTotalProfits == 0,
                "New address exists already");

        updateProfitShare(_oldAddress);

        accounts[_newAddress] = accounts[_oldAddress];
        delete accounts[_oldAddress];

        emit TokenRecovery(_oldAddress, _newAddress);
        emit Transfer(_oldAddress, _newAddress, accounts[_newAddress].balance);
    }

    
    
    function totalSupply() public view returns (uint) {
        return totalSupply_;
    }

    
    
    
    function balanceOf(address _investor) public view returns (uint) {
        return accounts[_investor].balance;
    }

    
    
    
    
    function allowance(address _investor, address _spender) public view returns (uint) {
        return allowance_[_investor][_spender];
    }

    
    
    
    
    
    function approve(address _spender, uint _value) public returns (bool) {
        return _approve(msg.sender, _spender, _value);
    }

    
    
    
    
    
    function increaseAllowance(address _spender, uint _amount) public returns (bool) {
        require(allowance_[msg.sender][_spender] + _amount >= _amount, "Allowance overflow");

        return _approve(msg.sender, _spender, allowance_[msg.sender][_spender].add(_amount));
    }

    
    
    
    
    
    function decreaseAllowance(address _spender, uint _amount) public returns (bool) {
        require(_amount <= allowance_[msg.sender][_spender], "Amount exceeds allowance");

        return _approve(msg.sender, _spender, allowance_[msg.sender][_spender].sub(_amount));
    }

    
    
    
    
    
    function canTransfer(address _from, address _to, uint _value)
        public view returns (bool)
    {
        return totalSupplyIsFixed
            && _from != address(0x0)
            && _to != address(0x0)
            && _value <= accounts[_from].balance
            && whitelist.isWhitelisted(_from)
            && whitelist.isWhitelisted(_to);
    }

    
    
    
    
    
    
    function canTransferFrom(address _spender, address _from, address _to, uint _value)
        public view returns (bool)
    {
        return canTransfer(_from, _to, _value) && _value <= allowance_[_from][_spender];
    }

    
    
    
    
    
    function transfer(address _to, uint _value) public returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(_value <= allowance_[_from][msg.sender], "Amount exceeds allowance");

        return _approve(_from, msg.sender, allowance_[_from][msg.sender].sub(_value))
            && _transfer(_from, _to, _value);
    }

    
    
    
    
    
    function _approve(address _from, address _spender, uint _value)
        internal
        onlyWhitelisted(_from)
        onlyWhenTotalSupplyIsFixed
        returns (bool)
    {
        allowance_[_from][_spender] = _value;

        emit Approval(_from, _spender, _value);

        return true;
    }

    
    
    
    
    
    function _transfer(address _from, address _to, uint _value)
        internal
        onlyWhitelisted(_from)
        onlyWhitelisted(_to)
        onlyWhenTotalSupplyIsFixed
        returns (bool)
    {
        require(_to != address(0x0), "Recipient is zero");
        require(_value <= accounts[_from].balance, "Amount exceeds balance");

        updateProfitShare(_from);
        updateProfitShare(_to);

        accounts[_from].balance = accounts[_from].balance.sub(_value);
        accounts[_to].balance = accounts[_to].balance.add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

}



pragma solidity 0.5.12;





contract StokrTokenFactory {

    function createNewToken(
        string memory name,
        string memory symbol,
        Whitelist whitelist,
        address profitDepositor,
        address profitDistributor,
        address tokenRecoverer
    )
        public
        returns (StokrToken)
    {
        StokrToken token = new StokrToken(
            name,
            symbol,
            whitelist,
            profitDepositor,
            profitDistributor,
            tokenRecoverer);

        token.transferOwnershipUnsafe(msg.sender);

        return token;
    }

}