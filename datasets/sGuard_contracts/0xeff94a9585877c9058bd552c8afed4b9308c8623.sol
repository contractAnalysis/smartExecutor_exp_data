pragma solidity ^0.6.12;

interface Poap {
    function mintToken(uint256 eventId, address to) external returns (bool);
}

contract PoapAirdrop {

    string public name;

    
    Poap POAPToken;

    
    mapping(address => bool) public claimed;

    
    bytes32 public rootHash;

    
    constructor (string memory contractName, address contractAddress, bytes32 merkleTreeRootHash) public {
        name = contractName;
        POAPToken = Poap(contractAddress);
        rootHash = merkleTreeRootHash;
    }

    
    function claim(uint256 index, address recipient, uint256[] calldata events, bytes32[] calldata proofs) external {
        require(claimed[recipient] == false, "Recipient already processed!");
        require(verify(index, recipient, events, proofs), "Recipient not in merkle tree!");

        claimed[recipient] = true;

        require(mintTokens(recipient, events), "Could not mint POAPs");
    }

    
    function verify(uint256 index, address recipient, uint256[] memory events, bytes32[] memory proofs) public view returns (bool) {

        
        bytes32 node = keccak256(abi.encodePacked(index, recipient, events));
        for (uint16 i = 0; i < proofs.length; i++) {
            bytes32 proofElement = proofs[i];
            if (proofElement < node) {
                node = keccak256(abi.encodePacked(proofElement, node));
            } else {
                node = keccak256(abi.encodePacked(node, proofElement));
            }
        }

        
        return node == rootHash;
    }

    
    function mintTokens(address recipient, uint256[] memory events) internal returns (bool) {
        for (uint256 i = 0; i < events.length; i++) {
            POAPToken.mintToken(events[i], recipient);
        }
        return true;
    }

}