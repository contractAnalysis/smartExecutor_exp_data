pragma solidity ^0.5.11;


contract IAlphaJobsManager {
    function broadcasters(address _broadcaster) public view returns (uint256 deposit, uint256 withdrawBlock);
}



pragma solidity ^0.5.11;



contract Refunder {
    
    IAlphaJobsManager public alphaJobsManager;

    
    mapping (address => bool) public withdrawn;

    event FundsReceived(address from, uint256 amount);
    event RefundWithdrawn(address indexed addr, uint256 amount);

    
    constructor(address _alphaJobsManagerAddr) public {
        alphaJobsManager = IAlphaJobsManager(_alphaJobsManagerAddr);
    }

    
    function() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    
    function withdraw(address payable _addr) external {
        require(
            !withdrawn[_addr],
            "address has already withdrawn alpha JobsManager refund"
        );

        (uint256 deposit,) = alphaJobsManager.broadcasters(_addr);

        require(
            deposit > 0,
            "address does not have a deposit with alpha JobsManager"
        );

        withdrawn[_addr] = true;

        _addr.transfer(deposit);

        emit RefundWithdrawn(_addr, deposit);
    }
}