pragma solidity 0.5.11;

interface GemLike {
    function approve(address, uint) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
}

interface ManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint);
    function give(uint, address) external;
    function cdpAllow(uint, address, uint) external;
    function urnAllow(address, uint) external;
    function frob(uint, int, int) external;
    function flux(uint, address, uint) external;
    function move(uint, address, uint) external;
    function exit(
        address,
        uint,
        address,
        uint
    ) external;
    function quit(uint, address) external;
    function enter(address, uint) external;
    function shift(uint, uint) external;
}

interface VatLike {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);
    function frob(
        bytes32,
        address,
        address,
        address,
        int,
        int
    ) external;
    function hope(address) external;
    function move(address, address, uint) external;
}

interface GemJoinLike {
    function dec() external returns (uint);
    function gem() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface DaiJoinLike {
    function vat() external returns (VatLike);
    function dai() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface HopeLike {
    function hope(address) external;
    function nope(address) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint);
}

interface ProxyRegistryLike {
    function proxies(address) external view returns (address);
    function build(address) external returns (address);
}

interface ProxyLike {
    function owner() external view returns (address);
}

interface InstaMcdAddress {
    function manager() external returns (address);
    function dai() external returns (address);
    function daiJoin() external returns (address);
    function jug() external returns (address);
    function proxyRegistry() external returns (address);
    function ethAJoin() external returns (address);
}


contract Common {
    uint256 constant RAY = 10 ** 27;

    
    function getMcdAddresses() public pure returns (address mcd) {
        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0; 
    }

    
    function getGiveAddress() public pure returns (address addr) {
        addr = 0xc679857761beE860f5Ec4B3368dFE9752580B096;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

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
}


contract DssProxyHelpers is Common {
    
    function joinDaiJoin(address urn, uint wad) public {
        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
        
        DaiJoinLike(daiJoin).dai().transferFrom(msg.sender, address(this), wad);
        
        DaiJoinLike(daiJoin).dai().approve(daiJoin, wad);
        
        DaiJoinLike(daiJoin).join(urn, wad);
    }

    function _getDrawDart(
        address vat,
        address jug,
        address urn,
        bytes32 ilk,
        uint wad
    ) internal returns (int dart)
    {
        
        uint rate = JugLike(jug).drip(ilk);

        
        uint dai = VatLike(vat).dai(urn);

        
        if (dai < mul(wad, RAY)) {
            
            dart = toInt(sub(mul(wad, RAY), dai) / rate);
            
            dart = mul(uint(dart), rate) < mul(wad, RAY) ? dart + 1 : dart;
        }
    }

    function _getWipeAllWad(
        address vat,
        address usr,
        address urn,
        bytes32 ilk
    ) internal view returns (uint wad)
    {
        
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        
        (, uint art) = VatLike(vat).urns(ilk, urn);
        
        uint dai = VatLike(vat).dai(usr);

        uint rad = sub(mul(art, rate), dai);
        wad = rad / RAY;

        
        wad = mul(wad, RAY) < rad ? wad + 1 : wad;
    }
}


contract DssProxyActionsAdv is DssProxyHelpers {
    

    function transfer(address gem, address dst, uint wad) public {
        GemLike(gem).transfer(dst, wad);
    }

    function joinEthJoin(address urn) public payable {
        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();
        
        GemJoinLike(ethJoin).gem().deposit.value(msg.value)();
        
        GemJoinLike(ethJoin).gem().approve(address(ethJoin), msg.value);
        
        GemJoinLike(ethJoin).join(urn, msg.value);
    }

    function joinGemJoin(
        address apt,
        address urn,
        uint wad,
        bool transferFrom
    ) public
    {
        
        if (transferFrom) {
            
            GemJoinLike(apt).gem().transferFrom(msg.sender, address(this), wad);
            
            GemJoinLike(apt).gem().approve(apt, wad);
        }
        
        GemJoinLike(apt).join(urn, wad);
    }

    function open(bytes32 ilk, address usr) public returns (uint cdp) {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        cdp = ManagerLike(manager).open(ilk, usr);
    }

    function give(uint cdp, address usr) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).give(cdp, usr);
    }

