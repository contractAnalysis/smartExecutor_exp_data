pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract InstaAccount {
    
    function callOneInch(
        bytes calldata _callData,
        uint ethAmt,
        address _target
    )
    external payable{
        
        
        
        
        bytes memory datas = _callData;
        assembly {
            let succeeded := call(gas(), _target, ethAmt, add(datas, 0x20), mload(datas), 0, 0)

            switch iszero(succeeded)
                case 1 {
                    
                    let size := returndatasize()
                    returndatacopy(0x00, 0x00, size)
                    revert(0x00, size)
                }
        }
        
    }
    
    function external_call(bytes calldata data, uint value, address destination) external payable returns (bool) {
        bool result;
        bytes memory datas = data;
        uint dataLength = data.length;
        assembly {
            let x := mload(0x40)   
            let d := add(datas, 32) 
            result := call(
                sub(gas(), 34710),   
                                   
                                   
                destination,
                value,
                d,
                dataLength,        
                x,
                0                  
            )
        }
        return result;
    }
}