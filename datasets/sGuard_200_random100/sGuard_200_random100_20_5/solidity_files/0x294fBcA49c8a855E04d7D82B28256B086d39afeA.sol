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


contract Config {
    
    bytes4 constant POSTPROCESS_SIG = 0xc2722916;

    
    enum HandlerType {Token, Custom, Others}
}



pragma solidity ^0.5.0;


library LibCache {
    function setAddress(bytes32[] storage _cache, address _input) internal {
        _cache.push(bytes32(uint256(uint160(_input))));
    }

    function set(bytes32[] storage _cache, bytes32 _input) internal {
        _cache.push(_input);
    }

    function setHandlerType(bytes32[] storage _cache, uint256 _input) internal {
        require(_input < uint96(-1), "Invalid Handler Type");
        _cache.push(bytes12(uint96(_input)));
    }

    function setSender(bytes32[] storage _cache, address _input) internal {
        require(_cache.length == 0, "cache not empty");
        setAddress(_cache, _input);
    }

    function getAddress(bytes32[] storage _cache)
        internal
        returns (address ret)
    {
        ret = address(uint160(uint256(peek(_cache))));
        _cache.pop();
    }

    function getSig(bytes32[] storage _cache) internal returns (bytes4 ret) {
        ret = bytes4(peek(_cache));
        _cache.pop();
    }

    function get(bytes32[] storage _cache) internal returns (bytes32 ret) {
        ret = peek(_cache);
        _cache.pop();
    }

    function peek(bytes32[] storage _cache)
        internal
        view
        returns (bytes32 ret)
    {
        require(_cache.length > 0, "cache empty");
        ret = _cache[_cache.length - 1];
    }

    function getSender(bytes32[] storage _cache)
        internal
        returns (address ret)
    {
        require(_cache.length > 0, "cache empty");
        ret = address(uint160(uint256(_cache[0])));
    }
}



pragma solidity ^0.5.0;




contract Cache {
    using LibCache for bytes32[];

    bytes32[] cache;

    modifier isCacheEmpty() {
        require(cache.length == 0, "Cache not empty");
        _;
    }
}



pragma solidity ^0.5.0;




contract HandlerBase is Cache, Config {
    function postProcess() external payable {
        revert("Invalid post process");
        
    }

    function _updateToken(address token) internal {
        cache.setAddress(token);
        
        
    }

    function _updatePostProcess(bytes32[] memory params) internal {
        for (uint256 i = params.length; i > 0; i--) {
            cache.set(params[i - 1]);
        }
        cache.set(msg.sig);
        cache.setHandlerType(uint256(HandlerType.Custom));
    }
}



pragma solidity ^0.5.0;

interface IMakerManager {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint);
    function give(uint, address) external;
    function cdpAllow(uint, address, uint) external;
    function urnAllow(address, uint) external;
    function frob(uint, int, int) external;
    function flux(uint, address, uint) external;
    function move(uint, address, uint) external;
    function exit(address, uint, address, uint) external;
    function quit(uint, address) external;
    function enter(address, uint) external;
    function shift(uint, uint) external;

    function count(address) external view returns (uint256);
    function first(address) external view returns (uint256);
    function last(address) external view returns (uint256);
}

interface IMakerVat {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);
    function frob(bytes32, address, address, address, int, int) external;
    function hope(address) external;
    function move(address, address, uint) external;
}

interface IMakerGemJoin {
    function dec() external returns (uint);
    function gem() external returns (address);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}



pragma solidity ^0.5.0;

interface IDSProxy {
    function execute(address _target, bytes calldata _data) external payable returns (bytes32 response);
}

interface IDSProxyFactory {
    function isProxy(address proxy) external view returns (bool);
    function build() external returns (address);
    function build(address owner) external returns (address);
}

interface IDSProxyRegistry {
    function proxies(address input) external returns (address);
    function build() external returns (address);
    function build(address owner) external returns (address);
}



pragma solidity ^0.5.0;






