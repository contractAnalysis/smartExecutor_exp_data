pragma solidity 0.6.0;


contract Nest_NToken_TokenMapping {
    
    mapping (address => address) _tokenMapping;                 
    Nest_3_VoteFactory _voteFactory;                            
    
    event TokenMappingLog(address token, address nToken);
    
    
    constructor(address voteFactory) public {
        _voteFactory = Nest_3_VoteFactory(address(voteFactory));
    }
    
    
    function changeMapping(address voteFactory) public onlyOwner {
    	_voteFactory = Nest_3_VoteFactory(address(voteFactory));
    }
    
    
    function addTokenMapping(address token, address nToken) public {
        require(address(msg.sender) == address(_voteFactory.checkAddress("nest.nToken.tokenAuction")), "No authority");
        require(_tokenMapping[token] == address(0x0), "Token already exists");
        _tokenMapping[token] = nToken;
        emit TokenMappingLog(token, nToken);
    }
    
    
    function changeTokenMapping(address token, address nToken) public onlyOwner {
        _tokenMapping[token] = nToken;
        emit TokenMappingLog(token, nToken);
    }
    
    
    function checkTokenMapping(address token) public view returns (address) {
        return _tokenMapping[token];
    }
    
    
    modifier onlyOwner(){
        require(_voteFactory.checkOwners(msg.sender), "No authority");
        _;
    }
}


interface Nest_3_VoteFactory {
    
	function checkAddress(string calldata name) external view returns (address contractAddress);
	
	function checkOwners(address man) external view returns (bool);
}