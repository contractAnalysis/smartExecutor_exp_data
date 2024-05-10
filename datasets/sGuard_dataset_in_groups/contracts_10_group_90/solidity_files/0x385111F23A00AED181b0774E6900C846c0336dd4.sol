pragma solidity 0.6.0;


contract Nest_NToken_TokenAuction {
    using SafeMath for uint256;
    using address_make_payable for address;
    using SafeERC20 for ERC20;
    
    Nest_3_VoteFactory _voteFactory;                            
    Nest_NToken_TokenMapping _tokenMapping;                     
    ERC20 _nestToken;                                           
    Nest_3_OfferPrice _offerPrice;                              
    address _destructionAddress;                                
    uint256 _duration = 5 days;                                 
    uint256 _minimumNest = 100000 ether;                        
    uint256 _tokenNum = 1;                                      
    uint256 _incentiveRatio = 50;                               
    uint256 _minimumInterval = 10000 ether;                     
    mapping(address => AuctionInfo) _auctionList;               
    mapping(address => bool) _tokenBlackList;                   
    struct AuctionInfo {
        uint256 endTime;                                        
        uint256 auctionValue;                                   
        address latestAddress;                                  
        uint256 latestAmount;                                   
    }
    address[] _allAuction;                                      
    
    
    constructor (address voteFactory) public {
        Nest_3_VoteFactory voteFactoryMap = Nest_3_VoteFactory(address(voteFactory));
        _voteFactory = voteFactoryMap;
        _tokenMapping = Nest_NToken_TokenMapping(address(voteFactoryMap.checkAddress("nest.nToken.tokenMapping")));
        _nestToken = ERC20(address(voteFactoryMap.checkAddress("nest")));
        _destructionAddress = address(voteFactoryMap.checkAddress("nest.v3.destruction"));
        _offerPrice = Nest_3_OfferPrice(address(voteFactoryMap.checkAddress("nest.v3.offerPrice")));
    }
    
    
    function changeMapping(address voteFactory) public onlyOwner {
        Nest_3_VoteFactory voteFactoryMap = Nest_3_VoteFactory(address(voteFactory));
        _voteFactory = voteFactoryMap;
        _tokenMapping = Nest_NToken_TokenMapping(address(voteFactoryMap.checkAddress("nest.nToken.tokenMapping")));
        _nestToken = ERC20(address(voteFactoryMap.checkAddress("nest")));
        _destructionAddress = address(voteFactoryMap.checkAddress("nest.v3.destruction"));
        _offerPrice = Nest_3_OfferPrice(address(voteFactoryMap.checkAddress("nest.v3.offerPrice")));
    }
    
    
    function startAnAuction(address token, uint256 auctionAmount) public {
        require(_tokenMapping.checkTokenMapping(token) == address(0x0), "Token already exists");
        require(_auctionList[token].endTime == 0, "Token is on sale");
        require(auctionAmount >= _minimumNest, "AuctionAmount less than the minimum auction amount");
        require(_nestToken.transferFrom(address(msg.sender), address(this), auctionAmount), "Authorization failed");
        require(!_tokenBlackList[token]);
        
        ERC20 tokenERC20 = ERC20(token);
        tokenERC20.safeTransferFrom(address(msg.sender), address(this), 1);
        require(tokenERC20.balanceOf(address(this)) >= 1);
        tokenERC20.safeTransfer(address(msg.sender), 1);
        AuctionInfo memory thisAuction = AuctionInfo(now.add(_duration), auctionAmount, address(msg.sender), auctionAmount);
        _auctionList[token] = thisAuction;
        _allAuction.push(token);
    }
    
    
    function continueAuction(address token, uint256 auctionAmount) public {
        require(now <= _auctionList[token].endTime && _auctionList[token].endTime != 0, "Auction closed");
        require(auctionAmount > _auctionList[token].auctionValue, "Insufficient auction amount");
        uint256 subAuctionAmount = auctionAmount.sub(_auctionList[token].auctionValue);
        require(subAuctionAmount >= _minimumInterval);
        uint256 excitation = subAuctionAmount.mul(_incentiveRatio).div(100);
        require(_nestToken.transferFrom(address(msg.sender), address(this), auctionAmount), "Authorization failed");
        require(_nestToken.transfer(_auctionList[token].latestAddress, _auctionList[token].auctionValue.add(excitation)), "Transfer failure");
        
        _auctionList[token].auctionValue = auctionAmount;
        _auctionList[token].latestAddress = address(msg.sender);
        _auctionList[token].latestAmount = _auctionList[token].latestAmount.add(subAuctionAmount.sub(excitation));
    }
    
    
    function auctionSuccess(address token) public {
        Nest_3_TokenAbonus nestAbonus = Nest_3_TokenAbonus(_voteFactory.checkAddress("nest.v3.tokenAbonus"));
        uint256 nowTime = now;
        uint256 nextTime = nestAbonus.getNextTime();
        uint256 timeLimit = nestAbonus.checkTimeLimit();
        uint256 getAbonusTimeLimit = nestAbonus.checkGetAbonusTimeLimit();
        require(!(nowTime >= nextTime.sub(timeLimit) && nowTime <= nextTime.sub(timeLimit).add(getAbonusTimeLimit)), "Not time to auctionSuccess");
        require(nowTime > _auctionList[token].endTime && _auctionList[token].endTime != 0, "Token is on sale");
        
        Nest_NToken nToken = new Nest_NToken(strConcat("NToken", getAddressStr(_tokenNum)), strConcat("N", getAddressStr(_tokenNum)), address(_voteFactory), address(_auctionList[token].latestAddress));
        
        require(_nestToken.transfer(_destructionAddress, _auctionList[token].latestAmount), "Transfer failure");
        
        _tokenMapping.addTokenMapping(token, address(nToken));
        
        _offerPrice.addPriceCost(token);
        _tokenNum = _tokenNum.add(1);
    }
    
    function strConcat(string memory _a, string memory _b) public pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) {
            bret[k++] = _ba[i];
        } 
        for (uint i = 0; i < _bb.length; i++) {
            bret[k++] = _bb[i];
        } 
        return string(ret);
    } 
    
    
    function getAddressStr(uint256 iv) public pure returns (string memory) {
        bytes memory buf = new bytes(64);
        uint256 index = 0;
        do {
            buf[index++] = byte(uint8(iv % 10 + 48));
            iv /= 10;
        } while (iv > 0 || index < 4);
        bytes memory str = new bytes(index);
        for(uint256 i = 0; i < index; ++i) {
            str[i] = buf[index - i - 1];
        }
        return string(str);
    }
    
    
    function checkDuration() public view returns(uint256) {
        return _duration;
    }
    
    
    function checkMinimumNest() public view returns(uint256) {
        return _minimumNest;
    }
    
    
    function checkAllAuctionLength() public view returns(uint256) {
        return _allAuction.length;
    }
    
    
    function checkAuctionTokenAddress(uint256 num) public view returns(address) {
        return _allAuction[num];
    }
    
    
    function checkTokenBlackList(address token) public view returns(bool) {
        return _tokenBlackList[token];
    }
    
    
    function checkAuctionInfo(address token) public view returns(uint256 endTime, uint256 auctionValue, address latestAddress) {
        AuctionInfo memory info = _auctionList[token];
        return (info.endTime, info.auctionValue, info.latestAddress);
    }
    
    
    function checkTokenNum() public view returns (uint256) {
        return _tokenNum;
    }
    
    
    function changeDuration(uint256 num) public onlyOwner {
        _duration = num.mul(1 days);
    }
    
    
    function changeMinimumNest(uint256 num) public onlyOwner {
        _minimumNest = num;
    }
    
    
    function changeTokenBlackList(address token, bool isBlack) public onlyOwner {
        _tokenBlackList[token] = isBlack;
    }
    
    
    modifier onlyOwner(){
        require(_voteFactory.checkOwners(msg.sender), "No authority");
        _;
    }
    
}


