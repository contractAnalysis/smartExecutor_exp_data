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

  
  function setUint(uint setId, uint val) virtual internal {
    if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
  }

  
  function emitEvent(bytes32 eventCode, bytes memory eventData) virtual internal {
    (uint model, uint id) = connectorID();
    EventInterface(getEventAddr()).emitEvent(model, id, eventCode, eventData);
  }

  
  function connectorID() public view returns(uint model, uint id) {
    (model, id) = (0, 0);
  }

}

pragma solidity ^0.6.0;


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



pragma solidity ^0.6.0;


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


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        
        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        
        
        

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface OneProtoInterface {
    function swapWithReferral(
        TokenInterface fromToken,
        TokenInterface destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 flags, 
        address referral,
        uint256 feePercent
    ) external payable returns(uint256);

    function swapWithReferralMulti(
        TokenInterface[] calldata tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256[] calldata flags,
        address referral,
        uint256 feePercent
    ) external payable returns(uint256 returnAmount);

    function getExpectedReturn(
        TokenInterface fromToken,
        TokenInterface destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags 
    )
    external
    view
    returns(
        uint256 returnAmount,
        uint256[] memory distribution
    );
}


contract OneHelpers is Stores, DSMath {
    using SafeERC20 for IERC20;

    
    function getOneProtoAddress() internal pure returns (address payable) {
        return 0x50FDA034C0Ce7a8f7EFDAebDA7Aa7cA21CC1267e;
    }

    function getReferralAddr() internal pure returns (address) {
        return 0xa7615CD307F323172331865181DC8b80a2834324;  
    }

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = (_amt / 10 ** (18 - _dec));
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = mul(_amt, 10 ** (18 - _dec));
    }

    function getTokenBal(TokenInterface token) internal view returns(uint _amt) {
        _amt = address(token) == getEthAddr() ? address(this).balance : token.balanceOf(address(this));
    }

    function getTokensDec(TokenInterface buyAddr, TokenInterface sellAddr) internal view returns(uint buyDec, uint sellDec) {
        buyDec = address(buyAddr) == getEthAddr() ?  18 : buyAddr.decimals();
        sellDec = address(sellAddr) == getEthAddr() ?  18 : sellAddr.decimals();
    }

    function getSlippageAmt(
        TokenInterface _buyAddr,
        TokenInterface _sellAddr,
        uint _sellAmt,
        uint unitAmt
    ) internal view returns(uint _slippageAmt) {
        (uint _buyDec, uint _sellDec) = getTokensDec(_buyAddr, _sellAddr);
        uint _sellAmt18 = convertTo18(_sellDec, _sellAmt);
        _slippageAmt = convert18ToDec(_buyDec, wmul(unitAmt, _sellAmt18));
    }

    function convertToTokenInterface(address[] memory tokens) internal pure returns(TokenInterface[] memory) {
        TokenInterface[] memory _tokens = new TokenInterface[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            _tokens[i] = TokenInterface(tokens[i]);
        }
        return _tokens;
    }

    function _transfer(address payable to, IERC20 token, uint _amt) internal {
        address(token) == getEthAddr() ?
            to.transfer(_amt) :
            token.safeTransfer(to, _amt);
    }

    function takeFee(
        address token,
        uint amount,
        address feeCollector,
        uint feePercent
    ) internal returns (uint leftAmt, uint feeAmount){
        if (feeCollector != address(0)) {
            feeAmount = wmul(amount, feePercent);
            leftAmt = sub(amount, feeAmount);
            uint feeCollectorAmt = wmul(feeAmount, 7 * 10 ** 17); 
            uint restAmt = sub(feeAmount, feeCollectorAmt); 
            IERC20 tokenContract = IERC20(token);
            _transfer(payable(feeCollector), tokenContract, feeCollectorAmt);
            _transfer(payable(getReferralAddr()), tokenContract, restAmt);
        } else {
            leftAmt = amount;
        }
    }
}


