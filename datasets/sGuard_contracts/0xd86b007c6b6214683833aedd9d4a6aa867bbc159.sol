pragma solidity 0.5.17; 


interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
}














contract ApprovalBufferV1 {
    
    function () external payable {}
    
    
    function tradeEthForERC20(
        IERC20 tokenToReceive,
        uint256 tokenAmountExpected,
        address payable target,
        bytes calldata data
    ) external payable returns (uint256 tokenAmountReceived) {
        
        (bool ok,) = target.call.value(address(this).balance)(data);
        
        
        _revertOnFailure(ok);
        
        
        tokenAmountReceived = tokenToReceive.balanceOf(address(this));
        
        
        require(
            tokenAmountReceived >= tokenAmountExpected,
            "Trade did not result in the expected amount of tokens."
        );
        
        
        ok = (tokenToReceive.transfer(msg.sender, tokenAmountReceived));
        require(ok, "ERC20 transfer out failed.");
    }

    
    function tradeERC20ForEth(
        IERC20 tokenToGive,
        uint256 ethExpected,
        address target,
        bytes calldata data
    ) external returns (uint256 ethReceived) {
        
        if (tokenToGive.allowance(address(this), target) != uint256(-1)) {
            tokenToGive.approve(target, uint256(-1));
        }
        
        
        (bool ok,) = target.call(data);
        
        
        _revertOnFailure(ok);
        
        
        ethReceived = address(this).balance;

        
        require(
            ethReceived >= ethExpected,
            "Trade did not result in the expected amount of Ether."
        );
   
        
        (ok, ) = msg.sender.call.gas(4999).value(ethReceived)("");

        // Revert with reason if the call was not successful.
        _revertOnFailure(ok);
    }

    /// @notice target is the dex to call and data is the payload
    function tradeERC20ForERC20(
        IERC20 tokenToGive,
        IERC20 tokenToReceive,
        uint256 tokenAmountExpected,
        address payable target,
        bytes calldata data
    ) external payable returns (uint256 tokenAmountReceived) {
        // Ensure that target has allowance to transfer tokens.
        if (tokenToGive.allowance(address(this), target) != uint256(-1)) {
            tokenToGive.approve(target, uint256(-1));
        }
        
        // Call into the provided target, providing data.
        (bool ok,) = target.call(data);
        
        // Revert with reason if the call was not successful.
        _revertOnFailure(ok);
        
        // Determine the total token balance of this contract.
        tokenAmountReceived = tokenToReceive.balanceOf(address(this));
        
        // Ensure that enough tokens were received.
        require(
            tokenAmountReceived >= tokenAmountExpected,
            "Trade did not result in the expected amount of tokens."
        );
        
        // Transfer the tokens to the caller and revert on failure.
        ok = (tokenToReceive.transfer(msg.sender, tokenAmountReceived));
        require(ok, "ERC20 transfer out failed.");
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