pragma solidity ^0.5.16;


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



contract BalanceVerifier {
    event NewCommit(uint blockNumber, bytes32 rootHash, string ipfsHash);

    
    mapping (uint => bytes32) public committedHash;

    
    function onVerifySuccess(uint blockNumber, address account, uint balance) internal;

    
    function onCommit(uint blockNumber, bytes32 rootHash, string memory ipfsHash) internal;

    
    function commit(uint blockNumber, bytes32 rootHash, string calldata ipfsHash) external {
        require(committedHash[blockNumber] == 0, "error_overwrite");
        string memory _hash = ipfsHash;
        onCommit(blockNumber, rootHash, _hash); 
        committedHash[blockNumber] = rootHash;
        emit NewCommit(blockNumber, rootHash, _hash);
    }

    
    function prove(uint blockNumber, address account, uint balance, bytes32[] memory proof) public {
        require(proofIsCorrect(blockNumber, account, balance, proof), "error_proof");
        onVerifySuccess(blockNumber, account, balance);
    }

    
    function proofIsCorrect(uint blockNumber, address account, uint balance, bytes32[] memory proof) public view returns(bool) {
        bytes32 leafHash = keccak256(abi.encodePacked(account, balance, blockNumber));
        bytes32 rootHash = committedHash[blockNumber];
        require(rootHash != 0x0, "error_blockNotFound");
        return rootHash == calculateRootHash(leafHash, proof);
    }

    
    function calculateRootHash(bytes32 leafHash, bytes32[] memory others) public pure returns (bytes32 root) {
        root = leafHash;
        for (uint8 i = 0; i < others.length; i++) {
            bytes32 other = others[i];
            if (root < other) {
                
                root = keccak256(abi.encodePacked(root, other));
            } else {
                root = keccak256(abi.encodePacked(other, root));
            }
        }
    }
}



contract Ownable {
    address public owner;
    address public pendingOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    constructor() public {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "error_onlyOwner");
        _;
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner = newOwner;
    }

    
    function claimOwnership() public {
        require(msg.sender == pendingOwner, "error_onlyPendingOwner");
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}





contract Monoplasma is BalanceVerifier, Ownable {
    using SafeMath for uint256;

    event OperatorChanged(address indexed newOperator);
    event AdminFeeChanged(uint adminFee);

    
    uint public blockFreezeSeconds;

    
    mapping (uint => uint) public blockTimestamp;

    
    address public operator;

    
    uint public adminFee;

    IERC20 public token;

    
    uint public totalWithdrawn;

    
    uint public totalProven;

    
    mapping (address => uint) public earnings;

    
    mapping (address => uint) public withdrawn;

    constructor(address tokenAddress, uint blockFreezePeriodSeconds, uint initialAdminFee) public {
        blockFreezeSeconds = blockFreezePeriodSeconds;
        token = IERC20(tokenAddress);
        operator = msg.sender;
        setAdminFee(initialAdminFee);
    }

    
    function setOperator(address newOperator) public onlyOwner {
        operator = newOperator;
        emit OperatorChanged(newOperator);
    }

    
    function setAdminFee(uint newAdminFee) public onlyOwner {
        require(newAdminFee <= 1 ether, "error_adminFee");
        adminFee = newAdminFee;
        emit AdminFeeChanged(adminFee);
    }

    
    function onCommit(uint blockNumber, bytes32, string memory) internal {
        require(msg.sender == operator, "error_notPermitted");
        blockTimestamp[blockNumber] = now; 
    }

    
    function onVerifySuccess(uint blockNumber, address account, uint newEarnings) internal {
        uint blockFreezeStart = blockTimestamp[blockNumber];
        require(now > blockFreezeStart + blockFreezeSeconds, "error_frozen"); 
        require(earnings[account] < newEarnings, "error_oldEarnings");
        totalProven = totalProven.add(newEarnings).sub(earnings[account]);
        require(totalProven.sub(totalWithdrawn) <= token.balanceOf(address(this)), "error_missingBalance");
        earnings[account] = newEarnings;
    }

    
    function withdrawAll(uint blockNumber, uint totalEarnings, bytes32[] calldata proof) external {
        withdrawAllFor(msg.sender, blockNumber, totalEarnings, proof);
    }

    
    function withdrawAllFor(address recipient, uint blockNumber, uint totalEarnings, bytes32[] memory proof) public {
        prove(blockNumber, recipient, totalEarnings, proof);
        uint withdrawable = totalEarnings.sub(withdrawn[recipient]);
        withdrawFor(recipient, withdrawable);
    }

    
    function withdrawAllTo(address recipient, uint blockNumber, uint totalEarnings, bytes32[] calldata proof) external {
        prove(blockNumber, msg.sender, totalEarnings, proof);
        uint withdrawable = totalEarnings.sub(withdrawn[msg.sender]);
        withdrawTo(recipient, withdrawable);
    }

    
    function withdrawAllToSigned(
        address recipient,
        address signer, bytes calldata signature,                       
        uint blockNumber, uint totalEarnings, bytes32[] calldata proof  
    )
        external
    {
        require(signatureIsValid(recipient, signer, 0, signature), "error_badSignature");
        prove(blockNumber, signer, totalEarnings, proof);
        uint withdrawable = totalEarnings.sub(withdrawn[signer]);
        _withdraw(recipient, signer, withdrawable);
    }

    
    function proveAndWithdrawToSigned(
        address recipient,
        address signer, uint amount, bytes calldata signature,          
        uint blockNumber, uint totalEarnings, bytes32[] calldata proof  
    )
        external
    {
        require(signatureIsValid(recipient, signer, amount, signature), "error_badSignature");
        prove(blockNumber, signer, totalEarnings, proof);
        _withdraw(recipient, signer, amount);
    }

    
    function withdraw(uint amount) public {
        _withdraw(msg.sender, msg.sender, amount);
    }

    
    function withdrawFor(address recipient, uint amount) public {
        _withdraw(recipient, recipient, amount);
    }

    
    function withdrawTo(address recipient, uint amount) public {
        _withdraw(recipient, msg.sender, amount);
    }

    
    function withdrawToSigned(address recipient, address signer, uint amount, bytes memory signature) public {
        require(signatureIsValid(recipient, signer, amount, signature), "error_badSignature");
        _withdraw(recipient, signer, amount);
    }

    
    function _withdraw(address recipient, address account, uint amount) internal {
        require(amount > 0, "error_zeroWithdraw");
        uint w = withdrawn[account].add(amount);
        require(w <= earnings[account], "error_overdraft");
        withdrawn[account] = w;
        totalWithdrawn = totalWithdrawn.add(amount);
        require(token.transfer(recipient, amount), "error_transfer");
    }

    
    function signatureIsValid(address recipient, address signer, uint amount, bytes memory signature) public view returns (bool isValid) {
        require(signature.length == 65, "error_badSignatureLength");

        bytes32 r; bytes32 s; uint8 v;
        assembly {      
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "error_badSignatureVersion");

        
        bytes32 messageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n104", recipient, amount, address(this), withdrawn[signer]));
        address calculatedSigner = ecrecover(messageHash, v, r, s);

        return calculatedSigner == signer;
    }
}


contract DataunionVault is Monoplasma {

    string public joinPartStream;

    
    uint public version = 1;

    constructor(address operator, string memory joinPartStreamId, address tokenAddress, uint blockFreezePeriodSeconds, uint adminFeeFraction)
    Monoplasma(tokenAddress, blockFreezePeriodSeconds, adminFeeFraction) public {
        setOperator(operator);
        joinPartStream = joinPartStreamId;
    }
}