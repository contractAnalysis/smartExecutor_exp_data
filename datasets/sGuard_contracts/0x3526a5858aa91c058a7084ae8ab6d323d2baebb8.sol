pragma solidity 0.5.12;


contract DSPauseAbstract {
    function setDelay(uint256) public;
    function delay() public view returns (uint256);
    function plot(address, bytes32, bytes memory, uint256) public;
    function exec(address, bytes32, bytes memory, uint256) public returns (bytes memory);
}


contract VatAbstract {
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
}


contract PotAbstract {
    function file(bytes32, uint256) external;
    function drip() external returns (uint256);
}


contract JugAbstract {
    function file(bytes32, bytes32, uint256) external;
    function drip(bytes32) external returns (uint256);
}


contract SpotAbstract {
    function file(bytes32, bytes32, uint256) external;
    function poke(bytes32) external;
}


contract OsmAbstract {
    function kiss(address) external;
}


contract SaiMomAbstract {
    function setPep(address) public;
}


contract SaiTopAbstract {
    function cage() public;
    function setOwner(address) public;
}

contract SaiSlayer {
    uint256 constant public T2020_05_12_1600UTC = 1589299200;
    SaiTopAbstract constant public SAITOP = SaiTopAbstract(0x9b0ccf7C8994E19F39b2B4CF708e0A7DF65fA8a3);

    function cage() public {
        require(now >= T2020_05_12_1600UTC);
        SAITOP.cage();
    }
}

contract NewMkrOracle {
    function read() external pure returns (bytes32) {
        revert();
    }
    function peek() external pure returns (bytes32, bool) {
        return (0, false);
    }
}

contract SpellAction {
    
    
    string constant public description = "2020-04-24 MakerDAO Executive Spell";

    
    
    
    
    
    
    address constant public MCD_VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address constant public MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant public MCD_POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address constant public MCD_SPOT = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
    address constant public MCD_PAUSE = 0xbE286431454714F511008713973d3B053A2d38f3;
    address constant public ETHUSD = 0x64DE91F5A373Cd4c28de3600cB34C7C6cE410C85;
    address constant public BTCUSD = 0xe0F30cb149fAADC7247E953746Be9BbBB6B5751f;

    address constant public SET_ETHUSD = 0x97C3e595e8f80169266B5534e4d7A1bB58BB45ab;
    address constant public DYDX_BTCUSD = 0xbf63446ecF3341e04c6569b226a57860B188edBc;
    address constant public SET_BTCUSD = 0x538038E526517680735568f9C5342c6E68bbDA12;

    
    
    
    
    
    
    uint256 constant public ZERO_PCT_RATE =  1000000000000000000000000000;
    uint256 constant public SIX_PCT_RATE = 1000000001847694957439350562;

    uint256 constant public RAD = 10**45;
    uint256 constant public MILLION = 10**6;

    function execute() external {

        
        PotAbstract(MCD_POT).drip();
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");
        JugAbstract(MCD_JUG).drip("USDC-A");

        

        
        
        
        
        uint256 ETH_FEE = ZERO_PCT_RATE;
        JugAbstract(MCD_JUG).file("ETH-A", "duty", ETH_FEE);

        
        
        
        
        uint256 BAT_FEE = ZERO_PCT_RATE;
        JugAbstract(MCD_JUG).file("BAT-A", "duty", BAT_FEE);

        
        
        
        
        uint256 USDC_FEE = SIX_PCT_RATE;
        JugAbstract(MCD_JUG).file("USDC-A", "duty", USDC_FEE);

        
        
        
        
        uint256 DSR_RATE = ZERO_PCT_RATE;
        PotAbstract(MCD_POT).file("dsr", DSR_RATE);

        
        
        
        
        
        uint256 ETH_LINE = 100 * MILLION;
        VatAbstract(MCD_VAT).file("ETH-A", "line", ETH_LINE * RAD);

        
        uint256 GLOBAL_LINE = 123 * MILLION;
        VatAbstract(MCD_VAT).file("Line", GLOBAL_LINE * RAD);

        
        
        
        
        
        uint256 USDC_MAT = 1.2 * 10 ** 27;
        SpotAbstract(MCD_SPOT).file("USDC-A", "mat", USDC_MAT);
        SpotAbstract(MCD_SPOT).poke("USDC-A");

        
        OsmAbstract(ETHUSD).kiss(SET_ETHUSD);
        OsmAbstract(BTCUSD).kiss(DYDX_BTCUSD);
        OsmAbstract(BTCUSD).kiss(SET_BTCUSD);

        
        DSPauseAbstract(MCD_PAUSE).setDelay(12 hours);
    }
}

contract DssSpell {

    DSPauseAbstract  public pause =
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
    SaiMomAbstract   public saiMom =
        SaiMomAbstract(0xF2C5369cFFb8Ea6284452b0326e326DbFdCb867C);
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    uint256          public expiration;
    bool             public done;
    SaiSlayer        public saiSlayer;
    NewMkrOracle     public newMkrOracle;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;

        saiSlayer = new SaiSlayer();
        newMkrOracle = new NewMkrOracle();
    }

    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);

        
        saiSlayer.SAITOP().setOwner(address(saiSlayer));

        
        saiMom.setPep(address(newMkrOracle));
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}