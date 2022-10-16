pragma solidity 0.4.25;



interface IContractAddressLocator {
        function getContractAddress(bytes32 _identifier) external view returns (address);

        function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);
}




contract ContractAddressLocator is IContractAddressLocator {
    string public constant VERSION = "1.0.0";

    uint256 identifiersCount;

    mapping(bytes32 => address) private contractAddresses;

    event Mapped(bytes32 indexed _identifier, address indexed _contractAddress);

        constructor(bytes32[] memory _identifiers, address[] _contractAddresses) public {
        identifiersCount = _identifiers.length;
        require(identifiersCount == _contractAddresses.length, "list lengths are not equal");
        for (uint256 i = 0; i < identifiersCount; i++) {
            require(uint256(contractAddresses[_identifiers[i]]) == 0, "identifiers are not unique");
            contractAddresses[_identifiers[i]] = _contractAddresses[i];
            emit Mapped(_identifiers[i], _contractAddresses[i]);
        }
    }

        function getContractAddress(bytes32 _identifier) external view returns (address) {
        return contractAddresses[_identifier];
    }

        function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool){
        assert(_contractAddress != address(0));
        uint256 _identifiersCount = _identifiers.length;
        require(_identifiersCount <= identifiersCount, "cannot be more than actual identifiers count");
        bool isRelate = false;
        for (uint256 i = 0; i < _identifiersCount; i++) {
            if (_contractAddress == contractAddresses[_identifiers[i]]) {
                isRelate = true;
                break;
            }
        }
        return isRelate;
    }

}