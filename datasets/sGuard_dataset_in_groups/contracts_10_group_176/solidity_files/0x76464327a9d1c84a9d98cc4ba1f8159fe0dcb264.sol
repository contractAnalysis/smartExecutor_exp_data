pragma solidity 0.5.11;


interface IPartnerRegistry {

    function getPartnerContract(string calldata referralId) external view returns(address);

    function addPartner(
        string calldata referralId,
        address feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner
    )
        external;

    function removePartner(string calldata referralId) external;
}



pragma solidity ^0.5.0;


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



pragma solidity 0.5.11;


interface IPartnerDeployer {

    function deploy(
        string calldata referralId,
        address payable feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner
    )
        external
        returns(address);
}



pragma solidity 0.5.11;






contract PartnerRegistry is Ownable {

    using SafeMath for uint256;

    mapping(bytes32 => address) private _referralVsPartner;

    IPartnerDeployer private _partnerDeployer;

    event PartnerAdded(string referralId, address indexed partnerContract);
    event PartnerRemoved(string referralId);
    event PartnerDeployerChanged(address indexed partnerDeployer);

    constructor(address partnerDeployer) public {
        _partnerDeployer = IPartnerDeployer(partnerDeployer);
    }

    function getPartnerDeployer() external view returns(address) {
        return address(_partnerDeployer);
    }

    function changePartnerDeployer(address partnerDeployer) external onlyOwner {
        require(partnerDeployer != address(0), "Invalid address");
        _partnerDeployer = IPartnerDeployer(partnerDeployer);
        emit PartnerDeployerChanged(partnerDeployer);
    }

    function getPartnerContract(string calldata referralId) external view returns(address) {

        return _referralVsPartner[keccak256(abi.encodePacked(referralId))];
    }

    function addPartner(
        string calldata referralId,
        address payable feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner
    )
        external
        onlyOwner
    {
        require(feeWallet != address(0), "Invalid fee wallet");
        require(owner != address(0), "Invalid owner for partner");
        require(fee <= 10000, "Invalid fee passed");
        require(paraswapShare.add(partnerShare) == 10000, "Invalid shares");
        require(bytes(referralId).length > 0, "Empty refferalid");

        address partner = _partnerDeployer.deploy(
            referralId,
            feeWallet,
            fee,
            paraswapShare,
            partnerShare,
            owner
        );

        _referralVsPartner[keccak256(abi.encodePacked(referralId))] = address(partner);

        emit PartnerAdded(referralId, partner);
    }

    function removePartner(string calldata referralId) external onlyOwner {
        _referralVsPartner[keccak256(abi.encodePacked(referralId))] = address(0);

        emit PartnerRemoved(referralId);
    }
}