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



pragma solidity >=0.4.24 <0.7.0;



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
    
    
    
    
    
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}



pragma solidity ^0.5.0;



interface IuniswapFactory_ERC20toUniPoolZapV1 {
    function getExchange(address token)
        external
        view
        returns (address exchange);
}

interface IuniswapExchange_ERC20toUniPoolZapV1 {
    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256 tokens_bought);
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    ) external returns (uint256 eth_bought);
    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 eth_bought);
    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_bought);
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 deadline
    ) external payable returns (uint256);

}

contract Ownable {
    address payable public owner = 0x19627796b318E27C333530aD67c464Cfc37596ec;

    modifier onlyOwner() {
        require(isOwner(), "you are not authorised to call this function");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address payable newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        owner = newOwner;
    }

}

contract ERC20toUniPoolZapV1_General is Initializable, Ownable {
    using SafeMath for uint256;

    

    
    bool private stopped = false;

    IuniswapFactory_ERC20toUniPoolZapV1 public UniSwapFactoryAddress = IuniswapFactory_ERC20toUniPoolZapV1(
        0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
    );

    mapping(address => uint256) private userBalance;

    
    event details(
        address indexed user,
        address toWhomIssued,
        address indexed IncomingTokenAddress,
        address indexed UniPoolUnderlyingTokenAddressTokenAddress
    );
    event residualETH(uint256 residualETHtransferred);

    
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    constructor() public {}

    function LetsInvest(
        address _toWhomToIssue,
        address _IncomingTokenContractAddress,
        uint256 _IncomingTokenQty,
        address _UniPoolsUnderlyingTokenAddress
    )
        public
        stopInEmergency
        returns (bool)
    {
        
        require(
            IERC20(_IncomingTokenContractAddress).balanceOf(msg.sender) >
                _IncomingTokenQty,
            "Ownership less than requested"
        );
        require(
            IERC20(_IncomingTokenContractAddress).allowance(
                msg.sender,
                address(this)
            ) >
                _IncomingTokenQty,
            "Permission to DeFiZap is less than requested"
        );
        uint256 investmentQTY = _IncomingTokenQty;
        require(
            IERC20(_IncomingTokenContractAddress).transferFrom(
                msg.sender,
                address(this),
                investmentQTY
            ),
            "Error in transferring token:1"
        );
        require(
            (
                invest2UniPool(
                    investmentQTY,
                    _toWhomToIssue,
                    _IncomingTokenContractAddress,
                    _UniPoolsUnderlyingTokenAddress
                )
            ),
            "error in invest2UniPool"
        );
        emit details(
            msg.sender,
            _toWhomToIssue,
            _IncomingTokenContractAddress,
            _UniPoolsUnderlyingTokenAddress
        );
        return (true);
    }

    function invest2UniPool(
        uint256 _ERC20QTY,
        address _toWhomToIssue,
        address _IncomingTokenContractAddress,
        address _UniPoolsUnderlyingTokenAddress
    ) internal returns (bool) {
        
        uint256 EthOnConversion;
        uint256 nonConvertiblePortion;
        IuniswapExchange_ERC20toUniPoolZapV1 UniSwapExchangeContractAddress;
        
        if (_IncomingTokenContractAddress == _UniPoolsUnderlyingTokenAddress) {
            nonConvertiblePortion = SafeMath.div(
                SafeMath.mul(_ERC20QTY, 503),
                1000
            );
            uint256 convertiblePortion = SafeMath.sub(
                _ERC20QTY,
                nonConvertiblePortion
            );
            
            UniSwapExchangeContractAddress = IuniswapExchange_ERC20toUniPoolZapV1(
                UniSwapFactoryAddress.getExchange(_IncomingTokenContractAddress)
            );
            
            IERC20(_IncomingTokenContractAddress).approve(
                address(UniSwapExchangeContractAddress),
                _ERC20QTY
            );
            
            EthOnConversion = UniSwapExchangeContractAddress
                .tokenToEthSwapInput(
                convertiblePortion,
                1,
                SafeMath.add(now, 1800)
            );

        } else {
            
            IuniswapExchange_ERC20toUniPoolZapV1 UniSwapExchangeContractAddress_incomingToken = IuniswapExchange_ERC20toUniPoolZapV1(
                UniSwapFactoryAddress.getExchange(_IncomingTokenContractAddress)
            );

            require(
                (
                    IERC20(_IncomingTokenContractAddress).approve(
                        address(UniSwapExchangeContractAddress_incomingToken),
                        _ERC20QTY
                    )
                ),
                "error in approval:3"
            );
            uint256 nonConvertiblePortion_beforeConversion = SafeMath.div(
                SafeMath.mul(_ERC20QTY, 503),
                1000
            );
            nonConvertiblePortion = UniSwapExchangeContractAddress_incomingToken
                .tokenToTokenSwapInput(
                nonConvertiblePortion_beforeConversion,
                1,
                1,
                SafeMath.add(now, 1800),
                _UniPoolsUnderlyingTokenAddress
            );

            uint256 convertiblePortion = SafeMath.sub(
                _ERC20QTY,
                nonConvertiblePortion_beforeConversion
            );

            EthOnConversion = UniSwapExchangeContractAddress_incomingToken
                .tokenToEthSwapInput(
                convertiblePortion,
                1,
                SafeMath.add(now, 1800)
            );

            require(
                (
                    IERC20(_IncomingTokenContractAddress).approve(
                        address(UniSwapExchangeContractAddress_incomingToken),
                        0
                    )
                ),
                "error in setting approval back to zero"
            );
            UniSwapExchangeContractAddress = IuniswapExchange_ERC20toUniPoolZapV1(
                UniSwapFactoryAddress.getExchange(
                    _UniPoolsUnderlyingTokenAddress
                )
            );

        }
        require(
            (
                addLiquidity(
                    _toWhomToIssue,
                    _UniPoolsUnderlyingTokenAddress,
                    nonConvertiblePortion,
                    UniSwapExchangeContractAddress,
                    EthOnConversion
                )
            ),
            "issue in adding Liquidity"
        );
        return (true);
    }

    function addLiquidity(
        address _toWhomToIssue,
        address _UniPoolsUnderlyingTokenAddress,
        uint256 _UsableERC20,
        IuniswapExchange_ERC20toUniPoolZapV1 _UniSwapExchangeContractAddress,
        uint256 _valueinETH
    ) internal returns (bool) {
        uint256 max_tokens_ans = getMaxTokens(
            address(_UniSwapExchangeContractAddress),
            IERC20(_UniPoolsUnderlyingTokenAddress),
            _valueinETH
        );

        require(
            (
                IERC20(_UniPoolsUnderlyingTokenAddress).approve(
                    address(_UniSwapExchangeContractAddress),
                    _UsableERC20
                )
            ),
            "error in approving the unicontract, addLiquidity"
        );
        uint256 LiquidityTokens = _UniSwapExchangeContractAddress
            .addLiquidity
            .value(_valueinETH)(1, max_tokens_ans, SafeMath.add(now, 1800));
        require(
            LiquidityTokens ==
                _UniSwapExchangeContractAddress.balanceOf(address(this)),
            "error3:DeFiZap"
        );
        require(
            _UniSwapExchangeContractAddress.transfer(
                _toWhomToIssue,
                LiquidityTokens
            ),
            "error6:DeFiZap"
        );

        
        uint256 residual = IERC20(_UniPoolsUnderlyingTokenAddress).balanceOf(
            address(this)
        );
        uint256 ETHfromResidual = _UniSwapExchangeContractAddress
            .tokenToEthTransferInput(
            residual,
            1,
            SafeMath.add(now, 1800),
            _toWhomToIssue
        );
        emit residualETH(ETHfromResidual);
        require(
            (
                IERC20(_UniPoolsUnderlyingTokenAddress).approve(
                    address(_UniSwapExchangeContractAddress),
                    0
                )
            ),
            "error in resetting the approval to zero"
        );
        return true;
    }

    function getMaxTokens(
        address _UniSwapExchangeContractAddress,
        IERC20 _ERC20TokenAddress,
        uint256 _value
    ) internal view returns (uint256) {
        uint256 contractBalance = address(_UniSwapExchangeContractAddress)
            .balance;
        uint256 eth_reserve = SafeMath.sub(contractBalance, _value);
        uint256 token_reserve = _ERC20TokenAddress.balanceOf(
            _UniSwapExchangeContractAddress
        );
        uint256 token_amount = SafeMath.div(
            SafeMath.mul(_value, token_reserve),
            eth_reserve
        ) +
            1;
        return token_amount;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner, qty);
    }

    
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    
    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    
    function() external payable {
    }
}