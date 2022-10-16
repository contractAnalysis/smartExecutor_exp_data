pragma solidity ^0.6.0;

interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

interface MemoryInterface {
    function getUint(uint id) external returns (uint num);
    function setUint(uint id, uint val) external;
}

interface EventInterface {
    function emitEvent(uint connectorType, uint connectorID, bytes32 eventCode, bytes calldata eventData) external;
}

contract Stores {

  
  function getEthAddr() internal pure returns (address) {
    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; 
  }

  
  function getMemoryAddr() internal pure returns (address) {
    return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; 
  }

  
  function getEventAddr() internal pure returns (address) {
    return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97; 
  }

  
  function getUint(uint getId, uint val) internal returns (uint returnVal) {
    returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
  }

  
  function setUint(uint setId, uint val) internal {
    if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
  }

  
  function emitEvent(bytes32 eventCode, bytes memory eventData) internal {
    (uint model, uint id) = connectorID();
    EventInterface(getEventAddr()).emitEvent(model, id, eventCode, eventData);
  }

  
  function connectorID() public view returns(uint model, uint id) {
    (model, id) = (1, 34);
  }

}


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

contract DSMath {
  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function add(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(x, y);
  }

  function sub(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.sub(x, y);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.mul(x, y);
  }

  function div(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.div(x, y);
  }

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
  }

}

interface ICurve {
    function calc_token_amount(uint256[4] calldata amounts, bool deposit) external view returns (uint256 amount);
    function exchange_underlying(int128 sellTokenId, int128 buyTokenId, uint256 sellTokenAmt, uint256 minBuyToken) external;
}

interface ICurveZap {
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external returns (uint256 amount);
    function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount) external;
    function remove_liquidity_imbalance(uint256[4] calldata amounts, uint256 max_burn_amount) external;
}


contract CurveHelpers is Stores, DSMath {
    
    function getCurveSwapAddr() internal pure returns (address) {
        return 0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51;
    }

    
    function getCurveZapAddr() internal pure returns (address) {
        return 0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;
    }

    
    function getCurveTokenAddr() internal pure returns (address) {
        return 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    }

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = (_amt / 10 ** (18 - _dec));
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = mul(_amt, 10 ** (18 - _dec));
    }

  function getTokenI(address token) internal pure returns (int128 i) {
    if (token == address(0x6B175474E89094C44Da98b954EedeAC495271d0F)) {
      
      i = 0;
    } else if (token == address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {
      
      i = 1;
    } else if (token == address(0xdAC17F958D2ee523a2206206994597C13D831ec7)) {
      
      i = 2;
    } else if (token == address(0x0000000000085d4780B73119b644AE5ecd22b376)) {
      
      i = 3;
    } else {
      revert("token-not-found.");
    }
  }
}

