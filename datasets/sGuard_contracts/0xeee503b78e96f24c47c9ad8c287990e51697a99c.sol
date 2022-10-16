pragma solidity 0.5.12;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);

  function addLiquidity(
      address tokenA,
      address tokenB,
      uint amountADesired,
      uint amountBDesired,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);
  function addLiquidityETH(
      address token,
      uint amountTokenDesired,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
  function removeLiquidity(
      address tokenA,
      address tokenB,
      uint liquidity,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline
  ) external returns (uint amountA, uint amountB);
  function removeLiquidityETH(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
  ) external returns (uint amountToken, uint amountETH);
  function removeLiquidityWithPermit(
      address tokenA,
      address tokenB,
      uint liquidity,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline,
      bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountA, uint amountB);
  function removeLiquidityETHWithPermit(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline,
      bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountToken, uint amountETH);
  function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);
  function swapTokensForExactTokens(
      uint amountOut,
      uint amountInMax,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);
  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
      external
      returns (uint[] memory amounts);
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      returns (uint[] memory amounts);
  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);

  function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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



pragma solidity 0.5.12;








interface IERC20 {
    
    function decimals() external view returns (uint256);

    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IUniswapV1Factory {
    function getExchange(address token)
        external
        view
        returns (address exchange);
}


interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}


interface Iuniswap {
    
    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256 tokens_bought);

    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_bought);

    function getTokenToEthInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256 eth_bought);

    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 eth_bought);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);

    function ethToTokenTransferInput(
        uint256 min_tokens,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256 tokens_bought);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);
}


interface IUniswapV2Pair {
    function token0() external pure returns (address);

    function token1() external pure returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

    
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    
    function skim(address to) external;
}


