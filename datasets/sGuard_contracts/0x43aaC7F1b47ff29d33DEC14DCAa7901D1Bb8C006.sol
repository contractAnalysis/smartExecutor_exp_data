pragma solidity 0.5.12;


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


contract VatAbstract {
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
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


contract CatAbstract {
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) public view returns (address, uint256, uint256);
    function live() public view returns (uint256);
    function vat() public view returns (address);
    function vow() public view returns (address);
    function file(bytes32, address) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, address) external;
    function bite(bytes32, address) external returns (uint256);
    function cage() external;
}


contract JugAbstract {
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) public view returns (uint256, uint256);
    function vat() public view returns (address);
    function vow() public view returns (address);
    function base() public view returns (address);
    function init(bytes32) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function drip(bytes32) external returns (uint256);
}


contract FlipAbstract {
    function wards(address) public view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function bids(uint256) public view returns (uint256, uint256, address, uint48, uint48, address, address, uint256);
    function vat() public view returns (address);
    function ilk() public view returns (bytes32);
    function beg() public view returns (uint256);
    function ttl() public view returns (uint48);
    function tau() public view returns (uint48);
    function kicks() public view returns (uint256);
    function file(bytes32, uint256) external;
    function kick(address, address, uint256, uint256, uint256) public returns (uint256);
    function tick(uint256) external;
    function tend(uint256, uint256, uint256) external;
    function dent(uint256, uint256, uint256) external;
    function deal(uint256) external;
    function yank(uint256) external;
}


