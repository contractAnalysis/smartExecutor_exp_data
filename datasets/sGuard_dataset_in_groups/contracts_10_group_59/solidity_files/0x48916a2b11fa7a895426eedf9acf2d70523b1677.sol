pragma solidity ^0.5.12;

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

contract SaiMomLike {
    function setCap(uint256) external;
    function setFee(uint256) external;
}

contract SaiConstants {
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAD = 10 ** 45;
    address constant public SAIMOM = 0xF2C5369cFFb8Ea6284452b0326e326DbFdCb867C;
    uint256 constant public SCDCAP = 30000000;
    uint256 constant public SCDFEE = 1000000003022265980097387650;
}

contract SpellAction is SaiConstants, DSMath {
    address constant public VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address constant public JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant public POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;

    function execute() external {
        
        PotAbstract(POT).drip();
        JugAbstract(JUG).drip("ETH-A");
        JugAbstract(JUG).drip("BAT-A");

        
        VatAbstract(VAT).file("SAI", "line", mul(SCDCAP, RAD));

        
        (,,,uint256 lineSAI,) = VatAbstract(VAT).ilks("SAI");    
        (,,,uint256 lineETH,) = VatAbstract(VAT).ilks("ETH-A");  
        (,,,uint256 lineBAT,) = VatAbstract(VAT).ilks("BAT-A");  

        uint256 LineVat = add(add(lineSAI, lineETH), lineBAT);
        VatAbstract(VAT).file("Line", LineVat);

        
        PotAbstract(POT).file("dsr", 1000000002659864411854984565);

        
        uint256 sf = 1000000002732676825177582095;

        
        JugAbstract(JUG).file("ETH-A", "duty", sf);

        
        JugAbstract(JUG).file("BAT-A", "duty", sf);
    }
}

contract DssJanuary31Spell is SaiConstants, DSMath {
    DSPauseAbstract  public pause =
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
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

        
        

        
        SaiMomLike(SAIMOM).setCap(mul(SCDCAP, WAD));

        
        SaiMomLike(SAIMOM).setFee(SCDFEE);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}