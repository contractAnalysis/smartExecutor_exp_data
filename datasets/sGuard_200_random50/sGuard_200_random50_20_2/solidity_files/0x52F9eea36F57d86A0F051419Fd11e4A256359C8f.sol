pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IRegistry {
    function isValid(address handler) external view returns (bool result);
}

contract Proxy {
    address[] public tokens;

    modifier isTokenEmpty() {
        require(tokens.length == 0, "token list not empty");
        _;
    }

    function () payable external {}
    
    bytes32 private constant HANDLER_REGISTRY =
        0x6874162fd62902201ea0f4bf541086067b3b88bd802fac9e150fd2d1db584e19;

    constructor(address registry) public {
        bytes32 slot = HANDLER_REGISTRY;
        assembly {
            sstore(slot, registry)
        }
    }

    function _getRegistry() internal view returns (address registry) {
        bytes32 slot = HANDLER_REGISTRY;
        assembly {
            registry := sload(slot)
        }
    }

    function _isValid(address handler) internal view returns (bool result) {
        return IRegistry(_getRegistry()).isValid(handler);
    }

    function batchExec(address[] memory tos, bytes[] memory datas)
        isTokenEmpty
        public
        payable
    {
        _preProcess();

        for (uint256 i = 0; i < tos.length; i++) {
            require(_isValid(tos[i]), "invalid handler");
            _exec(tos[i], datas[i]);
        }

        _postProcess();
    }

    function _exec(address _to, bytes memory _data) internal returns (bytes memory result) {
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), _to, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize

            result := mload(0x40)
            mstore(0x40, add(result, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(result, size)
            returndatacopy(add(result, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                revert(add(result, 0x20), size)
            }
        }
    }

    function _preProcess() internal {
    }

    function _postProcess() internal {
        
        while (tokens.length > 0) {
            address token = tokens[tokens.length - 1];
            uint256 amount = IERC20(token).balanceOf(address(this));
            if (amount > 0)
                IERC20(token).transfer(msg.sender, amount);
            tokens.pop();
        }

        
        uint256 amount = address(this).balance;
        if (amount > 0)
            msg.sender.transfer(amount);
    }
}