pragma solidity 0.5.8;


contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}




pragma solidity 0.5.8;


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity 0.5.8;


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


















pragma solidity 0.5.8;

contract LibNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  usr,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes             data
    ) anonymous;

    modifier note {
        _;
        
        assembly {
            
            
            let mark := msize                         
            mstore(0x40, add(mark, 288))              
            mstore(mark, 0x20)                        
            mstore(add(mark, 0x20), 224)              
            calldatacopy(add(mark, 0x40), 0, 224)     
            log4(mark, 288,                           
                 shl(224, shr(224, calldataload(0))), 
                 caller,                              
                 calldataload(4),                     
                 calldataload(36)                     
                )
        }
    }
}




















pragma solidity 0.5.8;


contract Dai is LibNote {
    
    mapping (address => uint) public wards;
    function rely(address guy) external note auth { wards[guy] = 1; }
    function deny(address guy) external note auth { wards[guy] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Dai/not-authorized");
        _;
    }

    
    string  public constant name     = "Dai Stablecoin";
    string  public constant symbol   = "DAI";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint)                      public nonces;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }

    
    bytes32 public DOMAIN_SEPARATOR;
    
    bytes32 public constant PERMIT_TYPEHASH = 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;

    constructor(uint256 chainId_) public {
        wards[msg.sender] = 1;
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId_,
            address(this)
        ));
    }

    
    function transfer(address dst, uint wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad)
        public returns (bool)
    {
        require(balanceOf[src] >= wad, "Dai/insufficient-balance");
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "Dai/insufficient-allowance");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
    }
    function mint(address usr, uint wad) external auth {
        balanceOf[usr] = add(balanceOf[usr], wad);
        totalSupply    = add(totalSupply, wad);
        emit Transfer(address(0), usr, wad);
    }
    function burn(address usr, uint wad) external {
        require(balanceOf[usr] >= wad, "Dai/insufficient-balance");
        if (usr != msg.sender && allowance[usr][msg.sender] != uint(-1)) {
            require(allowance[usr][msg.sender] >= wad, "Dai/insufficient-allowance");
            allowance[usr][msg.sender] = sub(allowance[usr][msg.sender], wad);
        }
        balanceOf[usr] = sub(balanceOf[usr], wad);
        totalSupply    = sub(totalSupply, wad);
        emit Transfer(usr, address(0), wad);
    }
    function approve(address usr, uint wad) external returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }

    
    function push(address usr, uint wad) external {
        transferFrom(msg.sender, usr, wad);
    }
    function pull(address usr, uint wad) external {
        transferFrom(usr, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) external {
        transferFrom(src, dst, wad);
    }

    
    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) external
    {
        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH,
                                     holder,
                                     spender,
                                     nonce,
                                     expiry,
                                     allowed))
        ));

        require(holder != address(0), "Dai/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Dai/invalid-permit");
        require(expiry == 0 || now <= expiry, "Dai/permit-expired");
        require(nonce == nonces[holder]++, "Dai/invalid-nonce");
        uint wad = allowed ? uint(-1) : 0;
        allowance[holder][spender] = wad;
        emit Approval(holder, spender, wad);
    }
}






pragma solidity 0.5.8;


library AddressUtils {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}



pragma solidity 0.5.8;







contract ReserveBank is Ownable {
    using SafeMath for uint256;
    using AddressUtils for address;

    Dai public token;

    constructor(address _daiAddress) public {
        require(_daiAddress.isContract(), "The address should be a contract");
        token = Dai(_daiAddress);
    }

    
    function withdraw(address _receiver, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        require(_receiver != address(0), "Receiver must not be 0 address");
        return token.transfer(_receiver, _amount);
    }
}



pragma solidity 0.5.8;


