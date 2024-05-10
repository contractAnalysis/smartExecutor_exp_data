pragma solidity 0.5.16;



contract BytesLibLite {
    

    function sliceToEnd(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (bytes memory) {
        require(_start < _bytes.length, "bytes-read-out-of-bounds");

        return slice(
            _bytes,
            _start,
            _bytes.length - _start
        );
    }
    
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_bytes.length >= (_start + _length), "bytes-read-out-of-bounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                
                
                tempBytes := mload(0x40)

                
                
                
                
                
                
                
                
                let lengthmod := and(_length, 31)

                
                
                
                
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    
                    
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                
                
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function bytesToAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= (_start + 20), "Read out of bounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }
}



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

    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
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



pragma solidity ^0.5.5;


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



pragma solidity 0.5.16;





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



pragma solidity 0.5.16;


interface IFlashLoanReceiver {
    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params) external;
}



pragma solidity 0.5.16;



contract ILendingPoolAddressesProvider {

    function getLendingPool() public view returns (address);
    function setLendingPoolImpl(address _pool) public;

    function getLendingPoolCore() public view returns (address payable);
    function setLendingPoolCoreImpl(address _lendingPoolCore) public;

    function getLendingPoolConfigurator() public view returns (address);
    function setLendingPoolConfiguratorImpl(address _configurator) public;

    function getLendingPoolDataProvider() public view returns (address);
    function setLendingPoolDataProviderImpl(address _provider) public;

    function getLendingPoolParametersProvider() public view returns (address);
    function setLendingPoolParametersProviderImpl(address _parametersProvider) public;

    function getTokenDistributor() public view returns (address);
    function setTokenDistributor(address _tokenDistributor) public;

    function getFeeProvider() public view returns (address);
    function setFeeProviderImpl(address _feeProvider) public;

    function getLendingPoolLiquidationManager() public view returns (address);
    function setLendingPoolLiquidationManager(address _manager) public;

    function getLendingPoolManager() public view returns (address);
    function setLendingPoolManager(address _lendingPoolManager) public;

    function getPriceOracle() public view returns (address);
    function setPriceOracle(address _priceOracle) public;

    function getLendingRateOracle() public view returns (address);
    function setLendingRateOracle(address _lendingRateOracle) public;

}



pragma solidity 0.5.16;





contract FlashLoanReceiverBase is IFlashLoanReceiver {
    using SafeMath for uint256;

    address constant ETHADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    ILendingPoolAddressesProvider public addressesProvider = ILendingPoolAddressesProvider(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);

    function () external payable {    }

    function transferFundsBackToPoolInternal(address _reserve, uint256 _amount) internal {
        address payable core = addressesProvider.getLendingPoolCore();
        transferInternal(core,_reserve, _amount);
    }

    function transferInternal(address payable _destination, address _reserve, uint256  _amount) internal {
        if(_reserve == ETHADDRESS) {
            
            _destination.call.value(_amount)("");
            return;
        }

        IERC20(_reserve).transfer(_destination, _amount);
    }

    function getBalanceInternal(address _target, address _reserve) internal view returns(uint256) {
        if(_reserve == ETHADDRESS) {

            return _target.balance;
        }

        return IERC20(_reserve).balanceOf(_target);
    }
}

// File: src/lib/dapphub/Auth.sol

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.5.16;

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (address(authority) == address(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}


















pragma solidity 0.5.16;

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint256           wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);

        _;
    }
}




















pragma solidity >=0.5.0 <0.6.0;








contract DSProxy is DSAuth, DSNote {
    DSProxyCache public cache;  

    constructor(address _cacheAddr) public {
        setCache(_cacheAddr);
    }

    function() external payable {
    }

    
    function execute(bytes memory _code, bytes memory _data)
        public
        payable
        returns (address target, bytes memory response)
    {
        target = cache.read(_code);
        if (target == address(0)) {
            
            target = cache.write(_code);
        }

        response = execute(target, _data);
    }

    function execute(address _target, bytes memory _data)
        public
        auth
        note
        payable
        returns (bytes memory response)
    {
        require(_target != address(0), "ds-proxy-target-address-required");

        
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), _target, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                
                revert(add(response, 0x20), size)
            }
        }
    }

    
    function setCache(address _cacheAddr)
        public
        auth
        note
        returns (bool)
    {
        require(_cacheAddr != address(0), "ds-proxy-cache-address-required");
        cache = DSProxyCache(_cacheAddr);  
        return true;
    }
}




