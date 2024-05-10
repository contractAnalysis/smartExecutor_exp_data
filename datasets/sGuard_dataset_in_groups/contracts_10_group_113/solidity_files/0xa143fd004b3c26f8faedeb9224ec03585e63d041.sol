pragma solidity 0.5.11; 



contract TwoStepOwnable {
  address private _owner;

  address private _newPotentialOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  
  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }

  
  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    require(
      newOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  
  function cancelOwnershipTransfer() public onlyOwner {
    delete _newPotentialOwner;
  }

  
  function acceptOwnership() public {
    require(
      msg.sender == _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }
}


contract DharmaSpreadRegistryPrototypeStaging is TwoStepOwnable {
  uint256 internal _daiSpreadPerBlock;
  uint256 internal _usdcSpreadPerBlock;

  
  function setDaiSpreadPerBlock(uint256 spreadPerBlock) external onlyOwner {
    _daiSpreadPerBlock = spreadPerBlock;
  }

  
  function setUSDCSpreadPerBlock(uint256 spreadPerBlock) external onlyOwner {
    _usdcSpreadPerBlock = spreadPerBlock;
  }

  
  function getDaiSpreadPerBlock() external view returns (uint256 daiSpreadPerBlock) {
    daiSpreadPerBlock = _daiSpreadPerBlock;
  }

  
  function getUSDCSpreadPerBlock() external view returns (uint256 usdcSpreadPerBlock) {
    usdcSpreadPerBlock = _usdcSpreadPerBlock;
  }
}