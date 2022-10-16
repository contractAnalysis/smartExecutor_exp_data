pragma solidity 0.5.12;






library UniformRandomNumber {
  
  
  
  
  function uniform(uint256 _entropy, uint256 _upperBound) internal pure returns (uint256) {
    require(_upperBound > 0, "UniformRand/min-bound");
    uint256 min = -_upperBound % _upperBound;
    uint256 random = _entropy;
    while (true) {
      if (random >= min) {
        break;
      }
      random = uint256(keccak256(abi.encodePacked(random)));
    }
    return random % _upperBound;
  }
}





library SortitionSumTreeFactory {
    

    struct SortitionSumTree {
        uint K; 
        
        uint[] stack;
        uint[] nodes;
        
        mapping(bytes32 => uint) IDsToNodeIndexes;
        mapping(uint => bytes32) nodeIndexesToIDs;
    }

    

    struct SortitionSumTrees {
        mapping(bytes32 => SortitionSumTree) sortitionSumTrees;
    }

    

    
    function createTree(SortitionSumTrees storage self, bytes32 _key, uint _K) internal {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        require(tree.K == 0, "Tree already exists.");
        require(_K > 1, "K must be greater than one.");
        tree.K = _K;
        tree.stack.length = 0;
        tree.nodes.length = 0;
        tree.nodes.push(0);
    }

    
    function set(SortitionSumTrees storage self, bytes32 _key, uint _value, bytes32 _ID) internal {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToNodeIndexes[_ID];

        if (treeIndex == 0) { 
            if (_value != 0) { 
                
                
                if (tree.stack.length == 0) { 
                    
                    treeIndex = tree.nodes.length;
                    tree.nodes.push(_value);

                    
                    if (treeIndex != 1 && (treeIndex - 1) % tree.K == 0) { 
                        uint parentIndex = treeIndex / tree.K;
                        bytes32 parentID = tree.nodeIndexesToIDs[parentIndex];
                        uint newIndex = treeIndex + 1;
                        tree.nodes.push(tree.nodes[parentIndex]);
                        delete tree.nodeIndexesToIDs[parentIndex];
                        tree.IDsToNodeIndexes[parentID] = newIndex;
                        tree.nodeIndexesToIDs[newIndex] = parentID;
                    }
                } else { 
                    
                    treeIndex = tree.stack[tree.stack.length - 1];
                    tree.stack.length--;
                    tree.nodes[treeIndex] = _value;
                }

                
                tree.IDsToNodeIndexes[_ID] = treeIndex;
                tree.nodeIndexesToIDs[treeIndex] = _ID;

                updateParents(self, _key, treeIndex, true, _value);
            }
        } else { 
            if (_value == 0) { 
                
                
                uint value = tree.nodes[treeIndex];
                tree.nodes[treeIndex] = 0;

                
                tree.stack.push(treeIndex);

                
                delete tree.IDsToNodeIndexes[_ID];
                delete tree.nodeIndexesToIDs[treeIndex];

                updateParents(self, _key, treeIndex, false, value);
            } else if (_value != tree.nodes[treeIndex]) { 
                
                bool plusOrMinus = tree.nodes[treeIndex] <= _value;
                uint plusOrMinusValue = plusOrMinus ? _value - tree.nodes[treeIndex] : tree.nodes[treeIndex] - _value;
                tree.nodes[treeIndex] = _value;

                updateParents(self, _key, treeIndex, plusOrMinus, plusOrMinusValue);
            }
        }
    }

    

    
    function queryLeafs(
        SortitionSumTrees storage self,
        bytes32 _key,
        uint _cursor,
        uint _count
    ) internal view returns(uint startIndex, uint[] memory values, bool hasMore) {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        
        for (uint i = 0; i < tree.nodes.length; i++) {
            if ((tree.K * i) + 1 >= tree.nodes.length) {
                startIndex = i;
                break;
            }
        }

        
        uint loopStartIndex = startIndex + _cursor;
        values = new uint[](loopStartIndex + _count > tree.nodes.length ? tree.nodes.length - loopStartIndex : _count);
        uint valuesIndex = 0;
        for (uint j = loopStartIndex; j < tree.nodes.length; j++) {
            if (valuesIndex < _count) {
                values[valuesIndex] = tree.nodes[j];
                valuesIndex++;
            } else {
                hasMore = true;
                break;
            }
        }
    }

    
    function draw(SortitionSumTrees storage self, bytes32 _key, uint _drawnNumber) internal view returns(bytes32 ID) {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = 0;
        uint currentDrawnNumber = _drawnNumber % tree.nodes[0];

        while ((tree.K * treeIndex) + 1 < tree.nodes.length)  
            for (uint i = 1; i <= tree.K; i++) { 
                uint nodeIndex = (tree.K * treeIndex) + i;
                uint nodeValue = tree.nodes[nodeIndex];

                if (currentDrawnNumber >= nodeValue) currentDrawnNumber -= nodeValue; 
                else { 
                    treeIndex = nodeIndex;
                    break;
                }
            }
        
        ID = tree.nodeIndexesToIDs[treeIndex];
    }

    
    function stakeOf(SortitionSumTrees storage self, bytes32 _key, bytes32 _ID) internal view returns(uint value) {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToNodeIndexes[_ID];

        if (treeIndex == 0) value = 0;
        else value = tree.nodes[treeIndex];
    }

   function total(SortitionSumTrees storage self, bytes32 _key) internal view returns (uint) {
       SortitionSumTree storage tree = self.sortitionSumTrees[_key];
       if (tree.nodes.length == 0) {
           return 0;
       } else {
           return tree.nodes[0];
       }
   }

    

    
    function updateParents(SortitionSumTrees storage self, bytes32 _key, uint _treeIndex, bool _plusOrMinus, uint _value) private {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        uint parentIndex = _treeIndex;
        while (parentIndex != 0) {
            parentIndex = (parentIndex - 1) / tree.K;
            tree.nodes[parentIndex] = _plusOrMinus ? tree.nodes[parentIndex] + _value : tree.nodes[parentIndex] - _value;
        }
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



library DrawManager {
    using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees;
    using SafeMath for uint256;

    
    bytes32 public constant TREE_OF_DRAWS = "TreeOfDraws";

    uint8 public constant MAX_BRANCHES_PER_NODE = 10;

    
    struct State {
        
        SortitionSumTreeFactory.SortitionSumTrees sortitionSumTrees;

        
        mapping(address => uint256) consolidatedDrawIndices;

        
        mapping(address => uint256) latestDrawIndices;

        
        mapping(uint256 => uint256) __deprecated__drawTotals;

        
        uint256 openDrawIndex;

        
        uint256 __deprecated__committedSupply;
    }

    
    function openNextDraw(State storage self) public returns (uint256) {
        if (self.openDrawIndex == 0) {
            
            self.sortitionSumTrees.createTree(TREE_OF_DRAWS, MAX_BRANCHES_PER_NODE);
        } else {
            
            bytes32 drawId = bytes32(self.openDrawIndex);
            uint256 drawTotal = openSupply(self);
            self.sortitionSumTrees.set(TREE_OF_DRAWS, drawTotal, drawId);
        }
        
        uint256 drawIndex = self.openDrawIndex.add(1);
        self.sortitionSumTrees.createTree(bytes32(drawIndex), MAX_BRANCHES_PER_NODE);
        self.openDrawIndex = drawIndex;

        return drawIndex;
    }

    
    function deposit(State storage self, address _addr, uint256 _amount) public requireOpenDraw(self) onlyNonZero(_addr) {
        bytes32 userId = bytes32(uint256(_addr));
        uint256 openDrawIndex = self.openDrawIndex;

        
        uint256 currentAmount = self.sortitionSumTrees.stakeOf(bytes32(openDrawIndex), userId);
        currentAmount = currentAmount.add(_amount);
        drawSet(self, openDrawIndex, currentAmount, _addr);

        uint256 consolidatedDrawIndex = self.consolidatedDrawIndices[_addr];
        uint256 latestDrawIndex = self.latestDrawIndices[_addr];

        
        if (consolidatedDrawIndex == 0) {
            self.consolidatedDrawIndices[_addr] = openDrawIndex;
        
        } else if (consolidatedDrawIndex != openDrawIndex) {
            
            if (latestDrawIndex == 0) {
                
                self.latestDrawIndices[_addr] = openDrawIndex;
            
            } else if (latestDrawIndex != openDrawIndex) {
                
                uint256 consolidatedAmount = self.sortitionSumTrees.stakeOf(bytes32(consolidatedDrawIndex), userId);
                uint256 latestAmount = self.sortitionSumTrees.stakeOf(bytes32(latestDrawIndex), userId);
                drawSet(self, consolidatedDrawIndex, consolidatedAmount.add(latestAmount), _addr);
                drawSet(self, latestDrawIndex, 0, _addr);
                self.latestDrawIndices[_addr] = openDrawIndex;
            }
        }
    }

    
    function depositCommitted(State storage self, address _addr, uint256 _amount) public requireCommittedDraw(self) onlyNonZero(_addr) {
        bytes32 userId = bytes32(uint256(_addr));
        uint256 consolidatedDrawIndex = self.consolidatedDrawIndices[_addr];

        
        if (consolidatedDrawIndex != 0 && consolidatedDrawIndex != self.openDrawIndex) {
            uint256 consolidatedAmount = self.sortitionSumTrees.stakeOf(bytes32(consolidatedDrawIndex), userId);
            drawSet(self, consolidatedDrawIndex, consolidatedAmount.add(_amount), _addr);
        } else { 
            self.latestDrawIndices[_addr] = consolidatedDrawIndex;
            self.consolidatedDrawIndices[_addr] = self.openDrawIndex.sub(1);
            drawSet(self, self.consolidatedDrawIndices[_addr], _amount, _addr);
        }
    }

    
    function withdraw(State storage self, address _addr) public requireOpenDraw(self) onlyNonZero(_addr) {
        uint256 consolidatedDrawIndex = self.consolidatedDrawIndices[_addr];
        uint256 latestDrawIndex = self.latestDrawIndices[_addr];

        if (consolidatedDrawIndex != 0) {
            drawSet(self, consolidatedDrawIndex, 0, _addr);
            delete self.consolidatedDrawIndices[_addr];
        }

        if (latestDrawIndex != 0) {
            drawSet(self, latestDrawIndex, 0, _addr);
            delete self.latestDrawIndices[_addr];
        }
    }

    
    function withdrawOpen(State storage self, address _addr, uint256 _amount) public requireOpenDraw(self) onlyNonZero(_addr) {
        bytes32 userId = bytes32(uint256(_addr));
        uint256 openTotal = self.sortitionSumTrees.stakeOf(bytes32(self.openDrawIndex), userId);

        require(_amount <= openTotal, "DrawMan/exceeds-open");

        uint256 remaining = openTotal.sub(_amount);

        drawSet(self, self.openDrawIndex, remaining, _addr);
    }

    
    function withdrawCommitted(State storage self, address _addr, uint256 _amount) public requireCommittedDraw(self) onlyNonZero(_addr) {
        bytes32 userId = bytes32(uint256(_addr));
        uint256 consolidatedDrawIndex = self.consolidatedDrawIndices[_addr];
        uint256 latestDrawIndex = self.latestDrawIndices[_addr];

        uint256 consolidatedAmount = 0;
        uint256 latestAmount = 0;
        uint256 total = 0;

        if (latestDrawIndex != 0 && latestDrawIndex != self.openDrawIndex) {
            latestAmount = self.sortitionSumTrees.stakeOf(bytes32(latestDrawIndex), userId);
            total = total.add(latestAmount);
        }

        if (consolidatedDrawIndex != 0 && consolidatedDrawIndex != self.openDrawIndex) {
            consolidatedAmount = self.sortitionSumTrees.stakeOf(bytes32(consolidatedDrawIndex), userId);
            total = total.add(consolidatedAmount);
        }

        
        
        if (total == 0) {
            return;
        }

        require(_amount <= total, "Pool/exceed");

        uint256 remaining = total.sub(_amount);

        
        if (remaining > consolidatedAmount) {
            uint256 secondRemaining = remaining.sub(consolidatedAmount);
            drawSet(self, latestDrawIndex, secondRemaining, _addr);
        } else if (latestAmount > 0) { 
            delete self.latestDrawIndices[_addr];
            drawSet(self, latestDrawIndex, 0, _addr);
        }

        
        if (remaining == 0) {
            delete self.consolidatedDrawIndices[_addr];
            drawSet(self, consolidatedDrawIndex, 0, _addr);
        } else if (remaining < consolidatedAmount) {
            drawSet(self, consolidatedDrawIndex, remaining, _addr);
        }
    }

    
    function balanceOf(State storage drawState, address _addr) public view returns (uint256) {
        return committedBalanceOf(drawState, _addr).add(openBalanceOf(drawState, _addr));
    }

    
    function committedBalanceOf(State storage self, address _addr) public view returns (uint256) {
        uint256 balance = 0;

        uint256 consolidatedDrawIndex = self.consolidatedDrawIndices[_addr];
        uint256 latestDrawIndex = self.latestDrawIndices[_addr];

        if (consolidatedDrawIndex != 0 && consolidatedDrawIndex != self.openDrawIndex) {
            balance = self.sortitionSumTrees.stakeOf(bytes32(consolidatedDrawIndex), bytes32(uint256(_addr)));
        }

        if (latestDrawIndex != 0 && latestDrawIndex != self.openDrawIndex) {
            balance = balance.add(self.sortitionSumTrees.stakeOf(bytes32(latestDrawIndex), bytes32(uint256(_addr))));
        }

        return balance;
    }

    
    function openBalanceOf(State storage self, address _addr) public view returns (uint256) {
        if (self.openDrawIndex == 0) {
            return 0;
        } else {
            return self.sortitionSumTrees.stakeOf(bytes32(self.openDrawIndex), bytes32(uint256(_addr)));
        }
    }

    
    function openSupply(State storage self) public view returns (uint256) {
        return self.sortitionSumTrees.total(bytes32(self.openDrawIndex));
    }

    
    function committedSupply(State storage self) public view returns (uint256) {
        return self.sortitionSumTrees.total(TREE_OF_DRAWS);
    }

    
    function drawSet(State storage self, uint256 _drawIndex, uint256 _amount, address _addr) internal {
        bytes32 drawId = bytes32(_drawIndex);
        bytes32 userId = bytes32(uint256(_addr));
        uint256 oldAmount = self.sortitionSumTrees.stakeOf(drawId, userId);

        if (oldAmount != _amount) {
            

            
            self.sortitionSumTrees.set(drawId, _amount, userId);

            
            if (_drawIndex != self.openDrawIndex) {
                
                uint256 newDrawTotal = self.sortitionSumTrees.total(drawId);

                
                self.sortitionSumTrees.set(TREE_OF_DRAWS, newDrawTotal, drawId);
            }
        }
    }

   
    function draw(State storage self, uint256 _token) public view returns (address) {
        
        if (committedSupply(self) == 0) {
            return address(0);
        }
        require(_token < committedSupply(self), "Pool/ineligible");
        bytes32 drawIndex = self.sortitionSumTrees.draw(TREE_OF_DRAWS, _token);
        uint256 drawSupply = self.sortitionSumTrees.total(drawIndex);
        uint256 drawToken = _token % drawSupply;
        return address(uint256(self.sortitionSumTrees.draw(drawIndex, drawToken)));
    }

    
    function drawWithEntropy(State storage self, bytes32 _entropy) public view returns (address) {
        uint256 bound = committedSupply(self);
        address selected;
        if (bound == 0) {
            selected = address(0);
        } else {
            selected = draw(self, UniformRandomNumber.uniform(uint256(_entropy), bound));
        }
        return selected;
    }

    modifier requireOpenDraw(State storage self) {
        require(self.openDrawIndex > 0, "Pool/no-open");
        _;
    }

    modifier requireCommittedDraw(State storage self) {
        require(self.openDrawIndex > 1, "Pool/no-commit");
        _;
    }

    modifier onlyNonZero(address _addr) {
        require(_addr != address(0), "Pool/not-zero");
        _;
    }
}