pragma solidity ^0.5.8;


contract IsContract {
    
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}






pragma solidity ^0.5.8;



contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}






pragma solidity ^0.5.8;



library SafeERC20 {
    
    
    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    
    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {
        bytes memory transferCallData = abi.encodeWithSelector(
            TRANSFER_SELECTOR,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferCallData);
    }

    
    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {
        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferFromCallData);
    }

    
    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {
        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), approveCallData);
    }

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata) private returns (bool) {
        bool ret;
        assembly {
            let ptr := mload(0x40)    

            let success := call(
                gas,                  
                _addr,                
                0,                    
                add(_calldata, 0x20), 
                mload(_calldata),     
                ptr,                  
                0x20                  
            )

            if gt(success, 0) {
            
                switch returndatasize

                
                case 0 {
                    ret := 1
                }

                
                case 0x20 {
                
                
                    ret := eq(mload(ptr), 1)
                }

                
                default { }
            }
        }
        return ret;
    }
}



pragma solidity ^0.5.8;



interface ERC900 {
    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    
    function stake(uint256 _amount, bytes calldata _data) external;

    
    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external;

    
    function unstake(uint256 _amount, bytes calldata _data) external;

    
    function totalStakedFor(address _addr) external view returns (uint256);

    
    function totalStaked() external view returns (uint256);

    
    function token() external view returns (address);

    
    function supportsHistory() external pure returns (bool);
}



pragma solidity ^0.5.0;

interface IUniswapExchange {
  event TokenPurchase(address indexed buyer, uint256 indexed eth_sold, uint256 indexed tokens_bought);
  event EthPurchase(address indexed buyer, uint256 indexed tokens_sold, uint256 indexed eth_bought);
  event AddLiquidity(address indexed provider, uint256 indexed eth_amount, uint256 indexed token_amount);
  event RemoveLiquidity(address indexed provider, uint256 indexed eth_amount, uint256 indexed token_amount);

   
  function () external payable;

 
  function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);

 
  function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);


   
  function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256);

  
  function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns(uint256);


  
  function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns(uint256);
  
  function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256);

  
  function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256);

  
  function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256);

  
  function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256);

  
  function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256);

  
  function tokenToTokenSwapInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_eth_bought, 
    uint256 deadline, 
    address token_addr) 
    external returns (uint256);

  
  function tokenToTokenTransferInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_eth_bought, 
    uint256 deadline, 
    address recipient, 
    address token_addr) 
    external returns (uint256);


  
  function tokenToTokenSwapOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_eth_sold, 
    uint256 deadline, 
    address token_addr) 
    external returns (uint256);

  
  function tokenToTokenTransferOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_eth_sold, 
    uint256 deadline, 
    address recipient, 
    address token_addr) 
    external returns (uint256);

  
  function tokenToExchangeSwapInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_eth_bought, 
    uint256 deadline, 
    address exchange_addr) 
    external returns (uint256);

  
  function tokenToExchangeTransferInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_eth_bought, 
    uint256 deadline, 
    address recipient, 
    address exchange_addr) 
    external returns (uint256);

  
  function tokenToExchangeSwapOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_eth_sold, 
    uint256 deadline, 
    address exchange_addr) 
    external returns (uint256);

  
  function tokenToExchangeTransferOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_eth_sold, 
    uint256 deadline, 
    address recipient, 
    address exchange_addr) 
    external returns (uint256);


  

  
  function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256);

  
  function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256);

  
  function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256);

  
  function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256);

  
  function tokenAddress() external view returns (address);

  
  function factoryAddress() external view returns (address);


  

  
  function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

  
  function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
}



pragma solidity ^0.5.0;

interface IUniswapFactory {
  event NewExchange(address indexed token, address indexed exchange);

  function initializeFactory(address template) external;
  function createExchange(address token) external returns (address payable);
  function getExchange(address token) external view returns (address payable);
  function getToken(address token) external view returns (address);
  function getTokenWihId(uint256 token_id) external view returns (address);
}



pragma solidity ^0.5.8;




contract Refundable {
    using SafeERC20 for ERC20;

    string private constant ERROR_NOT_GOVERNOR = "REF_NOT_GOVERNOR";
    string private constant ERROR_ZERO_AMOUNT = "REF_ZERO_AMOUNT";
    string private constant ERROR_NOT_ENOUGH_BALANCE = "REF_NOT_ENOUGH_BALANCE";
    string private constant ERROR_ETH_REFUND = "REF_ETH_REFUND";
    string private constant ERROR_TOKEN_REFUND = "REF_TOKEN_REFUND";

    address public governor;

    modifier onlyGovernor() {
        require(msg.sender == governor, ERROR_NOT_GOVERNOR);
        _;
    }

    constructor(address _governor) public {
        governor = _governor;
    }

    
    function refundEth(address payable _recipient, uint256 _amount) external onlyGovernor {
        require(_amount > 0, ERROR_ZERO_AMOUNT);
        uint256 selfBalance = address(this).balance;
        require(selfBalance >= _amount, ERROR_NOT_ENOUGH_BALANCE);

        
        (bool result,) = _recipient.call.value(_amount)("");
        require(result, ERROR_ETH_REFUND);
    }

    /**
    * @notice Refunds accidentally sent ERC20 tokens. Only governor can do it
    * @param _token Token to be refunded
    * @param _recipient Address to send funds to
    * @param _amount Amount to be refunded
    */
    function refundToken(ERC20 _token, address _recipient, uint256 _amount) external onlyGovernor {
        require(_amount > 0, ERROR_ZERO_AMOUNT);
        uint256 selfBalance = _token.balanceOf(address(this));
        require(selfBalance >= _amount, ERROR_NOT_ENOUGH_BALANCE);

        require(_token.safeTransfer(_recipient, _amount), ERROR_TOKEN_REFUND);
    }
}