contract Registry is Ownable {
    
    
    

    struct Member {
        uint256 challengeID;
        uint256 memberStartTime; 
    }

    
    mapping(address => Member) public members;

    
    
    

    
    function getChallengeID(address _member) external view returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = members[_member];
        return member.challengeID;
    }

    
    function getMemberStartTime(address _member) external view returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = members[_member];
        return member.memberStartTime;
    }

    
    
    

    
    function setMember(address _member) external onlyOwner returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = Member({
            challengeID: 0,
            
            memberStartTime: now
        });
        members[_member] = member;

        
        return now;
    }

    
    function editChallengeID(address _member, uint256 _newChallengeID) external onlyOwner {
        require(_member != address(0), "Can't check 0 address");
        Member storage member = members[_member];
        member.challengeID = _newChallengeID;
    }

    
    function deleteMember(address _member) external onlyOwner {
        require(_member != address(0), "Can't check 0 address");
        delete members[_member];
    }
}




pragma solidity 0.5.8;

contract EthereumDIDRegistry {
    mapping(address => address) public owners;
    mapping(address => mapping(bytes32 => mapping(address => uint256))) public delegates;
    mapping(address => uint256) public changed;
    mapping(address => uint256) public nonce;

    modifier onlyOwner(address identity, address actor) {
        require(actor == identityOwner(identity), "Caller must be the identity owner");
        _;
    }

    event DIDOwnerChanged(address indexed identity, address owner, uint256 previousChange);

    event DIDDelegateChanged(
        address indexed identity,
        bytes32 delegateType,
        address delegate,
        uint256 validTo,
        uint256 previousChange
    );

    event DIDAttributeChanged(
        address indexed identity,
        bytes32 name,
        bytes value,
        uint256 validTo,
        uint256 previousChange
    );

    function identityOwner(address identity) public view returns (address) {
        address owner = owners[identity];
        if (owner != address(0)) {
            return owner;
        }
        return identity;
    }

    function checkSignature(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 hash)
        internal
        returns (address)
    {
        address signer = ecrecover(hash, sigV, sigR, sigS);
        require(signer == identityOwner(identity), "Signer must be the identity owner");
        nonce[signer]++;
        return signer;
    }

    function validDelegate(address identity, bytes32 delegateType, address delegate)
        public
        view
        returns (bool)
    {
        uint256 validity = delegates[identity][keccak256(abi.encode(delegateType))][delegate];
        
        return (validity > now);
    }

    function changeOwner(address identity, address actor, address newOwner)
        internal
        onlyOwner(identity, actor)
    {
        owners[identity] = newOwner;
        emit DIDOwnerChanged(identity, newOwner, changed[identity]);
        changed[identity] = block.number;
    }

    function changeOwner(address identity, address newOwner) public {
        changeOwner(identity, msg.sender, newOwner);
    }

    function changeOwnerSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        address newOwner
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "changeOwner",
                newOwner
            )
        );
        changeOwner(identity, checkSignature(identity, sigV, sigR, sigS, hash), newOwner);
    }

    function addDelegate(
        address identity,
        address actor,
        bytes32 delegateType,
        address delegate,
        uint256 validity
    ) internal onlyOwner(identity, actor) {
        
        delegates[identity][keccak256(abi.encode(delegateType))][delegate] = now + validity;
        emit DIDDelegateChanged(
            identity,
            delegateType,
            delegate,
            
            now + validity,
            changed[identity]
        );
        changed[identity] = block.number;
    }

    function addDelegate(address identity, bytes32 delegateType, address delegate, uint256 validity)
        public
    {
        addDelegate(identity, msg.sender, delegateType, delegate, validity);
    }

    function addDelegateSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 delegateType,
        address delegate,
        uint256 validity
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "addDelegate",
                delegateType,
                delegate,
                validity
            )
        );
        addDelegate(
            identity,
            checkSignature(identity, sigV, sigR, sigS, hash),
            delegateType,
            delegate,
            validity
        );
    }

    function revokeDelegate(address identity, address actor, bytes32 delegateType, address delegate)
        internal
        onlyOwner(identity, actor)
    {
        
        delegates[identity][keccak256(abi.encode(delegateType))][delegate] = now;
        
        emit DIDDelegateChanged(identity, delegateType, delegate, now, changed[identity]);
        changed[identity] = block.number;
    }

    function revokeDelegate(address identity, bytes32 delegateType, address delegate) public {
        revokeDelegate(identity, msg.sender, delegateType, delegate);
    }

    function revokeDelegateSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 delegateType,
        address delegate
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "revokeDelegate",
                delegateType,
                delegate
            )
        );
        revokeDelegate(
            identity,
            checkSignature(identity, sigV, sigR, sigS, hash),
            delegateType,
            delegate
        );
    }

    function setAttribute(
        address identity,
        address actor,
        bytes32 name,
        bytes memory value,
        uint256 validity
    ) internal onlyOwner(identity, actor) {
        
        emit DIDAttributeChanged(identity, name, value, now + validity, changed[identity]);
        changed[identity] = block.number;
    }

    function setAttribute(address identity, bytes32 name, bytes memory value, uint256 validity)
        public
    {
        setAttribute(identity, msg.sender, name, value, validity);
    }

    function setAttributeSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 name,
        bytes memory value,
        uint256 validity
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "setAttribute",
                name,
                value,
                validity
            )
        );
        setAttribute(
            identity,
            checkSignature(identity, sigV, sigR, sigS, hash),
            name,
            value,
            validity
        );
    }

    function revokeAttribute(address identity, address actor, bytes32 name, bytes memory value)
        internal
        onlyOwner(identity, actor)
    {
        emit DIDAttributeChanged(identity, name, value, 0, changed[identity]);
        changed[identity] = block.number;
    }

    function revokeAttribute(address identity, bytes32 name, bytes memory value) public {
        revokeAttribute(identity, msg.sender, name, value);
    }

    function revokeAttributeSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 name,
        bytes memory value
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "revokeAttribute",
                name,
                value
            )
        );
        revokeAttribute(identity, checkSignature(identity, sigV, sigR, sigS, hash), name, value);
    }

}






