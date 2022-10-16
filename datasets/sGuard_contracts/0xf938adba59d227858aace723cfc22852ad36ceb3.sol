pragma solidity 0.5.17;


contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract LexDAORole is Context {
    using Roles for Roles.Role;

    event LexDAOadded(address indexed account);
    event LexDAOremoved(address indexed account);

    Roles.Role private _lexDAOs;

    modifier onlyLexDAO() {
        require(isLexDAO(_msgSender()), "LexDAORole: caller does not have the LexDAO role");
        _;
    }

    function isLexDAO(address account) public view returns (bool) {
        return _lexDAOs.has(account);
    }

    function addLexDAO(address account) public onlyLexDAO {
        _addLexDAO(account);
    }

    function renounceLexDAO() public {
        _removeLexDAO(_msgSender());
    }

    function _addLexDAO(address account) internal {
        _lexDAOs.add(account);
        emit LexDAOadded(account);
    }

    function _removeLexDAO(address account) internal {
        _lexDAOs.remove(account);
        emit LexDAOremoved(account);
    }
}

contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


contract Pausable is PauserRole {
    
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
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }
}


contract ERC20Burnable is ERC20 {
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    
    function burnFrom(address account, uint256 amount) public {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


contract ERC20Capped is ERC20 {
    uint256 private _cap;

    
    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { 
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
    }
}


contract ERC20Mintable is MinterRole, ERC20 {
    
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}


contract ERC20Pausable is Pausable, ERC20 {
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}


contract LexArt is LexDAORole, ERC20Burnable, ERC20Capped, ERC20Mintable, ERC20Pausable {

    uint256 public periodDuration = 86400; 

    
    
    address public buyer; 
    string public artworkHash; 
    string public certificateHash; 
    uint8 public ownerOffered; 
    uint256 public transactionValue; 
    uint256 public totalRoyaltyPayout; 


    
    struct Owner {
        address payable ownerAddress;
        uint8 royalties;
        uint256 royaltiesReceived;
        uint8 gifted; 
    }

    uint8 public startingRoyalties = 10; 
    uint8 public ownerCount = 0; 
    mapping(uint256 => Owner) public owners; 


    
    struct License {
        
        address licensee;
        uint256 licenseFee;
        string licenseDocument;
        uint8 licensePeriodLength; 

        
        uint256 licenseStartTime;
        uint256 licenseEndTime;
        uint8 licensePeriodLengthReached; 

        
        uint8 licenseOffered; 
        uint8 licenseCompleted; 
        uint8 licenseTerminated; 
        string licenseReport; 
        string terminationDetail; 
    }

    uint8 public licenseCount = 0; 
    mapping(uint256 => License) public licenses; 


    
    event LexDAOtransferred(string indexed details);
    event ArtworkUpdated(string indexed _artworkHash);
    event CertificateUpdated(string indexed _certificatekHash);
    event LicenseCreated(address _licensee, string indexed _licenseDocument, uint8 _licenseDuration, uint256 _licenseStartTime);

    constructor (
        string memory name,
        string memory symbol,
        string memory _artworkHash,
        string memory _certificateHash,
        address payable _owner,
        address _lexDAO) public
        ERC20(name, symbol)
        ERC20Capped(1) {
        artworkHash = _artworkHash;
        certificateHash = _certificateHash;

        owners[ownerCount].ownerAddress = _owner;
        owners[ownerCount].royalties = startingRoyalties;

	    _addLexDAO(_lexDAO);
        _addMinter(owners[ownerCount].ownerAddress);
        _addPauser(_lexDAO);
        _mint(owners[ownerCount].ownerAddress, 1);
        _setupDecimals(0);
    }

    function giftLexART(address payable newOwner) public payable {
        require(msg.sender == owners[ownerCount].ownerAddress, "You do not currently own this Art!");
        require(newOwner != owners[ownerCount].ownerAddress, "Owner cannot gift to herself!");

        _transfer(owners[ownerCount].ownerAddress, newOwner, 1);

        ownerCount += 1;
        owners[ownerCount].ownerAddress = newOwner;
        owners[ownerCount].royalties = decayRoyalties(owners[ownerCount - 1].royalties);
        owners[ownerCount].gifted = 1;
    }

    function decayRoyalties(uint8 royalties) private view returns (uint8) {
        if (royalties <= startingRoyalties) {
            if (royalties > 0) {
                royalties = royalties - 1;
                return royalties;
            }
        }
    }

    
    function makeOffer(address _buyer, uint256 _transactionValue) public {
        require(msg.sender == owners[ownerCount].ownerAddress, "You are not the owner!");
        require(_buyer != owners[ownerCount].ownerAddress, "Owner cannot be a buyer!");
        require(_transactionValue != 0, "Transaction value cannot be 0!");

        transactionValue = _transactionValue;
        buyer = _buyer;
        ownerOffered = 1;
    }

    
    function distributeRoyalties(uint256 _transactionValue) private returns (uint256) {
        uint256 totalPayout = _transactionValue.div(100);
        uint256 royaltyPayout;

        
        for (uint256 i = 0; i <= ownerCount; i++) {
            uint256 eachPayout;

            eachPayout = totalPayout.mul(owners[i].royalties);
            royaltyPayout += eachPayout;

            owners[i].ownerAddress.transfer(eachPayout);
            owners[i].royaltiesReceived += eachPayout;
        }
        return royaltyPayout;
    }

    
    function acceptOffer() public payable {
        require(msg.sender == buyer, "You are not the buyer to accept owner's offer!");
        require(msg.value == transactionValue, "Incorrect payment amount!");
        require(ownerOffered == 1, "Owner has not made any offer!");

        
        uint256 royaltyPayout = distributeRoyalties(transactionValue);

        
        totalRoyaltyPayout += royaltyPayout;

        
        owners[ownerCount].ownerAddress.transfer(transactionValue - royaltyPayout);
        _transfer(owners[ownerCount].ownerAddress, buyer, 1);

        
        ownerCount += 1;
        owners[ownerCount].ownerAddress = msg.sender;
        owners[ownerCount].royalties = decayRoyalties(owners[ownerCount - 1].royalties);
        owners[ownerCount].gifted = 0;

        
        ownerOffered = 0;
    }

    
    function createLicense(
        address _licensee,
        uint256 _licenseFee,
        string memory _licenseDocument,
        uint8 _licensePeriodLength) public {
        require(msg.sender == owners[0].ownerAddress, "You are not the minter-owner!");
        require(_licensee != owners[0].ownerAddress, "Mintor-owner doesn't need a license!");
        require(_licensee != address(0), "Licensee zeroed!");
        require(_licensePeriodLength != 0, "License is set to 0 days!");

        License memory license = License({
            licensee : _licensee,
            licenseFee : _licenseFee,
            licenseDocument : _licenseDocument,
            licensePeriodLength : _licensePeriodLength,
            licenseStartTime : 0,
            licenseEndTime : 0,
            licensePeriodLengthReached : 0,
            licenseOffered : 1,
            licenseCompleted : 0,
            licenseTerminated : 0,
            licenseReport : "",
            terminationDetail : ""
        });

        licenses[licenseCount] = license;
        emit LicenseCreated(licenses[licenseCount].licensee, licenses[licenseCount].licenseDocument, licenses[licenseCount].licensePeriodLength, licenses[licenseCount].licenseStartTime);

        licenseCount += 1;
    }

    // designated licensee can accept license
    function acceptLicense(uint256 _licenseCount) public payable {
        require(msg.sender == licenses[_licenseCount].licensee, "Not licensee!");
        require(msg.value == licenses[_licenseCount].licenseFee, "Licensee fee incorrect!");
        require(licenses[_licenseCount].licenseOffered == 1, "Cannot accept offer never created or already claimed!");

        // record time of acceptance... maybe connect LexGrow for escrow?
        licenses[_licenseCount].licenseStartTime = now;

        // license contract formed and so license offer is no longer active
        licenses[_licenseCount].licenseOffered = 0;

        // licensee pays licensee fee
        owners[0].ownerAddress.transfer(msg.value);
    }

    // licensee can complete active licenses
    function completeLicense(uint256 _licenseCount, string memory _licenseReport) public payable {
        require(msg.sender == licenses[_licenseCount].licensee, "Not licensee!");
        require(msg.value > 0, "Cannot complete a license without paying!"); // is this needed??????????
        require(licenses[_licenseCount].licenseOffered == 0, "Cannot complete a license that is pending acceptance!");
        require(licenses[_licenseCount].licenseTerminated == 0, "Cannot complete a license that has been terminated!");

        licenses[_licenseCount].licenseReport = _licenseReport;
        owners[0].ownerAddress.transfer(msg.value);
        licenses[_licenseCount].licenseCompleted = 1;
        licenses[_licenseCount].licenseEndTime = now;

        // Record whether the license has lapsed
        getCurrentPeriod(_licenseCount) > licenses[_licenseCount].licensePeriodLength ? licenses[_licenseCount].licensePeriodLengthReached = 1 : licenses[_licenseCount].licensePeriodLengthReached = 0;
    }

    // creator can terminate active licenses
    function terminateLicense(uint256 _licenseCount, string memory _terminationDetail) public {
        require(msg.sender == owners[0].ownerAddress, "You are not the creator!");
        require(licenses[_licenseCount].licensee != address(0), "License does not have a licensee!");
        require(licenses[_licenseCount].licenseOffered == 0, "Cannot terminate a license not accepted by licensee!");
        require(licenses[_licenseCount].licenseCompleted == 0, "Cannot terminate a license that has been completed!");

        licenses[_licenseCount].terminationDetail = _terminationDetail;
        licenses[_licenseCount].licenseTerminated = 1;
        licenses[_licenseCount].licenseEndTime = now;

        // Record whether the license has lapsed
        getCurrentPeriod(_licenseCount) > licenses[_licenseCount].licensePeriodLength ? licenses[_licenseCount].licensePeriodLengthReached = 1 : licenses[_licenseCount].licensePeriodLengthReached = 0;
    }

    function getCurrentPeriod(uint256 _licenseCount) public view returns (uint256) {
        return now.sub(licenses[_licenseCount].licenseStartTime).div(periodDuration);
    }

     /***************
    LEXDAO FUNCTIONS
    ***************/

    // DAO can vote to effectuate transfer of this token
    function lexDAOtransfer(string memory details, address currentOwner, address newOwner) public onlyLexDAO {
        _transfer(currentOwner, newOwner, 1);
        emit LexDAOtransferred(details);
    }

    // DAO can vote to burn this token
    function lexDAOburn(string memory details, address currentOwner) public onlyLexDAO {
        _burn(currentOwner, 1);
        emit LexDAOtransferred(details);
    }

    // DAO can vote to update artwork hash
    function updateArtworkHash(string memory _artworkHash) public onlyLexDAO {
        artworkHash = _artworkHash; // pauser admin(s) adjust token stamp
        emit ArtworkUpdated(_artworkHash);
    }

    // DAO can vote to update certificate hash
    function updateCertificateHash(string memory _certificateHash) public onlyLexDAO {
        certificateHash = _certificateHash;
        emit CertificateUpdated(_certificateHash);
    }
}

/**
 * @dev Factory pattern to create new token contracts with LexARTDAO governance.
 */
contract LexArtFactory is Context {

    string public factoryName;
    uint256 public factoryFee = 5000000000000000; // default - 0.005 Ξ
    address payable public lexDAO = 0x9455b183F9a6f716F8F46E5C6856A9775e40240d; // WARNING: This is a LexART DAO temp account.
    address payable public factoryOwner; // owner of LexArtFactory

    address[] public arts;

    event FactoryFeeUpdated(uint256 indexed _factoryFee);
    event FactoryNameUpdated(string indexed _factoryName);
    event FactoryOwnerUpdated(address indexed _factoryOwner);
    event LexDAOpaid(string indexed details, uint256 indexed payment, address indexed sender);
    event LexDAOupdated(address indexed lexDAO);
    event LexTokenDeployed(address indexed LT, address indexed owner, bool indexed _lexDAOgoverned);

    constructor (string memory _factoryName) public {
        factoryName = _factoryName;
        factoryOwner = lexDAO;
    }

    function newLexArt(
        string memory name,
        string memory symbol,
        string memory artworkHash,
        string memory certificateHash
        ) payable public {

        require(msg.sender == factoryOwner, "Only factory owners can mint Art!");
	    require(msg.value == factoryFee, "Factory Fee not attached!");

        LexArt LA = new LexArt (
            name,
            symbol,
            artworkHash,
            certificateHash,
            factoryOwner,
            lexDAO);

        arts.push(address(LA));
        address(lexDAO).transfer(msg.value);
    }

    function getLexArtCount() public view returns (uint256 LexArtCount) {
        return arts.length;
    }

    /***************
    LEXDAO FUNCTIONS
    ***************/
    modifier onlyLexDAO () {
        require(_msgSender() == lexDAO, "caller not lexDAO");
        _;
    }

    function updateFactoryFee(uint256 _factoryFee) public onlyLexDAO {
       factoryFee = _factoryFee;
       emit FactoryFeeUpdated(_factoryFee);
    }

    function updateFactoryName(string memory _factoryName) public {
        require(msg.sender == factoryOwner, "Not factory owner!");
        factoryName = _factoryName;
        emit FactoryNameUpdated(_factoryName);
    }

    function assignFactoryOwner(address payable _factoryOwner) public onlyLexDAO {
        require(msg.sender == lexDAO, "Not factory owner!");
        factoryOwner = _factoryOwner;
        emit FactoryOwnerUpdated(_factoryOwner);
    }

    function updateLexDAO(address payable __lexDAO) public onlyLexDAO {
        lexDAO = __lexDAO;
        emit LexDAOupdated(lexDAO);
    }
}