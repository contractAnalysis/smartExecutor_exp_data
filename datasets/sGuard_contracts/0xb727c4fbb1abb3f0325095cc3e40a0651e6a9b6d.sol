pragma solidity 0.4.26;

contract Math {

    
    
    

    
    function absDiff(uint256 v1, uint256 v2)
        internal
        pure
        returns(uint256)
    {
        return v1 > v2 ? v1 - v2 : v2 - v1;
    }

    
    function divRound(uint256 v, uint256 d)
        internal
        pure
        returns(uint256)
    {
        return add(v, d/2) / d;
    }

    
    
    
    
    function decimalFraction(uint256 amount, uint256 frac)
        internal
        pure
        returns(uint256)
    {
        
        return proportion(amount, frac, 10**18);
    }

    
    
    function proportion(uint256 amount, uint256 part, uint256 total)
        internal
        pure
        returns(uint256)
    {
        return divRound(mul(amount, part), total);
    }

    
    
    

    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a > b ? a : b;
    }
}







contract IContractId {
    
    
    function contractId() public pure returns (bytes32 id, uint256 version);
}







contract PlatformTerms is Math, IContractId {

    
    
    

    
    uint256 public constant PLATFORM_FEE_FRACTION = 3 * 10**16;
    
    uint256 public constant TOKEN_PARTICIPATION_FEE_FRACTION = 2 * 10**16;
    
    
    
    uint256 public constant PLATFORM_NEUMARK_SHARE = 2; 
    
    bool public constant IS_ICBM_INVESTOR_WHITELISTED = true;

    
    uint256 public constant TOKEN_RATE_EXPIRES_AFTER = 4 hours;

    
    uint256 public constant DEFAULT_DISBURSAL_RECYCLE_AFTER_DURATION = 4 * 365 days;

    
    
    

    
    function calculateNeumarkDistribution(uint256 rewardNmk)
        public
        pure
        returns (uint256 platformNmk, uint256 investorNmk)
    {
        
        platformNmk = rewardNmk / PLATFORM_NEUMARK_SHARE;
        
        return (platformNmk, rewardNmk - platformNmk);
    }

    
    
    
    
    
    function calculatePlatformTokenFee(uint256 tokenAmount)
        public
        pure
        returns (uint256)
    {
        
        
        return divRound(tokenAmount, 50);
    }

    
    function calculateAmountWithoutFee(uint256 tokenAmountWithFee)
        public
        pure
        returns (uint256)
    {
        
        return divRound(mul(tokenAmountWithFee, 50), 51);
    }

    function calculatePlatformFee(uint256 amount)
        public
        pure
        returns (uint256)
    {
        return decimalFraction(amount, PLATFORM_FEE_FRACTION);
    }

    
    
    

    function contractId() public pure returns (bytes32 id, uint256 version) {
        return (0x95482babc4e32de6c4dc3910ee7ae62c8e427efde6bc4e9ce0d6d93e24c39323, 2);
    }
}