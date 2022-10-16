pragma solidity ^0.5.16;




library SafeMath {

 
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

 
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract ReentrancyGuard {

  
  bool private reentrancyLock = false;

  
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }
}


library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}


contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  
  function checkRole(address addr, string memory roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  
  function hasRole(address addr, string memory roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  
  function addRole(address addr, string memory roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }

  
  function removeRole(address addr, string memory roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }

  
  modifier onlyRole(string memory roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

}


contract RBACWithAdmin is RBAC { 
  
  string public constant ROLE_ADMIN = "admin";
  string public constant ROLE_PAUSE_ADMIN = "pauseAdmin";

  
  modifier onlyAdmin()
  {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }
  modifier onlyPauseAdmin()
  {
    checkRole(msg.sender, ROLE_PAUSE_ADMIN);
    _;
  }
  
  constructor()
    public
  {
    addRole(msg.sender, ROLE_ADMIN);
    addRole(msg.sender, ROLE_PAUSE_ADMIN);
  }

  
  function adminAddRole(address addr, string memory roleName)
    onlyAdmin
    public
  {
    addRole(addr, roleName);
  }

  
  function adminRemoveRole(address addr, string memory roleName)
    onlyAdmin
    public
  {
    removeRole(addr, roleName);
  }
}


contract Pausable is RBACWithAdmin {
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

  
  function pause() onlyPauseAdmin whenNotPaused public {
    paused = true;
    emit Pause();
  }

  
  function unpause() onlyPauseAdmin whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract DragonsETH {
    struct Dragon {
        uint256 gen1;
        uint8 stage; 
        uint8 currentAction; 
                             
        uint240 gen2;
        uint256 nextBlock2Action;
    }
    Dragon[] public dragons;
    
    function ownerOf(uint256 _tokenId) public view returns (address);
    function checkDragonStatus(uint256 _dragonID, uint8 _stage) public view;
    function setCurrentAction(uint256 _dragonID, uint8 _currentAction) external;
    function setTime2Rest(uint256 _dragonID, uint256 _addNextBlock2Action) external;
    function isApprovedOrOwner(address _spender, uint256 _tokenId) public view returns (bool);
}

contract DragonsFight {
    function getWinner(uint256 _dragonOneID, uint256 _dragonTwoID) external returns (uint256 _winerID);
}

contract DragonsStats {
    function incFightWin(uint256 _dragonID) external;
    function incFightLose(uint256 _dragonID) external;
    function setLastAction(uint256 _dragonID, uint256 _lastActionDragonID, uint8 _lastActionID) external;
}

contract Mutagen {
    function mint(address _to, uint256 _amount)  public returns (bool);
}

contract DragonsFightGC is Pausable {
    Mutagen public mutagenContract;
    DragonsETH public mainContract;
    DragonsFight public dragonsFightContract;
    DragonsStats public dragonsStatsContract;
    address payable wallet;
    uint256 public mutagenToWin = 10;
    uint256 public mutagenToLose =1;
    uint256 public addTime2Rest = 240; 
    
    event FightFP(uint256 _winnerId, uint256 _loserId, address indexed _ownerWinner, address indexed _onwerLoser);
    event AddDragonFP(address indexed _from, uint256 _tokenId);
    event RemoveDragonFP(address indexed _from, uint256 _tokenId);
    
 
    function changeAddressMutagenContract(address _newAddress) external onlyAdmin {
        mutagenContract = Mutagen(_newAddress);
    }
    function changeAddressMainContract(address _newAddress) external onlyAdmin {
        mainContract = DragonsETH(_newAddress);
    }
    function changeAddressFightContract(address _newAddress) external onlyAdmin {
        dragonsFightContract = DragonsFight(_newAddress);
    }
    function changeAddressStatsContract(address _newAddress) external onlyAdmin {
        dragonsStatsContract = DragonsStats(_newAddress);
    }
    function changeWallet(address payable _wallet) external onlyAdmin {
        wallet = _wallet;
    }
    function changeMutagenToWin(uint256 _mutagenToWin) external onlyAdmin {
        mutagenToWin = _mutagenToWin;
    }
    
    function changeMutagenToLose(uint256 _mutagenToLose) external onlyAdmin {
        mutagenToLose = _mutagenToLose;
    }
    function changeAddTime2Rest(uint256 _addTime2Rest) external onlyAdmin {
        addTime2Rest = _addTime2Rest;
    }
    function withdrawAllEther() external onlyAdmin {
        require(wallet != address(0), "Withdraw address can't be zero!");
        wallet.transfer(address(this).balance);
    }
}

contract DragonsFightPlace is DragonsFightGC, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public priceToFight = 0.001 ether; 
    uint256 public priceToAdd = 0.0001 ether;  
    mapping(uint256 => address) dragonOwners;
    mapping(address => uint256) public ownerDragonsCount;
    mapping(uint256 => uint256) public dragonsListIndex;
    uint256[] public dragonsList;
    
    
    constructor(address payable _wallet) public {
        wallet = _wallet;
    }

    
    function addToFightPlace(uint256 _dragonID) external payable whenNotPaused nonReentrant {
        require(mainContract.isApprovedOrOwner(msg.sender, _dragonID), "The sender is not an owner!");
        require(msg.value >= priceToAdd, "Not enough ether!");
        mainContract.checkDragonStatus(_dragonID, 2);
        uint256 valueToReturn = msg.value.sub(priceToAdd);
        if (priceToAdd != 0) {
            wallet.transfer(priceToAdd);
        }
        
        if (valueToReturn != 0) {
            msg.sender.transfer(valueToReturn);
        }
        dragonOwners[_dragonID] = mainContract.ownerOf(_dragonID);
        ownerDragonsCount[dragonOwners[_dragonID]]++;
        dragonsListIndex[_dragonID] = dragonsList.length;
        dragonsList.push(_dragonID);
        mainContract.setCurrentAction(_dragonID, 1);
        emit AddDragonFP(dragonOwners[_dragonID], _dragonID);
        
    }
    
    function delFromFightPlace(uint256 _dragonID) external {
        require(mainContract.isApprovedOrOwner(msg.sender, _dragonID), "Only the owner or approved address can do this!");
        emit RemoveDragonFP(dragonOwners[_dragonID], _dragonID);
        _delItem(_dragonID);
    }

    function fightWithDragon(uint256 _yourDragonID,uint256 _thisDragonID) external payable whenNotPaused nonReentrant {
        require(msg.value >= priceToFight, "Not enough ether!");
        require(mainContract.isApprovedOrOwner(msg.sender, _yourDragonID), "The sender is not an owner!");
        uint8 stage;
        uint8 currentAction;
        uint256 nextBlock2Action;
        (,stage,currentAction,,nextBlock2Action) = mainContract.dragons(_yourDragonID);
        require(stage >= 2, "No eggs, No dead dragons!");
        require(nextBlock2Action <= block.number, "Dragon is resting!");
        require(currentAction == 0 || currentAction == 1, "Dragon is busy!");
        uint256 valueToReturn = msg.value - priceToFight;
        if (priceToFight != 0) {
            wallet.transfer(priceToFight);
        }
        if (valueToReturn != 0) {
            msg.sender.transfer(valueToReturn);
        }
        if (dragonsFightContract.getWinner(_yourDragonID, _thisDragonID) == _yourDragonID ) {
            _setFightResult(_yourDragonID, _thisDragonID);
            _closeFight(_yourDragonID, _thisDragonID);
            emit FightFP(_yourDragonID, _thisDragonID, mainContract.ownerOf(_yourDragonID), dragonOwners[_thisDragonID]);
        } else {
            _setFightResult(_thisDragonID, _yourDragonID);
            _closeFight(_thisDragonID, _yourDragonID);
            emit FightFP(_thisDragonID, _yourDragonID, dragonOwners[_thisDragonID], mainContract.ownerOf(_yourDragonID));
        }
        _delItem(_thisDragonID);
        if (dragonOwners[_yourDragonID] != address(0))
            _delItem(_yourDragonID);
    }
    function getAllDragonsFight() external view returns(uint256[] memory) {
        return dragonsList;
    }
    function getSlicedDragonsSale(uint256 _firstIndex, uint256 _aboveLastIndex) external view returns(uint256[] memory) {
        require(_firstIndex < dragonsList.length, "First index greater than totalDragonsToFight!");
        uint256 lastIndex = _aboveLastIndex;
        if (_aboveLastIndex > dragonsList.length) lastIndex = dragonsList.length;
        require(_firstIndex <= lastIndex, "First index greater than last!");
        uint256 resultCount = lastIndex - _firstIndex;
        if (resultCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](resultCount);
            uint256 _dragonIndex;
            uint256 _resultIndex = 0;

            for (_dragonIndex = _firstIndex; _dragonIndex < lastIndex; _dragonIndex++) {
                result[_resultIndex] = dragonsList[_dragonIndex];
                _resultIndex++;
            }

            return result;
        }
    }
    function getFewDragons(uint256[] calldata _dragonIDs) external view returns(uint256[] memory) {
        uint256 dragonCount = _dragonIDs.length;
        if (dragonCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](dragonCount * 3);
            uint256 resultIndex = 0;

            for (uint256 dragonIndex = 0; dragonIndex < dragonCount; dragonIndex++) {
                uint256 dragonID = _dragonIDs[dragonIndex];
                if (dragonOwners[dragonID] == address(0))
                    continue;
                result[resultIndex++] = dragonID;
                uint8 dragonStage;
                (,dragonStage,,,) = mainContract.dragons(dragonID);
                result[resultIndex++] = uint256(dragonStage);
                result[resultIndex++] = uint256(dragonOwners[dragonID]);
            }
            return result; 
        }
    }
    function getAddressDragons(address _owner) external view returns(uint256[] memory) {
        uint256 dragonCount = ownerDragonsCount[_owner];
        if (dragonCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](dragonCount * 2);
            uint256 resultIndex = 0;

            for (uint256 dragonIndex = 0; dragonIndex < dragonsList.length; dragonIndex++) {
                uint256 dragonID = dragonsList[dragonIndex];
                if (_owner != dragonOwners[dragonID])
                    continue;
                result[resultIndex++] = dragonID;
                uint8 dragonStage;
                (,dragonStage,,,) = mainContract.dragons(dragonID);
                result[resultIndex++] = uint256(dragonStage);
            }
            return result; 
        }
    }
    function totalDragonsToFight() external view returns(uint256) {
        return dragonsList.length;
    }
    function _delItem(uint256 _dragonID) private {
        require(dragonOwners[_dragonID] != address(0), "An attempt to remove an unregistered dragon!");
        mainContract.setCurrentAction(_dragonID, 0);
        ownerDragonsCount[dragonOwners[_dragonID]]--;
        delete(dragonOwners[_dragonID]);
        if (dragonsList.length - 1 != dragonsListIndex[_dragonID]) {
            dragonsList[dragonsListIndex[_dragonID]] = dragonsList[dragonsList.length - 1];
            dragonsListIndex[dragonsList[dragonsList.length - 1]] = dragonsListIndex[_dragonID];
        }
        dragonsList.length--;
        delete(dragonsListIndex[_dragonID]);
    }
    function _setFightResult(uint256 _dragonWin, uint256 _dragonLose) private {
        dragonsStatsContract.incFightWin(_dragonWin);
        dragonsStatsContract.incFightLose(_dragonLose);
        dragonsStatsContract.setLastAction(_dragonWin, _dragonLose, 13);
        dragonsStatsContract.setLastAction(_dragonLose, _dragonWin, 14);
    }
    function _closeFight(uint256 _dragonWin, uint256 _dragonLose) private {
        mainContract.setTime2Rest(_dragonWin, addTime2Rest);
        mainContract.setTime2Rest(_dragonLose, addTime2Rest);
        mutagenContract.mint(mainContract.ownerOf(_dragonWin), mutagenToWin);
        mutagenContract.mint(mainContract.ownerOf(_dragonLose), mutagenToLose);
    }
    function clearFightPlace(uint256[] calldata _dragonIDs) external onlyAdmin whenPaused {
        uint256 dragonCount = _dragonIDs.length;
        for (uint256 dragonIndex = 0; dragonIndex < dragonCount; dragonIndex++) {
            uint256 dragonID = _dragonIDs[dragonIndex];
            if (dragonOwners[dragonID] != address(0))
                _delItem(dragonID);
        }
    }
    function changePrices(uint256 _priceToFight,uint256 _priceToAdd) external onlyAdmin {
        priceToFight = _priceToFight;
        priceToAdd = _priceToAdd;
    }
}