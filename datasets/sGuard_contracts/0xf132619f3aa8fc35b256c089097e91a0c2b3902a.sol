pragma solidity 0.5.12;

interface DSPauseAbstract {
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

interface JugAbstract {
    function file(bytes32, bytes32, uint256) external;
    function drip(bytes32) external returns (uint256);
}

interface MedianAbstract {
    function kiss(address) external;
}

contract SpellAction {

    
    
    
    string constant public description =
        "2020-07-31 MakerDAO Weekly Executive Spell | Hash: 0x39191aff3396e2ae7db1b8c8f08e13f0d9d96d1135a918154c0bf69c70830eee";

    
    
    
    
    

    address constant public MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant ETHUSD = 0x64DE91F5A373Cd4c28de3600cB34C7C6cE410C85;
    address constant dYdX = 0x538038E526517680735568f9C5342c6E68bbDA12;

    
    
    
    
    
    
    uint256 constant public ZERO_PCT_RATE = 1000000000000000000000000000;
    uint256 constant public FORTYSIX_PCT_RATE = 1000000012000140727767957524;
    uint256 constant public EIGHT_PCT_RATE = 1000000002440418608258400030;

    function execute() external {
        
        
        
        
        
        
        JugAbstract(MCD_JUG).drip("WBTC-A");
        JugAbstract(MCD_JUG).file("WBTC-A", "duty", ZERO_PCT_RATE);

        
        
        
        
        
        
        JugAbstract(MCD_JUG).drip("USDC-A");
        JugAbstract(MCD_JUG).file("USDC-A", "duty", ZERO_PCT_RATE);

        
        
        
        
        
        
        JugAbstract(MCD_JUG).drip("USDC-B");
        JugAbstract(MCD_JUG).file("USDC-B", "duty", FORTYSIX_PCT_RATE);

        
        
        
        
        
        
        JugAbstract(MCD_JUG).drip("ZRX-A");
        JugAbstract(MCD_JUG).file("ZRX-A", "duty", ZERO_PCT_RATE);

        
        
        
        
        
        
        JugAbstract(MCD_JUG).drip("KNC-A");
        JugAbstract(MCD_JUG).file("KNC-A", "duty", ZERO_PCT_RATE);

        
        
        
        
        
        
        JugAbstract(MCD_JUG).drip("MANA-A");
        JugAbstract(MCD_JUG).file("MANA-A", "duty", EIGHT_PCT_RATE);

        
        MedianAbstract(ETHUSD).kiss(dYdX);
    }
}

contract DssSpell {
    DSPauseAbstract public pause = 
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

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