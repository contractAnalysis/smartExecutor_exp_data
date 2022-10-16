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



contract ERC20Proxy {
  
  event TransferWithReference(
    address tokenAddress,
    address to,
    uint256 amount,
    bytes indexed paymentReference
  );

  
  function()
    external
    payable
  {
    revert("not payable fallback");
  }

  
  function transferFromWithReference(
    address _tokenAddress,
    address _to,
    uint256 _amount,
    bytes calldata _paymentReference
  )
    external 
  {
    IERC20 erc20 = IERC20(_tokenAddress);
    require(erc20.transferFrom(msg.sender, _to, _amount), "transferFrom() failed");
    emit TransferWithReference(
      _tokenAddress,
      _to,
      _amount,
      _paymentReference
    );
  }
}