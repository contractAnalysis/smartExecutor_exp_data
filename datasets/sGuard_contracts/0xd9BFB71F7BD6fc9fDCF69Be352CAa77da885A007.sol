pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract InstaAccount {

    

    

    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        
    
    
    function callOneInch(
        bytes memory _callData,
        uint ethAmt,
        address _target
    )
    public {
        
        
        
        
        assembly {
            let succeeded := call(gas(), _target, ethAmt, add(_callData, 0x20), mload(_callData), 0, 0)

            switch iszero(succeeded)
                case 1 {
                    
                    let size := returndatasize()
                    returndatacopy(0x00, 0x00, size)
                    revert(0x00, size)
                }
        }
        
    }
}