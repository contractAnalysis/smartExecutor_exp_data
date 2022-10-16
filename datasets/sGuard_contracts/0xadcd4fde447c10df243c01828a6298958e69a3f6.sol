pragma solidity ^0.5.0;



interface IERC20 {
    
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

    
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.5.0;



contract Context {
    
    
    constructor() internal {}

    

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
    address payable public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    constructor() internal {
        address payable msgSender = _msgSender();
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

    
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address payable newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    
    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
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

    
    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;



contract ReentrancyGuard {
    bool private _notEntered;

    constructor() internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}



interface IuniswapFactory {
    function getExchange(address token)
        external
        view
        returns (address exchange);
}


interface IuniswapExchange {
    
    function removeLiquidity(
        uint256 amount,
        uint256 min_eth,
        uint256 min_tokens,
        uint256 deadline
    ) external returns (uint256, uint256);

    
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

    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256 tokens_bought);

    function getTokenToEthInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256 eth_bought);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address from, address to, uint256 tokens)
        external
        returns (bool success);
}


interface ICurveExchange {
    function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount)
        external;
}

interface IrenBtcCurveExchange {
    function add_liquidity(
        uint256[2] calldata amounts,
        uint min_mint_amount
    ) external;
}

interface IsBtcCurveExchange {
    function add_liquidity(
        uint256[3] calldata amounts,
        uint min_mint_amount
    ) external;
}


interface yERC20 {
    function deposit(uint256 _amount) external;
}

