pragma solidity 0.5.2;

contract PaymentSplitter {

 
  function split(
    address payable[] memory _recipients,
    uint256[] memory _splits
  ) public payable {
    uint256 amount = msg.value;
    require(_recipients.length == _splits.length, "splits and recipients should be of the same length");

    uint256 sumShares = 0;
    for (uint i = 0; i < _recipients.length; i++) {
      sumShares += _splits[i];
    }

    for (uint i = 0; i < _recipients.length - 1; i++) {
      _recipients[i].transfer(amount * _splits[i] / sumShares);
    }
    
    _recipients[_recipients.length - 1].transfer(address(this).balance);
  }

}