pragma solidity 0.5.8;


library ABDKMath64x64 {
  
  function fromUInt (uint256 x) internal pure returns (int128) {
    require (x <= 0x7FFFFFFFFFFFFFFF);
    return int128 (x << 64);
  }

  
  function toUInt (int128 x) internal pure returns (uint64) {
    require (x >= 0);
    return uint64 (x >> 64);
  }

  
  function sqrt (int128 x) internal pure returns (int128) {
    require (x >= 0);
    return int128 (sqrtu (uint256 (x) << 64, 0x10000000000000000));
  }

  
  function sqrtu (uint256 x, uint256 r) private pure returns (uint128) {
    if (x == 0) return 0;
    else {
      require (r > 0);
      while (true) {
        uint256 rr = x / r;
        if (r == rr || r + 1 == rr) return uint128 (r);
        else if (r == rr + 1) return uint128 (rr);
        r = r + rr + 1 >> 1;
      }
    }
  }
}




pragma solidity 0.5.8;








contract Everest is Ownable {
    using SafeMath for uint256;
    using ABDKMath64x64 for uint256;
    using ABDKMath64x64 for int128;
    using AddressUtils for address;

    
    
    

    
    uint256 public votingPeriodDuration;
    
    uint256 public challengeDeposit;
    
    uint256 public applicationFee;
    
    bytes32 public charter;
    
    bytes32 public categories;
    
    bool public challengesFrozen;

    
    Dai public approvedToken;
    
    ReserveBank public reserveBank;
    
    EthereumDIDRegistry public erc1056Registry;
    
    Registry public registry;

    
    
    
    bytes32 constant delegateType = 0x6576657265737400000000000000000000000000000000000000000000000000;

    mapping (uint256 => Challenge) public challenges;
    
    
    uint256 public challengeCounter;

    
    
    

    
    event NewMember(address indexed member, uint256 startTime, uint256 fee);
    event MemberExited(address indexed member);
    event CharterUpdated(bytes32 indexed data);
    event CategoriesUpdated(bytes32 indexed data);
    event Withdrawal(address indexed receiver, uint256 amount);
    event VotingDurationUpdated(uint256 indexed duration);
    event ChallengeDepositUpdated(uint256 indexed deposit);
    event ApplicationFeeUpdated(uint256 indexed fee);
    event ChallengesFrozen(bool isFrozen);


    event EverestDeployed(
        address owner,
        address approvedToken,
        uint256 votingPeriodDuration,
        uint256 challengeDeposit,
        uint256 applicationFee,
        bytes32 charter,
        bytes32 categories,
        address didRegistry,
        address reserveBank,
        address registry,
        uint256 startingChallengeID
    );

    event MemberChallenged(
        address indexed member,
        uint256 indexed challengeID,
        address indexed challenger,
        uint256 challengeEndTime,
        bytes32 details
    );

    event SubmitVote(
        uint256 indexed challengeID,
        address indexed submitter,      
        address indexed votingMember,
        VoteChoice voteChoice,
        uint256 voteWeight
    );

    event ChallengeFailed(
        address indexed member,
        uint256 indexed challengeID,
        uint256 yesVotes,
        uint256 noVotes,
        uint256 voterCount,
        uint256 resolverReward
    );

    event ChallengeSucceeded(
        address indexed member,
        uint256 indexed challengeID,
        uint256 yesVotes,
        uint256 noVotes,
        uint256 voterCount,
        uint256 challengerReward,
        uint256 resolverReward
    );

    
    
    

    enum VoteChoice {
        Null, 
        Yes,
        No
    }

    struct Challenge {
        address challenger;         
        address challengee;         
        uint256 yesVotes;           
        uint256 noVotes;            
        uint256 voterCount;         
        uint256 endTime;            
        bytes32 details;            
        mapping (address => VoteChoice) voteChoiceByMember;     
        mapping (address => uint256) voteWeightByMember;        
    }

    
    
    

    
    modifier onlyMemberOwnerOrDelegate(address _member) {
        require(
            isMember(_member),
            "onlyMemberOwnerOrDelegate - Address is not a Member"
        );
        address memberOwner = erc1056Registry.identityOwner(_member);
        bool validDelegate = erc1056Registry.validDelegate(_member, delegateType, msg.sender);
        require(
            validDelegate || memberOwner == msg.sender,
            "onlyMemberOwnerOrDelegate - Caller must be delegate or owner"
        );
        _;
    }

    
    modifier onlyMemberOwner(address _member) {
        require(
            isMember(_member),
            "onlyMemberOwner - Address is not a member"
        );
        address memberOwner = erc1056Registry.identityOwner(_member);
        require(
            memberOwner == msg.sender,
            "onlyMemberOwner - Caller must be the owner"
        );
        _;
    }

    
    
    

    constructor(
        address _approvedToken,
        uint256 _votingPeriodDuration,
        uint256 _challengeDeposit,
        uint256 _applicationFee,
        bytes32 _charter,
        bytes32 _categories,
        address _DIDregistry,
        address _reserveBank,
        address _registry,
        uint256 _startingChallengeID
    ) public {
        require(_approvedToken.isContract(), "The _approvedToken address should be a contract");
        require(_DIDregistry.isContract(), "The _DIDregistry address should be a contract");
        require(_reserveBank.isContract(), "The _reserveBank address should be a contract");
        require(_registry.isContract(), "The _registry address should be a contract");
        require(_votingPeriodDuration > 0, "constructor - _votingPeriodDuration cannot be 0");
        require(_challengeDeposit > 0, "constructor - _challengeDeposit cannot be 0");
        require(_applicationFee > 0, "constructor - _applicationFee cannot be 0");
        require(_startingChallengeID != 0, "constructor - _startingChallengeID cannot be 0");

        approvedToken = Dai(_approvedToken);
        votingPeriodDuration = _votingPeriodDuration;
        challengeDeposit = _challengeDeposit;
        applicationFee = _applicationFee;
        charter = _charter;
        categories = _categories;
        erc1056Registry = EthereumDIDRegistry(_DIDregistry);
        reserveBank = ReserveBank(_reserveBank);
        registry = Registry(_registry);
        challengeCounter = _startingChallengeID;

        emit EverestDeployed(
            msg.sender,             
            _approvedToken,
            _votingPeriodDuration,
            _challengeDeposit,
            _applicationFee,
            _charter,
            _categories,
            _DIDregistry,
            _reserveBank,
            _registry,
            _startingChallengeID
        );
    }

    
    
    

    
    function applySignedWithAttributeAndPermit(
        address _newMember,
        uint8[3] calldata _sigV,
        bytes32[3] calldata _sigR,
        bytes32[3] calldata _sigS,
        address _memberOwner,
        bytes32 _offChainDataName,
        bytes calldata _offChainDataValue,
        uint256 _offChainDataValidity
    ) external {
        require(_newMember != address(0), "Member can't be 0 address");
        require(_memberOwner != address(0), "Owner can't be 0 address");
        applySignedWithAttributeAndPermitInternal(
            _newMember,
            _sigV,
            _sigR,
            _sigS,
            _memberOwner,
            _offChainDataName,
            _offChainDataValue,
            _offChainDataValidity
        );
    }

    
    
    function applySignedWithAttributeAndPermitInternal(
        address _newMember,
        uint8[3] memory _sigV,
        bytes32[3] memory _sigR,
        bytes32[3] memory _sigS,
        address _memberOwner,
        bytes32 _offChainDataName,
        bytes memory _offChainDataValue,
        uint256 _offChainDataValidity
    ) internal {
        
        
        uint256 nonce = approvedToken.nonces(_memberOwner);
        approvedToken.permit(_memberOwner, address(this), nonce, 0, true, _sigV[2], _sigR[2], _sigS[2]);

        applySignedWithAttribute(
            _newMember,
            [_sigV[0], _sigV[1]],
            [_sigR[0], _sigR[1]],
            [_sigS[0], _sigS[1]],
            _memberOwner,
            _offChainDataName,
            _offChainDataValue,
            _offChainDataValidity
        );
    }

    
    function applySignedWithAttribute(
        address _newMember,
        uint8[2] memory _sigV,
        bytes32[2] memory _sigR,
        bytes32[2] memory _sigS,
        address _memberOwner,
        bytes32 _offChainDataName,
        bytes memory _offChainDataValue,
        uint256 _offChainDataValidity
    ) public {
        require(_newMember != address(0), "Member can't be 0 address");
        require(_memberOwner != address(0), "Owner can't be 0 address");
        require(
            registry.getMemberStartTime(_newMember) == 0,
            "applySignedInternal - This member already exists"
        );
        uint256 startTime = registry.setMember(_newMember);

        
        
        
        
        emit NewMember(
            _newMember,
            startTime,
            applicationFee
        );

        erc1056Registry.setAttributeSigned(
            _newMember,
            _sigV[0],
            _sigR[0],
            _sigS[0],
            _offChainDataName,
            _offChainDataValue,
            _offChainDataValidity
        );

        erc1056Registry.changeOwnerSigned(_newMember, _sigV[1], _sigR[1], _sigS[1], _memberOwner);

        
        require(
            approvedToken.transferFrom(_memberOwner, address(reserveBank), applicationFee),
            "applySignedInternal - Token transfer failed"
        );
    }

    
    function memberExit(
        address _member
    ) external onlyMemberOwner(_member) {
        require(_member != address(0), "Member can't be 0 address");
        require(
            !memberChallengeExists(_member),
            "memberExit - Can't exit during ongoing challenge"
        );
        registry.deleteMember(_member);
        emit MemberExited(_member);
    }

    
    
    

    
    function challenge(
        address _challenger,
        address _challengee,
        bytes32 _details
    ) external onlyMemberOwner(_challenger) returns (uint256 challengeID) {
        require(_challenger != address(0), "Challenger can't be 0 address");
        require(isMember(_challengee), "challenge - Challengee must exist");
        require(
            _challenger != _challengee,
            "challenge - Can't challenge self"
        );
        require(challengesFrozen != true, "challenge - Cannot create challenge, frozen");
        uint256 currentChallengeID = registry.getChallengeID(_challengee);
        require(currentChallengeID == 0, "challenge - Existing challenge must be resolved first");

        uint256 newChallengeID = challengeCounter;
        Challenge memory newChallenge = Challenge({
            challenger: _challenger,
            challengee: _challengee,
            
            yesVotes: 0,
            noVotes: 0,
            voterCount: 0,
            
            endTime: now.add(votingPeriodDuration),
            details: _details
        });
        challengeCounter = challengeCounter.add(1);

        challenges[newChallengeID] = newChallenge;

        
        registry.editChallengeID(_challengee, newChallengeID);

        
        require(
            approvedToken.transferFrom(msg.sender, address(reserveBank), challengeDeposit),
            "challenge - Token transfer failed"
        );

        emit MemberChallenged(
            _challengee,
            newChallengeID,
            _challenger,
            
            now.add(votingPeriodDuration),
            newChallenge.details
        );

        
        submitVote(newChallengeID, VoteChoice.Yes, _challenger);
        return newChallengeID;
    }

    
    function submitVote(
        uint256 _challengeID,
        VoteChoice _voteChoice,
        address _votingMember
    ) public onlyMemberOwnerOrDelegate(_votingMember) {
        require(_votingMember != address(0), "Member can't be 0 address");
        require(
            _voteChoice == VoteChoice.Yes || _voteChoice == VoteChoice.No,
            "submitVote - Vote must be either Yes or No"
        );

        Challenge storage storedChallenge = challenges[_challengeID];
        require(
            storedChallenge.endTime > 0,
            "submitVote - Challenge does not exist"
        );
        require(
            !hasVotingPeriodExpired(storedChallenge.endTime),
            "submitVote - Challenge voting period has expired"
        );
        require(
            storedChallenge.voteChoiceByMember[_votingMember] == VoteChoice.Null,
            "submitVote - Member has already voted on this challenge"
        );

        require(
            storedChallenge.challengee != _votingMember,
            "submitVote - Member can't vote on their own challenge"
        );

        uint256 startTime = registry.getMemberStartTime(_votingMember);
        
        uint256 voteWeightSquared = storedChallenge.endTime.sub(startTime);

        
        
        
        int128 sixtyFourBitFPInt = voteWeightSquared.fromUInt();
        int128 voteWeightInt128 = sixtyFourBitFPInt.sqrt();
        uint256 voteWeight = uint256(voteWeightInt128.toUInt());

        
        storedChallenge.voteChoiceByMember[_votingMember] = _voteChoice;
        storedChallenge.voteWeightByMember[_votingMember] = voteWeight;
        storedChallenge.voterCount = storedChallenge.voterCount.add(1);

        
        if (_voteChoice == VoteChoice.Yes) {
            storedChallenge.yesVotes = storedChallenge.yesVotes.add(voteWeight);
        } else if (_voteChoice == VoteChoice.No) {
            storedChallenge.noVotes = storedChallenge.noVotes.add(voteWeight);
        }

        emit SubmitVote(_challengeID, msg.sender, _votingMember, _voteChoice, voteWeight);
    }

    
    function submitVotes(
        uint256 _challengeID,
        VoteChoice[] calldata _voteChoices,
        address[] calldata _voters
    ) external {
        require(
            _voteChoices.length == _voters.length,
            "submitVotes - Arrays must be equal"
        );
        require(_voteChoices.length < 90, "submitVotes - Array should be < 90 to avoid going over the block gas limit");
        for (uint256 i; i < _voteChoices.length; i++){
            submitVote(_challengeID, _voteChoices[i], _voters[i]);
        }
    }

    
    function resolveChallenge(uint256 _challengeID) external {
        challengeCanBeResolved(_challengeID);
        Challenge storage storedChallenge = challenges[_challengeID];

        bool didPass = storedChallenge.yesVotes > storedChallenge.noVotes;
        bool moreThanOneVote = storedChallenge.voterCount > 1;
        
        
        uint256 challengeRewardDivisor = 10;
        uint256 resolverReward = challengeDeposit.div(challengeRewardDivisor);

        if (didPass && moreThanOneVote) {
            address challengerOwner = erc1056Registry.identityOwner(storedChallenge.challenger);

            
            
            uint256 challengerReward = challengeDeposit.add(applicationFee).sub(resolverReward);
            require(
                reserveBank.withdraw(challengerOwner, challengerReward),
                "resolveChallenge - Rewarding challenger failed"
            );
            
            require(
                reserveBank.withdraw(msg.sender, resolverReward),
                "resolveChallenge - Rewarding resolver failed"
            );

            registry.deleteMember(storedChallenge.challengee);
            emit ChallengeSucceeded(
                storedChallenge.challengee,
                _challengeID,
                storedChallenge.yesVotes,
                storedChallenge.noVotes,
                storedChallenge.voterCount,
                challengerReward,
                resolverReward
            );

        } else {
            
            require(
                reserveBank.withdraw(msg.sender, resolverReward),
                "resolveChallenge - Rewarding resolver failed"
            );

            
            registry.editChallengeID(storedChallenge.challengee, 0);
            emit ChallengeFailed(
                storedChallenge.challengee,
                _challengeID,
                storedChallenge.yesVotes,
                storedChallenge.noVotes,
                storedChallenge.voterCount,
                resolverReward
            );
        }

        
        delete challenges[_challengeID];
    }

    
    
    

    
    function withdraw(address _receiver, uint256 _amount) external onlyOwner returns (bool) {
        require(_receiver != address(0), "Receiver must not be 0 address");
        require(_amount > 0, "Amount must be greater than 0");
        emit Withdrawal(_receiver, _amount);
        return reserveBank.withdraw(_receiver, _amount);
    }

    
    function transferOwnershipReserveBank(address _newOwner) external onlyOwner {
        reserveBank.transferOwnership(_newOwner);
    }

    
    function transferOwnershipRegistry(address _newOwner) external onlyOwner {
        registry.transferOwnership(_newOwner);
    }

    
    function updateCharter(bytes32 _newCharter) external onlyOwner {
        charter = _newCharter;
        emit CharterUpdated(charter);
    }

    
    function updateCategories(bytes32 _newCategories) external onlyOwner {
        categories = _newCategories;
        emit CategoriesUpdated(categories);
    }

    
    function updateVotingPeriodDuration(uint256 _newVotingDuration) external onlyOwner {
        votingPeriodDuration = _newVotingDuration;
        emit VotingDurationUpdated(votingPeriodDuration);
    }

    
    function updateChallengeDeposit(uint256 _newDeposit) external onlyOwner {
        challengeDeposit = _newDeposit;
        emit ChallengeDepositUpdated(challengeDeposit);
    }

    
    function updateApplicationFee(uint256 _newFee) external onlyOwner {
        applicationFee = _newFee;
        emit ApplicationFeeUpdated(applicationFee);
    }

    
    function updateChallengeFreeze(bool _isFrozen) external onlyOwner {
        challengesFrozen = _isFrozen;
        emit ChallengesFrozen(challengesFrozen);
    }

    
    
    


    
    function hasVotingPeriodExpired(uint256 _endTime) private view returns (bool) {
        
        return now >= _endTime;
    }

    
    function isMember(address _member) public view returns (bool){
        require(_member != address(0), "Member can't be 0 address");
        uint256 startTime = registry.getMemberStartTime(_member);
        if (startTime > 0){
            return true;
        }
        return false;
    }

    
    function memberChallengeExists(address _member) public view returns (bool) {
        require(_member != address(0), "Member can't be 0 address");
        uint256 challengeID = registry.getChallengeID(_member);
        return (challengeID > 0);
    }

    
    function challengeCanBeResolved(uint256 _challengeID) private view {
        Challenge storage storedChallenge = challenges[_challengeID];
        require(
            challenges[_challengeID].endTime > 0,
            "challengeCanBeResolved - Challenge does not exist or was completed"
        );
        require(
            hasVotingPeriodExpired(storedChallenge.endTime),
            "challengeCanBeResolved - Current challenge is not ready to be resolved"
        );
    }
}