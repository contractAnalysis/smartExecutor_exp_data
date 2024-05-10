pragma solidity 0.5.14;


contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IToken { 
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract LexDAOMagickSpell01 is Ownable {
    address public accessToken = 0x39B62c0Cb59DB1C4D62efBF62bb3c1BfB0cFFdBc; 
    address public leethToken; 
    IToken private token = IToken(accessToken);
    IToken private leeth = IToken(leethToken);
    string public offer;

    function castSpell() public { 
        require(token.balanceOf(_msgSender()) >= 1000000000000000000, "token balance insufficient");
        leeth.transfer(_msgSender(), leeth.balanceOf(address(this)));
    }
    
    function redeemOffer() public { 
        token.transferFrom(_msgSender(), 0x97103fda00a2b47EaC669568063C00e65866a633, 1000000000000000000);
    }
    
    function turnPage(address newLeethToken) public onlyOwner { 
        leethToken = newLeethToken;
    }
    
    function writeOffer(string memory _offer) public onlyOwner { 
        offer = _offer;
    }
}