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




contract HasNoEther is Ownable {

  
  constructor() public payable {
    require(msg.value == 0);
  }

  
  function() external {
  }

  
  function reclaimEther() external onlyOwner {
    owner.transfer(address(this).balance);
  }
}



pragma solidity ^0.4.24;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



pragma solidity ^0.4.24;




contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



pragma solidity ^0.4.24;





library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}



pragma solidity ^0.4.24;






contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  
  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}



pragma solidity ^0.4.24;




contract HasNoTokens is CanReclaimToken {

 
  function tokenFallback(
    address _from,
    uint256 _value,
    bytes _data
  )
    external
    pure
  {
    _from;
    _value;
    _data;
    revert();
  }

}



pragma solidity ^0.4.24;





contract FactProviderRegistry is Ownable, HasNoEther, HasNoTokens {
    
    event FactProviderAdded(address indexed factProvider);

    
    event FactProviderUpdated(address indexed factProvider);

    
    event FactProviderDeleted(address indexed factProvider);

    struct FactProviderInfo {
        bool initialized;
        string name;
        address reputation_passport;
        string website;
    }

    mapping(address => FactProviderInfo) public factProviders;

    
    function setFactProviderInfo(
        address _factProvider,
        string _factProviderName,
        address _factProviderReputationPassport,
        string _factProviderWebsite
    ) external onlyOwner {
        bool initializedFactProvider;
        initializedFactProvider = factProviders[_factProvider].initialized;

        factProviders[_factProvider] = FactProviderInfo({
            initialized : true,
            name : _factProviderName,
            reputation_passport : _factProviderReputationPassport,
            website : _factProviderWebsite
            });

        if (initializedFactProvider) {
            emit FactProviderUpdated(_factProvider);
        } else {
            emit FactProviderAdded(_factProvider);
        }
    }

    
    function deleteFactProviderInfo(address _factProvider) external onlyOwner {
        if (factProviders[_factProvider].initialized) {
            delete factProviders[_factProvider];

            emit FactProviderDeleted(_factProvider);
        }
    }
}