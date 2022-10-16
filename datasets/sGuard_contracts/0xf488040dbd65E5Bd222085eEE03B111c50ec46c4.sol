pragma solidity ^0.5.12;


contract V1Token {
    function isApprovedForAll(address owner, address operator) public view returns (bool) {}

    function transferFrom(address from, address to, uint256 tokenId) public {}
}


contract V2Token {
    function upgradeV1Token(uint256 tokenId, address v1Address, bool isControlToken, address to, 
        uint256 platformFirstPercentageForToken, uint256 platformSecondPercentageForToken, bool hasTokenHadFirstSale,
        address payable[] calldata uniqueTokenCreatorsForToken) external {}
}




contract TokenUpgrader {
    event TokenUpgraded(
        uint256 tokenId,
        address v1TokenAddress,
        address v2TokenAddress
    );

    
    V1Token public v1TokenAddress;
    
    V2Token public v2TokenAddress;
    
    address public adminAddress;

    mapping(uint256 => bool) public isTokenReadyForUpgrade;
    mapping(uint256 => bool) public isControlTokenMapping;
    mapping(uint256 => bool) public hasTokenHadFirstSale;
    mapping(uint256 => uint256) public platformFirstPercentageForToken;
    mapping(uint256 => uint256) public platformSecondPercentageForToken;
    mapping(uint256 => address payable[]) public uniqueTokenCreatorMapping;

    constructor(V1Token _v1TokenAddress) public {
        adminAddress = msg.sender;

        v1TokenAddress = _v1TokenAddress;
    }

    
    modifier onlyAdmin() {
        require(msg.sender == adminAddress);
        _;
    }

    function setupV2Address(V2Token _v2TokenAddress) public onlyAdmin {
        require(address(v2TokenAddress) == address(0), "V2 address has already been initialized.");
        
        v2TokenAddress = _v2TokenAddress;
    }

    function prepareTokenForUpgrade(uint256 tokenId, bool isControlToken, uint256 platformFirstSalePercentage,
        uint256 platformSecondSalePercentage, bool hasHadFirstSale, address payable[] memory uniqueTokenCreators) public onlyAdmin {
        isTokenReadyForUpgrade[tokenId] = true;

        isControlTokenMapping[tokenId] = isControlToken;

        hasTokenHadFirstSale[tokenId] = hasHadFirstSale;

        uniqueTokenCreatorMapping[tokenId] = uniqueTokenCreators;

        platformFirstPercentageForToken[tokenId] = platformFirstSalePercentage;

        platformSecondPercentageForToken[tokenId] = platformSecondSalePercentage;
    }

    function upgradeTokenList(uint256[] memory tokenIds, address tokenOwner) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            upgradeToken(tokenIds[i], tokenOwner);
        }
    }

    function upgradeToken(uint256 tokenId, address tokenOwner) public {
        
        require(isTokenReadyForUpgrade[tokenId], "Token not ready for upgrade.");

        
        require((tokenOwner == msg.sender) || v1TokenAddress.isApprovedForAll(tokenOwner, msg.sender), "Not owner or approved.");

        
        v1TokenAddress.transferFrom(tokenOwner, address(this), tokenId);

        
        v2TokenAddress.upgradeV1Token(tokenId, address(v1TokenAddress), isControlTokenMapping[tokenId], 
            tokenOwner, platformFirstPercentageForToken[tokenId], platformSecondPercentageForToken[tokenId],
            hasTokenHadFirstSale[tokenId], uniqueTokenCreatorMapping[tokenId]);

        
        emit TokenUpgraded(tokenId, address(v1TokenAddress), address(v2TokenAddress));
    }
}