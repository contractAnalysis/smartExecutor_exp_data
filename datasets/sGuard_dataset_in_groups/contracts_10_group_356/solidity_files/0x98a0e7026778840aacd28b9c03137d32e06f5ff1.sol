pragma solidity ^0.5.0;


contract Ownable {
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  
  constructor() public {
    _owner = msg.sender;
  }

  
  function owner() public view returns(address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract DOSAddressBridge is Ownable {
    
    address private _proxyAddress;
    
    address private _commitrevealAddress;
    
    address private _paymentAddress;
    
    address private _stakingAddress;
    
    string private _bootStrapUrl;

    event ProxyAddressUpdated(address previousProxy, address newProxy);
    event CommitRevealAddressUpdated(address previousAddr, address newAddr);
    event PaymentAddressUpdated(address previousPayment, address newPayment);
    event StakingAddressUpdated(address previousStaking, address newStaking);
    event BootStrapUrlUpdated(string previousURL, string newURL);

    function getProxyAddress() public view returns (address) {
        return _proxyAddress;
    }

    function setProxyAddress(address newAddr) public onlyOwner {
        emit ProxyAddressUpdated(_proxyAddress, newAddr);
        _proxyAddress = newAddr;
    }

    function getCommitRevealAddress() public view returns (address) {
        return _commitrevealAddress;
    }

    function setCommitRevealAddress(address newAddr) public onlyOwner {
        emit CommitRevealAddressUpdated(_commitrevealAddress, newAddr);
        _commitrevealAddress = newAddr;
    }

    function getPaymentAddress() public view returns (address) {
        return _paymentAddress;
    }

    function setPaymentAddress(address newAddr) public onlyOwner {
        emit PaymentAddressUpdated(_paymentAddress, newAddr);
        _paymentAddress = newAddr;
    }

    function getStakingAddress() public view returns (address) {
        return _stakingAddress;
    }

    function setStakingAddress(address newAddr) public onlyOwner {
        emit StakingAddressUpdated(_stakingAddress, newAddr);
        _stakingAddress = newAddr;
    }

    function getBootStrapUrl() public view returns (string memory) {
        return _bootStrapUrl;
    }

    function setBootStrapUrl(string memory url) public onlyOwner {
        emit BootStrapUrlUpdated(_bootStrapUrl, url);
        _bootStrapUrl = url;
    }
}