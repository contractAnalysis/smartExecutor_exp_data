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

interface IfulcrumInterface__ERC20toUniPoolZapV1 {
    function mintWithToken(
        address receiver,
        address depositTokenAddress,
        uint256 depositAmount,
        uint256 maxPriceAllowed
    ) external returns (uint256);
}

contract Ownable {
    address payable public owner;
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

contract control_goodwill is Ownable {
    uint16 public goodwillInBasisPoints;
    address public dzgoodwillAddress;

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill >= 0 && _new_goodwill <= 10000,
            "GoodWill Value not allowed"
        );
        goodwillInBasisPoints = _new_goodwill;

    }

    function set_new_dzgoodwillAddress(address _new_dzgoodwillAddress)
        public
        onlyOwner
    {
        dzgoodwillAddress = _new_dzgoodwillAddress;
    }
}

contract ERC20toUniPoolZapV1_General is
    Initializable,
    Ownable,
    control_goodwill
{
    using SafeMath for uint256;

    

    
    bool private stopped;

    IuniswapFactory_ERC20toUniPoolZapV1 public UniSwapFactoryAddress;
    address public DaiContractAddress;

    mapping(address => uint256) private userBalance;

    
    event details(
        address indexed _user,
        address _IncomingTokenAddress,
        address _ZapOutAddress
    );

    event internal_d(string, uint256);
    event internal_s(string, address);

    
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function initialize(
        
        
        
        
    ) public initializer {
        stopped = false;
        owner = msg.sender;
        goodwillInBasisPoints = 100;
        dzgoodwillAddress = address(0xf79Cabc4cacA5ECa8eE6A36651A0Ad5A2190F04E);
        UniSwapFactoryAddress = IuniswapFactory_ERC20toUniPoolZapV1(
            0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
        );
        DaiContractAddress = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function LetsInvest(
        address _toWhomToIssue,
        address _IncomingTokenContractAddress,
        uint256 _IncomingTokenQty,
        bool _InvestingInLLP,
        address _UniPoolsUnderlyingTokenAddress,
        address _UnderlyingFulcrumContractAddress,
        uint16 _LLPPortionInBasisPoints
    ) public stopInEmergency returns (bool) {
        
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
        uint256 investmentQTY = work4goodwill(
            _IncomingTokenQty,
            _IncomingTokenContractAddress
        );
        emit internal_d("investmentQTY", investmentQTY);
        require(
            IERC20(_IncomingTokenContractAddress).transferFrom(
                msg.sender,
                address(this),
                investmentQTY
            ),
            "error2:defizap"
        );
        uint ECBalance = IERC20(_IncomingTokenContractAddress).balanceOf(address(this));
        emit internal_d("ECBalance", ECBalance);
        
        
        if (!_InvestingInLLP) {
            require(
                (invest2UniPool(
                    investmentQTY,
                    _toWhomToIssue,
                    _IncomingTokenContractAddress,
                    _UniPoolsUnderlyingTokenAddress
                )
            ),"error in invest2UniPool");

            return true;
            
        } else {
            require(
                _UnderlyingFulcrumContractAddress != address(0),
                "error4:DefiZap"
            );
            require(
                _LLPPortionInBasisPoints > 0 &&
                    _LLPPortionInBasisPoints <= 10000,
                "error5:DeFiZap"
            );
            uint256 LLP_Portion = SafeMath.div(
                SafeMath.mul(investmentQTY, _LLPPortionInBasisPoints),
                10000
            );
            emit internal_d("LLP_Portion", LLP_Portion);
            uint256 BalanceUniPoolPortion = SafeMath.sub(
                investmentQTY,
                LLP_Portion
            );
            emit internal_d("BalanceFromLLP_Portion", BalanceUniPoolPortion);
            require(
              ( invest2UniPool(
                    BalanceUniPoolPortion,
                    _toWhomToIssue,
                    _IncomingTokenContractAddress,
                    _UniPoolsUnderlyingTokenAddress
                )
            ), "error in invest2UniPool");
            
            if (_IncomingTokenContractAddress == DaiContractAddress) {
                require((invest2Fulcrum(
                    _UnderlyingFulcrumContractAddress,
                    _toWhomToIssue,
                    LLP_Portion
                )),"issue in investing in Fulcrum");

            } else {
                IuniswapExchange_ERC20toUniPoolZapV1 UniSwapExchangeContractAddress_incomingToken = IuniswapExchange_ERC20toUniPoolZapV1(
                    UniSwapFactoryAddress.getExchange(
                        _IncomingTokenContractAddress
                    )
                );
                emit internal_s("IssueAddd", address(UniSwapExchangeContractAddress_incomingToken));
                require((IERC20(_IncomingTokenContractAddress).approve(
                    address(UniSwapExchangeContractAddress_incomingToken),
                    LLP_Portion
                )),"issue in some odd approval");
                emit internal_s("issueadd approved", address(UniSwapExchangeContractAddress_incomingToken));
                uint256 ERC202DAI = UniSwapExchangeContractAddress_incomingToken
                    .tokenToTokenSwapInput(
                    LLP_Portion,
                    1,
                    1,
                    SafeMath.add(now, 1800),
                    DaiContractAddress
                );
                emit internal_d("Dai on conversion", ERC202DAI);
                require((IERC20(_IncomingTokenContractAddress).approve(
                    address(UniSwapExchangeContractAddress_incomingToken),
                    0
                )),"issue in some odd approval second time");
                require((invest2Fulcrum(
                        _UnderlyingFulcrumContractAddress,
                        _toWhomToIssue,
                        ERC202DAI
                    )),"issue in investing in Fulcrum non DAI");
                return (true);
            }

        }
    }

    function work4goodwill(
        uint256 _IncomingTokenQty,
        address _IncomingTokenContractAddress
    ) internal returns (uint256) {
        
        uint256 goodwillPortion = SafeMath.div(
            SafeMath.mul(_IncomingTokenQty, goodwillInBasisPoints),
            10000
        );
        
        require(
            IERC20(_IncomingTokenContractAddress).transferFrom(
                msg.sender,
                dzgoodwillAddress,
                goodwillPortion
            ),
            "error1:defizap"
        );
        
        uint256 investmentQTY = SafeMath.sub(
            _IncomingTokenQty,
            goodwillPortion
        );
        return investmentQTY;
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
            emit internal_d("ETHAfterSwap1", EthOnConversion);

        } else {
            
            IuniswapExchange_ERC20toUniPoolZapV1 UniSwapExchangeContractAddress_incomingToken = IuniswapExchange_ERC20toUniPoolZapV1(
                UniSwapFactoryAddress.getExchange(_IncomingTokenContractAddress)
            );
            emit internal_s("ExAddrss", address(UniSwapExchangeContractAddress_incomingToken));
            require((IERC20(_IncomingTokenContractAddress).approve(
                address(UniSwapExchangeContractAddress_incomingToken),
                _ERC20QTY
            )),"error in approving");
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
            emit internal_d("nonConAfterSwap", nonConvertiblePortion);
            uint256 convertiblePortion = SafeMath.sub(
                _ERC20QTY,
                nonConvertiblePortion_beforeConversion
            );
            emit internal_d("ConPortion", convertiblePortion);
            EthOnConversion = UniSwapExchangeContractAddress_incomingToken
                .tokenToEthSwapInput(
                convertiblePortion,
                1,
                SafeMath.add(now, 1800)
            );
            emit internal_d("ETHAfterSwap2", EthOnConversion);
            require((IERC20(_IncomingTokenContractAddress).approve(
                address(UniSwapExchangeContractAddress_incomingToken),
                0
            )),"error in setting approval back to zero");
            UniSwapExchangeContractAddress = IuniswapExchange_ERC20toUniPoolZapV1(
                UniSwapFactoryAddress.getExchange(
                    _UniPoolsUnderlyingTokenAddress
                )
            );
            emit internal_s("UniAddress", address(UniSwapExchangeContractAddress));
        }
        require(
            (addLiquidity(
                _toWhomToIssue,
                _UniPoolsUnderlyingTokenAddress,
                nonConvertiblePortion,
                UniSwapExchangeContractAddress,
                EthOnConversion
            )
        ),"issue in adding Liquidity");
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
        emit internal_d("maxTokens", max_tokens_ans);
        require((IERC20(_UniPoolsUnderlyingTokenAddress).approve(address(_UniSwapExchangeContractAddress),_UsableERC20)),"error in approving the unicontract, addLiquidity");
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
        emit internal_d("Residual", residual);
        uint256 ETHfromResidual = _UniSwapExchangeContractAddress
            .tokenToEthTransferInput(
            residual,
            1,
            SafeMath.add(now, 1800),
            _toWhomToIssue
        );
        emit internal_d("ETHResidual", ETHfromResidual);
        require((IERC20(_UniPoolsUnderlyingTokenAddress).approve(address(_UniSwapExchangeContractAddress),0)),"silly error");
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

    function invest2Fulcrum(
        address _UnderlyingFulcrumContractAddress,
        address _toWhomToIssue,
        uint256 LLP_Portion
    ) internal returns (bool) {
        IERC20(DaiContractAddress).approve(
            _UnderlyingFulcrumContractAddress,
            LLP_Portion
        );
        IfulcrumInterface__ERC20toUniPoolZapV1(
            _UnderlyingFulcrumContractAddress
        )
            .mintWithToken(_toWhomToIssue, DaiContractAddress, LLP_Portion, 0);
        IERC20(DaiContractAddress).approve(
            _UnderlyingFulcrumContractAddress,
            0
        );
        require(
            (IERC20(DaiContractAddress).balanceOf(address(this)) == 0),
            "error6:DefiZap"
        );
        return true;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner, qty);
    }

    
    function() external payable {}

    
    function checkERC20Balance(address _ERC20Address) public returns (uint256) {
        uint256 ERC20Balance = IERC20(_ERC20Address).balanceOf(address(this));
        emit internal_d("ERC20Balance", ERC20Balance);
        return (ERC20Balance);
    }

    function checkETHBalance() public returns (uint256) {
        uint256 ETHBalance = address(this).balance;
        emit internal_d("ERC20Balance", ETHBalance);
    }

    
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    
    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    
    function destruct() public onlyOwner {
        selfdestruct(owner);
    }

}