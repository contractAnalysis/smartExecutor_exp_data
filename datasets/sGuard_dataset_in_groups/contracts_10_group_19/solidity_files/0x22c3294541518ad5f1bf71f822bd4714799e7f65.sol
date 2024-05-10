pragma solidity ^0.5.8;

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

interface JugLike {
    function drip(bytes32) external returns (uint);
}

interface oracleInterface {
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


interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
}

interface KyberInterface {
    function trade(
        address src,
        uint srcAmount,
        address dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
        ) external payable returns (uint);

    function getExpectedRate(
        address src,
        address dest,
        uint srcQty
        ) external view returns (uint, uint);
}

interface SplitSwapInterface {
    function getBest(address src, address dest, uint srcAmt) external view returns (uint bestExchange, uint destAmt);
    function ethToDaiSwap(uint splitAmt, uint slippageAmt) external payable returns (uint destAmt);
    function daiToEthSwap(uint srcAmt, uint splitAmt, uint slippageAmt) external returns (uint destAmt);
}

interface InstaMcdAddress {
    function manager() external view returns (address);
    function dai() external view returns (address);
    function daiJoin() external view returns (address);
    function vat() external view returns (address);
    function jug() external view returns (address);
    function ethAJoin() external view returns (address);
}


contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
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


