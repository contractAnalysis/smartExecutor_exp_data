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

contract GemLike {
    function allowance(address, address) public returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
}

contract ValueLike {
    function peek() public returns (uint, bool);
}

contract SaiTubLike {
    function skr() public view returns (GemLike);
    function gem() public view returns (GemLike);
    function gov() public view returns (GemLike);
    function sai() public view returns (GemLike);
    function pep() public view returns (ValueLike);
    function vox() public view returns (VoxLike);
    function bid(uint) public view returns (uint);
    function ink(bytes32) public view returns (uint);
    function tag() public view returns (uint);
    function tab(bytes32) public returns (uint);
    function rap(bytes32) public returns (uint);
    function draw(bytes32, uint) public;
    function shut(bytes32) public;
    function exit(uint) public;
    function give(bytes32, address) public;
}

contract VoxLike {
    function par() public returns (uint);
}

contract JoinLike {
    function ilk() public returns (bytes32);
    function gem() public returns (GemLike);
    function dai() public returns (GemLike);
    function join(address, uint) public;
    function exit(address, uint) public;
}
contract VatLike {
    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);
    function hope(address) public;
    function frob(bytes32, address, address, address, int, int) public;
}

contract ManagerLike {
    function vat() public view returns (address);
    function urns(uint) public view returns (address);
    function open(bytes32, address) public returns (uint);
    function frob(uint, int, int) public;
    function give(uint, address) public;
    function move(uint, address, uint) public;
}

