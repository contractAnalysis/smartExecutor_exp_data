pragma solidity ^0.6.0;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a); 
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a); 
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b); 
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0); 
        c = a / b;
    }
}

pragma experimental ABIEncoderV2;

contract BasicMetaTransaction {

    using SafeMath for uint256;

    event MetaTransactionExecuted(address userAddress, address payable relayerAddress, bytes functionSignature);
    mapping(address => uint256) nonces;
    
    function getChainID() public pure returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    
    function executeMetaTransaction(address userAddress,
        bytes memory functionSignature, string memory message, string memory length,
        bytes32 sigR, bytes32 sigS, uint8 sigV) public payable returns(bytes memory) {

        require(verify(userAddress, message, length, nonces[userAddress], getChainID(), sigR, sigS, sigV), "Signer and signature do not match");
        
        (bool success, bytes memory returnData) = address(this).call(abi.encodePacked(functionSignature, userAddress));

        require(success, "Function call not successfull");
        nonces[userAddress] = nonces[userAddress].add(1);
        emit MetaTransactionExecuted(userAddress, msg.sender, functionSignature);
        return returnData;
    }

    function getNonce(address user) public view returns(uint256 nonce) {
        nonce = nonces[user];
    }



    function verify(address owner, string memory message, string memory length, uint256 nonce, uint256 chainID,
        bytes32 sigR, bytes32 sigS, uint8 sigV) public pure returns (bool) {

        string memory nonceStr = uint2str(nonce);
        string memory chainIDStr = uint2str(chainID);
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", length, message, nonceStr, chainIDStr));
		return (owner == ecrecover(hash, sigV, sigR, sigS));
    }

    
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        uint256 temp = _i;
        while (temp != 0) {
            bstr[k--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(bstr);
    }

    function msgSender() internal view returns(address sender) {
        if(msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                
                sender := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }

    
    receive() external payable { }
    fallback() external payable { }
}






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

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256 balance);
}

interface IGateway {
    function mint(bytes32 _pHash, uint256 _amount, bytes32 _nHash, bytes calldata _sig) external returns (uint256);
    function burn(bytes calldata _to, uint256 _amount) external returns (uint256);
}

interface IGatewayRegistry {
    function getGatewayBySymbol(string calldata _tokenSymbol) external view returns (IGateway);
    function getGatewayByToken(address  _tokenAddress) external view returns (IGateway);
    function getTokenBySymbol(string calldata _tokenSymbol) external view returns (IERC20);
}

interface ICurveExchange {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;

    function get_dy(int128, int128 j, uint256 dx) external view returns (uint256);

    function calc_token_amount(uint256[2] calldata amounts, bool deposit) external returns (uint256 amount);

    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount) external;

    function remove_liquidity(
        uint256 _amount,
        uint256[2] calldata min_amounts
    ) external;

    function remove_liquidity_imbalance(uint256[2] calldata amounts, uint256 max_burn_amount) external;

    function remove_liquidity_one_coin(uint256 _token_amounts, int128 i, uint256 min_amount) external;
}

interface IFreeFromUpTo {
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract CurveExchangeAdapter is BasicMetaTransaction {
    using SafeMath for uint256;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 *
                           msg.data.length;
        if(chi.balanceOf(address(this)) > 0) {
            chi.freeFromUpTo(address(this), (gasSpent + 14154) / 41947);
        }
        else {
            chi.freeFromUpTo(msgSender(), (gasSpent + 14154) / 41947);
        }
    }

    
    IERC20 RENBTC;
    IERC20 WBTC;
    IERC20 curveToken;

    ICurveExchange public exchange;  
    IGatewayRegistry public registry;

    event SwapReceived(uint256 mintedAmount, uint256 wbtcAmount);
    event DepositMintedCurve(uint256 mintedAmount, uint256 curveAmount);
    event ReceiveRen(uint256 renAmount);
    event Burn(uint256 burnAmount);

