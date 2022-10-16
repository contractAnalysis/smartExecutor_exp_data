pragma solidity ^0.5.0;

interface IUnderlyingTokenValuator {

    
    function getTokenValue(address token, uint amount) external view returns (uint);

}



pragma solidity ^0.5.0;

library StringHelpers {

    function toString(address _address) public pure returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++) {
            b[i] = byte(uint8(uint(_address) / (2 ** (8 * (19 - i)))));
        }
        return string(b);
    }

}



pragma solidity ^0.5.0;



contract UnderlyingTokenValuatorImplV1 is IUnderlyingTokenValuator {

    using StringHelpers for address;

    address public dai;
    address public usdc;

    constructor(
        address _dai,
        address _usdc
    ) public {
        dai = _dai;
        usdc = _usdc;
    }

    
    function getTokenValue(address token, uint amount) public view returns (uint) {
        if (token == usdc) {
            return amount;
        } else if (token == dai) {
            return amount;
        } else {
            revert(string(abi.encodePacked("Invalid token, found: ", token.toString())));
        }
    }

}