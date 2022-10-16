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



contract ICHAI {
    function balanceOf(address usr) external returns (uint);
    
    function transfer(address dst, uint wad) external returns (bool);

    function dai(address usr) external returns (uint wad);
    
    function dai(uint chai) external returns (uint wad);

    function join(address dst, uint wad) external;
}


interface ICERC20 {
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);
}


contract LexGrow is LexDAORole { 
    using SafeMath for uint256;
    
    
    
    address private daiToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IERC20 public dai = IERC20(daiToken);
    
    
    address private chaiToken = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;
    ICHAI public chai = ICHAI(chaiToken);
    
    
    address private vault = address(this);
    address payable public manager;
    uint8 public version = 2;
    uint256 public depositFee;
    uint256 public lxg; 
    string public emoji = "⚖️🌱⚔️";
    mapping (uint256 => Deposit) public deposit; 

    struct Deposit {  
        address client; 
        address provider;
        address compoundToken;
        uint256 amount;
        uint256 wrap;
        uint256 termination;
        uint256 index;
        string details; 
        bool dsr;
        bool disputed; 
        bool released;
    }
    	
    
    event Log(string, uint256); 
    event Registered(address indexed client, address indexed provider, uint256 indexed index);  
    event Released(uint256 indexed index); 
    event Disputed(uint256 indexed index, string indexed details); 
    event Resolved(address indexed resolver, uint256 indexed index, string indexed details); 
    event ManagerTransferred(address indexed manager, string indexed details);
    
    constructor () public {
        dai.approve(chaiToken, uint(-1));
        manager = msg.sender;
        depositFee = 0;
    } 
    
    
    function dealDepositDSR( 
        address provider,
        uint256 amount, 
        uint256 termination,
        string memory details) public payable {
        require(msg.value == depositFee);
	    uint256 index = lxg.add(1); 
	    lxg = lxg.add(1);
	    
	    dai.transferFrom(msg.sender, vault, amount); 
        uint256 balance = chai.balanceOf(vault);
        chai.join(vault, amount); 
                
            deposit[index] = Deposit( 
                msg.sender, 
                provider,
                chaiToken,
                amount, 
                chai.balanceOf(vault).sub(balance),
                termination,
                index,
                details,
                true,
                false, 
                false);
        
        address(manager).transfer(msg.value);
        
        emit Registered(msg.sender, provider, index); 
    }
    
    function dealDepositCompound( 
        address provider,
        address underlyingToken,
        address compoundToken,
        uint256 amount, 
        uint256 termination,
        string memory details) public payable returns (uint) {
        require(msg.value == depositFee);
	    
	    IERC20 uToken = IERC20(underlyingToken);
	    ICERC20 cToken = ICERC20(compoundToken);
	    
	    
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit Log("Exchange Rate (scaled up by 1e18)", exchangeRateMantissa);
        
        
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit Log("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);
	    
	    
        uToken.approve(compoundToken, amount);
        
        
	    uToken.transferFrom(msg.sender, vault, amount); 
	    uint256 balance = cToken.balanceOf(vault);
        uint mintResult = cToken.mint(amount); 
        
        uint256 index = lxg.add(1); 
	    lxg = lxg.add(1);
                
            deposit[index] = Deposit( 
                msg.sender, 
                provider,
                compoundToken,
                amount, 
                cToken.balanceOf(vault).sub(balance),
                termination,
                index,
                details, 
                false,
                false, 
                false);
        
        address(manager).transfer(msg.value);
        
        emit Registered(msg.sender, provider, index);
        
        return mintResult; 
    }
    
    function release(uint256 index) public { 
    	Deposit storage depos = deposit[index];
	    require(depos.disputed == false); 
	    require(depos.released == false); 
    	require(now <= depos.termination); 
    	require(msg.sender == depos.client); 

        if (depos.dsr == true) {
            chai.transfer(depos.provider, depos.wrap);
        } else {
            ICERC20 cToken = ICERC20(depos.compoundToken);
            cToken.transfer(depos.provider, depos.wrap);
        }
        
        depos.released = true; 
        
	    emit Released(index); 
    }
    
    function withdraw(uint256 index) public { 
    	Deposit storage depos = deposit[index];
        require(depos.disputed == false); 
        require(depos.released == false); 
    	require(now >= depos.termination); 
        
        if (depos.dsr == true) {
            chai.transfer(depos.client, depos.wrap);
        } else {
            ICERC20 cToken = ICERC20(depos.compoundToken);
            cToken.transfer(depos.client, depos.wrap);
        }
        
        depos.released = true; 
        
	    emit Released(index); 
    }
    
    
    function dispute(uint256 index, string memory details) public {
        Deposit storage depos = deposit[index]; 
        require(depos.released == false); 
        require(now <= depos.termination); 
        require(msg.sender == depos.client || msg.sender == depos.provider); 

	    depos.disputed = true; 
	    
	    emit Disputed(index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256 providerAward, string memory details) public onlyLexDAO {
        Deposit storage depos = deposit[index];
	    require(depos.disputed == true); 
	    require(depos.released == false); 
	    require(clientAward.add(providerAward) == depos.wrap); 
        require(msg.sender != depos.client); 
        require(msg.sender != depos.provider); 
        
        if (depos.dsr == true) {
            chai.transfer(depos.client, clientAward); 
            chai.transfer(depos.provider, providerAward);
        } else {
            ICERC20 cToken = ICERC20(depos.compoundToken);
            cToken.transfer(depos.client, clientAward);
            cToken.transfer(depos.provider, providerAward);
        }
    
	    depos.released = true; 
	    
	    emit Resolved(msg.sender, index, details);
    }
    
    
    function newDepositFee(uint256 weiAmount) public {
        require(msg.sender == manager);
        depositFee = weiAmount;
    }
    
    function transferManager(address payable newManager, string memory details) public {
        require(msg.sender == manager);
        manager = newManager; 
        
        emit ManagerTransferred(manager, details);
    }
}