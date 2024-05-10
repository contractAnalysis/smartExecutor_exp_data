pragma solidity ^0.5.0;

contract GemLike {
    function approve(address, uint) public;
    function transfer(address, uint) public;
    function transferFrom(address, address, uint) public;
    function deposit() public payable;
    function withdraw(uint) public;
}

contract ManagerLike {
    function cdpCan(address, uint, address) public view returns (uint);
    function ilks(uint) public view returns (bytes32);
    function owns(uint) public view returns (address);
    function urns(uint) public view returns (address);
    function vat() public view returns (address);
    function open(bytes32, address) public returns (uint);
    function give(uint, address) public;
    function cdpAllow(uint, address, uint) public;
    function urnAllow(address, uint) public;
    function frob(uint, int, int) public;
    function flux(uint, address, uint) public;
    function move(uint, address, uint) public;
    function exit(address, uint, address, uint) public;
    function quit(uint, address) public;
    function enter(address, uint) public;
    function shift(uint, uint) public;
}

contract VatLike {
    function can(address, address) public view returns (uint);
    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);
    function dai(address) public view returns (uint);
    function urns(bytes32, address) public view returns (uint, uint);
    function frob(bytes32, address, address, address, int, int) public;
    function hope(address) public;
    function move(address, address, uint) public;
}

