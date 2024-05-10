pragma solidity 0.5.10;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



interface IMarket {
	
    event Approval(
      address indexed owner,
      address indexed spender,
      uint256 value
    );
    
    event Transfer(address indexed from, address indexed to, uint value);
    
    event Mint(
      address indexed to,			
      uint256 amountMinted,			
      uint256 collateralAmount,		
      uint256 researchContribution	
    );
    
    event Burn(
      address indexed from,			
      uint256 amountBurnt,			
      uint256 collateralReturned	
    );
	
    event MarketTerminated();

    
    function approve(address _spender, uint256 _value) external returns (bool);

     
    function burn(uint256 _numTokens) external returns(bool);

    
    function mint(address _to, uint256 _numTokens) external returns(bool);

    
    function transfer(address _to, uint256 _value) external returns (bool);

    
    function transferFrom(
		address _from,
		address _to,
		uint256 _value
	)
		external
		returns(bool);

    
    function finaliseMarket() external returns(bool);

    
    function withdraw(uint256 _amount) external returns(bool);

    
    function priceToMint(uint256 _numTokens) external view returns(uint256);

    
    function rewardForBurn(uint256 _numTokens) external view returns(uint256);

    
    function collateralToTokenBuying(
		uint256 _collateralTokenOffered
	)
		external
		view
		returns(uint256);

    
    function collateralToTokenSelling(
		uint256 _collateralTokenNeeded
	)
		external
		view
		returns(uint256);

    
    function allowance(
		address _owner,
		address _spender
	)
		external
		view
		returns(uint256);

    
    function balanceOf(address _owner) external view returns (uint256);

    
    function poolBalance() external view returns (uint256);

    
    function totalSupply() external view returns (uint256);

    
    function feeRate() external view returns(uint256);

    
    function decimals() external view returns(uint256);

    
    function active() external view returns(bool);
}



interface IVault {
	
	enum FundingState { NOT_STARTED, STARTED, ENDED, PAID }
	
	event FundingWithdrawn(uint256 phase, uint256 amount);
	
	event PhaseFinalised(uint256 phase, uint256 amount);

   	
    function initialize(address _market) external returns(bool);

    
    function withdraw() external returns(bool);

    
    function validateFunding(uint256 _receivedFunding) external returns(bool);

	
    function terminateMarket() external;

	
    function fundingPhase(
      uint256 _phase
    )
		external
		view
		returns(
			uint256,
			uint256,
			uint256,
			uint256,
			FundingState
		);

	
    function outstandingWithdraw() external view returns(uint256);

	
    function currentPhase() external view returns(uint256);

	
    function getTotalRounds() external view returns(uint256);

	
    function market() external view returns(address);

	
    function creator() external view returns(address);
}


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



interface ICurveFunctions {
    
    function curveIntegral(uint256 _x) external pure returns(uint256);

    
    function inverseCurveIntegral(uint256 _x) external pure returns(uint256);
}







