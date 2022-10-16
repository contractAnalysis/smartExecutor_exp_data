pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


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

library StableMath {

    using SafeMath for uint256;

    
    uint256 private constant FULL_SCALE = 1e18;

    
    uint256 private constant RATIO_SCALE = 1e8;

    
    function getFullScale() internal pure returns (uint256) {
        return FULL_SCALE;
    }

    
    function getRatioScale() internal pure returns (uint256) {
        return RATIO_SCALE;
    }

    
    function scaleInteger(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return x.mul(FULL_SCALE);
    }

    

    
    function mulTruncate(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return mulTruncateScale(x, y, FULL_SCALE);
    }

    
    function mulTruncateScale(uint256 x, uint256 y, uint256 scale)
        internal
        pure
        returns (uint256)
    {
        
        
        uint256 z = x.mul(y);
        
        return z.div(scale);
    }

    
    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        
        uint256 scaled = x.mul(y);
        
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        
        return ceil.div(FULL_SCALE);
    }

    
    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        
        uint256 z = x.mul(FULL_SCALE);
        
        return z.div(y);
    }


    

    
    function mulRatioTruncate(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {
        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    
    function mulRatioTruncateCeil(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256)
    {
        
        
        uint256 scaled = x.mul(ratio);
        
        uint256 ceil = scaled.add(RATIO_SCALE.sub(1));
        
        return ceil.div(RATIO_SCALE);
    }


    
    function divRatioPrecisely(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {
        
        uint256 y = x.mul(RATIO_SCALE);
        
        return y.div(ratio);
    }

    

    
    function min(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return x > y ? y : x;
    }

    
    function max(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return x > y ? x : y;
    }

    
    function clamp(uint256 x, uint256 upperBound)
        internal
        pure
        returns (uint256)
    {
        return x > upperBound ? upperBound : x;
    }
}

interface MassetStructs {

    
    struct Basket {

        
        Basset[] bassets;

        
        uint8 maxBassets;

        
        bool undergoingRecol;

        
        bool failed;
        uint256 collateralisationRatio;

    }

    
    struct Basset {

        
        address addr;

        
        BassetStatus status; 

        
        bool isTransferFeeCharged; 

        
        uint256 ratio;

        
        uint256 maxWeight;

        
        uint256 vaultBalance;

    }

    
    enum BassetStatus {
        Default,
        Normal,
        BrokenBelowPeg,
        BrokenAbovePeg,
        Blacklisted,
        Liquidating,
        Liquidated,
        Failed
    }

    
    struct BassetDetails {
        Basset bAsset;
        address integrator;
        uint8 index;
    }

    
    struct ForgePropsMulti {
        bool isValid; 
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }

    
    struct RedeemPropsMulti {
        uint256 colRatio;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
}

contract IBasketManager is MassetStructs {
    function paused() external view returns (bool);
    function getBasket() external view returns (Basket memory b);
    function getBasset(address _token) external view
        returns (Basset memory bAsset);
}

contract IForgeValidator is MassetStructs {
    function validateRedemption(
        bool basketIsFailed,
        uint256 _totalVault,
        Basset[] calldata _allBassets,
        uint8[] calldata _indices,
        uint256[] calldata _bassetQuantities) external pure returns (bool, string memory, bool);
}

interface IMasset {
    function getBasketManager() external view returns(address);
    function forgeValidator() external view returns(address);
    function totalSupply() external view returns(uint256);
    function swapFee() external view returns(uint256);
}


contract MassetRedemptionValidator is MassetStructs {

    using StableMath for uint256;
    using SafeMath for uint256;

    function getRedeemValidity(
        address _mAsset,
        uint256 _mAssetQuantity,
        address _outputBasset
    )
        public
        view
        returns (bool, string memory, uint256 output)
    {
        
        IBasketManager basketManager = IBasketManager(IMasset(_mAsset).getBasketManager());
        Basset memory bAsset = basketManager.getBasset(_outputBasset);
        uint256 bAssetOutput = _mAssetQuantity.divRatioPrecisely(bAsset.ratio);

        
        address[] memory bAssets = new address[](1);
        uint256[] memory quantities = new uint256[](1);
        bAssets[0] = _outputBasset;
        quantities[0] = bAssetOutput;

        return _getRedeemValidity(_mAsset, bAssets, quantities);
    }

    function _getRedeemValidity(
        address _mAsset,
        address[] memory _bAssets,
        uint256[] memory _bAssetQuantities
    )
        internal
        view
        returns (bool, string memory, uint256 output)
    {
        uint256 bAssetCount = _bAssetQuantities.length;
        require(bAssetCount == 1 && bAssetCount == _bAssets.length, "Input array mismatch");

        IMasset mAsset = IMasset(_mAsset);
        IBasketManager basketManager = IBasketManager(mAsset.getBasketManager());

        Basket memory basket = basketManager.getBasket();

        if(basket.undergoingRecol || basketManager.paused()){
            return (false, "Invalid basket state", 0);
        }

        (bool redemptionValid, string memory reason, bool applyFee) =
            _validateRedeem(mAsset, _bAssetQuantities, _bAssets[0], basket.failed, mAsset.totalSupply(),  basket.bassets);
        if(!redemptionValid){
            return (false, reason, 0);
        }
        uint256 fee = applyFee ? mAsset.swapFee() : 0;
        uint256 feeAmount = _bAssetQuantities[0].mulTruncate(fee);
        uint256 outputMinusFee = _bAssetQuantities[0].sub(feeAmount);
        return (true, "", outputMinusFee);
    }

    function _validateRedeem(
        IMasset mAsset,
        uint256[] memory quantities,
        address bAsset,
        bool failed,
        uint256 supply,
        Basset[] memory allBassets
    )
        internal
        view
        returns (bool, string memory, bool)
    {
        IForgeValidator forgeValidator = IForgeValidator(mAsset.forgeValidator());
        uint8[] memory bAssetIndexes = new uint8[](1);
        for(uint8 i = 0; i < uint8(allBassets.length); i ++) {
            if(allBassets[i].addr == bAsset) {
                bAssetIndexes[0] = i;
                break;
            }
        }
        return forgeValidator.validateRedemption(failed, supply, allBassets, bAssetIndexes, quantities);
    }
}