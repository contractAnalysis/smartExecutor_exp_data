pragma solidity ^0.5.0;


contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.5.0;


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = _msgSender();
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
        return _msgSender() == _owner;
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



pragma solidity ^0.5.0;



contract Blacklistable is Ownable {

    string public constant BLACKLISTED = "BLACKLISTED";

    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

    
    modifier onlyBlacklister() {
        require(msg.sender == owner(), "MUST_BE_BLACKLISTER");
        _;
    }

    
    modifier notBlacklisted(address account) {
        require(blacklisted[account] == false, BLACKLISTED);
        _;
    }

    
    function checkNotBlacklisted(address account) public view {
        require(!blacklisted[account], BLACKLISTED);
    }

    
    function isBlacklisted(address account) public view returns (bool) {
        return blacklisted[account];
    }

    
    function blacklist(address account) public onlyBlacklister {
        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    
    function unBlacklist(address account) public onlyBlacklister {
        blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

}



pragma solidity ^0.5.0;


contract DmmBlacklistable is Blacklistable {

    constructor() public {
    }

}