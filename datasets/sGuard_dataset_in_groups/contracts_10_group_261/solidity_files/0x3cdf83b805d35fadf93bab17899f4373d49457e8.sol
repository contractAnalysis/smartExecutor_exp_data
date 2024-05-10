pragma solidity 0.5.16;


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

interface IRewardsDistributionRecipient {
    function notifyRewardAmount(uint256 reward) external;
    function getRewardToken() external view returns (IERC20);
}

contract InitializableModuleKeys {

    
    bytes32 internal KEY_GOVERNANCE;          
    bytes32 internal KEY_STAKING;             
    bytes32 internal KEY_PROXY_ADMIN;         

    
    bytes32 internal KEY_ORACLE_HUB;          
    bytes32 internal KEY_MANAGER;             
    bytes32 internal KEY_RECOLLATERALISER;    
    bytes32 internal KEY_META_TOKEN;          
    bytes32 internal KEY_SAVINGS_MANAGER;     

    
    function _initialize() internal {
        
        
        KEY_GOVERNANCE = keccak256("Governance");
        KEY_STAKING = keccak256("Staking");
        KEY_PROXY_ADMIN = keccak256("ProxyAdmin");

        KEY_ORACLE_HUB = keccak256("OracleHub");
        KEY_MANAGER = keccak256("Manager");
        KEY_RECOLLATERALISER = keccak256("Recollateraliser");
        KEY_META_TOKEN = keccak256("MetaToken");
        KEY_SAVINGS_MANAGER = keccak256("SavingsManager");
    }
}

interface INexus {
    function governor() external view returns (address);
    function getModule(bytes32 key) external view returns (address);

    function proposeModule(bytes32 _key, address _addr) external;
    function cancelProposedModule(bytes32 _key) external;
    function acceptProposedModule(bytes32 _key) external;
    function acceptProposedModules(bytes32[] calldata _keys) external;

    function requestLockModule(bytes32 _key) external;
    function cancelLockModule(bytes32 _key) external;
    function lockModule(bytes32 _key) external;
}

contract InitializableModule is InitializableModuleKeys {

    INexus public nexus;

    
    modifier onlyGovernor() {
        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    
    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    
    modifier onlyProxyAdmin() {
        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    
    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    
    function _initialize(address _nexus) internal {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
        InitializableModuleKeys._initialize();
    }

    
    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    
    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    
    function _staking() internal view returns (address) {
        return nexus.getModule(KEY_STAKING);
    }

    
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    
    function _metaToken() internal view returns (address) {
        return nexus.getModule(KEY_META_TOKEN);
    }

    
    function _oracleHub() internal view returns (address) {
        return nexus.getModule(KEY_ORACLE_HUB);
    }

    
    function _manager() internal view returns (address) {
        return nexus.getModule(KEY_MANAGER);
    }

    
    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    
    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }
}

contract InitializableGovernableWhitelist is InitializableModule {

    event Whitelisted(address indexed _address);

    mapping(address => bool) public whitelist;

    
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Not a whitelisted address");
        _;
    }

    
    function _initialize(
        address _nexus,
        address[] memory _whitelisted
    )
        internal
    {
        InitializableModule._initialize(_nexus);

        require(_whitelisted.length > 0, "Empty whitelist array");

        for(uint256 i = 0; i < _whitelisted.length; i++) {
            _addWhitelist(_whitelisted[i]);
        }
    }

    
    function _addWhitelist(address _address) internal {
        require(_address != address(0), "Address is zero");
        require(! whitelist[_address], "Already whitelisted");

        whitelist[_address] = true;

        emit Whitelisted(_address);
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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract RewardsDistributor is InitializableGovernableWhitelist {

    using SafeERC20 for IERC20;

    event RemovedFundManager(address indexed _address);
    event DistributedReward(address funder, address recipient, address rewardToken, uint256 amount);

    
    constructor(
        address _nexus,
        address[] memory _fundManagers
    )
        public
    {
        InitializableGovernableWhitelist._initialize(_nexus, _fundManagers);
    }

    
    function addFundManager(address _address)
        external
        onlyGovernor
    {
        _addWhitelist(_address);
    }

    
    function removeFundManager(address _address)
        external
        onlyGovernor
    {
        require(_address != address(0), "Address is zero");
        require(whitelist[_address], "Address is not whitelisted");

        whitelist[_address] = false;

        emit RemovedFundManager(_address);
    }

    
    function distributeRewards(
        IRewardsDistributionRecipient[] calldata _recipients,
        uint256[] calldata _amounts
    )
        external
        onlyWhitelisted
    {
        uint256 len = _recipients.length;
        require(len > 0, "Must choose recipients");
        require(len == _amounts.length, "Mismatching inputs");

        for(uint i = 0; i < len; i++){
            uint256 amount = _amounts[i];
            IRewardsDistributionRecipient recipient = _recipients[i];
            
            IERC20 rewardToken = recipient.getRewardToken();
            rewardToken.safeTransferFrom(msg.sender, address(recipient), amount);
            
            recipient.notifyRewardAmount(amount);

            emit DistributedReward(msg.sender, address(recipient), address(rewardToken), amount);
        }
    }
}