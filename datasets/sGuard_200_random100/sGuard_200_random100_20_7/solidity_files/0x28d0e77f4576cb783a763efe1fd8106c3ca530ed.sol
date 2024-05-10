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


library ECDSA {
    
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        
        bytes32 r;
        bytes32 s;
        uint8 v;

        
        
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        
        
        
        
        
        
        
        
        
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        
        
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}




pragma solidity ^0.6.0;




contract Escrow {

    using SafeMath for uint256;
    using ECDSA for bytes32;

    event FundsDeposited(address indexed buyer, uint256 amount);
    event FundsRefunded();
    event FundsReleased(address indexed seller, uint256 amount);
    event DisputeResolved();
    event OwnershipTransferred(address indexed oldOwner, address newOwner);
    event MediatorChanged(address indexed oldMediator, address newMediator);

    enum Status { AWAITING_PAYMENT, PAID, REFUNDED, MEDIATED, COMPLETE }

    Status public status;
    bytes32 escrowID;
    uint256 amount;
    uint256 fee;
    address payable public owner;
    address payable public mediator;
    address payable public buyer;
    address payable public seller;
    bool public initialized = false;
    bool public funded = false;
    bool public completed = false;
    bytes32 public releaseMsgHash;
    bytes32 public resolveMsgHash;

    modifier onlyExactAmount(uint256 _amount) {
        require(_amount == depositAmount(), "Amount needs to be exact.");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function.");
        _;
    }

    modifier onlyWithBuyerSignature(bytes32 hash, bytes memory signature) {
        require(
            hash.toEthSignedMessageHash()
                .recover(signature) == buyer,
            "Must be signed by buyer."
        );
        _;
    }

    modifier onlyWithParticipantSignature(bytes32 hash, bytes memory signature) {
        address signer = hash.toEthSignedMessageHash()
            .recover(signature);
        require(
            signer == buyer || signer == seller,
            "Must be signed by either buyer or seller."
        );
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only the seller can call this function.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyMediator() {
        require(msg.sender == mediator, "Only the mediator can call this function.");
        _;
    }

    modifier onlyUninitialized() {
        require(initialized == false, "Escrow already initialized.");
        initialized = true;
        _;
    }

    modifier onlyUnfunded() {
        require(funded == false, "Escrow already funded.");
        funded = true;
        _;
    }

    modifier onlyFunded() {
        require(funded == true, "Escrow not funded.");
        _;
    }

    modifier onlyIncompleted() {
        require(completed == false, "Escrow already completed.");
        completed = true;
        _;
    }

    function init(
        bytes32 _escrowID,
        address payable _owner,
        address payable _buyer,
        address payable  _seller,
        address payable _mediator,
        uint256 _amount,
        uint256 _fee
    )
        external
        onlyUninitialized
    {
        status = Status.AWAITING_PAYMENT;
        escrowID = _escrowID;
        owner = _owner;
        buyer = _buyer;
        seller = _seller;
        mediator = _mediator;
        amount = _amount;
        fee = _fee;
        releaseMsgHash = keccak256(
            abi.encodePacked("releaseFunds()", escrowID, address(this))
        );
        resolveMsgHash = keccak256(
            abi.encodePacked("resolveDispute()", escrowID, address(this))
        );
        emit OwnershipTransferred(address(0), _owner);
        emit MediatorChanged(address(0), _owner);
    }

    fallback() external payable {
        deposit();
    }

    function depositAmount() public view returns (uint256) {
        return amount;
    }

    function deposit()
        public
        payable
        onlyUnfunded
        onlyExactAmount(msg.value)
    {
        status = Status.PAID;
        emit FundsDeposited(msg.sender, msg.value);
    }

    function refund()
        public
        onlySeller
        onlyFunded
        onlyIncompleted
    {
        buyer.transfer(depositAmount());
        status = Status.REFUNDED;
        emit FundsRefunded();
    }

    function _releaseFees() private {
        mediator.transfer(fee);
    }

    function releaseFunds(
        bytes calldata _signature
    )
        external
        onlyFunded
        onlyIncompleted
        onlyWithBuyerSignature(releaseMsgHash, _signature)
    {
        uint256 releaseAmount = depositAmount().sub(fee);
        status = Status.COMPLETE;
        emit FundsReleased(seller, releaseAmount);
        seller.transfer(releaseAmount);
        _releaseFees();
    }

    function resolveDispute(
        bytes calldata _signature,
        uint8 _buyerPercent
    )
        external
        onlyFunded
        onlyMediator
        onlyIncompleted
        onlyWithParticipantSignature(resolveMsgHash, _signature)
    {
        require(_buyerPercent <= 100, "_buyerPercent must be 100 or lower");
        uint256 releaseAmount = depositAmount().sub(fee);

        status = Status.MEDIATED;
        emit DisputeResolved();

        if (_buyerPercent > 0)
          buyer.transfer(releaseAmount.mul(uint256(_buyerPercent)).div(100));
        if (_buyerPercent < 100)
          seller.transfer(releaseAmount.mul(uint256(100).sub(_buyerPercent)).div(100));

        _releaseFees();
    }

    function setOwner(address payable _newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function setMediator(address payable _newMediator) external onlyOwner {
        emit MediatorChanged(mediator, _newMediator);
        mediator = _newMediator;
    }
}