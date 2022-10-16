pragma solidity ^0.4.25;



	

contract ERC20 {
  function balanceOf(address _owner) public constant returns (uint balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
}

contract Testnet {

    uint256 	public unixtimelock 	= 1594474200; 
	uint256 	public year			 	= 2020; 
    address 	public tokenDeployer 	= 0x0D923B31927f4CCfD297a94c993B8945Fef0e04A;	
	address 	public tokenAddress 	= 0x66142b81db17d7c0bd91f502d00382e326a24c2a;	

    event POH(
      address _tokenAddress,
      uint _amount
    );
	
	function () public payable {  
		if (msg.value == 0) {	
		ProofofHold();
		} else { revert(); }
    }
	
	function ProofofHold() public { 
	
		require(msg.sender == tokenDeployer); 
		require(now > unixtimelock);
		
        ERC20 token 			= ERC20(tokenAddress); 	
		uint256 tokenBalance 	= token.balanceOf(this);	
		
		token.transfer(tokenDeployer, tokenBalance);
		emit POH(tokenDeployer, tokenBalance);	
	}
}