pragma solidity ^0.5.0;



contract EthereumProxy {
  
  event TransferWithReference(address to, uint256 amount, bytes indexed paymentReference);

  
  function() external payable {
    revert("not payable fallback");
  }

  
  function transferWithReference(address payable _to, bytes calldata _paymentReference)
    external
    payable
  {
    _to.transfer(msg.value);
    emit TransferWithReference(_to, msg.value, _paymentReference);
  }
}