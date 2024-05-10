pragma solidity 0.6.6;


contract Owned {

  address payable public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransferred(
    address indexed from,
    address indexed to
  );

  constructor() public {
    owner = msg.sender;
  }

  
  function transferOwnership(address _to)
    external
    onlyOwner()
  {
    pendingOwner = _to;

    emit OwnershipTransferRequested(owner, _to);
  }

  
  function acceptOwnership()
    external
  {
    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner, "Only callable by owner");
    _;
  }

}


interface FlagsInterface {
  function getFlag(address) external view returns (bool);
  function getFlags(address[] calldata) external view returns (bool[] memory);
  function raiseFlag(address) external;
  function raiseFlags(address[] calldata) external;
  function lowerFlags(address[] calldata) external;
  function setRaisingAccessController(address) external;
}


interface AccessControllerInterface {
  function hasAccess(address user, bytes calldata data) external view returns (bool);
}











contract SimpleWriteAccessController is AccessControllerInterface, Owned {

  bool public checkEnabled;
  mapping(address => bool) internal accessList;

  event AddedAccess(address user);
  event RemovedAccess(address user);
  event CheckAccessEnabled();
  event CheckAccessDisabled();

  constructor()
    public
  {
    checkEnabled = true;
  }

  
  function hasAccess(
    address _user,
    bytes memory
  )
    public
    view
    virtual
    override
    returns (bool)
  {
    return accessList[_user] || !checkEnabled;
  }

  
  function addAccess(address _user)
    external
    onlyOwner()
  {
    if (!accessList[_user]) {
      accessList[_user] = true;

      emit AddedAccess(_user);
    }
  }

  
  function removeAccess(address _user)
    external
    onlyOwner()
  {
    if (accessList[_user]) {
      accessList[_user] = false;

      emit RemovedAccess(_user);
    }
  }

  
  function enableAccessCheck()
    external
    onlyOwner()
  {
    if (!checkEnabled) {
      checkEnabled = true;

      emit CheckAccessEnabled();
    }
  }

  
  function disableAccessCheck()
    external
    onlyOwner()
  {
    if (checkEnabled) {
      checkEnabled = false;

      emit CheckAccessDisabled();
    }
  }

  
  modifier checkAccess() {
    require(hasAccess(msg.sender, msg.data), "No access");
    _;
  }
}



contract SimpleReadAccessController is SimpleWriteAccessController {

  
  function hasAccess(
    address _user,
    bytes memory _calldata
  )
    public
    view
    virtual
    override
    returns (bool)
  {
    return super.hasAccess(_user, _calldata) || _user == tx.origin;
  }

}






contract Flags is FlagsInterface, SimpleReadAccessController {

  AccessControllerInterface public raisingAccessController;

  mapping(address => bool) private flags;

  event FlagRaised(
    address indexed subject
  );
  event FlagLowered(
    address indexed subject
  );
  event RaisingAccessControllerUpdated(
    address indexed previous,
    address indexed current
  );

  
  constructor(
    address racAddress
  )
    public
  {
    setRaisingAccessController(racAddress);
  }

  
  function getFlag(address subject)
    external
    view
    override
    checkAccess()
    returns (bool)
  {
    return flags[subject];
  }

  
  function getFlags(address[] calldata subjects)
    external
    view
    override
    checkAccess()
    returns (bool[] memory)
  {
    bool[] memory responses = new bool[](subjects.length);
    for (uint256 i = 0; i < subjects.length; i++) {
      responses[i] = flags[subjects[i]];
    }
    return responses;
  }

  
  function raiseFlag(address subject)
    external
    override
  {
    require(allowedToRaiseFlags(), "Not allowed to raise flags");

    tryToRaiseFlag(subject);
  }

  
  function raiseFlags(address[] calldata subjects)
    external
    override
  {
    require(allowedToRaiseFlags(), "Not allowed to raise flags");

    for (uint256 i = 0; i < subjects.length; i++) {
      tryToRaiseFlag(subjects[i]);
    }
  }

  
  function lowerFlags(address[] calldata subjects)
    external
    override
    onlyOwner()
  {
    for (uint256 i = 0; i < subjects.length; i++) {
      address subject = subjects[i];

      if (flags[subject]) {
        flags[subject] = false;
        emit FlagLowered(subject);
      }
    }
  }

  
  function setRaisingAccessController(
    address racAddress
  )
    public
    override
    onlyOwner()
  {
    address previous = address(raisingAccessController);

    if (previous != racAddress) {
      raisingAccessController = AccessControllerInterface(racAddress);

      emit RaisingAccessControllerUpdated(previous, racAddress);
    }
  }


  

  function allowedToRaiseFlags()
    private
    view
    returns (bool)
  {
    return msg.sender == owner ||
      raisingAccessController.hasAccess(msg.sender, msg.data);
  }

  function tryToRaiseFlag(address subject)
    private
  {
    if (!flags[subject]) {
      flags[subject] = true;
      emit FlagRaised(subject);
    }
  }

}