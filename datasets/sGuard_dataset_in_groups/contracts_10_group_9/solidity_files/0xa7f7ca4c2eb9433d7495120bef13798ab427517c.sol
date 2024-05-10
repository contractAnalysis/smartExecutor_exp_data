pragma solidity ^0.5.7;

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
    function gem(bytes32, address) external view returns (uint);

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

interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
}

interface PepInterface {
    function peek() external returns (bytes32, bool);
}

interface MakerOracleInterface {
    function read() external view returns (bytes32);
}

interface UniswapExchange {
    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);
    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);
    function tokenToTokenSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint256 deadline,
        address tokenAddr
        ) external returns (uint256  tokensSold);
}

interface PoolInterface {
    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;
    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;
}

interface CTokenInterface {
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) external returns (uint);
    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;
    function exchangeRateCurrent() external returns (uint);
    function getCash() external view returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function totalReserves() external view returns (uint);
    function reserveFactorMantissa() external view returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);

    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function allowance(address, address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

interface CERC20Interface {
    function mint(uint mintAmount) external returns (uint); 
    function repayBorrow(uint repayAmount) external returns (uint); 
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint); 
    function borrowBalanceCurrent(address account) external returns (uint);
}

interface CETHInterface {
    function mint() external payable; 
    function repayBorrow() external payable; 
    function repayBorrowBehalf(address borrower) external payable; 
    function borrowBalanceCurrent(address account) external returns (uint);
}

interface ComptrollerInterface {
    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    function exitMarket(address cTokenAddress) external returns (uint);
    function getAssetsIn(address account) external view returns (address[] memory);
    function getAccountLiquidity(address account) external view returns (uint, uint, uint);
}

interface CompOracleInterface {
    function getUnderlyingPrice(address) external view returns (uint);
}

interface InstaMcdAddress {
    function manager() external view returns (address);
    function dai() external view returns (address);
    function daiJoin() external view returns (address);
    function vat() external view returns (address);
    function jug() external view returns (address);
    function ethAJoin() external view returns (address);
}

interface OtcInterface {
    function getPayAmount(address, address, uint) external view returns (uint);
    function buyAllAmount(
        address,
        uint,
        address,
        uint
    ) external;
}


contract DSMath {

    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y <= x ? x - y : 0;
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }

}