    function shut(uint cdp) public {
        give(cdp, getGiveAddress());
    }

    function flux(uint cdp, address dst, uint wad) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).flux(cdp, dst, wad);
    }

    function move(uint cdp, address dst, uint rad) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).move(cdp, dst, rad);
    }

    function frob(uint cdp, int dink, int dart) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).frob(cdp, dink, dart);
    }

    function drawAndSend(uint cdp, uint wad, address to) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address jug = InstaMcdAddress(getMcdAddresses()).jug();
        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        
        frob(
            cdp,
            0,
            _getDrawDart(
                vat,
                jug,
                urn,
                ilk,
                wad
            )
        );
        
        move(
            cdp,
            address(this),
            toRad(wad)
        );
        
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        
        DaiJoinLike(daiJoin).exit(to, wad);
    }

    function lockETHAndDraw(uint cdp, uint wadD) public payable {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address jug = InstaMcdAddress(getMcdAddresses()).jug();
        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        
        joinEthJoin(urn);
        
        frob(
            cdp,
            toInt(msg.value),
            _getDrawDart(
                vat,
                jug,
                urn,
                ilk,
                wadD
            )
        );
        
        move(
            cdp,
            address(this),
            toRad(wadD)
        );
        
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function openLockETHAndDraw(bytes32 ilk, uint wadD) public payable returns (uint cdp) {
        cdp = open(ilk, address(this));
        lockETHAndDraw(cdp, wadD);
    }

    function lockGemAndDraw(
        address gemJoin,
        uint cdp,
        uint wadC,
        uint wadD,
        bool transferFrom
    ) public
    {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address jug = InstaMcdAddress(getMcdAddresses()).jug();
        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        
        joinGemJoin(
            gemJoin,
            urn,
            wadC,
            transferFrom
        );
        
        frob(
            cdp,
            toInt(convertTo18(gemJoin, wadC)),
            _getDrawDart(
                vat,
                jug,
                urn,
                ilk,
                wadD
            )
        );
        
        move(
            cdp,
            address(this),
            toRad(wadD)
        );
        
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function openLockGemAndDraw( 
        address gemJoin,
        bytes32 ilk,
        uint wadC,
        uint wadD,
        bool transferFrom
    ) public returns (uint cdp)
    {
        cdp = open(ilk, address(this));
        lockGemAndDraw(
            gemJoin,
            cdp,
            wadC,
            wadD,
            transferFrom
        );
    }

    function wipeAllAndFreeEth(uint cdp) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();
        address vat = ManagerLike(manager).vat();
        address urn = ManagerLike(manager).urns(cdp);
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        (uint wadC, uint art) = VatLike(vat).urns(ilk, urn); 

        
        joinDaiJoin(
            urn,
            _getWipeAllWad(
                vat,
                urn,
                urn,
                ilk
            )
        );
        
        frob(
            cdp,
            -toInt(wadC),
            -int(art)
        );
        
        flux(cdp, address(this), wadC);
        
        GemJoinLike(ethJoin).exit(address(this), wadC);
        
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        
        msg.sender.transfer(wadC);
    }

    function wipeAllAndFreeGem(uint cdp, address gemJoin) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address vat = ManagerLike(manager).vat();
        address urn = ManagerLike(manager).urns(cdp);
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        (uint wadC, uint art) = VatLike(vat).urns(ilk, urn); 

        
        joinDaiJoin(
            urn,
            _getWipeAllWad(
                vat,
                urn,
                urn,
                ilk
            )
        );
        uint wad18 = convertTo18(gemJoin, wadC);
        
        frob(
            cdp,
            -toInt(wad18),
            -int(art)
        );
        
        flux(cdp, address(this), wad18);
        
        GemJoinLike(gemJoin).exit(msg.sender, wadC);
    }

    function wipeFreeGemAndShut(uint cdp, address gemJoin) public {
        wipeAllAndFreeGem(cdp, gemJoin);
        shut(cdp);
    }

    function wipeFreeEthAndShut(uint cdp) public {
        wipeAllAndFreeEth(cdp);
        shut(cdp);
    }
}