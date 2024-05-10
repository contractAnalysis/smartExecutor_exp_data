pragma solidity ^0.5.0;

interface ENS {

    
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    
    event Transfer(bytes32 indexed node, address owner);

    
    event NewResolver(bytes32 indexed node, address resolver);

    
    event NewTTL(bytes32 indexed node, uint64 ttl);

    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns(bytes32);
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function setApprovalForAll(address operator, bool approved) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);
    function recordExists(bytes32 node) external view returns (bool);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract Registrar {
  function approve(address to, uint256 tokenId) public;
  function transferFrom(address from, address to, uint256 tokenId) public;
  function ownerOf(uint256 tokenId) public view returns (address owner);
  function reclaim(uint256 id, address owner) external;
}

contract Resolver {
   function supportsInterface(bytes4 interfaceID) public pure returns (bool);
   function addr(bytes32 node) public view returns (address);
   function setAddr(bytes32 node, address addr) public;
}

contract IMinion {
  function moloch() public view returns (address);
}

contract IMoloch {
  function members(address) public view returns (address, uint256, uint256, bool, uint256, uint256);
}



contract MinionSubdomainRegistrar {
    
    bytes32 constant public TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

    ENS public ens;

    address public registrar;
    address public registrarOwner;
    address public migration;
    bool public stopped = false;

    struct Domain {
        string name;
        address owner;
        address minion;
        address moloch;
    }

    mapping (bytes32 => Domain) domains;

    modifier owner_only(bytes32 label) {
        require(owner(label) == msg.sender);
        _;
    }

    modifier not_stopped() {
        require(!stopped);
        _;
    }

    modifier registrar_owner_only() {
        require(msg.sender == registrarOwner);
        _;
    }

    event TransferAddressSet(bytes32 indexed label, address addr);
    event DomainTransferred(bytes32 indexed label, string name);
    event OwnerChanged(bytes32 indexed label, address indexed oldOwner, address indexed newOwner);
    event DomainConfigured(bytes32 indexed label, string domain, address indexed minion);
    event DomainUnlisted(bytes32 indexed label);
    event NewRegistration(bytes32 indexed label, string subdomain, address indexed owner);

    constructor(ENS _ens) public {
        ens = _ens;
        registrar = ens.owner(TLD_NODE);
        registrarOwner = msg.sender;
    }

    

    function transferOwnership(address newOwner) public registrar_owner_only {
        registrarOwner = newOwner;
    }

    
    function setMigrationAddress(address _migration) public registrar_owner_only {
        require(stopped);
        migration = _migration;
    }

    
    function stop() public not_stopped registrar_owner_only {
        stopped = true;
    }

    

    
    function setResolver(string memory name, address resolver) public owner_only(keccak256(bytes(name))) {
        bytes32 label = keccak256(bytes(name));
        bytes32 node = keccak256(abi.encodePacked(TLD_NODE, label));
        ens.setResolver(node, resolver);
    }

    
    function transfer(string memory name, address newOwner) public owner_only(keccak256(bytes(name))) {
        bytes32 label = keccak256(bytes(name));
        emit OwnerChanged(label, domains[label].owner, newOwner);
        domains[label].owner = newOwner;
    }

    
    function unlistDomain(string memory name) public owner_only(keccak256(bytes(name))) {
        bytes32 label = keccak256(bytes(name));
        Registrar(registrar).reclaim(uint256(label), domains[label].owner);
        Registrar(registrar).transferFrom(address(this), domains[label].owner, uint256(label));
        delete domains[label];
        emit DomainUnlisted(label);
    }

    

    
    function configureDomain(string memory name, address minion) public {
        configureDomainFor(name, minion, msg.sender);
    }

    
    function configureDomainFor(string memory name, address minion, address _owner) public not_stopped owner_only(keccak256(bytes(name))) {
        bytes32 label = keccak256(bytes(name));
        Domain storage domain = domains[label];

        if (Registrar(registrar).ownerOf(uint256(label)) != address(this)) {
            Registrar(registrar).transferFrom(msg.sender, address(this), uint256(label));
            Registrar(registrar).reclaim(uint256(label), address(this));
        }

        if (domain.owner != _owner) {
            domain.owner = _owner;
        }

        if (keccak256(abi.encodePacked(domain.name)) != label) {
            
            domain.name = name;
        }

        domain.minion = minion;
        domain.moloch = IMinion(minion).moloch();

        emit DomainConfigured(label, name, minion);
    }

    

    
    function migrate(string memory name) public owner_only(keccak256(bytes(name))) {
        require(stopped);
        require(migration != address(0x0));

        bytes32 label = keccak256(bytes(name));
        Domain storage domain = domains[label];

        Registrar(registrar).approve(migration, uint256(label));

        MinionSubdomainRegistrar(migration).configureDomainFor(
            domain.name,
            domain.minion,
            domain.owner
        );

        delete domains[label];

        emit DomainTransferred(label, name);
    }

    

    
    function register(bytes32 label, string calldata subdomain, address _subdomainOwner, address resolver) external not_stopped {
        address subdomainOwner = _subdomainOwner;
        bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));
        bytes32 subdomainLabel = keccak256(bytes(subdomain));

        
        require(ens.owner(keccak256(abi.encodePacked(domainNode, subdomainLabel))) == address(0));

        Domain storage domain = domains[label];

        
        require(keccak256(abi.encodePacked(domain.name)) == label);

        
        if (subdomainOwner == address(0x0)) {
            subdomainOwner = msg.sender;
        }

        
        if (msg.sender != domain.minion) {
          
          ( , uint256 ownerStakes, , , , ) = IMoloch(domain.moloch).members(subdomainOwner);
          ( , uint256 senderStakes, , , , ) = IMoloch(domain.moloch).members(msg.sender);
          require(senderStakes > 0 && ownerStakes > 0);
        }

        doRegistration(domainNode, subdomainLabel, subdomainOwner, Resolver(resolver));

        emit NewRegistration(label, subdomain, subdomainOwner);
    }

    function deregister(bytes32 label, string calldata subdomain, address resolver) external {
        bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));
        bytes32 subdomainLabel = keccak256(bytes(subdomain));
        address subdomainOwner = ens.owner(keccak256(abi.encodePacked(domainNode, subdomainLabel)));

        
        require(subdomainOwner != address(0));

        Domain storage domain = domains[label];

        
        require(keccak256(abi.encodePacked(domain.name)) == label);
        
        require(msg.sender == domain.minion || msg.sender == subdomainOwner);

        doRegistration(domainNode, subdomainLabel, address(0), Resolver(resolver));

        emit NewRegistration(label, subdomain, address(0));
    }

    function doRegistration(bytes32 node, bytes32 label, address subdomainOwner, Resolver resolver) internal {
        
        ens.setSubnodeOwner(node, label, address(this));

        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        
        ens.setResolver(subnode, address(resolver));

        
        resolver.setAddr(subnode, subdomainOwner);

        
        ens.setOwner(subnode, subdomainOwner);
    }

    

    
    function owner(bytes32 label) public view returns (address) {
        if (domains[label].owner != address(0x0)) {
            return domains[label].owner;
        }

        return Registrar(registrar).ownerOf(uint256(label));
    }
}