pragma solidity 0.5.12;


contract SaiTopAbstract {
    function vox() public view returns (address);
    function tub() public view returns (address);
    function tap() public view returns (address);
    function sai() public view returns (address);
    function sin() public view returns (address);
    function skr() public view returns (address);
    function gem() public view returns (address);
    function fix() public view returns (uint256);
    function fit() public view returns (uint256);
    function caged() public view returns (uint256);
    function cooldown() public view returns (uint256);
    function era() public view returns (uint256);
    function cage() public;
    function flow() public;
    function setCooldown(uint256) public;
    function authority() public view returns (address);
    function owner() public view returns (address);
    function setOwner(address) public;
    function setAuthority(address) public;
}

contract SaiSlayer {
    uint256 constant public T2020_05_12_1600UTC = 1589299200;
    SaiTopAbstract constant public SAITOP = SaiTopAbstract(0x9b0ccf7C8994E19F39b2B4CF708e0A7DF65fA8a3);

    function cage() public {
        require(now >= T2020_05_12_1600UTC);
        SAITOP.cage();
    }
}