    constructor(ICurveExchange _exchange, IGatewayRegistry _registry, IERC20 _wbtc) public {
        exchange = _exchange;
        registry = _registry;
        RENBTC = registry.getTokenBySymbol("BTC");
        WBTC = _wbtc;
        address curveTokenAddress = 0x49849C98ae39Fff122806C06791Fa73784FB3675;
        curveToken = IERC20(curveTokenAddress);
        
        
        require(RENBTC.approve(address(exchange), uint256(-1)));
        require(WBTC.approve(address(exchange), uint256(-1)));
        require(chi.approve(address(this), uint256(-1)));
    }

    function recoverStuck(
        bytes calldata encoded,
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) external {
        uint256 start = encoded.length - 32;
        address sender = abi.decode(encoded[start:], (address));
        require(sender == msgSender());
        bytes32 pHash = keccak256(encoded);
        uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(pHash, _amount, _nHash, _sig);
        require(RENBTC.transfer(msgSender(), mintedAmount));
    }
    
    function mintThenSwap(
        uint256 _minExchangeRate,
        uint256 _newMinExchangeRate,
        uint256 _slippage,
        address payable _wbtcDestination,
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) external discountCHI {
        
        bytes32 pHash = keccak256(abi.encode(_minExchangeRate, _slippage, _wbtcDestination, msgSender()));
        uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(pHash, _amount, _nHash, _sig);
        
        
        uint256 dy = exchange.get_dy(0, 1, mintedAmount);
        uint256 rate = dy.mul(1e8).div(mintedAmount);
        _slippage = uint256(1e4).sub(_slippage);
        uint256 min_dy = dy.mul(_slippage).div(1e4);
        
        
        if (rate >= _newMinExchangeRate) {
            uint256 startWbtcBalance = WBTC.balanceOf(address(this));
            exchange.exchange(0, 1, mintedAmount, min_dy);

            uint256 endWbtcBalance = WBTC.balanceOf(address(this));
            uint256 wbtcBought = endWbtcBalance.sub(startWbtcBalance);
        
            
            require(WBTC.transfer(_wbtcDestination, wbtcBought));
            emit SwapReceived(mintedAmount, wbtcBought);
        } else {
            
            require(RENBTC.transfer(_wbtcDestination, mintedAmount));
            emit ReceiveRen(mintedAmount);
        }
    }

    function mintThenDeposit(
        address payable _wbtcDestination, 
        uint256 _amount, 
        uint256[2] calldata _amounts, 
        uint256 _min_mint_amount, 
        uint256 _new_min_mint_amount, 
        bytes32 _nHash, 
        bytes calldata _sig
    ) external discountCHI {
        
        bytes32 pHash = keccak256(abi.encode(_wbtcDestination, _amounts, _min_mint_amount, msgSender()));
        
        uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(pHash, _amount, _nHash, _sig);

        
        uint256[2] memory receivedAmounts = _amounts;
        receivedAmounts[0] = mintedAmount;
        uint256 calc_token_amount = exchange.calc_token_amount(_amounts, true);
        if(calc_token_amount >= _new_min_mint_amount) {
            require(WBTC.transferFrom(msgSender(), address(this), receivedAmounts[1]));
            uint256 curveBalanceBefore = curveToken.balanceOf(address(this));
            exchange.add_liquidity(receivedAmounts, 0);
            uint256 curveBalanceAfter = curveToken.balanceOf(address(this));
            uint256 curveAmount = curveBalanceAfter.sub(curveBalanceBefore);
            require(curveAmount >= _new_min_mint_amount);
            require(curveToken.transfer(msgSender(), curveAmount));
            emit DepositMintedCurve(mintedAmount, curveAmount);
        }
        else {
            require(RENBTC.transfer(_wbtcDestination, mintedAmount));
            emit ReceiveRen(mintedAmount);
        }
    }

    function mintNoSwap(
        uint256 _minExchangeRate,
        uint256 _newMinExchangeRate,
        uint256 _slippage,
        address payable _wbtcDestination,
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) external discountCHI {
        bytes32 pHash = keccak256(abi.encode(_minExchangeRate, _slippage, _wbtcDestination, msgSender()));
        uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(pHash, _amount, _nHash, _sig);
        
        require(RENBTC.transfer(_wbtcDestination, mintedAmount));
        emit ReceiveRen(mintedAmount);
    }

