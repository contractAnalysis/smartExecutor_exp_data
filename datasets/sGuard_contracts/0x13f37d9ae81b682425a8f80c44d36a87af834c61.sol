pragma solidity ^0.5.0;



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

pragma solidity ^0.5.0;


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



pragma solidity ^0.5.0;



contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}



pragma solidity ^0.5.0;




contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}



pragma solidity ^0.5.0;


library Strings {

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {
        return strConcat(_a, _b, "", "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory _concatenatedString) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}

pragma solidity ^0.5.0;

interface punkInterface {
    
    function punkIndexToAddress(uint256 _punkId) external view returns (address); 
}

pragma solidity ^0.5.0;

contract punkDetails is WhitelistedRole {
    using SafeMath for uint256;

    punkInterface public punkContract;
    
    uint256 constant internal MAX_UINT256 = ~uint256(0);
    
    string contractName = "Punk Details";
    string punksWebsite = "https://www.larvalabs.com/cryptopunks";
    
    uint256 public serialNumbers = 0;
    
    mapping(uint256 => string) public punkIdToPunkName;
    mapping(uint256 => uint256) public punkIdToPunkAge;
    mapping(uint256 => string) public punkIdToPunkJob;
    mapping(uint256 => string) public punkIdToPunkLocation;
    mapping(uint256 => string) public punkIdToPunkBio;
    mapping(uint256 => bytes32) public punkIdToSerialNumber;
    
    
    constructor() public {
        super.addWhitelisted(msg.sender);
        super.addWhitelisted(0xC352B534e8b987e036A93539Fd6897F53488e56a);

        punkContract = punkInterface(0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB);
    }

    function updatePunkName(string memory _name, uint256 _punkId) public returns (bool){
        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), "You must have permission.");
        punkIdToPunkName[_punkId] = _name;
        return true;
    }
    
    function updatePunkAge(uint256 _age, uint256 _punkId) public returns (bool){
        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), "You must have permission.");
        punkIdToPunkAge[_punkId] = _age;
        return true;
    }
    
    function updatePunkJob(string memory _job, uint256 _punkId) public returns (bool){
        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), "You must have permission.");
        punkIdToPunkJob[_punkId] = _job;
        return true;
    }
    
    function updatePunkLocation(string memory _location, uint256 _punkId) public returns (bool){
        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), "You must have permission.");
        punkIdToPunkLocation[_punkId] = _location;
        return true;
    }
    
    function updatePunkBio(string memory _bio, uint256 _punkId) public returns (bool){
        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), "You must have permission.");
        punkIdToPunkBio[_punkId] = _bio;
        return true;
    }
    
    function assignSerialNumber(uint256 _punkId) public returns (bool){
        require(msg.sender == punkContract.punkIndexToAddress(_punkId), "You must have permission.");
        require(punkIdToSerialNumber[_punkId]=="", "Can only assign a serial number once.");
        
        serialNumbers = serialNumbers.add(1); 
        bytes32 serialNumber = keccak256(abi.encodePacked(serialNumbers, block.number, msg.sender));
        punkIdToSerialNumber[_punkId] = serialNumber;
    }
    
    function updatePunksWebsite(string memory _website) public onlyWhitelisted returns (bool){
        punksWebsite = _website;
        return true;
    }
    
    
    
}