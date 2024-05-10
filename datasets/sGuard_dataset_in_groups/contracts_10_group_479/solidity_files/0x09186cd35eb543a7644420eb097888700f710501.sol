pragma solidity ^0.5.0;

contract IFreeFromUpTo {
    function freeFromUpTo(address from, uint256 value) external returns(uint256 freed);
}

contract ChiGasSaver {

    modifier saveGas(address payable sponsor) {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;

        IFreeFromUpTo chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
        chi.freeFromUpTo(sponsor, (gasSpent + 14154) / 41947);
    }
}



pragma solidity >=0.5.0 <0.6.0;




contract GasSaverDeployerV1 is ChiGasSaver {

    
    function deployAndExecute(bytes memory _code, bytes memory _data)
    public
    payable
    saveGas(msg.sender)
    returns (address target, bytes memory response) {
        target = _deploy(_code);

        
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), target, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
            
                revert(add(response, 0x20), size)
            }
        }
    }

    
    function deploy(bytes memory _code)
    public
    saveGas(msg.sender)
    returns (address target) {
        target = _deploy(_code);
    }

    function _deploy(bytes memory _code)
    internal
    returns (address target) {
        assembly {
            target := create(0, add(_code, 0x20), mload(_code))
            switch iszero(extcodesize(target))
            case 1 {
            
                revert(0, 0)
            }
        }
    }
}