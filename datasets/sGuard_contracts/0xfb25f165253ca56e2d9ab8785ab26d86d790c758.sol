pragma solidity 0.5.13;

contract OrchidLogger  {
    event Book(address funder, address signer, bytes shared, address target, uint128 amount, uint128 ratio, bytes receipt);

    function book(address funder, address signer, bytes calldata shared, address target, uint128 amount, uint128 ratio, bytes calldata receipt) external  {
        emit Book(funder, signer, shared, target, amount, ratio, receipt);
    }
}