contract Resolver is OneHelpers {
    struct OneProtoData {
        TokenInterface sellToken;
        TokenInterface buyToken;
        uint _sellAmt;
        uint _buyAmt;
        uint unitAmt;
        address feeCollector;
        uint256 feeAmount;
        uint[] distribution;
        uint disableDexes;
    }

    function oneProtoSwap(
        OneProtoInterface oneProtoContract,
        OneProtoData memory oneProtoData
    ) internal returns (uint buyAmt) {
        TokenInterface _sellAddr = oneProtoData.sellToken;
        TokenInterface _buyAddr = oneProtoData.buyToken;
        uint _sellAmt = oneProtoData._sellAmt;

        uint _slippageAmt = getSlippageAmt(_buyAddr, _sellAddr, _sellAmt, oneProtoData.unitAmt);

        uint ethAmt;
        if (address(_sellAddr) == getEthAddr()) {
            ethAmt = _sellAmt;
        } else {
            _sellAddr.approve(address(oneProtoContract), _sellAmt);
        }


        uint initalBal = getTokenBal(_buyAddr);
        oneProtoContract.swapWithReferral.value(ethAmt)(
            _sellAddr,
            _buyAddr,
            _sellAmt,
            _slippageAmt,
            oneProtoData.distribution,
            oneProtoData.disableDexes,
            getReferralAddr(),
            0
        );
        uint finalBal = getTokenBal(_buyAddr);

        buyAmt = sub(finalBal, initalBal);

        require(_slippageAmt <= buyAmt, "Too much slippage");
    }

    struct OneProtoMultiData {
        address[] tokens;
        TokenInterface sellToken;
        TokenInterface buyToken;
        uint _sellAmt;
        uint _buyAmt;
        uint unitAmt;
        address feeCollector;
        uint256 feeAmount;
        uint[] distribution;
        uint[] disableDexes;
    }

    function oneProtoSwapMulti(OneProtoMultiData memory oneProtoData) internal returns (uint buyAmt) {
        TokenInterface _sellAddr = oneProtoData.sellToken;
        TokenInterface _buyAddr = oneProtoData.buyToken;
        uint _sellAmt = oneProtoData._sellAmt;
        uint _slippageAmt = getSlippageAmt(_buyAddr, _sellAddr, _sellAmt, oneProtoData.unitAmt);

        OneProtoInterface oneSplitContract = OneProtoInterface(getOneProtoAddress());
        uint ethAmt;
        if (address(_sellAddr) == getEthAddr()) {
            ethAmt = _sellAmt;
        } else {
            _sellAddr.approve(address(oneSplitContract), _sellAmt);
        }

        uint initalBal = getTokenBal(_buyAddr);
        oneSplitContract.swapWithReferralMulti.value(ethAmt)(
            convertToTokenInterface(oneProtoData.tokens),
            _sellAmt,
            _slippageAmt,
            oneProtoData.distribution,
            oneProtoData.disableDexes,
            getReferralAddr(),
            0
        );
        uint finalBal = getTokenBal(_buyAddr);

        buyAmt = sub(finalBal, initalBal);

        require(_slippageAmt <= buyAmt, "Too much slippage");
    }
}

contract OneProtoEventResolver is Resolver {
    event LogSell(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 getId,
        uint256 setId
    );

    event LogSellFee(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        address indexed feeCollector,
        uint256 feeAmount,
        uint256 getId,
        uint256 setId
    );

    function emitLogSell(
        OneProtoData memory oneProtoData,
        uint256 getId,
        uint256 setId
    ) internal {
        bytes32 _eventCode;
        bytes memory _eventParam;
        if (oneProtoData.feeCollector == address(0)) {
            emit LogSell(
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                getId,
                setId
            );
            _eventCode = keccak256("LogSell(address,address,uint256,uint256,uint256,uint256)");
            _eventParam = abi.encode(
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                getId,
                setId
            );
        } else {
            emit LogSellFee(
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                oneProtoData.feeCollector,
                oneProtoData.feeAmount,
                getId,
                setId
            );
            _eventCode = keccak256("LogSellFee(address,address,uint256,uint256,address,uint256,uint256,uint256)");
            _eventParam = abi.encode(
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                oneProtoData.feeCollector,
                oneProtoData.feeAmount,
                getId,
                setId
            );
        }
        
    }

    event LogSellTwo(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 getId,
        uint256 setId
    );

    event LogSellFeeTwo(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        address indexed feeCollector,
        uint256 feeAmount,
        uint256 getId,
        uint256 setId
    );

    function emitLogSellTwo(
        OneProtoData memory oneProtoData,
        uint256 getId,
        uint256 setId
    ) internal {
        bytes32 _eventCode;
        bytes memory _eventParam;
        if (oneProtoData.feeCollector == address(0)) {
            emit LogSellTwo(
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                getId,
                setId
            );
            _eventCode = keccak256("LogSellTwo(address,address,uint256,uint256,uint256,uint256)");
            _eventParam = abi.encode(
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                getId,
                setId
            );
        } else {
            emit LogSellFeeTwo(
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                oneProtoData.feeCollector,
                oneProtoData.feeAmount,
                getId,
                setId
            );
            _eventCode = keccak256("LogSellFeeTwo(address,address,uint256,uint256,address,uint256,uint256,uint256)");
            _eventParam = abi.encode(
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                oneProtoData.feeCollector,
                oneProtoData.feeAmount,
                getId,
                setId
            );
        }
        
    }

    event LogSellMulti(
        address[] tokens,
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 getId,
        uint256 setId
    );

    event LogSellFeeMulti(
        address[] tokens,
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        address indexed feeCollector,
        uint256 feeAmount,
        uint256 getId,
        uint256 setId
    );

    function emitLogSellMulti(
        OneProtoMultiData memory oneProtoData,
        uint256 getId,
        uint256 setId
    ) internal {
        bytes32 _eventCode;
        bytes memory _eventParam;
        if (oneProtoData.feeCollector == address(0)) {
            emit LogSellMulti(
                oneProtoData.tokens,
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                getId,
                setId
            );
            _eventCode = keccak256("LogSellMulti(address[],address,address,uint256,uint256,uint256,uint256)");
            _eventParam = abi.encode(
                oneProtoData.tokens,
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                getId,
                setId
            );
        } else {
            emit LogSellFeeMulti(
                oneProtoData.tokens,
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                oneProtoData.feeCollector,
                oneProtoData.feeAmount,
                getId,
                setId
            );
            _eventCode = keccak256("LogSellFeeMulti(address[],address,address,uint256,uint256,address,uint256,uint256,uint256)");
            _eventParam = abi.encode(
                oneProtoData.tokens,
                address(oneProtoData.buyToken),
                address(oneProtoData.sellToken),
                oneProtoData._buyAmt,
                oneProtoData._sellAmt,
                oneProtoData.feeCollector,
                oneProtoData.feeAmount,
                getId,
                setId
            );
        }
        
    }
}

