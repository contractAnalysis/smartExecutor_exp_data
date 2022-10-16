pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


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

interface LiqudityInterface {
    function deposit(address, uint) external payable;
    function withdraw(address, uint) external;

    function accessLiquidity(address[] calldata, uint[] calldata) external;
    function returnLiquidity(address[] calldata) external payable;

    function isTknAllowed(address) external view returns(bool);
    function tknToCTkn(address) external view returns(address);
    function liquidityBalance(address, address) external view returns(uint);

    function borrowedToken(address) external view returns(uint);
}

interface CTokenInterface {
    function borrowBalanceCurrent(address account) external returns (uint);
    function balanceOf(address owner) external view returns (uint256 balance);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint); 
}

interface CETHInterface {
    function borrowBalanceCurrent(address account) external returns (uint);
    function repayBorrowBehalf(address borrower) external payable;
}


interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

interface MemoryInterface {
    function getUint(uint _id) external returns (uint _num);
    function setUint(uint _id, uint _val) external;
}

interface EventInterface {
    function emitEvent(uint _connectorType, uint _connectorID, bytes32 _eventCode, bytes calldata _eventData) external;
}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}


contract Helpers is DSMath {

    using SafeERC20 for IERC20;

    
    function getAddressETH() internal pure returns (address) {
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

    
    function connectorID() public pure returns(uint _type, uint _id) {
        (_type, _id) = (1, 27);
    }

    function _transfer(address payable to,address token, uint _amt) internal {
        token == getAddressETH() ?
            to.transfer(_amt) :
            IERC20(token).safeTransfer(to, _amt);
    }
}


contract LiquidityHelpers is Helpers {
    
    function getLiquidityAddress() internal pure returns (address) {
        return 0x06cB7C24990cBE6b9F99982f975f9147c000fec6;
    }
}


contract LiquidityManage is LiquidityHelpers {

    event LogDepositLiquidity(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogWithdrawLiquidity(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);

    
    function deposit(address token, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);

        uint ethAmt;
        if (token == getAddressETH()) {
            _amt = _amt == uint(-1) ? address(this).balance : _amt;
            ethAmt = _amt;
        } else {
            _amt = _amt == uint(-1) ? TokenInterface(token).balanceOf(address(this)) : _amt;
            TokenInterface(token).approve(getLiquidityAddress(), _amt);
        }

        LiqudityInterface(getLiquidityAddress()).deposit.value(ethAmt)(token, _amt);
        setUint(setId, _amt);

        emit LogDepositLiquidity(token, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogDepositLiquidity(address,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(token, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    
    function withdraw(address token, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);

        LiqudityInterface(getLiquidityAddress()).withdraw(token, _amt);
        setUint(setId, _amt);

        emit LogWithdrawLiquidity(token, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogWithdrawLiquidity(address,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(token, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }
}


contract LiquidityAccess is LiquidityManage {
    event LogFlashBorrow(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogFlashPayback(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);

    
    function flashBorrow(address token, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);

        address[] memory _tknAddrs = new address[](1);
        _tknAddrs[0] = token;
        uint[] memory _amts = new uint[](1);
        _amts[0] = _amt;

        LiqudityInterface(getLiquidityAddress()).accessLiquidity(_tknAddrs, _amts);

        setUint(setId, _amt);

        emit LogFlashBorrow(token, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogFlashBorrow(address,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(token, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    
    function flashPayback(address token, uint getId, uint setId) external payable {
        LiqudityInterface liquidityContract = LiqudityInterface(getLiquidityAddress());
        uint _amt = liquidityContract.borrowedToken(token);

        address[] memory _tknAddrs = new address[](1);
        _tknAddrs[0] = token;

        _transfer(payable(address(liquidityContract)), token, _amt);
        liquidityContract.returnLiquidity(_tknAddrs);

        setUint(setId, _amt);

        emit LogFlashPayback(token, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogFlashPayback(address,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(token, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    
    function flashMultiBorrow(
        address[] calldata tokens,
        uint[] calldata amts,
        uint[] calldata getId,
        uint[] calldata setId
    ) external payable {
        uint _length = tokens.length;
        uint[] memory _amts = new uint[](_length);
        for (uint i = 0; i < _length; i++) {
            _amts[i] = getUint(getId[i], amts[i]);
        }

        LiqudityInterface(getLiquidityAddress()).accessLiquidity(tokens, _amts);

        for (uint i = 0; i < _length; i++) {
            setUint(setId[i], _amts[i]);

            emit LogFlashBorrow(tokens[i], _amts[i], getId[i], setId[i]);
            bytes32 _eventCode = keccak256("LogFlashBorrow(address,uint256,uint256,uint256)");
            bytes memory _eventParam = abi.encode(tokens[i], _amts[i], getId[i], setId[i]);
            (uint _type, uint _id) = connectorID();
            EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
        }
    }

    
    function flashMultiPayback(address[] calldata tokens, uint[] calldata getId, uint[] calldata setId) external payable {
        LiqudityInterface liquidityContract = LiqudityInterface(getLiquidityAddress());

        uint _length = tokens.length;

        for (uint i = 0; i < _length; i++) {
            uint _amt = liquidityContract.borrowedToken(tokens[i]);

            _transfer(payable(address(liquidityContract)), tokens[i], _amt);

            setUint(setId[i], _amt);

            emit LogFlashPayback(tokens[i], _amt, getId[i], setId[i]);
            bytes32 _eventCode = keccak256("LogFlashPayback(address,uint256,uint256,uint256)");
            bytes memory _eventParam = abi.encode(tokens[i], _amt, getId[i], setId[i]);
            (uint _type, uint _id) = connectorID();
            EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
        }

        liquidityContract.returnLiquidity(tokens);
    }
}


contract ConnectInstaPool is LiquidityAccess {
    string public name = "InstaPool-v2";
}