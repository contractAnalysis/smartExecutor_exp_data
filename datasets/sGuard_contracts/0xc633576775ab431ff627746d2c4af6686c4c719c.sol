pragma solidity ^0.5.12;

library Math {
    
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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
    function balanceOf   (address)                external view returns (uint256);
    function approve     (address, uint256)       external      returns (bool);
    function transferFrom(address, address, uint) external      returns (bool);
    function transfer    (address, uint256)       external      returns (bool);
}

interface IGateway {
    function mint(bytes32 _pHash, uint256 _amount, bytes32 _nHash, bytes calldata _sig) external returns (uint256);
    function burn(bytes calldata _to, uint256 _amount) external returns (uint256);
}

interface IGatewayRegistry {
    function getGatewayBySymbol(string calldata _tokenSymbol) external view returns (IGateway);
    function getGatewayByToken(address  _tokenAddress) external view returns (IGateway);
    function getTokenBySymbol(string calldata _tokenSymbol) external view returns (IERC20);
}

interface ICurveExchange {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
    function get_dy(int128, int128 j, uint256 dx) external view returns (uint256);
}

contract DirectBTCProxy {

    function borrow(
        address _owner, 
        int     _dink,  
        int     _dart   
    ) external;

    function repay(
        address _owner, 
        int     _dink,  
        int     _dart   
    ) external;
}

contract WBTCCDPProxy {
    using SafeMath for uint256;

    IGatewayRegistry public registry;
    IERC20           public dai;
    IERC20           public wbtc;
    IERC20           public renbtc;
    DirectBTCProxy   public directProxy;
    ICurveExchange   public exchange; 

    mapping (address => bytes) btcAddrs;

    constructor(
        address _registry,
        address _dai,
        address _wbtc,
        address _directProxy,
        ICurveExchange _exchange
    ) public {
        registry    = IGatewayRegistry(_registry);
        dai         = IERC20(_dai);
        wbtc        = IERC20(_wbtc);
        renbtc      = registry.getTokenBySymbol('BTC');
        directProxy = DirectBTCProxy(_directProxy);
        exchange    = ICurveExchange(_exchange);
        
        
        require(wbtc.approve(address(exchange), uint256(-1)));
        require(renbtc.approve(address(exchange), uint256(-1)));
    }

    
    function mintDai(
        
        uint256     _dart,
        bytes calldata _btcAddr,
        uint256 _minWbtcAmount,

        
        uint256        _amount, 
        bytes32        _nHash,  
        bytes calldata _sig     
    ) external {
        
        
        
        
        uint256 amount = registry.getGatewayBySymbol("BTC").mint(
            keccak256(abi.encode(msg.sender, _dart, _btcAddr, _minWbtcAmount)), 
            _amount, 
            _nHash, 
            _sig
        );
        
        
        uint256 proceeds = exchange.get_dy(0, 1, amount);
        
        
        if (proceeds >= _minWbtcAmount) {
            uint256 startWbtcBalance = wbtc.balanceOf(address(this));
            exchange.exchange(0, 1, amount, _minWbtcAmount);
            uint256 wbtcBought = wbtc.balanceOf(address(this)).sub(startWbtcBalance);

            require(
                wbtc.transfer(address(directProxy), wbtcBought),
                "err: transfer failed"
            );

            directProxy.borrow(
                msg.sender,
                int(wbtcBought * (10 ** 10)),
                int(_dart)
            );

            btcAddrs[msg.sender] = _btcAddr;
        } else {
            
            renbtc.transfer(msg.sender, amount);
        }
    }

    
    function burnDai(
        
        uint256 _dink,  
        uint256 _dart,   
        uint256 _minRenbtcAmount
    ) external {
        
        require(
            dai.transferFrom(msg.sender, address(this), _dart),
            "err: transferFrom dai"
        );

        
        require(
            dai.transfer(address(directProxy), _dart),
            "err: transfer dai"
        );

        
        directProxy.repay(
            msg.sender,
            int(_dink) * (10 ** 10),
            int(_dart)
        );
        
        
        uint256 startRenbtcBalance = renbtc.balanceOf(address(this));
        exchange.exchange(1, 0, _dink, _minRenbtcAmount);
        uint256 endRenbtcBalance = renbtc.balanceOf(address(this));
        uint256 renbtcBought = endRenbtcBalance.sub(startRenbtcBalance);

        
        
        
        
        registry.getGatewayBySymbol("BTC").burn(btcAddrs[msg.sender], renbtcBought);
    }
}