contract OtcLike {
    function getPayAmount(address, address, uint) public view returns (uint);
    function buyAllAmount(address, uint, address, uint) public;
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












contract Context is Initializable {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
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




library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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




contract ERC777 is Initializable, Context, IERC777, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    
    

    
    bytes32 constant private TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    
    address[] private _defaultOperatorsArray;

    
    mapping(address => bool) private _defaultOperators;

    
    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    
    mapping (address => mapping (address => uint256)) private _allowances;

    
    function initialize(
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    ) public initializer {
        _name = name;
        _symbol = symbol;

        _defaultOperatorsArray = defaultOperators;
        for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
            _defaultOperators[_defaultOperatorsArray[i]] = true;
        }

        
        ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public pure returns (uint8) {
        return 18;
    }

    
    function granularity() public view returns (uint256) {
        return 1;
    }

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address tokenHolder) public view returns (uint256) {
        return _balances[tokenHolder];
    }

    
    function send(address recipient, uint256 amount, bytes memory data) public {
        _send(_msgSender(), _msgSender(), recipient, amount, data, "", true);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Unlike `send`, `recipient` is _not_ required to implement the {IERC777Recipient}
     * interface if it is a contract.
     *
     * Also emits a {Sent} event.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = _msgSender();

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    /**
     * @dev See {IERC777-burn}.
     *
     * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
     */
    function burn(uint256 amount, bytes memory data) public {
        _burn(_msgSender(), _msgSender(), amount, data, "");
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
    function authorizeOperator(address operator) public {
        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

    
    function revokeOperator(address operator) public {
        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

    
    function defaultOperators() public view returns (address[] memory) {
        return _defaultOperatorsArray;
    }

    
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
    public
    {
        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(_msgSender(), sender, recipient, amount, data, operatorData, true);
    }

    
    function operatorBurn(address account, uint256 amount, bytes memory data, bytes memory operatorData) public {
        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(_msgSender(), account, amount, data, operatorData);
    }

    
    function allowance(address holder, address spender) public view returns (uint256) {
        return _allowances[holder][spender];
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

   
    function transferFrom(address holder, address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = _msgSender();

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");
        _approve(holder, spender, _allowances[holder][spender].sub(amount, "ERC777: transfer amount exceeds allowance"));

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `operator`, `data` and `operatorData`.
     *
     * See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits {Minted} and {IERC20-Transfer} events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function _mint(
        address operator,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
    internal
    {
        require(account != address(0), "ERC777: mint to the zero address");

        
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    
    function _send(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        internal
    {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    
    function _burn(
        address operator,
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        internal
    {
        require(from != address(0), "ERC777: burn from the zero address");

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        
        _balances[from] = _balances[from].sub(amount, "ERC777: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

        emit Burned(operator, from, amount, data, operatorData);
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
        _balances[from] = _balances[from].sub(amount, "ERC777: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _approve(address holder, address spender, uint256 value) internal {
        
        
        
        require(spender != address(0), "ERC777: approve to the zero address");

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
        internal
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
        internal
    {
        address implementer = ERC1820_REGISTRY.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    uint256[50] private ______gap;
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
    function mint(uint256 mintAmount) external returns (uint);
    function redeemUnderlying(uint256 redeemAmount) external returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getCash() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
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







library Blocklock {
  using SafeMath for uint256;

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
    require(cooldownDuration > 0, "Blocklock/cool-min");
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
      blockNumber >= endAt.add(self.cooldownDuration)
    );
  }

  function cooldownEndAt(State storage self) internal view returns (uint256) {
    return lockEndAt(self).add(self.cooldownDuration);
  }

  function lockEndAt(State storage self) internal view returns (uint256) {
    uint256 endAt = self.lockedAt.add(self.lockDuration);
    
    if (self.unlockedAt >= self.lockedAt && self.unlockedAt < endAt) {
      endAt = self.unlockedAt;
    }
    return endAt;
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

  
  function pool() public view returns (BasePool) {
      return _pool;
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
  function decimals() public view returns (uint8) {
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
    * @dev Atomically increases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {IERC20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
      _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
      return true;
  }

  /**
    * @dev Atomically decreases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {IERC20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    * - `spender` must have allowance for the caller of at least
    * `subtractedValue`.
    */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
      _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "PoolToken/negative"));
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

  /**
    * Emits {Minted} and {IERC20-Transfer} events.
    */
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

  /**
    * @dev Send tokens
    * @param operator address operator requesting the transfer
    * @param from address token holder address
    * @param to address recipient address
    * @param amount uint256 amount of tokens to transfer
    * @param userData bytes extra information provided by the token holder (if any)
    * @param operatorData bytes extra information provided by the operator (if any)
    */
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

      _callTokensReceived(operator, from, to, amount, userData, operatorData, false);
  }

  /**
    * @dev Redeems tokens for the underlying asset.
    * @param operator address operator requesting the operation
    * @param from address token holder address
    * @param amount uint256 amount of tokens to redeem
    * @param data bytes extra information provided by the token holder
    * @param operatorData bytes extra information provided by the operator (if any)
    */
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

      _pool.withdrawCommittedDepositFrom(from, amount);

      emit Redeemed(operator, from, amount, data, operatorData);
      emit Transfer(from, address(0), amount);
  }

  /**
   * @notice Moves tokens from one user to another.  Emits Sent and Transfer events.
   */
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

  /**
   * Approves of a token spend by a spender for a holder.
   * @param holder The address from which the tokens are spent
   * @param spender The address that is spending the tokens
   * @param value The amount of tokens to spend
   */
  function _approve(address holder, address spender, uint256 value) private {
      require(spender != address(0), "PoolToken/from-zero");

      _allowances[holder][spender] = value;
      emit Approval(holder, spender, value);
  }

  /**
    * @dev Call from.tokensToSend() if the interface is registered
    * @param operator address operator requesting the transfer
    * @param from address token holder address
    * @param to address recipient address
    * @param amount uint256 amount of tokens to transfer
    * @param userData bytes extra information provided by the token holder (if any)
    * @param operatorData bytes extra information provided by the operator (if any)
    */
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

  /**
    * @dev Call to.tokensReceived() if the interface is registered. Reverts if the recipient is a contract but
    * tokensReceived() was not registered for the recipient
    * @param operator address operator requesting the transfer
    * @param from address token holder address
    * @param to address recipient address
    * @param amount uint256 amount of tokens to transfer
    * @param userData bytes extra information provided by the token holder (if any)
    * @param operatorData bytes extra information provided by the operator (if any)
    * @param requireReceptionAck whether to require that, if the recipient is a contract, it has registered a IERC777Recipient
    */
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

  /**
   * @notice Requires the sender to be the pool contract
   */
  modifier onlyPool() {
    require(msg.sender == address(_pool), "PoolToken/only-pool");
    _;
  }

  /**
   * @notice Requires the contract to be unlocked
   */
  modifier notLocked() {
    require(!_pool.isLocked(), "PoolToken/is-locked");
    _;
  }
}


/**
 * @title The Pool contract
 * @author Brendan Asselstine
 * @notice This contract allows users to pool deposits into Compound and win the accrued interest in periodic draws.
 * Funds are immediately deposited and withdrawn from the Compound cToken contract.
 * Draws go through three stages: open, committed and rewarded in that order.
 * Only one draw is ever in the open stage.  Users deposits are always added to the open draw.  Funds in the open Draw are that user's open balance.
 * When a Draw is committed, the funds in it are moved to a user's committed total and the total committed balance of all users is updated.
 * When a Draw is rewarded, the gross winnings are the accrued interest since the last reward (if any).  A winner is selected with their chances being
 * proportional to their committed balance vs the total committed balance of all users.
 *
 *
 * With the above in mind, there is always an open draw and possibly a committed draw.  The progression is:
 *
 * Step 1: Draw 1 Open
 * Step 2: Draw 2 Open | Draw 1 Committed
 * Step 3: Draw 3 Open | Draw 2 Committed | Draw 1 Rewarded
 * Step 4: Draw 4 Open | Draw 3 Committed | Draw 2 Rewarded
 * Step 5: Draw 5 Open | Draw 4 Committed | Draw 3 Rewarded
 * Step X: ...
 */
contract BasePool is Initializable, ReentrancyGuard {
  using DrawManager for DrawManager.State;
  using SafeMath for uint256;
  using Roles for Roles.Role;
  using Blocklock for Blocklock.State;

  bytes32 internal constant ROLLED_OVER_ENTROPY_MAGIC_NUMBER = bytes32(uint256(1));

  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  
  

  
  bytes32 constant internal REWARD_LISTENER_INTERFACE_HASH =
      0x68f03b0b1a978ee238a70b362091d993343460bc1a2830ab3f708936d9f564a4;

  
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

  
  event RewardListenerFailed(
    uint256 indexed drawId,
    address indexed winner,
    address indexed impl
  );

  
  event NextFeeFractionChanged(uint256 feeFraction);

  
  event NextFeeBeneficiaryChanged(address indexed feeBeneficiary);

  
  event DepositsPaused(address indexed sender);

  
  event DepositsUnpaused(address indexed sender);

  
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

  
  mapping (address => uint256) internal balances;

  
  mapping(uint256 => Draw) internal draws;

  
  DrawManager.State internal drawState;

  
  Roles.Role internal admins;

  
  bool public paused;

  Blocklock.State internal blocklock;

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
    require(address(_poolToken.pool()) == address(this), "Pool/token-mismatch");
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

    uint256 grossWinnings;

    
    
    if (underlyingBalance > accountedBalance) {
      grossWinnings = capWinnings(underlyingBalance.sub(accountedBalance));
    }

    
    uint256 fee = calculateFee(draw.feeFraction, grossWinnings);

    
    balances[draw.feeBeneficiary] = balances[draw.feeBeneficiary].add(fee);

    
    uint256 netWinnings = grossWinnings.sub(fee);

    draw.winner = winningAddress;
    draw.netWinnings = netWinnings;
    draw.fee = fee;
    draw.entropy = entropy;

    
    if (winningAddress != address(0) && netWinnings != 0) {
      
      accountedBalance = underlyingBalance;

      
      balances[winningAddress] = balances[winningAddress].add(netWinnings);

      
      drawState.deposit(winningAddress, netWinnings);

      callRewarded(winningAddress, netWinnings, drawId);
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

  
  function callRewarded(address winner, uint256 netWinnings, uint256 drawId) internal {
    address impl = ERC1820_REGISTRY.getInterfaceImplementer(winner, REWARD_LISTENER_INTERFACE_HASH);
    if (impl != address(0)) {
      (bool success,) = impl.call.gas(200000)(abi.encodeWithSignature("rewarded(address,uint256,uint256)", winner, netWinnings, drawId));
      if (!success) {
        emit RewardListenerFailed(drawId, winner, impl);
      }
    }
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

  
  function capWinnings(uint256 _grossWinnings) internal pure returns (uint256) {
    uint256 max = uint256(FixidityLib.maxNewFixed());
    if (_grossWinnings > max) {
      return max;
    }
    return _grossWinnings;
  }

  
  function calculateFee(uint256 _feeFraction, uint256 _grossWinnings) internal pure returns (uint256) {
    int256 grossWinningsFixed = FixidityLib.newFixed(int256(_grossWinnings));
    
    int256 feeFixed = FixidityLib.multiply(grossWinningsFixed, FixidityLib.newFixed(int256(_feeFraction), uint8(18)));
    return uint256(FixidityLib.fromFixed(feeFixed));
  }

  
  function depositSponsorship(uint256 _amount) public unlessDepositsPaused nonReentrant {
    
    require(token().transferFrom(msg.sender, address(this), _amount), "Pool/t-fail");

    
    _depositSponsorshipFrom(msg.sender, _amount);
  }

  
  function transferBalanceToSponsorship() public unlessDepositsPaused {
    
    _depositSponsorshipFrom(address(this), token().balanceOf(address(this)));
  }

  
  function depositPool(uint256 _amount) public requireOpenDraw unlessDepositsPaused nonReentrant notLocked {
    
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

  
  function withdraw(uint256 amount) public nonReentrant notLocked {
    uint256 remainingAmount = amount;
    
    uint256 sponsorshipAndFeesBalance = sponsorshipAndFeeBalanceOf(msg.sender);
    if (sponsorshipAndFeesBalance < remainingAmount) {
      withdrawSponsorshipAndFee(sponsorshipAndFeesBalance);
      remainingAmount = remainingAmount.sub(sponsorshipAndFeesBalance);
    } else {
      withdrawSponsorshipAndFee(remainingAmount);
      return;
    }

    
    uint256 pendingBalance = drawState.openBalanceOf(msg.sender);
    if (pendingBalance < remainingAmount) {
      _withdrawOpenDeposit(msg.sender, pendingBalance);
      remainingAmount = remainingAmount.sub(pendingBalance);
    } else {
      _withdrawOpenDeposit(msg.sender, remainingAmount);
      return;
    }

    
    _withdrawCommittedDeposit(msg.sender, remainingAmount);
  }

  
  function withdraw() public nonReentrant notLocked {
    uint256 committedBalance = drawState.committedBalanceOf(msg.sender);

    uint256 balance = balances[msg.sender];
    
    drawState.withdraw(msg.sender);
    _withdraw(msg.sender, balance);

    if (address(poolToken) != address(0)) {
      poolToken.poolRedeem(msg.sender, committedBalance);
    }

    emit Withdrawn(msg.sender, balance);
  }

  
  function withdrawSponsorshipAndFee(uint256 _amount) public {
    uint256 sponsorshipAndFees = sponsorshipAndFeeBalanceOf(msg.sender);
    require(_amount <= sponsorshipAndFees, "Pool/exceeds-sfee");
    _withdraw(msg.sender, _amount);

    emit SponsorshipAndFeesWithdrawn(msg.sender, _amount);
  }

  
  function sponsorshipAndFeeBalanceOf(address _sender) public view returns (uint256) {
    return balances[_sender].sub(drawState.balanceOf(_sender));
  }

  
  function withdrawOpenDeposit(uint256 _amount) public nonReentrant notLocked {
    _withdrawOpenDeposit(msg.sender, _amount);
  }

  function _withdrawOpenDeposit(address sender, uint256 _amount) internal {
    drawState.withdrawOpen(sender, _amount);
    _withdraw(sender, _amount);

    emit OpenDepositWithdrawn(sender, _amount);
  }

  
  function withdrawCommittedDeposit(uint256 _amount) public nonReentrant notLocked returns (bool)  {
    _withdrawCommittedDeposit(msg.sender, _amount);
    return true;
  }

  function _withdrawCommittedDeposit(address sender, uint256 _amount) internal {
    _withdrawCommittedDepositAndEmit(sender, _amount);
    if (address(poolToken) != address(0)) {
      poolToken.poolRedeem(sender, _amount);
    }
  }

  
  function withdrawCommittedDepositFrom(
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
    uint256 balance = balances[_sender];

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

  
  function pauseDeposits() public unlessDepositsPaused onlyAdmin {
    paused = true;

    emit DepositsPaused(msg.sender);
  }

  
  function unpauseDeposits() public whenDepositsPaused onlyAdmin {
    paused = false;

    emit DepositsUnpaused(msg.sender);
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

  
  modifier whenDepositsPaused() {
    require(paused, "Pool/d-not-paused");
    _;
  }

  
  modifier unlessDepositsPaused() {
    require(!paused, "Pool/d-paused");
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





contract ScdMcdMigration {
    SaiTubLike                  public tub;
    VatLike                     public vat;
    ManagerLike                 public cdpManager;
    JoinLike                    public saiJoin;
    JoinLike                    public wethJoin;
    JoinLike                    public daiJoin;

    constructor(
        address tub_,           
        address cdpManager_,    
        address saiJoin_,       
        address wethJoin_,      
        address daiJoin_        
    ) public {
        tub = SaiTubLike(tub_);
        cdpManager = ManagerLike(cdpManager_);
        vat = VatLike(cdpManager.vat());
        saiJoin = JoinLike(saiJoin_);
        wethJoin = JoinLike(wethJoin_);
        daiJoin = JoinLike(daiJoin_);

        require(wethJoin.gem() == tub.gem(), "non-matching-weth");
        require(saiJoin.gem() == tub.sai(), "non-matching-sai");

        tub.gov().approve(address(tub), uint(-1));
        tub.skr().approve(address(tub), uint(-1));
        tub.sai().approve(address(tub), uint(-1));
        tub.sai().approve(address(saiJoin), uint(-1));
        wethJoin.gem().approve(address(wethJoin), uint(-1));
        daiJoin.dai().approve(address(daiJoin), uint(-1));
        vat.hope(address(daiJoin));
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    
    
    
    function swapSaiToDai(
        uint wad
    ) external {
        
        saiJoin.gem().transferFrom(msg.sender, address(this), wad);
        
        saiJoin.join(address(this), wad);
        
        vat.frob(saiJoin.ilk(), address(this), address(this), address(this), toInt(wad), toInt(wad));
        
        daiJoin.exit(msg.sender, wad);
    }

    
    
    
    function swapDaiToSai(
        uint wad
    ) external {
        
        daiJoin.dai().transferFrom(msg.sender, address(this), wad);
        
        daiJoin.join(address(this), wad);
        
        vat.frob(saiJoin.ilk(), address(this), address(this), address(this), -toInt(wad), -toInt(wad));
        
        saiJoin.exit(msg.sender, wad);
    }

    
    
    function migrate(
        bytes32 cup
    ) external returns (uint cdp) {
        
        uint debtAmt = tub.tab(cup);    
        uint pethAmt = tub.ink(cup);    
        uint ethAmt = tub.bid(pethAmt); 

        
        
        
        vat.frob(
            bytes32(saiJoin.ilk()),
            address(this),
            address(this),
            address(this),
            -toInt(debtAmt),
            0
        );
        saiJoin.exit(address(this), debtAmt); 

        
        tub.shut(cup);      
        tub.exit(pethAmt);  

        
        cdp = cdpManager.open(wethJoin.ilk(), address(this));

        
        wethJoin.join(cdpManager.urns(cdp), ethAmt);

        
        (, uint rate,,,) = vat.ilks(wethJoin.ilk());
        cdpManager.frob(
            cdp,
            toInt(ethAmt),
            toInt(mul(debtAmt, 10 ** 27) / rate + 1) 
        );
        
        cdpManager.move(cdp, address(this), mul(debtAmt, 10 ** 27));
        
        vat.frob(
            bytes32(saiJoin.ilk()),
            address(this),
            address(this),
            address(this),
            0,
            -toInt(debtAmt)
        );

        
        cdpManager.give(cdp, msg.sender);
    }
}





contract MCDAwarePool is BasePool, IERC777Recipient {
  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  
  bytes32 constant internal TOKENS_RECIPIENT_INTERFACE_HASH =
      0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

  uint256 internal constant DEFAULT_LOCK_DURATION = 40;
  uint256 internal constant DEFAULT_COOLDOWN_DURATION = 80;

  
  ScdMcdMigration public scdMcdMigration;

  
  MCDAwarePool public saiPool;

  
  function init (
    address _owner,
    address _cToken,
    uint256 _feeFraction,
    address _feeBeneficiary,
    uint256 lockDuration,
    uint256 cooldownDuration
  ) public initializer {
    super.init(
      _owner,
      _cToken,
      _feeFraction,
      _feeBeneficiary,
      lockDuration,
      cooldownDuration
    );
    initRegistry();
    initBlocklock(lockDuration, cooldownDuration);
  }

  
  function initMCDAwarePool(uint256 lockDuration, uint256 cooldownDuration) public {
    initRegistry();
    if (blocklock.lockDuration == 0) {
      initBlocklock(lockDuration, cooldownDuration);
    }
  }

  function initRegistry() internal {
    ERC1820_REGISTRY.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
  }

  function initMigration(ScdMcdMigration _scdMcdMigration, MCDAwarePool _saiPool) public onlyAdmin {
    _initMigration(_scdMcdMigration, _saiPool);
  }

  function _initMigration(ScdMcdMigration _scdMcdMigration, MCDAwarePool _saiPool) internal {
    require(address(scdMcdMigration) == address(0), "Pool/init");
    require(address(_scdMcdMigration) != address(0), "Pool/mig-def");
    scdMcdMigration = _scdMcdMigration;
    saiPool = _saiPool; 
  }

  
  function tokensReceived(
    address, 
    address from,
    address, 
    uint256 amount,
    bytes calldata,
    bytes calldata
  ) external unlessDepositsPaused {
    require(msg.sender == address(saiPoolToken()), "Pool/sai-only");
    require(address(token()) == address(daiToken()), "Pool/not-dai");

    
    saiPoolToken().redeem(amount, '');

    // approve of the transfer to the migration contract
    saiToken().approve(address(scdMcdMigration), amount);

    // migrate the sai to dai.  The contract now has dai
    scdMcdMigration.swapSaiToDai(amount);

    if (currentCommittedDrawId() > 0) {
      // now deposit the dai as tickets
      _depositPoolFromCommitted(from, amount);
    } else {
      _depositPoolFrom(from, amount);
    }
  }

  /**
   * @notice Returns the address of the PoolSai pool token contract
   * @return The address of the Sai PoolToken contract
   */
  function saiPoolToken() internal view returns (PoolToken) {
    if (address(saiPool) != address(0)) {
      return saiPool.poolToken();
    } else {
      return PoolToken(0);
    }
  }

  /**
   * @notice Returns the address of the Sai token
   * @return The address of the sai token
   */
  function saiToken() public returns (GemLike) {
    return scdMcdMigration.saiJoin().gem();
  }

  /**
   * @notice Returns the address of the Dai token
   * @return The address of the Dai token.
   */
  function daiToken() public returns (GemLike) {
    return scdMcdMigration.daiJoin().dai();
  }
}



/**
 * @author Brendan Asselstine
 * @notice Users can listen for rewards by registering RewardListeners using ERC1820.  The reward listeners must
 * implement this interface.
 */
interface IRewardListener {
  /**
   * @notice Triggered when the winner is awarded.  This function must not use more than 200,000 gas.
   * @param winner The user that won
   * @param winnings The amount they won
   * @param drawId The draw id that they won
   */
  function rewarded(address winner, uint256 winnings, uint256 drawId) external;
}

/**
Copyright 2020 PoolTogether Inc.

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/





/**
 * @author Brendan Asselstine
 * @notice Library for tracking deposits with respect to time.
 *
 * This library allows a user to "schedule" a deposit.  The deposit will be valid on and after a given timestamp.
 *
 * The word "timestamp" is used here because time always moves forward.  However, the value used for the timestamps
 * could have any granularity.  In the Pod, we're passing draw ids.
 *
 * The contract only stores the deposit for a particular timestamp.  If a subsequent deposit is made with a later timestamp,
 * that deposit replaces the current deposit.
 */
library ScheduledBalance {
  using SafeMath for uint256;

  
  struct State {
    uint256 lastDeposit;
    uint256 lastTimestamp;
  }

  
  function deposit(State storage self, uint256 amount, uint256 currentTimestamp) internal {
    require(currentTimestamp >= self.lastTimestamp, "ScheduledBalance/backwards");
    if (self.lastTimestamp == currentTimestamp) {
      self.lastDeposit = self.lastDeposit.add(amount);
    } else {
      self.lastDeposit = amount;
      self.lastTimestamp = currentTimestamp;
    }
  }

  
  function withdraw(State storage self, uint256 amount) internal {
    require(amount <= self.lastDeposit, "ScheduledBalance/insuff");
    self.lastDeposit = self.lastDeposit.sub(amount);
  }

  
  function balanceAt(State storage self, uint256 currentTimestamp) internal view returns (uint256) {
    (uint256 balance,) = balanceInfoAt(self, currentTimestamp);
    return balance;
  }

  
  function balanceInfoAt(
    State storage self,
    uint256 currentTimestamp
  ) internal view returns (uint256 balance, uint256 timestamp) {
    if (self.lastTimestamp <= currentTimestamp) {
      balance = self.lastDeposit;
      timestamp = self.lastTimestamp;
    }
    return (balance, timestamp);
  }

  
  function withdrawAll(State storage self) internal {
    delete self.lastTimestamp;
    delete self.lastDeposit;
  }
}












library FixedPoint {
  using SafeMath for uint256;

  
  uint256 public constant SCALE = 1e18;

  
  struct Fixed18 {
    uint256 mantissa;
  }

  
  function calculateMantissa(uint256 numerator, uint256 denominator) public pure returns (uint256) {
    uint256 mantissa = numerator.mul(SCALE);
    mantissa = mantissa.div(denominator);
    return mantissa;
  }

  
  function multiplyUint(Fixed18 storage f, uint256 b) public view returns (uint256) {
    uint256 result = f.mantissa.mul(b);
    result = result.div(SCALE);
    return result;
  }

  
  function divideUintByFixed(uint256 dividend, Fixed18 storage divisor) public view returns (uint256) {
    return divideUintByMantissa(dividend, divisor.mantissa);
  }

  
  function divideUintByMantissa(uint256 dividend, uint256 mantissa) public pure returns (uint256) {
    uint256 result = SCALE.mul(dividend);
    result = result.div(mantissa);
    return result;
  }
}



library ExchangeRateTracker {

  
  struct ExchangeRate {
    uint256 timestamp;
    FixedPoint.Fixed18 exchangeRate;
  }

  
  struct State {
    ExchangeRate[] exchangeRates;
  }

  
  function initialize(State storage self, uint256 baseExchangeRateMantissa) internal {
    require(baseExchangeRateMantissa > 0, "ExchangeRateTracker/non-zero");
    require(self.exchangeRates.length == 0, "ExchangeRateTracker/init-prev");
    self.exchangeRates.push(ExchangeRate(0, FixedPoint.Fixed18(baseExchangeRateMantissa)));
  }

  
  function collateralizationChanged(
    State storage self,
    uint256 tokens,
    uint256 collateral,
    uint256 timestamp
  ) internal returns (uint256) {
    wasInitialized(self);
    require(self.exchangeRates[self.exchangeRates.length - 1].timestamp <= timestamp, "ExchangeRateTracker/too-early");
    FixedPoint.Fixed18 memory rate = FixedPoint.Fixed18(FixedPoint.calculateMantissa(tokens, collateral));
    self.exchangeRates.push(ExchangeRate(timestamp, rate));
    return rate.mantissa;
  }

  
  function tokenToCollateralValue(State storage self, uint256 tokens) internal view returns (uint256) {
    return FixedPoint.divideUintByFixed(tokens, currentExchangeRate(self));
  }

  
  function collateralToTokenValue(State storage self, uint256 collateral) internal view returns (uint256) {
    return FixedPoint.multiplyUint(currentExchangeRate(self), collateral);
  }

  
  function tokenToCollateralValueAt(State storage self, uint256 tokens, uint256 timestamp) internal view returns (uint256) {
    uint256 exchangeRateIndex = search(self, timestamp);
    return FixedPoint.divideUintByFixed(tokens, self.exchangeRates[exchangeRateIndex].exchangeRate);
  }

  
  function collateralToTokenValueAt(State storage self, uint256 collateral, uint256 timestamp) internal view returns (uint256) {
    uint256 exchangeRateIndex = search(self, timestamp);
    return FixedPoint.multiplyUint(self.exchangeRates[exchangeRateIndex].exchangeRate, collateral);
  }

  
  function currentExchangeRate(State storage self) internal view returns (FixedPoint.Fixed18 storage) {
    wasInitialized(self);
    return self.exchangeRates[self.exchangeRates.length - 1].exchangeRate;
  }

  
  function search(State storage self, uint256 timestamp) internal view returns (uint256) {
    wasInitialized(self);

    uint256 lowerBound = 0;
    uint256 upperBound = self.exchangeRates.length;

    while (lowerBound < upperBound - 1) {
        uint256 midPoint = lowerBound + (upperBound - lowerBound) / 2;

        if (timestamp < self.exchangeRates[midPoint].timestamp) {
          upperBound = midPoint;
        } else {
          lowerBound = midPoint;
        }
    }

    return upperBound - 1;
  }

  function wasInitialized(State storage self) internal view {
    require(self.exchangeRates.length > 0, "ExchangeRateTracker/not-init");
  }
}



contract Pod is ERC777, ReentrancyGuard, IERC777Recipient, IRewardListener {
  using ScheduledBalance for ScheduledBalance.State;
  using ExchangeRateTracker for ExchangeRateTracker.State;

  
  uint256 internal constant BASE_EXCHANGE_RATE_MANTISSA = 1e24;

  
  bytes32 constant internal REWARD_LISTENER_INTERFACE_HASH =
      0x68f03b0b1a978ee238a70b362091d993343460bc1a2830ab3f708936d9f564a4;

  
  bytes32 constant internal TOKENS_RECIPIENT_INTERFACE_HASH =
      0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

  
  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  
  event PendingDepositWithdrawn(address indexed operator, address indexed from, uint256 collateral, bytes data, bytes operatorData);

  
  event Redeemed(address indexed operator, address indexed from, uint256 amount, uint256 collateral, bytes data, bytes operatorData);

  
  event RedeemedToPool(address indexed operator, address indexed from, uint256 amount, uint256 collateral, bytes data, bytes operatorData);

  
  event CollateralizationChanged(uint256 indexed timestamp, uint256 tokens, uint256 collateral, uint256 mantissa);

  
  event Deposited(address indexed operator, address indexed from, uint256 collateral, uint256 drawId, bytes data, bytes operatorData);

  
  ScheduledBalance.State internal scheduledSupply;

  
  mapping(address => ScheduledBalance.State) internal scheduledBalances;

  
  ExchangeRateTracker.State internal exchangeRateTracker;

  
  MCDAwarePool public pool;

  
  function initialize(
    MCDAwarePool _pool
  ) public initializer {
    require(address(_pool) != address(0), "Pod/pool-def");
    exchangeRateTracker.initialize(BASE_EXCHANGE_RATE_MANTISSA);
    pool = _pool;
    ERC1820_REGISTRY.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    ERC1820_REGISTRY.setInterfaceImplementer(address(this), REWARD_LISTENER_INTERFACE_HASH, address(this));
  }

  
  function operatorDeposit(address user, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
    _deposit(msg.sender, user, amount, data, operatorData);
  }

  
  function deposit(uint256 amount, bytes calldata data) external {
    _deposit(msg.sender, msg.sender, amount, data, "");
  }

  /**
   * @notice Deposits on behalf of a user by an operator.  The operator may also be the user. The deposit will become Pod shares upon the next Pool reward.
   *
   * @dev If there is an existing deposit for the open draw, the deposits will be combined.  Otherwise, if there is an existing deposit for the
   * committed draw then those tokens will be transferred to the user.  We can do so because *we always have the exchange rate for the committed draw*
   *
   * @param operator The operator who kicked of the deposit
   * @param from The user on whose behalf to deposit
   * @param amount The amount of collateral to deposit
   * @param data Included user data
   * @param operatorData Included operator data
   */
  function _deposit(
    address operator,
    address from,
    uint256 amount,
    bytes memory data,
    bytes memory operatorData
  ) internal nonReentrant {
    consolidateBalanceOf(from);
    pool.token().transferFrom(from, address(this), amount);
    pool.token().approve(address(pool), amount);
    pool.depositPool(amount);
    uint256 openDrawId = pool.currentOpenDrawId();
    scheduledSupply.deposit(amount, openDrawId);
    scheduledBalances[from].deposit(amount, openDrawId);
    emit Deposited(operator, from, amount, openDrawId, data, operatorData);
  }

  /**
   * @notice IERC777Recipient callback to handle direct Pool token transfers. When users transfer their Pool tickets to this contract they will be instantly converted into Pod shares.
   * @param from The user whose tickets are being transferred
   * @param amount The number of tickets being transferred
   */
  function tokensReceived(
    address,
    address from,
    address, // to address can't be anything but us because we don't implement ERC1820ImplementerInterface
    uint256 amount,
    bytes calldata,
    bytes calldata
  ) external {
    // if this is a transfer of pool tickets
    if (msg.sender == address(pool.poolToken())) {
      // convert to shares
      consolidateBalanceOf(from);
      uint256 tokens = exchangeRateTracker.collateralToTokenValue(amount);
      _mint(address(this), from, tokens, "", "");
    } else {
      // The only other allowed token is itself and the asset
      require(msg.sender == address(this) || msg.sender == address(pool.token()), "Pod/unknown-token");
    }
  }

  
  function balanceOfUnderlying(address user) public view returns (uint256) {
    return exchangeRateTracker.tokenToCollateralValue(balanceOf(user));
  }

  
  function pendingDeposit(address user) public view returns (uint256) {
    
    uint256 committedBalance = scheduledBalances[user].balanceAt(pool.currentCommittedDrawId());
    return scheduledBalances[user].balanceAt(pool.currentOpenDrawId()).sub(committedBalance);
  }

  function totalPendingDeposits() public view returns (uint256) {
    uint256 committedBalance = scheduledSupply.balanceAt(pool.currentCommittedDrawId());
    return scheduledSupply.balanceAt(pool.currentOpenDrawId()).sub(committedBalance);
  }

  
  function operatorWithdrawPendingDeposit(
    address from,
    uint256 amount,
    bytes calldata data,
    bytes calldata operatorData
  ) external {
    require(isOperatorFor(msg.sender, from), "Pod/not-op");
    _withdrawPendingDeposit(msg.sender, from, amount, data, operatorData);
  }

  function withdrawAndRedeemCollateral(uint256 collateral) external nonReentrant {
    _withdrawAndRedeemCollateral(msg.sender, msg.sender, collateral);
  }

  function operatorWithdrawAndRedeemCollateral(address from, uint256 collateral) external nonReentrant {
    require(isOperatorFor(msg.sender, from), "Pod/not-op");
    _withdrawAndRedeemCollateral(msg.sender, from, collateral);
  }

  function _withdrawAndRedeemCollateral(address operator, address from, uint256 amount) internal {
    uint256 remainingCollateral = amount;
    uint256 pending = pendingDeposit(from);
    if (pending < remainingCollateral) {
      _withdrawPendingDeposit(operator, from, pending, "", "");
      remainingCollateral = remainingCollateral.sub(pending);
    } else {
      _withdrawPendingDeposit(operator, from, remainingCollateral, "", "");
      return;
    }

    uint256 tokens = exchangeRateTracker.collateralToTokenValue(remainingCollateral);
    _redeem(operator, from, tokens, "", "");
  }

  /**
   * @notice Allows a user to withdraw their pending deposit
   * @param amount The amount the user wishes to withdraw
   * @param data Data included by the user
   */
  function withdrawPendingDeposit(
    uint256 amount,
    bytes calldata data
  ) external {
    _withdrawPendingDeposit(msg.sender, msg.sender, amount, data, "");
  }

  /**
   * @notice Withdraw from a user's pending deposit
   * @param operator The operator conducting the withdrawal
   * @param from The user whose deposit will be withdrawn
   * @param amount The amount to withdraw
   * @param data Data included by the user
   * @param operatorData Data included by the operator
   */
  function _withdrawPendingDeposit(
    address operator,
    address from,
    uint256 amount,
    bytes memory data,
    bytes memory operatorData
  ) internal {
    consolidateBalanceOf(from);
    scheduledSupply.withdraw(amount);
    scheduledBalances[from].withdraw(amount);
    pool.withdrawOpenDeposit(amount);
    pool.token().transfer(from, amount);

    emit PendingDepositWithdrawn(operator, from, amount, data, operatorData);
  }

  // =============================================== //
  // ============== ERC777 Overrides =============== //
  // =============================================== //

  /**
    * @dev Moves `amount` tokens from the caller's account to `recipient`.
    *
    * If send or receive hooks are registered for the caller and `recipient`,
    * the corresponding functions will be called with `data` and empty
    * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
    *
    * Emits a {Sent} event.
    *
    * Requirements
    *
    * - the caller must have at least `amount` tokens.
    * - `recipient` cannot be the zero address.
    * - if `recipient` is a contract, it must implement the {IERC777Recipient}
    * interface.
    */
  function send(address recipient, uint256 amount, bytes memory data) public {
    consolidateBalanceOf(msg.sender);
    super.send(recipient, amount, data);
  }

  /**
    * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
    * be an operator of `sender`.
    *
    * If send or receive hooks are registered for `sender` and `recipient`,
    * the corresponding functions will be called with `data` and
    * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
    *
    * Emits a {Sent} event.
    *
    * Requirements
    *
    * - `sender` cannot be the zero address.
    * - `sender` must have at least `amount` tokens.
    * - the caller must be an operator for `sender`.
    * - `recipient` cannot be the zero address.
    * - if `recipient` is a contract, it must implement the {IERC777Recipient}
    * interface.
    */
  function operatorSend(
      address sender,
      address recipient,
      uint256 amount,
      bytes memory data,
      bytes memory operatorData
  ) public {
    consolidateBalanceOf(sender);
    super.operatorSend(sender, recipient, amount, data, operatorData);
  }

  // ============= End ERC777 Overrides ============ //

  // =============================================== //
  // =============== ERC20 Overrides =============== //
  // =============================================== //

  /**
   * @notice Returns the number of tokens held by the given user.  Does not include pending deposits.
   * @param tokenHolder The user whose balance should be checked
   * @return The users total balance of tokens.
   */
  function balanceOf(address tokenHolder) public view returns (uint256) {
    (uint256 balance, uint256 drawId) = scheduledBalances[tokenHolder].balanceInfoAt(pool.currentCommittedDrawId());
    return super.balanceOf(tokenHolder).add(
      exchangeRateTracker.collateralToTokenValueAt(
        balance,
        drawId
      )
    );
  }

  /**
   * @notice Returns the total supply of tokens.  Does not included any pending deposits.
   * @return The total supply of tokens.
   */
  function totalSupply() public view returns (uint256) {
    (uint256 balance, uint256 drawId) = scheduledSupply.balanceInfoAt(pool.currentCommittedDrawId());
    return super.totalSupply().add(
      exchangeRateTracker.collateralToTokenValueAt(
        balance,
        drawId
      )
    );
  }

  /**
    * @dev Moves `amount` tokens from the caller's account to `recipient`.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
  function transfer(address recipient, uint256 amount) public returns (bool) {
    consolidateBalanceOf(msg.sender);
    return super.transfer(recipient, amount);
  }

  /**
    * @dev Moves `amount` tokens from `sender` to `recipient` using the
    * allowance mechanism. `amount` is then deducted from the caller's
    * allowance.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    consolidateBalanceOf(sender);
    return super.transferFrom(sender, recipient, amount);
  }

  // ============= End ERC20 Overrides ============= //

  /**
    * @dev See {IERC777-operatorBurn}.
    *
    * This contract does not support burning.  Redeem must be called.
    */
  function operatorBurn(address, uint256, bytes memory, bytes memory) public {
    revert("Pod/no-op");
  }

  
  function burn(uint256, bytes memory) public {
    revert("Pod/no-op");
  }

  
  function rewarded(address, uint256 winnings, uint256 drawId) external nonReentrant {
    require(msg.sender == address(pool), "Pod/only-pool");
    uint256 tokens = totalSupply();
    uint256 collateral = exchangeRateTracker.tokenToCollateralValue(tokens).add(winnings);
    
    uint256 mantissa = exchangeRateTracker.collateralizationChanged(tokens, collateral, drawId.add(1));
    emit CollateralizationChanged(drawId, tokens, collateral, mantissa);
  }

  
  function currentExchangeRateMantissa() external view returns (uint256) {
    return exchangeRateTracker.currentExchangeRate().mantissa;
  }

  
  function operatorRedeem(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external nonReentrant {
    require(isOperatorFor(msg.sender, account), "Pod/not-op");
    _redeem(msg.sender, account, amount, data, operatorData);
  }

  
  function redeem(uint256 amount, bytes calldata data) external nonReentrant {
    _redeem(msg.sender, msg.sender, amount, data, "");
  }

  /**
    * @notice Redeems tokens for the underlying asset.
    * @param operator address operator requesting the operation
    * @param from address token holder address
    * @param amount uint256 amount of tokens to redeem
    * @param data bytes extra information provided by the token holder
    * @param operatorData bytes extra information provided by the operator (if any)
    */
  function _redeem(
      address operator,
      address from,
      uint256 amount,
      bytes memory data,
      bytes memory operatorData
  )
      internal
  {
      consolidateBalanceOf(from);
      uint256 collateral = exchangeRateTracker.tokenToCollateralValue(amount);
      pool.withdrawCommittedDeposit(collateral);
      pool.token().transfer(from, collateral);
      emit Redeemed(operator, from, amount, collateral, data, operatorData);
      _burn(operator, from, amount, data, operatorData);
  }

  /**
   * @notice Allows an operator to redeem tokens for Pool tickets on behalf of a user.
   * @param account The user who is redeeming tokens
   * @param amount The amount of tokens to convert to Pool tickets
   * @param data User data included with the tx
   * @param operatorData Operator data included with the tx
   */
  function operatorRedeemToPool(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external nonReentrant {
    require(isOperatorFor(msg.sender, account), "Pod/not-op");
    _redeemToPool(msg.sender, account, amount, data, operatorData);
  }

  
  function redeemToPool(uint256 amount, bytes calldata data) external nonReentrant {
    _redeemToPool(msg.sender, msg.sender, amount, data, "");
  }

  /**
   * @notice Allows an operator to redeem tokens for Pool tickets on behalf of a user.
   * @param operator The operator who is running the tx
   * @param from The user who is redeeming tokens
   * @param amount The amount of tokens to convert to Pool tickets
   * @param data User data included with the tx
   * @param operatorData Operator data included with the tx
   */
  function _redeemToPool(
    address operator,
    address from,
    uint256 amount,
    bytes memory data,
    bytes memory operatorData
  ) internal {
    consolidateBalanceOf(from);
    uint256 collateral = exchangeRateTracker.tokenToCollateralValue(amount);
    pool.poolToken().transfer(from, collateral);
    emit RedeemedToPool(operator, from, amount, collateral, data, operatorData);
    _burn(operator, from, amount, data, operatorData);
  }

  function tokenToCollateralValue(uint256 tokens) external view returns (uint256) {
    return exchangeRateTracker.tokenToCollateralValue(tokens);
  }

  function collateralToTokenValue(uint256 collateral) external view returns (uint256) {
    return exchangeRateTracker.collateralToTokenValue(collateral);
  }

  /**
   * @dev Mints tokens to the Pod using any consolidated supply, then zeroes out the supply.
   */
  function consolidateSupply() internal {
    (uint256 balance, uint256 drawId) = scheduledSupply.balanceInfoAt(pool.currentCommittedDrawId());
    uint256 tokens = exchangeRateTracker.collateralToTokenValueAt(balance, drawId);
    if (tokens > 0) {
      scheduledSupply.withdrawAll();
      _mint(address(this), address(this), tokens, "", "");
    }
  }

  /**
   * @notice Ensures any pending shares are minted to the user.
   * @dev First calls `consolidateSupply()`, then transfers tokens from the Pod to the user based
   * on the user's consolidated supply.  Finally, it zeroes out the user's consolidated supply.
   *
   * @param user The user whose balance should be consolidated.
   */
  function consolidateBalanceOf(address user) internal {
    consolidateSupply();
    (uint256 balance, uint256 drawId) = scheduledBalances[user].balanceInfoAt(pool.currentCommittedDrawId());
    uint256 tokens = exchangeRateTracker.collateralToTokenValueAt(balance, drawId);
    if (tokens > 0) {
      scheduledBalances[user].withdrawAll();
      _send(address(this), address(this), user, tokens, "", "", true);
    }
  }

  
    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool
    )
        internal
    {
        address implementer = ERC1820_REGISTRY.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        }
    }
}