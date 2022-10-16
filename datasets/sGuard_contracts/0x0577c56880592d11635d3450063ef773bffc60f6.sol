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


interface IPartner {

    function getReferralId() external view returns(string memory);

    function getFeeWallet() external view returns(address payable);

    function getFee() external view returns(uint256);

    function getPartnerShare() external returns(uint256);

    function getParaswapShare() external returns(uint256);

    function changeFeeWallet(address payable feeWallet) external;

    function changeFee(uint256 newFee) external;
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



pragma solidity 0.5.11;




contract Partner is Ownable {

    string private _referralId;

    address payable private _feeWallet;

    
    uint256 private _fee;

    
    
    uint256 private _paraswapShare;

    
    uint256 private _partnerShare;

    event FeeWalletChanged(address indexed feeWallet);
    event FeeChanged(uint256 fee);

    constructor(
        string memory referralId,
        address payable feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner
    )
        public
    {
        _referralId = referralId;
        _feeWallet = feeWallet;
        _fee = fee;
        _paraswapShare = paraswapShare;
        _partnerShare = partnerShare;
        transferOwnership(owner);
    }

    function getReferralId() external view returns(string memory) {
        return _referralId;
    }

    function getFeeWallet() external view returns(address payable) {
        return _feeWallet;
    }

    function getFee() external view returns(uint256) {
        return _fee;
    }

    function getPartnerShare() external returns(uint256) {
        return _partnerShare;
    }

    function getParaswapShare() external returns(uint256) {
        return _paraswapShare;
    }

    function changeFeeWallet(address payable feeWallet) external onlyOwner {
        require(feeWallet != address(0), "Invalide fee wallet passed!!");
        _feeWallet = feeWallet;

        emit FeeWalletChanged(feeWallet);
    }

    function changeFee(uint256 newFee) external onlyOwner {
        require(newFee <= 10000, "Invalid fee passed!!");

        _fee = newFee;

        emit FeeChanged(newFee);
    }

}



pragma solidity 0.5.11;



contract PartnerDeployer is IPartnerDeployer {

    function deploy(
        string calldata referralId,
        address payable feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner
    )
        external
        returns(address)
    {
        Partner partner = new Partner(
            referralId,
            feeWallet,
            fee,
            paraswapShare,
            partnerShare,
            owner
        );
        return address(partner);
    }
}