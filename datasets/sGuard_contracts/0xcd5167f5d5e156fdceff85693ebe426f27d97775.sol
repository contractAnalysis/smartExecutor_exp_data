pragma solidity ^0.6.0;


contract KeyMap {
  mapping(address => bytes32[2]) private mappedKeys;

  
  function mapKey(bytes32 slice0, bytes32 slice1) external returns(address _address) {
    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0x04, 0x40)
      let mask := 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff
      _address := and(mask, keccak256(ptr, 0x40))
      calldatacopy(ptr, calldatasize(), 0x40)
    }
    mappedKeys[_address][0] = slice0;
    mappedKeys[_address][1] = slice1;
  }

  
  function mapKey(bytes calldata _pubKey) external returns(address _address) {
    require(_pubKey.length == 64, "Invalid public key.");
    bytes32[2] memory pubKey;
    assembly {
      calldatacopy(pubKey, 0x44, 0x40)
      let mask := 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff
      _address := and(mask, keccak256(pubKey, 0x40))
    }
    mappedKeys[_address][0] = pubKey[0];
    mappedKeys[_address][1] = pubKey[1];
  }

  
  function getKey(address _address) public view returns (bytes memory pubKey) {
    pubKey = new bytes(64);
    bytes32[2] memory key = mappedKeys[_address];
    require(key[0] != bytes32(0), "Key not mapped.");
    assembly {
      mstore(add(pubKey, 32), mload(key))
      mstore(add(pubKey, 64), mload(add(key, 32)))
    }
  }
}