contract SpotAbstract {
    function wards(address) public view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) public view returns (address, uint256);
    function vat() public view returns (address);
    function par() public view returns (uint256);
    function live() public view returns (uint256);
    function file(bytes32, bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function poke(bytes32) external;
    function cage() external;
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


contract FlipperMomAbstract {
    function owner() public returns (address);
    function setOwner(address) external;
    function authority() public returns (address);
    function setAuthority(address) external;
    function cat() public returns (address);
    function rely(address) external;
    function deny(address) external;
}

contract SpellAction {
    
    
    string constant public description = "2020-05-29 MakerDAO Executive Spell";

    
    
    
    
    
    
    address constant public MCD_VAT             = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address constant public MCD_CAT             = 0x78F2c2AF65126834c51822F56Be0d7469D7A523E;
    address constant public MCD_JUG             = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant public MCD_POT             = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;

    address constant public MCD_SPOT            = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
    address constant public MCD_END             = 0xaB14d3CE3F733CACB76eC2AbE7d2fcb00c99F3d5;
    address constant public FLIPPER_MOM         = 0x9BdDB99625A711bf9bda237044924E34E8570f75;

    
    address constant public MCD_JOIN_USDC_B     = 0x2600004fd1585f7270756DDc88aD9cfA10dD0428;
    address constant public PIP_USDC            = 0x77b68899b99b686F415d074278a9a16b336085A0;
    address constant public MCD_FLIP_USDC_B     = 0xec25Ca3fFa512afbb1784E17f1D414E16D01794F;

    
    address constant public MCD_JOIN_TUSD_A     = 0x4454aF7C8bb9463203b66C816220D41ED7837f44;
    address constant public PIP_TUSD            = 0xeE13831ca96d191B688A670D47173694ba98f1e5;
    address constant public MCD_FLIP_TUSD_A     = 0xba3f6a74BD12Cf1e48d4416c7b50963cA98AfD61;
    
    
    uint256 constant public THOUSAND            = 10 ** 3;
    uint256 constant public MILLION             = 10 ** 6;
    uint256 constant public WAD                 = 10 ** 18;
    uint256 constant public RAY                 = 10 ** 27;
    uint256 constant public RAD                 = 10 ** 45;

    
    
    
    
    
    
    uint256 constant public ZERO_PCT_RATE       = 1000000000000000000000000000;
    uint256 constant public FIFTY_PCT_RATE      = 1000000012857214317438491659;

    function execute() external {

        PotAbstract(MCD_POT).drip();
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");
        JugAbstract(MCD_JUG).drip("USDC-A");
        JugAbstract(MCD_JUG).drip("WBTC-A");

        
        

        
        
        VatAbstract(MCD_VAT).file("Line", 165 * MILLION * RAD);

        
        

        
        bytes32 usdcBIlk = "USDC-B";

        
        VatAbstract(MCD_VAT).init(usdcBIlk);
        JugAbstract(MCD_JUG).init(usdcBIlk);

        
        VatAbstract(MCD_VAT).rely(MCD_JOIN_USDC_B);

        
        SpotAbstract(MCD_SPOT).file(usdcBIlk, "pip", PIP_USDC);

        
        CatAbstract(MCD_CAT).file(usdcBIlk, "flip", MCD_FLIP_USDC_B);

        
        
        FlipAbstract(MCD_FLIP_USDC_B).rely(MCD_CAT);

        
        FlipAbstract(MCD_FLIP_USDC_B).rely(MCD_END);

        
        FlipAbstract(MCD_FLIP_USDC_B).rely(FLIPPER_MOM);

        VatAbstract(MCD_VAT).file(usdcBIlk,   "line"  , 10 * MILLION * RAD   ); 
        VatAbstract(MCD_VAT).file(usdcBIlk,   "dust"  , 20 * RAD             ); 
        CatAbstract(MCD_CAT).file(usdcBIlk,   "lump"  , 50 * THOUSAND * WAD  ); 
        CatAbstract(MCD_CAT).file(usdcBIlk,   "chop"  , 113 * RAY / 100      ); 
        JugAbstract(MCD_JUG).file(usdcBIlk,   "duty"  , FIFTY_PCT_RATE       ); 
        FlipAbstract(MCD_FLIP_USDC_B).file(   "beg"   , 103 * WAD / 100      ); 
        FlipAbstract(MCD_FLIP_USDC_B).file(   "ttl"   , 6 hours              ); 
        FlipAbstract(MCD_FLIP_USDC_B).file(   "tau"   , 3 days               ); 
        SpotAbstract(MCD_SPOT).file(usdcBIlk, "mat"   , 120 * RAY / 100      ); 
        SpotAbstract(MCD_SPOT).poke(usdcBIlk);

        
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_B);

        
        

        
        bytes32 tusdAIlk = "TUSD-A";

        
        VatAbstract(MCD_VAT).init(tusdAIlk);
        JugAbstract(MCD_JUG).init(tusdAIlk);

        
        VatAbstract(MCD_VAT).rely(MCD_JOIN_TUSD_A);

        
        SpotAbstract(MCD_SPOT).file(tusdAIlk, "pip", PIP_TUSD);

        
        CatAbstract(MCD_CAT).file(tusdAIlk, "flip", MCD_FLIP_TUSD_A);

        
        
        FlipAbstract(MCD_FLIP_TUSD_A).rely(MCD_CAT);

        
        FlipAbstract(MCD_FLIP_TUSD_A).rely(MCD_END);

        
        FlipAbstract(MCD_FLIP_TUSD_A).rely(FLIPPER_MOM);

        VatAbstract(MCD_VAT).file(tusdAIlk,   "line"  , 2 * MILLION * RAD    ); 
        VatAbstract(MCD_VAT).file(tusdAIlk,   "dust"  , 20 * RAD             ); 
        CatAbstract(MCD_CAT).file(tusdAIlk,   "lump"  , 50 * THOUSAND * WAD  ); 
        CatAbstract(MCD_CAT).file(tusdAIlk,   "chop"  , 113 * RAY / 100      ); 
        JugAbstract(MCD_JUG).file(tusdAIlk,   "duty"  , ZERO_PCT_RATE        ); 
        FlipAbstract(MCD_FLIP_TUSD_A).file(   "beg"   , 103 * WAD / 100      ); 
        FlipAbstract(MCD_FLIP_TUSD_A).file(   "ttl"   , 6 hours              ); 
        FlipAbstract(MCD_FLIP_TUSD_A).file(   "tau"   , 3 days               ); 
        SpotAbstract(MCD_SPOT).file(tusdAIlk, "mat"   , 120 * RAY / 100      ); 
        SpotAbstract(MCD_SPOT).poke(tusdAIlk);

        
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_TUSD_A);
    }
}

contract DssSpell {
    DSPauseAbstract  public pause =
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    uint256          public expiration;
    bool             public done;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}