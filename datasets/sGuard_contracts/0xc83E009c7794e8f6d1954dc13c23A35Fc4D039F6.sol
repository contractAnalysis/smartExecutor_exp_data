pragma solidity 0.6.0;


contract Nest_3_OfferMain {
    using SafeMath for uint256;
    using address_make_payable for address;
    using SafeERC20 for ERC20;
    
    struct Nest_3_OfferPriceData {
        
        
        address owner;                                  
        bool deviate;                                   
        address tokenAddress;                           
        
        uint256 ethAmount;                              
        uint256 tokenAmount;                            
        
        uint256 dealEthAmount;                          
        uint256 dealTokenAmount;                        
        
        uint256 blockNum;                               
        uint256 serviceCharge;                          
        
        
    }
    
    Nest_3_OfferPriceData [] _prices;                   

    mapping(address => bool) _tokenAllow;               
    Nest_3_VoteFactory _voteFactory;                    
    Nest_3_OfferPrice _offerPrice;                      
    Nest_3_MiningContract _miningContract;              
    Nest_NodeAssignment _NNcontract;                    
    ERC20 _nestToken;                                   
    Nest_3_Abonus _abonus;                              
    address _coderAddress;                              
    uint256 _miningETH = 10;                            
    uint256 _tranEth = 1;                               
    uint256 _tranAddition = 2;                          
    uint256 _coderAmount = 5;                           
    uint256 _NNAmount = 15;                             
    uint256 _leastEth = 10 ether;                       
    uint256 _offerSpan = 10 ether;                      
    uint256 _deviate = 10;                              
    uint256 _deviationFromScale = 10;                   
    uint32 _blockLimit = 25;                            
    mapping(uint256 => uint256) _offerBlockEth;         
    mapping(uint256 => uint256) _offerBlockMining;      
    
    
    event OfferContractAddress(address contractAddress, address tokenAddress, uint256 ethAmount, uint256 erc20Amount, uint256 continued, uint256 serviceCharge);
    
    event OfferTran(address tranSender, address tranToken, uint256 tranAmount,address otherToken, uint256 otherAmount, address tradedContract, address tradedOwner);        
    
     
    constructor (address voteFactory) public {
        Nest_3_VoteFactory voteFactoryMap = Nest_3_VoteFactory(address(voteFactory));
        _voteFactory = voteFactoryMap; 
        _offerPrice = Nest_3_OfferPrice(address(voteFactoryMap.checkAddress("nest.v3.offerPrice")));            
        _miningContract = Nest_3_MiningContract(address(voteFactoryMap.checkAddress("nest.v3.miningSave")));
        _abonus = Nest_3_Abonus(voteFactoryMap.checkAddress("nest.v3.abonus"));
        _nestToken = ERC20(voteFactoryMap.checkAddress("nest"));                                         
        _NNcontract = Nest_NodeAssignment(address(voteFactoryMap.checkAddress("nodeAssignment")));      
        _coderAddress = voteFactoryMap.checkAddress("nest.v3.coder");
        require(_nestToken.approve(address(_NNcontract), uint256(10000000000 ether)), "Authorization failed");
    }
    
     
    function changeMapping(address voteFactory) public onlyOwner {
        Nest_3_VoteFactory voteFactoryMap = Nest_3_VoteFactory(address(voteFactory));
        _voteFactory = voteFactoryMap; 
        _offerPrice = Nest_3_OfferPrice(address(voteFactoryMap.checkAddress("nest.v3.offerPrice")));            
        _miningContract = Nest_3_MiningContract(address(voteFactoryMap.checkAddress("nest.v3.miningSave")));
        _abonus = Nest_3_Abonus(voteFactoryMap.checkAddress("nest.v3.abonus"));
        _nestToken = ERC20(voteFactoryMap.checkAddress("nest"));                                           
        _NNcontract = Nest_NodeAssignment(address(voteFactoryMap.checkAddress("nodeAssignment")));      
        _coderAddress = voteFactoryMap.checkAddress("nest.v3.coder");
        require(_nestToken.approve(address(_NNcontract), uint256(10000000000 ether)), "Authorization failed");
    }
    
    
    function offer(uint256 ethAmount, uint256 erc20Amount, address erc20Address) public payable {
        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        require(_tokenAllow[erc20Address], "Token not allow");
        
        uint256 ethMining;
        bool isDeviate = comparativePrice(ethAmount,erc20Amount,erc20Address);
        if (isDeviate) {
            require(ethAmount >= _leastEth.mul(_deviationFromScale), "EthAmount needs to be no less than 10 times of the minimum scale");
            ethMining = _leastEth.mul(_miningETH).div(1000);
        } else {
            ethMining = ethAmount.mul(_miningETH).div(1000);
        }
        require(msg.value >= ethAmount.add(ethMining), "msg.value needs to be equal to the quoted eth quantity plus Mining handling fee");
        uint256 subValue = msg.value.sub(ethAmount.add(ethMining));
        if (subValue > 0) {
            repayEth(address(msg.sender), subValue);
        }
        
        createOffer(ethAmount, erc20Amount, erc20Address, ethMining, isDeviate);
        
        ERC20(erc20Address).safeTransferFrom(address(msg.sender), address(this), erc20Amount);
        
        uint256 miningAmount = _miningContract.oreDrawing();
        _abonus.switchToEth.value(ethMining)(address(_nestToken));
        if (miningAmount > 0) {
            uint256 coder = miningAmount.mul(_coderAmount).div(100);
            uint256 NN = miningAmount.mul(_NNAmount).div(100);
            uint256 other = miningAmount.sub(coder).sub(NN);
            _offerBlockMining[block.number] = other;
            _NNcontract.bookKeeping(NN);   
            if (coder > 0) {
                _nestToken.safeTransfer(_coderAddress, coder);  
            }
        }
        _offerBlockEth[block.number] = _offerBlockEth[block.number].add(ethMining);
    }
    
    
    function createOffer(uint256 ethAmount, uint256 erc20Amount, address erc20Address, uint256 mining, bool isDeviate) private {
        
        require(ethAmount >= _leastEth, "Eth scale is smaller than the minimum scale");
        require(ethAmount % _offerSpan == 0, "Non compliant asset span");
        require(erc20Amount % (ethAmount.div(_offerSpan)) == 0, "Asset quantity is not divided");
        require(erc20Amount > 0);
        
        emit OfferContractAddress(toAddress(_prices.length), address(erc20Address), ethAmount, erc20Amount,_blockLimit,mining);
        _prices.push(Nest_3_OfferPriceData(
            
            msg.sender,
            isDeviate,
            erc20Address,
            
            ethAmount,
            erc20Amount,
                           
            ethAmount, 
            erc20Amount, 
              
            block.number, 
            mining
            
        )); 
        
        _offerPrice.addPrice(ethAmount, erc20Amount, block.number.add(_blockLimit), erc20Address, address(msg.sender));
    }
    
    
    function sendEthBuyErc(uint256 ethAmount, uint256 tokenAmount, address contractAddress, uint256 tranEthAmount, uint256 tranTokenAmount, address tranTokenAddress) public payable {
        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        
        uint256 index = toIndex(contractAddress);
        Nest_3_OfferPriceData memory offerPriceData = _prices[index]; 
        
        bool thisDeviate = comparativePrice(ethAmount,tokenAmount,tranTokenAddress);
        bool isDeviate;
        if (offerPriceData.deviate == true) {
            isDeviate = true;
        } else {
            isDeviate = thisDeviate;
        }
        
        if (offerPriceData.deviate) {
            
            require(ethAmount >= tranEthAmount.mul(_tranAddition), "EthAmount needs to be no less than 2 times of transaction scale");
        } else {
            if (isDeviate) {
                
                require(ethAmount >= tranEthAmount.mul(_deviationFromScale), "EthAmount needs to be no less than 10 times of transaction scale");
            } else {
                
                require(ethAmount >= tranEthAmount.mul(_tranAddition), "EthAmount needs to be no less than 2 times of transaction scale");
            }
        }
        
        uint256 serviceCharge = tranEthAmount.mul(_tranEth).div(1000);
        require(msg.value == ethAmount.add(tranEthAmount).add(serviceCharge), "msg.value needs to be equal to the quotation eth quantity plus transaction eth plus transaction handling fee");
        require(tranEthAmount % _offerSpan == 0, "Transaction size does not meet asset span");
        
        
        require(checkContractState(offerPriceData.blockNum) == 0, "Offer status error");
        require(offerPriceData.dealEthAmount >= tranEthAmount, "Insufficient trading eth");
        require(offerPriceData.dealTokenAmount >= tranTokenAmount, "Insufficient trading token");
        require(offerPriceData.tokenAddress == tranTokenAddress, "Wrong token address");
        require(tranTokenAmount == offerPriceData.dealTokenAmount * tranEthAmount / offerPriceData.dealEthAmount, "Wrong token amount");
        
        
        offerPriceData.ethAmount = offerPriceData.ethAmount.add(tranEthAmount);
        offerPriceData.tokenAmount = offerPriceData.tokenAmount.sub(tranTokenAmount);
        offerPriceData.dealEthAmount = offerPriceData.dealEthAmount.sub(tranEthAmount);
        offerPriceData.dealTokenAmount = offerPriceData.dealTokenAmount.sub(tranTokenAmount);
        _prices[index] = offerPriceData;
        
        createOffer(ethAmount, tokenAmount, tranTokenAddress, 0, isDeviate);
        
        if (tokenAmount > tranTokenAmount) {
            ERC20(tranTokenAddress).safeTransferFrom(address(msg.sender), address(this), tokenAmount.sub(tranTokenAmount));
        } else {
            ERC20(tranTokenAddress).safeTransfer(address(msg.sender), tranTokenAmount.sub(tokenAmount));
        }
        
        _offerPrice.changePrice(tranEthAmount, tranTokenAmount, tranTokenAddress, offerPriceData.blockNum.add(_blockLimit));
        emit OfferTran(address(msg.sender), address(0x0), tranEthAmount, address(tranTokenAddress), tranTokenAmount, contractAddress, offerPriceData.owner);
        
        if (serviceCharge > 0) {
            _abonus.switchToEth.value(serviceCharge)(address(_nestToken));
        }
    }
    
    
    function sendErcBuyEth(uint256 ethAmount, uint256 tokenAmount, address contractAddress, uint256 tranEthAmount, uint256 tranTokenAmount, address tranTokenAddress) public payable {
        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        
        uint256 index = toIndex(contractAddress);
        Nest_3_OfferPriceData memory offerPriceData = _prices[index]; 
        
        bool thisDeviate = comparativePrice(ethAmount,tokenAmount,tranTokenAddress);
        bool isDeviate;
        if (offerPriceData.deviate == true) {
            isDeviate = true;
        } else {
            isDeviate = thisDeviate;
        }
        
        if (offerPriceData.deviate) {
            
            require(ethAmount >= tranEthAmount.mul(_tranAddition), "EthAmount needs to be no less than 2 times of transaction scale");
        } else {
            if (isDeviate) {
                
                require(ethAmount >= tranEthAmount.mul(_deviationFromScale), "EthAmount needs to be no less than 10 times of transaction scale");
            } else {
                
                require(ethAmount >= tranEthAmount.mul(_tranAddition), "EthAmount needs to be no less than 2 times of transaction scale");
            }
        }
        uint256 serviceCharge = tranEthAmount.mul(_tranEth).div(1000);
        require(msg.value == ethAmount.sub(tranEthAmount).add(serviceCharge), "msg.value needs to be equal to the quoted eth quantity plus transaction handling fee");
        require(tranEthAmount % _offerSpan == 0, "Transaction size does not meet asset span");
        
        
        require(checkContractState(offerPriceData.blockNum) == 0, "Offer status error");
        require(offerPriceData.dealEthAmount >= tranEthAmount, "Insufficient trading eth");
        require(offerPriceData.dealTokenAmount >= tranTokenAmount, "Insufficient trading token");
        require(offerPriceData.tokenAddress == tranTokenAddress, "Wrong token address");
        require(tranTokenAmount == offerPriceData.dealTokenAmount * tranEthAmount / offerPriceData.dealEthAmount, "Wrong token amount");
        
        
        offerPriceData.ethAmount = offerPriceData.ethAmount.sub(tranEthAmount);
        offerPriceData.tokenAmount = offerPriceData.tokenAmount.add(tranTokenAmount);
        offerPriceData.dealEthAmount = offerPriceData.dealEthAmount.sub(tranEthAmount);
        offerPriceData.dealTokenAmount = offerPriceData.dealTokenAmount.sub(tranTokenAmount);
        _prices[index] = offerPriceData;
        
        createOffer(ethAmount, tokenAmount, tranTokenAddress, 0, isDeviate);
        
        ERC20(tranTokenAddress).safeTransferFrom(address(msg.sender), address(this), tranTokenAmount.add(tokenAmount));
        
        _offerPrice.changePrice(tranEthAmount, tranTokenAmount, tranTokenAddress, offerPriceData.blockNum.add(_blockLimit));
        emit OfferTran(address(msg.sender), address(tranTokenAddress), tranTokenAmount, address(0x0), tranEthAmount, contractAddress, offerPriceData.owner);
        
        if (serviceCharge > 0) {
            _abonus.switchToEth.value(serviceCharge)(address(_nestToken));
        }
    }
    
    
    function turnOut(address contractAddress) public {
        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        uint256 index = toIndex(contractAddress);
        Nest_3_OfferPriceData storage offerPriceData = _prices[index]; 
        require(checkContractState(offerPriceData.blockNum) == 1, "Offer status error");
        
        
        if (offerPriceData.ethAmount > 0) {
            uint256 payEth = offerPriceData.ethAmount;
            offerPriceData.ethAmount = 0;
            repayEth(offerPriceData.owner, payEth);
        }
        
        
        if (offerPriceData.tokenAmount > 0) {
            uint256 payErc = offerPriceData.tokenAmount;
            offerPriceData.tokenAmount = 0;
            ERC20(address(offerPriceData.tokenAddress)).safeTransfer(offerPriceData.owner, payErc);
            
        }
        
        if (offerPriceData.serviceCharge > 0) {
            uint256 myMiningAmount = offerPriceData.serviceCharge.mul(_offerBlockMining[offerPriceData.blockNum]).div(_offerBlockEth[offerPriceData.blockNum]);
            _nestToken.safeTransfer(offerPriceData.owner, myMiningAmount);
            offerPriceData.serviceCharge = 0;
        }
        
    }
    
    
    function toIndex(address contractAddress) public pure returns(uint256) {
        return uint256(contractAddress);
    }
    
    
    function toAddress(uint256 index) public pure returns(address) {
        return address(index);
    }
    
    
    function checkContractState(uint256 createBlock) public view returns (uint256) {
        if (block.number.sub(createBlock) > _blockLimit) {
            return 1;
        }
        return 0;
    }

    
    function comparativePrice(uint256 myEthValue, uint256 myTokenValue, address token) private view returns(bool) {
        (uint256 frontEthValue, uint256 frontTokenValue) = _offerPrice.updateAndCheckPricePrivate(token);
        if (frontEthValue == 0 || frontTokenValue == 0) {
            return false;
        }
        uint256 maxTokenAmount = myEthValue.mul(frontTokenValue).mul(uint256(100).add(_deviate)).div(frontEthValue.mul(100));
        if (myTokenValue <= maxTokenAmount) {
            uint256 minTokenAmount = myEthValue.mul(frontTokenValue).mul(uint256(100).sub(_deviate)).div(frontEthValue.mul(100));
            if (myTokenValue >= minTokenAmount) {
                return false;
            }
        }
        return true;
    }
    
    
    function repayEth(address accountAddress, uint256 asset) private {
        address payable addr = accountAddress.make_payable();
        addr.transfer(asset);
    }
    
    
    function checkBlockLimit() public view returns(uint32) {
        return _blockLimit;
    }
    
    
    function checkMiningETH() public view returns (uint256) {
        return _miningETH;
    }
    
    
    function checkTokenAllow(address token) public view returns(bool) {
        return _tokenAllow[token];
    }
    
    
    function checkTranAddition() public view returns(uint256) {
        return _tranAddition;
    }
    
    
    function checkCoderAmount() public view returns(uint256) {
        return _coderAmount;
    }
    
    
    function checkNNAmount() public view returns(uint256) {
        return _NNAmount;
    }
    
    
    function checkleastEth() public view returns(uint256) {
        return _leastEth;
    }
    
    
    function checkOfferSpan() public view returns(uint256) {
        return _offerSpan;
    }
    
    
    function checkDeviate() public view returns(uint256){
        return _deviate;
    }
    
    
    function checkDeviationFromScale() public view returns(uint256) {
        return _deviationFromScale;
    }
    
    
    function checkOfferBlockEth(uint256 blockNum) public view returns(uint256) {
        return _offerBlockEth[blockNum];
    }
    
    
    function checkTranEth() public view returns (uint256) {
        return _tranEth;
    }
    
    
    function checkOfferBlockMining(uint256 blockNum) public view returns(uint256) {
        return _offerBlockMining[blockNum];
    }

    
    function checkOfferMining(uint256 blockNum, uint256 serviceCharge) public view returns (uint256) {
        if (serviceCharge == 0) {
            return 0;
        } else {
            return _offerBlockMining[blockNum].mul(serviceCharge).div(_offerBlockEth[blockNum]);
        }
    }
    
    
    function changeMiningETH(uint256 num) public onlyOwner {
        _miningETH = num;
    }
    
    
    function changeTranEth(uint256 num) public onlyOwner {
        _tranEth = num;
    }
    
    
    function changeBlockLimit(uint32 num) public onlyOwner {
        _blockLimit = num;
    }
    
    
    function changeTokenAllow(address token, bool allow) public onlyOwner {
        _tokenAllow[token] = allow;
    }
    
    
    function changeTranAddition(uint256 num) public onlyOwner {
        require(num > 0, "Parameter needs to be greater than 0");
        _tranAddition = num;
    }
    
    
    function changeInitialRatio(uint256 coderNum, uint256 NNNum) public onlyOwner {
        require(coderNum.add(NNNum) <= 100, "User allocation ratio error");
        _coderAmount = coderNum;
        _NNAmount = NNNum;
    }
    
    
    function changeLeastEth(uint256 num) public onlyOwner {
        require(num > 0);
        _leastEth = num;
    }
    
    
    function changeOfferSpan(uint256 num) public onlyOwner {
        require(num > 0);
        _offerSpan = num;
    }
    
    
    function changekDeviate(uint256 num) public onlyOwner {
        _deviate = num;
    }
    
    
    function changeDeviationFromScale(uint256 num) public onlyOwner {
        _deviationFromScale = num;
    }
    
    
    function getPriceCount() view public returns (uint256) {
        return _prices.length;
    }
    
    
    function getPrice(uint256 priceIndex) view public returns (string memory) {
        
        bytes memory buf = new bytes(500000);
        uint256 index = 0;
        
        index = writeOfferPriceData(priceIndex, _prices[priceIndex], buf, index);
        
        
        bytes memory str = new bytes(index);
        while(index-- > 0) {
            str[index] = buf[index];
        }
        return string(str);
    }
    
    
    function find(address start, uint256 count, uint256 maxFindCount, address owner) view public returns (string memory) {
        
        
        bytes memory buf = new bytes(500000);
        uint256 index = 0;
        
        
        uint256 i = _prices.length;
        uint256 end = 0;
        if (start != address(0)) {
            i = toIndex(start);
        }
        if (i > maxFindCount) {
            end = i - maxFindCount;
        }
        
        
        while (count > 0 && i-- > end) {
            Nest_3_OfferPriceData memory price = _prices[i];
            if (price.owner == owner) {
                --count;
                index = writeOfferPriceData(i, price, buf, index);
            }
        }
        
        
        bytes memory str = new bytes(index);
        while(index-- > 0) {
            str[index] = buf[index];
        }
        return string(str);
    }
    
    
    function list(uint256 offset, uint256 count, uint256 order) view public returns (string memory) {
        
        
        bytes memory buf = new bytes(500000);
        uint256 index = 0;
        
        
        uint256 i = 0;
        uint256 end = 0;
        
        if (order == 0) {
            
            
            if (offset < _prices.length) {
                i = _prices.length - offset;
            } 
            if (count < i) {
                end = i - count;
            }
            
            
            while (i-- > end) {
                index = writeOfferPriceData(i, _prices[i], buf, index);
            }
        } else {
            
            
            if (offset < _prices.length) {
                i = offset;
            } else {
                i = _prices.length;
            }
            end = i + count;
            if(end > _prices.length) {
                end = _prices.length;
            }
            
            
            while (i < end) {
                index = writeOfferPriceData(i, _prices[i], buf, index);
                ++i;
            }
        }
        
        
        bytes memory str = new bytes(index);
        while(index-- > 0) {
            str[index] = buf[index];
        }
        return string(str);
    }   
     
    
    function writeOfferPriceData(uint256 priceIndex, Nest_3_OfferPriceData memory price, bytes memory buf, uint256 index) pure private returns (uint256) {
        index = writeAddress(toAddress(priceIndex), buf, index);
        buf[index++] = byte(uint8(44));
        
        index = writeAddress(price.owner, buf, index);
        buf[index++] = byte(uint8(44));
        
        index = writeAddress(price.tokenAddress, buf, index);
        buf[index++] = byte(uint8(44));
        
        index = writeUInt(price.ethAmount, buf, index);
        buf[index++] = byte(uint8(44));
        
        index = writeUInt(price.tokenAmount, buf, index);
        buf[index++] = byte(uint8(44));
       
        index = writeUInt(price.dealEthAmount, buf, index);
        buf[index++] = byte(uint8(44));
        
        index = writeUInt(price.dealTokenAmount, buf, index);
        buf[index++] = byte(uint8(44));
        
        index = writeUInt(price.blockNum, buf, index);
        buf[index++] = byte(uint8(44));
        
        index = writeUInt(price.serviceCharge, buf, index);
        buf[index++] = byte(uint8(44));
        
        return index;
    }
     
    
    function writeUInt(uint256 iv, bytes memory buf, uint256 index) pure public returns (uint256) {
        uint256 i = index;
        do {
            buf[index++] = byte(uint8(iv % 10 +48));
            iv /= 10;
        } while (iv > 0);
        
        for (uint256 j = index; j > i; ++i) {
            byte t = buf[i];
            buf[i] = buf[--j];
            buf[j] = t;
        }
        
        return index;
    }

    
    function writeAddress(address addr, bytes memory buf, uint256 index) pure private returns (uint256) {
        
        uint256 iv = uint256(addr);
        uint256 i = index + 40;
        do {
            uint256 w = iv % 16;
            if(w < 10) {
                buf[index++] = byte(uint8(w +48));
            } else {
                buf[index++] = byte(uint8(w +87));
            }
            
            iv /= 16;
        } while (index < i);
        
        i -= 40;
        for (uint256 j = index; j > i; ++i) {
            byte t = buf[i];
            buf[i] = buf[--j];
            buf[j] = t;
        }
        
        return index;
    }
    
    
    modifier onlyOwner(){
        require(_voteFactory.checkOwners(msg.sender), "No authority");
        _;
    }
}


interface Nest_NodeAssignment {
    function bookKeeping(uint256 amount) external;
}


interface Nest_3_MiningContract {
    
    function oreDrawing() external returns (uint256);
}


interface Nest_3_VoteFactory {
    
	function checkAddress(string calldata name) external view returns (address contractAddress);
	
	function checkOwners(address man) external view returns (bool);
}


interface Nest_3_OfferPrice {
    function addPrice(uint256 ethAmount, uint256 tokenAmount, uint256 endBlock, address tokenAddress, address offerOwner) external;
    function changePrice(uint256 ethAmount, uint256 tokenAmount, address tokenAddress, uint256 endBlock) external;
    function updateAndCheckPricePrivate(address tokenAddress) external view returns(uint256 ethAmount, uint256 erc20Amount);
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