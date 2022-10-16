pragma solidity ^0.5.8;

interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}


interface ScdMcdMigration {
    function swapDaiToSai(uint daiAmt) external;
    function swapSaiToDai(uint saiAmt) external;
}

interface InstaMcdAddress {
    function migration() external returns (address payable);
}


contract Helpers {
     
    function getMcdAddresses() public pure returns (address mcd) {
        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;
    }

    
    function getSaiAddress() public pure returns (address sai) {
        sai = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    }

    
    function getDaiAddress() public pure returns (address dai) {
        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }
}


contract InstaMcdSwap is Helpers {
    function swapDaiToSai(
        uint wad 
    ) external
    {
        address scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();    
        TokenInterface dai = TokenInterface(getDaiAddress());
        dai.transferFrom(msg.sender, address(this), wad);
        if (dai.allowance(address(this), scdMcdMigration) < wad) {
            dai.approve(scdMcdMigration, wad);
        }
        ScdMcdMigration(scdMcdMigration).swapDaiToSai(wad);
        TokenInterface(getSaiAddress()).transfer(msg.sender, wad);
    }

    function swapSaiToDai(
        uint wad 
    ) external
    {
        address scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();    
        TokenInterface sai = TokenInterface(getSaiAddress());
        sai.transferFrom(msg.sender, address(this), wad);
        if (sai.allowance(address(this), scdMcdMigration) < wad) {
            sai.approve(scdMcdMigration, wad);
        }
        ScdMcdMigration(scdMcdMigration).swapSaiToDai(wad);
        TokenInterface(getDaiAddress()).transfer(msg.sender, wad);
    }
}