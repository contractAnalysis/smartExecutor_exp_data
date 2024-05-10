pragma solidity 0.5.12;


contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}



contract DSPauseAbstract {
    function setOwner(address) public;
    
    function setAuthority(address) public;
    function setDelay(uint256) public;
    
    function plans(bytes32) public view returns (bool);
    
    function proxy() public view returns (address);
    
    function delay() public view returns (uint256);
    function plot(address, bytes32, bytes memory, uint256) public;
    function drop(address, bytes32, bytes memory, uint256) public;
    function exec(address, bytes32, bytes memory, uint256) public returns (bytes memory);
}



contract OsmAbstract {
    
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    
    function stopped() public view returns (uint256);
    
    function src() public view returns (address);
    
    function ONE_HOUR() public view returns (uint16);
    
    function hop() public view returns (uint16);
    
    function zzz() public view returns (uint64);
    struct Feed {
        uint128 val;
        uint128 has;
    }
    
    function cur() public view returns (uint128, uint128);
    
    function nxt() public view returns (uint128, uint128);
    
    function bud(address) public view returns (uint256);
    event LogValue(bytes32);
    function stop() external;
    function start() external;
    function change(address) external;
    function step(uint16) external;
    function void() external;
    function pass() public view returns (bool);
    function poke() external;
    function peek() external view returns (bytes32, bool);
    function peep() external view returns (bytes32, bool);
    function read() external view returns (bytes32);
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
}



contract OsmMomAbstract {
    
    function owner() public view returns (address);
    
    function authority() public view returns (address);
    
    function osms(bytes32) public view returns (address);
    function setOsm(bytes32, address) public;
    function setOwner(address) public;
    function setAuthority(address) public;
    function stop(bytes32) public;
}



contract JugAbstract {
    
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    struct Ilk {
        uint256 duty;
        uint256  rho;
    }
    
    function ilks(bytes32) public view returns (uint256, uint256);
    
    function vat() public view returns (address);
    
    function vow() public view returns (address);
    
    function base() public view returns (address);
    
    function ONE() public view returns (uint256);
    function init(bytes32) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function drip(bytes32) external returns (uint256);
}



contract PotAbstract {
    
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    
    function pie(address) public view returns (uint256);
    
    function Pie() public view returns (uint256);
    
    function dsr() public view returns (uint256);
    
    function chi() public view returns (uint256);
    
    function vat() public view returns (address);
    
    function vow() public view returns (address);
    
    function rho() public view returns (uint256);
    
    function live() public view returns (uint256);
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function cage() external;
    function drip() external returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
}



contract VatAbstract {
    
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    struct Ilk {
        uint256 Art;   
        uint256 rate;  
        uint256 spot;  
        uint256 line;  
        uint256 dust;  
    }
    struct Urn {
        uint256 ink;   
        uint256 art;   
    }
    
    function can(address, address) public view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    
    function urns(bytes32, address) public view returns (uint256, uint256);
    
    function gem(bytes32, address) public view returns (uint256);
    
    function dai(address) public view returns (uint256);
    
    function sin(address) public view returns (uint256);
    
    function debt() public view returns (uint256);
    
    function vice() public view returns (uint256);
    
    function Line() public view returns (uint256);
    
    function live() public view returns (uint256);
    function init(bytes32) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function cage() external;
    function slip(bytes32, address, int256) external;
    function flux(bytes32, address, address, uint256) external;
    function move(address, address, uint256) external;
    function frob(bytes32, address, address, address, int256, int256) external;
    function fork(bytes32, address, address, int256, int256) external;
    function grab(bytes32, address, address, address, int256, int256) external;
    function heal(uint256) external;
    function suck(address, address, uint256) external;
    function fold(bytes32, address, int256) external;
}



contract FlapAbstract {
    
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    struct Bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
    }
    
    function bids(uint256) public view returns (uint256);
    
    function vat() public view returns (address);
    
    
    function gem() public view returns (address);
    
    function ONE() public view returns (uint256);
    
    function beg() public view returns (uint256);
    
    function ttl() public view returns (uint48);
    
    function tau() public view returns (uint48);
    
    function kicks() public view returns (uint256);
    
    function live() public view returns (uint256);
    event Kick(uint256, uint256, uint256);
    function file(bytes32, uint256) external;
    function kick(uint256, uint256) external returns (uint256);
    function tick(uint256) external;
    function tend(uint256, uint256, uint256) external;
    function deal(uint256) external;
    function cage(uint256) external;
    function yank(uint256) external;
}



contract SaiMomAbstract {
    
    function tub() public view returns (address);
    
    function tap() public view returns (address);
    
    function vox() public view returns (address);
    function setCap(uint256) public;                  
    function setMat(uint256) public;                  
    function setTax(uint256) public;                  
    function setFee(uint256) public;                  
    function setAxe(uint256) public;                  
    function setTubGap(uint256) public;               
    function setPip(address) public;                  
    function setPep(address) public;                  
    function setVox(address) public;                  
    function setTapGap(uint256) public;               
    function setWay(uint256) public;                  
    function setHow(uint256) public;
    
    
    function authority() public view returns (address);
    
    function owner() public view returns (address);
    function setOwner(address) public;
    function setAuthority(address) public;
}


contract SpellAction is DSMath {
    uint256 constant RAD = 10 ** 45;
    address constant public PAUSE = 0xbE286431454714F511008713973d3B053A2d38f3;
    address constant public CHIEF = 0x9eF05f7F6deB616fd37aC3c959a2dDD25A54E4F5;
    address constant public OSM_MOM = 0x76416A4d5190d071bfed309861527431304aA14f;
    address constant public ETH_OSM = 0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763;
    address constant public BAT_OSM = 0xB4eb54AF9Cc7882DF0121d26c5b97E802915ABe6;
    address constant public VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address constant public JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant public POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address constant public FLAP = 0xdfE0fb1bE2a52CDBf8FB962D5701d7fd0902db9f;
    uint256 constant NEW_BEG = 1.02E18; 

    function execute() external {
        
        PotAbstract(POT).drip();
        JugAbstract(JUG).drip("ETH-A");
        JugAbstract(JUG).drip("BAT-A");

        
        VatAbstract(VAT).file("Line", mul(183000000, RAD));

        
        
        VatAbstract(VAT).file("ETH-A", "line", mul(150000000, RAD));

        

        
        
        
        
        PotAbstract(POT).file("dsr", 1000000002440418608258400030);

        
        

        
        
        FlapAbstract(FLAP).file("beg", NEW_BEG);

        
        OsmAbstract(ETH_OSM).rely(OSM_MOM);
        OsmAbstract(BAT_OSM).rely(OSM_MOM);
        OsmMomAbstract(OSM_MOM).setAuthority(CHIEF);
        OsmMomAbstract(OSM_MOM).setOsm("ETH-A", ETH_OSM);
        OsmMomAbstract(OSM_MOM).setOsm("BAT-A", BAT_OSM);
        DSPauseAbstract(PAUSE).setDelay(60 * 60 * 24);
    }
}

contract DssSpell20200221 is DSMath {
    DSPauseAbstract  public pause =
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
    address constant public SAIMOM = 0xF2C5369cFFb8Ea6284452b0326e326DbFdCb867C;
    uint256 constant public NEW_FEE = 1000000002877801985002875644; 
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    bool             public done;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
    }

    function schedule() public {
        require(eta == 0, "spell-already-scheduled");
        eta = add(now, DSPauseAbstract(pause).delay());
        pause.plot(action, tag, sig, eta);

        
        

        
        
        SaiMomAbstract(SAIMOM).setFee(NEW_FEE);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}