contract OneProtoResolverHelpers is OneProtoEventResolver {
    function _sell(
        OneProtoData memory oneProtoData,
        uint256 feePercent,
        uint256 getId,
        uint256 setId
    ) internal {
        uint _sellAmt = getUint(getId, oneProtoData._sellAmt);
        oneProtoData._sellAmt = _sellAmt == uint(-1) ?
            getTokenBal(oneProtoData.sellToken) :
            _sellAmt;

        OneProtoInterface oneProtoContract = OneProtoInterface(getOneProtoAddress());

        (, oneProtoData.distribution) = oneProtoContract.getExpectedReturn(
                oneProtoData.sellToken,
                oneProtoData.buyToken,
                oneProtoData._sellAmt,
                5,
                0
            );

        oneProtoData._buyAmt = oneProtoSwap(
            oneProtoContract,
            oneProtoData
        );

        (uint feeAmount, uint leftBuyAmt) = takeFee(
            address(oneProtoData.buyToken),
            oneProtoData._buyAmt,
            oneProtoData.feeCollector,
            feePercent
        );

        setUint(setId, leftBuyAmt);
        oneProtoData.feeAmount = feeAmount;

        emitLogSell(oneProtoData, getId, setId);
    }

    function _sellTwo(
        OneProtoData memory oneProtoData,
        uint256 feePercent,
        uint getId,
        uint setId
    ) internal {
        uint _sellAmt = getUint(getId, oneProtoData._sellAmt);

        oneProtoData._sellAmt = _sellAmt == uint(-1) ?
            getTokenBal(oneProtoData.sellToken) :
            _sellAmt;

        oneProtoData._buyAmt = oneProtoSwap(
            OneProtoInterface(getOneProtoAddress()),
            oneProtoData
        );

        (uint feeAmount, uint leftBuyAmt) = takeFee(
            address(oneProtoData.buyToken),
            oneProtoData._buyAmt,
            oneProtoData.feeCollector,
            feePercent
        );

        setUint(setId, leftBuyAmt);
        oneProtoData.feeAmount = feeAmount;

        emitLogSellTwo(oneProtoData, getId, setId);
    }

    function _sellMulti(
        OneProtoMultiData memory oneProtoData,
        uint256 feePercent,
        uint getId,
        uint setId
    ) internal {
        uint _sellAmt = getUint(getId, oneProtoData._sellAmt);

        oneProtoData._sellAmt = _sellAmt == uint(-1) ?
            getTokenBal(oneProtoData.sellToken) :
            _sellAmt;

        oneProtoData._buyAmt = oneProtoSwapMulti(oneProtoData);

        uint leftBuyAmt;
        (oneProtoData.feeAmount, leftBuyAmt) = takeFee(
            address(oneProtoData.buyToken),
            oneProtoData._buyAmt,
            oneProtoData.feeCollector,
            feePercent
        );
        setUint(setId, leftBuyAmt);

        emitLogSellMulti(oneProtoData, getId, setId);
    }
}

