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

interface UniswapFactoryInterface {
    function getExchange(address token) external view returns (address exchange);
}

interface UniswapExchangeInterface {
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
}

interface uniswapPoolZap {
    function LetsInvest(address _TokenContractAddress, address _towhomtoissue) external payable returns (uint256);
}


contract MultiPoolZapV1_4 is Ownable {
    using SafeMath for uint;

    uniswapPoolZap public uniswapPoolZapAddress;
    UniswapFactoryInterface public UniswapFactory;
    uint16 public goodwill;
    address payable public dzgoodwillAddress;
    mapping(address => uint256) private userBalance;

    constructor(uint16 _goodwill, address payable _dzgoodwillAddress) public {
        goodwill = _goodwill;
        dzgoodwillAddress = _dzgoodwillAddress;
        uniswapPoolZapAddress = uniswapPoolZap(0x97402249515994Cc0D22092D3375033Ad0ea438A);
        UniswapFactory = UniswapFactoryInterface(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill > 0 && _new_goodwill < 10000,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_new_dzgoodwillAddress(address payable _new_dzgoodwillAddress)
        public
        onlyOwner
    {
        dzgoodwillAddress = _new_dzgoodwillAddress;
    }

    function set_uniswapPoolZapAddress(address _uniswapPoolZapAddress) onlyOwner public {
        uniswapPoolZapAddress = uniswapPoolZap(_uniswapPoolZapAddress);
    }

    function set_UniswapFactory(address _UniswapFactory) onlyOwner public {
        UniswapFactory = UniswapFactoryInterface(_UniswapFactory);
    }

    
    function multipleZapIn(address _IncomingTokenContractAddress, uint256 _IncomingTokenQty, address[] memory underlyingTokenAddresses, uint256[] memory respectiveWeightedValues) public payable {

        uint totalWeights;
        require(underlyingTokenAddresses.length == respectiveWeightedValues.length);
        for(uint i=0;i<underlyingTokenAddresses.length;i++) {
            totalWeights = (totalWeights).add(respectiveWeightedValues[i]);
        }

        uint256 eth2Trade;

        if (msg.value > 0) {
            require (_IncomingTokenContractAddress == address(0), "Incoming token address should be address(0)");
            eth2Trade = msg.value;
        } else if(_IncomingTokenContractAddress == address(0) && msg.value == 0) {
            revert("Please send ETH along with function call");
        } else if(_IncomingTokenContractAddress != address(0)) {
            require(msg.value == 0, "Cannot send Tokens and ETH at the same time");
            require(
                IERC20(_IncomingTokenContractAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _IncomingTokenQty
                ),
                "Error in transferring ERC20"
            );
            eth2Trade = _token2Eth(
              _IncomingTokenContractAddress,
              _IncomingTokenQty,
              address(this)
            );
        }

        uint goodwillPortion = ((eth2Trade).mul(goodwill)).div(10000);
        uint totalInvestable = (eth2Trade).sub(goodwillPortion);
        uint totalLeftToBeInvested = totalInvestable;

        require(address(dzgoodwillAddress).send(goodwillPortion));

        uint residualETH;
        for (uint i=0;i<underlyingTokenAddresses.length;i++) {
            uint LPT = uniswapPoolZapAddress.LetsInvest.value((((totalInvestable).mul(respectiveWeightedValues[i])).div(totalWeights)+residualETH))(underlyingTokenAddresses[i], address(this));
            IERC20(UniswapFactory.getExchange(address(underlyingTokenAddresses[i]))).transfer(msg.sender, LPT);
            totalLeftToBeInvested = (totalLeftToBeInvested).sub(((totalInvestable).mul(respectiveWeightedValues[i])).div(totalWeights));
            residualETH = (address(this).balance).sub(totalLeftToBeInvested);
        }

        if(address(this).balance >= 250000000000000000){
            totalInvestable = address(this).balance;
            totalLeftToBeInvested = totalInvestable;
            residualETH = 0;
            for (uint i=0;i<underlyingTokenAddresses.length;i++) {
                uint LPT = uniswapPoolZapAddress.LetsInvest.value((((totalInvestable).mul(respectiveWeightedValues[i])).div(totalWeights)+residualETH))(underlyingTokenAddresses[i], address(this));
                IERC20(UniswapFactory.getExchange(address(underlyingTokenAddresses[i]))).transfer(msg.sender, LPT);
                totalLeftToBeInvested = (totalLeftToBeInvested).sub(((totalInvestable).mul(respectiveWeightedValues[i])).div(totalWeights));
                residualETH = (address(this).balance).sub(totalLeftToBeInvested);
            }
        }

        userBalance[msg.sender] = address(this).balance;
        require (send_out_eth(msg.sender));
    }

    
    function _token2Eth(
        address _FromTokenContractAddress,
        uint256 tokens2Trade,
        address _toWhomToIssue
    ) internal returns (uint256 ethBought) {

            UniswapExchangeInterface FromUniSwapExchangeContractAddress
         = UniswapExchangeInterface(
            UniswapFactory.getExchange(_FromTokenContractAddress)
        );

        IERC20(_FromTokenContractAddress).approve(
            address(FromUniSwapExchangeContractAddress),
            tokens2Trade
        );

        ethBought = FromUniSwapExchangeContractAddress.tokenToEthTransferInput(
            tokens2Trade,
            ((FromUniSwapExchangeContractAddress.getTokenToEthInputPrice(tokens2Trade)).mul(99).div(100)),
            SafeMath.add(block.timestamp, 300),
            _toWhomToIssue
        );
        require(ethBought > 0, "Error in swapping Eth: 1");
    }

    
    function send_out_eth(address _towhomtosendtheETH) internal returns (bool) {
        require(userBalance[_towhomtosendtheETH] > 0);
        uint256 amount = userBalance[_towhomtosendtheETH];
        userBalance[_towhomtosendtheETH] = 0;
        (bool success, ) = _towhomtosendtheETH.call.value(amount)("");
        return success;
    }

    
    function() external payable {
    }
}