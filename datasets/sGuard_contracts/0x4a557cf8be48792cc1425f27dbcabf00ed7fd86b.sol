pragma solidity ^0.5.11;

contract Ownable {
    function acceptOwnership() public;
}



contract Burn_Ownership {
    function burnOwnership(address _contract) public {
        Ownable(_contract).acceptOwnership();
    }
}