contract UniswapV2_ZapIn is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    bool private stopped = false;
    uint16 public goodwill;
    address public dzgoodwillAddress;

    IUniswapV2Router01 public uniswapV2Router = IUniswapV2Router01(
        0xf164fC0Ec4E93095b804a4795bBe1e041497b92a
    );

    IUniswapV1Factory public UniSwapV1FactoryAddress = IUniswapV1Factory(
        0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
    );

    IUniswapV2Factory public UniSwapV2FactoryAddress = IUniswapV2Factory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );

    constructor(uint16 _goodwill, address _dzgoodwillAddress) public {
        goodwill = _goodwill;
        dzgoodwillAddress = _dzgoodwillAddress;
    }

    
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    
    function ZapIn(
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount
    ) public payable nonReentrant stopInEmergency returns (uint256) {
        uint256 toInvest;
        if (_FromTokenContractAddress == address(0)) {
            require(msg.value > 0, "Error: ETH not sent");
            toInvest = msg.value;
        } else {
            require(msg.value == 0, "Error: ETH sent");
            require(_amount > 0, "Error: Invalid ERC amount");
            toInvest = _amount;
        }

        (uint256 LPBought, uint256 residue) = _performZapIn(
            _FromTokenContractAddress,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            toInvest
        );

        if (residue > 0) {
            (uint256 newLP, uint256 newResidue) = _performZapIn(
                address(0),
                _ToUnipoolToken0,
                _ToUnipoolToken1,
                residue
            );
            if (newResidue > 0) msg.sender.transfer(newResidue);
            LPBought += newLP;
        }
        
        address _ToUniPoolAddress = UniSwapV2FactoryAddress.getPair(
            _ToUnipoolToken0,
            _ToUnipoolToken1
        );

        
        uint256 goodwillPortion = _transferGoodwill(
            _ToUniPoolAddress,
            LPBought
        );
        require(
            IERC20(_ToUniPoolAddress).transfer(
                msg.sender,
                SafeMath.sub(LPBought, goodwillPortion)
            ),
            "Error in transferring LP"
        );
        return SafeMath.sub(LPBought, goodwillPortion);
    }

    function _performZapIn(
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount
    ) internal returns (uint256, uint256) {
        
        address _ToUniPoolAddress = UniSwapV2FactoryAddress.getPair(
            _ToUnipoolToken0,
            _ToUnipoolToken1
        );

        uint256 r0;
        uint256 r1;

        if (_ToUniPoolAddress == address(0)) {
            (r0, r1) = (1, 1);
        } else {
            (r0, r1) = _getRatio(IUniswapV2Pair(_ToUniPoolAddress));
        }

        uint256 token0Bought;
        uint256 token1Bought;
        uint256 amount;

        if (_FromTokenContractAddress == address(0)) {
            amount = SafeMath.div(
                SafeMath.mul(_amount, r0),
                SafeMath.add(r0, r1)
            );
            token0Bought = _eth2Token(_ToUnipoolToken0, amount);
            token1Bought = _eth2Token(
                _ToUnipoolToken1,
                SafeMath.sub(_amount, amount)
            );
        } else {
            require(
                IERC20(_FromTokenContractAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Error: ERC Transfer"
            );

            if (_ToUnipoolToken0 == _FromTokenContractAddress) {
                amount = SafeMath.div(
                    SafeMath.mul(_amount, r1),
                    SafeMath.add(r0, r1)
                );

                token1Bought = _token2Token(
                    _FromTokenContractAddress,
                    address(this),
                    _ToUnipoolToken1,
                    amount
                );

                token0Bought = SafeMath.sub(_amount, amount);
            } else if (_ToUnipoolToken1 == _FromTokenContractAddress) {
                amount = SafeMath.div(
                    SafeMath.mul(_amount, r0),
                    SafeMath.add(r0, r1)
                );

                token0Bought = _token2Token(
                    _FromTokenContractAddress,
                    address(this),
                    _ToUnipoolToken0,
                    amount
                );

                token1Bought = SafeMath.sub(_amount, amount);
            } else {
                amount = SafeMath.div(
                    SafeMath.mul(_amount, r0),
                    SafeMath.add(r0, r1)
                );
                token0Bought = _token2Token(
                    _FromTokenContractAddress,
                    address(this),
                    _ToUnipoolToken0,
                    amount
                );

                token1Bought = _token2Token(
                    _FromTokenContractAddress,
                    address(this),
                    _ToUnipoolToken1,
                    SafeMath.sub(_amount, amount)
                );
            }
        }
        IERC20(_ToUnipoolToken0).approve(
            address(uniswapV2Router),
            token0Bought
        );
        IERC20(_ToUnipoolToken1).approve(
            address(uniswapV2Router),
            token1Bought
        );

        (uint256 amountA, uint256 amountB, uint256 LP) = uniswapV2Router
            .addLiquidity(
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            token0Bought,
            token1Bought,
            1,
            1,
            address(this),
            now + 60
        );

        
        uint256 residueEth;

        if (SafeMath.sub(token0Bought, amountA) > 0) {
            residueEth = _token2Eth(
                _ToUnipoolToken0,
                SafeMath.sub(token0Bought, amountA),
                address(this)
            );
        }

        if (SafeMath.sub(token1Bought, amountB) > 0) {
            residueEth += _token2Eth(
                _ToUnipoolToken1,
                SafeMath.sub(token1Bought, amountB),
                address(this)
            );
        }
        if (residueEth < 0.5 ether) {
            msg.sender.transfer(residueEth);
            residueEth = 0;
        }
        return (LP, residueEth);
    }

    
    function _getRatio(IUniswapV2Pair UnipoolPair)
        internal
        view
        returns (uint256 r0, uint256 r1)
    {
        (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(UnipoolPair)
            .getReserves();

        Iuniswap token0ExchangeContractAddress = Iuniswap(
            UniSwapV1FactoryAddress.getExchange(UnipoolPair.token0())
        );

        Iuniswap token1ExchangeContractAddress = Iuniswap(
            UniSwapV1FactoryAddress.getExchange(UnipoolPair.token1())
        );

        IERC20 token0 = IERC20(UnipoolPair.token0());
        IERC20 token1 = IERC20(UnipoolPair.token1());

        uint256 token0Price = token0ExchangeContractAddress
            .getTokenToEthInputPrice(10**token0.decimals());
        uint256 token1Price = token1ExchangeContractAddress
            .getTokenToEthInputPrice(10**token1.decimals());

        uint256 EthReserve0 = SafeMath.div(
            SafeMath.mul(token0Price, _reserve0),
            10**token0.decimals()
        );

        uint256 EthReserve1 = SafeMath.div(
            SafeMath.mul(token1Price, _reserve1),
            10**token1.decimals()
        );

        if (EthReserve0 >= EthReserve1) {
            uint256 ratio = SafeMath.div(
                SafeMath.mul(EthReserve0, 100),
                EthReserve1
            );
            return (ratio, 100);
        } else {
            uint256 ratio = SafeMath.div(
                SafeMath.mul(EthReserve1, 100),
                EthReserve0
            );
            return (100, ratio);
        }
    }

    
    function _eth2Token(address _tokenContractAddress, uint256 _amount)
        internal
        returns (uint256 tokenBought)
    {
        Iuniswap FromUniSwapExchangeContractAddress = Iuniswap(
            UniSwapV1FactoryAddress.getExchange(_tokenContractAddress)
        );

        tokenBought = FromUniSwapExchangeContractAddress
            .ethToTokenSwapInput
            .value(_amount)(1, SafeMath.add(now, 300));
    }

    
    function _token2Eth(
        address _FromTokenContractAddress,
        uint256 tokens2Trade,
        address _toWhomToIssue
    ) internal returns (uint256 ethBought) {
        Iuniswap FromUniSwapExchangeContractAddress = Iuniswap(
            UniSwapV1FactoryAddress.getExchange(_FromTokenContractAddress)
        );

        IERC20(_FromTokenContractAddress).approve(
            address(FromUniSwapExchangeContractAddress),
            tokens2Trade
        );

        uint256 minEthBought = FromUniSwapExchangeContractAddress
            .getTokenToEthInputPrice(tokens2Trade);
        minEthBought = SafeMath.div(SafeMath.mul(minEthBought, 99), 100);

        ethBought = FromUniSwapExchangeContractAddress.tokenToEthTransferInput(
            tokens2Trade,
            minEthBought,
            SafeMath.add(now, 300),
            _toWhomToIssue
        );
        require(ethBought > 0, "Error in swapping Eth: 1");
    }

    
    function _token2Token(
        address _FromTokenContractAddress,
        address _ToWhomToIssue,
        address _ToTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 tokenBought) {
        Iuniswap FromUniSwapExchangeContractAddress = Iuniswap(
            UniSwapV1FactoryAddress.getExchange(_FromTokenContractAddress)
        );

        IERC20(_FromTokenContractAddress).approve(
            address(FromUniSwapExchangeContractAddress),
            tokens2Trade
        );

        tokenBought = FromUniSwapExchangeContractAddress
            .tokenToTokenTransferInput(
            tokens2Trade,
            1,
            1,
            SafeMath.add(now, 300),
            _ToWhomToIssue,
            _ToTokenContractAddress
        );
        require(tokenBought > 0, "Error in swapping ERC: 1");
    }

    
    function _transferGoodwill(
        address _tokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 goodwillPortion) {
        goodwillPortion = SafeMath.div(
            SafeMath.mul(tokens2Trade, goodwill),
            10000
        );

        if (goodwillPortion == 0) {
            return 0;
        }

        require(
            IERC20(_tokenContractAddress).transfer(
                dzgoodwillAddress,
                goodwillPortion
            ),
            "Error in transferring BPT:1"
        );
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill >= 0 && _new_goodwill < 10000,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_new_dzgoodwillAddress(address _new_dzgoodwillAddress)
        public
        onlyOwner
    {
        dzgoodwillAddress = _new_dzgoodwillAddress;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner(), qty);
    }

    
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

    
    function destruct() public onlyOwner {
        address payable _to = owner().toPayable();
        selfdestruct(_to);
    }

    function() external payable {}
}