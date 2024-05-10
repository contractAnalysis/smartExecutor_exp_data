pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;


contract UnlockScanner {
  
  function unlockTimestamp(address owner, address unlockContract) external returns (uint256 timestamp) {
    timestamp = 0;
    uint256 size = codeSize(unlockContract);

    if (size > 0) {
      (bool success, bytes memory data) = unlockContract.call(abi.encodeWithSelector(bytes4(0xabdf82ce), owner));
      if (success) {
        (timestamp) = abi.decode(data, (uint256));
      }
    }
  }

  
  function unlockTimestamps(address[] calldata addresses, address[] calldata contracts) external returns (uint256[][] memory timestamps) {
    timestamps = new uint256[][](addresses.length);

    for (uint256 i = 0; i < addresses.length; i++) {
      timestamps[i] = new uint256[](contracts.length);
      for (uint256 j = 0; j < contracts.length; j++) {
        timestamps[i][j] = this.unlockTimestamp(addresses[i], contracts[j]);
      }
    }
  }

  
  function codeSize(address _address) internal view returns (uint256 size) {
    assembly {
      size := extcodesize(_address)
    }
  }
}