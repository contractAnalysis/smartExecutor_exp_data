pragma solidity 0.5.16;


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


contract BlockbirdLock {

  
  IERC20 lockContract;

  
  struct Lock {
    uint256 amount;
    uint256 duration;
  }

  
  mapping(address => Lock) public lockedTokens;

  
  constructor(address lockContractAddress) public {
    lockContract = IERC20(lockContractAddress);
  }

  
  function lock(
    address recipient,
    uint256 amount,
    uint256 duration
  )
    external
  {
    require(lockedTokens[recipient].amount == 0, 'BlockbirdLock: Tokens for this recipent already locked.');
    lockedTokens[recipient] = Lock({ amount: amount, duration: duration });
    lockContract.transferFrom(msg.sender, address(this), amount);
  }

  
  function withdraw()
    external
  {
    require(lockedTokens[msg.sender].duration < now, 'BlockbirdLock: Lock time has not yet passed.');
    uint256 amount = lockedTokens[msg.sender].amount;
    delete lockedTokens[msg.sender];
    lockContract.transfer(msg.sender, amount);
  }

}