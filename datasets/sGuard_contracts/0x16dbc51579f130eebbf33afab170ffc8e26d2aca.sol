pragma solidity ^0.6.0;

contract GetVotesHardCapFunctionality {

    function onStop(address) public {
    }

    function onStart(address,address) public {
    }

    function getVotesHardCap() public view returns(uint256) {
        return 5900000000000000000;
    }
}