pragma solidity 0.5.14;


contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IToken { 
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract LXCHAT is Ownable { 
    address public accessToken = 0xAF0348b2A3818BD6Bc1f12bd2a9f73F1B725448F;
    address public leethToken = 0x4D9D9a22458dD84dB8B0D074470f5d9536116eC5;
    IToken private token = IToken(accessToken);
    IToken private leeth = IToken(leethToken);
    uint256 public posts;
    string public redemptionOffer;
    
    mapping (uint256 => post) public postings; 
    
    event LexPosting(uint256 indexed index, string indexed details);
    event Offering(string indexed details);
    event Posting(uint256 indexed index, string indexed details);
    event Redemption(string indexed details, string indexed redemptionOffer);
    
    struct post {
        address poster;
        uint256 index;
        string details;
        string response;
    }
    
    
    function newPost(string memory details) public { 
        require(token.balanceOf(_msgSender()) >= 1000000000000000000, "accessToken balance insufficient");
            uint256 index = posts + 1; 
            posts = posts + 1;
            
            postings[index] = post(
                _msgSender(),
                index,
                details,
                "");
        
        emit Posting(index, details);
    } 
    
    function redeemOffer(string memory details) public { // accessToken holder can deposit (1) to redeem current offer 
        token.transferFrom(_msgSender(), address(this), 1000000000000000000);
        emit Redemption(details, redemptionOffer);
    }
    
    function updatePost(uint256 index, string memory details) public { // accessToken holder can always update posts
        post storage p = postings[index];
        require(_msgSender() == p.poster, "must be indexed poster");
        p.details = details;
        emit Posting(index, details);
    }

    
    function lexPost(uint256 index, string memory details) public { 
        require(leeth.balanceOf(_msgSender()) >= 5000000000000000000, "leeth balance insufficient");
        post storage p = postings[index];
        p.response = details;
        emit LexPosting(index, details);
    }
    
    function updateRedemptionOffer(string memory details) public onlyOwner { 
        redemptionOffer = details;
        emit Offering(details);
    }
    
    function withdraw() public onlyOwner { 
        token.transfer(_msgSender(), token.balanceOf(address(this)));
    }
}