contract Helpers is DSMath {

    
    function getMcdAddresses() public pure returns (address mcd) {
        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;
    }

    
    function getOracleAddress() public pure returns (address oracle) {
        oracle = 0x729D19f657BD0614b4985Cf1D82531c67569197B;
    }

    
    function getUniswapMKRExchange() public pure returns (address ume) {
        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;
    }

    
    function getUniswapDAIExchange() public pure returns (address ude) {
        ude = 0x2a1530C4C41db0B0b2bB646CB5Eb1A67b7158667;
    }

    
    function getAddressETH() public pure returns (address eth) {
        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    
    function getAddressDAI() public pure returns (address dai) {
        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    
    function getAddressKyber() public pure returns (address kyber) {
        kyber = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    }

    
    function getAddressSplitSwap() public pure returns (address payable splitSwap) {
        splitSwap = 0xc51a5024280d6AB2596e4aFFe1BDf6bDc2318da2;
    }

    
    function getAddressAdmin() public pure returns (address payable admin) {
        admin = 0x7284a8451d9a0e7Dc62B3a71C0593eA2eC5c5638;
    }

    function getVaultStats(uint cup) internal view returns (uint ethCol, uint daiDebt, uint usdPerEth) {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address urn = ManagerLike(manager).urns(cup);
        bytes32 ilk = ManagerLike(manager).ilks(cup);
        (ethCol, daiDebt) = VatLike(ManagerLike(manager).vat()).urns(ilk, urn);
        (,uint rate,,,) = VatLike(ManagerLike(manager).vat()).ilks(ilk);
        daiDebt = rmul(daiDebt, rate);
        usdPerEth = uint(oracleInterface(getOracleAddress()).read());
    }

}


contract MakerHelpers is Helpers {

    event LogLock(uint vaultId, uint amtETH, address owner);
    event LogFree(uint vaultId, uint amtETH, address owner);
    event LogDraw(uint vaultId, uint daiAmt, address owner);
    event LogWipe(uint vaultId, uint daiAmt, address owner);

    function setAllowance(TokenInterface _token, address _spender) internal {
        if (_token.allowance(address(this), _spender) != uint(-1)) {
            _token.approve(_spender, uint(-1));
        }
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

    function joinDaiJoin(address urn, uint wad) internal {
        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
        
        DaiJoinLike(daiJoin).dai().transferFrom(msg.sender, address(this), wad);
        
        DaiJoinLike(daiJoin).dai().approve(daiJoin, wad);
        
        DaiJoinLike(daiJoin).join(urn, wad);
    }

    function lock(uint cdpNum, uint wad) internal {
        if (wad > 0) {
            address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();
            address manager = InstaMcdAddress(getMcdAddresses()).manager();
            
            ManagerLike(manager).frob(cdpNum, -toInt(wad), 0);
            
            ManagerLike(manager).flux(
                cdpNum,
                address(this),
                wad
            );
            
            GemJoinLike(ethJoin).exit(address(this), wad);
            
            GemJoinLike(ethJoin).gem().withdraw(wad);
            
            emit LogLock(
                cdpNum,
                wad,
                address(this)
            );
        }
    }

    function free(uint cdp, uint wad) internal {
        if (wad > 0) {
            address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();
            address manager = InstaMcdAddress(getMcdAddresses()).manager();

            
            ManagerLike(manager).frob(
                cdp,
                -toInt(wad),
                0
            );
            
            ManagerLike(manager).flux(
                cdp,
                address(this),
                wad
            );
            
            GemJoinLike(ethJoin).exit(address(this), wad);
            
            GemJoinLike(ethJoin).gem().withdraw(wad);
            

            emit LogFree(
                cdp,
                wad,
                address(this)
            );
        }
    }

    function draw(uint cdp, uint wad) internal {
        if (wad > 0) {
            address manager = InstaMcdAddress(getMcdAddresses()).manager();
            address jug = InstaMcdAddress(getMcdAddresses()).jug();
            address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
            address urn = ManagerLike(manager).urns(cdp);
            address vat = ManagerLike(manager).vat();
            bytes32 ilk = ManagerLike(manager).ilks(cdp);
            
            ManagerLike(manager).frob(
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
            
            ManagerLike(manager).move(
                cdp,
                address(this),
                toRad(wad)
            );
            
            if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
                VatLike(vat).hope(daiJoin);
            }
            
            DaiJoinLike(daiJoin).exit(address(this), wad);

            emit LogDraw(
                cdp,
                wad,
                address(this)
            );
        }
    }

    function wipe(uint cdp, uint wad) internal {
        if (wad > 0) {
            address manager = InstaMcdAddress(getMcdAddresses()).manager();
            address vat = ManagerLike(manager).vat();
            address urn = ManagerLike(manager).urns(cdp);
            bytes32 ilk = ManagerLike(manager).ilks(cdp);

            address own = ManagerLike(manager).owns(cdp);
            if (own == address(this) || ManagerLike(manager).cdpCan(own, cdp, address(this)) == 1) {
                
                joinDaiJoin(urn, wad);
                
                ManagerLike(manager).frob(
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

            emit LogWipe(
                cdp,
                wad,
                address(this)
            );

        }
    }

}


contract GetDetails is MakerHelpers {

    function getMax(uint cdpID) public view returns (uint maxColToFree, uint maxDaiToDraw, uint ethInUSD) {
        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);
        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);
        uint minColNeeded = add(wmul(daiDebt, 1500000000000000000), 10);
        maxColToFree = wdiv(sub(colToUSD, minColNeeded), usdPerEth);
        uint maxDebtLimit = sub(wdiv(colToUSD, 1500000000000000000), 10);
        maxDaiToDraw = sub(maxDebtLimit, daiDebt);
        ethInUSD = usdPerEth;
    }

    function getSave(uint cdpID, uint ethToSwap) public view returns (uint finalEthCol, uint finalDaiDebt, uint finalColToUSD, bool canSave) {
        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);
        (finalEthCol, finalDaiDebt, finalColToUSD, canSave) = checkSave(
            ethCol,
            daiDebt,
            usdPerEth,
            ethToSwap
        );
    }

    function getLeverage(
        uint cdpID,
        uint daiToSwap
    ) public view returns (
        uint finalEthCol,
        uint finalDaiDebt,
        uint finalColToUSD,
        bool canLeverage
    )
    {
        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);
        (finalEthCol, finalDaiDebt, finalColToUSD, canLeverage) = checkLeverage(
            ethCol,
            daiDebt,
            usdPerEth,
            daiToSwap
        );
    }

    function checkSave(
        uint ethCol,
        uint daiDebt,
        uint usdPerEth,
        uint ethToSwap
    ) internal view returns
    (
        uint finalEthCol,
        uint finalDaiDebt,
        uint finalColToUSD,
        bool canSave
    )
    {
        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);
        uint minColNeeded = add(wmul(daiDebt, 1500000000000000000), 10);
        uint colToFree = wdiv(sub(colToUSD, minColNeeded), usdPerEth);
        if (ethToSwap < colToFree) {
            colToFree = ethToSwap;
        }
        (, uint expectedDAI) = SplitSwapInterface(getAddressSplitSwap()).getBest(getAddressETH(), getAddressDAI(), colToFree);
        if (expectedDAI < daiDebt) {
            finalEthCol = sub(ethCol, colToFree);
            finalDaiDebt = sub(daiDebt, expectedDAI);
            finalColToUSD = wmul(finalEthCol, usdPerEth);
            canSave = true;
        } else {
            finalEthCol = 0;
            finalDaiDebt = 0;
            finalColToUSD = 0;
            canSave = false;
        }
    }

    function checkLeverage(
        uint ethCol,
        uint daiDebt,
        uint usdPerEth,
        uint daiToSwap
    ) internal view returns
    (
        uint finalEthCol,
        uint finalDaiDebt,
        uint finalColToUSD,
        bool canLeverage
    )
    {
        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);
        uint maxDebtLimit = sub(wdiv(colToUSD, 1500000000000000000), 10);
        uint debtToBorrow = sub(maxDebtLimit, daiDebt);
        if (daiToSwap < debtToBorrow) {
            debtToBorrow = daiToSwap;
        }
        (, uint expectedETH) = SplitSwapInterface(getAddressSplitSwap()).getBest(getAddressDAI(), getAddressETH(), debtToBorrow);
        if (ethCol != 0) {
            finalEthCol = add(ethCol, expectedETH);
            finalDaiDebt = add(daiDebt, debtToBorrow);
            finalColToUSD = wmul(finalEthCol, usdPerEth);
            canLeverage = true;
        } else {
            finalEthCol = 0;
            finalDaiDebt = 0;
            finalColToUSD = 0;
            canLeverage = false;
        }
    }

}


