pragma solidity 0.5.12;


contract DSPauseAbstract {
    function delay() public view returns (uint256);
    function plot(address, bytes32, bytes memory, uint256) public;
    function exec(address, bytes32, bytes memory, uint256) public returns (bytes memory);
}


contract PotAbstract {
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function drip() external returns (uint256);
}


contract JugAbstract {
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function drip(bytes32) external returns (uint256);
}


contract VatAbstract {
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
}


contract CatAbstract {
    function file(bytes32, address) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, address) external;
}


contract VowAbstract {
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
}


contract FlipAbstract {
    function file(bytes32, uint256) external;
}


contract FlopAbstract {
    function file(bytes32, uint256) external;
}


contract SaiMomAbstract {
    function setCap(uint256) public;
    function setFee(uint256) public;
}

contract SpellAction {
    
    
    string  constant public description = "03/12/2020 MakerDAO Executive Spell";

    
    
    
    
    
    
    address constant public MCD_PAUSE = 0xbE286431454714F511008713973d3B053A2d38f3;
    address constant public MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant public MCD_POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address constant public MCD_VOW = 0xA950524441892A31ebddF91d3cEEFa04Bf454466;
    address constant public MCD_VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address constant public MCD_CAT = 0x78F2c2AF65126834c51822F56Be0d7469D7A523E;
    address constant public MCD_FLIP_ETH_A = 0xd8a04F5412223F513DC55F839574430f5EC15531;
    address constant public MCD_FLIP_BAT_A = 0xaA745404d55f88C108A28c86abE7b5A1E7817c07;
    address constant public MCD_FLOP = 0x4D95A049d5B0b7d32058cd3F2163015747522e99;


    
    
    
    
    
    
    uint256 constant public FOUR_PCT_RATE = 1000000001243680656318820312;

    uint256 constant public WAD = 10**18;
    uint256 constant public RAD = 10**45;
    uint256 constant public MILLION = 10**6;
    uint256 constant public HOUR = 3600; 

    function execute() external {

        
        PotAbstract(MCD_POT).drip();
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");


        


        
        
        
        
        
        
        uint256 DSR_RATE = FOUR_PCT_RATE;
        PotAbstract(MCD_POT).file("dsr", DSR_RATE);


        
        
        
        
        
        
        uint256 ETH_LINE = 100 * MILLION;
        VatAbstract(MCD_VAT).file("ETH-A", "line", ETH_LINE * RAD);


        
        
        
        
        
        
        uint256 ETH_FEE = FOUR_PCT_RATE;
        JugAbstract(MCD_JUG).file("ETH-A", "duty", ETH_FEE);


        
        
        
        
        
        
        uint256 BAT_FEE = FOUR_PCT_RATE;
        JugAbstract(MCD_JUG).file("BAT-A", "duty", BAT_FEE);


        
        
        
        
        
        
        uint256 SAI_LINE = 10 * MILLION;
        VatAbstract(MCD_VAT).file("SAI", "line", SAI_LINE * RAD);

        
        
        
        
        
        
        
        
        uint256 GLOBAL_AMOUNT = 113 * MILLION;
        VatAbstract(MCD_VAT).file("Line", GLOBAL_AMOUNT * RAD);


        
        
        
        
        
        
        uint256 ETH_FLIP_TTL = 6 hours;
        FlipAbstract(MCD_FLIP_ETH_A).file(bytes32("ttl"), ETH_FLIP_TTL);


        
        
        
        
        
        
        uint256 BAT_FLIP_TTL = 6 hours;
        FlipAbstract(MCD_FLIP_BAT_A).file(bytes32("ttl"), BAT_FLIP_TTL);


        
        
        
        
        
        
        uint256 ETH_FLIP_TAU = 6 hours;
        FlipAbstract(MCD_FLIP_ETH_A).file(bytes32("tau"), ETH_FLIP_TAU);


        
        
        
        
        
        
        uint256 BAT_FLIP_TAU = 6 hours;
        FlipAbstract(MCD_FLIP_BAT_A).file(bytes32("tau"), BAT_FLIP_TAU);


        
        
        
        
        
        
        uint256 FLOP_TTL = 6 hours;
        FlopAbstract(MCD_FLOP).file(bytes32("ttl"), FLOP_TTL);


        
        
        
        
        uint256 LUMP = 500 * WAD;
        CatAbstract(MCD_CAT).file("ETH-A", "lump", LUMP);


        
        
        
        
        
        
        uint256 WAIT_DELAY = 156 * HOUR;
        VowAbstract(MCD_VOW).file("wait", WAIT_DELAY);
    }
}

contract DssSpell {

    DSPauseAbstract  public pause =
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
    address constant public SAI_MOM = 0xF2C5369cFFb8Ea6284452b0326e326DbFdCb867C;
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    uint256          public expiration;
    bool             public done;

    uint256 constant internal MILLION = 10**6;
    uint256 constant internal WAD = 10**18;

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

        
        


        
        
        
        
        
        
        uint256 SAI_FEE = 1000000002293273137447730714;
        SaiMomAbstract(SAI_MOM).setFee(SAI_FEE);


        
        
        
        
        
        
        
        
        
        
        uint256 SAI_AMOUNT = 25 * MILLION;
        SaiMomAbstract(SAI_MOM).setCap(SAI_AMOUNT * WAD);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}