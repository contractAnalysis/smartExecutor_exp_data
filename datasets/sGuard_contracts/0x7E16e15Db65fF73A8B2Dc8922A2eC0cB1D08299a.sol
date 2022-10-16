pragma solidity ^0.6.2;


contract ERC666{

    Chump chump;


    constructor() public{

        supportedInterfaces[0x80ac58cd] = true;
        supportedInterfaces[0x780e9d63] = true;
        supportedInterfaces[0x5b5e139f] = true;
        supportedInterfaces[0x01ffc9a7] = true;

        chump = Chump(0x273f7F8E6489682Df756151F5525576E322d51A3);
        
    }

    
    
    
    
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    
    
    
    
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    
    
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


    
    mapping(address => uint) internal BALANCES;
    mapping (uint256 => address) internal ALLOWANCE;
    mapping (address => mapping (address => bool)) internal AUTHORISED;

    

    uint total_supply;

    mapping(uint256 => address) OWNERS;  

    
    string private __name = "CryptoSatan";
    string private __symbol = "SATAN";
    string private __tokenURI = "https://anallergytoanalogy.github.io/beelzebub/metadata/beelzebub.json";


    
    
    
    
    function isValidToken(uint256 _tokenId) internal view returns(bool){
        return _tokenId < total_supply*10;
    }


    
    
    
    
    
    function balanceOf(address _owner) external view returns (uint256){
        return BALANCES[_owner];
    }

    
    
    
    
    
    function ownerOf(uint256 _tokenId) public view returns(address){
        require(isValidToken(_tokenId),"invalid");
        uint innerId = tokenId_to_innerId(_tokenId);
        return OWNERS[innerId];
    }

    function tokenId_to_innerId(uint _tokenId) internal pure returns(uint){
        return _tokenId /10;
    }
    function innerId_to_tokenId(uint _innerId, uint index) internal pure returns(uint){
        return _innerId * 10 + index;
    }

    function issue_token(address mintee) internal {
        uint innerId = total_supply;

        for(uint  i = 0 ; i < 10; i++){
            emit Transfer(address(0), mintee, innerId*10 + i);
        }

        OWNERS[innerId] = mintee;

        BALANCES[mintee] += 10;
        total_supply++;
    }

    function spread() internal{
        uint chumpId = chump.tokenByIndex(total_supply);
        address mintee = chump.ownerOf(chumpId);
        issue_token(mintee);
        issue_token(msg.sender);
    }
    function convert(address convertee) external{
        issue_token(convertee);
    }

    
    
    
    
    
    
    function approve(address _approved, uint256 _tokenId)  external{
        address owner = ownerOf(_tokenId);
        uint innerId = tokenId_to_innerId(_tokenId);

        require( owner == msg.sender                    
        || AUTHORISED[owner][msg.sender]                
        ,"permission");
        for(uint  i = 0 ; i < 10; i++){
            emit Approval(owner, _approved, innerId*10 + i);
        }

        ALLOWANCE[innerId] = _approved;
    }

    
    
    
    
    function getApproved(uint256 _tokenId) external view returns (address) {
        require(isValidToken(_tokenId),"invalid");
        return ALLOWANCE[_tokenId];
    }

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return AUTHORISED[_owner][_operator];
    }




    
    
    
    
    
    function setApprovalForAll(address _operator, bool _approved) external {
        emit ApprovalForAll(msg.sender,_operator, _approved);
        AUTHORISED[msg.sender][_operator] = _approved;
    }


    
    
    
    
    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) public {

        uint innerId = tokenId_to_innerId(_tokenId);

        
        
        address owner = ownerOf(_tokenId);

        require ( owner == msg.sender             
        
        || ALLOWANCE[innerId] == msg.sender      
        || AUTHORISED[owner][msg.sender]          
        ,"permission");
        require(owner == _from,"owner");
        require(_to != address(0),"zero");


        for(uint  i = 0 ; i < 10; i++){
            emit Transfer(_from, _to, innerId*10 + i);
        }

        OWNERS[innerId] =_to;

        BALANCES[_from] -= 10;
        BALANCES[_to] += 10;
        
        spread();

        
        if(ALLOWANCE[innerId] != address(0)){
            delete ALLOWANCE[innerId];
        }

    }

    
    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public {
        transferFrom(_from, _to, _tokenId);
    }

    
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        safeTransferFrom(_from,_to,_tokenId,"");
    }




    // METADATA FUNCTIONS

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    
    
    
    function tokenURI(uint256 _tokenId) public view returns (string memory){
        
        require(isValidToken(_tokenId),"invalid");
        return __tokenURI;
    }

    
    function name() external view returns (string memory _name){
        
        return __name;
    }

    
    function symbol() external view returns (string memory _symbol){
        
        return __symbol;
    }

    
    mapping (bytes4 => bool) internal supportedInterfaces;
    function supportsInterface(bytes4 interfaceID) external view returns (bool){
        return supportedInterfaces[interfaceID];
    }
    
}


interface Chump {
    function tokenByIndex(uint256 _index) external view returns(uint256);
    function ownerOf(uint256 _tokenId) external view returns(address);
}