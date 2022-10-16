pragma solidity 0.6.2; 


contract EthReturner {
    constructor() public payable {
        selfdestruct(tx.origin);
    }
}



contract ExampleWildcardResolver {
  bytes32 private constant _INIT_CODE_HASH = keccak256(
    type(EthReturner).creationCode
  );
    
  function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
    return interfaceID == 0x3b3b57de;
  }

  function addr(bytes32 nodeID) external view returns (address) {
    return _getWildcardAddress(nodeID);
  }
    
  function returnEthToTxOrigin(bytes32 nodeID) external {
    new EthReturner{salt: nodeID}();
  }
    
  function _getWildcardAddress(bytes32 salt) internal view returns (address) {
    return address(              
      uint160(                   
        uint256(                 
          keccak256(             
            abi.encodePacked(    
              bytes1(0xff),      
              address(this),     
              salt,              
              _INIT_CODE_HASH    
            )
          )
        )
      )
    );
  }
}