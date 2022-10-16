pragma solidity ^0.5.0;

contract Owned {
	
	address payable public owner;
	
    constructor() public
	{
		owner = msg.sender;
	}
	
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Owner required");
        _;
    }
}



pragma solidity ^0.5.0;


contract Mortal is Owned
{
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}



pragma solidity ^0.5.0;


contract IERC20
{
	function totalSupply() public view returns (uint);
	
	function transfer(address _to, uint _value) public returns (bool success);
	
	function transferFrom(address _from, address _to, uint _value) public returns (bool success);
	
	function balanceOf(address _owner) public view returns (uint balance);
	
	function approve(address _spender, uint _value) public returns (bool success);
	
	function allowance(address _owner, address _spender) public view returns (uint remaining);
	
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed owner, address indexed spender, uint tokens);
}



pragma solidity ^0.5.0;






library SafeMathLib {
	
	using SafeMathLib for uint;
	
	
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, "SafeMathLib.add: required c >= a");
    }
	
	
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "SafeMathLib.sub: required b <= a");
        c = a - b;
    }
	
	
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require((a == 0 || c / a == b), "SafeMathLib.mul: required (a == 0 || c / a == b)");
    }
	
	
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0, "SafeMathLib.div: required b > 0");
        c = a / b;
    }
}



pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

interface OrFeedInterface {
  function getExchangeRate ( string calldata fromSymbol, string calldata  toSymbol, string calldata venue, uint256 amount ) external view returns ( uint256 );
  function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 );
  function getTokenAddress ( string calldata  symbol ) external view returns ( address );
  function getSynthBytes32 ( string calldata  symbol ) external view returns ( bytes32 );
  function getForexAddress ( string calldata symbol ) external view returns ( address );
  
}



pragma solidity ^0.5.0;











contract OrFeedLIVETest is Owned, Mortal, OrFeedInterface
{
	using SafeMathLib for uint;
	
	
	address public orFeedContractAddress;
	OrFeedInterface public orFeed;
	
	uint public oneEthAsWei = 10**18;
	
	
	
	
    
    
    constructor(OrFeedInterface _orFeedContract) public
	{
		orFeedContractAddress = address(_orFeedContract);
		orFeed = OrFeedInterface(orFeedContractAddress);
    }
	
	
	
	function setOrFeedAddress(OrFeedInterface _orFeedContract) public onlyOwner returns(bool) {
		require(orFeedContractAddress != address(_orFeedContract), "New orfeed address required");
		
		orFeedContractAddress = address(_orFeedContract);
		orFeed = OrFeedInterface(orFeedContractAddress);
		return true;
	}
	
	
	
	function getEthUsdPrice() public view returns(uint) {
		return orFeed.getExchangeRate("ETH", "USDT", "DEFAULT", oneEthAsWei);
	}
	
	function getEthWeiAmountPrice(uint ethWeiAmount) public view returns(uint) {
		return orFeed.getExchangeRate("ETH", "USDT", "DEFAULT", ethWeiAmount);
	}
	
	
	
	function getEthUsdPrice2() public view returns(uint) {
		return OrFeedInterface(orFeedContractAddress).getExchangeRate("ETH", "USDT", "DEFAULT", oneEthAsWei);
	}
	
	function getEthWeiAmountPrice2(uint ethWeiAmount) public view returns(uint) {
		return OrFeedInterface(orFeedContractAddress).getExchangeRate("ETH", "USDT", "DEFAULT", ethWeiAmount);
	}
	
	
	
	function getExchangeRate( string calldata fromSymbol,
							string calldata toSymbol,
							string calldata venue,
							uint256 amount )
						external view returns ( uint256 )
	{
		return (orFeed.getExchangeRate(fromSymbol, toSymbol, venue, amount));
	}
	
	function getExchangeRate2( string calldata fromSymbol,
							string calldata toSymbol,
							string calldata venue,
							uint256 amount )
						external view returns ( uint256 )
	{
		return (OrFeedInterface(orFeedContractAddress).getExchangeRate(fromSymbol, toSymbol, venue, amount));
	}
	
	
	
	function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 ) {
		return orFeed.getTokenDecimalCount(tokenAddress);
	}
	
	function getTokenAddress ( string calldata  symbol ) external view returns ( address ) {
		return orFeed.getTokenAddress(symbol);
	}
	
	function getSynthBytes32 ( string calldata  symbol ) external view returns ( bytes32 ) {
		return orFeed.getSynthBytes32(symbol);
	}
	
	function getForexAddress ( string calldata symbol ) external view returns ( address ) {
		return orFeed.getForexAddress(symbol);
	}
	
	
	
	
	
	
    function () external payable {
    }
	
	
	
	
    function reclaimEther(address payable _to) external onlyOwner returns (bool) {
        _to.transfer(address(this).balance);
		return true;
    }
	
	
    function recoverAnyERC20Token(address tokenAddress, uint tokens) external onlyOwner returns (bool ok) {
		ok = IERC20(tokenAddress).transfer(owner, tokens);
    }
}