contract Helper is DSMath {

    
    function getAddressETH() public pure returns (address eth) {
        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    
    function getMcdAddresses() public pure returns (address mcd) {
        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;
    }

    
    function getPoolAddr() public pure returns (address poolAddr) {
        poolAddr = 0x1564D040EC290C743F67F5cB11f3C1958B39872A;
    }

    
    function getComptrollerAddress() public pure returns (address troller) {
        troller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    }

    
    function getCETHAddress() public pure returns (address cEth) {
        cEth = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    }

    
    function getDAIAddress() public pure returns (address dai) {
        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    
    function getCDAIAddress() public pure returns (address cDai) {
        cDai = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    }

    
    function setApproval(address erc20, uint srcAmt, address to) internal {
        TokenInterface erc20Contract = TokenInterface(erc20);
        uint tokenAllowance = erc20Contract.allowance(address(this), to);
        if (srcAmt > tokenAllowance) {
            erc20Contract.approve(to, uint(-1));
        }
    }

}


contract InstaPoolResolver is Helper {

    function accessDai(uint daiAmt, bool isCompound) internal {
        address[] memory borrowAddr = new address[](1);
        uint[] memory borrowAmt = new uint[](1);
        borrowAddr[0] = getCDAIAddress();
        borrowAmt[0] = daiAmt;
        PoolInterface(getPoolAddr()).accessToken(borrowAddr, borrowAmt, isCompound);

    }

    function returnDai(uint daiAmt, bool isCompound) internal {
        address[] memory borrowAddr = new address[](1);
        borrowAddr[0] = getCDAIAddress();
        require(TokenInterface(getDAIAddress()).transfer(getPoolAddr(), daiAmt), "Not-enough-DAI");
        PoolInterface(getPoolAddr()).paybackToken(borrowAddr, isCompound);
    }

}


contract MakerHelper is InstaPoolResolver {

    event LogOpen(uint cdpNum, address owner);
    event LogLock(uint cdpNum, uint amtETH, address owner);
    event LogFree(uint cdpNum, uint amtETH, address owner);
    event LogDraw(uint cdpNum, uint daiAmt, address owner);
    event LogWipe(uint cdpNum, uint daiAmt, address owner);

    
    function setMakerAllowance(TokenInterface _token, address _spender) internal {
        if (_token.allowance(address(this), _spender) != uint(-1)) {
            _token.approve(_spender, uint(-1));
        }
    }

    
    function checkVault(uint id, uint ethAmt, uint daiAmt) internal view returns (uint ethCol, uint daiDebt) {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address urn = ManagerLike(manager).urns(id);
        bytes32 ilk = ManagerLike(manager).ilks(id);
        uint art = 0;
        (ethCol, art) = VatLike(ManagerLike(manager).vat()).urns(ilk, urn);
        (,uint rate,,,) = VatLike(ManagerLike(manager).vat()).ilks(ilk);
        daiDebt = rmul(art,rate);
        daiDebt = daiAmt < daiDebt ? daiAmt : daiDebt; 
        ethCol = ethAmt < ethCol ? ethAmt : ethCol; 
    }

    function joinDaiJoin(address urn, uint wad) internal {
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

    function _getWipeDart(
        address vat,
        uint dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart)
    {
        
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        
        (, uint art) = VatLike(vat).urns(ilk, urn);

        
        dart = toInt(dai / rate);
        
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    function joinEthJoin(address urn, uint _wad) internal {
        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();
        
        GemJoinLike(ethJoin).gem().deposit.value(_wad)();
        
        GemJoinLike(ethJoin).gem().approve(address(ethJoin), _wad);
        
        GemJoinLike(ethJoin).join(urn, _wad);
    }

    function joinGemJoin(
        address apt,
        address urn,
        uint wad,
        bool transferFrom
    ) internal
    {
        
        if (transferFrom) {
            
            GemJoinLike(apt).gem().transferFrom(msg.sender, address(this), wad);
            
            GemJoinLike(apt).gem().approve(apt, wad);
        }
        
        GemJoinLike(apt).join(urn, wad);
    }
}


contract CompoundHelper is MakerHelper {

    event LogMint(address erc20, address cErc20, uint tokenAmt, address owner);
    event LogRedeem(address erc20, address cErc20, uint tokenAmt, address owner);
    event LogBorrow(address erc20, address cErc20, uint tokenAmt, address owner);
    event LogRepay(address erc20, address cErc20, uint tokenAmt, address owner);

    
    function enterMarket(address cErc20) internal {
        ComptrollerInterface troller = ComptrollerInterface(getComptrollerAddress());
        address[] memory markets = troller.getAssetsIn(address(this));
        bool isEntered = false;
        for (uint i = 0; i < markets.length; i++) {
            if (markets[i] == cErc20) {
                isEntered = true;
            }
        }
        if (!isEntered) {
            address[] memory toEnter = new address[](1);
            toEnter[0] = cErc20;
            troller.enterMarkets(toEnter);
        }
    }

}


contract MakerResolver is CompoundHelper {
    function flux(uint cdp, address dst, uint wad) internal {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).flux(cdp, dst, wad);
    }

    function move(uint cdp, address dst, uint rad) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).move(cdp, dst, rad);
    }

    function frob(uint cdp, int dink, int dart) internal {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).frob(cdp, dink, dart);
    }

    function open() public returns (uint cdp) {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        bytes32 ilk = 0x4554482d41000000000000000000000000000000000000000000000000000000;
        cdp = ManagerLike(manager).open(ilk, address(this));
        emit LogOpen(cdp, address(this));
    }

    function give(uint cdp, address usr) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).give(cdp, usr);
    }

    function lock(uint cdp, uint _wad) internal {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        
        joinEthJoin(address(this), _wad);
        
        VatLike(ManagerLike(manager).vat()).frob(
            ManagerLike(manager).ilks(cdp),
            ManagerLike(manager).urns(cdp),
            address(this),
            address(this),
            toInt(_wad),
            0
        );
        emit LogLock(cdp, _wad, address(this));
    }

    function free(uint cdp, uint wad) internal {
        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();
        
        frob(
            cdp,
            -toInt(wad),
            0
        );
        
        flux(
            cdp,
            address(this),
            wad
        );
        
        GemJoinLike(ethJoin).exit(address(this), wad);
        
        GemJoinLike(ethJoin).gem().withdraw(wad);
        emit LogFree(cdp, wad, address(this));
    }

    function draw(uint cdp, uint wad) internal {
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
        
        DaiJoinLike(daiJoin).exit(address(this), wad);
        emit LogDraw(cdp, wad, address(this));

    }

    function wipe(uint cdp, uint wad) internal {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address vat = ManagerLike(manager).vat();
        address urn = ManagerLike(manager).urns(cdp);
        bytes32 ilk = ManagerLike(manager).ilks(cdp);

        address own = ManagerLike(manager).owns(cdp);
        if (own == address(this) || ManagerLike(manager).cdpCan(own, cdp, address(this)) == 1) {
            
            joinDaiJoin(urn, wad);
            
            frob(
                cdp,
                0,
                _getWipeDart(
                    vat,
                    VatLike(vat).dai(urn),
                    urn,
                    ilk
                )
            );
        } else {
             
            joinDaiJoin(address(this), wad);
            
            VatLike(vat).frob(
                ilk,
                urn,
                address(this),
                address(this),
                0,
                _getWipeDart(
                    vat,
                    wad * RAY,
                    urn,
                    ilk
                )
            );
        }
        emit LogWipe(cdp, wad, address(this));
    }

    
    function wipeAndFreeMaker(
        uint cdpNum,
        uint jam,
        uint _wad,
        bool isCompound
    ) internal
    {
        accessDai(_wad, isCompound);
        wipe(cdpNum, _wad);
        free(cdpNum, jam);
    }

    
    function lockAndDrawMaker(
        uint cdpNum,
        uint jam,
        uint _wad,
        bool isCompound
    ) internal
    {
        lock(cdpNum, jam);
        draw(cdpNum, _wad);
        returnDai(_wad, isCompound);
    }

}