interface Nest_3_TokenAbonus {
    
    function getNextTime() external view returns (uint256);
    
    function checkTimeLimit() external view returns (uint256);
    
    function checkGetAbonusTimeLimit() external view returns (uint256);
}


interface Nest_3_VoteFactory {
    
	function checkAddress(string calldata name) external view returns (address contractAddress);
	
	function checkOwners(address man) external view returns (bool);
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Nest_NToken is IERC20 {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;                                 
    mapping (address => mapping (address => uint256)) private _allowed;             
    uint256 private _totalSupply = 0 ether;                                         
    string public name;                                                             
    string public symbol;                                                           
    uint8 public decimals = 18;                                                     
    uint256 public _createBlock;                                                    
    uint256 public _recentlyUsedBlock;                                              
    Nest_3_VoteFactory _voteFactory;                                                
    address _bidder;                                                                
    
    
    constructor (string memory _name, string memory _symbol, address voteFactory, address bidder) public {
    	name = _name;                                                               
    	symbol = _symbol;
    	_createBlock = block.number;
    	_recentlyUsedBlock = block.number;
    	_voteFactory = Nest_3_VoteFactory(address(voteFactory));
    	_bidder = bidder;
    }
    
    
    function changeMapping (address voteFactory) public onlyOwner {
    	_voteFactory = Nest_3_VoteFactory(address(voteFactory));
    }
    
    
    function increaseTotal(uint256 value) public {
        address offerMain = address(_voteFactory.checkAddress("nest.nToken.offerMain"));
        require(address(msg.sender) == offerMain, "No authority");
        _balances[offerMain] = _balances[offerMain].add(value);
        _totalSupply = _totalSupply.add(value);
        _recentlyUsedBlock = block.number;
    }

    
    function totalSupply() override public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address owner) override public view returns (uint256) {
        return _balances[owner];
    }
    
    
    function checkBlockInfo() public view returns(uint256 createBlock, uint256 recentlyUsedBlock) {
        return (_createBlock, _recentlyUsedBlock);
    }

    
    function allowance(address owner, address spender) override public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) override public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    
    function approve(address spender, uint256 value) override public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value) override public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    
    function _transfer(address from, address to, uint256 value) internal {
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    
    
    function checkBidder() public view returns(address) {
        return _bidder;
    }
    
    
    function changeBidder(address bidder) public {
        require(address(msg.sender) == _bidder);
        _bidder = bidder; 
    }
    
    
    modifier onlyOwner(){
        require(_voteFactory.checkOwners(msg.sender));
        _;
    }
}


interface Nest_NToken_TokenMapping {
    
    function addTokenMapping(address token, address nToken) external;
    function checkTokenMapping(address token) external view returns (address);
}


interface Nest_3_OfferPrice {
    function addPriceCost(address tokenAddress) external;
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

library address_make_payable {
   function make_payable(address x) internal pure returns (address payable) {
      return address(uint160(x));
   }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}