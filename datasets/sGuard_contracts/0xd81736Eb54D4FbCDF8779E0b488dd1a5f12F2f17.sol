pragma solidity ^0.6.0;

interface PermittedConvertsInterface {
  function permittedAddresses(address _address) external view returns(bool);
}
interface PermittedStablesInterface {
  function permittedAddresses(address _address) external view returns(bool);
}
interface PermittedPoolsInterface {
  function permittedAddresses(address _address) external view returns(bool);
}
interface PermittedExchangesInterface {
  function permittedAddresses(address _address) external view returns(bool);
}
interface SmartFundUSDFactoryInterface {
  function createSmartFund(
    address _owner,
    string  calldata _name,
    uint256 _successFee,
    uint256 _platformFee,
    address _platfromAddress,
    address _exchangePortalAddress,
    address _permittedExchanges,
    address _permittedPools,
    address _permittedStabels,
    address _poolPortalAddress,
    address _stableCoinAddress,
    address _cEther,
    address _permittedConvertsAddress
    )
  external
  returns(address);
}
interface SmartFundETHFactoryInterface {
  function createSmartFund(
    address _owner,
    string  calldata _name,
    uint256 _successFee,
    uint256 _platformFee,
    address _platfromAddress,
    address _exchangePortalAddress,
    address _permittedExchanges,
    address _permittedPools,
    address _poolPortalAddress,
    address _cEther,
    address _permittedConvertsAddress
    )
  external
  returns(address);
}



contract Context {
    
    
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract SmartFundRegistry is Ownable {
  address[] public smartFunds;

  
  PermittedExchangesInterface public permittedExchanges;
  
  PermittedPoolsInterface public permittedPools;
  
  PermittedStablesInterface public permittedStables;
  
  PermittedConvertsInterface public permittedConverts;

  
  address public poolPortalAddress;
  address public exchangePortalAddress;
  address public convertPortalAddress;

  
  uint256 public platformFee;

  
  uint256 public maximumSuccessFee = 3000;

  
  address public stableCoinAddress;

  
  address public cEther;

  
  SmartFundETHFactoryInterface public smartFundETHFactory;
  SmartFundUSDFactoryInterface public smartFundUSDFactory;

  event SmartFundAdded(address indexed smartFundAddress, address indexed owner);

  
  constructor(
    address _convertPortalAddress,
    uint256 _platformFee,
    address _permittedExchangesAddress,
    address _exchangePortalAddress,
    address _permittedPoolAddress,
    address _poolPortalAddress,
    address _permittedStables,
    address _stableCoinAddress,
    address _smartFundETHFactory,
    address _smartFundUSDFactory,
    address _cEther,
    address _permittedConvertsAddress
  ) public {
    convertPortalAddress = _convertPortalAddress;
    platformFee = _platformFee;
    exchangePortalAddress = _exchangePortalAddress;
    permittedExchanges = PermittedExchangesInterface(_permittedExchangesAddress);
    permittedPools = PermittedPoolsInterface(_permittedPoolAddress);
    permittedStables = PermittedStablesInterface(_permittedStables);
    poolPortalAddress = _poolPortalAddress;
    stableCoinAddress = _stableCoinAddress;
    smartFundETHFactory = SmartFundETHFactoryInterface(_smartFundETHFactory);
    smartFundUSDFactory = SmartFundUSDFactoryInterface(_smartFundUSDFactory);
    cEther = _cEther;
    permittedConverts = PermittedConvertsInterface(_permittedConvertsAddress);
  }

  
  function createSmartFund(
    string memory _name,
    uint256 _successFee,
    bool _isStableBasedFund
  ) public {
    
    require(_successFee <= maximumSuccessFee);

    address owner = msg.sender;
    address smartFund;

    if(_isStableBasedFund){
      
      smartFund = smartFundUSDFactory.createSmartFund(
        owner,
        _name,
        _successFee,
        platformFee,
        exchangePortalAddress,
        address(permittedExchanges),
        address(permittedPools),
        address(permittedStables),
        poolPortalAddress,
        stableCoinAddress,
        convertPortalAddress,
        cEther,
        address(permittedConverts)
      );
    }else{
      
      smartFund = smartFundETHFactory.createSmartFund(
        owner,
        _name,
        _successFee,
        platformFee,
        exchangePortalAddress,
        address(permittedExchanges),
        address(permittedPools),
        poolPortalAddress,
        convertPortalAddress,
        cEther,
        address(permittedConverts)
      );
    }

    smartFunds.push(smartFund);
    emit SmartFundAdded(smartFund, owner);
  }

  function totalSmartFunds() public view returns (uint256) {
    return smartFunds.length;
  }

  function getAllSmartFundAddresses() public view returns(address[] memory) {
    address[] memory addresses = new address[](smartFunds.length);

    for (uint i; i < smartFunds.length; i++) {
      addresses[i] = address(smartFunds[i]);
    }

    return addresses;
  }

  
  function setExchangePortalAddress(address _newExchangePortalAddress) public onlyOwner {
    
    require(permittedExchanges.permittedAddresses(_newExchangePortalAddress));

    exchangePortalAddress = _newExchangePortalAddress;
  }

  
  function setPoolPortalAddress (address _poolPortalAddress) external onlyOwner {
    
    require(permittedPools.permittedAddresses(_poolPortalAddress));

    poolPortalAddress = _poolPortalAddress;
  }


  
  function setConvertPortalAddress(address _convertPortalAddress) external onlyOwner {
    
    require(permittedConverts.permittedAddresses(_convertPortalAddress));

    convertPortalAddress = _convertPortalAddress;
  }

  
  function setMaximumSuccessFee(uint256 _maximumSuccessFee) external onlyOwner {
    maximumSuccessFee = _maximumSuccessFee;
  }

  
  function setPlatformFee(uint256 _platformFee) external onlyOwner {
    platformFee = _platformFee;
  }


  
  function setStableCoinAddress(address _stableCoinAddress) external onlyOwner {
    require(permittedStables.permittedAddresses(_stableCoinAddress));
    stableCoinAddress = _stableCoinAddress;
  }

  
  function withdrawTokens(address _tokenAddress) external onlyOwner {
    IERC20 token = IERC20(_tokenAddress);

    token.transfer(owner(), token.balanceOf(address(this)));
  }

  
  function withdrawEther() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  
  fallback() external payable {}

}