pragma solidity >=0.5.1;


contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(this));
        owner = newOwner;
    }
}


contract tokenRecipient {
    event receivedEther(address sender, uint amount);
    event receivedTokens(address _from, uint256 _value, address _token, bytes _extraData);

    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public {
        Token t = Token(_token);
        require(t.transferFrom(_from, address(this), _value));
        emit receivedTokens(_from, _value, _token, _extraData);
    }

    function () payable external {
        emit receivedEther(msg.sender, msg.value);
    }
}


contract Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function transfer(address _to, uint256 _value) public returns (bool success);
}



contract MindsyncRewardPool is owned, tokenRecipient {
    Token public tokenAddress;
    bool public initialized = false;

    event Initialized();
    event WithdrawTokens(address destination, uint256 amount);
    event WithdrawAnyTokens(address tokenAddress, address destination, uint256 amount);
    event WithdrawEther(address destination, uint256 amount);


    
    constructor() payable public {
    }


    
    function init(Token _tokenAddress) onlyOwner public {
        require(!initialized);
        initialized = true;
        tokenAddress = _tokenAddress;
        emit Initialized();
    }


    
    function withdrawTokens(
        uint256 amount
    )
        onlyOwner public
    {
        tokenAddress.transfer(msg.sender, amount);
        emit WithdrawTokens(msg.sender, amount);
    }

    
    function withdrawAnyTokens(
        address _tokenAddress,
        uint256 amount
    )
        onlyOwner public
    {
        Token(_tokenAddress).transfer(msg.sender, amount);
        emit WithdrawAnyTokens(_tokenAddress, msg.sender, amount);
    }
    
    
    function withdrawEther(
        uint256 amount
    )
        onlyOwner public
    {
        msg.sender.transfer(amount);
        emit WithdrawEther(msg.sender, amount);
    }
    
}