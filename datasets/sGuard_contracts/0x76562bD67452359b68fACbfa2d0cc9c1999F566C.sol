pragma solidity ^0.4.26;


contract LockMapping {

  Receipt[] public receipts;
  uint256 public receiptCount;

	struct Receipt {

		address asset;
	    address owner;		
	    string targetAddress;
	    uint256 amount;
	    uint256 startTime;
	    uint256 endTime;
	    bool finished;

  	}
}

contract Owned {
    address public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract MerkleTreeGenerator is Owned {

    using SafeMath for uint256;
	event Log(bytes data);

	LockMapping candyReceipt = LockMapping(0x91517330816D4727EDc7C3F5Ae4CC5beF02Ec70f);

	uint256 constant pathMaximalLength = 7;
	uint256 constant public MerkleTreeMaximalLeafCount = 1 << pathMaximalLength;
	uint256 constant treeMaximalSize = MerkleTreeMaximalLeafCount * 2;
	uint256 public MerkleTreeCount = 0;
	uint256 public ReceiptCountInTree = 0;
	mapping (uint256 => MerkleTree) indexToMerkleTree;

	struct MerkleTree {
		bytes32 root;
		uint256 leaf_count;
        uint256 first_recipt_id;
        uint256 size;
  	}

  	struct MerkleNode {

		bytes32 hash;
		bool is_left_child_node;

  	}

  	struct MerklePath {
  	    MerkleNode[] merkle_path_nodes;
  	}

  	struct Receipt {

		  address asset;		
	    address owner;		
	    string targetAddress;
	    uint256 amount;
	    uint256 startTime;
	    uint256 endTime;
	    bool finished;

  	}



  	
  	function ReceiptsToLeaves(uint256 _start, uint256 _leafCount, bool _event) internal returns (bytes32[]){
  	    bytes32[] memory leaves = new bytes32[](_leafCount);

		for(uint256 i = _start; i< _start + _leafCount; i++) {
            (
    		    ,
    		    ,
    		    string memory targetAddress,
    		    uint256 amount,
    		    ,
    		    ,
    		    bool finished
		    ) = candyReceipt.receipts(i);


		    bytes32 amountHash = sha256(amount);
		    bytes32 targetAddressHash = sha256(targetAddress);
		    bytes32 receiptIdHash = sha256(i);

		    leaves[i - _start] = (sha256(amountHash, targetAddressHash, receiptIdHash));

		    if(_event)
		        Log(abi.encodePacked(amountHash, targetAddressHash, receiptIdHash));
        }

        return leaves;
  	}

  	 	
	function GenerateMerkleTree() external onlyOwner {

        uint256 receiptCount = candyReceipt.receiptCount() - ReceiptCountInTree;

		require(receiptCount > 0);

		uint256 leafCount = receiptCount < MerkleTreeMaximalLeafCount ? receiptCount : MerkleTreeMaximalLeafCount;
        bytes32[] memory leafNodes = ReceiptsToLeaves(ReceiptCountInTree, leafCount, true);


        bytes32[treeMaximalSize] memory allNodes;
  	    uint256 nodeCount;

  	    (allNodes, nodeCount) = LeavesToTree(leafNodes);

		MerkleTree memory merkleTree = MerkleTree(allNodes[nodeCount - 1], leafCount, ReceiptCountInTree, nodeCount);

		indexToMerkleTree[MerkleTreeCount] = merkleTree;
		ReceiptCountInTree = ReceiptCountInTree + leafCount;
		MerkleTreeCount = MerkleTreeCount + 1;
  	}

  	
  	function GenerateMerklePath(uint256 receiptId) public view returns(uint256, uint256, bytes32[pathMaximalLength], bool[pathMaximalLength]) {

  	    require(receiptId < ReceiptCountInTree);
  	    uint256 treeIndex = MerkleTreeCount - 1;
  	    for (; treeIndex >= 0 ; treeIndex--){

  	        if (receiptId >= indexToMerkleTree[treeIndex].first_recipt_id)
  	            break;
  	    }

  	    bytes32[pathMaximalLength] memory neighbors;
  	    bool[pathMaximalLength] memory isLeftNeighbors;
  	    uint256 pathLength;

  	    MerkleTree merkleTree = indexToMerkleTree[treeIndex];
  	    uint256 index = receiptId - merkleTree.first_recipt_id;
  	    (pathLength, neighbors, isLeftNeighbors) = GetPath(merkleTree, index);
  	    return (treeIndex, pathLength, neighbors, isLeftNeighbors);

  	}

  	function LeavesToTree(bytes32[] _leaves) internal returns (bytes32[treeMaximalSize], uint256){
        uint256 leafCount = _leaves.length;
		bytes32 left;
		bytes32 right;

        uint256 newAdded = 0;
		uint256 i = 0;

		bytes32[treeMaximalSize] memory nodes;

		for (uint256 t = 0; t < leafCount ; t++)
		{
		    nodes[t] = _leaves[t];
		}

		uint256 nodeCount = leafCount;
        if(_leaves.length % 2 == 1) {
            nodes[leafCount] = (_leaves[leafCount - 1]);
            nodeCount = nodeCount + 1;
        }


        
        uint256 nodeToAdd = nodeCount / 2;

		while( i < nodeCount - 1) {

		    left = nodes[i++];
            right = nodes[i++];
            nodes[nodeCount++] = sha256(left,right);
            if (++newAdded != nodeToAdd)
                continue;

            if (nodeToAdd % 2 == 1 && nodeToAdd != 1)
            {
                nodeToAdd++;
                nodes[nodeCount] = nodes[nodeCount - 1];
                nodeCount++;
            }

            nodeToAdd /= 2;
            newAdded = 0;
		}

		return (nodes, nodeCount);
  	}

  	function GetPath(MerkleTree _merkleTree, uint256 _index) internal returns(uint256, bytes32[pathMaximalLength],bool[pathMaximalLength]){

  	    bytes32[] memory leaves = ReceiptsToLeaves(_merkleTree.first_recipt_id, _merkleTree.leaf_count, false);
  	    bytes32[treeMaximalSize] memory allNodes;
  	    uint256 nodeCount;

  	    (allNodes, nodeCount)= LeavesToTree(leaves);
  	    require(nodeCount == _merkleTree.size);

  	    bytes32[] memory nodes = new bytes32[](_merkleTree.size);
  	    for (uint256 t = 0; t < _merkleTree.size; t++){
  	        nodes[t] = allNodes[t];
  	    }

  	    return GeneratePath(nodes, _merkleTree.leaf_count, _index);
  	}

  	function GeneratePath(bytes32[] _nodes, uint256 _leafCount, uint256 _index) internal returns(uint256, bytes32[pathMaximalLength],bool[pathMaximalLength]){
  	    bytes32[pathMaximalLength] memory neighbors;
  	    bool[pathMaximalLength] memory isLeftNeighbors;
  	    uint256 indexOfFirstNodeInRow = 0;
  	    uint256 nodeCountInRow = _leafCount;
  	    bytes32 neighbor;
  	    bool isLeftNeighbor;
  	    uint256 shift;
  	    uint256 i = 0;

  	    while (_index < _nodes.length - 1) {

            if (_index % 2 == 0)
            {
                
                neighbor = _nodes[_index + 1];
                isLeftNeighbor = false;
            }
            else
            {
                
                neighbor = _nodes[_index - 1];
                isLeftNeighbor = true;
            }

            neighbors[i] = neighbor;
            isLeftNeighbors[i++] = isLeftNeighbor;

            nodeCountInRow = nodeCountInRow % 2 == 0 ? nodeCountInRow : nodeCountInRow + 1;
            shift = (_index - indexOfFirstNodeInRow) / 2;
            indexOfFirstNodeInRow += nodeCountInRow;
            _index = indexOfFirstNodeInRow + shift;
            nodeCountInRow /= 2;

  	    }

  	    return (i, neighbors,isLeftNeighbors);
  	}

    function GetMerkleTreeNodes(uint256 treeIndex) public view returns (bytes32[], uint256){
        MerkleTree merkleTree = indexToMerkleTree[treeIndex];
  	    bytes32[] memory leaves = ReceiptsToLeaves(merkleTree.first_recipt_id, merkleTree.leaf_count, false);
  	    bytes32[treeMaximalSize] memory allNodes;
  	    uint256 nodeCount;

  	    (allNodes, nodeCount)= LeavesToTree(leaves);
  	    require(nodeCount == merkleTree.size);

  	    bytes32[] memory nodes = new bytes32[](merkleTree.size);
  	    for (uint256 t = 0; t < merkleTree.size; t++){
  	        nodes[t] = allNodes[t];
  	    }
        return (nodes, merkleTree.leaf_count);
    }

    function GetMerkleTree(uint256 treeIndex) public view returns (bytes32, uint256, uint256, uint256){
        require(treeIndex < MerkleTreeCount);
        MerkleTree merkleTree = indexToMerkleTree[treeIndex];
        return (merkleTree.root, merkleTree.first_recipt_id, merkleTree.leaf_count, merkleTree.size);
    }
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}