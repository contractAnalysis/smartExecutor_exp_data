pragma solidity 0.5.12;

interface DSPauseAbstract {
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

interface VatAbstract {
    function wards(address) external view returns (uint256);
}

contract SpellAction {

    
    
    
    
    
    address constant MCD_VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;

    function execute() external {
		
		require(VatAbstract(MCD_VAT).wards(address(this)) == 1, "no-access");
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

    
    
    
    string constant public description =
        "2020-08-24 MakerDAO August 2020 Governance Cycle Bundle | Hash: 0xa0d81d0896decfa0e74f1e4d353640d132953c373605e2fe22f1da23a7c3ed6c";

    
    
	string constant public MIP13C3SP1 = "0xdc1d9ca6751a4f9e138a5852d1bc0372cd175a8007b9f0a05f8e4e8b4213c9a4";

    
    
	string constant public MIP0C13SP1 = "0xf8c9b8e15faf490c1f6b4a3d089453d496f2a27a662a70114b446c76a629172e";

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 4 days + 2 hours;
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