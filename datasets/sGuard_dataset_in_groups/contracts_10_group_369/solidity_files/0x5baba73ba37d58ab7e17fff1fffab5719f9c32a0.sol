pragma solidity 0.5.8;


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




pragma solidity 0.5.8;


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



pragma solidity 0.5.8;


contract Registry is Ownable {
    
    
    

    struct Member {
        uint256 challengeID;
        uint256 memberStartTime; 
    }

    
    mapping(address => Member) public members;

    
    
    

    
    function getChallengeID(address _member) external view returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = members[_member];
        return member.challengeID;
    }

    
    function getMemberStartTime(address _member) external view returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = members[_member];
        return member.memberStartTime;
    }

    
    
    

    
    function setMember(address _member) external onlyOwner returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = Member({
            challengeID: 0,
            
            memberStartTime: now
        });
        members[_member] = member;

        
        return now;
    }

    
    function editChallengeID(address _member, uint256 _newChallengeID) external onlyOwner {
        require(_member != address(0), "Can't check 0 address");
        Member storage member = members[_member];
        member.challengeID = _newChallengeID;
    }

    
    function deleteMember(address _member) external onlyOwner {
        require(_member != address(0), "Can't check 0 address");
        delete members[_member];
    }
}