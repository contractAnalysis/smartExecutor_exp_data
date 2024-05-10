pragma solidity 0.5.17;

interface IVat {
    function hope(address usr) external;
    function gem(bytes32, address) external view returns (uint);
    function dai(address) external view returns (uint);
}



pragma solidity 0.5.17;

interface ITokenJoin {
    function join(address usr, uint wad) external;
    function exit(address usr, uint wad) external;
}



pragma solidity 0.5.17;

contract IFlip {
    function tick(uint id) external;
    function tend(uint id, uint lot, uint bid) external;
    function dent(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}



pragma solidity 0.5.17;

contract IFlap {
    function tick(uint id) external;
    function tend(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}



pragma solidity 0.5.17;

contract IFlop {
    function tick(uint id) external;
    function dent(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}



pragma solidity 0.5.17;


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



pragma solidity 0.5.17;








contract ProxyActionsStorage {

    IVat public vat;
    IFlap public flap;
    IFlop public flop;

    mapping(bytes32 => IERC20) public tokens;
    mapping(bytes32 => uint) public decimals;
    mapping(bytes32 => bytes32) public ilks;
    mapping(bytes32 => ITokenJoin) public tokenJoins;
    mapping(bytes32 => IFlip) public flips;

    constructor() public {

        vat = IVat(address(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B));
        flap = IFlap(address(0xdfE0fb1bE2a52CDBf8FB962D5701d7fd0902db9f));
        flop = IFlop(address(0x4D95A049d5B0b7d32058cd3F2163015747522e99));

        tokens["ETH"] = IERC20(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)); 
        tokens["DAI"] = IERC20(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));
        tokens["BAT"] = IERC20(address(0x0D8775F648430679A709E98d2b0Cb6250d2887EF));
        tokens["USDC"] = IERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
        tokens["MKR"] = IERC20(address(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2));

        decimals["ETH"] = 18;
        decimals["BAT"] = 18;
        decimals["USDC"] = 6;

        ilks["ETH"] = "ETH-A";
        ilks["BAT"] = "BAT-A";
        ilks["USDC"] = "USDC-A";

        tokenJoins["ETH"] = ITokenJoin(address(0x2F0b23f53734252Bda2277357e97e1517d6B042A));
        tokenJoins["DAI"] = ITokenJoin(address(0x9759A6Ac90977b93B58547b4A71c78317f391A28));
        tokenJoins["BAT"] = ITokenJoin(address(0x3D0B1912B66114d4096F48A8CEe3A56C231772cA));
        tokenJoins["USDC"] = ITokenJoin(address(0xA191e578a6736167326d05c119CE0c90849E84B7));

        flips["ETH"] = IFlip(address(0xd8a04F5412223F513DC55F839574430f5EC15531));
        flips["BAT"] = IFlip(address(0xaA745404d55f88C108A28c86abE7b5A1E7817c07));
        flips["USDC"] = IFlip(address(0xE6ed1d09a19Bd335f051d78D5d22dF3bfF2c28B1));
    }
}