contract CurveProtocol is CurveHelpers {

  event LogSell(
    address indexed buyToken,
    address indexed sellToken,
    uint256 buyAmt,
    uint256 sellAmt,
    uint256 getId,
    uint256 setId
  );
  event LogDeposit(address token, uint256 amt, uint256 mintAmt, uint256 getId, uint256 setId);
  event LogWithdraw(address token, uint256 amt, uint256 burnAmt, uint256 getId,  uint256 setId);

  
  function sell(
    address buyAddr,
    address sellAddr,
    uint sellAmt,
    uint unitAmt,
    uint getId,
    uint setId
  ) external payable {
    uint _sellAmt = getUint(getId, sellAmt);
    ICurve curve = ICurve(getCurveSwapAddr());
    TokenInterface _buyToken = TokenInterface(buyAddr);
    TokenInterface _sellToken = TokenInterface(sellAddr);
    _sellAmt = _sellAmt == uint(-1) ? _sellToken.balanceOf(address(this)) : _sellAmt;
    _sellToken.approve(address(curve), _sellAmt);

    uint _slippageAmt = convert18ToDec(_buyToken.decimals(), wmul(unitAmt, convertTo18(_sellToken.decimals(), _sellAmt)));

    uint intialBal = _buyToken.balanceOf(address(this));
    curve.exchange_underlying(getTokenI(sellAddr), getTokenI(buyAddr), _sellAmt, _slippageAmt);
    uint finalBal = _buyToken.balanceOf(address(this));

    uint _buyAmt = sub(finalBal, intialBal);

    setUint(setId, _buyAmt);

    emit LogSell(buyAddr, sellAddr, _buyAmt, _sellAmt, getId, setId);
    bytes32 _eventCode = keccak256("LogSell(address,address,uint256,uint256,uint256,uint256)");
    bytes memory _eventParam = abi.encode(buyAddr, sellAddr, _buyAmt, _sellAmt, getId, setId);
    emitEvent(_eventCode, _eventParam);

  }

    
    function deposit(
        address token,
        uint amt,
        uint unitAmt,
        uint getId,
        uint setId
    ) external payable {
        uint256 _amt = getUint(getId, amt);
        TokenInterface tokenContract = TokenInterface(token);
        ICurveZap curveZap = ICurveZap(getCurveZapAddr());
        _amt = _amt == uint(-1) ? tokenContract.balanceOf(address(this)) : _amt;
        uint[4] memory _amts;
        _amts[uint(getTokenI(token))] = _amt;

        tokenContract.approve(address(curveZap), _amt);

        uint _slippageAmt = wmul(unitAmt, convertTo18(tokenContract.decimals(), _amt));

        TokenInterface curveTokenContract = TokenInterface(getCurveTokenAddr());
        uint initialCurveBal = curveTokenContract.balanceOf(address(this));

        curveZap.add_liquidity(_amts, _slippageAmt);

        uint finalCurveBal = curveTokenContract.balanceOf(address(this));

        uint mintAmt = sub(finalCurveBal, initialCurveBal);

        setUint(setId, mintAmt);

        emit LogDeposit(token, _amt, mintAmt, getId, setId);
        bytes32 _eventCode = keccak256("LogDeposit(address,uint256,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(token, _amt, mintAmt, getId, setId);
        emitEvent(_eventCode, _eventParam);
    }

    
    function withdraw(
        address token,
        uint256 amt,
        uint256 unitAmt,
        uint getId,
        uint setId
    ) external payable {
        uint _amt = getUint(getId, amt);
        int128 tokenId = getTokenI(token);

        TokenInterface curveTokenContract = TokenInterface(getCurveTokenAddr());
        ICurveZap curveZap = ICurveZap(getCurveZapAddr());
        ICurve curveSwap = ICurve(getCurveSwapAddr());

        uint _curveAmt;
        uint[4] memory _amts;
        if (_amt == uint(-1)) {
        _curveAmt = curveTokenContract.balanceOf(address(this));
        _amt = curveZap.calc_withdraw_one_coin(_curveAmt, tokenId);
        _amts[uint(tokenId)] = _amt;
        } else {
        _amts[uint(tokenId)] = _amt;
        _curveAmt = curveSwap.calc_token_amount(_amts, false);
        }


        uint _amt18 = convertTo18(TokenInterface(token).decimals(), _amt);
        uint _slippageAmt = wmul(unitAmt, _amt18);

        curveTokenContract.approve(address(curveZap), 0);
        curveTokenContract.approve(address(curveZap), _slippageAmt);

        curveZap.remove_liquidity_imbalance(_amts, _slippageAmt);

        setUint(setId, _amt);

        emit LogWithdraw(token, _amt, _curveAmt, getId, setId);
        bytes32 _eventCode = keccak256("LogWithdraw(address,uint256,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(token, _amt, _curveAmt, getId, setId);
        emitEvent(_eventCode, _eventParam);
    }

}

contract ConnectCurveY is CurveProtocol {
  string public name = "Curve-y-v1";
}