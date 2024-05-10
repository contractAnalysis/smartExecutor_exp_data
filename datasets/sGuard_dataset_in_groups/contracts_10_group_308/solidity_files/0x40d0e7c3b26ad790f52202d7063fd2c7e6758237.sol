pragma solidity ^0.6.0;


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



pragma solidity ^0.6.0;


contract Context {
    
    
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.6.0;


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

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.6.0;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}



pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;




contract TetherToken {
    function transfer(address _to, uint _value) public {}
    function transferFrom(address _from, address _to, uint _value) public {}
}

library Lending {
    
    
    
    struct Round {
        uint256 startTime;
        uint256 duration;
        uint256 apr; 
        uint256 softCap; 
        uint256 hardCap; 
        uint256 personalCap; 
        
        uint256 totalLendingAmount;
        bool withdrawn;
        bool disabled;
    }
    
    struct PersonalRound {
        Round round;
        
        uint256 lendingAmount;
        bool redeemed;
    }
}

contract AcexDeFi is
    Ownable,
    ReentrancyGuard
{
    using SafeMath for uint256;
    
    address private _usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7; 
    TetherToken private _usdtContract = TetherToken(_usdtAddress);
    uint256 public _minAmount = 0;
    uint256 public _processPeriod = 3 days;
    
    Lending.Round[] private _rounds;
    mapping (uint256 => mapping (address => uint256)) private _lendingAmounts;
    mapping (uint256 => mapping (address => bool)) private _redeemed;
    
    event Lend (
        address indexed lender,
        uint256 amount,
        uint256 round
    );
    
    event Redeem (
        address indexed lender,
        uint256 amount,
        uint256 round
    );
    
    function addRound (
        uint256 startTime,
        uint256 duration,
        uint256 apr,
        uint256 softCap,
        uint256 hardCap,
        uint256 personalCap
    )
        public
        onlyOwner 
    {
        _rounds.push(Lending.Round(
            startTime,
            duration,
            apr,
            softCap,
            hardCap,
            personalCap,
            0,
            false,
            false
        ));
    }
    
    function ownerUpdateMinAmount(uint256 minAmount)
        public
        onlyOwner
    {
        _minAmount = minAmount;
    }
    
    function ownerUpdateProcessPeriod(uint256 processPeriod)
        public
        onlyOwner
    {
        _processPeriod = processPeriod;
    }
    
    function ownerWithdrawRound(uint256 index)
        public
        onlyOwner
    {
        Lending.Round storage round = _rounds[index];
        
        
        require(!round.withdrawn, "ACEX DeFi: Round already withdrawn");
        
        
        require(now > round.startTime, "ACEX DeFi: Cannot redeem in funding phase.");
        
        
        require(round.totalLendingAmount >= round.softCap, "ACEX DeFi: Cannot redeem for failed round (lower than SoftCap).");
        
        round.withdrawn = true;
        _usdtContract.transfer(msg.sender, round.totalLendingAmount);
    }
    
    function ownerDisableRound(uint256 index)
        public
        onlyOwner
    {
        _rounds[index].disabled = true;
    }
    
    
    function ownerWithdrawAllETH()
        public
        onlyOwner
    {
        msg.sender.transfer(address(this).balance);
    }
    
    function getRounds()
        public
        view
        returns (Lending.Round[] memory rounds)
    {
        return _rounds;
    }
    
    function getPersonalRounds()
        public
        view
        returns (Lending.PersonalRound[] memory rounds)
    {
        rounds = new Lending.PersonalRound[](_rounds.length);
        
        for(uint i = 0; i < _rounds.length; i++) {
            rounds[i].round = _rounds[i];
            rounds[i].lendingAmount = _lendingAmounts[i][msg.sender];
            rounds[i].redeemed = _redeemed[i][msg.sender];
        }
        
        return rounds;
    }
    
    function lend (
        uint256 index,
        uint256 amount
    )
        public
        nonReentrant
    {
        Lending.Round storage round = _rounds[index];
        
        
        require(!round.disabled, "ACEX DeFi: Round is disabled.");
        
        
        require(now < round.startTime, "ACEX DeFi: Funding phase has passed.");
        
        
        require(amount > _minAmount, "ACEX DeFi: Amount too low");
        
        
        uint256 personalLendingAmount = _lendingAmounts[index][msg.sender].add(amount);
        require(personalLendingAmount <= round.personalCap, "ACEX DeFi: Exceeds personal cap.");
        
        
        uint256 totalLendingAmount = round.totalLendingAmount.add(amount);
        require(totalLendingAmount <= round.hardCap, "ACEX DeFi: Exceeds round hard cap.");
        
        _usdtContract.transferFrom(msg.sender, address(this), amount);
        _lendingAmounts[index][msg.sender] = personalLendingAmount;
        round.totalLendingAmount = totalLendingAmount;
        
        emit Lend(msg.sender, amount, index);
    }
    
    function redeem (
        uint256 index
    )
        public
        nonReentrant
    {
        Lending.Round storage round = _rounds[index];
        
        
        require(!round.disabled, "ACEX DeFi: Round is disabled.");
        
        
        require(now > round.startTime, "ACEX DeFi: Cannot redeem in funding phase.");
        
        
        require(!_redeemed[index][msg.sender], "ACEX DeFi: Already redeemed.");
        
        if (round.totalLendingAmount < round.softCap) {
            
            
            
            uint256 originalAmount = _lendingAmounts[index][msg.sender];
            
            _usdtContract.transfer(msg.sender, originalAmount);
            _redeemed[index][msg.sender] = true;
            emit Redeem(msg.sender, originalAmount, index);
        } else {
            
            
            
            require(now > round.startTime.add(round.duration).add(_processPeriod), "ACEX DeFi: Not redeem phase yet.");
            
            uint256 originalAmount = _lendingAmounts[index][msg.sender];
            
            
            uint256 interestAmount = originalAmount.mul(round.apr).mul(round.duration).div(1000).div(365 days);
            uint256 totalAmount = originalAmount + interestAmount;
            
            _usdtContract.transfer(msg.sender, totalAmount);
            _redeemed[index][msg.sender] = true;
            emit Redeem(msg.sender, totalAmount, index);
        }
    }
}