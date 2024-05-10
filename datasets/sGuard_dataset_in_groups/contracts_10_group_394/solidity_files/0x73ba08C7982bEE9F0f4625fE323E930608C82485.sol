pragma solidity ^0.5.0;

contract Box {
    uint256 private value;

    
    event ValueChanged(uint256 newValue);

    
    function store(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }

    
    function retrieve() public view returns (uint256) {
        return value;
    }
}