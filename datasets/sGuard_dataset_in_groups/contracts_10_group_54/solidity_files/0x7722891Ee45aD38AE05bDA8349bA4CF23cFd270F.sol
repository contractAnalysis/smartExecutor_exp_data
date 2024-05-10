pragma solidity 0.6.0;


contract Nest_3_OfferPrice{
    using SafeMath for uint256;
    using address_make_payable for address;
    using SafeERC20 for ERC20;
    
    Nest_3_VoteFactory _voteFactory;                                
    ERC20 _nestToken;                                               
    Nest_NToken_TokenMapping _tokenMapping;                         
    Nest_3_OfferMain _offerMain;                                    
    Nest_3_Abonus _abonus;                                          
    address _nTokeOfferMain;                                        
    address _destructionAddress;                                    
    address _nTokenAuction;                                         
    struct PriceInfo {                                              
        uint256 ethAmount;                                          
        uint256 erc20Amount;                                        
        uint256 frontBlock;                                         
        address offerOwner;                                         
    }
    struct TokenInfo {                                              
        mapping(uint256 => PriceInfo) priceInfoList;                
        uint256 latestOffer;                                        
        uint256 priceCostLeast;                                     
        uint256 priceCostMost;                                      
        uint256 priceCostSingle;                                    
        uint256 priceCostUser;                                      
    }
    uint256 destructionAmount = 10000 ether;                        
    uint256 effectTime = 1 days;                                    
    mapping(address => TokenInfo) _tokenInfo;                       
    mapping(address => bool) _blocklist;                            
    mapping(address => uint256) _addressEffect;                     
    mapping(address => bool) _offerMainMapping;                     

    
    event NowTokenPrice(address a, uint256 b, uint256 c);
    
    
    constructor (address voteFactory) public {
        Nest_3_VoteFactory voteFactoryMap = Nest_3_VoteFactory(address(voteFactory));
        _voteFactory = voteFactoryMap;
        _offerMain = Nest_3_OfferMain(address(voteFactoryMap.checkAddress("nest.v3.offerMain")));
        _nTokeOfferMain = address(voteFactoryMap.checkAddress("nest.nToken.offerMain"));
        _abonus = Nest_3_Abonus(address(voteFactoryMap.checkAddress("nest.v3.abonus")));
        _destructionAddress = address(voteFactoryMap.checkAddress("nest.v3.destruction"));
        _nestToken = ERC20(address(voteFactoryMap.checkAddress("nest")));
        _tokenMapping = Nest_NToken_TokenMapping(address(voteFactoryMap.checkAddress("nest.nToken.tokenMapping")));
        _nTokenAuction = address(voteFactoryMap.checkAddress("nest.nToken.tokenAuction"));
        _offerMainMapping[address(_offerMain)] = true;
        _offerMainMapping[address(_nTokeOfferMain)] = true;
    }
    
    
    function changeMapping(address voteFactory) public onlyOwner {
        Nest_3_VoteFactory voteFactoryMap = Nest_3_VoteFactory(address(voteFactory));
        _voteFactory = voteFactoryMap;                                   
        _offerMain = Nest_3_OfferMain(address(voteFactoryMap.checkAddress("nest.v3.offerMain")));
        _nTokeOfferMain = address(voteFactoryMap.checkAddress("nest.nToken.offerMain"));
        _abonus = Nest_3_Abonus(address(voteFactoryMap.checkAddress("nest.v3.abonus")));
        _destructionAddress = address(voteFactoryMap.checkAddress("nest.v3.destruction"));
        _nestToken = ERC20(address(voteFactoryMap.checkAddress("nest")));
        _tokenMapping = Nest_NToken_TokenMapping(address(voteFactoryMap.checkAddress("nest.nToken.tokenMapping")));
        _nTokenAuction = address(voteFactoryMap.checkAddress("nest.nToken.tokenAuction"));
        _offerMainMapping[address(_offerMain)] = true;
        _offerMainMapping[address(_nTokeOfferMain)] = true;
    }
    
    
    function addPriceCost(address tokenAddress) public {
        require(msg.sender == _nTokenAuction);
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        tokenInfo.priceCostLeast = 0.001 ether;
        tokenInfo.priceCostMost = 0.01 ether;
        tokenInfo.priceCostSingle = 0.0001 ether;
        tokenInfo.priceCostUser = 2;
    }
    
    
    function addPrice(uint256 ethAmount, uint256 tokenAmount, uint256 endBlock, address tokenAddress, address offerOwner) public onlyOfferMain{
        
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        PriceInfo storage priceInfo = tokenInfo.priceInfoList[endBlock];
        priceInfo.ethAmount = priceInfo.ethAmount.add(ethAmount);
        priceInfo.erc20Amount = priceInfo.erc20Amount.add(tokenAmount);
        priceInfo.offerOwner = offerOwner;
        if (endBlock != tokenInfo.latestOffer) {
            
            priceInfo.frontBlock = tokenInfo.latestOffer;
            tokenInfo.latestOffer = endBlock;
        }
    }
    
    
    function changePrice(uint256 ethAmount, uint256 tokenAmount, address tokenAddress, uint256 endBlock) public onlyOfferMain {
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        PriceInfo storage priceInfo = tokenInfo.priceInfoList[endBlock];
        priceInfo.ethAmount = priceInfo.ethAmount.sub(ethAmount);
        priceInfo.erc20Amount = priceInfo.erc20Amount.sub(tokenAmount);
    }
    
    
    function updateAndCheckPriceNow(address tokenAddress) public payable returns(uint256 ethAmount, uint256 erc20Amount, uint256 blockNum) {
        require(checkUseNestPrice(address(msg.sender)));
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        uint256 checkBlock = tokenInfo.latestOffer;
        while(checkBlock > 0 && (checkBlock >= block.number || tokenInfo.priceInfoList[checkBlock].ethAmount == 0)) {
            checkBlock = tokenInfo.priceInfoList[checkBlock].frontBlock;
        }
        require(checkBlock != 0);
        PriceInfo memory priceInfo = tokenInfo.priceInfoList[checkBlock];
        address nToken = _tokenMapping.checkTokenMapping(tokenAddress);
        if (nToken == address(0x0)) {
            _abonus.switchToEth.value(tokenInfo.priceCostLeast.sub(tokenInfo.priceCostLeast.mul(tokenInfo.priceCostUser).div(10)))(address(_nestToken));
        } else {
            _abonus.switchToEth.value(tokenInfo.priceCostLeast.sub(tokenInfo.priceCostLeast.mul(tokenInfo.priceCostUser).div(10)))(address(nToken));
        }
        repayEth(priceInfo.offerOwner, tokenInfo.priceCostLeast.mul(tokenInfo.priceCostUser).div(10));
        repayEth(address(msg.sender), msg.value.sub(tokenInfo.priceCostLeast));
        emit NowTokenPrice(tokenAddress,priceInfo.ethAmount, priceInfo.erc20Amount);
        return (priceInfo.ethAmount,priceInfo.erc20Amount, checkBlock);
    }
    
    
    function updateAndCheckPricePrivate(address tokenAddress) public view onlyOfferMain returns(uint256 ethAmount, uint256 erc20Amount) {
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        uint256 checkBlock = tokenInfo.latestOffer;
        while(checkBlock > 0 && (checkBlock >= block.number || tokenInfo.priceInfoList[checkBlock].ethAmount == 0)) {
            checkBlock = tokenInfo.priceInfoList[checkBlock].frontBlock;
        }
        if (checkBlock == 0) {
            return (0,0);
        }
        PriceInfo memory priceInfo = tokenInfo.priceInfoList[checkBlock];
        return (priceInfo.ethAmount,priceInfo.erc20Amount);
    }
    
    
    function updateAndCheckPriceList(address tokenAddress, uint256 num) public payable returns (uint256[] memory) {
        require(checkUseNestPrice(address(msg.sender)));
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        
        uint256 thisPay = tokenInfo.priceCostSingle.mul(num);
        if (thisPay < tokenInfo.priceCostLeast) {
            thisPay=tokenInfo.priceCostLeast;
        } else if (thisPay > tokenInfo.priceCostMost) {
            thisPay = tokenInfo.priceCostMost;
        }
        
        
        uint256 length = num.mul(3);
        uint256 index = 0;
        uint256[] memory data = new uint256[](length);
        address latestOfferOwner = address(0x0);
        uint256 checkBlock = tokenInfo.latestOffer;
        while(index < length && checkBlock > 0){
            if (checkBlock < block.number && tokenInfo.priceInfoList[checkBlock].ethAmount != 0) {
                
                data[index++] = tokenInfo.priceInfoList[checkBlock].ethAmount;
                data[index++] = tokenInfo.priceInfoList[checkBlock].erc20Amount;
                data[index++] = checkBlock;
                if (latestOfferOwner == address(0x0)) {
                    latestOfferOwner = tokenInfo.priceInfoList[checkBlock].offerOwner;
                }
            }
            checkBlock = tokenInfo.priceInfoList[checkBlock].frontBlock;
        }
        require(latestOfferOwner != address(0x0));
        require(length == data.length);
        
        address nToken = _tokenMapping.checkTokenMapping(tokenAddress);
        if (nToken == address(0x0)) {
            _abonus.switchToEth.value(thisPay.sub(thisPay.mul(tokenInfo.priceCostUser).div(10)))(address(_nestToken));
        } else {
            _abonus.switchToEth.value(thisPay.sub(thisPay.mul(tokenInfo.priceCostUser).div(10)))(address(nToken));
        }
        repayEth(latestOfferOwner, thisPay.mul(tokenInfo.priceCostUser).div(10));
        repayEth(address(msg.sender), msg.value.sub(thisPay));
        return data;
    }
    
    
    function activation() public {
        _nestToken.safeTransferFrom(address(msg.sender), _destructionAddress, destructionAmount);
        _addressEffect[address(msg.sender)] = now.add(effectTime);
    }
    
    
    function repayEth(address accountAddress, uint256 asset) private {
        address payable addr = accountAddress.make_payable();
        addr.transfer(asset);
    }
    
    
    function checkPriceForBlock(address tokenAddress, uint256 blockNum) public view returns (uint256 ethAmount, uint256 erc20Amount) {
        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        return (tokenInfo.priceInfoList[blockNum].ethAmount, tokenInfo.priceInfoList[blockNum].erc20Amount);
    }    
    
    
    function checkPriceNow(address tokenAddress) public view returns (uint256 ethAmount, uint256 erc20Amount, uint256 blockNum) {
        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        uint256 checkBlock = tokenInfo.latestOffer;
        while(checkBlock > 0 && (checkBlock >= block.number || tokenInfo.priceInfoList[checkBlock].ethAmount == 0)) {
            checkBlock = tokenInfo.priceInfoList[checkBlock].frontBlock;
        }
        if (checkBlock == 0) {
            return (0,0,0);
        }
        PriceInfo storage priceInfo = tokenInfo.priceInfoList[checkBlock];
        return (priceInfo.ethAmount,priceInfo.erc20Amount, checkBlock);
    }
    
    
    function checkPriceCostProportion(address tokenAddress) public view returns(uint256 user, uint256 abonus) {
        return (_tokenInfo[tokenAddress].priceCostUser, uint256(10).sub(_tokenInfo[tokenAddress].priceCostUser));
    }
    
    
    function checkPriceCostLeast(address tokenAddress) public view returns(uint256) {
        return _tokenInfo[tokenAddress].priceCostLeast;
    }
    
    
    function checkPriceCostMost(address tokenAddress) public view returns(uint256) {
        return _tokenInfo[tokenAddress].priceCostMost;
    }
    
    
    function checkPriceCostSingle(address tokenAddress) public view returns(uint256) {
        return _tokenInfo[tokenAddress].priceCostSingle;
    }
    
    
    function checkUseNestPrice(address target) public view returns (bool) {
        if (!_blocklist[target] && _addressEffect[target] < now && _addressEffect[target] != 0) {
            return true;
        } else {
            return false;
        }
    }
    
    
    function checkBlocklist(address add) public view returns(bool) {
        return _blocklist[add];
    }
    
    
    function checkDestructionAmount() public view returns(uint256) {
        return destructionAmount;
    }
    
    
    function checkEffectTime() public view returns (uint256) {
        return effectTime;
    }
    
    
    function changePriceCostProportion(uint256 user, address tokenAddress) public onlyOwner {
        _tokenInfo[tokenAddress].priceCostUser = user;
    }
    
    
    function changePriceCostLeast(uint256 amount, address tokenAddress) public onlyOwner {
        _tokenInfo[tokenAddress].priceCostLeast = amount;
    }
    
    
    function changePriceCostMost(uint256 amount, address tokenAddress) public onlyOwner {
        _tokenInfo[tokenAddress].priceCostMost = amount;
    }
    
    
    function checkPriceCostSingle(uint256 amount, address tokenAddress) public onlyOwner {
        _tokenInfo[tokenAddress].priceCostSingle = amount;
    }
    
    
    function changeBlocklist(address add, bool isBlock) public onlyOwner {
        _blocklist[add] = isBlock;
    }
    
    
    function changeDestructionAmount(uint256 amount) public onlyOwner {
        destructionAmount = amount;
    }
    
    
    function changeEffectTime(uint256 num) public onlyOwner {
        effectTime = num;
    }

    
    modifier onlyOfferMain(){
        require(_offerMainMapping[address(msg.sender)], "No authority");
        _;
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


interface Nest_NToken_TokenMapping {
    function checkTokenMapping(address token) external view returns (address);
}


interface Nest_3_OfferMain {
    function checkTokenAllow(address token) external view returns(bool);
}


interface Nest_3_Abonus {
    function switchToEth(address token) external payable;
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