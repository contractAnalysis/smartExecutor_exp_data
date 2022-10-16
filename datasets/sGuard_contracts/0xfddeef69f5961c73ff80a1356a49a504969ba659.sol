pragma solidity 0.5.12;

interface DSPauseAbstract {
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

interface VatAbstract {
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
}

contract SpellAction {

    
    
    
    string constant public description =
        "2020-08-18 MakerDAO Executive Spell | Hash: 0xf2d66116128a66c268be1252477cebe8d16a48b599df641a01fbae20010d3277";

    
    
    
    
    

    address constant MCD_VAT  = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;

    uint256 constant MILLION  = 10 ** 6;
    uint256 constant RAD      = 10 ** 45;

    function execute() external {
        
        
        
        VatAbstract(MCD_VAT).file("Line", 688 * MILLION * RAD);

        
        
        
        VatAbstract(MCD_VAT).file("ETH-A", "line", 420 * MILLION * RAD);
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