contract HMaker is HandlerBase {
    using SafeERC20 for IERC20;

    address constant PROXY_ACTIONS = 0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038;
    address constant CDP_MANAGER = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address constant PROXY_REGISTRY = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;
    address constant MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant DAI_TOKEN = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    modifier cdpAllowed(uint256 cdp) {
        IMakerManager manager = IMakerManager(CDP_MANAGER);
        address owner = manager.owns(cdp);
        address sender = cache.getSender();
        require(
            IDSProxyRegistry(PROXY_REGISTRY).proxies(sender) == owner ||
                manager.cdpCan(owner, cdp, sender) == 1,
            "Unauthorized sender of cdp"
        );
        _;
    }

    function openLockETHAndDraw(
        uint256 value,
        address ethJoin,
        address daiJoin,
        bytes32 ilk,
        uint256 wadD
    ) external payable returns (uint256 cdp) {
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        cdp = uint256(
            proxy.execute.value(value)(
                PROXY_ACTIONS,
                abi.encodeWithSelector(
                    
                    0xe685cc04,
                    CDP_MANAGER,
                    MCD_JUG,
                    ethJoin,
                    daiJoin,
                    ilk,
                    wadD
                )
            )
        );

        
        bytes32[] memory params = new bytes32[](1);
        params[0] = bytes32(cdp);
        _updatePostProcess(params);
    }

    function openLockGemAndDraw(
        address gemJoin,
        address daiJoin,
        bytes32 ilk,
        uint256 wadC,
        uint256 wadD
    ) external payable returns (uint256 cdp) {
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        address token = IMakerGemJoin(gemJoin).gem();
        IERC20(token).safeApprove(address(proxy), wadC);
        cdp = uint256(
            proxy.execute(
                PROXY_ACTIONS,
                abi.encodeWithSelector(
                    
                    0xdb802a32,
                    CDP_MANAGER,
                    MCD_JUG,
                    gemJoin,
                    daiJoin,
                    ilk,
                    wadC,
                    wadD,
                    true
                )
            )
        );
        IERC20(token).safeApprove(address(proxy), 0);

        
        bytes32[] memory params = new bytes32[](1);
        params[0] = bytes32(cdp);
        _updatePostProcess(params);
    }

    function safeLockETH(
        uint256 value,
        address ethJoin,
        uint256 cdp
    ) external payable {
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        address owner = _getProxy(cache.getSender());
        proxy.execute.value(value)(
            PROXY_ACTIONS,
            abi.encodeWithSelector(
                
                0xee284576,
                CDP_MANAGER,
                ethJoin,
                cdp,
                owner
            )
        );
    }

    function safeLockGem(
        address gemJoin,
        uint256 cdp,
        uint256 wad
    ) external payable {
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        address owner = _getProxy(cache.getSender());
        address token = IMakerGemJoin(gemJoin).gem();
        IERC20(token).safeApprove(address(proxy), wad);
        proxy.execute(
            PROXY_ACTIONS,
            abi.encodeWithSelector(
                
                0xead64729,
                CDP_MANAGER,
                gemJoin,
                cdp,
                wad,
                true,
                owner
            )
        );
        IERC20(token).safeApprove(address(proxy), 0);
    }

    function freeETH(
        address ethJoin,
        uint256 cdp,
        uint256 wad
    ) external payable cdpAllowed(cdp) {
        
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        proxy.execute(
            PROXY_ACTIONS,
            abi.encodeWithSelector(
                
                0x7b5a3b43,
                CDP_MANAGER,
                ethJoin,
                cdp,
                wad
            )
        );
    }

    function freeGem(
        address gemJoin,
        uint256 cdp,
        uint256 wad
    ) external payable cdpAllowed(cdp) {
        
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        address token = IMakerGemJoin(gemJoin).gem();
        proxy.execute(
            PROXY_ACTIONS,
            abi.encodeWithSelector(
                
                0x6ab6a491,
                CDP_MANAGER,
                gemJoin,
                cdp,
                wad
            )
        );

        
        _updateToken(token);
    }

    function draw(
        address daiJoin,
        uint256 cdp,
        uint256 wad
    ) external payable cdpAllowed(cdp) {
        
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        proxy.execute(
            PROXY_ACTIONS,
            abi.encodeWithSelector(
                
                0x9f6f3d5b,
                CDP_MANAGER,
                MCD_JUG,
                daiJoin,
                cdp,
                wad
            )
        );

        
        _updateToken(DAI_TOKEN);
    }

    function wipe(
        address daiJoin,
        uint256 cdp,
        uint256 wad
    ) external payable {
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        IERC20(DAI_TOKEN).safeApprove(address(proxy), wad);
        proxy.execute(
            PROXY_ACTIONS,
            abi.encodeWithSelector(
                
                0x4b666199,
                CDP_MANAGER,
                daiJoin,
                cdp,
                wad
            )
        );
        IERC20(DAI_TOKEN).safeApprove(address(proxy), 0);
    }

    function wipeAll(address daiJoin, uint256 cdp) external payable {
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        IERC20(DAI_TOKEN).safeApprove(address(proxy), uint256(-1));
        proxy.execute(
            PROXY_ACTIONS,
            abi.encodeWithSelector(
                
                0x036a2395,
                CDP_MANAGER,
                daiJoin,
                cdp
            )
        );
        IERC20(DAI_TOKEN).safeApprove(address(proxy), 0);
    }

    function postProcess() external payable {
        bytes4 sig = cache.getSig();
        
        
        if (sig == 0x5481e4a4 || sig == 0x73af24e7) {
            _transferCdp(uint256(cache.get()));
            uint256 amount = IERC20(DAI_TOKEN).balanceOf(address(this));
            if (amount > 0)
                IERC20(DAI_TOKEN).safeTransfer(cache.getSender(), amount);
        } else revert("Invalid post process");
    }

    function _getProxy(address user) internal returns (address) {
        return IDSProxyRegistry(PROXY_REGISTRY).proxies(user);
    }

    function _transferCdp(uint256 cdp) internal {
        IDSProxy proxy = IDSProxy(_getProxy(address(this)));
        proxy.execute(
            PROXY_ACTIONS,
            abi.encodeWithSelector(
                
                0x493c2049,
                PROXY_REGISTRY,
                CDP_MANAGER,
                cdp,
                cache.getSender()
            )
        );
    }
}