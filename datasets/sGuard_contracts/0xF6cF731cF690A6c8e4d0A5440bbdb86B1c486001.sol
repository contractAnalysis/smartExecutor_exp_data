pragma solidity ^0.6.7;

interface IlkRegistry {
    function list() external view returns (bytes32[] memory);
}

interface PotLike {
    function drip() external;
}

interface JugLike {
    function drip(bytes32) external;
}

contract Drizzle {

    IlkRegistry private _reg;
    PotLike     private _pot;
    JugLike     private _jug;

    constructor(address ilkRegistry, address dss_pot, address dss_jug) public {
        _reg = IlkRegistry(ilkRegistry);
        _pot = PotLike(dss_pot);
        _jug = JugLike(dss_jug);
    }

    function drizzle(bytes32[] memory ilks) public {
        _pot.drip();
        for (uint i = 0; i < ilks.length; i++) {
            _jug.drip(ilks[i]);
        }
    }

    function drizzle() external {
        bytes32[] memory ilks = _reg.list();
        drizzle(ilks);
    }

    function registry() external view returns (address) {
        return address(_reg);
    }

    function pot() external view returns (address) {
        return address(_pot);
    }

    function jug() external view returns (address) {
        return address(_jug);
    }
}