pragma solidity 0.6.0;


contract Nest_3_Leveling {
    using address_make_payable for address;
    using SafeMath for uint256;
    Nest_3_VoteFactory _voteFactory;                                
    mapping (address => uint256) ethMapping;                        
    
    
    constructor (address voteFactory) public {
        _voteFactory = Nest_3_VoteFactory(voteFactory); 
    }
    
    
    function changeMapping(address voteFactory) public onlyOwner {
        _voteFactory = Nest_3_VoteFactory(voteFactory); 
    }
    
    
    function tranEth(uint256 amount, address token, address target) public returns (uint256) {
        require(address(msg.sender) == address(_voteFactory.checkAddress("nest.v3.tokenAbonus")), "No authority");
        uint256 tranAmount = amount;
        if (tranAmount > ethMapping[token]) {
            tranAmount = ethMapping[token];
        }
        ethMapping[token] = ethMapping[token].sub(tranAmount);
        address payable addr = target.make_payable();
        addr.transfer(tranAmount);
        return tranAmount;
    }
    
    
    function switchToEth(address token) public payable {
        ethMapping[token] = ethMapping[token].add(msg.value);
    }
    
    
    function checkEthMapping(address token) public view returns (uint256) {
        return ethMapping[token];
    }
    
    
    function turnOutAllEth(uint256 amount, address target) public onlyOwner {
        address payable addr = target.make_payable();
        addr.transfer(amount);  
    }
    
    
    modifier onlyOwner(){
        require(_voteFactory.checkOwners(address(msg.sender)), "No authority");
        _;
    }
}


interface Nest_3_VoteFactory {
    
	function checkAddress(string calldata name) external view returns (address contractAddress);
	
	function checkOwners(address man) external view returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library address_make_payable {
   function make_payable(address x) internal pure returns (address payable) {
      return address(uint160(x));
   }
}