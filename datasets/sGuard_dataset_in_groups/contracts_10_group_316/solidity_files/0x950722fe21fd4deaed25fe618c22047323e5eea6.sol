pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

interface IArbitrableTokenList {
    
    enum TokenStatus {
        Absent, 
        Registered, 
        RegistrationRequested, 
        ClearingRequested 
    }
    
    enum Party {
        None,
        Requester,
        Challenger
    }
    
    function getTokenInfo(bytes32) external view returns (string memory, string memory, address, string memory, TokenStatus, uint);
    function queryTokens(bytes32 _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst, address _tokenAddr)
        external
        view
        returns (bytes32[] memory values, bool hasMore);
    function tokenCount() external view returns (uint);
    function addressToSubmissions(address _addr, uint _index) external view returns (bytes32);
    function tokensList(uint _index) external view returns (bytes32);
    function getRequestInfo(bytes32 _tokenID, uint _request)
        external
        view
        returns (
            bool disputed,
            uint disputeID,
            uint submissionTime,
            bool resolved,
            address[3] memory parties,
            uint numberOfRounds,
            Party ruling,
            address arbitrator,
            bytes memory arbitratorExtraData
        );
}



contract TokensViewV3 {
    
    struct Token {
        bytes32 ID;
        string name;
        string ticker;
        address addr;
        string symbolMultihash;
        IArbitrableTokenList.TokenStatus status;
        uint decimals;
    }
    
    
    function getTokensIDsForAddresses(
        address _t2crAddress, 
        address[] calldata _tokenAddresses
    ) external view returns (bytes32[] memory result) {
        IArbitrableTokenList t2cr = IArbitrableTokenList(_t2crAddress);
        result = new bytes32[](_tokenAddresses.length);
        bytes32 ZERO_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;
        for (uint i = 0; i < _tokenAddresses.length;  i++){
            
            address tokenAddr = _tokenAddresses[i];
            bool counting = true;
            bytes4 sig = bytes4(keccak256("addressToSubmissions(address,uint256)"));
            uint submissions = 0;
            while(counting) {
                assembly {
                    let x := mload(0x40)   
                    mstore(x, sig)         
                    mstore(add(x, 0x04), tokenAddr)
                    mstore(add(x, 0x24), submissions)
                    counting := staticcall( 
                        30000,              
                        _t2crAddress,       
                        x,                  
                        0x44,               
                        x,                  
                        0x20                
                    )
                }
                
                if (counting) {
                    submissions++;
                }
            }
            
            
            for(uint j = 0; j < submissions; j++) {
                bytes32 tokenID = t2cr.addressToSubmissions(tokenAddr, j);
                (,,,,IArbitrableTokenList.TokenStatus status,) = t2cr.getTokenInfo(tokenID);
                if (status == IArbitrableTokenList.TokenStatus.Registered || status == IArbitrableTokenList.TokenStatus.ClearingRequested) 
                {
                    result[i] = tokenID;
                    break;
                }
            }
        }
    }
    
    
    function getTokens(address _t2crAddress, bytes32[] calldata _tokenIDs) 
        external 
        view 
        returns (Token[] memory tokens)
    {
        IArbitrableTokenList t2cr = IArbitrableTokenList(_t2crAddress);
        tokens = new Token[](_tokenIDs.length);
        for (uint i = 0; i < _tokenIDs.length ; i++){
            string[] memory strings = new string[](3); 
            address tokenAddress;
            IArbitrableTokenList.TokenStatus status;
            (
                strings[0], 
                strings[1], 
                tokenAddress, 
                strings[2], 
                status, 
            ) = t2cr.getTokenInfo(_tokenIDs[i]);
            
            tokens[i] = Token(
                _tokenIDs[i],
                strings[0],
                strings[1],
                tokenAddress,
                strings[2],
                status,
                0
            );
            
            
            
            
            
            
            
            
            
            
            
            
            
            uint decimals;
            bool success;
            bytes4 sig = bytes4(keccak256("decimals()"));
            assembly {
                let x := mload(0x40)   
                mstore(x, sig)          
                success := staticcall(
                    30000,              
                    tokenAddress,       
                    x,                  
                    0x04,               
                    x,                  
                    0x20                
                )
                
                decimals := mload(x)   
            }
            if (success && decimals != 22270923699561257074107342068491755213283769984150504402684791726686939079929) {
                tokens[i].decimals = decimals;
            }
        }
    }
    
    
    function getTokensCursor(address _t2crAddress, uint _cursor, uint _count, bool[6] calldata _filter) 
        external 
        view 
        returns (Token[] memory tokens, bool hasMore)
    {
        IArbitrableTokenList t2cr = IArbitrableTokenList(_t2crAddress);
        if (_count == 0) _count = t2cr.tokenCount();
        if (_cursor >= t2cr.tokenCount()) _cursor = t2cr.tokenCount() - 1;
        if (_cursor + _count > t2cr.tokenCount() - 1) _count = t2cr.tokenCount() - _cursor - 1;
        if (_cursor + _count < t2cr.tokenCount() - 1) hasMore = true;
        
        tokens = new Token[](_count);
        uint index = 0;
        
        
        for (uint i = _cursor; i < t2cr.tokenCount() && i < _cursor + _count ; i++){
            bytes32 tokenID = t2cr.tokensList(i);
            string[] memory strings = new string[](3); 
            address tokenAddress;
            IArbitrableTokenList.TokenStatus status;
            uint numberOfRequests;
            (
                strings[0], 
                strings[1], 
                tokenAddress, 
                strings[2], 
                status, 
                numberOfRequests
            ) = t2cr.getTokenInfo(tokenID);
            
            tokens[index] = Token(
                tokenID,
                strings[0],
                strings[1],
                tokenAddress,
                strings[2],
                status,
                0
            );
            
            (bool disputed,,,,,,,,) = t2cr.getRequestInfo(tokenID, numberOfRequests - 1);
            
            if (
                
                (_filter[0] && status == IArbitrableTokenList.TokenStatus.Absent) ||
                (_filter[1] && status == IArbitrableTokenList.TokenStatus.Registered) ||
                (_filter[2] && status == IArbitrableTokenList.TokenStatus.RegistrationRequested && !disputed) ||
                (_filter[3] && status == IArbitrableTokenList.TokenStatus.ClearingRequested && !disputed) ||
                (_filter[4] && status == IArbitrableTokenList.TokenStatus.RegistrationRequested && disputed) ||
                (_filter[5] && status == IArbitrableTokenList.TokenStatus.ClearingRequested && disputed)
                
            ) {
                if (index < _count) {
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    uint decimals;
                    bool success;
                    bytes4 sig = bytes4(keccak256("decimals()"));
                    assembly {
                        let x := mload(0x40)   
                        mstore(x, sig)          
                        success := staticcall(
                            30000,              
                            tokenAddress,       
                            x,                  
                            0x04,               
                            x,                  
                            0x20                
                        )
                        
                        decimals := mload(x)   
                    }
                    if (success && decimals != 22270923699561257074107342068491755213283769984150504402684791726686939079929) {
                        tokens[index].decimals = decimals;
                    }
                    index++;
                } else {
                    hasMore = true;
                    break;
                }
            }
        }
    }
}