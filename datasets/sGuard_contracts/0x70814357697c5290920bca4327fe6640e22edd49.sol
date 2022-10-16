pragma solidity ^0.6.0;

contract DropETH { 
    event ETHDropped(string indexed message);
    
    function dropETH(address payable[] memory recipients, string memory message) public payable {
        uint256 amount = msg.value / recipients.length;
        for (uint256 i = 0; i < recipients.length; i++) {
	         recipients[i].transfer(amount);
        }
        emit ETHDropped(message);
    }
}