pragma solidity ^0.5.2;


library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



pragma solidity ^0.5.2;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.2;




contract ERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    
    function mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
}



pragma solidity ^0.5.2;



contract ERC20Capped is ERC20 {
    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0);
        _cap = cap;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap);
        super.mint(account, value);
    }
}



pragma solidity ^0.5.2;




contract ITAMToken is ERC20Capped {
    string public name = "ITAM";
    string public symbol = "ITAM";
    uint8 public decimals = 18;
    uint256 constant TOTAL_CAP = 2500000000 ether;

    address public firstMaster;
    address public secondMaster;
    address public thirdMaster;
    mapping(address => mapping(address => bool)) public decidedOwner;
    
    address public owner;
    address public gameMaster;
    mapping(address => bool) public blackLists;

    uint8 public unlockCount = 0;
    address public strategicSaleAddress;
    uint[] public strategicSaleReleaseCaps = [15000000 ether, 15000000 ether, 15000000 ether, 
                                              15000000 ether, 15000000 ether, 15000000 ether,
                                              15000000 ether, 22500000 ether, 22500000 ether];

    address public privateSaleAddress;
    uint[] public privateSaleReleaseCaps = [97500000 ether, 97500000 ether, 97500000 ether,
                                            97500000 ether, 130000000 ether, 130000000 ether];

    address public publicSaleAddress;
    uint public publicSaleReleaseCap = 200000000 ether;

    address public teamAddress;
    uint[] public teamReleaseCaps = [0, 0, 0, 0, 0, 0,
                                     12500000 ether, 12500000 ether, 12500000 ether,
                                     12500000 ether, 12500000 ether, 12500000 ether,
                                     12500000 ether, 12500000 ether, 12500000 ether,
                                     12500000 ether, 12500000 ether, 12500000 ether,
                                     12500000 ether, 12500000 ether, 12500000 ether,
                                     12500000 ether, 12500000 ether, 12500000 ether,
                                     12500000 ether, 12500000 ether];

    address public advisorAddress;
    uint[] public advisorReleaseCaps = [0, 0, 0, 25000000 ether, 0, 25000000 ether,
                                        0, 25000000 ether, 0, 25000000 ether, 0, 25000000 ether];
    
    address public marketingAddress;
    uint[] public marketingReleaseCaps = [100000000 ether, 25000000 ether, 25000000 ether,
                                          25000000 ether, 25000000 ether, 25000000 ether,
                                          25000000 ether, 25000000 ether, 25000000 ether,
                                          25000000 ether, 25000000 ether, 25000000 ether];
    
    address public ecoAddress;
    uint[] public ecoReleaseCaps = [50000000 ether, 50000000 ether, 50000000 ether,
                                    50000000 ether, 50000000 ether, 50000000 ether,
                                    50000000 ether, 50000000 ether, 50000000 ether,
                                    50000000 ether, 50000000 ether, 50000000 ether,
                                    50000000 ether, 50000000 ether, 50000000 ether];
    address payable public inAppAddress;

    ERC20 erc20;

    
    mapping(uint64 => mapping(uint64 => mapping(address => uint256))) items;

    event Unlock(uint8 unlockCount);
    event WithdrawEther(address indexed _to, uint256 amount);
    event PurchaseItemOnEther(address indexed _spender, uint64 appId, uint64 itemId, uint256 amount);
    event PurchaseItemOnITAM(address indexed _spender, uint64 appId, uint64 itemId, uint256 amount);
    event PurchaseItemOnERC20(address indexed _spender, address indexed _tokenAddress, uint64 appId, uint64 itemId, uint256 amount);
    event SetItem(uint64 appId);
    event ChangeOwner(address _owner);

    constructor(address _firstMaster, address _secondMaster, address _thirdMaster,
                address _owner, address _gameMaster, address _strategicSaleAddress,
                address _privateSaleAddress, address _publicSaleAddress, address _teamAddress,
                address _advisorAddress, address _marketingAddress, address _ecoAddress, address payable _inAppAddress) public ERC20Capped(TOTAL_CAP) {
        firstMaster = _firstMaster;
        secondMaster = _secondMaster;
        thirdMaster = _thirdMaster;
        owner = _owner;
        gameMaster = _gameMaster;
        strategicSaleAddress = _strategicSaleAddress;
        privateSaleAddress = _privateSaleAddress;
        publicSaleAddress = _publicSaleAddress;
        teamAddress = _teamAddress;
        advisorAddress = _advisorAddress;
        marketingAddress = _marketingAddress;
        ecoAddress = _ecoAddress;
        inAppAddress = _inAppAddress;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyGameMaster {
        require(msg.sender == gameMaster);
        _;
    }
    
    modifier onlyMaster {
        require(msg.sender == firstMaster || msg.sender == secondMaster || msg.sender == thirdMaster);
        _;
    }
    
    function setGameMaster(address _gameMaster) public onlyOwner {
        gameMaster = _gameMaster;
    }

    function transfer(address _to, uint256 _value) public onlyNotBlackList returns (bool)  {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public onlyNotBlackList returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address spender, uint256 value) public onlyNotBlackList returns (bool) {
        return super.approve(spender, value);
    }

    function burn(uint256 value) public onlyOwner {
        super._burn(msg.sender, value);
    }

    function unlock() public onlyOwner returns (bool) {
        uint8 _unlockCount = unlockCount;

        if(strategicSaleReleaseCaps.length > _unlockCount) {
            super._mint(strategicSaleAddress, strategicSaleReleaseCaps[_unlockCount]);
        }

        if(privateSaleReleaseCaps.length > _unlockCount) {
            super._mint(privateSaleAddress, privateSaleReleaseCaps[_unlockCount]);
        }

        if(_unlockCount == 0) {
            super._mint(publicSaleAddress, publicSaleReleaseCap);
        }

        if(teamReleaseCaps.length > _unlockCount) {
            super._mint(teamAddress, teamReleaseCaps[_unlockCount]);
        }

        if(advisorReleaseCaps.length > _unlockCount) {
            super._mint(advisorAddress, advisorReleaseCaps[_unlockCount]);
        }

        if(marketingReleaseCaps.length > _unlockCount) {
            super._mint(marketingAddress, marketingReleaseCaps[_unlockCount]);
        }

        if(ecoReleaseCaps.length > _unlockCount) {
            super._mint(ecoAddress, ecoReleaseCaps[_unlockCount]);
        }

        unlockCount++;
        return true;
    }

    function setAddresses(address _strategicSaleAddress, address _privateSaleAddress, address _publicSaleAddress, address _teamAddress, address _advisorAddress, address _marketingAddress, address _ecoAddress,
                          address payable _inAppAddress) public onlyOwner {
        strategicSaleAddress = _strategicSaleAddress;
        privateSaleAddress = _privateSaleAddress;
        publicSaleAddress = _publicSaleAddress;
        teamAddress = _teamAddress;
        advisorAddress = _advisorAddress;
        marketingAddress = _marketingAddress;
        ecoAddress = _ecoAddress;
        inAppAddress = _inAppAddress;
    }
    
    function changeOwner(address _owner) public onlyMaster {
        decidedOwner[msg.sender][_owner] = true;
        
        uint16 decidedCount = 0;
        if (decidedOwner[firstMaster][_owner] == true) {
            decidedCount += 1;
        }
        if (decidedOwner[secondMaster][_owner] == true)  {
            decidedCount += 1;
        }
        if (decidedOwner[thirdMaster][_owner] == true) {
            decidedCount += 1;
        }
        
        if (decidedCount >= 2) {
            owner = _owner;
            emit ChangeOwner(_owner);
        }
    }
    
    function addToBlackList(address _to) public onlyOwner {
        require(!blackLists[_to], "already blacklist");
        blackLists[_to] = true;
    }
    
    function removeFromBlackList(address _to) public onlyOwner {
        require(blackLists[_to], "cannot found this address from blacklist");
        blackLists[_to] = false;
    }

    modifier onlyNotBlackList {
        require(!blackLists[msg.sender], "sender cannot call this contract");
        _;
    }
    
    
    function() payable external {
        
    }

    function withdrawEther(uint256 amount) public onlyOwner {
        inAppAddress.transfer(amount);
        emit WithdrawEther(inAppAddress, amount);
    }

    function createOrUpdateItem(uint64 appId, uint64[] memory itemIds, address[] memory tokenAddresses, uint256[] memory values) public onlyGameMaster returns(bool) {
        uint itemLength = itemIds.length;
        require(itemLength == tokenAddresses.length && tokenAddresses.length == values.length);
        
        uint64 itemId;
        address tokenAddress;
        uint256 value;
        for(uint16 i = 0; i < itemLength; i++) {
            itemId = itemIds[i];
            tokenAddress = tokenAddresses[i];
            value = values[i];

            items[appId][itemId][tokenAddress] = value;
        }
        
        emit SetItem(appId);
        return true;
    }
    
    function _getItemAmount(uint64 appId, uint64 itemId, address tokenAddress) private view returns(uint256) {
        uint256 itemAmount = items[appId][itemId][tokenAddress];
        require(itemAmount > 0, "invalid item id");
        return itemAmount;
    }

    function purchaseItemOnERC20(address payable tokenAddress, uint64 appId, uint64 itemId) external onlyNotBlackList returns(bool) {
        uint256 itemAmount = _getItemAmount(appId, itemId, tokenAddress);

        erc20 = ERC20(tokenAddress);
        require(erc20.transferFrom(msg.sender, inAppAddress, itemAmount), "failed transferFrom");

        emit PurchaseItemOnERC20(msg.sender, tokenAddress, appId, itemId, itemAmount);
        return true;
    }

    function purchaseItemOnITAM(uint64 appId, uint64 itemId) external onlyNotBlackList returns(bool) {
        uint256 itemAmount = _getItemAmount(appId, itemId, address(this));

        transfer(inAppAddress, itemAmount);
        
        emit PurchaseItemOnITAM(msg.sender, appId, itemId, itemAmount);
        return true;
    }

    function purchaseItemOnEther(uint64 appId, uint64 itemId) external payable onlyNotBlackList returns(bool) {
        uint256 itemAmount = _getItemAmount(appId, itemId, address(0));
        require(itemAmount == msg.value, "wrong quantity");
        
        emit PurchaseItemOnEther(msg.sender, appId, itemId, msg.value);
        return true;
    }
}