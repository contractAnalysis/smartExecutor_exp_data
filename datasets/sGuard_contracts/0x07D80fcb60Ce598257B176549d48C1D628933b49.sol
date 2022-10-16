pragma solidity 0.6.10;

interface ITokenVesting {
    function release(address token) external;
}


contract MultiRelease {
    function release(ITokenVesting[] memory tokenVestings, address token) external {
        require(tokenVestings.length > 0);
        for (uint256 i = 0; i < tokenVestings.length; i++) {
            tokenVestings[i].release(token);
        }
    }
}