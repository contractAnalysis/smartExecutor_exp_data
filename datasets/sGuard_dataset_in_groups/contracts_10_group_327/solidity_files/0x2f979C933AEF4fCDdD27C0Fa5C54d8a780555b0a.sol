pragma solidity 0.6.0;


contract Nest_3_MiningContract {
    
    using address_make_payable for address;
    using SafeMath for uint256;
    
    uint256 _blockAttenuation = 2400000;                 
    uint256[10] _attenuationAmount;                      
    uint256 _afterMiningAmount = 40 ether;               
    uint256 _firstBlockNum;                              
    uint256 _latestMining;                               
    Nest_3_VoteFactory _voteFactory;                     
    ERC20 _nestContract;                                 
    address _offerFactoryAddress;                        
    
    
    event OreDrawingLog(uint256 nowBlock, uint256 blockAmount);
    
    
    constructor(address voteFactory) public {
        _voteFactory = Nest_3_VoteFactory(address(voteFactory));                  
        _offerFactoryAddress = address(_voteFactory.checkAddress("nest.v3.offerMain"));
        _nestContract = ERC20(address(_voteFactory.checkAddress("nest")));
        
        _firstBlockNum = 6236588;
        _latestMining = block.number;
        uint256 blockAmount = 400 ether;
        for (uint256 i = 0; i < 10; i ++) {
            _attenuationAmount[i] = blockAmount;
            blockAmount = blockAmount.mul(8).div(10);
        }
    }
    
    
    function changeMapping(address voteFactory) public onlyOwner {
        _voteFactory = Nest_3_VoteFactory(address(voteFactory));                  
        _offerFactoryAddress = address(_voteFactory.checkAddress("nest.v3.offerMain"));
        _nestContract = ERC20(address(_voteFactory.checkAddress("nest")));
    }
    
    
    function oreDrawing() public returns (uint256) {
        require(address(msg.sender) == _offerFactoryAddress, "No authority");
        
        uint256 miningAmount = changeBlockAmountList();
        
        if (_nestContract.balanceOf(address(this)) < miningAmount){
            miningAmount = _nestContract.balanceOf(address(this));
        }
        if (miningAmount > 0) {
            _nestContract.transfer(address(msg.sender), miningAmount);
            emit OreDrawingLog(block.number,miningAmount);
        }
        return miningAmount;
    }
    
    
    function changeBlockAmountList() private returns (uint256) {
        uint256 createBlock = _firstBlockNum;
        uint256 recentlyUsedBlock = _latestMining;
        uint256 attenuationPointNow = block.number.sub(createBlock).div(_blockAttenuation);
        uint256 miningAmount = 0;
        uint256 attenuation;
        if (attenuationPointNow > 9) {
            attenuation = _afterMiningAmount;
        } else {
            attenuation = _attenuationAmount[attenuationPointNow];
        }
        miningAmount = attenuation.mul(block.number.sub(recentlyUsedBlock));
        _latestMining = block.number;
        return miningAmount;
    }
    
    
    function takeOutNest(address target) public onlyOwner {
        _nestContract.transfer(address(target),_nestContract.balanceOf(address(this)));
    }

    
    function checkBlockAttenuation() public view returns(uint256) {
        return _blockAttenuation;
    }
    
    
    function checkLatestMining() public view returns(uint256) {
        return _latestMining;
    }
    
    
    function checkAttenuationAmount(uint256 num) public view returns(uint256) {
        return _attenuationAmount[num];
    }
    
    
    function checkNestBalance() public view returns(uint256) {
        return _nestContract.balanceOf(address(this));
    }
    
    
    function changeBlockAttenuation(uint256 blockNum) public onlyOwner {
        require(blockNum > 0);
        _blockAttenuation = blockNum;
    }
    
    
    function changeAttenuationAmount(uint256 firstAmount, uint256 top, uint256 bottom) public onlyOwner {
        uint256 blockAmount = firstAmount;
        for (uint256 i = 0; i < 10; i ++) {
            _attenuationAmount[i] = blockAmount;
            blockAmount = blockAmount.mul(top).div(bottom);
        }
    }
    
    
    modifier onlyOwner(){
        require(_voteFactory.checkOwners(msg.sender), "No authority");
        _;
    }
}


interface Nest_3_VoteFactory {
    
	function checkAddress(string calldata name) external view returns (address contractAddress);
	
	function checkOwners(address man) external view returns (bool);
}


interface ERC20 {
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