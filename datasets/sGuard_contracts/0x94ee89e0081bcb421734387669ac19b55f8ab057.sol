pragma solidity 0.5.13;

interface OrchidVerifier {
    function book(address funder, address signer, bytes calldata shared, address target, uint128 amount, uint128 ratio, bytes calldata receipt) external pure;
}

contract OrchidFailer is OrchidVerifier {
    function kill() external {
        selfdestruct(msg.sender);
    }

    function book(address, address, bytes calldata, address, uint128, uint128, bytes calldata) external pure {
        require(false);
    }
}