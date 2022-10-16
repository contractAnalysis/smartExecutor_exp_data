pragma solidity 0.5.16;


interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}


contract EthToDaiTradeHelperV2 {
    IERC20 internal constant _DAI = IERC20(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    
    function trade(
        address payable target, bytes calldata data
    ) external payable returns (uint256 daiReceived) {
        
        (bool ok,) = target.call.value(address(this).balance)(data);
        
        
        _revertOnFailure(ok);
        
        
        daiReceived = _DAI.balanceOf(address(this));
        
        
        ok = (_DAI.transfer(msg.sender, daiReceived));
        require(ok, "Dai transfer out failed.");
    }
    
    function _revertOnFailure(bool ok) internal pure {
        if (!ok) {
            assembly {
                returndatacopy(0, 0, returndatasize)
                revert(0, returndatasize)
            }
        }
    }
}