contract GemJoinLike {
    function dec() public returns (uint);
    function gem() public returns (GemLike);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract GNTJoinLike {
    function bags(address) public view returns (address);
    function make(address) public returns (address);
}

contract DaiJoinLike {
    function vat() public returns (VatLike);
    function dai() public returns (GemLike);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract HopeLike {
    function hope(address) public;
    function nope(address) public;
}

contract ProxyRegistryInterface {
    function build(address) public returns (address);
}

contract EndLike {
    function fix(bytes32) public view returns (uint);
    function cash(bytes32, uint) public;
    function free(bytes32) public;
    function pack(uint) public;
    function skim(bytes32, address) public;
}

contract JugLike {
    function drip(bytes32) public returns (uint);
}

contract PotLike {
    function pie(address) public view returns (uint);
    function drip() public returns (uint);
    function join(uint) public;
    function exit(uint) public;
}

contract ProxyRegistryLike {
    function proxies(address) public view returns (address);
    function build(address) public returns (address);
}

contract ProxyLike {
    function owner() public view returns (address);
}






contract Common {
    uint256 constant RAY = 10 ** 27;

    

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    

    function daiJoin_join(address apt, address urn, uint wad) public {
        
        DaiJoinLike(apt).dai().transferFrom(msg.sender, address(this), wad);
        
        DaiJoinLike(apt).dai().approve(apt, wad);
        
        DaiJoinLike(apt).join(urn, wad);
    }
}

contract MCDOpenProxyActions is Common {

    

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }

    function convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {
        
        
        wad = mul(
            amt,
            10 ** (18 - GemJoinLike(gemJoin).dec())
        );
    }

    function _getDrawDart(
        address vat,
        address jug,
        address urn,
        bytes32 ilk,
        uint wad
    ) internal returns (int dart) {
        
        uint rate = JugLike(jug).drip(ilk);

        
        uint dai = VatLike(vat).dai(urn);

        
        if (dai < mul(wad, RAY)) {
            
            dart = toInt(sub(mul(wad, RAY), dai) / rate);
            
            dart = mul(uint(dart), rate) < mul(wad, RAY) ? dart + 1 : dart;
        }
    }

    function _getWipeDart(
        address vat,
        uint dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart) {
        
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        
        (, uint art) = VatLike(vat).urns(ilk, urn);

        
        dart = toInt(dai / rate);
        
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    function _getWipeAllWad(
        address vat,
        address usr,
        address urn,
        bytes32 ilk
    ) internal view returns (uint wad) {
        
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        
        (, uint art) = VatLike(vat).urns(ilk, urn);
        
        uint dai = VatLike(vat).dai(usr);

        uint rad = sub(mul(art, rate), dai);
        wad = rad / RAY;

        
        wad = mul(wad, RAY) < rad ? wad + 1 : wad;
    }

    

    function transfer(address gem, address dst, uint wad) public {
        GemLike(gem).transfer(dst, wad);
    }

    function ethJoin_join(address apt, address urn) public payable {
        
        GemJoinLike(apt).gem().deposit.value(msg.value)();
        
        GemJoinLike(apt).gem().approve(address(apt), msg.value);
        
        GemJoinLike(apt).join(urn, msg.value);
    }

    function gemJoin_join(address apt, address urn, uint wad, bool transferFrom) public {
        
        if (transferFrom) {
            
            GemJoinLike(apt).gem().transferFrom(msg.sender, address(this), wad);
            
            GemJoinLike(apt).gem().approve(apt, wad);
        }
        
        GemJoinLike(apt).join(urn, wad);
    }

    function hope(
        address obj,
        address usr
    ) public {
        HopeLike(obj).hope(usr);
    }

    function nope(
        address obj,
        address usr
    ) public {
        HopeLike(obj).nope(usr);
    }

    function open(
        address manager,
        bytes32 ilk,
        address usr
    ) public returns (uint cdp) {
        cdp = ManagerLike(manager).open(ilk, usr);
    }

    function give(
        address manager,
        uint cdp,
        address usr
    ) public {
        ManagerLike(manager).give(cdp, usr);
    }

    function move(
        address manager,
        uint cdp,
        address dst,
        uint rad
    ) public {
        ManagerLike(manager).move(cdp, dst, rad);
    }

    function frob(
        address manager,
        uint cdp,
        int dink,
        int dart
    ) public {
        ManagerLike(manager).frob(cdp, dink, dart);
    }

    function lockETH(
        address manager,
        address ethJoin,
        uint cdp
    ) public payable {
        
        ethJoin_join(ethJoin, address(this));
        
        VatLike(ManagerLike(manager).vat()).frob(
            ManagerLike(manager).ilks(cdp),
            ManagerLike(manager).urns(cdp),
            address(this),
            address(this),
            toInt(msg.value),
            0
        );
    }

    function lockGem(
        address manager,
        address gemJoin,
        uint cdp,
        uint wad,
        bool transferFrom
    ) public {
        
        gemJoin_join(gemJoin, address(this), wad, transferFrom);
        
        VatLike(ManagerLike(manager).vat()).frob(
            ManagerLike(manager).ilks(cdp),
            ManagerLike(manager).urns(cdp),
            address(this),
            address(this),
            toInt(convertTo18(gemJoin, wad)),
            0
        );

    }


    function draw(
        address manager,
        address jug,
        address daiJoin,
        uint cdp,
        uint wad
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        
        frob(manager, cdp, 0, _getDrawDart(vat, jug, urn, ilk, wad));
        
        move(manager, cdp, address(this), toRad(wad));
        
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        
        DaiJoinLike(daiJoin).exit(msg.sender, wad);

    }

    function lockETHAndDraw(
        address manager,
        address jug,
        address ethJoin,
        address daiJoin,
        uint cdp,
        uint wadD
    ) public payable {
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        
        ethJoin_join(ethJoin, urn);
        
        frob(manager, cdp, toInt(msg.value), _getDrawDart(vat, jug, urn, ilk, wadD));
        
        move(manager, cdp, address(this), toRad(wadD));
        
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function openLockETHAndDraw(
        address manager,
        address jug,
        address ethJoin,
        address daiJoin,
        bytes32 ilk,
        uint wadD,
        address owner
    ) public payable returns (uint cdp) {
        cdp = open(manager, ilk, address(this));
        lockETHAndDraw(manager, jug, ethJoin, daiJoin, cdp, wadD);
        give(manager, cdp, owner);

    }

    function lockGemAndDraw(
        address manager,
        address jug,
        address gemJoin,
        address daiJoin,
        uint cdp,
        uint wadC,
        uint wadD,
        bool transferFrom
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        
        gemJoin_join(gemJoin, urn, wadC, transferFrom);
        
        frob(manager, cdp, toInt(convertTo18(gemJoin, wadC)), _getDrawDart(vat, jug, urn, ilk, wadD));
        
        move(manager, cdp, address(this), toRad(wadD));
        
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);

    }

    function openLockGemAndDraw(
        address manager,
        address jug,
        address gemJoin,
        address daiJoin,
        bytes32 ilk,
        uint wadC,
        uint wadD,
        bool transferFrom,
        address owner
    ) public returns (uint cdp) {
        cdp = open(manager, ilk, address(this));
        lockGemAndDraw(manager, jug, gemJoin, daiJoin, cdp, wadC, wadD, transferFrom);
        give(manager, cdp, owner);
    }

}