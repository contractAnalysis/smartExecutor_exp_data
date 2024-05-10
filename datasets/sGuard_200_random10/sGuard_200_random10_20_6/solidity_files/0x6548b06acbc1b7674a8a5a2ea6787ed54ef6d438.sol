pragma solidity 0.6.8;


interface ERC20 {
    function transfer(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract PerlinXRewards {
    using SafeMath for uint256;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    address public PERL;
    address public treasury;

    address[] public arrayAdmins;
    address[] public arrayPerlinPools;
    address[] public arraySynths;
    address[] public arrayMembers;

    uint256 public currentEra;

    mapping(address => bool) public isAdmin; 
    mapping(address => bool) public poolIsListed; 
    mapping(address => bool) public poolHasMembers; 
    mapping(address => bool) public poolWasListed; 
    mapping(address => uint256) public mapAsset_Rewards; 
    mapping(address => uint256) public poolWeight; 
    mapping(uint256 => uint256) public mapEra_Total; 
    mapping(uint256 => bool) public eraIsOpen; 
    mapping(uint256 => mapping(address => uint256)) public mapEraAsset_Reward; 
    mapping(uint256 => mapping(address => uint256)) public mapEraPool_Balance; 
    mapping(uint256 => mapping(address => uint256)) public mapEraPool_Share; 
    mapping(uint256 => mapping(address => uint256)) public mapEraPool_Claims; 

    mapping(address => address) public mapPool_Asset; 
    mapping(address => address) public mapSynth_EMP; 

    mapping(address => bool) public isMember; 
    mapping(address => uint256) public mapMember_poolCount; 
    mapping(address => address[]) public mapMember_arrayPools; 
    mapping(address => mapping(address => uint256))
        public mapMemberPool_Balance; 
    mapping(address => mapping(address => bool)) public mapMemberPool_Added; 
    mapping(address => mapping(uint256 => bool))
        public mapMemberEra_hasRegistered; 
    mapping(address => mapping(uint256 => mapping(address => uint256)))
        public mapMemberEraPool_Claim; 
    mapping(address => mapping(uint256 => mapping(address => bool)))
        public mapMemberEraAsset_hasClaimed; 

    
    event Snapshot(
        address indexed admin,
        uint256 indexed era,
        uint256 rewardForEra,
        uint256 perlTotal,
        uint256 validPoolCount,
        uint256 validMemberCount,
        uint256 date
    );
    event NewPool(
        address indexed admin,
        address indexed pool,
        address indexed asset,
        uint256 assetWeight
    );
    event NewSynth(
        address indexed pool,
        address indexed synth,
        address indexed expiringMultiParty
    );
    event MemberLocks(
        address indexed member,
        address indexed pool,
        uint256 amount,
        uint256 indexed currentEra
    );
    event MemberUnlocks(
        address indexed member,
        address indexed pool,
        uint256 balance,
        uint256 indexed currentEra
    );
    event MemberRegisters(
        address indexed member,
        address indexed pool,
        uint256 amount,
        uint256 indexed currentEra
    );
    event MemberClaims(address indexed member, uint256 indexed era, uint256 totalClaim);

    
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Must be Admin");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor() public {
        arrayAdmins.push(msg.sender);
        isAdmin[msg.sender] = true;
        PERL = 0xb5A73f5Fc8BbdbcE59bfD01CA8d35062e0dad801;
        treasury = 0x7786B620937af5F6F24Bf4fefA4ab7c544a59Ca6; 
        currentEra = 1;
        _status = _NOT_ENTERED;
    }

    

    
    function listSynth(
        address pool,
        address synth,
        address emp,
        uint256 weight
    ) public onlyAdmin {
        require(emp != address(0), "Must pass address validation");
        if (!poolWasListed[pool]) {
            arraySynths.push(synth); 
        }
        listPool(pool, synth, weight); 
        mapSynth_EMP[synth] = emp; 
        emit NewSynth(pool, synth, emp);
    }

    
    
    function listPool(
        address pool,
        address asset,
        uint256 weight
    ) public onlyAdmin {
        require(
            (asset != PERL) && (asset != address(0)) && (pool != address(0)),
            "Must pass address validation"
        );
        require(
            weight >= 10 && weight <= 1000,
            "Must be greater than 0.1, less than 10"
        );
        if (!poolWasListed[pool]) {
            arrayPerlinPools.push(pool);
        }
        poolIsListed[pool] = true; 
        poolWasListed[pool] = true; 
        poolWeight[pool] = weight; 
        mapPool_Asset[pool] = asset; 
        emit NewPool(msg.sender, pool, asset, weight);
    }

    function delistPool(address pool) public onlyAdmin {
        poolIsListed[pool] = false;
    }

    
    function addAdmin(address newAdmin) public onlyAdmin {
        require(
            (isAdmin[newAdmin] == false) && (newAdmin != address(0)),
            "Must pass address validation"
        );
        arrayAdmins.push(newAdmin);
        isAdmin[newAdmin] = true;
    }

    function transferAdmin(address newAdmin) public onlyAdmin {
        require(
            (isAdmin[newAdmin] == false) && (newAdmin != address(0)),
            "Must pass address validation"
        );
        arrayAdmins.push(newAdmin);
        isAdmin[msg.sender] = false;
        isAdmin[newAdmin] = true;
    }

    
    
    function snapshot(address rewardAsset) public onlyAdmin {
        snapshotInEra(rewardAsset, currentEra); 
        currentEra = currentEra.add(1); 
    }

    
    
    function snapshotInEra(address rewardAsset, uint256 era) public onlyAdmin {
        uint256 start = 0;
        uint256 end = poolCount();
        snapshotInEraWithOffset(rewardAsset, era, start, end);
    }

    
    function snapshotWithOffset(
        address rewardAsset,
        uint256 start,
        uint256 end
    ) public onlyAdmin {
        snapshotInEraWithOffset(rewardAsset, currentEra, start, end); 
        currentEra = currentEra.add(1); 
    }

    
    function snapshotInEraWithOffset(
        address rewardAsset,
        uint256 era,
        uint256 start,
        uint256 end
    ) public onlyAdmin {
        require(rewardAsset != address(0), "Address must not be 0x0");
        require(
            (era >= currentEra - 1) && (era <= currentEra),
            "Must be current or previous era only"
        );
        uint256 amount = ERC20(rewardAsset).balanceOf(address(this)).sub(
            mapAsset_Rewards[rewardAsset]
        );
        require(amount > 0, "Amount must be non-zero");
        mapAsset_Rewards[rewardAsset] = mapAsset_Rewards[rewardAsset].add(
            amount
        );
        mapEraAsset_Reward[era][rewardAsset] = mapEraAsset_Reward[era][rewardAsset]
            .add(amount);
        eraIsOpen[era] = true;
        updateRewards(era, amount, start, end); 
    }

    
    function updateRewards(
        uint256 era,
        uint256 rewardForEra,
        uint256 start,
        uint256 end
    ) internal {
        
        uint256 perlTotal;
        uint256 validPoolCount;
        uint256 validMemberCount;
        for (uint256 i = start; i < end; i++) {
            address pool = arrayPerlinPools[i];
            if (poolIsListed[pool] && poolHasMembers[pool]) {
                validPoolCount = validPoolCount.add(1);
                uint256 weight = poolWeight[pool];
                uint256 weightedBalance = (
                    ERC20(PERL).balanceOf(pool).mul(weight)).div(100); 
                perlTotal = perlTotal.add(weightedBalance);
                mapEraPool_Balance[era][pool] = weightedBalance;
            }
        }
        mapEra_Total[era] = perlTotal;
        
        for (uint256 i = start; i < end; i++) {
            address pool = arrayPerlinPools[i];
            if (poolIsListed[pool] && poolHasMembers[pool]) {
                validMemberCount = validMemberCount.add(1);
                uint256 part = mapEraPool_Balance[era][pool];
                mapEraPool_Share[era][pool] = getShare(
                    part,
                    perlTotal,
                    rewardForEra
                );
            }
        }
        emit Snapshot(
            msg.sender,
            era,
            rewardForEra,
            perlTotal,
            validPoolCount,
            validMemberCount,
            now
        );
    }

    
    
    function removeReward(uint256 era, address rewardAsset) public onlyAdmin {
      uint256 amount = mapEraAsset_Reward[era][rewardAsset];
      mapEraAsset_Reward[era][rewardAsset] = 0;
      mapAsset_Rewards[rewardAsset] = mapAsset_Rewards[rewardAsset].sub(
          amount
      );
      eraIsOpen[era] = false;
      require(
            ERC20(rewardAsset).transfer(treasury, amount),
            "Must transfer"
        );
    }

    
    
    function sweep(address asset, uint256 amount) public onlyAdmin {
      require(
            ERC20(asset).transfer(treasury, amount),
            "Must transfer"
        );
    }

    
    
    function lock(address pool, uint256 amount) public nonReentrant {
        require(poolIsListed[pool] == true, "Must be listed");
        if (!isMember[msg.sender]) {
            
            arrayMembers.push(msg.sender);
            isMember[msg.sender] = true;
        }
        if (!poolHasMembers[pool]) {
            
            poolHasMembers[pool] = true;
        }
        if (!mapMemberPool_Added[msg.sender][pool]) {
            
            mapMember_poolCount[msg.sender] = mapMember_poolCount[msg.sender]
                .add(1);
            mapMember_arrayPools[msg.sender].push(pool);
            mapMemberPool_Added[msg.sender][pool] = true;
        }
        require(
            ERC20(pool).transferFrom(msg.sender, address(this), amount),
            "Must transfer"
        ); 
        mapMemberPool_Balance[msg.sender][pool] = mapMemberPool_Balance[msg.sender][pool]
            .add(amount); 
        registerClaim(msg.sender, pool, amount); 
        emit MemberLocks(msg.sender, pool, amount, currentEra);
    }

    
    function unlock(address pool) public nonReentrant {
        uint256 balance = mapMemberPool_Balance[msg.sender][pool];
        require(balance > 0, "Must have a balance to claim");
        mapMemberPool_Balance[msg.sender][pool] = 0; 
        require(ERC20(pool).transfer(msg.sender, balance), "Must transfer"); 
        if (ERC20(pool).balanceOf(address(this)) == 0) {
            poolHasMembers[pool] = false; 
        }
        emit MemberUnlocks(msg.sender, pool, balance, currentEra);
    }

    
    
    function registerClaim(
        address member,
        address pool,
        uint256 amount
    ) internal {
        mapMemberEraPool_Claim[member][currentEra][pool] += amount;
        mapEraPool_Claims[currentEra][pool] = mapEraPool_Claims[currentEra][pool]
            .add(amount);
        emit MemberRegisters(member, pool, amount, currentEra);
    }

    
    function registerAllClaims(address member) public {
        require(
            mapMemberEra_hasRegistered[msg.sender][currentEra] == false,
            "Must not have registered in this era already"
        );
        for (uint256 i = 0; i < mapMember_poolCount[member]; i++) {
            address pool = mapMember_arrayPools[member][i];
            
            mapEraPool_Claims[currentEra][pool] = mapEraPool_Claims[currentEra][pool]
                .sub(mapMemberEraPool_Claim[member][currentEra][pool]);
            uint256 amount = mapMemberPool_Balance[member][pool]; 
            mapMemberEraPool_Claim[member][currentEra][pool] = amount; 
            mapEraPool_Claims[currentEra][pool] = mapEraPool_Claims[currentEra][pool]
                .add(amount); 
            emit MemberRegisters(member, pool, amount, currentEra);
        }
        mapMemberEra_hasRegistered[msg.sender][currentEra] = true;
    }

    
    function claim(uint256 era, address rewardAsset)
        public
        nonReentrant
    {
        require(
            mapMemberEraAsset_hasClaimed[msg.sender][era][rewardAsset] == false,
            "Reward asset must not have been claimed"
        );
        require(eraIsOpen[era], "Era must be opened");
        uint256 totalClaim = checkClaim(msg.sender, era);
        if (totalClaim > 0) {
            mapMemberEraAsset_hasClaimed[msg.sender][era][rewardAsset] = true; 
            mapEraAsset_Reward[era][rewardAsset] = mapEraAsset_Reward[era][rewardAsset]
                .sub(totalClaim); 
            mapAsset_Rewards[rewardAsset] = mapAsset_Rewards[rewardAsset].sub(
                totalClaim
            ); 
            require(
                ERC20(rewardAsset).transfer(msg.sender, totalClaim),
                "Must transfer"
            ); 
        }
        emit MemberClaims(msg.sender, era, totalClaim);
        if (mapMemberEra_hasRegistered[msg.sender][currentEra] == false) {
            registerAllClaims(msg.sender); 
        }
    }

    
    function checkClaim(address member, uint256 era)
        public
        view
        returns (uint256 totalClaim)
    {
        for (uint256 i = 0; i < mapMember_poolCount[member]; i++) {
            address pool = mapMember_arrayPools[member][i];
            totalClaim += checkClaimInPool(member, era, pool);
        }
        return totalClaim;
    }

    
    function checkClaimInPool(
        address member,
        uint256 era,
        address pool
    ) public view returns (uint256 claimShare) {
        uint256 poolShare = mapEraPool_Share[era][pool]; 
        uint256 memberClaimInEra = mapMemberEraPool_Claim[member][era][pool]; 
        uint256 totalClaimsInEra = mapEraPool_Claims[era][pool]; 
        if (totalClaimsInEra > 0) {
            
            claimShare = getShare(
                memberClaimInEra,
                totalClaimsInEra,
                poolShare
            );
        } else {
            claimShare = 0;
        }
        return claimShare;
    }

    
    
    function getShare(
        uint256 part,
        uint256 total,
        uint256 amount
    ) public pure returns (uint256 share) {
        return (amount.mul(part)).div(total);
    }

    function adminCount() public view returns (uint256) {
        return arrayAdmins.length;
    }

    function poolCount() public view returns (uint256) {
        return arrayPerlinPools.length;
    }

    function synthCount() public view returns (uint256) {
        return arraySynths.length;
    }

    function memberCount() public view returns (uint256) {
        return arrayMembers.length;
    }
}