pragma solidity ^0.5.13;


contract ERC20200206  {
    event Mint(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    function name()   external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);

    function totalSupply() public view returns (uint256);
    function exists(uint256 _tokenId) public view returns (bool _exists);
    function minerOf(uint256 _tokenId) public view returns (address _miner);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function tokenURI(uint256 _tokenId) public view returns (string memory _uri);

    function amountOf(address _miner) public view returns (uint256 _amount);
    function tokenOfMinerByIndex(
        address _miner,
        uint256 _index
    )
        public
        view
        returns (uint256 _tokenId);
    function tokenByIndex(uint256 _index) public view returns (uint256 _tokenId);

    function setTokenURI(uint256 _tokenId, string memory _uri) public;
    function mint(string memory _uri) public;
}

contract NFT {
    using SafeMath for uint256;

    
    string internal name_;

    
    string internal symbol_;

    
    mapping(address => uint256[]) internal mintedTokens;

    
    mapping(uint256 => uint256) internal mintedTokensIndex;

    
    uint256[] internal allTokens;

    
    mapping(uint256 => uint256) internal allTokensIndex;

    
    mapping(uint256 => string) internal tokenURIs;

    
    mapping (uint256 => address) internal tokenMiner;

    
    mapping (address => uint256) internal mintedTokensCount;

    
    mapping (uint256 => address) internal tokenOwner;

    
    mapping (address => uint256) internal lastMintMoment;

    event Mint(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );


    
    constructor(string memory _name, string memory _symbol) 
        public 
    {
        name_ = _name;
        symbol_ = _symbol;
    }

    
    function name() external  view returns (string memory _name) 
    {
        _name = name_;
    }

    
    function symbol() 
        external 
        view 
        returns (string memory _symbol) 
    {
        _symbol = symbol_;
    }

    
    function totalSupply() 
        public 
        view 
        returns (uint256 _amount) 
    {
        _amount = allTokens.length;
    }

    
    function exists(uint256 _tokenId) 
        public 
        view 
        returns (bool _exists) 
    {
        address miner = tokenMiner[_tokenId];
        _exists = (miner != address(0));
    }

    
    function minerOf(uint256 _tokenId) 
        public 
        view 
        returns (address _miner) 
    {
        _miner = tokenMiner[_tokenId];
    }

    
    function ownerOf(uint256 _tokenId) 
        public 
        view 
        returns (address _owner) 
    {
        require(exists(_tokenId));
        _owner = tokenOwner[_tokenId];
    }

    
    function tokenURI(uint256 _tokenId) 
        public 
        view 
        returns (string memory _uri) 
    {
        require(exists(_tokenId));
        _uri = tokenURIs[_tokenId];
    }

    
    function amountOf(address _miner) 
        public 
        view 
        returns (uint256 _amount) 
    {
        require(_miner != address(0));
        _amount = mintedTokensCount[_miner];
    }

    
    function tokenOfMinerByIndex(
        address _miner,
        uint256 _index
    )
        public
        view
        returns (uint256 _tokenId)
    {
        require(_index < amountOf(_miner));
        _tokenId = mintedTokens[_miner][_index];
    }

    
    function tokenByIndex(uint256 _index) 
        public 
        view 
        returns (uint256 _tokenId) 
    {
        require(_index < totalSupply());
        _tokenId = allTokens[_index];
    }


    
    function setTokenURI(uint256 _tokenId, string memory _uri) 
        public
    {
        require(exists(_tokenId),"TokenId is not exist");
        require(minerOf(_tokenId) == msg.sender,"Only Miner can reset URI");
        tokenURIs[_tokenId] = _uri;
    }

    
    function mint(string memory _uri) 
        public
    {
        require(canMint(msg.sender));

        uint256 _tokenId = totalSupply().add(1);
        require(tokenMiner[_tokenId] == address(0));
        tokenMiner[_tokenId] = msg.sender;
        mintedTokensCount[msg.sender] = mintedTokensCount[msg.sender].add(1);

        uint256 length = mintedTokens[msg.sender].length;
        mintedTokens[msg.sender].push(_tokenId);
        mintedTokensIndex[_tokenId] = length;
        tokenOwner[_tokenId] = address(0);

        allTokensIndex[_tokenId] = allTokens.length;
        allTokens.push(_tokenId);
        tokenURIs[_tokenId] = _uri;

        lastMintMoment[msg.sender] = now;

        emit Mint(msg.sender, address(0), _tokenId);
    }

    
    function() external payable {
        revert();
    }

    
    function canMint(address _miner) 
        public 
        view 
        returns(bool _canmint) 
    {
        if (lastMintMoment[_miner] == 0) {
            _canmint = true;
        } else {
            uint256 _last = lastMintMoment[_miner];
            uint256 _lastutc_8 = _last.sub(1581264000);
            uint256 _lastspec = _lastutc_8 % 86400;
            if (now.sub(_last).add(_lastspec) > 86400) {
                _canmint = true;
            } else {
                _canmint = false;
            }
        }
    }
}



library SafeMath {
    
    
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }
    
    
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
    
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
    
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}