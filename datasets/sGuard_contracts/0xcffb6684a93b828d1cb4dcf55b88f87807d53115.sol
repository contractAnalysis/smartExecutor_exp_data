pragma solidity ^0.4.24;


library SafeMath {

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}



contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    
    constructor() public {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


contract BasicERC20 {
    
    string public standard = 'ERC20';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    bool public isTokenTransferable = true;

    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(isTokenTransferable);
        require(balanceOf[msg.sender] >= _value);             
        if (balanceOf[_to] + _value < balanceOf[_to])
            revert('Overflow detected'); 
        balanceOf[msg.sender] -= _value;                     
        balanceOf[_to] += _value;                            
        emit Transfer(msg.sender, _to, _value);                   
        return true;
    }

    
    function approve(address _spender, uint256 _value) public
    returns (bool success)  {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(isTokenTransferable || _from == address(0x0)); 
        if (balanceOf[_from] < _value)
            revert('Insufficient sunds');                     
        if (balanceOf[_to] + _value < balanceOf[_to])
            revert('Overflow detected');                      
        if (_value > allowance[_from][msg.sender])
            revert('Operation is not allow');                 
        balanceOf[_from] -= _value;                           
        balanceOf[_to] += _value;                             
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}


contract EditableToken is BasicERC20, Ownable {
    using SafeMath for uint256;

    
    function editTokenProperties(string _name, string _symbol, int256 extraSupplay) onlyOwner public {
        name = _name;
        symbol = _symbol;
        if (extraSupplay > 0)
        {
            balanceOf[owner] = balanceOf[owner].add(uint256(extraSupplay));
            totalSupply = totalSupply.add(uint256(extraSupplay));
            emit Transfer(address(0x0), owner, uint256(extraSupplay));
        }
        else if (extraSupplay < 0)
        {
            balanceOf[owner] = balanceOf[owner].sub(uint256(extraSupplay * -1));
            totalSupply = totalSupply.sub(uint256(extraSupplay * -1));
            emit Transfer(owner, address(0x0), uint256(extraSupplay * -1));
        }
    }
}


contract ThirdPartyTransferableToken is BasicERC20 {
    using SafeMath for uint256;

    struct confidenceInfo {
        uint256 nonce;
        mapping (uint256 => bool) operation;
    }
    mapping (address => confidenceInfo) _confidence_transfers;

    function nonceOf(address src) view public returns (uint256) {
        return _confidence_transfers[src].nonce;
    }

    function transferByThirdParty(uint256 nonce, address where, uint256 amount, uint8 v, bytes32 r, bytes32 s) public returns (bool){
        require(where != address(this));
        require(where != address(0x0));

        bytes32 hash = sha256(abi.encodePacked(this, nonce, where, amount));
        address src = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),v,r,s);
        require(balanceOf[src] >= amount);
        require(nonce == _confidence_transfers[src].nonce+1);

        require(_confidence_transfers[src].operation[uint256(hash)]==false);

        balanceOf[src] = balanceOf[src].sub(amount);
        balanceOf[where] = balanceOf[where].add(amount);
        _confidence_transfers[src].nonce += 1;
        _confidence_transfers[src].operation[uint256(hash)] = true;

        emit Transfer(src, where, amount);

        return true;
    }
}


contract ERC20Token is EditableToken, ThirdPartyTransferableToken {
    using SafeMath for uint256;

    
    constructor() public
    {
        balanceOf[0xBF165e10878628768939f0415d7df2A9d52f0aB0] = uint256(100000000) * 10**18;
        emit Transfer(address(0x0), 0xBF165e10878628768939f0415d7df2A9d52f0aB0, balanceOf[0xBF165e10878628768939f0415d7df2A9d52f0aB0]);

        transferOwnership(0xBF165e10878628768939f0415d7df2A9d52f0aB0);

        totalSupply = 100000000 * 10**18;                        
        name = 'CLICK';                                          
        symbol = 'CLK';                                          
        decimals = 18;                                           
    }

    
    function () public {
        require(false);     
    }
}