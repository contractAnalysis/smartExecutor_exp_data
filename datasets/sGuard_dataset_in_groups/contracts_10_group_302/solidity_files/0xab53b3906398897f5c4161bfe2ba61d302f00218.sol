pragma solidity ^0.5.0;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



pragma solidity ^0.5.0;


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



pragma solidity ^0.5.0;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}



pragma solidity ^0.5.0;





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
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
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



pragma solidity ^0.5.0;




contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}



pragma solidity ^0.5.0;



contract ERC20Burnable is ERC20 {
    
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}



pragma solidity ^0.5.0;


contract ReentrancyGuard {
    
    uint256 private _guardCounter;

    constructor () internal {
        
        
        _guardCounter = 1;
    }

    
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}



pragma solidity >=0.4.24 <0.6.0;


contract VersionedInitializable {
    
    uint256 private lastInitializedRevision = 0;

    
    bool private initializing;

    
    modifier initializer() {
        uint256 revision = getRevision();
        require(initializing || isConstructor() || revision > lastInitializedRevision, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            lastInitializedRevision = revision;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    
    
    function getRevision() internal pure returns(uint256);


    
    function isConstructor() private view returns (bool) {
        
        
        
        
        
        uint256 cs;
        
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    
    uint256[50] private ______gap;
}



pragma solidity ^0.5.0;


interface IKyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, IERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);
    function getExpectedRate(IERC20 src, IERC20 dest, uint srcQty)
        external view returns (uint expectedRate, uint slippageRate);
    function tradeWithHint(
        IERC20 src,
        uint srcAmount,
        IERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes calldata hint) external payable returns(uint);
}



pragma solidity ^0.5.0;

library EthAddressLib {

    
    function ethAddress() internal pure returns(address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}



pragma solidity ^0.5.0;

library UintConstants {
    
    function maxUint() internal pure returns(uint256) {
        return uint256(-1);
    }

    
    function maxUintMinus1() internal pure returns(uint256) {
        return uint256(-1) - 1;
    }
}



pragma solidity ^0.5.0;





contract IExchangeAdapter {
    using SafeERC20 for IERC20;

    event Exchange(
        address indexed from,
        address indexed to,
        address indexed platform,
        uint256 fromAmount,
        uint256 toAmount
    );

    function approveExchange(IERC20[] calldata _tokens) external;

    function exchange(address _from, address _to, uint256 _amount, uint256 _maxSlippage) external returns(uint256);
}



pragma solidity ^0.5.0;





















contract TokenDistributor is ReentrancyGuard, VersionedInitializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Distribution {
        address[] receivers;
        uint256[] percentages;
    }

    event DistributionUpdated(address[] receivers, uint256[] percentages);
    event Distributed(address receiver, uint256 percentage, uint256 amount);
    event Setup(address tokenToBurn, IExchangeAdapter exchangeAdapter, address _recipientBurn);
    event Burn(uint256 amount);

    uint256 public constant IMPLEMENTATION_REVISION = 0x4;

    
    uint256 public constant MAX_UINT = 2**256 - 1;

    
    uint256 public constant MAX_UINT_MINUS_ONE = (2**256 - 1) - 1;

    
    uint256 public constant MIN_CONVERSION_RATE = 1;

    
    address public constant KYBER_ETH_MOCK_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    
    Distribution private distribution;

    
    uint256 public constant DISTRIBUTION_BASE = 10000;

   
    IKyberNetworkProxyInterface public kyberProxy;

    
    address public tokenToBurn;

    
    
    
    address public recipientBurn;

    
    
    IExchangeAdapter public exchangeAdapter;

    
    function initialize(
        address _recipientBurn,
        address _tokenToBurn,
        IExchangeAdapter _exchangeAdapter,
        address[] memory _receivers,
        uint256[] memory _percentages
    ) public initializer {
        recipientBurn = _recipientBurn;
        tokenToBurn = _tokenToBurn;
        exchangeAdapter = _exchangeAdapter;
        internalSetTokenDistribution(_receivers, _percentages);
        emit Setup(_tokenToBurn, _exchangeAdapter, _recipientBurn);
    }

    
    function() external payable {}

    
    
    function approveExchange(IERC20[] memory _tokens) public {
        (bool _success, ) = address(exchangeAdapter).delegatecall(
            abi.encodeWithSelector(exchangeAdapter.approveExchange.selector, _tokens)
        );
    }

    
    
    function distribute(IERC20[] memory _tokens) public {
        for (uint256 i = 0; i < _tokens.length; i++) {
            uint256 _balanceToDistribute = (address(_tokens[i]) != EthAddressLib.ethAddress())
                ? _tokens[i].balanceOf(address(this))
                : address(this).balance;
            if (_balanceToDistribute <= 0) {
                continue;
            }

            internalDistributeTokenWithAmount(_tokens[i], _balanceToDistribute);
        }
    }

    
    
    
    function distributeWithAmounts(IERC20[] memory _tokens, uint256[] memory _amounts) public {
        for (uint256 i = 0; i < _tokens.length; i++) {
            internalDistributeTokenWithAmount(_tokens[i], _amounts[i]);
        }
    }

    
    
    
    function distributeWithPercentages(IERC20[] memory _tokens, uint256[] memory _percentages) public {
        for (uint256 i = 0; i < _tokens.length; i++) {
            uint256 _amountToDistribute = (address(_tokens[i]) != EthAddressLib.ethAddress())
                ? _tokens[i].balanceOf(address(this)).mul(_percentages[i]).div(100)
                : address(this).balance.mul(_percentages[i]).div(100);
            if (_amountToDistribute <= 0) {
                continue;
            }

            internalDistributeTokenWithAmount(_tokens[i], _amountToDistribute);
        }
    }

    
    
    
    
    function internalSetTokenDistribution(address[] memory _receivers, uint256[] memory _percentages) internal {
        require(_receivers.length == _percentages.length, "Array lengths should be equal");

        distribution = Distribution({receivers: _receivers, percentages: _percentages});
        emit DistributionUpdated(_receivers, _percentages);
    }

    
    
    
    function internalDistributeTokenWithAmount(IERC20 _token, uint256 _amountToDistribute) internal {
        address _tokenAddress = address(_token);
        Distribution memory _distribution = distribution;
        for (uint256 j = 0; j < _distribution.receivers.length; j++) {
            uint256 _amount = _amountToDistribute.mul(_distribution.percentages[j]).div(DISTRIBUTION_BASE);

            
            if(_amount == 0){
                continue;
            }

            if (_distribution.receivers[j] != address(0)) {
                if (_tokenAddress != EthAddressLib.ethAddress()) {
                    _token.safeTransfer(_distribution.receivers[j], _amount);
                } else {
                    
                    (bool _success,) = _distribution.receivers[j].call.value(_amount)("");
                    require(_success, "Reverted ETH transfer");
                }
                emit Distributed(_distribution.receivers[j], _distribution.percentages[j], _amount);
            } else {
                uint256 _amountToBurn = _amount;
                
                if (_tokenAddress != tokenToBurn) {
                    (bool _success, bytes memory _result) = address(exchangeAdapter).delegatecall(
                        abi.encodeWithSelector(
                            exchangeAdapter.exchange.selector,
                            _tokenAddress,
                            tokenToBurn,
                            _amount,
                            10
                        )
                    );
                    require(_success, "ERROR_ON_EXCHANGE");
                    _amountToBurn = abi.decode(_result, (uint256));
                }
                internalBurn(_amountToBurn);
            }
        }
    }

    
    
    function internalBurn(uint256 _amount) internal {
        require(IERC20(tokenToBurn).transfer(recipientBurn, _amount), "INTERNAL_BURN. Reverted transfer to recipientBurn address");
        emit Burn(_amount);
    }

    
    
    function getDistribution() public view returns(address[] memory receivers, uint256[] memory percentages) {
        receivers = distribution.receivers;
        percentages = distribution.percentages;
    }

    
    
    function getRevision() internal pure returns (uint256) {
        return IMPLEMENTATION_REVISION;
    }

}