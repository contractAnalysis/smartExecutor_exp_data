pragma solidity =0.5.12;





















contract PauseLike {
    function plot(address, bytes32, bytes memory, uint) public;
    function exec(address, bytes32, bytes memory, uint) public;
}

contract DssDeployPauseProxyActions {
    function file(address pause, address actions, address who, bytes32 what, uint data) external {
        bytes32 tag;
        assembly { tag := extcodehash(actions) }
        PauseLike(pause).plot(
            address(actions),
            tag,
            abi.encodeWithSignature("file(address,bytes32,uint256)", who, what, data),
            now
        );
        PauseLike(pause).exec(
            address(actions),
            tag,
            abi.encodeWithSignature("file(address,bytes32,uint256)", who, what, data),
            now
        );
    }

    function file(address pause, address actions, address who, bytes32 ilk, bytes32 what, uint data) external {
        bytes32 tag;
        assembly { tag := extcodehash(actions) }
        PauseLike(pause).plot(
            address(actions),
            tag,
            abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", who, ilk, what, data),
            now
        );
        PauseLike(pause).exec(
            address(actions),
            tag,
            abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", who, ilk, what, data),
            now
        );
    }

    function file(address pause, address actions, address who, bytes32 ilk, bytes32 what, address data) external {
        bytes32 tag;
        assembly { tag := extcodehash(actions) }
        PauseLike(pause).plot(
            address(actions),
            tag,
            abi.encodeWithSignature("file(address,bytes32,bytes32,address)", who, ilk, what, data),
            now
        );
        PauseLike(pause).exec(
            address(actions),
            tag,
            abi.encodeWithSignature("file(address,bytes32,bytes32,address)", who, ilk, what, data),
            now
        );
    }

    function dripAndFile(address pause, address actions, address who, bytes32 what, uint data) external {
        bytes32 tag;
        assembly { tag := extcodehash(actions) }
        PauseLike(pause).plot(
            address(actions),
            tag,
            abi.encodeWithSignature("dripAndFile(address,bytes32,uint256)", who, what, data),
            now
        );
        PauseLike(pause).exec(
            address(actions),
            tag,
            abi.encodeWithSignature("dripAndFile(address,bytes32,uint256)", who, what, data),
            now
        );
    }

    function dripAndFile(address pause, address actions, address who, bytes32 ilk, bytes32 what, uint data) external {
        bytes32 tag;
        assembly { tag := extcodehash(actions) }
        PauseLike(pause).plot(
            address(actions),
            tag,
            abi.encodeWithSignature("dripAndFile(address,bytes32,bytes32,uint256)", who, ilk, what, data),
            now
        );
        PauseLike(pause).exec(
            address(actions),
            tag,
            abi.encodeWithSignature("dripAndFile(address,bytes32,bytes32,uint256)", who, ilk, what, data),
            now
        );
    }

    function setAuthorityAndDelay(address pause, address actions, address newAuthority, uint newDelay) external {
        bytes32 tag;
        assembly { tag := extcodehash(actions) }
        PauseLike(pause).plot(
            address(actions),
            tag,
            abi.encodeWithSignature("setAuthorityAndDelay(address,address,uint256)", pause, newAuthority, newDelay),
            now
        );
        PauseLike(pause).exec(
            address(actions),
            tag,
            abi.encodeWithSignature("setAuthorityAndDelay(address,address,uint256)", pause, newAuthority, newDelay),
            now
        );
    }
}