pragma solidity ^0.6.2;

contract Savings {
	mapping(address => mapping(address => uint256)) private balances;
	mapping(address => mapping(address => uint)) private experations;


    
    
	function deposit(address _tokenAddress, uint256 _amount, uint _duration) public returns (bool success) {


		
		require(balances[msg.sender][_tokenAddress] == 0, "You can't have two pending pools with the same currency");

		
		require(ERC20Interface(_tokenAddress).allowance(msg.sender,address(this)) >= _amount, "Allowance is too low for this transaction");

		
		require(ERC20Interface(_tokenAddress).balanceOf(msg.sender) >= _amount,"Wallet balance is too low for this transaction");


		
		

		
		require(ERC20Interface(_tokenAddress).transferFrom(msg.sender,address(this),_amount));

		
		uint experation = block.number + _duration;
		assert(experation > block.number);

		balances[msg.sender][_tokenAddress] = _amount;
		experations[msg.sender][_tokenAddress] = experation;

		return true;
	}

	function withdraw(address _tokenAddress) public returns (bool success) {
		
		require(balances[msg.sender][_tokenAddress] > 0, "Sender does not own any of specified token in Savings contract");

		
		require(experations[msg.sender][_tokenAddress] <= block.number, "The term has not ended yet");

		
		uint256 withdrawalAmount = balances[msg.sender][_tokenAddress];

		
		balances[msg.sender][_tokenAddress] = 0;

		
		require(ERC20Interface(_tokenAddress).transfer(msg.sender,withdrawalAmount));

		return true;
	}
}



interface ERC20Interface {
	function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
}