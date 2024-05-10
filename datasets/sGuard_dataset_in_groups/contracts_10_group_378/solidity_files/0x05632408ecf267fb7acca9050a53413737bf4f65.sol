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

contract KyberNetworkProxyInterface {
  function maxGasPrice() public view returns(uint);
  function getUserCapInWei(address user) public view returns(uint);
  function getUserCapInTokenWei(address user, IERC20 token) public view returns(uint);
  function enabled() public view returns(bool);
  function info(bytes32 id) public view returns(uint);

  function getExpectedRate(IERC20 src, IERC20 dest, uint srcQty) public view returns (uint expectedRate, uint slippageRate);

  function tradeWithHint(IERC20 src, uint srcAmount, IERC20 dest, address payable destAddress, uint maxDestAmount, uint minConversionRate, address walletId, bytes memory hint) public payable returns (uint);
}


contract IERC721Receiver {
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}


interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) public view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) public view returns (address owner);

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

contract KyberNetworkWrapper is IERC721Receiver {

    event TokenChange(address token, uint change);
    event ETHReceived(address indexed sender, uint amount);

    IERC20 constant internal ETH_TOKEN_ADDRESS = IERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    function() payable external {
        emit ETHReceived(msg.sender, msg.value);
    }

    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function tradeAndBuy(
        IERC721 nft,
        uint nftId,
        bytes memory buyData,
        uint price,
        KyberNetworkProxyInterface _kyberProxy,
        address sale,
        IERC20 token,
        uint tokenQty,
        uint minRate
    ) public {
        uint startTokenBalance = token.balanceOf(address(this));
        require(token.transferFrom(msg.sender, address(this), tokenQty));
        require(token.approve(address(_kyberProxy), tokenQty));
        uint userETH = _kyberProxy.tradeWithHint(token, tokenQty, ETH_TOKEN_ADDRESS, address(uint160(address(this))), price, minRate, address(0x0), "");
        require(userETH >= price, "not enough eth to buy nft");

        (bool success,) = sale.call.value(price)(buyData);
        require(success, "buy error");
        nft.transferFrom(address(this), msg.sender, nftId);

        if (userETH > price) {
            msg.sender.transfer(userETH - price);
            emit TokenChange(address(ETH_TOKEN_ADDRESS), userETH - price);
        }
        uint endTokenBalance = token.balanceOf(address(this));
        if (endTokenBalance > startTokenBalance) {
            token.transfer(msg.sender, endTokenBalance - startTokenBalance);
            emit TokenChange(address(token), endTokenBalance - startTokenBalance);
        }
    }
}