contract DSProxyFactory {
    event Created(address indexed sender, address indexed owner, address proxy, address cache);
    mapping(address=>address) public proxies;
    DSProxyCache public cache;

    constructor() public {
        cache = new DSProxyCache();
    }

    
    
    function build() public returns (address payable proxy) {
        proxy = build(msg.sender);
    }

    
    
    function build(address owner) public returns (address payable proxy) {
        proxy = address(new DSProxy(address(cache)));
        emit Created(msg.sender, owner, address(proxy), address(cache));
        DSProxy(proxy).setOwner(owner);
        proxies[owner] = proxy;
    }
}










contract DSProxyCache {
    mapping(bytes32 => address) cache;

    function read(bytes memory _code) public view returns (address) {
        bytes32 hash = keccak256(_code);
        return cache[hash];
    }

    function write(bytes memory _code) public returns (address target) {
        assembly {
            target := create(0, add(_code, 0x20), mload(_code))
            switch iszero(extcodesize(target))
            case 1 {
                
                revert(0, 0)
            }
        }
        bytes32 hash = keccak256(_code);
        cache[hash] = target;
    }
}





pragma solidity 0.5.16;





contract DACProxy is
    DSProxy(address(1)),
    FlashLoanReceiverBase,
    BytesLibLite
{
    
    address payable constant protocolFeePayoutAddress1 = 0x773CCbFB422850617A5680D40B1260422d072f41;
    address payable constant protocolFeePayoutAddress2 = 0xAbcCB8f0a3c206Bb0468C52CCc20f3b81077417B;

    constructor(address _cacheAddr) public {
        setCache(_cacheAddr);
    }

    function() external payable {}

    
    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    ) external
        auth
    {
        
        
        
        uint protocolFee = _fee.div(2);

        
        
        
        address targetAddress = bytesToAddress(_params, 12);
        bytes memory fSig     = slice(_params, 32, 4);
        bytes memory data     = sliceToEnd(_params, 132);

        
        
        bytes memory newData = abi.encodePacked(
            fSig,
            abi.encode(_amount),
            abi.encode(_fee),
            abi.encode(protocolFee),
            data
        );

        
        execute(targetAddress, newData);

        
        if (_reserve == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            protocolFeePayoutAddress1.call.value(protocolFee.div(2))("");
            protocolFeePayoutAddress2.call.value(protocolFee.div(2))("");
        } else {
            IERC20(_reserve).transfer(protocolFeePayoutAddress1, protocolFee.div(2));
            IERC20(_reserve).transfer(protocolFeePayoutAddress2, protocolFee.div(2));
        }

        
        transferFundsBackToPoolInternal(_reserve, _amount.add(_fee));
    }
}




















pragma solidity 0.5.16;


contract DSGuardEvents {
    event LogPermit(
        bytes32 indexed src,
        bytes32 indexed dst,
        bytes32 indexed sig
    );

    event LogForbid(
        bytes32 indexed src,
        bytes32 indexed dst,
        bytes32 indexed sig
    );
}

