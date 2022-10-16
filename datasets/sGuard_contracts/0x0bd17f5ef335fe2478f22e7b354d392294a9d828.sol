pragma solidity 0.5.17;

interface IToken { 
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


contract TermsOfService { 
    
    address public leethToken = 0x15Dbc0A51FAD8F932872cB00EfC868f52FA99807; 
    IToken private leeth = IToken(leethToken);
    address public ownerToken = 0x7bfCB5772FE0BDB53Ad829340dD92123Ed1196eC; 
    IToken private owner = IToken(ownerToken);
    
    uint256 public purchaseRate;
    uint256 public redemptionAmount;
    string public emoji = "📜⚖";
    string public offer;
    string public terms;
    
    
    uint256 public signature; 
    mapping (uint256 => Signature) public sigs;
    
    struct Signature {  
        address signatory;
        uint256 number;
        string details;
        string terms;
    }
    
    event OfferUpgraded(string indexed _offer);
    event Purchased(address indexed sender, uint256 indexed purchaseAmount);
    event PurchaseRateUpgraded(uint256 indexed _purchaseRate);
    event RedemptionAmountUpgraded(uint256 indexed _redemptionAmount);
    event Signed(address indexed signatory, uint256 indexed number, string indexed details);
    event TermsUpgraded(string indexed _terms);
    
    constructor (uint256 _purchaseRate, uint256 _redemptionAmount, string memory _offer, string memory _terms) public {
        purchaseRate = _purchaseRate;
        redemptionAmount = _redemptionAmount;
        offer = _offer;
        terms = _terms;
    } 
    
    
    function() external payable { 
        uint256 purchaseAmount = msg.value * purchaseRate;
        leeth.transfer(msg.sender, purchaseAmount);
        emit Purchased(msg.sender, purchaseAmount);
    } 
    
    function redeemOffer(string memory details) public {
	    uint256 number = signature + 1; 
	    signature = signature + 1;
	    
        sigs[number] = Signature( 
            msg.sender,
            number,
            details,
            terms);
                
        leeth.transferFrom(msg.sender, address(this), redemptionAmount);
        emit Signed(msg.sender, number, details);
    }
 
    
    modifier onlyOwner () {
        require(owner.balanceOf(msg.sender) > 0, "ownerToken balance insufficient");
        _;
    }
    
    
    function upgradeOffer(string memory _offer) public onlyOwner {
        offer = _offer;
        emit OfferUpgraded(_offer);
    } 
    
    function upgradeTerms(string memory _terms) public onlyOwner {
        terms = _terms;
        emit TermsUpgraded(_terms);
    } 
    
    
    function upgradePurchaseRate(uint256 _purchaseRate) public onlyOwner {
        purchaseRate = _purchaseRate;
        emit PurchaseRateUpgraded(_purchaseRate);
    }
    
    function upgradeRedemptionAmount(uint256 _redemptionAmount) public onlyOwner {
        redemptionAmount = _redemptionAmount;
        emit RedemptionAmountUpgraded(_redemptionAmount);
    }
    
    function withdrawETH() public onlyOwner {
        address(msg.sender).transfer(address(this).balance);
    }
    
    function withdrawLEETH() public onlyOwner {
        leeth.transfer(msg.sender, leeth.balanceOf(address(this)));
    } 
}