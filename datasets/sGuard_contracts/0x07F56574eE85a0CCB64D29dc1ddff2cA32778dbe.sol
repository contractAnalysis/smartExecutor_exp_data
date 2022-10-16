pragma solidity 0.5.12;



contract Initializable {

  
  bool private initialized;

  
  bool private initializing;

  
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
    
    
    
    
    
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}



library Blocklock {

  struct State {
    uint256 lockedAt;
    uint256 unlockedAt;
    uint256 lockDuration;
    uint256 cooldownDuration;
  }

  function setLockDuration(State storage self, uint256 lockDuration) public {
    require(lockDuration > 0, "Blocklock/lock-min");
    self.lockDuration = lockDuration;
  }

  function setCooldownDuration(State storage self, uint256 cooldownDuration) public {
    self.cooldownDuration = cooldownDuration;
  }

  function isLocked(State storage self, uint256 blockNumber) public view returns (bool) {
    uint256 endAt = lockEndAt(self);
    return (
      self.lockedAt != 0 &&
      blockNumber >= self.lockedAt &&
      blockNumber < endAt
    );
  }

  function lock(State storage self, uint256 blockNumber) public {
    require(canLock(self, blockNumber), "Blocklock/no-lock");
    self.lockedAt = blockNumber;
  }

  function unlock(State storage self, uint256 blockNumber) public {
    self.unlockedAt = blockNumber;
  }

  function canLock(State storage self, uint256 blockNumber) public view returns (bool) {
    uint256 endAt = lockEndAt(self);
    return (
      self.lockedAt == 0 ||
      blockNumber >= endAt + self.cooldownDuration
    );
  }

  function cooldownEndAt(State storage self) internal view returns (uint256) {
    return lockEndAt(self) + self.cooldownDuration;
  }

  function lockEndAt(State storage self) internal view returns (uint256) {
    uint256 endAt = self.lockedAt + self.lockDuration;
    
    if (self.unlockedAt >= self.lockedAt && self.unlockedAt < endAt) {
      endAt = self.unlockedAt;
    }
    return endAt;
  }
}















interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
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






contract ReentrancyGuard is Initializable {
    
    uint256 private _guardCounter;

    function initialize() public initializer {
        
        
        _guardCounter = 1;
    }

    
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}




library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}





contract ICErc20 {
    address public underlying;
    function mint(uint mintAmount) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getCash() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
}










