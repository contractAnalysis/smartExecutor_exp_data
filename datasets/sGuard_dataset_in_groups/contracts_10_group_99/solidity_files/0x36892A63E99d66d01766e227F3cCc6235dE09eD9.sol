pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;


library Create2 {
    
    function deploy(bytes32 salt, bytes memory bytecode) internal returns (address) {
        address addr;
        
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    
    function computeAddress(bytes32 salt, bytes memory bytecode) internal view returns (address) {
        return computeAddress(salt, bytecode, address(this));
    }

    
    function computeAddress(bytes32 salt, bytes memory bytecode, address deployer) internal pure returns (address) {
        return computeAddress(salt, keccak256(bytecode), deployer);
    }

    
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(bytes20(_data << 96));
    }
}


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


interface IReplayProtectionAuthority {
    
    function update(bytes calldata nonce) external returns (bool);

    
    function updateFor(address target, bytes calldata nonce) external returns (bool);

}


contract ReplayProtection {
    mapping(bytes32 => uint256) public nonceStore;

    
    function getChainID() public pure returns(uint) {
        
        uint256 chainId;
        assembly {chainId := chainid() }
    }

    
    function verify(bytes memory _callData,
        bytes memory _replayProtection,
        address _replayProtectionAuthority,
        bytes memory _signature) internal returns(address){

        
        address signer = verifySig(_callData, _replayProtection, _replayProtectionAuthority, getChainID(), _signature);

        
        if(_replayProtectionAuthority == address(0x0000000000000000000000000000000000000000)) {
            
            require(nonce(signer, _replayProtection), "Multinonce replay protection failed");
        } else if (_replayProtectionAuthority == address(0x0000000000000000000000000000000000000001)) {
            require(bitflip(signer, _replayProtection), "Bitflip replay protection failed");
        } else {
            require(IReplayProtectionAuthority(_replayProtectionAuthority).updateFor(signer, _replayProtection), "Replay protection from authority failed");
        }

        return signer;
    }

    
    function verifySig(bytes memory _callData,
        bytes memory _replayProtection,
        address _replayProtectionAuthority, uint chainId, bytes memory _signature) public view returns (address) {
        bytes memory encodedData = abi.encode(_callData, _replayProtection, _replayProtectionAuthority, address(this), chainId);
        return ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(encodedData)), _signature);
    }

    
    function nonce(address _signer, bytes memory _replayProtection) internal returns(bool) {
        uint256 nonce1;
        uint256 nonce2;

        (nonce1, nonce2) = abi.decode(_replayProtection, (uint256, uint256));
        bytes32 index = keccak256(abi.encode(_signer, nonce1));
        uint256 storedNonce = nonceStore[index];

        
        if(nonce2 == storedNonce) {
            nonceStore[index] = storedNonce + 1;
            return true;
        }

        return false;
    }

    
    function bitflip(address _signer, bytes memory _replayProtection) internal returns(bool) {
        (uint256 nonce1, uint256 bitsToFlip) = abi.decode(_replayProtection, (uint256, uint256));

        
        
        require(nonce1 >= 6174, "Nonce1 must be at least 6174 to separate multinonce and bitflip");

        
        bytes32 senderIndex = keccak256(abi.encodePacked(_signer, nonce1));
        uint256 currentBitmap = nonceStore[senderIndex];
        require(currentBitmap & bitsToFlip != bitsToFlip, "Bit already flipped.");
        nonceStore[senderIndex] = currentBitmap | bitsToFlip;
    }
}



contract RelayHub is ReplayProtection {

     event Deployed(address signer, address addr);

     
    function forward(
        address _target,
        bytes memory _callData,
        bytes memory _replayProtection,
        address _replayProtectionAuthority,
        address _signer,
        bytes memory _signature) public {

        bytes memory encodedCallData = abi.encode(_target, _callData);

        
        require(_signer == verify(encodedCallData, _replayProtection, _replayProtectionAuthority, _signature),
        "Signer did not sign this meta-transaction.");

        
        (bool success,) = _target.call(abi.encodePacked(_callData, _signer));
        require(success, "Forwarding call failed.");
    }


    
    function deployContract(
        bytes memory _initCode,
        bytes memory _replayProtection,
        address _replayProtectionAuthority,
        address _signer,
        bytes memory _signature) public {

        
        require(_signer == verify(_initCode, _replayProtection, _replayProtectionAuthority, _signature),
        "Signer must authorise deploying contract");

        
        address deployed = Create2.deploy(keccak256(abi.encode(_signer, _replayProtection)), _initCode);

        emit Deployed(_signer, deployed);
    }

}