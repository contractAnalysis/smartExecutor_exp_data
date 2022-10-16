pragma solidity ^0.5.16;


library Math {
    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
    }
}



pragma solidity ^0.5.16;



contract MarmoImp {
    uint256 private constant EXTRA_GAS = 21000;

    event Receipt(
        bytes32 indexed _id,
        bool _success,
        bytes _result
    );

    
    
    
    function() external payable {
        
        (
            bytes32 id,
            bytes memory data
        ) = abi.decode(
            msg.data, (
                bytes32,
                bytes
            )
        );

        
        bytes memory dependency;
        address to;
        uint256 value;
        uint256 maxGasLimit;
        uint256 maxGasPrice;
        uint256 expiration;

        (
            dependency,
            to,
            value,
            data,
            maxGasLimit,
            maxGasPrice,
            expiration
        ) = abi.decode(
            data, (
                bytes,
                address,
                uint256,
                bytes,
                uint256,
                uint256,
                uint256
            )
        );

        
        require(now < expiration, "Intent is expired");
        require(tx.gasprice < maxGasPrice, "Gas price too high");
        require(_checkDependency(dependency), "Dependency is not satisfied");

        
        
        
        (
            bool success,
            bytes memory result
        ) = to.call.gas(
            Math.min(
                block.gaslimit - EXTRA_GAS,
                maxGasLimit
            )
        ).value(value)(data);

        
        emit Receipt(
            id,
            success,
            result
        );
    }

    
    
    
    function _checkDependency(bytes memory _dependency) internal view returns (bool result) {
        if (_dependency.length == 0) {
            result = true;
        } else {
            assembly {
                let response := mload(0x40)
                let success := staticcall(
                    gas,
                    mload(add(_dependency, 20)),
                    add(52, _dependency),
                    sub(mload(_dependency), 20),
                    response,
                    32
                )

                result := and(gt(success, 0), gt(mload(response), 0))
            }
        }
    }
}