    function mintNoDeposit(
        address payable _wbtcDestination, 
        uint256 _amount, 
        uint256[2] calldata _amounts, 
        uint256 _min_mint_amount, 
        uint256 _new_min_mint_amount, 
        bytes32 _nHash, 
        bytes calldata _sig
    ) external discountCHI {
         
        bytes32 pHash = keccak256(abi.encode(_wbtcDestination, _amounts, _min_mint_amount, msgSender()));
        
        uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(pHash, _amount, _nHash, _sig);

        require(RENBTC.transfer(_wbtcDestination, mintedAmount));
        emit ReceiveRen(mintedAmount);
    }

    function removeLiquidityThenBurn(bytes calldata _btcDestination, uint256 amount, uint256[2] calldata min_amounts) external discountCHI {
        uint256 startRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 startWbtcBalance = WBTC.balanceOf(address(this));
        require(curveToken.transferFrom(msgSender(), address(this), amount));
        exchange.remove_liquidity(amount, min_amounts);
        uint256 endRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 endWbtcBalance = WBTC.balanceOf(address(this));
        uint256 wbtcWithdrawn = endWbtcBalance.sub(startWbtcBalance);
        require(WBTC.transfer(msgSender(), wbtcWithdrawn));
        uint256 renbtcWithdrawn = endRenbtcBalance.sub(startRenbtcBalance);

        
        uint256 burnAmount = registry.getGatewayBySymbol("BTC").burn(_btcDestination, renbtcWithdrawn);
        emit Burn(burnAmount);
    }

    function removeLiquidityImbalanceThenBurn(bytes calldata _btcDestination, uint256[2] calldata amounts, uint256 max_burn_amount) external discountCHI {
        uint256 startRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 startWbtcBalance = WBTC.balanceOf(address(this));
        uint256 _tokens = curveToken.balanceOf(msgSender());
        if(_tokens > max_burn_amount) { 
            _tokens = max_burn_amount;
        }
        require(curveToken.transferFrom(msgSender(), address(this), _tokens));
        exchange.remove_liquidity_imbalance(amounts, max_burn_amount.mul(101).div(100));
        _tokens = curveToken.balanceOf(address(this));
        require(curveToken.transfer(msgSender(), _tokens));
        uint256 endRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 endWbtcBalance = WBTC.balanceOf(address(this));
        uint256 renbtcWithdrawn = endRenbtcBalance.sub(startRenbtcBalance);
        uint256 wbtcWithdrawn = endWbtcBalance.sub(startWbtcBalance);
        require(WBTC.transfer(msgSender(), wbtcWithdrawn));

        
        uint256 burnAmount = registry.getGatewayBySymbol("BTC").burn(_btcDestination, renbtcWithdrawn);
        emit Burn(burnAmount);
    }

    
    function removeLiquidityOneCoinThenBurn(bytes calldata _btcDestination, uint256 _token_amounts, uint256 min_amount) external discountCHI {
        uint256 startRenbtcBalance = RENBTC.balanceOf(address(this));
        require(curveToken.transferFrom(msgSender(), address(this), _token_amounts));
        exchange.remove_liquidity_one_coin(_token_amounts, 0, min_amount);
        uint256 endRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 renbtcWithdrawn = endRenbtcBalance.sub(startRenbtcBalance);

        
        uint256 burnAmount = registry.getGatewayBySymbol("BTC").burn(_btcDestination, renbtcWithdrawn);
        emit Burn(burnAmount);
    }
    
    function swapThenBurn(bytes calldata _btcDestination, uint256 _amount, uint256 _minRenbtcAmount) external discountCHI {
        require(WBTC.transferFrom(msgSender(), address(this), _amount));
        uint256 startRenbtcBalance = RENBTC.balanceOf(address(this));
        exchange.exchange(1, 0, _amount, _minRenbtcAmount);
        uint256 endRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 renbtcBought = endRenbtcBalance.sub(startRenbtcBalance);
        
        
        uint256 burnAmount = registry.getGatewayBySymbol("BTC").burn(_btcDestination, renbtcBought);
        emit Burn(burnAmount);
    }
}