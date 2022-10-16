pragma solidity 0.5.14;



contract Context {
    
    
    constructor () internal { }

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

    event LexDAOAdded(address indexed account);
    event LexDAORemoved(address indexed account);

    Roles.Role private _lexDAOs;
    
    constructor () internal {
        _addLexDAO(_msgSender());
    }

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
        emit LexDAOAdded(account);
    }

    function _removeLexDAO(address account) internal {
        _lexDAOs.remove(account);
        emit LexDAORemoved(account);
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


contract IChai {
    function transfer(address dst, uint wad) external returns (bool);
    
    function move(address src, address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
    function approve(address usr, uint wad) external returns (bool);
    function balanceOf(address usr) external returns (uint);

    
    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

    function dai(address usr) external returns (uint wad);
    function dai(uint chai) external returns (uint wad);

    
    function join(address dst, uint wad) external;

    
    function exit(address src, uint wad) public;

    
    function draw(address src, uint wad) external returns (uint chai);
}


contract DaiSavingsEscrow is LexDAORole {  
    using SafeMath for uint256;
    
    
    address private daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IERC20 public dai = IERC20(daiAddress);
    
    
    address private chaiAddress = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;
    IChai public chai = IChai(chaiAddress);
    
    
    address private vault = address(this);
    address public proposedManager;
    address payable public manager;
    uint8 public version = 1;
    uint256 public escrowFee;
    uint256 public dse; 
    string public emoji = "⚖️🔐⚔️";
    mapping (uint256 => Escrow) public escrow; 

    struct Escrow {  
        address client; 
        address provider;
        uint256 payment;
        uint256 wrap;
        uint256 termination;
        uint256 index;
        string details; 
        bool disputed; 
        bool released;
    }
    	
    
    event Registered(address indexed client, address indexed provider, uint256 indexed index);  
    event Released(uint256 indexed index); 
    event Disputed(uint256 indexed index, string indexed details); 
    event Resolved(uint256 indexed index, string indexed details); 
    event ManagerProposed(address indexed proposedManager, string indexed details);
    event ManagerTransferred(address indexed manager, string indexed details);
    
    constructor () public {
        dai.approve(chaiAddress, uint(-1));
        manager = msg.sender;
        escrowFee = 0;
    } 
    
    
    function register( 
        address provider,
        uint256 payment, 
        uint256 termination,
        string memory details) public payable {
        require(msg.value == escrowFee);
	    uint256 index = dse.add(1); 
	    dse = dse.add(1);
	    
	    dai.transferFrom(msg.sender, vault, payment); 
        uint256 balance = chai.balanceOf(vault);
        chai.join(vault, payment); 
                
            escrow[index] = Escrow( 
                msg.sender, 
                provider,
                payment, 
                chai.balanceOf(vault).sub(balance),
                termination,
                index,
                details, 
                false, 
                false);
        
        address(manager).transfer(msg.value);
        
        emit Registered(msg.sender, provider, index); 
    }
    
    function release(uint256 index) public { 
    	Escrow storage escr = escrow[index];
	    require(escr.disputed == false); 
    	require(now <= escr.termination); 
    	require(msg.sender == escr.client); 

    	chai.transfer(escr.provider, escr.wrap); 
        
        escr.released = true; 
        
	    emit Released(index); 
    }
    
    function withdraw(uint256 index) public { 
    	Escrow storage escr = escrow[index];
        require(escr.disputed == false); 
    	require(now >= escr.termination); 
    	require(msg.sender == escr.client); 
        
    	chai.transfer(escr.client, escr.wrap); 
        
        escr.released = true; 
        
	    emit Released(index); 
    }
    
    
    function dispute(uint256 index, string memory details) public {
        Escrow storage escr = escrow[index]; 
        require(escr.released == false); 
        require(now <= escr.termination); 
        require(msg.sender == escr.client || msg.sender == escr.provider); 

	    escr.disputed = true; 
	    
	    emit Disputed(index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256 providerAward, string memory details) public onlyLexDAO {
        Escrow storage escr = escrow[index];
	    uint256 lexFee = escr.wrap.div(20); 
	    require(escr.disputed == true); 
	    require(clientAward.add(providerAward) == escr.wrap.sub(lexFee)); 
        require(msg.sender != escr.client || msg.sender != escr.provider); 
        
        chai.transfer(escr.client, clientAward); 
        chai.transfer(escr.provider, providerAward); 
    	chai.transfer(msg.sender, lexFee); 
    	
	    escr.released = true; 
	    
	    emit Resolved(index, details);
    }
    
    
    function newEscrowFee(uint256 weiAmount) public {
        require(msg.sender == manager);
        escrowFee = weiAmount;
    }
    
    function proposeManager(address _proposedManager, string memory details) public {
        require(msg.sender == manager);
        proposedManager = _proposedManager; 
        
        emit ManagerProposed(proposedManager, details);
    }
    
    function transferManager(string memory details) public {
        require(msg.sender == proposedManager);
        manager = msg.sender; 
        
        emit ManagerTransferred(manager, details);
    }
}