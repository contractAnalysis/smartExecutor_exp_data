pragma solidity ^0.4.24;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



pragma solidity ^0.4.24;



library AddressUtils {

  
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
    
    
    
    
    
    
    
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}



pragma solidity ^0.4.24;



contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  
  constructor() public {
    owner = msg.sender;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}



pragma solidity ^0.4.24;



library SafeMath {

  
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}



pragma solidity 0.4.24;




contract BaseMediatorFeeManager is Ownable {
    using SafeMath for uint256;

    event FeeUpdated(uint256 fee);

    
    
    uint256 internal constant MAX_FEE = 1 ether;
    uint256 internal constant MAX_REWARD_ACCOUNTS = 50;

    uint256 public fee;
    address[] internal rewardAccounts;
    address internal mediatorContract;

    modifier validFee(uint256 _fee) {
        require(_fee < MAX_FEE);
        
        _;
    }

    
    constructor(address _owner, uint256 _fee, address[] _rewardAccountList, address _mediatorContract) public {
        require(_rewardAccountList.length > 0 && _rewardAccountList.length <= MAX_REWARD_ACCOUNTS);
        _transferOwnership(_owner);
        _setFee(_fee);
        mediatorContract = _mediatorContract;

        for (uint256 i = 0; i < _rewardAccountList.length; i++) {
            require(isValidAccount(_rewardAccountList[i]));
        }
        rewardAccounts = _rewardAccountList;
    }

    
    function calculateFee(uint256 _value) external view returns (uint256) {
        return _value.mul(fee).div(MAX_FEE);
    }

    
    function _setFee(uint256 _fee) internal validFee(_fee) {
        fee = _fee;
        emit FeeUpdated(_fee);
    }

    
    function setFee(uint256 _fee) external onlyOwner {
        _setFee(_fee);
    }

    function isValidAccount(address _account) internal returns (bool) {
        return _account != address(0) && _account != mediatorContract;
    }

    
    function addRewardAccount(address _account) external onlyOwner {
        require(isValidAccount(_account));
        require(!isRewardAccount(_account));
        require(rewardAccounts.length.add(1) < MAX_REWARD_ACCOUNTS);
        rewardAccounts.push(_account);
    }

    
    function removeRewardAccount(address _account) external onlyOwner returns (bool) {
        uint256 numOfAccounts = rewardAccountsCount();
        for (uint256 i = 0; i < numOfAccounts; i++) {
            if (rewardAccounts[i] == _account) {
                rewardAccounts[i] = rewardAccounts[numOfAccounts - 1];
                delete rewardAccounts[numOfAccounts - 1];
                rewardAccounts.length--;
                return true;
            }
        }
        
        revert();
    }

    
    function rewardAccountsCount() public view returns (uint256) {
        return rewardAccounts.length;
    }

    
    function isRewardAccount(address _account) internal view returns (bool) {
        for (uint256 i = 0; i < rewardAccountsCount(); i++) {
            if (rewardAccounts[i] == _account) {
                return true;
            }
        }
        return false;
    }

    
    function rewardAccountsList() public view returns (address[]) {
        return rewardAccounts;
    }

    
    function onTokenTransfer(address, uint256 _value, bytes) external returns (bool) {
        distributeFee(_value);
        return true;
    }

    
    function distributeFee(uint256 _fee) internal {
        uint256 numOfAccounts = rewardAccountsCount();
        uint256 feePerAccount = _fee.div(numOfAccounts);
        uint256 randomAccountIndex;
        uint256 diff = _fee.sub(feePerAccount.mul(numOfAccounts));
        if (diff > 0) {
            randomAccountIndex = random(numOfAccounts);
        }

        for (uint256 i = 0; i < numOfAccounts; i++) {
            uint256 feeToDistribute = feePerAccount;
            if (diff > 0 && randomAccountIndex == i) {
                feeToDistribute = feeToDistribute.add(diff);
            }
            onFeeDistribution(rewardAccounts[i], feeToDistribute);
        }
    }

    
    function random(uint256 _count) internal view returns (uint256) {
        return uint256(blockhash(block.number.sub(1))) % _count;
    }

    
    function onFeeDistribution(address _rewardAddress, uint256 _fee) internal;
}



pragma solidity 0.4.24;





contract ForeignFeeManagerAMBNativeToErc20 is BaseMediatorFeeManager {
    address public token;

    
    constructor(address _owner, uint256 _fee, address[] _rewardAccountList, address _mediatorContract, address _token)
        public
        BaseMediatorFeeManager(_owner, _fee, _rewardAccountList, _mediatorContract)
    {
        _setToken(_token);
    }

    
    function setToken(address _newToken) external onlyOwner {
        _setToken(_newToken);
    }

    
    function _setToken(address _newToken) internal {
        require(AddressUtils.isContract(_newToken));
        token = _newToken;
    }

    
    function onFeeDistribution(address _rewardAddress, uint256 _fee) internal {
        ERC20Basic(token).transfer(_rewardAddress, _fee);
    }
}