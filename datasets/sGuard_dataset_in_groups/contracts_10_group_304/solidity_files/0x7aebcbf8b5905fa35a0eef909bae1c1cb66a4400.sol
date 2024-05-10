pragma solidity ^0.4.21;


contract Hourglass {
    function reinvest() public {}
    function myTokens() public view returns(uint256) {}
    function myDividends(bool) public view returns(uint256) {}
}

contract RainMaker {
    Hourglass eWLTH;
    address public eWLTHAddress = 0x5833C959C3532dD5B3B6855D590D70b01D2d9fA6;

    function RainMaker() public {
        eWLTH = Hourglass(eWLTHAddress);
    }

    function makeItRain() public {
        eWLTH.reinvest();
    }

    function myTokens() public view returns(uint256) {
        return eWLTH.myTokens();
    }
    
    function myDividends() public view returns(uint256) {
        return eWLTH.myDividends(true);
    }
}