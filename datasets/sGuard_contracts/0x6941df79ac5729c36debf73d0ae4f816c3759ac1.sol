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
    function ilks(bytes32) public view returns (uint256, uint256);
    function drip(bytes32) external returns (uint256);
}


contract SpellAction {
    
    
    string  constant public description = "2020-03-06 Weekly Executive: DSR spread adjustment";

    
    
    
    
    
    
    address constant public MCD_PAUSE = 0xbE286431454714F511008713973d3B053A2d38f3;
    address constant public MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant public MCD_POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;

    
    
    
    
    
    
    uint256 constant public SEVEN_PCT_RATE = 1000000002145441671308778766;
    uint256 constant public EIGHT_PCT_RATE = 1000000002440418608258400030;

    function execute() external {

        
        PotAbstract(MCD_POT).drip();
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");


        


        
        
        
        
        
        
        
        
        
        uint256 DSR_RATE = SEVEN_PCT_RATE;
        PotAbstract(MCD_POT).file("dsr", DSR_RATE);


        
        
        
        
        
        
        
        
        
        
        (uint256 dutyETH,) = JugAbstract(MCD_JUG).ilks("ETH-A");
        require(dutyETH == EIGHT_PCT_RATE, "Unexpected ETH-A Stability Fee");

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