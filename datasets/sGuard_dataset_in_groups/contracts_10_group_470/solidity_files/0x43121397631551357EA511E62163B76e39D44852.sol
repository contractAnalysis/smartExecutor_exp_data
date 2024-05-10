pragma solidity 0.6.0;


contract Nest_3_Abonus {
    using address_make_payable for address;
    using SafeMath for uint256;
    
    Nest_3_VoteFactory _voteFactory;                                
    address _nestAddress;                                           
    mapping (address => uint256) ethMapping;                        
    uint256 _mostDistribution = 40;                                 
    uint256 _leastDistribution = 20;                                
    uint256 _distributionTime = 1200000;                            
    uint256 _distributionSpan = 5;                                  
    
    
    constructor(address voteFactory) public {
        _voteFactory = Nest_3_VoteFactory(voteFactory);
        _nestAddress = address(_voteFactory.checkAddress("nest"));
    }
 
    
    function changeMapping(address voteFactory) public onlyOwner{
        _voteFactory = Nest_3_VoteFactory(voteFactory);
        _nestAddress = address(_voteFactory.checkAddress("nest"));
    }
    
    
    function switchToEth(address token) public payable {
        ethMapping[token] = ethMapping[token].add(msg.value);
    }
    
    
    function switchToEthForNTokenOffer(address token) public payable {
        Nest_NToken nToken = Nest_NToken(token);
        (uint256 createBlock,) = nToken.checkBlockInfo();
        uint256 subBlock = block.number.sub(createBlock);
        uint256 times = subBlock.div(_distributionTime);
        uint256 distributionValue = times.mul(_distributionSpan);
        uint256 distribution = _mostDistribution;
        if (_leastDistribution.add(distributionValue) > _mostDistribution) {
            distribution = _leastDistribution;
        } else {
            distribution = _mostDistribution.sub(distributionValue);
        }
        uint256 nestEth = msg.value.mul(distribution).div(100);
        ethMapping[_nestAddress] = ethMapping[_nestAddress].add(nestEth);
        ethMapping[token] = ethMapping[token].add(msg.value.sub(nestEth));
    }
    
    
    function getETH(uint256 num, address token, address target) public onlyContract {
        require(num <= ethMapping[token], "Insufficient storage balance");
        ethMapping[token] = ethMapping[token].sub(num);
        address payable addr = target.make_payable();
        addr.transfer(num);
    }
    
    
    function getETHNum(address token) public view returns (uint256) {
        return ethMapping[token];
    }
    
    
    function checkNestAddress() public view returns(address) {
        return _nestAddress;
    }
    
    
    function checkMostDistribution() public view returns(uint256) {
        return _mostDistribution;
    }
    
    
    function checkLeastDistribution() public view returns(uint256) {
        return _leastDistribution;
    }
    
    
    function checkDistributionTime() public view returns(uint256) {
        return _distributionTime;
    }
    
    
    function checkDistributionSpan() public view returns(uint256) {
        return _distributionSpan;
    }
    
    
    function changeMostDistribution(uint256 num) public onlyOwner  {
        _mostDistribution = num;
    }
    
    
    function changeLeastDistribution(uint256 num) public onlyOwner  {
        _leastDistribution = num;
    }
    
    
    function changeDistributionTime(uint256 num) public onlyOwner  {
        _distributionTime = num;
    }
    
    
    function changeDistributionSpan(uint256 num) public onlyOwner  {
        _distributionSpan = num;
    }
    
    
    function turnOutAllEth(uint256 amount, address target) public onlyOwner {
        address payable addr = target.make_payable();
        addr.transfer(amount);  
    }
    
    
    modifier onlyContract(){
        require(_voteFactory.checkAddress("nest.v3.tokenAbonus") == address(msg.sender), "No authority");
        _;
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


interface Nest_NToken {
    
    function increaseTotal(uint256 value) external;
    
    function checkBlockInfo() external view returns(uint256 createBlock, uint256 recentlyUsedBlock);
    
    function checkOwner() external view returns(address);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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