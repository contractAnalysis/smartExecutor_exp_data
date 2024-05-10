pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function decimals() external view returns (uint);
}

contract InstaAccount {
    
    function callOneInch(
        bytes calldata _callData,
        uint ethAmt,
        address payable _target
    )
    external payable{
        
        
        
        
        (bool success, bytes memory data) = _target.call.value(ethAmt)(_callData);
        if (!success) revert("Failed");
        
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