contract Save is GetDetails {

    
    event LogTrade(
        uint what, 
        address src,
        uint srcAmt,
        address dest,
        uint destAmt,
        address beneficiary,
        uint minConversionRate,
        address affiliate
    );

    event LogSaveVault(
        uint vaultId,
        uint srcETH,
        uint destDAI
    );

    event LogLeverageVault(
        uint vaultId,
        uint srcDAI,
        uint destETH
    );


    function save(
        uint cdpID,
        uint colToSwap,
        uint splitAmt,
        uint slippageAmt
    ) public
    {
        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);
        uint colToFree = getColToFree(ethCol, daiDebt, usdPerEth);
        require(colToFree != 0, "no-collatral-to-free");
        if (colToSwap < colToFree) {
            colToFree = colToSwap;
        }
        free(cdpID, colToFree);
        uint ethToSwap = address(this).balance;
        ethToSwap = ethToSwap < colToFree ? ethToSwap : colToFree;
        uint destAmt = SplitSwapInterface(getAddressSplitSwap()).ethToDaiSwap.value(ethToSwap)(splitAmt, slippageAmt);
        uint finalDebt = sub(daiDebt, destAmt);
        require(finalDebt >= 20*10**18 || finalDebt == 0, "Final Debt should be min 20Dai.");
        wipe(cdpID, destAmt);

        emit LogSaveVault(cdpID, ethToSwap, destAmt);
    }

    function leverage(
        uint cdpID,
        uint daiToSwap,
        uint splitAmt,
        uint slippageAmt
    ) public
    {
        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);
        uint debtToBorrow = getDebtToBorrow(ethCol, daiDebt, usdPerEth);
        require(debtToBorrow != 0, "No-debt-to-borrow");
        if (daiToSwap < debtToBorrow) {
            debtToBorrow = daiToSwap;
        }
        draw(cdpID, debtToBorrow);
        TokenInterface(getAddressDAI()).approve(getAddressSplitSwap(), debtToBorrow);
        uint destAmt = SplitSwapInterface(getAddressSplitSwap()).daiToEthSwap(debtToBorrow, splitAmt, slippageAmt);
        lock(cdpID, destAmt);

        emit LogLeverageVault(cdpID, debtToBorrow, destAmt);
    }

    function getColToFree(uint ethCol, uint daiDebt, uint usdPerEth) internal pure returns (uint colToFree) {
        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);
        uint minColNeeded = add(wmul(daiDebt, 1500000000000000000), 10);
        colToFree = sub(wdiv(sub(colToUSD, minColNeeded), usdPerEth), 10);
    }

    function getDebtToBorrow(uint ethCol, uint daiDebt, uint usdPerEth) internal pure returns (uint debtToBorrow) {
        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);
        uint maxDebtLimit = sub(wdiv(colToUSD, 1500000000000000000), 10);
        debtToBorrow = sub(maxDebtLimit, daiDebt);
    }

}


contract InstaMcdSave is Save {
    function() external payable {}
}