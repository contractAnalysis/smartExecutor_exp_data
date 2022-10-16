pragma solidity 0.5.12;

contract DSPauseAbstract {
    function delay() public view returns (uint256);
    function plot(address, bytes32, bytes memory, uint256) public;
    function exec(address, bytes32, bytes memory, uint256) public returns (bytes memory);
}

contract VatAbstract {
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
}

contract JugAbstract {
    function file(bytes32, bytes32, uint256) external;
    function drip(bytes32) external returns (uint256);
}

contract PotAbstract {
    function drip() external returns (uint256);
}

contract MedianAbstract {
    function lift(address[] calldata) external;
    function kiss(address) external;
    function kiss(address[] calldata) external;
}

contract OsmAbstract {
    function kiss(address) external;
}

contract SpellAction {
    
    
    string constant public description = "2020-07-03 MakerDAO Executive Spell";

    
    
    
    address constant MCD_VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address constant MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant MCD_POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;

    address constant PIP_ETH = 0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763;
    address constant PIP_BAT = 0xB4eb54AF9Cc7882DF0121d26c5b97E802915ABe6;
    address constant PIP_WBTC = 0xf185d0682d50819263941e5f4EacC763CC5C6C42;

    address constant BATUSD = 0x18B4633D6E39870f398597f3c1bA8c4A41294966;
    address constant BTCUSD = 0xe0F30cb149fAADC7247E953746Be9BbBB6B5751f;
    address constant ETHBTC = 0x81A679f98b63B3dDf2F17CB5619f4d6775b3c5ED;
    address constant ETHUSD = 0x64DE91F5A373Cd4c28de3600cB34C7C6cE410C85;
    address constant KNCUSD = 0x83076a2F42dc1925537165045c9FDe9A4B71AD97;
    address constant ZRXUSD = 0x956ecD6a9A9A0d84e8eB4e6BaaC09329E202E55e;

    address constant ETHERSCAN  = 0x71eCFF5261bAA115dcB1D9335c88678324b8A987;
    address constant GITCOIN    = 0xA4188B523EccECFbAC49855eB52eA0b55c4d56dd;
    address constant KYBER      = 0xD09506dAC64aaA718b45346a032F934602e29cca;
    address constant INFURA     = 0x8ff6a38A1CD6a42cAac45F08eB0c802253f68dfD;
    address constant DEFI_SAVER = 0xeAa474cbFFA87Ae0F1a6f68a3aBA6C77C656F72c;
    address constant MCDEX      = 0x12Ee7E3369272CeE4e9843F36331561DBF9Ae6b4;

    uint256 constant THOUSAND = 10**3;
    uint256 constant MILLION  = 10**6;
    uint256 constant WAD      = 10**18;
    uint256 constant RAY      = 10**27;
    uint256 constant RAD      = 10**45;

    
    
    
    
    
    
    uint256 constant ZERO_PCT_RATE = 1000000000000000000000000000;
    uint256 constant TWO_PCT_RATE = 1000000000627937192491029810;
    uint256 constant FOUR_PCT_RATE =  1000000001243680656318820312;
    uint256 constant FIFTY_PCT_RATE = 1000000012857214317438491659;

    function execute() external {
        
        PotAbstract(MCD_POT).drip();

        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");
        JugAbstract(MCD_JUG).drip("USDC-A");
        JugAbstract(MCD_JUG).drip("USDC-B");
        JugAbstract(MCD_JUG).drip("TUSD-A");
        JugAbstract(MCD_JUG).drip("WBTC-A");
        JugAbstract(MCD_JUG).drip("KNC-A");
        JugAbstract(MCD_JUG).drip("ZRX-A");

        
        
        
        VatAbstract(MCD_VAT).file("Line", 225 * MILLION * RAD);

        
        
        
        
        VatAbstract(MCD_VAT).file("WBTC-A", "line", 20 * MILLION * RAD);

        
        
        
        
        VatAbstract(MCD_VAT).file("USDC-A", "line", 40 * MILLION * RAD);

        
        
        
        
        
        
        JugAbstract(MCD_JUG).file("ETH-A", "duty", ZERO_PCT_RATE);
        JugAbstract(MCD_JUG).file("BAT-A", "duty", ZERO_PCT_RATE);
        JugAbstract(MCD_JUG).file("USDC-A", "duty", FOUR_PCT_RATE);
        JugAbstract(MCD_JUG).file("USDC-B", "duty", FIFTY_PCT_RATE);
        JugAbstract(MCD_JUG).file("WBTC-A", "duty", TWO_PCT_RATE);
        JugAbstract(MCD_JUG).file("TUSD-A", "duty", ZERO_PCT_RATE);
        JugAbstract(MCD_JUG).file("KNC-A", "duty", FOUR_PCT_RATE);
        JugAbstract(MCD_JUG).file("ZRX-A", "duty", FOUR_PCT_RATE);

        address[] memory lightFeeds = new address[](4);
        lightFeeds[0] = ETHERSCAN;
        lightFeeds[1] = GITCOIN;
        lightFeeds[2] = KYBER;
        lightFeeds[3] = INFURA;

        
        MedianAbstract(BATUSD).lift(lightFeeds);
        MedianAbstract(BTCUSD).lift(lightFeeds);
        MedianAbstract(ETHBTC).lift(lightFeeds);
        MedianAbstract(ETHUSD).lift(lightFeeds);
        MedianAbstract(KNCUSD).lift(lightFeeds);
        MedianAbstract(ZRXUSD).lift(lightFeeds);

        
        OsmAbstract(PIP_ETH).kiss(DEFI_SAVER);
        
        OsmAbstract(PIP_BAT).kiss(DEFI_SAVER);
        
        OsmAbstract(PIP_WBTC).kiss(DEFI_SAVER);
        
        MedianAbstract(ETHUSD).kiss(MCDEX);
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