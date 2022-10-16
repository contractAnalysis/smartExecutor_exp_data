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




contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  
  modifier whenPaused() {
    require(paused);
    _;
  }

  
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
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




interface IKODAV2ArtistBurner {
  function editionActive(uint256 _editionNumber) external view returns (bool);

  function artistCommission(uint256 _editionNumber) external view returns (address _artistAccount, uint256 _artistCommission);

  function updateActive(uint256 _editionNumber, bool _active) external;

  function totalSupplyEdition(uint256 _editionNumber) external view returns (uint256);

  function totalRemaining(uint256 _editionNumber) external view returns (uint256);

  function updateTotalAvailable(uint256 _editionNumber, uint256 _totalAvailable) external;
}


contract ArtistEditionBurner is Ownable, Pausable {
  using SafeMath for uint256;

  
  IKODAV2ArtistBurner public kodaAddress;

  event EditionDeactivated(
    uint256 indexed _editionNumber
  );

  event EditionSupplyReduced(
    uint256 indexed _editionNumber
  );

  constructor(IKODAV2ArtistBurner _kodaAddress) public {
    kodaAddress = _kodaAddress;
  }

  
  function deactivateOrReduceEditionSupply(uint256 _editionNumber) external whenNotPaused {
    (address artistAccount, uint256 _) = kodaAddress.artistCommission(_editionNumber);
    require(msg.sender == artistAccount || msg.sender == owner, "Only from the edition artist account");

    
    bool isActive = kodaAddress.editionActive(_editionNumber);
    require(isActive, "Only when edition is active");

    
    uint256 totalRemaining = kodaAddress.totalRemaining(_editionNumber);
    require(totalRemaining > 0, "Only when edition not sold out");

    
    uint256 totalSupply = kodaAddress.totalSupplyEdition(_editionNumber);

    
    if (totalSupply == 0) {
      kodaAddress.updateActive(_editionNumber, false);
      kodaAddress.updateTotalAvailable(_editionNumber, 0);
      emit EditionDeactivated(_editionNumber);
    }
    
    else {
      kodaAddress.updateTotalAvailable(_editionNumber, totalSupply);
      emit EditionSupplyReduced(_editionNumber);
    }
  }

  
  function setKodavV2(IKODAV2ArtistBurner _kodaAddress) onlyOwner public {
    kodaAddress = _kodaAddress;
  }

}