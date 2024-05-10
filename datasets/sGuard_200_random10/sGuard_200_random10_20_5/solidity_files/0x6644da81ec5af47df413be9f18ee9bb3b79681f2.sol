pragma solidity ^0.6.0;

contract Interoperability {

	
	address constant private PROPOSAL = 0x5d8617E6CcDe987d05018550DD817A24B11Bec4F;
	
	
	address constant private TOKEN = 0x44b6e3e85561ce054aB13Affa0773358D795D36D;
	
	
	uint256 constant private VOTE = 910000000000000000000000;
	
	
	address constant private WALLET = 0x2BbBC1238b567F240A915451bE0D8c210895aa95;
	
    function callOneTime(address proposal) public {

		
		IMVDProxy(msg.sender).transfer(address(this), VOTE, TOKEN);

		
		IMVDFunctionalityProposal(PROPOSAL).accept(VOTE);
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