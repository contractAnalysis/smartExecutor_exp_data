pragma solidity 0.5.2;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract ERC20PaymentSplitter {

  address public payerAddr;

  constructor(address _payerAddr) public {
    payerAddr = _payerAddr;
  }

  modifier onlyPayer() {
    require(msg.sender == payerAddr, "Only payer can call");
    _;
  }

 
  function split(
    address[] memory _recipients,
    uint256[] memory _splits,
    address _tokenAddr
  ) public onlyPayer {
    require(_recipients.length == _splits.length, "splits and recipients should be of the same length");
    IERC20 token = IERC20(_tokenAddr);
    for (uint i = 0; i < _recipients.length; i++) {
      token.transferFrom(payerAddr, _recipients[i], _splits[i]);
    }
  }
}