contract Market is IMarket, IERC20 {
    
    using SafeMath for uint256;

    
    bool internal active_ = true;
    
    IVault internal creatorVault_;
    
    uint256 internal feeRate_;
    
    ICurveFunctions internal curveLibrary_;
    
    IERC20 internal collateralToken_;
    
    uint256 internal totalSupply_;
    
    uint256 internal decimals_ = 18;

    
    mapping(address => mapping (address => uint256)) internal allowed;
    
    mapping(address => uint256) internal balances;

    
    constructor(
        uint256 _feeRate,
        address _creatorVault,
        address _curveLibrary,
        address _collateralToken
    )
        public
    {
        
        feeRate_ = _feeRate;
        creatorVault_ = IVault(_creatorVault);
        curveLibrary_ = ICurveFunctions(_curveLibrary);
        collateralToken_ = IERC20(_collateralToken);
    }

    
    modifier onlyActive(){
        require(active_, "Market inactive");
        _;
    }

    
    modifier onlyVault(){
        require(msg.sender == address(creatorVault_), "Invalid requestor");
        _;
    }

    
    function burn(uint256 _numTokens) external onlyActive() returns(bool) {
        require(
            balances[msg.sender] >= _numTokens,
            "Not enough tokens available"
        );

        uint256 reward = rewardForBurn(_numTokens);

        totalSupply_ = totalSupply_.sub(_numTokens);
        balances[msg.sender] = balances[msg.sender].sub(_numTokens);

        require(
            collateralToken_.transfer(
                msg.sender,
                reward
            ),
            "Tokens not sent"
        );

        emit Transfer(msg.sender, address(0), _numTokens);
        emit Burn(msg.sender, _numTokens, reward);
        return true;
    }

    
    function mint(
        address _to,
        uint256 _numTokens
    )
        external
        onlyActive()
        returns(bool)
    {
        
        uint256 priceForTokens = priceToMint(_numTokens);
        
        
        require(priceForTokens > 0, "Tokens requested too low");

        
        uint256 fee = priceForTokens.mul(feeRate_).div(100);
        
        require(
            collateralToken_.transferFrom(
                msg.sender,
                address(this),
                priceForTokens
            ),
            "Collateral transfer failed"
        );
        
        require(
            collateralToken_.transfer(
                address(creatorVault_),
                fee
            ),
            "Vault fee not transferred"
        );

        
        totalSupply_ = totalSupply_.add(_numTokens);
        
        balances[msg.sender] = balances[msg.sender].add(_numTokens);
        
        require(
            creatorVault_.validateFunding(fee),
            "Funding validation failed"
        );
        
        uint256 priceWithoutFee = priceForTokens.sub(fee);

        emit Transfer(address(0), _to, _numTokens);
        emit Mint(_to, _numTokens, priceWithoutFee, fee);
        return true;
    }

	    
    function collateralToTokenBuying(
        uint256 _collateralTokenOffered
    )
        external
        view
        returns(uint256)
    {
        
        uint256 fee = _collateralTokenOffered.mul(feeRate_).div(100);
        
        uint256 amountLessFee = _collateralTokenOffered.sub(fee);
        
        return _inverseCurveIntegral(
                _curveIntegral(totalSupply_).add(amountLessFee)
            ).sub(totalSupply_);
    }

    
    function collateralToTokenSelling(
        uint256 _collateralTokenNeeded
    )
        external
        view
        returns(uint256)
    {
        return uint256(
            totalSupply_.sub(
                _inverseCurveIntegral(
                    _curveIntegral(totalSupply_).sub(_collateralTokenNeeded)
                )
            )
        );
    }

    
    function poolBalance() external view returns (uint256){
        return collateralToken_.balanceOf(address(this));
    }

    
    function feeRate() external view returns(uint256) {
        return feeRate_;
    }

    
    function decimals() external view returns(uint256) {
        return decimals_;
    }

    
    function active() external view returns(bool){
        return active_;
    }

    
    function finaliseMarket() public onlyVault() returns(bool) {
        require(active_, "Market deactivated");
        active_ = false;
        emit MarketTerminated();
        return true;
    }

    
    function withdraw(uint256 _amount) public returns(bool) {
        
        require(!active_, "Market not finalised");
        
        require(_amount <= balances[msg.sender], "Insufficient funds");
        
        require(_amount > 0, "Cannot withdraw 0");

        
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        
        uint256 balance = collateralToken_.balanceOf(address(this));

        
        uint256 collateralToTransfer = balance.mul(_amount).div(totalSupply_);
        
        totalSupply_ = totalSupply_.sub(_amount);

        
        require(
            collateralToken_.transfer(msg.sender, collateralToTransfer),
            "Dai transfer failed"
        );

        emit Transfer(msg.sender, address(0), _amount);
        emit Burn(msg.sender, _amount, collateralToTransfer);

        return true;
    }

    
    function priceToMint(uint256 _numTokens) public view returns(uint256) {
        
        uint256 balance = collateralToken_.balanceOf(address(this));
        
        uint256 collateral = _curveIntegral(
                totalSupply_.add(_numTokens)
            ).sub(balance);
        
        uint256 baseUnit = 100;
        
        uint256 result = collateral.mul(100).div(baseUnit.sub(feeRate_));
        return result;
    }

    
    function rewardForBurn(uint256 _numTokens) public view returns(uint256) {
        
        uint256 poolBalanceFetched = collateralToken_.balanceOf(address(this));
        
        
        return poolBalanceFetched.sub(
            _curveIntegral(totalSupply_.sub(_numTokens))
        );
    }

    
    function _curveIntegral(uint256 _x) internal view returns (uint256) {
        return curveLibrary_.curveIntegral(_x);
    }

    
    function _inverseCurveIntegral(uint256 _x) internal view returns(uint256) {
        return curveLibrary_.inverseCurveIntegral(_x);
    }

	
	
	

	
    function totalSupply() external view returns (uint256) {
        return totalSupply_;
    }

	
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

	
    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    
    function approve(
        address _spender,
        uint256 _value
    )
        external
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    function increaseAllowance(
        address _spender,
        uint256 _addedValue
    )
        public
        returns(bool) 
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender]
            .add(_addedValue);
        emit Approval(msg.sender, _spender, _addedValue);
        return true;
    }

    
    function decreaseAllowance(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns(bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender]
            .sub(_subtractedValue);
        emit Approval(msg.sender, _spender, _subtractedValue);
        return true;
    }

	
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_value <= balances[_from], "Requested amount exceeds balance");
        require(_value <= allowed[_from][msg.sender], "Allowance exceeded");
        require(_to != address(0), "Target account invalid");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

	
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender], "Insufficient funds");
        require(_to != address(0), "Target account invalid");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}