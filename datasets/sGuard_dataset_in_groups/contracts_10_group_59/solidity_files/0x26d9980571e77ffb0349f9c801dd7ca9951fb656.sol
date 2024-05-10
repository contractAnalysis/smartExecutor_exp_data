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

contract CurveExchangeAdapter {
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
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
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
        require(sender == msg.sender);
        bytes32 pHash = keccak256(encoded);
        uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(pHash, _amount, _nHash, _sig);
        require(RENBTC.transfer(msg.sender, mintedAmount));
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
        
        bytes32 pHash = keccak256(abi.encode(_minExchangeRate, _slippage, _wbtcDestination, msg.sender));
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
        
        bytes32 pHash = keccak256(abi.encode(_wbtcDestination, _amounts, _min_mint_amount, msg.sender));
        
        uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(pHash, _amount, _nHash, _sig);

        
        uint256[2] memory receivedAmounts = _amounts;
        receivedAmounts[0] = mintedAmount;
        uint256 calc_token_amount = exchange.calc_token_amount(_amounts, true);
        if(calc_token_amount >= _new_min_mint_amount) {
            require(WBTC.transferFrom(msg.sender, address(this), receivedAmounts[1]));
            uint256 curveBalanceBefore = curveToken.balanceOf(address(this));
            exchange.add_liquidity(receivedAmounts, 0);
            uint256 curveBalanceAfter = curveToken.balanceOf(address(this));
            uint256 curveAmount = curveBalanceAfter.sub(curveBalanceBefore);
            require(curveAmount >= _new_min_mint_amount);
            require(curveToken.transfer(msg.sender, curveAmount));
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
        bytes32 pHash = keccak256(abi.encode(_minExchangeRate, _slippage, _wbtcDestination, msg.sender));
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
         
        bytes32 pHash = keccak256(abi.encode(_wbtcDestination, _amounts, _min_mint_amount, msg.sender));
        
        uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(pHash, _amount, _nHash, _sig);

        require(RENBTC.transfer(_wbtcDestination, mintedAmount));
        emit ReceiveRen(mintedAmount);
    }

    function removeLiquidityThenBurn(bytes calldata _btcDestination, uint256 amount, uint256[2] calldata min_amounts) external discountCHI {
        uint256 startRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 startWbtcBalance = WBTC.balanceOf(address(this));
        require(curveToken.transferFrom(msg.sender, address(this), amount));
        exchange.remove_liquidity(amount, min_amounts);
        uint256 endRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 endWbtcBalance = WBTC.balanceOf(address(this));
        uint256 wbtcWithdrawn = endWbtcBalance.sub(startWbtcBalance);
        require(WBTC.transfer(msg.sender, wbtcWithdrawn));
        uint256 renbtcWithdrawn = endRenbtcBalance.sub(startRenbtcBalance);

        
        uint256 burnAmount = registry.getGatewayBySymbol("BTC").burn(_btcDestination, renbtcWithdrawn);
        emit Burn(burnAmount);
    }

    function removeLiquidityImbalanceThenBurn(bytes calldata _btcDestination, uint256[2] calldata amounts, uint256 max_burn_amount) external discountCHI {
        uint256 startRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 startWbtcBalance = WBTC.balanceOf(address(this));
        uint256 _tokens = curveToken.balanceOf(msg.sender);
        if(_tokens > max_burn_amount) { 
            _tokens = max_burn_amount;
        }
        require(curveToken.transferFrom(msg.sender, address(this), _tokens));
        exchange.remove_liquidity_imbalance(amounts, max_burn_amount.mul(101).div(100));
        _tokens = curveToken.balanceOf(address(this));
        require(curveToken.transfer(msg.sender, _tokens));
        uint256 endRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 endWbtcBalance = WBTC.balanceOf(address(this));
        uint256 renbtcWithdrawn = endRenbtcBalance.sub(startRenbtcBalance);
        uint256 wbtcWithdrawn = endWbtcBalance.sub(startWbtcBalance);
        require(WBTC.transfer(msg.sender, wbtcWithdrawn));

        
        uint256 burnAmount = registry.getGatewayBySymbol("BTC").burn(_btcDestination, renbtcWithdrawn);
        emit Burn(burnAmount);
    }

    
    function removeLiquidityOneCoinThenBurn(bytes calldata _btcDestination, uint256 _token_amounts, uint256 min_amount) external discountCHI {
        uint256 startRenbtcBalance = RENBTC.balanceOf(address(this));
        require(curveToken.transferFrom(msg.sender, address(this), _token_amounts));
        exchange.remove_liquidity_one_coin(_token_amounts, 0, min_amount);
        uint256 endRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 renbtcWithdrawn = endRenbtcBalance.sub(startRenbtcBalance);

        
        uint256 burnAmount = registry.getGatewayBySymbol("BTC").burn(_btcDestination, renbtcWithdrawn);
        emit Burn(burnAmount);
    }
    
    function swapThenBurn(bytes calldata _btcDestination, uint256 _amount, uint256 _minRenbtcAmount) external discountCHI {
        require(WBTC.transferFrom(msg.sender, address(this), _amount));
        uint256 startRenbtcBalance = RENBTC.balanceOf(address(this));
        exchange.exchange(1, 0, _amount, _minRenbtcAmount);
        uint256 endRenbtcBalance = RENBTC.balanceOf(address(this));
        uint256 renbtcBought = endRenbtcBalance.sub(startRenbtcBalance);
        
        
        uint256 burnAmount = registry.getGatewayBySymbol("BTC").burn(_btcDestination, renbtcBought);
        emit Burn(burnAmount);
    }
}