contract CompoundResolver is MakerResolver {

    
    function mintCEth(uint tokenAmt) internal {
        enterMarket(getCETHAddress());
        CETHInterface cToken = CETHInterface(getCETHAddress());
        cToken.mint.value(tokenAmt)();
        emit LogMint(
            getAddressETH(),
            getCETHAddress(),
            tokenAmt,
            msg.sender
        );
    }

    
    function borrowDAIComp(uint daiAmt, bool isCompound) internal {
        enterMarket(getCDAIAddress());
        require(CTokenInterface(getCDAIAddress()).borrow(daiAmt) == 0, "got collateral?");
        
        returnDai(daiAmt, isCompound);
        emit LogBorrow(
            getDAIAddress(),
            getCDAIAddress(),
            daiAmt,
            address(this)
        );
    }

    
    function repayDaiComp(uint tokenAmt, bool isCompound) internal returns (uint wipeAmt) {
        CERC20Interface cToken = CERC20Interface(getCDAIAddress());
        uint daiBorrowed = cToken.borrowBalanceCurrent(address(this));
        wipeAmt = tokenAmt < daiBorrowed ? tokenAmt : daiBorrowed;
        
        accessDai(wipeAmt, isCompound);
        setApproval(getDAIAddress(), wipeAmt, getCDAIAddress());
        require(cToken.repayBorrow(wipeAmt) == 0, "transfer approved?");
        emit LogRepay(
            getDAIAddress(),
            getCDAIAddress(),
            wipeAmt,
            address(this)
        );
    }

    
    function redeemCETH(uint tokenAmt) internal returns(uint ethAmtReddemed) {
        CTokenInterface cToken = CTokenInterface(getCETHAddress());
        uint cethBal = cToken.balanceOf(address(this));
        uint exchangeRate = cToken.exchangeRateCurrent();
        uint cethInEth = wmul(cethBal, exchangeRate);
        setApproval(getCETHAddress(), 2**128, getCETHAddress());
        ethAmtReddemed = tokenAmt;
        if (tokenAmt > cethInEth) {
            require(cToken.redeem(cethBal) == 0, "something went wrong");
            ethAmtReddemed = cethInEth;
        } else {
            require(cToken.redeemUnderlying(tokenAmt) == 0, "something went wrong");
        }
        emit LogRedeem(
            getAddressETH(),
            getCETHAddress(),
            ethAmtReddemed,
            address(this)
        );
    }

    
    function mintAndBorrowComp(uint ethAmt, uint daiAmt, bool isCompound) internal {
        mintCEth(ethAmt);
        borrowDAIComp(daiAmt, isCompound);
    }

    
    function paybackAndRedeemComp(uint ethCol, uint daiDebt, bool isCompound) internal returns (uint ethAmt, uint daiAmt) {
        daiAmt = repayDaiComp(daiDebt, isCompound);
        ethAmt = redeemCETH(ethCol);
    }

    
    function checkCompound(uint ethAmt, uint daiAmt) internal returns (uint ethCol, uint daiDebt) {
        CTokenInterface cEthContract = CTokenInterface(getCETHAddress());
        uint cEthBal = cEthContract.balanceOf(address(this));
        uint ethExchangeRate = cEthContract.exchangeRateCurrent();
        ethCol = wmul(cEthBal, ethExchangeRate);
        ethCol = wdiv(ethCol, ethExchangeRate) <= cEthBal ? ethCol : ethCol - 1;
        ethCol = ethCol <= ethAmt ? ethCol : ethAmt; 

        daiDebt = CERC20Interface(getCDAIAddress()).borrowBalanceCurrent(address(this));
        daiDebt = daiDebt <= daiAmt ? daiDebt : daiAmt; 
    }

}


