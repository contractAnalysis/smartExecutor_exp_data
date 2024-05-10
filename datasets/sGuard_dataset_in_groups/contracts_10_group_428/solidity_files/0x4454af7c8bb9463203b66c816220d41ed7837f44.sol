pragma solidity ^0.5.12;

contract LibNote {
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
}

contract VatLike {
    function slip(bytes32,address,int) public;
}

contract GemLike6 {
    function decimals() public view returns (uint);
    function balanceOf(address) public returns (uint256);
    function transfer(address, uint256) public returns (bool);
    function transferFrom(address,address,uint) public returns (bool);
    function implementation() public view returns (address);
}

contract GemJoin6 is LibNote {
    
    mapping (address => uint256) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "GemJoin6/not-authorized");
        _;
    }

    VatLike  public vat;
    bytes32  public ilk;
    GemLike6 public gem;
    uint     public dec;
    uint     public live;  

    mapping (address => uint256) public implementations;

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = GemLike6(gem_);
        setImplementation(gem.implementation(), 1);
        dec = gem.decimals();
    }
    function cage() external note auth {
        live = 0;
    }
    function setImplementation(address implementation, uint256 permitted) public auth note {
        implementations[implementation] = permitted;  
    }
    function join(address usr, uint wad) external note {
        require(live == 1, "GemJoin6/not-live");
        require(int(wad) >= 0, "GemJoin6/overflow");
        require(implementations[gem.implementation()] == 1, "GemJoin6/implementation-invalid");
        vat.slip(ilk, usr, int(wad));
        require(gem.transferFrom(msg.sender, address(this), wad), "GemJoin6/failed-transfer");
    }
    function exit(address usr, uint wad) external note {
        require(wad <= 2 ** 255, "GemJoin6/overflow");
        require(implementations[gem.implementation()] == 1, "GemJoin6/implementation-invalid");
        vat.slip(ilk, msg.sender, -int(wad));
        require(gem.transfer(usr, wad), "GemJoin6/failed-transfer");
    }
}