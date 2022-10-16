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
    function drip(bytes32) external returns (uint256);
}


contract VatAbstract {
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;    
}


contract SaiMomAbstract {    
    function setCap(uint256) public;
}

contract SpellAction {
    
    
    string  constant public description =
        "2020-02-28 Weekly Executive: DSR, Sai Ceiling, Dai Ceiling";

    uint256 constant public RAD = 10**45;
    uint256 constant public MILLION = 10**6;
    address constant public PAUSE = 0xbE286431454714F511008713973d3B053A2d38f3;
    address constant public JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant public POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address constant public VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;

    
    
    
    
    
    
    uint256 constant public SEVEN_PCT_RATE = 1000000002145441671308778766;

    function execute() external {

        
        PotAbstract(POT).drip();
        JugAbstract(JUG).drip("ETH-A");
        JugAbstract(JUG).drip("BAT-A");


        

        
        
        
        
        
        
        
        
        uint256 DSR_RATE = SEVEN_PCT_RATE;
        PotAbstract(POT).file("dsr", DSR_RATE);


        
        
        
        
        
        
        
        
        uint256 ETH_LINE = 130 * MILLION;
        VatAbstract(VAT).file("ETH-A", "line", ETH_LINE * RAD);


        
        
        
        
        
        
        
        
        uint256 SAI_LINE = 25 * MILLION;
        VatAbstract(VAT).file("SAI", "line", SAI_LINE * RAD);


        
        
        
        
        
        
        
        
        
        
        uint256 GLOBAL_AMOUNT = 158 * MILLION;
        VatAbstract(VAT).file("Line", GLOBAL_AMOUNT * RAD);
    }
}

contract DssSpell {

    uint256 constant public WAD = 10**18;
    uint256 constant public MILLION = 10**6;
    DSPauseAbstract  public pause =
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
    address constant public SAI_MOM = 0xF2C5369cFFb8Ea6284452b0326e326DbFdCb867C;
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

    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }

    function schedule() public {
        require(eta == 0, "spell-already-scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);

        
        


        
        
        
        
        
        
        
        
        
        
        uint256 SAI_AMOUNT = 25 * MILLION;
        SaiMomAbstract(SAI_MOM).setCap(SAI_AMOUNT * WAD);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}