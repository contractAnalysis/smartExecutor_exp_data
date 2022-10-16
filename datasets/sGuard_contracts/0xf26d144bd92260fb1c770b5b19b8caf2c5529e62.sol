pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


library ECDSA {
    
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        
        if (signature.length != 65) {
            return (address(0));
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
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        
        return ecrecover(hash, v, r, s);
    }

    
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        
        
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}



contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract CampaignBank is Ownable {
    using ECDSA for bytes32;

    mapping(address => bool) public trustedSigner;
    mapping(bytes32 => bool) public alreadySent;

    event RegisteredSigner(
        address indexed sender,
        address indexed signer,
        uint256 indexed date
    );
    event RemovedSigner(
        address indexed sender,
        address indexed signer,
        uint256 indexed date
    );
    event Rewarded(
        address indexed targetContract,
        bytes32 indexed hashedSig,
        bytes payload,
        uint256 signedTimestamp,
        bytes signature,
        address sender
    );

    constructor() public Ownable() {}

    function registerTrustedSigner(address target, bool allowed)
        public
        onlyOwner
    {
        if (allowed && !trustedSigner[target]) {
            trustedSigner[target] = true;
            emit RegisteredSigner(msg.sender, target, block.timestamp);
        } else if (!allowed && trustedSigner[target]) {
            trustedSigner[target] = false;
            emit RemovedSigner(msg.sender, target, block.timestamp);
        }
    }

    event TransactionRelayed(
        address indexed sender,
        address indexed targetContract,
        bytes payload,
        uint256 value,
        bytes signature
    );

    function claimManyRewards(
        address[] memory targetContract,
        bytes[] memory payload,
        uint256[] memory expirationTimestamp,
        bytes[] memory signature
    ) public {
        require(
            targetContract.length == payload.length,
            "Arrays should be of the same size"
        );
        require(
            targetContract.length == expirationTimestamp.length,
            "Arrays should be of the same size"
        );
        require(
            targetContract.length == signature.length,
            "Arrays should be of the same size"
        );
        uint256 length = targetContract.length;

        for (uint256 i = 0; i < length; i++) {
            if (
                !claimReward(
                    targetContract[i],
                    payload[i],
                    expirationTimestamp[i],
                    signature[i]
                )
            ) {
                revert("Transaction failed");
            }
        }
    }

    function claimReward(
        address targetContract,
        bytes memory payload,
        uint256 expirationTimestamp,
        bytes memory signature
    ) public returns (bool) {
        require(block.timestamp < expirationTimestamp, "Signature too old");

        bytes memory blob = abi.encode(
            targetContract,
            payload,
            expirationTimestamp
        );
        bytes32 signed = keccak256(blob);
        bytes32 verify = signed.toEthSignedMessageHash();
        require(!alreadySent[signed], "Already sent!");

        require(
            trustedSigner[verify.recover(signature)],
            "Invalid signature provided"
        );

        alreadySent[signed] = true;

        bool result;
        (result,) = targetContract.call(payload);
        if (!result) {
            revert("Failed call");
        }

        emit Rewarded(
            targetContract,
            signed,
            payload,
            expirationTimestamp,
            signature,
            msg.sender
        );

        return true;
    }

    function halt() public onlyOwner {
        selfdestruct(address(uint256(owner())));
    }
}