contract ETH_ERC20_Curve_General_Zap_V1 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    bool private stopped = false;
    uint16 public goodwill;
    address public dzgoodwillAddress;
    

    IuniswapFactory private UniSwapFactoryAddress = IuniswapFactory(
        0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
    );
    address private DaiTokenAddress = address(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    address private UsdcTokenAddress = address(
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    );
    address private sUSDCurveExchangeAddress = address(
        0xA5407eAE9Ba41422680e2e00537571bcC53efBfD
    );
    address private sUSDCurvePoolTokenAddress = address(
        0xC25a3A3b969415c80451098fa907EC722572917F
    );
    address private yCurveExchangeAddress = address(
        0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3
    );
    address private yCurvePoolTokenAddress = address(
        0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8
    );
    address private bUSDCurveExchangeAddress = address(
        0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB
    );
    address private bUSDCurvePoolTokenAddress = address(
        0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B
    );
    address private paxCurveExchangeAddress = address(
        0xA50cCc70b6a011CffDdf45057E39679379187287
    );
    address private paxCurvePoolTokenAddress = address(
        0xD905e2eaeBe188fc92179b6350807D8bd91Db0D8
    );
    address private renBtcCurveExchangeAddress = address(
        0x93054188d876f558f4a66B2EF1d97d16eDf0895B
    );
    address private renBtcCurvePoolTokenAddress = address(
        0x49849C98ae39Fff122806C06791Fa73784FB3675
    );
    address private sBtcCurveExchangeAddress = address(
        0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714
    );
    address private sBtcCurvePoolTokenAddress = address(
        0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3
    );
    
    
    address private wbtcTokenAddress = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    address private renBtcTokenAddress = address(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
    address private sBtcTokenAddress = address(0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6);


    mapping(address => address) internal exchange2Token;

    constructor(uint16 _goodwill, address _dzgoodwillAddress) public {
        goodwill = _goodwill;
        dzgoodwillAddress = _dzgoodwillAddress;
        exchange2Token[sUSDCurveExchangeAddress] = sUSDCurvePoolTokenAddress;
        exchange2Token[yCurveExchangeAddress] = yCurvePoolTokenAddress;
        exchange2Token[bUSDCurveExchangeAddress] = bUSDCurvePoolTokenAddress;
        exchange2Token[paxCurveExchangeAddress] = paxCurvePoolTokenAddress;
        exchange2Token[renBtcCurveExchangeAddress] = renBtcCurvePoolTokenAddress;     
        exchange2Token[sBtcCurveExchangeAddress] = sBtcCurvePoolTokenAddress;
        
        approveToken();
    }

    
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function approveToken() public {
        IERC20(DaiTokenAddress).approve(sUSDCurveExchangeAddress, uint256(-1));
        IERC20(DaiTokenAddress).approve(yCurveExchangeAddress, uint256(-1));
        IERC20(DaiTokenAddress).approve(bUSDCurveExchangeAddress, uint256(-1));
        IERC20(DaiTokenAddress).approve(paxCurveExchangeAddress, uint256(-1));

        IERC20(UsdcTokenAddress).approve(sUSDCurveExchangeAddress, uint256(-1));
        IERC20(UsdcTokenAddress).approve(yCurveExchangeAddress, uint256(-1));
        IERC20(UsdcTokenAddress).approve(bUSDCurveExchangeAddress, uint256(-1));
        IERC20(UsdcTokenAddress).approve(paxCurveExchangeAddress, uint256(-1));
    }


    function ZapIn(
        address _toWhomToIssue,
        address _IncomingTokenAddress,
        address _curvePoolExchangeAddress,
        uint256 _IncomingTokenQty,
        uint256 _minPoolTokens
    ) public payable stopInEmergency returns (uint256 crvTokensBought) {
        require(
            _curvePoolExchangeAddress == sUSDCurveExchangeAddress ||
                _curvePoolExchangeAddress == yCurveExchangeAddress ||
                _curvePoolExchangeAddress == bUSDCurveExchangeAddress ||
                _curvePoolExchangeAddress == paxCurveExchangeAddress ||
                _curvePoolExchangeAddress == renBtcCurveExchangeAddress ||
                _curvePoolExchangeAddress == sBtcCurveExchangeAddress,
            "Invalid Curve Pool Address"
        );

        if (_IncomingTokenAddress == address(0)) {
            crvTokensBought = ZapInWithETH(
                _toWhomToIssue,
                _curvePoolExchangeAddress,
                _minPoolTokens
            );
        } else {
            crvTokensBought = ZapInWithERC20(
                _toWhomToIssue,
                _IncomingTokenAddress,
                _curvePoolExchangeAddress,
                _IncomingTokenQty,
                _minPoolTokens
            );
        }
    }

    function ZapInWithETH(
        address _toWhomToIssue,
        address _curvePoolExchangeAddress,
        uint256 _minPoolTokens
    ) internal stopInEmergency returns (uint256 crvTokensBought) {
        require(msg.value > 0, "Err: No ETH sent");
        
        if(_curvePoolExchangeAddress != sBtcCurveExchangeAddress && _curvePoolExchangeAddress != renBtcCurveExchangeAddress) {
            uint256 daiBought = _eth2Token(DaiTokenAddress, (msg.value).div(2));
            uint256 usdcBought = _eth2Token(UsdcTokenAddress, (msg.value).div(2));
            crvTokensBought = _enter2Curve(
                _toWhomToIssue,
                daiBought,
                usdcBought,
                _curvePoolExchangeAddress,
                _minPoolTokens
            );
        } else {
            uint256 wbtcBought = _eth2Token(wbtcTokenAddress, msg.value);
            crvTokensBought = _enter2BtcCurve(
                _toWhomToIssue,
                wbtcTokenAddress,
                _curvePoolExchangeAddress,
                wbtcBought,
                _minPoolTokens
            );
        }
    }


    function ZapInWithERC20(
        address _toWhomToIssue,
        address _IncomingTokenAddress,
        address _curvePoolExchangeAddress,
        uint256 _IncomingTokenQty,
        uint256 _minPoolTokens
    ) internal stopInEmergency returns (uint256 crvTokensBought) {
        require(_IncomingTokenQty > 0, "Err: No ERC20 sent");

        require(
            IERC20(_IncomingTokenAddress).transferFrom(
                msg.sender,
                address(this),
                _IncomingTokenQty
            ),
            "Error in transferring ERC20"
        );
        
        if(_curvePoolExchangeAddress == sBtcCurveExchangeAddress || _curvePoolExchangeAddress == renBtcCurveExchangeAddress) {
            if(_IncomingTokenAddress == wbtcTokenAddress || _IncomingTokenAddress == renBtcTokenAddress || _IncomingTokenAddress == sBtcTokenAddress) {
                crvTokensBought = _enter2BtcCurve(
                    _toWhomToIssue,
                    _IncomingTokenAddress,
                    _curvePoolExchangeAddress,
                    _IncomingTokenQty,
                    _minPoolTokens
                );
            } else {
                uint256 wbtcBought = _token2Token(
                    _IncomingTokenAddress,
                    wbtcTokenAddress,
                    _IncomingTokenQty
                );
                crvTokensBought = _enter2BtcCurve(
                    _toWhomToIssue,
                    wbtcTokenAddress,
                    _curvePoolExchangeAddress,
                    wbtcBought,
                    _minPoolTokens
                );
            }
            
        } else {
            uint256 daiBought;
            uint256 usdcBought;
    
            if (_IncomingTokenAddress == DaiTokenAddress) {
                daiBought = _IncomingTokenQty;
                usdcBought = 0;
            } else if (_IncomingTokenAddress == UsdcTokenAddress) {
                daiBought = 0;
                usdcBought = _IncomingTokenQty;
            } else {
                daiBought = _token2Token(
                    _IncomingTokenAddress,
                    DaiTokenAddress,
                    (_IncomingTokenQty).div(2)
                );
                usdcBought = _token2Token(
                    _IncomingTokenAddress,
                    UsdcTokenAddress,
                    (_IncomingTokenQty).div(2)
                );
            }
    
            crvTokensBought = _enter2Curve(
                _toWhomToIssue,
                daiBought,
                usdcBought,
                _curvePoolExchangeAddress,
                _minPoolTokens
            );
        }
        
    }
    
    function _enter2BtcCurve(
        address _toWhomToIssue,
        address _incomingBtcTokenAddress,
        address _curvePoolExchangeAddress,
        uint256 _incomingBtcTokenAmt,
        uint256 _minPoolTokens
    ) internal returns (uint256 crvTokensBought) {
        require(_incomingBtcTokenAddress == sBtcTokenAddress || 
                _incomingBtcTokenAddress == wbtcTokenAddress ||
                _incomingBtcTokenAddress == renBtcTokenAddress,
                "ERR: Incorrect BTC Token Address"
        );
        IERC20(_incomingBtcTokenAddress).approve(_curvePoolExchangeAddress, _incomingBtcTokenAmt);
        address btcCurvePoolTokenAddress = exchange2Token[_curvePoolExchangeAddress];
        uint256 iniTokenBal = IERC20(btcCurvePoolTokenAddress).balanceOf(address(this));
        
        if(_incomingBtcTokenAddress == wbtcTokenAddress) {
            if(_curvePoolExchangeAddress == renBtcCurveExchangeAddress){
                IrenBtcCurveExchange(_curvePoolExchangeAddress).add_liquidity(
                    [0, _incomingBtcTokenAmt],
                    _minPoolTokens
                );
            }else {
                IsBtcCurveExchange(_curvePoolExchangeAddress).add_liquidity(
                    [0, _incomingBtcTokenAmt, 0],
                    _minPoolTokens
                );                
            }
        } else if(_incomingBtcTokenAddress == renBtcTokenAddress) {
            if(_curvePoolExchangeAddress == renBtcCurveExchangeAddress){
                IrenBtcCurveExchange(_curvePoolExchangeAddress).add_liquidity(
                    [_incomingBtcTokenAmt,0],
                    _minPoolTokens
                );
            }else {
                IsBtcCurveExchange(_curvePoolExchangeAddress).add_liquidity(
                    [_incomingBtcTokenAmt,0, 0],
                    _minPoolTokens
                );                
            }
        } 
        else {
            IsBtcCurveExchange(_curvePoolExchangeAddress).add_liquidity(
                [0, 0, _incomingBtcTokenAmt],
                0
            );
        }
        crvTokensBought = (IERC20(btcCurvePoolTokenAddress).balanceOf(address(this))).sub(iniTokenBal);
        require(crvTokensBought > _minPoolTokens, "Error less than min pool tokens");
        IERC20(btcCurvePoolTokenAddress).transfer(
            _toWhomToIssue,
            crvTokensBought
        );
    }

    function _enter2Curve(
        address _toWhomToIssue,
        uint256 daiBought,
        uint256 usdcBought,
        address _curvePoolExchangeAddress,
        uint256 _minPoolTokens
    ) internal returns (uint256 crvTokensBought) {
        
        address poolTokenAddress = exchange2Token[_curvePoolExchangeAddress];
        uint256 iniTokenBal = IERC20(poolTokenAddress).balanceOf(address(this));
        ICurveExchange(_curvePoolExchangeAddress).add_liquidity(
            [daiBought, usdcBought, 0, 0],
            _minPoolTokens
        );
        crvTokensBought = (IERC20(poolTokenAddress).balanceOf(address(this))).sub(iniTokenBal);
        require(crvTokensBought > _minPoolTokens, "Error less than min pool tokens");

        uint256 goodwillPortion = SafeMath.div(
            SafeMath.mul(crvTokensBought, goodwill),
            10000
        );

        require(
            IERC20(poolTokenAddress).transfer(
                dzgoodwillAddress,
                goodwillPortion
            ),
            "Error transferring goodwill"
        );

        require(
            IERC20(poolTokenAddress).transfer(
                _toWhomToIssue,
                SafeMath.sub(crvTokensBought, goodwillPortion)
            ),
            "Error transferring CRV"
        );
    }

    
    function _eth2Token(address _ToTokenContractAddress, uint256 ethReceived)
        internal
        returns (uint256 tokensBought)
    {
        IuniswapExchange ToUniSwapExchangeContractAddress = IuniswapExchange(
            UniSwapFactoryAddress.getExchange(_ToTokenContractAddress)
        );
        
        uint ERC20_againstETH = ToUniSwapExchangeContractAddress.getEthToTokenInputPrice(ethReceived);
        
        tokensBought = ToUniSwapExchangeContractAddress
            .ethToTokenSwapInput
            .value(ethReceived)(
                SafeMath.div(SafeMath.mul(ERC20_againstETH, 98), 100), 
                SafeMath.add(now, 300)
            );
        require(tokensBought > 0, "Error in swapping ETH");
    }

    function _token2Token(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 tokensBought) {
        IuniswapExchange FromUniSwapExchangeContractAddress = IuniswapExchange(
            UniSwapFactoryAddress.getExchange(_FromTokenContractAddress)
        );

        IERC20(_FromTokenContractAddress).approve(
            address(FromUniSwapExchangeContractAddress),
            tokens2Trade
        );

        tokensBought = FromUniSwapExchangeContractAddress.tokenToTokenSwapInput(
            tokens2Trade,
            1,
            1,
            SafeMath.add(now, 300),
            _ToTokenContractAddress
        );

        require(tokensBought > 0, "Error in swapping ERC");
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(_owner, qty);
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

    
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    
    function withdraw() public onlyOwner {
        _owner.transfer(address(this).balance);
    }

    
    function destruct() public onlyOwner {
        selfdestruct(_owner);
    }
}