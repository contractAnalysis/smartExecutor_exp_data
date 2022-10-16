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

contract SpellAction {

    
    
    
    string constant public description =
        "2020-08-21 MakerDAO Executive Spell | Hash: 0xa42625339c53b03d0d95ad99ccffc07a1f2cf8ec5f8858d9a0b5578204949609";

    
    
    
    
    
    address constant MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;

    
    
    
    uint256 constant EIGHT_PCT      = 1000000002440418608258400030;
    uint256 constant FOURTY_SIX_PCT = 1000000012000140727767957524;

    function execute() external {
        
        
        
        JugAbstract(MCD_JUG).drip("USDC-B"); 
        JugAbstract(MCD_JUG).file("USDC-B", "duty", FOURTY_SIX_PCT);

        
        
        
        JugAbstract(MCD_JUG).drip("MANA-A"); 
        JugAbstract(MCD_JUG).file("MANA-A", "duty", EIGHT_PCT);
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