contract DSGuard is DSAuth, DSAuthority, DSGuardEvents {
    bytes32 constant public ANY = bytes32(uint(-1));

    mapping (bytes32 => mapping (bytes32 => mapping (bytes32 => bool))) acl;

    function canCall(
        address src_, address dst_, bytes4 sig
    ) public view returns (bool) {
        bytes32 src = bytes32(bytes20(src_));
        bytes32 dst = bytes32(bytes20(dst_));

        return acl[src][dst][sig]
            || acl[src][dst][ANY]
            || acl[src][ANY][sig]
            || acl[src][ANY][ANY]
            || acl[ANY][dst][sig]
            || acl[ANY][dst][ANY]
            || acl[ANY][ANY][sig]
            || acl[ANY][ANY][ANY];
    }

    function permit(bytes32 src, bytes32 dst, bytes32 sig) public auth {
        acl[src][dst][sig] = true;
        emit LogPermit(src, dst, sig);
    }

    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public auth {
        acl[src][dst][sig] = false;
        emit LogForbid(src, dst, sig);
    }

    function permit(address src, address dst, bytes32 sig) public {
        permit(bytes32(bytes20(src)), bytes32(bytes20(dst)), sig);
    }
    function forbid(address src, address dst, bytes32 sig) public {
        forbid(bytes32(bytes20(src)), bytes32(bytes20(dst)), sig);
    }

}

contract DSGuardFactory {
    mapping (address => bool)  public  isGuard;

    function newGuard() public returns (DSGuard guard) {
        guard = new DSGuard();
        guard.setOwner(msg.sender);
        isGuard[address(guard)] = true;
    }
}



pragma solidity 0.5.16;

interface IComptroller {
    
    function isComptroller() external view returns (bool);

    

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    function exitMarket(address cToken) external returns (uint);

    

    function getAccountLiquidity(address account) external view returns (uint, uint, uint);
    function getAssetsIn(address account) external view returns (address[] memory);

    function mintAllowed(address cToken, address minter, uint mintAmount) external returns (uint);
    function mintVerify(address cToken, address minter, uint mintAmount, uint mintTokens) external;

    function redeemAllowed(address cToken, address redeemer, uint redeemTokens) external returns (uint);
    function redeemVerify(address cToken, address redeemer, uint redeemAmount, uint redeemTokens) external;

    function borrowAllowed(address cToken, address borrower, uint borrowAmount) external returns (uint);
    function borrowVerify(address cToken, address borrower, uint borrowAmount) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);
    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);
    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);
    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;

    function transferAllowed(address cToken, address src, address dst, uint transferTokens) external returns (uint);
    function transferVerify(address cToken, address src, address dst, uint transferTokens) external;

    

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}



pragma solidity 0.5.16;




contract DACProxyFactory {
    event Created(address indexed sender, address indexed owner, address proxy, address cache);

    mapping(address=>address) public proxies;

    DSProxyCache public cache;
    DSGuardFactory public dsGuardFactory;

    constructor() public {
        cache = new DSProxyCache();
        dsGuardFactory = new DSGuardFactory();
    }

    
    
    function build() public returns (address payable proxy) {
        proxy = build(msg.sender);
    }

    
    
    
    function build(address owner) public returns (address payable) {
        
        if (proxies[owner] != address(0)) {
            return address(uint160(proxies[owner]));
        }

        address payable proxy = address(new DACProxy(address(cache)));
        emit Created(msg.sender, owner, address(proxy), address(cache));

        DSGuard guard = dsGuardFactory.newGuard();
        guard.setOwner(proxy);  

        DACProxy(proxy).setAuthority(guard);
        DACProxy(proxy).setOwner(owner);

        proxies[owner] = proxy;

        return proxy;
    }

    
    
    function buildAndEnterMarkets(
        address dedgeCompoundManager,
        bytes memory enterMarketCalldata
    ) public returns (address payable) {
        return buildAndEnterMarkets(msg.sender, dedgeCompoundManager, enterMarketCalldata);
    }

    function buildAndEnterMarkets(
        address owner,
        address dedgeCompoundManager,
        bytes memory enterMarketCalldata
    ) public returns (address payable) {
        
        if (proxies[owner] != address(0)) {
            return address(uint160(proxies[owner]));
        }

        address payable proxy = address(new DACProxy(address(cache)));
        emit Created(msg.sender, owner, address(proxy), address(cache));

        DSGuard guard = dsGuardFactory.newGuard();
        guard.setOwner(proxy);  

        
        DACProxy(proxy).execute(
            dedgeCompoundManager,
            enterMarketCalldata
        );

        DACProxy(proxy).setAuthority(guard);
        DACProxy(proxy).setOwner(owner);

        proxies[owner] = proxy;

        return proxy;
    }
}