contract BridgeResolver is CompoundResolver {

    event LogVaultToCompound(uint ethAmt, uint daiAmt);
    event LogCompoundToVault(uint ethAmt, uint daiAmt);

    
    function makerToCompound(
        uint cdpId,
        uint ethQty,
        uint daiQty,
        bool isCompound 
    ) external
    {
        
        uint initialPoolBal = sub(getPoolAddr().balance, 10000000000);

        (uint ethAmt, uint daiAmt) = checkVault(cdpId, ethQty, daiQty);
        wipeAndFreeMaker(
            cdpId,
            ethAmt,
            daiAmt,
            isCompound
        ); 

        enterMarket(getCETHAddress());
        enterMarket(getCDAIAddress());
        mintAndBorrowComp(ethAmt, daiAmt, isCompound); 

        uint finalPoolBal = getPoolAddr().balance;
        assert(finalPoolBal >= initialPoolBal);

        emit LogVaultToCompound(ethAmt, daiAmt);
    }

    
    function compoundToMaker(
        uint cdpId,
        uint ethQty,
        uint daiQty,
        bool isCompound
    ) external
    {
        
        uint initialPoolBal = sub(getPoolAddr().balance, 10000000000);

        uint cdpNum = cdpId > 0 ? cdpId : open();
        (uint ethCol, uint daiDebt) = checkCompound(ethQty, daiQty);
        (uint ethAmt, uint daiAmt) = paybackAndRedeemComp(ethCol, daiDebt, isCompound); 
        ethAmt = ethAmt < address(this).balance ? ethAmt : address(this).balance;
        lockAndDrawMaker(
            cdpNum,
            ethAmt,
            daiAmt,
            isCompound
        ); 

        uint finalPoolBal = getPoolAddr().balance;
        assert(finalPoolBal >= initialPoolBal);

        emit LogCompoundToVault(ethAmt, daiAmt);
    }
}


contract InstaVaultCompBridge is BridgeResolver {
    function() external payable {}
}