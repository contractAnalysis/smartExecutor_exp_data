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



interface ICERC20 {
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);
}


contract LexLocker is Context { 
    using SafeMath for uint256;
    
    
    address private judgeToken;
    IERC20 public judge = IERC20(judgeToken);

    
    
    address private daiToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IERC20 public dai = IERC20(daiToken);
    
    address private cDAItoken = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    ICERC20 public cDAI = ICERC20(cDAItoken);
    
    
    
    address private usdcToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    IERC20 public usdc = IERC20(usdcToken);
    
    address private cUSDCtoken = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    ICERC20 public cUSDC = ICERC20(cUSDCtoken);
    
    
    address payable public lexDAO;
    address private vault = address(this);
    uint8 public version = 1;
    uint256 public depositFee;
    uint256 public lxl; 
    string public emoji = "⚖️🌱⚔️";
    mapping (uint256 => Deposit) public deposit; 

    struct Deposit {  
        address client; 
        address provider;
        uint256 amount;
        uint256 index;
        uint256 termination;
        uint256 wrap;
        string details; 
        bool dai;
        bool locked; 
        bool released;
    }
    	
    
    event Log(string, uint256); 
    event Registered(address indexed client, address indexed provider, uint256 indexed index);  
    event Released(uint256 indexed index); 
    event Locked(uint256 indexed index, string indexed details); 
    event Resolved(address indexed resolver, uint256 indexed index, string indexed details); 
    
    constructor (address _judgeToken, address payable _lexDAO) public {
        dai.approve(cDAItoken, uint(-1));
        usdc.approve(cUSDCtoken, uint(-1));
        depositFee = 0.001 ether;
        judgeToken = _judgeToken;
        lexDAO = _lexDAO;
    } 
    
    
    function depositDAI( 
        address provider,
        uint256 amount, 
        uint256 termination,
        string memory details) public payable returns (uint) {
        require(msg.value == depositFee);
	    
	    
        uint256 exchangeRateMantissa = cDAI.exchangeRateCurrent();
        emit Log("Exchange Rate: (scaled up by 1e18)", exchangeRateMantissa);
        
        
        uint256 supplyRateMantissa = cDAI.supplyRatePerBlock();
        emit Log("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);
	    
	    dai.transferFrom(_msgSender(), vault, amount); 
	    uint256 balance = cDAI.balanceOf(vault);
        uint mintResult = cDAI.mint(amount); 
        
        uint256 index = lxl.add(1); 
	    lxl = lxl.add(1);
                
            deposit[index] = Deposit( 
                _msgSender(), 
                provider,
                amount,
                index,
                termination,
                cDAI.balanceOf(vault).sub(balance),
                details, 
                true,
                false, 
                false);
        
        address(lexDAO).transfer(msg.value);
        
        emit Registered(_msgSender(), provider, index); 
        
        return mintResult;
    }
    
    function depositUSDC( 
        address provider,
        uint256 amount, 
        uint256 termination,
        string memory details) public payable returns (uint) {
        require(msg.value == depositFee);
	    
	    
        uint256 exchangeRateMantissa = cUSDC.exchangeRateCurrent();
        emit Log("Exchange Rate: (scaled up by 1e18)", exchangeRateMantissa);
        
        
        uint256 supplyRateMantissa = cUSDC.supplyRatePerBlock();
        emit Log("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);
	    
	    usdc.transferFrom(_msgSender(), vault, amount); 
	    uint256 balance = cUSDC.balanceOf(vault);
        uint mintResult = cUSDC.mint(amount); 
        
        uint256 index = lxl.add(1); 
	    lxl = lxl.add(1);
                
            deposit[index] = Deposit( 
                _msgSender(), 
                provider,
                amount,
                index,
                termination,
                cUSDC.balanceOf(vault).sub(balance),
                details, 
                false,
                false, 
                false);
        
        address(lexDAO).transfer(msg.value);
        
        emit Registered(_msgSender(), provider, index);
        
        return mintResult; 
    }
    
    function release(uint256 index) public { 
    	Deposit storage depos = deposit[index];
	    require(depos.locked == false); 
	    require(depos.released == false); 
    	require(now <= depos.termination); 
    	require(_msgSender() == depos.client); 

        if (depos.dai == true) {
            cDAI.transfer(depos.provider, depos.wrap);
        } else {
            cUSDC.transfer(depos.provider, depos.wrap);
        }
        
        depos.released = true; 
        
	    emit Released(index); 
    }
    
    function withdraw(uint256 index) public { 
    	Deposit storage depos = deposit[index];
        require(depos.locked == false); 
        require(depos.released == false); 
    	require(now >= depos.termination); 
        
        if (depos.dai == true) {
            cDAI.transfer(depos.client, depos.wrap);
        } else {
            cUSDC.transfer(depos.client, depos.wrap);
        }
        
        depos.released = true; 
        
	    emit Released(index); 
    }
    
    
    function lock(uint256 index, string memory details) public {
        Deposit storage depos = deposit[index]; 
        require(depos.released == false); 
        require(now <= depos.termination); 
        require(_msgSender() == depos.client || _msgSender() == depos.provider); 

	    depos.locked = true; 
	    
	    emit Locked(index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256 providerAward, string memory details) public {
        Deposit storage depos = deposit[index];
	    require(depos.locked == true); 
	    require(depos.released == false); 
	    require(clientAward.add(providerAward) == depos.wrap); 
	    require(judge.balanceOf(_msgSender()) >= 1, "judgeToken balance insufficient");
	    require(_msgSender() != depos.client || _msgSender() != depos.provider);
        
        if (depos.dai == true) {
            cDAI.transfer(depos.client, clientAward); 
            cDAI.transfer(depos.provider, providerAward);
        } else {
            cUSDC.transfer(depos.client, clientAward); 
            cUSDC.transfer(depos.provider, providerAward);
        }
    	
	    depos.released = true; 
	    
	    emit Resolved(_msgSender(), index, details);
    }
    
    
    modifier onlyLexDAO () {
        require(_msgSender() == lexDAO);
        _;
    }
    
    function newDepositFee(uint256 _depositFee) public onlyLexDAO {
        depositFee = _depositFee;
    }
    
    function newJudgeToken(address _judgeToken) public onlyLexDAO {
        judgeToken = _judgeToken;
    }
    
    function newLexDAO(address payable _lexDAO) public onlyLexDAO {
        lexDAO = _lexDAO;
    }
}