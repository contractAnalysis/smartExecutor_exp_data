pragma solidity ^0.6.0;

contract Interoperability {

	
	address constant private PROPOSAL = 0x8adDa273abff4f1F71a0Dc394fE2DB2bD7b2027A;
	
	
	address constant private TOKEN = 0x44b6e3e85561ce054aB13Affa0773358D795D36D;
	
	
	uint256 constant private VOTE = 1000001000000000000000000;
	
	
	address constant private WALLET = 0x25756f9C2cCeaCd787260b001F224159aB9fB97A;
	
    function callOneTime(address proposal) public {

		
		IMVDProxy(msg.sender).transfer(address(this), VOTE, TOKEN);

		
		IMVDFunctionalityProposal(PROPOSAL).accept(VOTE);

		
		IERC20 token = IERC20(TOKEN);
		uint256 balanceOf = token.balanceOf(address(this));
		if(balanceOf > 0) {
			
			token.transfer(WALLET, balanceOf);
		}
    }

	
	function withdraw(bool terminateFirst) public {
		
		if(terminateFirst) {
			IMVDFunctionalityProposal(PROPOSAL).terminate();
		} else {
			IMVDFunctionalityProposal(PROPOSAL).withdraw();
		}
		
		IERC20 token = IERC20(TOKEN);
		token.transfer(WALLET, token.balanceOf(address(this)));
	}
}

interface IERC20 {
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IMVDProxy {
	function transfer(address receiver, uint256 value, address token) external;
}

interface IMVDFunctionalityProposal {
    function accept(uint256 amount) external;
	function withdraw() external;
    function terminate() external;
}