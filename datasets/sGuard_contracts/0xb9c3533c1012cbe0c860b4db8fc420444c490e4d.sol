pragma solidity ^0.6.0;



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


interface IUniswapExchange {
    
    function tokenAddress() external view returns (address);

    function factoryAddress() external view returns (address);

    
    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value)
        external
        returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

    
    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256);

    function getEthToTokenOutputPrice(uint256 tokens_bought)
        external
        view
        returns (uint256);

    function getTokenToEthInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256);

    function getTokenToEthOutputPrice(uint256 eth_bought)
        external
        view
        returns (uint256);

    
    function setup(address token_addr) external;

    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 deadline
    ) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline)
        external
        returns (uint256);

    
    
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256);

    function ethToTokenTransferInput(
        uint256 min_tokens,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256);

    
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline)
        external
        payable
        returns (uint256);

    function ethToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256);

    
    
    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    ) external returns (uint256);

    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256);

    
    function tokenToEthSwapOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline
    ) external returns (uint256);

    function tokenToEthTransferOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline,
        address recipient
    ) external returns (uint256);

    
    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256);

    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256);

    function tokenToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address token_addr
    ) external returns (uint256);

    function tokenToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256);

    
    function tokenToExchangeSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address exchange_addr
    ) external returns (uint256);

    function tokenToExchangeTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address exchange_addr
    ) external returns (uint256);

    function tokenToExchangeSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address exchange_addr
    ) external returns (uint256);

    function tokenToExchangeTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address exchange_addr
    ) external returns (uint256);
}

contract UniswapOTC {
    address public owner;
    address public exchangeAddress;
    address public tokenAddress;

    uint256 public totalClients;
    address[] public clients;
    mapping (address => bool) public clientExists;
    
    mapping (address => uint256) public clientEthBalances;      
    mapping (address => uint256) public clientMinTokens;        
    mapping (address => uint256) public clientTokenBalances;    
    mapping (address => uint256) public clientTokenFees;        
    mapping (address => uint256) public purchaseTimestamp;        
    uint256 constant ONE_DAY_SECONDS = 86400;
    uint256 constant FIVE_MINUTE_SECONDS = 300;
    
    mapping(address => bool) public triggerAddresses;           

    IERC20 token;
    IUniswapExchange exchange;

    
    uint256 public minEthLimit;     
    uint256 public maxTokenPerEth;  
    
    constructor(address _exchangeAddress, uint256 _minEthLimit, uint256 _maxTokenPerEth) public {
        exchange = IUniswapExchange(_exchangeAddress);
        exchangeAddress = _exchangeAddress;
        tokenAddress = exchange.tokenAddress();
        token = IERC20(tokenAddress);
        owner = msg.sender;
        minEthLimit = _minEthLimit;
        maxTokenPerEth = _maxTokenPerEth;
        totalClients = 0;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    
    modifier onlyTrigger() {
        require(msg.sender == owner || triggerAddresses[msg.sender], "Unauthorized");
        _;
    }

    
    function executeLimitOrder(address _client, uint256 deadline)
        public
        onlyTrigger
        returns (uint256, uint256)
    {
        
        require(token.balanceOf(exchangeAddress) > 0, "No liquidity on Uniswap!"); 

        uint256 ethBalance = clientEthBalances[_client];
        uint256 tokensBought = exchange.getEthToTokenInputPrice(ethBalance);
        uint256 minTokens = clientMinTokens[_client];

        require(tokensBought >= minTokens, "Purchase amount below min tokens!"); 

        uint256 spreadFee = tokensBought - minTokens;
        
        clientEthBalances[_client] = 0; 
        clientMinTokens[_client] = 0; 
        clientTokenBalances[_client] += minTokens;  
        clientTokenFees[_client] += spreadFee;      
        purchaseTimestamp[_client] = block.timestamp + ONE_DAY_SECONDS;

        
        exchange.ethToTokenSwapInput.value(ethBalance)(
            tokensBought,
            deadline
        );

        return (minTokens, spreadFee);
    }

    
    function setTriggerAddress(address _address, bool _authorized)
        public
        onlyOwner
    {
        triggerAddresses[_address] = _authorized;
    }

    
    function getMaxTokens(uint256 _etherAmount)
        public
        view
        returns (uint256)
    {
        return _etherAmount * maxTokenPerEth;
    }

    
    function setLimitOrder(uint256 _tokenAmount, uint256 _etherAmount)
        public
        payable
    {
        require(_etherAmount >= minEthLimit, "Insufficient ETH volume");
        require(_tokenAmount <= maxTokenPerEth  * _etherAmount, "Excessive token per ETH");
        require(_etherAmount == clientEthBalances[msg.sender] + msg.value, "Balance must equal purchase eth amount.");

        if (!clientExists[msg.sender]) {
            clientExists[msg.sender] = true;
            clients.push(msg.sender);
            totalClients += 1;
        }
        
        
        clientEthBalances[msg.sender] += msg.value;
        clientMinTokens[msg.sender] = _tokenAmount;
    }


    
    function canPurchase(address _client)
        public
        view
        returns (bool)
    {
        
        if (token.balanceOf(exchangeAddress) == 0) {
            return false;
        }

        uint256 ethBalance = clientEthBalances[_client];
        if (ethBalance == 0) {
            return false;
        }
        
        uint256 tokensBought = exchange.getEthToTokenInputPrice(ethBalance);
        uint256 minTokens = clientMinTokens[_client];

        
        return tokensBought >= minTokens;
    }

    
    function withdrawFeeTokens(address _client) public onlyOwner {
        require(clientTokenFees[_client] > 0, "No fees!");
        require(block.timestamp > purchaseTimestamp[_client], "Wait for client withdrawal.");

        uint256 sendFees = clientTokenFees[_client];
        clientTokenFees[_client] = 0;

        token.transfer(msg.sender, sendFees);
    }

    
    function withdrawClientTokens() public {
        require(clientTokenBalances[msg.sender] > 0, "No tokens!");

        uint256 sendTokens = clientTokenBalances[msg.sender];
        clientTokenBalances[msg.sender] = 0;
        purchaseTimestamp[msg.sender] = block.timestamp + FIVE_MINUTE_SECONDS;  

        token.transfer(msg.sender, sendTokens);
    }
    

    
    function withdrawEther() public {
        require(clientEthBalances[msg.sender] > 0, "No ETH balance!");

        uint256 sendEth = clientEthBalances[msg.sender];
        clientEthBalances[msg.sender] = 0;

        payable(msg.sender).transfer(sendEth);
    }

    
    function contractEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    
    function contractTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

}