library UniformRandomNumber {
  
  
  
  
  function uniform(uint256 _entropy, uint256 _upperBound) internal pure returns (uint256) {
    if (_upperBound == 0) {
      return 0;
    }
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




library DrawManager {
    using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees;
    using SafeMath for uint256;

    
    bytes32 public constant TREE_OF_DRAWS = "TreeOfDraws";

    uint8 public constant MAX_LEAVES = 10;

    
    struct State {
        
        SortitionSumTreeFactory.SortitionSumTrees sortitionSumTrees;

        
        mapping(address => uint256) usersFirstDrawIndex;

        
        mapping(address => uint256) usersSecondDrawIndex;

        
        mapping(uint256 => uint256) __deprecated__drawTotals;

        
        uint256 openDrawIndex;

        
        uint256 __deprecated__committedSupply;
    }

    
    function openNextDraw(State storage self) public returns (uint256) {
        if (self.openDrawIndex == 0) {
            
            self.sortitionSumTrees.createTree(TREE_OF_DRAWS, MAX_LEAVES);
        } else {
            
            bytes32 drawId = bytes32(self.openDrawIndex);
            uint256 drawTotal = openSupply(self);
            self.sortitionSumTrees.set(TREE_OF_DRAWS, drawTotal, drawId);
        }
        
        uint256 drawIndex = self.openDrawIndex.add(1);
        self.sortitionSumTrees.createTree(bytes32(drawIndex), MAX_LEAVES);
        self.openDrawIndex = drawIndex;

        return drawIndex;
    }

    
    function deposit(State storage self, address _addr, uint256 _amount) public requireOpenDraw(self) onlyNonZero(_addr) {
        bytes32 userId = bytes32(uint256(_addr));
        uint256 openDrawIndex = self.openDrawIndex;

        
        uint256 currentAmount = self.sortitionSumTrees.stakeOf(bytes32(openDrawIndex), userId);
        currentAmount = currentAmount.add(_amount);
        drawSet(self, openDrawIndex, currentAmount, _addr);

        uint256 firstDrawIndex = self.usersFirstDrawIndex[_addr];
        uint256 secondDrawIndex = self.usersSecondDrawIndex[_addr];

        
        if (firstDrawIndex == 0) {
            self.usersFirstDrawIndex[_addr] = openDrawIndex;
        
        } else if (firstDrawIndex != openDrawIndex) {
            
            if (secondDrawIndex == 0) {
                
                self.usersSecondDrawIndex[_addr] = openDrawIndex;
            
            } else if (secondDrawIndex != openDrawIndex) {
                
                uint256 firstAmount = self.sortitionSumTrees.stakeOf(bytes32(firstDrawIndex), userId);
                uint256 secondAmount = self.sortitionSumTrees.stakeOf(bytes32(secondDrawIndex), userId);
                drawSet(self, firstDrawIndex, firstAmount.add(secondAmount), _addr);
                drawSet(self, secondDrawIndex, 0, _addr);
                self.usersSecondDrawIndex[_addr] = openDrawIndex;
            }
        }
    }

    
    function depositCommitted(State storage self, address _addr, uint256 _amount) public requireCommittedDraw(self) onlyNonZero(_addr) {
        bytes32 userId = bytes32(uint256(_addr));
        uint256 firstDrawIndex = self.usersFirstDrawIndex[_addr];

        
        if (firstDrawIndex != 0 && firstDrawIndex != self.openDrawIndex) {
            uint256 firstAmount = self.sortitionSumTrees.stakeOf(bytes32(firstDrawIndex), userId);
            drawSet(self, firstDrawIndex, firstAmount.add(_amount), _addr);
        } else { 
            self.usersSecondDrawIndex[_addr] = firstDrawIndex;
            self.usersFirstDrawIndex[_addr] = self.openDrawIndex.sub(1);
            drawSet(self, self.usersFirstDrawIndex[_addr], _amount, _addr);
        }
    }

    
    function withdraw(State storage self, address _addr) public requireOpenDraw(self) onlyNonZero(_addr) {
        uint256 firstDrawIndex = self.usersFirstDrawIndex[_addr];
        uint256 secondDrawIndex = self.usersSecondDrawIndex[_addr];

        if (firstDrawIndex != 0) {
            drawSet(self, firstDrawIndex, 0, _addr);
            delete self.usersFirstDrawIndex[_addr];
        }

        if (secondDrawIndex != 0) {
            drawSet(self, secondDrawIndex, 0, _addr);
            delete self.usersSecondDrawIndex[_addr];
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
        uint256 firstDrawIndex = self.usersFirstDrawIndex[_addr];
        uint256 secondDrawIndex = self.usersSecondDrawIndex[_addr];

        uint256 firstAmount = 0;
        uint256 secondAmount = 0;
        uint256 total = 0;

        if (secondDrawIndex != 0 && secondDrawIndex != self.openDrawIndex) {
            secondAmount = self.sortitionSumTrees.stakeOf(bytes32(secondDrawIndex), userId);
            total = total.add(secondAmount);
        }

        if (firstDrawIndex != 0 && firstDrawIndex != self.openDrawIndex) {
            firstAmount = self.sortitionSumTrees.stakeOf(bytes32(firstDrawIndex), userId);
            total = total.add(firstAmount);
        }

        require(_amount <= total, "Pool/exceed");

        uint256 remaining = total.sub(_amount);

        
        if (remaining > firstAmount) {
            uint256 secondRemaining = remaining.sub(firstAmount);
            drawSet(self, secondDrawIndex, secondRemaining, _addr);
        } else if (secondAmount > 0) { 
            delete self.usersSecondDrawIndex[_addr];
            drawSet(self, secondDrawIndex, 0, _addr);
        }

        
        if (remaining == 0) {
            delete self.usersFirstDrawIndex[_addr];
            drawSet(self, firstDrawIndex, 0, _addr);
        } else if (remaining < firstAmount) {
            drawSet(self, firstDrawIndex, remaining, _addr);
        }
    }

    
    function balanceOf(State storage drawState, address _addr) public view returns (uint256) {
        return committedBalanceOf(drawState, _addr).add(openBalanceOf(drawState, _addr));
    }

    
    function committedBalanceOf(State storage self, address _addr) public view returns (uint256) {
        uint256 balance = 0;

        uint256 firstDrawIndex = self.usersFirstDrawIndex[_addr];
        uint256 secondDrawIndex = self.usersSecondDrawIndex[_addr];

        if (firstDrawIndex != 0 && firstDrawIndex != self.openDrawIndex) {
            balance = balance.add(self.sortitionSumTrees.stakeOf(bytes32(firstDrawIndex), bytes32(uint256(_addr))));
        }

        if (secondDrawIndex != 0 && secondDrawIndex != self.openDrawIndex) {
            balance = balance.add(self.sortitionSumTrees.stakeOf(bytes32(secondDrawIndex), bytes32(uint256(_addr))));
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
        uint256 drawIndex = uint256(self.sortitionSumTrees.draw(TREE_OF_DRAWS, _token));
        uint256 drawSupply = self.sortitionSumTrees.total(bytes32(drawIndex));
        uint256 drawToken = _token % drawSupply;
        return address(uint256(self.sortitionSumTrees.draw(bytes32(drawIndex), drawToken)));
    }

    
    function drawWithEntropy(State storage self, bytes32 _entropy) public view returns (address) {
        return draw(self, UniformRandomNumber.uniform(uint256(_entropy), committedSupply(self)));
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




library FixidityLib {

    
    function digits() public pure returns(uint8) {
        return 24;
    }
    
    
    function fixed1() public pure returns(int256) {
        return 1000000000000000000000000;
    }

    
    function mulPrecision() public pure returns(int256) {
        return 1000000000000;
    }

    
    function maxInt256() public pure returns(int256) {
        return 57896044618658097711785492504343953926634992332820282019728792003956564819967;
    }

    
    function minInt256() public pure returns(int256) {
        return -57896044618658097711785492504343953926634992332820282019728792003956564819968;
    }

    
    function maxNewFixed() public pure returns(int256) {
        return 57896044618658097711785492504343953926634992332820282;
    }

    
    function minNewFixed() public pure returns(int256) {
        return -57896044618658097711785492504343953926634992332820282;
    }

    
    function maxFixedAdd() public pure returns(int256) {
        return 28948022309329048855892746252171976963317496166410141009864396001978282409983;
    }

    
    function maxFixedSub() public pure returns(int256) {
        return -28948022309329048855892746252171976963317496166410141009864396001978282409984;
    }

    
    function maxFixedMul() public pure returns(int256) {
        return 240615969168004498257251713877715648331380787511296;
    }

    
    function maxFixedDiv() public pure returns(int256) {
        return 57896044618658097711785492504343953926634992332820282;
    }

    
    function maxFixedDivisor() public pure returns(int256) {
        return 1000000000000000000000000000000000000000000000000;
    }

    
    function newFixed(int256 x)
        public
        pure
        returns (int256)
    {
        require(x <= maxNewFixed());
        require(x >= minNewFixed());
        return x * fixed1();
    }

    
    function fromFixed(int256 x)
        public
        pure
        returns (int256)
    {
        return x / fixed1();
    }

    
    function convertFixed(int256 x, uint8 _originDigits, uint8 _destinationDigits)
        public
        pure
        returns (int256)
    {
        require(_originDigits <= 38 && _destinationDigits <= 38);
        
        uint8 decimalDifference;
        if ( _originDigits > _destinationDigits ){
            decimalDifference = _originDigits - _destinationDigits;
            return x/(uint128(10)**uint128(decimalDifference));
        }
        else if ( _originDigits < _destinationDigits ){
            decimalDifference = _destinationDigits - _originDigits;
            
            
            
            
            
            
            require(x <= maxInt256()/uint128(10)**uint128(decimalDifference));
            require(x >= minInt256()/uint128(10)**uint128(decimalDifference));
            return x*(uint128(10)**uint128(decimalDifference));
        }
        
        return x;
    }

    
    function newFixed(int256 x, uint8 _originDigits)
        public
        pure
        returns (int256)
    {
        return convertFixed(x, _originDigits, digits());
    }

    
    function fromFixed(int256 x, uint8 _destinationDigits)
        public
        pure
        returns (int256)
    {
        return convertFixed(x, digits(), _destinationDigits);
    }

    
    function newFixedFraction(
        int256 numerator, 
        int256 denominator
        )
        public
        pure
        returns (int256)
    {
        require(numerator <= maxNewFixed());
        require(denominator <= maxNewFixed());
        require(denominator != 0);
        int256 convertedNumerator = newFixed(numerator);
        int256 convertedDenominator = newFixed(denominator);
        return divide(convertedNumerator, convertedDenominator);
    }

    
    function integer(int256 x) public pure returns (int256) {
        return (x / fixed1()) * fixed1(); 
    }

    
    function fractional(int256 x) public pure returns (int256) {
        return x - (x / fixed1()) * fixed1(); 
    }

    
    function abs(int256 x) public pure returns (int256) {
        if (x >= 0) {
            return x;
        } else {
            int256 result = -x;
            assert (result > 0);
            return result;
        }
    }

    
    function add(int256 x, int256 y) public pure returns (int256) {
        int256 z = x + y;
        if (x > 0 && y > 0) assert(z > x && z > y);
        if (x < 0 && y < 0) assert(z < x && z < y);
        return z;
    }

    
    function subtract(int256 x, int256 y) public pure returns (int256) {
        return add(x,-y);
    }

    
    function multiply(int256 x, int256 y) public pure returns (int256) {
        if (x == 0 || y == 0) return 0;
        if (y == fixed1()) return x;
        if (x == fixed1()) return y;

        
        
        int256 x1 = integer(x) / fixed1();
        int256 x2 = fractional(x);
        int256 y1 = integer(y) / fixed1();
        int256 y2 = fractional(y);
        
        
        int256 x1y1 = x1 * y1;
        if (x1 != 0) assert(x1y1 / x1 == y1); 
        
        
        
        int256 fixed_x1y1 = x1y1 * fixed1();
        if (x1y1 != 0) assert(fixed_x1y1 / x1y1 == fixed1()); 
        x1y1 = fixed_x1y1;

        int256 x2y1 = x2 * y1;
        if (x2 != 0) assert(x2y1 / x2 == y1); 

        int256 x1y2 = x1 * y2;
        if (x1 != 0) assert(x1y2 / x1 == y2); 

        x2 = x2 / mulPrecision();
        y2 = y2 / mulPrecision();
        int256 x2y2 = x2 * y2;
        if (x2 != 0) assert(x2y2 / x2 == y2); 

        
        int256 result = x1y1;
        result = add(result, x2y1); 
        result = add(result, x1y2); 
        result = add(result, x2y2); 
        return result;
    }
    
    
    function reciprocal(int256 x) public pure returns (int256) {
        require(x != 0);
        return (fixed1()*fixed1()) / x; 
    }

    
    function divide(int256 x, int256 y) public pure returns (int256) {
        if (y == fixed1()) return x;
        require(y != 0);
        require(y <= maxFixedDivisor());
        return multiply(x, reciprocal(y));
    }
}






contract BasePool is ReentrancyGuard {
  using DrawManager for DrawManager.State;
  using SafeMath for uint256;
  using Roles for Roles.Role;
  using Blocklock for Blocklock.State;

  bytes32 internal constant ROLLED_OVER_ENTROPY_MAGIC_NUMBER = bytes32(uint256(1));
  uint256 internal constant DEFAULT_LOCK_DURATION = 40;
  uint256 internal constant DEFAULT_COOLDOWN_DURATION = 80;

  
  event Deposited(address indexed sender, uint256 amount);

  
  event DepositedAndCommitted(address indexed sender, uint256 amount);

  
  event SponsorshipDeposited(address indexed sender, uint256 amount);

  
  event AdminAdded(address indexed admin);

  
  event AdminRemoved(address indexed admin);

  
  event Withdrawn(address indexed sender, uint256 amount);

  
  event SponsorshipAndFeesWithdrawn(address indexed sender, uint256 amount);

  
  event OpenDepositWithdrawn(address indexed sender, uint256 amount);

  
  event CommittedDepositWithdrawn(address indexed sender, uint256 amount);

  
  event FeeCollected(address indexed sender, uint256 amount, uint256 drawId);

  
  event Opened(
    uint256 indexed drawId,
    address indexed feeBeneficiary,
    bytes32 secretHash,
    uint256 feeFraction
  );

  
  event Committed(
    uint256 indexed drawId
  );

  
  event Rewarded(
    uint256 indexed drawId,
    address indexed winner,
    bytes32 entropy,
    uint256 winnings,
    uint256 fee
  );

  
  event NextFeeFractionChanged(uint256 feeFraction);

  
  event NextFeeBeneficiaryChanged(address indexed feeBeneficiary);

  
  event Paused(address indexed sender);

  
  event Unpaused(address indexed sender);

  
  event RolledOver(uint256 indexed drawId);

  struct Draw {
    uint256 feeFraction; 
    address feeBeneficiary;
    uint256 openedBlock;
    bytes32 secretHash;
    bytes32 entropy;
    address winner;
    uint256 netWinnings;
    uint256 fee;
  }

  
  ICErc20 public cToken;

  
  address public nextFeeBeneficiary;

  
  uint256 public nextFeeFraction;

  
  uint256 public accountedBalance;

  
  mapping (address => uint256) balances;

  
  mapping(uint256 => Draw) draws;

  
  DrawManager.State drawState;

  
  Roles.Role admins;

  
  bool public paused;

  Blocklock.State blocklock;

  PoolToken public poolToken;

  
  function init (
    address _owner,
    address _cToken,
    uint256 _feeFraction,
    address _feeBeneficiary,
    uint256 _lockDuration,
    uint256 _cooldownDuration
  ) public initializer {
    require(_owner != address(0), "Pool/owner-zero");
    require(_cToken != address(0), "Pool/ctoken-zero");
    cToken = ICErc20(_cToken);
    _addAdmin(_owner);
    _setNextFeeFraction(_feeFraction);
    _setNextFeeBeneficiary(_feeBeneficiary);
    initBlocklock(_lockDuration, _cooldownDuration);
  }

  function setPoolToken(PoolToken _poolToken) external onlyAdmin {
    require(address(poolToken) == address(0), "Pool/token-was-set");
    require(_poolToken.pool() == address(this), "Pool/token-mismatch");
    poolToken = _poolToken;
  }

  function initBlocklock(uint256 _lockDuration, uint256 _cooldownDuration) internal {
    blocklock.setLockDuration(_lockDuration);
    blocklock.setCooldownDuration(_cooldownDuration);
  }

  
  function open(bytes32 _secretHash) internal {
    drawState.openNextDraw();
    draws[drawState.openDrawIndex] = Draw(
      nextFeeFraction,
      nextFeeBeneficiary,
      block.number,
      _secretHash,
      bytes32(0),
      address(0),
      uint256(0),
      uint256(0)
    );
    emit Opened(
      drawState.openDrawIndex,
      nextFeeBeneficiary,
      _secretHash,
      nextFeeFraction
    );
  }

  
  function emitCommitted() internal {
    uint256 drawId = currentOpenDrawId();
    emit Committed(drawId);
    if (address(poolToken) != address(0)) {
      poolToken.poolMint(openSupply());
    }
  }

  
  function openNextDraw(bytes32 nextSecretHash) public onlyAdmin {
    if (currentCommittedDrawId() > 0) {
      require(currentCommittedDrawHasBeenRewarded(), "Pool/not-reward");
    }
    if (currentOpenDrawId() != 0) {
      emitCommitted();
    }
    open(nextSecretHash);
  }

  
  function rolloverAndOpenNextDraw(bytes32 nextSecretHash) public onlyAdmin {
    rollover();
    openNextDraw(nextSecretHash);
  }

  
  function rewardAndOpenNextDraw(bytes32 nextSecretHash, bytes32 lastSecret, bytes32 _salt) public onlyAdmin {
    reward(lastSecret, _salt);
    openNextDraw(nextSecretHash);
  }

  
  function reward(bytes32 _secret, bytes32 _salt) public onlyAdmin onlyLocked requireCommittedNoReward nonReentrant {
    blocklock.unlock(block.number);

    
    
    uint256 drawId = currentCommittedDrawId();

    Draw storage draw = draws[drawId];

    require(draw.secretHash == keccak256(abi.encodePacked(_secret, _salt)), "Pool/bad-secret");

    
    bytes32 entropy = keccak256(abi.encodePacked(_secret));

    
    address winningAddress = calculateWinner(entropy);

    
    uint256 underlyingBalance = balance();
    uint256 grossWinnings = underlyingBalance.sub(accountedBalance);

    
    uint256 fee = calculateFee(draw.feeFraction, grossWinnings);

    
    balances[draw.feeBeneficiary] = balances[draw.feeBeneficiary].add(fee);

    
    uint256 netWinnings = grossWinnings.sub(fee);

    draw.winner = winningAddress;
    draw.netWinnings = netWinnings;
    draw.fee = fee;
    draw.entropy = entropy;

    
    if (winningAddress != address(0) && netWinnings != 0) {
      
      accountedBalance = underlyingBalance;

      awardWinnings(winningAddress, netWinnings);
    } else {
      
      accountedBalance = accountedBalance.add(fee);
    }

    emit Rewarded(
      drawId,
      winningAddress,
      entropy,
      netWinnings,
      fee
    );
    emit FeeCollected(draw.feeBeneficiary, fee, drawId);
  }

  function awardWinnings(address winner, uint256 amount) internal {
    
    balances[winner] = balances[winner].add(amount);

    
    drawState.deposit(winner, amount);
  }

  
  function rollover() public onlyAdmin requireCommittedNoReward {
    uint256 drawId = currentCommittedDrawId();

    Draw storage draw = draws[drawId];
    draw.entropy = ROLLED_OVER_ENTROPY_MAGIC_NUMBER;

    emit RolledOver(
      drawId
    );

    emit Rewarded(
      drawId,
      address(0),
      ROLLED_OVER_ENTROPY_MAGIC_NUMBER,
      0,
      0
    );
  }

  
  function calculateFee(uint256 _feeFraction, uint256 _grossWinnings) internal pure returns (uint256) {
    int256 grossWinningsFixed = FixidityLib.newFixed(int256(_grossWinnings));
    int256 feeFixed = FixidityLib.multiply(grossWinningsFixed, FixidityLib.newFixed(int256(_feeFraction), uint8(18)));
    return uint256(FixidityLib.fromFixed(feeFixed));
  }

  
  function depositSponsorship(uint256 _amount) public unlessPaused nonReentrant {
    
    require(token().transferFrom(msg.sender, address(this), _amount), "Pool/t-fail");

    
    _depositSponsorshipFrom(msg.sender, _amount);
  }

  
  function transferBalanceToSponsorship() public unlessPaused {
    
    _depositSponsorshipFrom(address(this), token().balanceOf(address(this)));
  }

  
  function depositPool(uint256 _amount) public requireOpenDraw unlessPaused nonReentrant {
    
    require(token().transferFrom(msg.sender, address(this), _amount), "Pool/t-fail");

    
    _depositPoolFrom(msg.sender, _amount);
  }

  function _depositSponsorshipFrom(address _spender, uint256 _amount) internal {
    
    _depositFrom(_spender, _amount);

    emit SponsorshipDeposited(_spender, _amount);
  }

  function _depositPoolFrom(address _spender, uint256 _amount) internal {
    
    drawState.deposit(_spender, _amount);

    _depositFrom(_spender, _amount);

    emit Deposited(_spender, _amount);
  }

  function _depositPoolFromCommitted(address _spender, uint256 _amount) internal notLocked {
    
    drawState.depositCommitted(_spender, _amount);

    _depositFrom(_spender, _amount);

    emit DepositedAndCommitted(_spender, _amount);
  }

  function _depositFrom(address _spender, uint256 _amount) internal {
    
    balances[_spender] = balances[_spender].add(_amount);

    
    accountedBalance = accountedBalance.add(_amount);

    
    require(token().approve(address(cToken), _amount), "Pool/approve");
    require(cToken.mint(_amount) == 0, "Pool/supply");
  }

  
  function withdraw() public nonReentrant notLocked {

    uint256 sponsorshipAndFees = sponsorshipAndFeeBalanceOf(msg.sender);
    uint256 openBalance = drawState.openBalanceOf(msg.sender);
    uint256 committedBalance = drawState.committedBalanceOf(msg.sender);

    uint balance = balances[msg.sender];
    
    drawState.withdraw(msg.sender);
    _withdraw(msg.sender, balance);

    if (address(poolToken) != address(0)) {
      poolToken.poolRedeem(msg.sender, committedBalance);
    }

    emit SponsorshipAndFeesWithdrawn(msg.sender, sponsorshipAndFees);
    emit OpenDepositWithdrawn(msg.sender, openBalance);
    emit CommittedDepositWithdrawn(msg.sender, committedBalance);
    emit Withdrawn(msg.sender, balance);
  }

  
  function withdrawSponsorshipAndFee(uint256 _amount) public {
    uint256 sponsorshipAndFees = sponsorshipAndFeeBalanceOf(msg.sender);
    require(_amount <= sponsorshipAndFees, "Pool/exceeds-sfee");
    _withdraw(msg.sender, _amount);

    emit SponsorshipAndFeesWithdrawn(msg.sender, _amount);
  }

  
  function sponsorshipAndFeeBalanceOf(address _sender) public view returns (uint256) {
    return balances[_sender] - drawState.balanceOf(_sender);
  }

  
  function withdrawOpenDeposit(uint256 _amount) public {
    drawState.withdrawOpen(msg.sender, _amount);
    _withdraw(msg.sender, _amount);

    emit OpenDepositWithdrawn(msg.sender, _amount);
  }

  
  function withdrawCommittedDeposit(uint256 _amount) external notLocked returns (bool)  {
    _withdrawCommittedDepositAndEmit(msg.sender, _amount);
    if (address(poolToken) != address(0)) {
      poolToken.poolRedeem(msg.sender, _amount);
    }
    return true;
  }

  
  function withdrawCommittedDeposit(
    address _from,
    uint256 _amount
  ) external onlyToken notLocked returns (bool)  {
    return _withdrawCommittedDepositAndEmit(_from, _amount);
  }

  
  function _withdrawCommittedDepositAndEmit(address _from, uint256 _amount) internal returns (bool) {
    drawState.withdrawCommitted(_from, _amount);
    _withdraw(_from, _amount);

    emit CommittedDepositWithdrawn(_from, _amount);

    return true;
  }

  
  function moveCommitted(
    address _from,
    address _to,
    uint256 _amount
  ) external onlyToken onlyCommittedBalanceGteq(_from, _amount) notLocked returns (bool) {
    balances[_from] = balances[_from].sub(_amount, "move could not sub amount");
    balances[_to] = balances[_to].add(_amount);
    drawState.withdrawCommitted(_from, _amount);
    drawState.depositCommitted(_to, _amount);

    return true;
  }

  
  function _withdraw(address _sender, uint256 _amount) internal {
    uint balance = balances[_sender];

    require(_amount <= balance, "Pool/no-funds");

    
    balances[_sender] = balance.sub(_amount);

    
    accountedBalance = accountedBalance.sub(_amount);

    
    require(cToken.redeemUnderlying(_amount) == 0, "Pool/redeem");
    require(token().transfer(_sender, _amount), "Pool/transfer");
  }

  
  function currentOpenDrawId() public view returns (uint256) {
    return drawState.openDrawIndex;
  }

  
  function currentCommittedDrawId() public view returns (uint256) {
    if (drawState.openDrawIndex > 1) {
      return drawState.openDrawIndex - 1;
    } else {
      return 0;
    }
  }

  
  function currentCommittedDrawHasBeenRewarded() internal view returns (bool) {
    Draw storage draw = draws[currentCommittedDrawId()];
    return draw.entropy != bytes32(0);
  }

  
  function getDraw(uint256 _drawId) public view returns (
    uint256 feeFraction,
    address feeBeneficiary,
    uint256 openedBlock,
    bytes32 secretHash,
    bytes32 entropy,
    address winner,
    uint256 netWinnings,
    uint256 fee
  ) {
    Draw storage draw = draws[_drawId];
    feeFraction = draw.feeFraction;
    feeBeneficiary = draw.feeBeneficiary;
    openedBlock = draw.openedBlock;
    secretHash = draw.secretHash;
    entropy = draw.entropy;
    winner = draw.winner;
    netWinnings = draw.netWinnings;
    fee = draw.fee;
  }

  
  function committedBalanceOf(address _addr) external view returns (uint256) {
    return drawState.committedBalanceOf(_addr);
  }

  
  function openBalanceOf(address _addr) external view returns (uint256) {
    return drawState.openBalanceOf(_addr);
  }

  
  function totalBalanceOf(address _addr) external view returns (uint256) {
    return balances[_addr];
  }

  
  function balanceOf(address _addr) external view returns (uint256) {
    return drawState.committedBalanceOf(_addr);
  }

  
  function calculateWinner(bytes32 _entropy) public view returns (address) {
    return drawState.drawWithEntropy(_entropy);
  }

  
  function committedSupply() public view returns (uint256) {
    return drawState.committedSupply();
  }

  
  function openSupply() public view returns (uint256) {
    return drawState.openSupply();
  }

  
  function estimatedInterestRate(uint256 _blocks) public view returns (uint256) {
    return supplyRatePerBlock().mul(_blocks);
  }

  
  function supplyRatePerBlock() public view returns (uint256) {
    return cToken.supplyRatePerBlock();
  }

  
  function setNextFeeFraction(uint256 _feeFraction) public onlyAdmin {
    _setNextFeeFraction(_feeFraction);
  }

  function _setNextFeeFraction(uint256 _feeFraction) internal {
    require(_feeFraction <= 1 ether, "Pool/less-1");
    nextFeeFraction = _feeFraction;

    emit NextFeeFractionChanged(_feeFraction);
  }

  
  function setNextFeeBeneficiary(address _feeBeneficiary) public onlyAdmin {
    _setNextFeeBeneficiary(_feeBeneficiary);
  }

  function _setNextFeeBeneficiary(address _feeBeneficiary) internal {
    require(_feeBeneficiary != address(0), "Pool/not-zero");
    nextFeeBeneficiary = _feeBeneficiary;

    emit NextFeeBeneficiaryChanged(_feeBeneficiary);
  }

  
  function addAdmin(address _admin) public onlyAdmin {
    _addAdmin(_admin);
  }

  
  function isAdmin(address _admin) public view returns (bool) {
    return admins.has(_admin);
  }

  function _addAdmin(address _admin) internal {
    admins.add(_admin);

    emit AdminAdded(_admin);
  }

  
  function removeAdmin(address _admin) public onlyAdmin {
    require(admins.has(_admin), "Pool/no-admin");
    require(_admin != msg.sender, "Pool/remove-self");
    admins.remove(_admin);

    emit AdminRemoved(_admin);
  }

  modifier requireCommittedNoReward() {
    require(currentCommittedDrawId() > 0, "Pool/committed");
    require(!currentCommittedDrawHasBeenRewarded(), "Pool/already");
    _;
  }

  
  function token() public view returns (IERC20) {
    return IERC20(cToken.underlying());
  }

  
  function balance() public returns (uint256) {
    return cToken.balanceOfUnderlying(address(this));
  }

  
  function lockTokens() public onlyAdmin {
    blocklock.lock(block.number);
  }

  
  function unlockTokens() public onlyAdmin {
    blocklock.unlock(block.number);
  }

  
  function pause() public unlessPaused onlyAdmin {
    paused = true;

    emit Paused(msg.sender);
  }

  
  function unpause() public whenPaused onlyAdmin {
    paused = false;

    emit Unpaused(msg.sender);
  }

  function isLocked() public view returns (bool) {
    return blocklock.isLocked(block.number);
  }

  function lockEndAt() public view returns (uint256) {
    return blocklock.lockEndAt();
  }

  function cooldownEndAt() public view returns (uint256) {
    return blocklock.cooldownEndAt();
  }

  function canLock() public view returns (bool) {
    return blocklock.canLock(block.number);
  }

  function lockDuration() public view returns (uint256) {
    return blocklock.lockDuration;
  }

  function cooldownDuration() public view returns (uint256) {
    return blocklock.cooldownDuration;
  }

  modifier notLocked() {
    require(!blocklock.isLocked(block.number), "Pool/locked");
    _;
  }

  modifier onlyLocked() {
    require(blocklock.isLocked(block.number), "Pool/unlocked");
    _;
  }

  modifier onlyAdmin() {
    require(admins.has(msg.sender), "Pool/admin");
    _;
  }

  modifier requireOpenDraw() {
    require(currentOpenDrawId() != 0, "Pool/no-open");
    _;
  }

  modifier whenPaused() {
    require(paused, "Pool/be-paused");
    _;
  }

  modifier unlessPaused() {
    require(!paused, "Pool/not-paused");
    _;
  }

  modifier onlyToken() {
    require(msg.sender == address(poolToken), "Pool/only-token");
    _;
  }

  modifier onlyCommittedBalanceGteq(address _from, uint256 _amount) {
    uint256 committedBalance = drawState.committedBalanceOf(_from);
    require(_amount <= committedBalance, "not enough funds");
    _;
  }
}






interface IERC777 {
    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function granularity() external view returns (uint256);

    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address owner) external view returns (uint256);

    
    function send(address recipient, uint256 amount, bytes calldata data) external;

    
    function burn(uint256 amount, bytes calldata data) external;

    
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    
    function authorizeOperator(address operator) external;

    
    function revokeOperator(address operator) external;

    
    function defaultOperators() external view returns (address[] memory);

    
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}




interface IERC777Recipient {
    
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}




interface IERC777Sender {
    
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}




interface IERC1820Registry {
    
    function setManager(address account, address newManager) external;

    
    function getManager(address account) external view returns (address);

    
    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;

    
    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);

    
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}




library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}





contract PoolToken is Initializable, IERC20, IERC777 {
  using SafeMath for uint256;
  using Address for address;

  
  event Redeemed(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  
  

  
  bytes32 constant internal TOKENS_SENDER_INTERFACE_HASH =
      0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

  
  bytes32 constant internal TOKENS_RECIPIENT_INTERFACE_HASH =
      0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

  
  bytes32 constant internal TOKENS_INTERFACE_HASH =
      0xac7fbab5f54a3ca8194167523c6753bfeb96a445279294b6125b68cce2177054;

  
  bytes32 constant internal ERC20_TOKENS_INTERFACE_HASH =
      0xaea199e31a596269b42cdafd93407f14436db6e4cad65417994c2eb37381e05a;

  string internal _name;
  string internal _symbol;

  
  address[] internal _defaultOperatorsArray;

  
  mapping(address => bool) internal _defaultOperators;

  
  mapping(address => mapping(address => bool)) internal _operators;
  mapping(address => mapping(address => bool)) internal _revokedDefaultOperators;

  
  mapping (address => mapping (address => uint256)) internal _allowances;

  BasePool internal _pool;

  function init (
    string memory name,
    string memory symbol,
    address[] memory defaultOperators,
    BasePool pool
  ) public initializer {
      require(bytes(name).length != 0, "PoolToken/name");
      require(bytes(symbol).length != 0, "PoolToken/symbol");
      require(address(pool) != address(0), "PoolToken/pool-zero");

      _name = name;
      _symbol = symbol;
      _pool = pool;

      _defaultOperatorsArray = defaultOperators;
      for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
          _defaultOperators[_defaultOperatorsArray[i]] = true;
      }

      
      ERC1820_REGISTRY.setInterfaceImplementer(address(this), TOKENS_INTERFACE_HASH, address(this));
      ERC1820_REGISTRY.setInterfaceImplementer(address(this), ERC20_TOKENS_INTERFACE_HASH, address(this));
  }

  function pool() public view returns (address) {
      return address(_pool);
  }

  function poolRedeem(address from, uint256 amount) external onlyPool {
      _callTokensToSend(from, from, address(0), amount, '', '');

      emit Redeemed(from, from, amount, '', '');
      emit Transfer(from, address(0), amount);
  }

  /**
    * @dev See {IERC777-name}.
    */
  function name() public view returns (string memory) {
      return _name;
  }

  /**
    * @dev See {IERC777-symbol}.
    */
  function symbol() public view returns (string memory) {
      return _symbol;
  }

  /**
    * @dev See {ERC20Detailed-decimals}.
    *
    * Always returns 18, as per the
    * [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).
    */
  function decimals() public pure returns (uint8) {
      return 18;
  }

  /**
    * @dev See {IERC777-granularity}.
    *
    * This implementation always returns `1`.
    */
  function granularity() public view returns (uint256) {
      return 1;
  }

  /**
    * @dev See {IERC777-totalSupply}.
    */
  function totalSupply() public view returns (uint256) {
      return _pool.committedSupply();
  }

  /**
    * @dev See {IERC20-balanceOf}.
    */
  function balanceOf(address _addr) external view returns (uint256) {
      return _pool.committedBalanceOf(_addr);
  }

  /**
    * @dev See {IERC777-send}.
    *
    * Also emits a {Transfer} event for ERC20 compatibility.
    */
  function send(address recipient, uint256 amount, bytes calldata data) external {
      _send(msg.sender, msg.sender, recipient, amount, data, "");
  }

  /**
    * @dev See {IERC20-transfer}.
    *
    * Unlike `send`, `recipient` is _not_ required to implement the {IERC777Recipient}
    * interface if it is a contract.
    *
    * Also emits a {Sent} event.
    */
  function transfer(address recipient, uint256 amount) external returns (bool) {
      require(recipient != address(0), "PoolToken/transfer-zero");

      address from = msg.sender;

      _callTokensToSend(from, from, recipient, amount, "", "");

      _move(from, from, recipient, amount, "", "");

      _callTokensReceived(from, from, recipient, amount, "", "", false);

      return true;
  }

  /**
    * @dev Allows a user to withdraw their tokens as the underlying asset.
    *
    * Also emits a {Transfer} event for ERC20 compatibility.
    */
  function redeem(uint256 amount, bytes calldata data) external {
      _redeem(msg.sender, msg.sender, amount, data, "");
  }

  /**
    * @dev See {IERC777-burn}.  Not currently implemented.
    *
    * Also emits a {Transfer} event for ERC20 compatibility.
    */
  function burn(uint256, bytes calldata) external {
      revert("PoolToken/no-support");
  }

  /**
    * @dev See {IERC777-isOperatorFor}.
    */
  function isOperatorFor(
      address operator,
      address tokenHolder
  ) public view returns (bool) {
      return operator == tokenHolder ||
          (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
          _operators[tokenHolder][operator];
  }

  /**
    * @dev See {IERC777-authorizeOperator}.
    */
  function authorizeOperator(address operator) external {
      require(msg.sender != operator, "PoolToken/auth-self");

      if (_defaultOperators[operator]) {
          delete _revokedDefaultOperators[msg.sender][operator];
      } else {
          _operators[msg.sender][operator] = true;
      }

      emit AuthorizedOperator(operator, msg.sender);
  }

  /**
    * @dev See {IERC777-revokeOperator}.
    */
  function revokeOperator(address operator) external {
      require(operator != msg.sender, "PoolToken/revoke-self");

      if (_defaultOperators[operator]) {
          _revokedDefaultOperators[msg.sender][operator] = true;
      } else {
          delete _operators[msg.sender][operator];
      }

      emit RevokedOperator(operator, msg.sender);
  }

  /**
    * @dev See {IERC777-defaultOperators}.
    */
  function defaultOperators() public view returns (address[] memory) {
      return _defaultOperatorsArray;
  }

  /**
    * @dev See {IERC777-operatorSend}.
    *
    * Emits {Sent} and {Transfer} events.
    */
  function operatorSend(
      address sender,
      address recipient,
      uint256 amount,
      bytes calldata data,
      bytes calldata operatorData
  )
  external
  {
      require(isOperatorFor(msg.sender, sender), "PoolToken/not-operator");
      _send(msg.sender, sender, recipient, amount, data, operatorData);
  }

  /**
    * @dev See {IERC777-operatorBurn}.
    *
    * Currently not supported
    */
  function operatorBurn(address, uint256, bytes calldata, bytes calldata) external {
      revert("PoolToken/no-support");
  }

  /**
    * @dev Allows an operator to redeem tokens for the underlying asset on behalf of a user.
    *
    * Emits {Redeemed} and {Transfer} events.
    */
  function operatorRedeem(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
      require(isOperatorFor(msg.sender, account), "PoolToken/not-operator");
      _redeem(msg.sender, account, amount, data, operatorData);
  }

  /**
    * @dev See {IERC20-allowance}.
    *
    * Note that operator and allowance concepts are orthogonal: operators may
    * not have allowance, and accounts with allowance may not be operators
    * themselves.
    */
  function allowance(address holder, address spender) public view returns (uint256) {
      return _allowances[holder][spender];
  }

  /**
    * @dev See {IERC20-approve}.
    *
    * Note that accounts cannot have allowance issued by their operators.
    */
  function approve(address spender, uint256 value) external returns (bool) {
      address holder = msg.sender;
      _approve(holder, spender, value);
      return true;
  }

  /**
  * @dev See {IERC20-transferFrom}.
  *
  * Note that operator and allowance concepts are orthogonal: operators cannot
  * call `transferFrom` (unless they have allowance), and accounts with
  * allowance cannot call `operatorSend` (unless they are operators).
  *
  * Emits {Sent}, {Transfer} and {Approval} events.
  */
  function transferFrom(address holder, address recipient, uint256 amount) external returns (bool) {
      require(recipient != address(0), "PoolToken/to-zero");
      require(holder != address(0), "PoolToken/from-zero");

      address spender = msg.sender;

      _callTokensToSend(spender, holder, recipient, amount, "", "");

      _move(spender, holder, recipient, amount, "", "");
      _approve(holder, spender, _allowances[holder][spender].sub(amount, "PoolToken/exceed-allow"));

      _callTokensReceived(spender, holder, recipient, amount, "", "", false);

      return true;
  }

  /**
   * Called by the associated Pool to emit `Mint` events.
   * @param amount The amount that was minted
   */
  function poolMint(uint256 amount) external onlyPool {
    _mintEvents(address(_pool), address(_pool), amount, '', '');
  }

  
  function _mintEvents(
      address operator,
      address account,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
  internal
  {
      emit Minted(operator, account, amount, userData, operatorData);
      emit Transfer(address(0), account, amount);
  }

  
  function _send(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
      private
  {
      require(from != address(0), "PoolToken/from-zero");
      require(to != address(0), "PoolToken/to-zero");

      _callTokensToSend(operator, from, to, amount, userData, operatorData);

      _move(operator, from, to, amount, userData, operatorData);

      _callTokensReceived(operator, from, to, amount, userData, operatorData, true);
  }

  
  function _redeem(
      address operator,
      address from,
      uint256 amount,
      bytes memory data,
      bytes memory operatorData
  )
      private
  {
      require(from != address(0), "PoolToken/from-zero");

      _callTokensToSend(operator, from, address(0), amount, data, operatorData);

      _pool.withdrawCommittedDeposit(from, amount);

      emit Redeemed(operator, from, amount, data, operatorData);
      emit Transfer(from, address(0), amount);
  }

  function _move(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
      private
  {
      _pool.moveCommitted(from, to, amount);

      emit Sent(operator, from, to, amount, userData, operatorData);
      emit Transfer(from, to, amount);
  }

  function _approve(address holder, address spender, uint256 value) private {
      require(spender != address(0), "PoolToken/from-zero");

      _allowances[holder][spender] = value;
      emit Approval(holder, spender, value);
  }

  
  function _callTokensToSend(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
      internal notLocked
  {
      address implementer = ERC1820_REGISTRY.getInterfaceImplementer(from, TOKENS_SENDER_INTERFACE_HASH);
      if (implementer != address(0)) {
          IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
      }
  }

  
  function _callTokensReceived(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData,
      bool requireReceptionAck
  )
      private
  {
      address implementer = ERC1820_REGISTRY.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
      if (implementer != address(0)) {
          IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
      } else if (requireReceptionAck) {
          require(!to.isContract(), "PoolToken/no-recip-inter");
      }
  }

  modifier onlyPool() {
    require(msg.sender == address(_pool), "PoolToken/only-pool");
    _;
  }

  modifier notLocked() {
    require(!_pool.isLocked(), "PoolToken/is-locked");
    _;
  }
}


contract RecipientWhitelistPoolToken is PoolToken {
  bool _recipientWhitelistEnabled;
  mapping(address => bool) _recipientWhitelist;

  function recipientWhitelistEnabled() public view returns (bool) {
    return _recipientWhitelistEnabled;
  }

  function recipientWhitelisted(address _recipient) public view returns (bool) {
    return _recipientWhitelist[_recipient];
  }

  function setRecipientWhitelistEnabled(bool _enabled) public onlyAdmin {
    _recipientWhitelistEnabled = _enabled;
  }

  function setRecipientWhitelisted(address _recipient, bool _whitelisted) public onlyAdmin {
    _recipientWhitelist[_recipient] = _whitelisted;
  }

  
  function _callTokensToSend(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
      internal
  {
      if (_recipientWhitelistEnabled) {
        require(to == address(0) || _recipientWhitelist[to], "Pool/not-list");
      }
      super._callTokensToSend(operator, from, to, amount, userData, operatorData);
  }

  modifier onlyAdmin() {
    require(_pool.isAdmin(msg.sender), "WhitelistToken/is-admin");
    _;
  }
}