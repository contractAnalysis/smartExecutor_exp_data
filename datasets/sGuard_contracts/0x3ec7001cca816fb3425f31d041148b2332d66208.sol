pragma solidity 0.5.14;

interface IToken { 
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract LexDAOMagickBatonSpell01 {
    address public accessToken = 0x027fa7C653fBfD1Fe49Bcf930a0E40fc429bCC72; 
    address public leethToken = 0x4D9D9a22458dD84dB8B0D074470f5d9536116eC5; 
    IToken private token = IToken(accessToken);
    IToken private leeth = IToken(leethToken);

    function castSpell() public { 
        require(token.balanceOf(msg.sender) >= 1, "token balance insufficient");
        leeth.transfer(msg.sender, leeth.balanceOf(address(this)));
    }
}