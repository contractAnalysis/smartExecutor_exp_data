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


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}

  
pragma solidity ^0.5.0;


contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

pragma solidity ^0.5.0;


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

pragma solidity ^0.5.0;


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

pragma solidity ^0.5.0;


library Math {
    
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

pragma solidity ^0.5.0;


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

pragma solidity ^0.5.0;

contract CapperRole is Context {
    using Roles for Roles.Role;

    event CapperAdded(address indexed account);
    event CapperRemoved(address indexed account);

    Roles.Role private _cappers;

    constructor () internal {
        _addCapper(_msgSender());
    }

    modifier onlyCapper() {
        require(isCapper(_msgSender()), "CapperRole: caller does not have the Capper role");
        _;
    }

    function isCapper(address account) public view returns (bool) {
        return _cappers.has(account);
    }

    function addCapper(address account) public onlyCapper {
        _addCapper(account);
    }

    function renounceCapper() public {
        _removeCapper(_msgSender());
    }

    function _addCapper(address account) internal {
        _cappers.add(account);
        emit CapperAdded(account);
    }

    function _removeCapper(address account) internal {
        _cappers.remove(account);
        emit CapperRemoved(account);
    }
}
pragma solidity ^0.5.0;


contract Crowdsale is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    
    IERC20 private _token;

    
    address payable private _wallet;

    
    
    
    
    uint256 private _rate;

    
    uint256 private _weiRaised;

    
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    
    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

    
    function () external payable {
        buyTokens(_msgSender());
    }

    
    function token() public view returns (IERC20) {
        return _token;
    }

    
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    
    function rate() public view returns (uint256) {
        return _rate;
    }

    
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        
        uint256 tokens = _getTokenAmount(weiAmount);

        
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; 
    }

    
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        
    }

    
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        
    }

    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }

    
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}

pragma solidity ^0.5.0;



contract IndividuallyCappedCrowdsale is Crowdsale, CapperRole {
    using SafeMath for uint256;

    mapping(address => uint256) private _contributions;
    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "CappedCrowdsale: Minimum cap is 0");
        _cap = cap;
    }
    
    function getContribution(address beneficiary) public view returns (uint256) {
        return _contributions[beneficiary];
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        super._preValidatePurchase(beneficiary, weiAmount);
        
        require(_contributions[beneficiary].add(weiAmount) >= _cap, "IndividuallyCappedCrowdsale: beneficiary's min cap not reached");
    }

    
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        super._updatePurchasingState(beneficiary, weiAmount);
        _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
    }
}

pragma solidity ^0.5.0;



contract AllowanceCrowdsale is Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private _tokenWallet;

    
    constructor (address tokenWallet) public {
        require(tokenWallet != address(0), "AllowanceCrowdsale: token wallet is the zero address");
        _tokenWallet = tokenWallet;
    }

    
    function tokenWallet() public view returns (address) {
        return _tokenWallet;
    }

    
    function remainingTokens() public view returns (uint256) {
        return Math.min(token().balanceOf(_tokenWallet), token().allowance(_tokenWallet, address(this)));
    }

    
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        token().safeTransferFrom(_tokenWallet, beneficiary, tokenAmount);
    }
}

pragma solidity ^0.5.0;



contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    
    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

    
    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    
    constructor (uint256 openingTime, uint256 closingTime) public {
        
        require(openingTime >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        
        require(closingTime > openingTime, "TimedCrowdsale: opening time is not before closing time");

        _openingTime = openingTime;
        _closingTime = closingTime;
    }

    
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    
    function isOpen() public view returns (bool) {
        
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    
    function hasClosed() public view returns (bool) {
        
        return block.timestamp > _closingTime;
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    
    function _extendTime(uint256 newClosingTime) internal {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        
        require(newClosingTime > _closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }
}

pragma solidity ^0.5.0;



contract IncreasingPriceCrowdsale is TimedCrowdsale {
    using SafeMath for uint256;

    uint256 private _initialRate;
    uint256 private _finalRate;

    
    constructor (uint256 initialRate, uint256 finalRate) public {
        require(finalRate > 0, "IncreasingPriceCrowdsale: final rate is 0");
        
        require(initialRate > finalRate, "IncreasingPriceCrowdsale: initial rate is not greater than final rate");
        _initialRate = initialRate;
        _finalRate = finalRate;
    }

    
    function rate() public view returns (uint256) {
        revert("IncreasingPriceCrowdsale: rate() called");
    }

    
    function initialRate() public view returns (uint256) {
        return _initialRate;
    }

    
    function finalRate() public view returns (uint256) {
        return _finalRate;
    }

    
    function getCurrentRate() public view returns (uint256) {
        if (!isOpen()) {
            return 0;
        }

        
        uint256 elapsedTime = block.timestamp.sub(openingTime());
        uint256 timeRange = closingTime().sub(openingTime());
        uint256 rateRange = _initialRate.sub(_finalRate);
        return _initialRate.sub(elapsedTime.mul(rateRange).div(timeRange));
    }

    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        uint256 currentRate = getCurrentRate();
        return currentRate.mul(weiAmount);
    }
}

pragma solidity ^0.5.0;


contract HBDVAuction is Crowdsale, IndividuallyCappedCrowdsale, TimedCrowdsale, AllowanceCrowdsale, IncreasingPriceCrowdsale
{
constructor(
	uint256 _cap,
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _rate,
    address payable _wallet,
    address _tokenWallet,
	uint256 _initialRate,
    uint256 _finalRate,
    IERC20 _token
    )
    public
	IndividuallyCappedCrowdsale (_cap)
    AllowanceCrowdsale(_tokenWallet)
    TimedCrowdsale(_openingTime, _closingTime)
	IncreasingPriceCrowdsale (_initialRate, _finalRate)
    Crowdsale (_rate, _wallet, _token)

    {
    }
}