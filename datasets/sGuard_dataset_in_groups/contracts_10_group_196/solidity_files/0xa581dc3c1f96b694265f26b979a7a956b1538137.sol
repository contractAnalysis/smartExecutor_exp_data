pragma solidity 0.5.12;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface Marmo {
    function signer() external view returns (address _signer);
}

contract ICErc20 {
    address public underlying;
    function mint(uint mintAmount) external returns (uint);
    function isCToken() external returns (bool);
    function exchangeRateCurrent() external returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);
    function redeem(uint amount) external returns (uint);
}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "SafeMath: subtraction overflow");
        c = a - b;
    }

}


library ECDSA {
    
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        
        if (signature.length != 65) {
            return (address(0));
        }

        
        bytes32 r;
        bytes32 s;
        uint8 v;

        
        
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        
        
        
        
        
        
        
        
        
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        
        return ecrecover(hash, v, r, s);
    }

}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
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


contract ReentrancyGuard {
    
    uint256 private _guardCounter;

    constructor () internal {
        
        
        _guardCounter = 1;
    }

    
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract CompoundFeeTransactionManager is Ownable, ReentrancyGuard, DSMath {
    
    IERC20 public token;
    ICErc20 public cToken;

    address public relayer;
    
    event NewRelayer(address _oldRelayer, address _newRelayer);
    event Mint(address indexed _sender, uint256 _value);
    event Redeem(address indexed _sender, uint256 _value);
    
    constructor (address _tokenAddress, address _cTokenAddress, address _relayer) public {
        require(_relayer != address(0));
        relayer = _relayer;
        cToken = ICErc20(_cTokenAddress);
        token = IERC20(_tokenAddress);
        require(cToken.isCToken());
        require(cToken.underlying() == _tokenAddress, "the underlying are different");
        
        token.approve(address(cToken), uint256(-1));
    }
    
    function mint(
        uint256 _value, 
        uint256 _fee, 
        bytes calldata _signature
    ) nonReentrant external {
        require(tx.origin == relayer, "Invalid transaction origin");
        Marmo marmo = Marmo(msg.sender);
        bytes32 hash = keccak256(
            abi.encodePacked(
                msg.sender,
                _value,
                _fee
            )
        );
        require(marmo.signer() == ECDSA.recover(hash, _signature), "Invalid signature");
    
        require(token.transferFrom(msg.sender, relayer, _fee), "the transferFrom method to relayer failed");
        require(token.transferFrom(msg.sender, address(this), _value), "Pull token failed");

        uint preMintBalance = cToken.balanceOf(address(this));
        require(cToken.mint(_value) == 0, "underlying mint failed");
        uint postMintBalance = cToken.balanceOf(address(this));

        uint mintedTokens = sub(postMintBalance, preMintBalance);
        require(cToken.transfer(msg.sender, mintedTokens), "The transfer method failed");
        
        emit Mint(msg.sender, mintedTokens);

    }
    
    function redeem(
        uint256 _value, 
        uint256 _fee, 
        bytes calldata _signature
    ) nonReentrant external {
        require(tx.origin == relayer, "Invalid transaction origin");
        Marmo marmo = Marmo(msg.sender);
        bytes32 hash = keccak256(
            abi.encodePacked(
                msg.sender,
                _value,
                _fee
            )
        );
        require(marmo.signer() == ECDSA.recover(hash, _signature), "Invalid signature");
        
        require(token.transferFrom(msg.sender, relayer, _fee));
    
        uint exchangeRate = cToken.exchangeRateCurrent();
        uint withdrawAmt = wdiv(_value, exchangeRate);
        
        require(cToken.transferFrom(msg.sender, address(this), withdrawAmt), "Pull token failed");
        uint preDaiBalance = token.balanceOf(address(this));
        require(cToken.redeem(withdrawAmt) == 0, "Underlying redeeming failed");
        uint postDaiBalance = token.balanceOf(address(this));

        uint redeemedDai = sub(postDaiBalance, preDaiBalance);

        token.transfer(msg.sender, redeemedDai);
        
        emit Redeem(msg.sender, redeemedDai);
    }
    
    function setRelayer(address _newRelayer) onlyOwner external {
        require(_newRelayer != address(0));
        emit NewRelayer(relayer, _newRelayer);
        relayer = _newRelayer;
    }
     
}