// File: contracts/UniswapWrapper.sol

pragma solidity ^0.5.8;









contract UniswapWrapper is Refundable, IsContract {
    using SafeERC20 for ERC20;

    string private constant ERROR_TOKEN_NOT_CONTRACT = "UW_TOKEN_NOT_CONTRACT";
    string private constant ERROR_REGISTRY_NOT_CONTRACT = "UW_REGISTRY_NOT_CONTRACT";
    string private constant ERROR_UNISWAP_FACTORY_NOT_CONTRACT = "UW_UNISWAP_FACTORY_NOT_CONTRACT";
    string private constant ERROR_RECEIVED_WRONG_TOKEN = "UW_RECEIVED_WRONG_TOKEN";
    string private constant ERROR_WRONG_DATA_LENGTH = "UW_WRONG_DATA_LENGTH";
    string private constant ERROR_ZERO_AMOUNT = "UW_ZERO_AMOUNT";
    string private constant ERROR_TOKEN_TRANSFER_FAILED = "UW_TOKEN_TRANSFER_FAILED";
    string private constant ERROR_TOKEN_APPROVAL_FAILED = "UW_TOKEN_APPROVAL_FAILED";
    string private constant ERROR_UNISWAP_UNAVAILABLE = "UW_UNISWAP_UNAVAILABLE";

    bytes32 internal constant ACTIVATE_DATA = keccak256("activate(uint256)");

    ERC20 public bondedToken;
    ERC900 public registry;
    IUniswapFactory public uniswapFactory;

    constructor(address _governor, ERC20 _bondedToken, ERC900 _registry, IUniswapFactory _uniswapFactory) Refundable(_governor) public {
        require(isContract(address(_bondedToken)), ERROR_TOKEN_NOT_CONTRACT);
        require(isContract(address(_registry)), ERROR_REGISTRY_NOT_CONTRACT);
        require(isContract(address(_uniswapFactory)), ERROR_UNISWAP_FACTORY_NOT_CONTRACT);

        bondedToken = _bondedToken;
        registry = _registry;
        uniswapFactory = _uniswapFactory;
    }

    
    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external {
        require(_token == msg.sender, ERROR_RECEIVED_WRONG_TOKEN);
        
        require(_data.length == 128, ERROR_WRONG_DATA_LENGTH);

        bool activate;
        uint256 minTokens;
        uint256 minEth;
        uint256 deadline;
        bytes memory data = _data;
        assembly {
            activate := mload(add(data, 0x20))
            minTokens := mload(add(data, 0x40))
            minEth := mload(add(data, 0x60))
            deadline := mload(add(data, 0x80))
        }

        _contributeExternalToken(_from, _amount, _token, minTokens, minEth, deadline, activate);
    }

    
    function contributeExternalToken(
        uint256 _amount,
        address _token,
        uint256 _minTokens,
        uint256 _minEth,
        uint256 _deadline,
        bool _activate
    )
        external
    {
        _contributeExternalToken(msg.sender, _amount, _token, _minTokens, _minEth, _deadline, _activate);
    }

    
    function contributeEth(uint256 _minTokens, uint256 _deadline, bool _activate) external payable {
        require(msg.value > 0, ERROR_ZERO_AMOUNT);

        
        address payable uniswapExchangeAddress = uniswapFactory.getExchange(address(bondedToken));
        require(uniswapExchangeAddress != address(0), ERROR_UNISWAP_UNAVAILABLE);
        IUniswapExchange uniswapExchange = IUniswapExchange(uniswapExchangeAddress);

        
        uint256 bondedTokenAmount = uniswapExchange.ethToTokenSwapInput.value(msg.value)(_minTokens, _deadline);

        
        _stakeAndActivate(msg.sender, bondedTokenAmount, _activate);
    }

    function _contributeExternalToken(
        address _from,
        uint256 _amount,
        address _token,
        uint256 _minTokens,
        uint256 _minEth,
        uint256 _deadline,
        bool _activate
    )
        internal
    {
        require(_amount > 0, ERROR_ZERO_AMOUNT);

        
        ERC20 token = ERC20(_token);
        require(token.safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_TRANSFER_FAILED);

        
        address payable uniswapExchangeAddress = uniswapFactory.getExchange(_token);
        require(uniswapExchangeAddress != address(0), ERROR_UNISWAP_UNAVAILABLE);
        IUniswapExchange uniswapExchange = IUniswapExchange(uniswapExchangeAddress);

        require(token.safeApprove(address(uniswapExchange), _amount), ERROR_TOKEN_APPROVAL_FAILED);

        
        uint256 bondedTokenAmount = uniswapExchange.tokenToTokenSwapInput(_amount, _minTokens, _minEth, _deadline, address(bondedToken));

        
        _stakeAndActivate(_from, bondedTokenAmount, _activate);
    }

    function _stakeAndActivate(address _from, uint256 _amount, bool _activate) internal {
        
        bondedToken.approve(address(registry), _amount);
        bytes memory data;
        if (_activate) {
            data = abi.encodePacked(ACTIVATE_DATA);
        }
        registry.stakeFor(_from, _amount, data);
    }
}