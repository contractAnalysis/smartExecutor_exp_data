pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;



interface ProtocolAdapter {

    
    function adapterType() external pure returns (string memory);

    
    function tokenType() external pure returns (string memory);

    
    function getBalance(address token, address account) external view returns (uint256);
}



abstract contract MKRAdapter {
    address internal constant VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address internal constant POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address internal constant JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address internal constant MANAGER = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;

    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant BAT = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 internal constant ONE = 10 ** 27;

    function mkrRpow(uint x, uint n, uint base) internal pure returns (uint z) {
        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  
                for { n := div(n, 2) } n { n := div(n,2) } {
                let xx := mul(x, x)
                if iszero(eq(div(xx, x), x)) { revert(0,0) }
                let xxRound := add(xx, half)
                if lt(xxRound, xx) { revert(0,0) }
                x := div(xxRound, base)
                if mod(n,2) {
                    let zx := mul(z, x)
                    if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                    let zxRound := add(zx, half)
                    if lt(zxRound, zx) { revert(0,0) }
                    z := div(zxRound, base)
                }
            }
            }
        }
    }

    function mkrRmul(uint x, uint y) internal pure returns (uint z) {
        z = mkrMul(x, y) / ONE;
    }

    function mkrMul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function mkrAdd(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
}



interface Vat {
    function urns(bytes32, address) external view returns (uint256, uint256);
    function ilks(bytes32) external view returns (uint256, uint256);
}



interface Jug {
    function ilks(bytes32) external view returns (uint256, uint256);
    function base() external view returns (uint256);
}



interface DssCdpManager {
    function first(address) external view returns (uint256);
    function list(uint256) external view returns (uint256, uint256);
    function urns(uint256) external view returns (address);
    function ilks(uint256) external view returns (bytes32);
}



contract MCDDebtAdapter is ProtocolAdapter, MKRAdapter {

    string public constant override adapterType = "Debt";

    string public constant override tokenType = "ERC20";

    
    function getBalance(address, address account) external view override returns (uint256) {
        DssCdpManager manager = DssCdpManager(MANAGER);
        Vat vat = Vat(VAT);
        Jug jug = Jug(JUG);
        uint256 id = manager.first(account);
        uint256 totalValue = 0;

        while (id > 0) {
            bytes32 ilk = manager.ilks(id);
            (, id) = manager.list(id);
            (, uint256 art) = vat.urns(ilk, manager.urns(id));
            (, uint256 storedRate) = vat.ilks(ilk);
            (uint256 duty, uint256 rho) = jug.ilks(ilk);
            uint256 base = jug.base();
            
            uint256 currentRate = mkrRmul(mkrRpow(mkrAdd(base, duty), now - rho, ONE), storedRate);

            totalValue = totalValue + mkrRmul(art, currentRate);
        }

        return totalValue;
    }
}