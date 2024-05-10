pragma solidity 0.5.12;

contract OsmLike {
    function stop() external;
}

contract AuthorityLike {
    function canCall(address src, address dst, bytes4 sig) public view returns (bool);
}

contract OsmMom {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  usr,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes             data
    ) anonymous;

    modifier note {
        _;
        assembly {
            
            
            let mark := msize                         
            mstore(0x40, add(mark, 288))              
            mstore(mark, 0x20)                        
            mstore(add(mark, 0x20), 224)              
            calldatacopy(add(mark, 0x40), 0, 224)     
            log4(mark, 288,                           
                 shl(224, shr(224, calldataload(0))), 
                 caller,                              
                 calldataload(4),                     
                 calldataload(36)                     
                )
        }
    }

    address public owner;
    modifier onlyOwner { require(msg.sender == owner, "osm-mom/only-owner"); _;}

    address public authority;
    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "osm-mom/not-authorized");
        _;
    }
    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == address(0)) {
            return false;
        } else {
            return AuthorityLike(authority).canCall(src, address(this), sig);
        }
    }

    mapping (bytes32 => address) public osms;

    constructor() public {
        owner = msg.sender;
    }

    function setOsm(bytes32 ilk, address osm) external note onlyOwner {
        osms[ilk] = osm;
    }

    function setOwner(address owner_) external note onlyOwner {
        owner = owner_;
    }

    function setAuthority(address authority_) external note onlyOwner {
        authority = authority_;
    }

    function stop(bytes32 ilk) external note auth {
        OsmLike(osms[ilk]).stop();
    }
}