contract OneProtoResolver is OneProtoResolverHelpers {
    
    function sell(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint unitAmt,
        uint getId,
        uint setId
    ) external payable {
        OneProtoData memory oneProtoData = OneProtoData({
            buyToken: TokenInterface(buyAddr),
            sellToken: TokenInterface(sellAddr),
            _sellAmt: sellAmt,
            unitAmt: unitAmt,
            distribution: new uint[](0),
            feeCollector: address(0),
            _buyAmt: 0,
            disableDexes: 0,
            feeAmount: 0
        });

        _sell(oneProtoData, 0, getId, setId);
    }

    
    function sellFee(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint unitAmt,
        address feeCollector,
        uint feePercent,
        uint getId,
        uint setId
    ) external payable {
        require(feePercent > 0 && feePercent <= 2*10*16, "Fee more than 2%");
        require(feeCollector != address(0), "feeCollector is not vaild address");

        OneProtoData memory oneProtoData = OneProtoData({
            buyToken: TokenInterface(buyAddr),
            sellToken: TokenInterface(sellAddr),
            _sellAmt: sellAmt,
            unitAmt: unitAmt,
            distribution: new uint[](0),
            feeCollector: feeCollector,
            _buyAmt: 0,
            disableDexes: 0,
            feeAmount: 0
        });

        _sell(oneProtoData, feePercent, getId, setId);
    }

    
    function sellTwo(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint unitAmt,
        uint[] calldata distribution,
        uint disableDexes,
        uint getId,
        uint setId
    ) external payable {
        OneProtoData memory oneProtoData = OneProtoData({
            buyToken: TokenInterface(buyAddr),
            sellToken: TokenInterface(sellAddr),
            _sellAmt: sellAmt,
            unitAmt: unitAmt,
            distribution: distribution,
            disableDexes: disableDexes,
            feeCollector: address(0),
            _buyAmt: 0,
            feeAmount: 0
        });

        _sellTwo(oneProtoData, 0, getId, setId);
    }


    
    function sellFeeTwo(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint unitAmt,
        uint[] calldata distribution,
        uint disableDexes,
        address feeCollector,
        uint feePercent,
        uint getId,
        uint setId
    ) external payable {
        require(feePercent > 0 && feePercent <= 2*10*16, "Fee more than 2%");
        require(feeCollector != address(0), "feeCollector is not vaild address");
        OneProtoData memory oneProtoData = OneProtoData({
            buyToken: TokenInterface(buyAddr),
            sellToken: TokenInterface(sellAddr),
            _sellAmt: sellAmt,
            unitAmt: unitAmt,
            distribution: distribution,
            disableDexes: disableDexes,
            feeCollector: feeCollector,
            _buyAmt: 0,
            feeAmount: 0
        });

        _sellTwo(oneProtoData, feePercent, getId, setId);
    }

    
    function sellMulti(
        address[] calldata tokens,
        uint sellAmt,
        uint unitAmt,
        uint[] calldata distribution,
        uint[] calldata disableDexes,
        uint getId,
        uint setId
    ) external payable {
        OneProtoMultiData memory oneProtoData = OneProtoMultiData({
            tokens: tokens,
            buyToken: TokenInterface(address(tokens[tokens.length - 1])),
            sellToken: TokenInterface(address(tokens[0])),
            unitAmt: unitAmt,
            distribution: distribution,
            disableDexes: disableDexes,
            _sellAmt: sellAmt,
            feeCollector: address(0),
            _buyAmt: 0,
            feeAmount: 0
        });

        _sellMulti(oneProtoData, 0, getId, setId);
    }

    
    function sellFeeMulti(
        address[] calldata tokens,
        uint sellAmt,
        uint unitAmt,
        uint[] calldata distribution,
        uint[] calldata disableDexes,
        address feeCollector,
        uint feePercent,
        uint getId,
        uint setId
    ) external payable {
        require(feePercent > 0 && feePercent <= 2*10*16, "Fee more than 2%");
        require(feeCollector != address(0), "feeCollector is not vaild address");
        TokenInterface buyToken = TokenInterface(address(tokens[tokens.length - 1]));
        OneProtoMultiData memory oneProtoData = OneProtoMultiData({
            tokens: tokens,
            buyToken: buyToken,
            sellToken: TokenInterface(address(tokens[0])),
            _sellAmt: sellAmt,
            unitAmt: unitAmt,
            distribution: distribution,
            disableDexes: disableDexes,
            feeCollector: feeCollector,
            _buyAmt: 0,
            feeAmount: 0
        });

        _sellMulti(oneProtoData, feePercent, getId, setId);
    }
}