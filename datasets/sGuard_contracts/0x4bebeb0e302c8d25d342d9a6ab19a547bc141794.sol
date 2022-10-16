pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

interface ERC20Interface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
}

interface InstaCompoundMapping {
    function ctokenAddrs(address) external view returns (address);
}


contract SoloMarginContract {

    struct Info {
        address owner;  
        uint256 number; 
    }

    enum ActionType {
        Deposit,   
        Withdraw,  
        Transfer,  
        Buy,       
        Sell,      
        Trade,     
        Liquidate, 
        Vaporize,  
        Call       
    }

    enum AssetDenomination {
        Wei, 
        Par  
    }

    enum AssetReference {
        Delta, 
        Target 
    }

    struct AssetAmount {
        bool sign; 
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct Wei {
        bool sign; 
        uint256 value;
    }

    function operate(Info[] memory accounts, ActionArgs[] memory actions) public;
    function getAccountWei(Info memory account, uint256 marketId) public view returns (Wei memory);
    function getNumMarkets() public view returns (uint256);
    function getMarketTokenAddress(uint256 marketI) public view returns (address);
}

interface PoolInterface {
    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;
    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;
}


contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y <= x ? x - y : 0;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}


contract Helpers is DSMath {

    
    function getAddressETH() public pure returns (address eth) {
        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

        
    function getAddressWETH() public pure returns (address weth) {
        weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }

    
    function getSoloAddress() public pure returns (address addr) {
        addr = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    }

    
    function getPoolAddress() public pure returns (address payable liqAddr) {
        liqAddr = 0x1564D040EC290C743F67F5cB11f3C1958B39872A;
    }

    
    function getCompMappingAddr() public pure returns (address compMap) {
        compMap = 0x3e980fB77B2f63613cDDD3C130E4cc10E90Ad6d1;
    }

    
    function setApproval(address erc20, uint srcAmt, address to) internal {
        ERC20Interface erc20Contract = ERC20Interface(erc20);
        uint tokenAllowance = erc20Contract.allowance(address(this), to);
        if (srcAmt > tokenAllowance) {
            erc20Contract.approve(to, uint(-1));
        }
    }

    
    function getActionsArgs(
        address tknAccount,
        uint accountIndex,
        uint256 marketId,
        uint256 tokenAmt,
        bool sign
    ) internal pure returns (SoloMarginContract.ActionArgs[] memory)
    {
        SoloMarginContract.ActionArgs[] memory actions = new SoloMarginContract.ActionArgs[](1);
        SoloMarginContract.AssetAmount memory amount = SoloMarginContract.AssetAmount(
            sign,
            SoloMarginContract.AssetDenomination.Wei,
            SoloMarginContract.AssetReference.Delta,
            tokenAmt
        );
        bytes memory empty;
        
        SoloMarginContract.ActionType action = sign ? SoloMarginContract.ActionType.Deposit : SoloMarginContract.ActionType.Withdraw;
        actions[0] = SoloMarginContract.ActionArgs(
            action,
            accountIndex,
            amount,
            marketId,
            0,
            tknAccount,
            0,
            empty
        );
        return actions;
    }

    
    function getAccountArgs(address owner, uint accountId) internal pure returns (SoloMarginContract.Info[] memory) {
        SoloMarginContract.Info[] memory accounts = new SoloMarginContract.Info[](1);
        accounts[0] = (SoloMarginContract.Info(owner, accountId));
        return accounts;
    }

    
    function getDydxBal(address owner, uint256 marketId, uint accountId) internal view returns (uint tokenBal, bool tokenSign) {
        SoloMarginContract solo = SoloMarginContract(getSoloAddress());
        SoloMarginContract.Wei memory tokenWeiBal = solo.getAccountWei(getAccountArgs(owner, accountId)[0], marketId);
        tokenBal = tokenWeiBal.value;
        tokenSign = tokenWeiBal.sign;
    }

}


contract ImportHelper is Helpers {
    struct BorrowData {
        uint[] borrowAmt;
        address[] borrowAddr;
        address[] borrowCAddr;
        uint[] marketId;
        uint borrowCount;
    }

    struct SupplyData {
        uint[] supplyAmt;
        address[] supplyAddr;
        uint[] marketId;
        uint supplyCount;
    }

    function getTokensData(uint accountId, uint toConvert) public returns(SupplyData memory, BorrowData memory) {
        SoloMarginContract solo = SoloMarginContract(getSoloAddress());
        uint markets = solo.getNumMarkets();
        SupplyData memory supplyDataArr;
        supplyDataArr.supplyAmt = new uint[](markets);
        supplyDataArr.marketId = new uint[](markets);
        supplyDataArr.supplyAddr = new address[](markets);
        BorrowData memory borrowDataArr;
        borrowDataArr.borrowAmt = new uint[](markets);
        borrowDataArr.marketId = new uint[](markets);
        borrowDataArr.borrowAddr = new address[](markets);
        borrowDataArr.borrowCAddr = new address[](markets);
        uint borrowCount = 0;
        uint supplyCount = 0;

        for (uint i = 0; i < markets; i++) {
            (uint tokenbal, bool tokenSign) = getDydxBal(msg.sender, i, accountId);
            if (tokenbal > 0) {
                if (tokenSign) {
                    supplyDataArr.supplyAmt[supplyCount] = wmul(tokenbal, toConvert);
                    supplyDataArr.supplyAddr[supplyCount] = solo.getMarketTokenAddress(i);
                    supplyDataArr.marketId[supplyCount] = i;
                    supplyCount++;
                } else {
                    address erc20 = solo.getMarketTokenAddress(i);
                    borrowDataArr.borrowAmt[borrowCount] = wmul(tokenbal, toConvert);
                    borrowDataArr.borrowAddr[borrowCount] = erc20;
                    borrowDataArr.borrowCAddr[borrowCount] = InstaCompoundMapping(getCompMappingAddr()).ctokenAddrs(erc20 == getAddressWETH() ? getAddressETH() : erc20);
                    borrowDataArr.marketId[borrowCount] = i;
                    borrowCount++;
                }
                setApproval(solo.getMarketTokenAddress(i), uint(-1), getSoloAddress());
            }
        }
        borrowDataArr.borrowCount = borrowCount;
        supplyDataArr.supplyCount = supplyCount;
        return (supplyDataArr, borrowDataArr);
    }

    function getOperatorActionsArgs(SupplyData memory suppyArr, BorrowData memory borrowArr) public view
    returns(SoloMarginContract.ActionArgs[] memory)
    {
        uint borrowCount = borrowArr.borrowCount;
        uint supplyCount = suppyArr.supplyCount;
        uint totalCount = borrowCount + supplyCount;
        SoloMarginContract.ActionArgs[] memory actions = new SoloMarginContract.ActionArgs[](totalCount*2);

        for (uint i = 0; i < borrowCount; i++) {
            actions[i] = getActionsArgs(
                address(this),
                0,
                borrowArr.marketId[i],
                borrowArr.borrowAmt[i],
                true
            )[0];
            actions[i + totalCount + supplyCount] = getActionsArgs(
                getPoolAddress(), 
                1,
                borrowArr.marketId[i],
                borrowArr.borrowAmt[i],
                false
            )[0];
        }

        for (uint i = 0; i < supplyCount; i++) {
            uint baseIndex = borrowCount + i;
            actions[baseIndex] = getActionsArgs(
                address(this),
                0,
                suppyArr.marketId[i],
                suppyArr.supplyAmt[i],
                false
            )[0];
            actions[baseIndex + supplyCount] = getActionsArgs(
                address(this),
                1,
                suppyArr.marketId[i],
                suppyArr.supplyAmt[i],
                true
            )[0];
        }
        return (actions);
    }

    function getOperatorAccountArgs(uint accountId) public view returns (SoloMarginContract.Info[] memory) {
        SoloMarginContract.Info[] memory accounts = new SoloMarginContract.Info[](2);
        accounts[0] = getAccountArgs(msg.sender, accountId)[0];
        accounts[1] = getAccountArgs(address(this), 0)[0];
        return accounts;
    }
}


contract ImportResolver is  ImportHelper {
    event LogDydxImport(address owner, uint accountId, uint percentage, bool isCompound, SupplyData supplyData, BorrowData borrowData);

    function importAssets(
        uint toConvert,
        uint accountId,
        bool isCompound
    ) external
    {
        
        uint initialPoolBal = sub(getPoolAddress().balance, 10000000000);
        (SupplyData memory supplyArr, BorrowData memory borrowArr) = getTokensData(accountId, toConvert);

        
        if (borrowArr.borrowCount > 0) {
            PoolInterface(getPoolAddress()).accessToken(borrowArr.borrowCAddr, borrowArr.borrowAmt, isCompound);
        }

        
        SoloMarginContract.ActionArgs[] memory actions = getOperatorActionsArgs(supplyArr, borrowArr);
        SoloMarginContract.Info[] memory accounts = getOperatorAccountArgs(accountId);

        
        SoloMarginContract solo = SoloMarginContract(getSoloAddress());
        solo.operate(accounts, actions);

        
        if (borrowArr.borrowCount > 0) {
            PoolInterface(getPoolAddress()).paybackToken(borrowArr.borrowCAddr, isCompound);
        }

        uint finalPoolBal = getPoolAddress().balance;
        assert(finalPoolBal >= initialPoolBal);

        emit LogDydxImport(
            msg.sender,
            accountId,
            toConvert,
            isCompound,
            supplyArr,
            borrowArr
        );
    }

}


contract InstaDydxImport is ImportResolver {
    function() external payable {}
}