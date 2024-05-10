pragma solidity 0.6.11;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract IUpgradeAgent {
    function isUpgradeAgent() external virtual pure returns (bool);
    function upgradeFrom(address _from, uint256 _value) public virtual;
    function originalSupply() public virtual view returns (uint256);
    function originalToken() public virtual view returns (address);
}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract MystToken is Context, IERC20, IUpgradeAgent {
    using SafeMath for uint256;
    using Address for address;

    address immutable _originalToken;                        
    uint256 immutable _originalSupply;                       

    
    
    
    uint256 constant private DECIMAL_OFFSET = 1e10;

    bool constant public override isUpgradeAgent = true;     
    address private _upgradeMaster;                          
    IUpgradeAgent private _upgradeAgent;                     
    uint256 private _totalUpgraded;                          

    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    string constant public name = "Mysterium";
    string constant public symbol = "MYST";
    uint8 constant public decimals = 18;

    
    bytes32 public immutable DOMAIN_SEPARATOR;

    
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    
    mapping(address => uint) public nonces;

    
    mapping (address => mapping (address => uint256)) private _allowances;

    event Minted(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount);

    
    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading, Completed}

    
    event Upgrade(address indexed from, address agent, uint256 _value);
    event UpgradeAgentSet(address agent);
    event UpgradeMasterSet(address master);

    constructor(address originalToken) public {
        
        _originalToken  = originalToken;
        _originalSupply = IERC20(originalToken).totalSupply();

        
        _upgradeMaster = _msgSender();

        
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                _chainID(),
                address(this)
            )
        );
    }

    function totalSupply() public view override(IERC20) returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenHolder) public view override(IERC20) returns (uint256) {
        return _balances[tokenHolder];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _move(_msgSender(), recipient, amount);
        return true;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function allowance(address holder, address spender) public view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function permit(address holder, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, 'MYST: Permit expired');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, holder, spender, value, nonces[holder]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == holder, 'MYST: invalid signature');
        _approve(holder, spender, value);
    }

    
    function transferFrom(address holder, address recipient, uint256 amount) public override returns (bool) {
        
        require(holder != address(0), "MYST: transfer from the zero address");
        address spender = _msgSender();

        
        if (holder != spender && _allowances[holder][spender] != uint256(-1)) {
            _approve(holder, spender, _allowances[holder][spender].sub(amount, "MYST: transfer amount exceeds allowance"));
        }

        _move(holder, recipient, amount);
        return true;
    }

    
    function _mint(address holder, uint256 amount) internal {
        require(holder != address(0), "MYST: mint to the zero address");

        
        _totalSupply = _totalSupply.add(amount);
        _balances[holder] = _balances[holder].add(amount);

        emit Minted(holder, amount);
        emit Transfer(address(0), holder, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "MYST: burn from the zero address");

        
        _balances[from] = _balances[from].sub(amount, "MYST: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(from, address(0), amount);
        emit Burned(from, amount);
    }

    function _move(address from, address to, uint256 amount) private {
        
        if (to == address(0)) {
            _burn(from, amount);
            return;
        }

        _balances[from] = _balances[from].sub(amount, "MYST: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);

        emit Transfer(from, to, amount);
    }

    function _approve(address holder, address spender, uint256 value) internal {
        require(holder != address(0), "MYST: approve from the zero address");
        require(spender != address(0), "MYST: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    

    function originalToken() public view override returns (address) {
        return _originalToken;
    }

    function originalSupply() public view override returns (uint256) {
        return _originalSupply;
    }

    function upgradeFrom(address _account, uint256 _value) public override {
        require(msg.sender == originalToken(), "only original token can call upgradeFrom");

        
        _mint(_account, _value.mul(DECIMAL_OFFSET));

        require(totalSupply() <= originalSupply().mul(DECIMAL_OFFSET), "can not mint more tokens than in original contract");
    }


    

    function upgradeMaster() public view returns (address) {
        return _upgradeMaster;
    }

    function upgradeAgent() public view returns (address) {
        return address(_upgradeAgent);
    }

    function totalUpgraded() public view returns (uint256) {
        return _totalUpgraded;
    }

    
    function upgrade(uint256 amount) public {
        UpgradeState state = getUpgradeState();
        require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading, "MYST: token is not in upgrading state");

        require(amount != 0, "MYST: upgradable amount should be more than 0");

        address holder = _msgSender();

        
        _burn(holder, amount);

        
        _totalUpgraded = _totalUpgraded.add(amount);

        
        _upgradeAgent.upgradeFrom(holder, amount);
        emit Upgrade(holder, upgradeAgent(), amount);
    }

    function setUpgradeMaster(address newUpgradeMaster) external {
        require(newUpgradeMaster != address(0x0), "MYST: upgrade master can't be zero address");
        require(_msgSender() == _upgradeMaster, "MYST: only upgrade master can set new one");
        _upgradeMaster = newUpgradeMaster;

        emit UpgradeMasterSet(upgradeMaster());
    }

    function setUpgradeAgent(address agent) external {
        require(_msgSender()== _upgradeMaster, "MYST: only a master can designate the next agent");
        require(agent != address(0x0), "MYST: upgrade agent can't be zero address");
        require(getUpgradeState() != UpgradeState.Upgrading, "MYST: upgrade has already begun");

        _upgradeAgent = IUpgradeAgent(agent);
        require(_upgradeAgent.isUpgradeAgent(), "MYST: agent should implement IUpgradeAgent interface");

        
        require(_upgradeAgent.originalSupply() == totalSupply(), "MYST: upgrade agent should know token's total supply");

        emit UpgradeAgentSet(upgradeAgent());
    }

    function getUpgradeState() public view returns(UpgradeState) {
        if(address(_upgradeAgent) == address(0x00)) return UpgradeState.WaitingForAgent;
        else if(_totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
        else if(totalSupply() == 0) return UpgradeState.Completed;
        else return UpgradeState.Upgrading;
    }

    

    address internal _fundsDestination;
    event FundsRecoveryDestinationChanged(address indexed previousDestination, address indexed newDestination);

    
    function setFundsDestination(address newDestination) public {
        require(_msgSender()== _upgradeMaster, "MYST: only a master can set funds destination");
        require(newDestination != address(0), "MYST: funds destination can't be zero addreess");

        _fundsDestination = newDestination;
        emit FundsRecoveryDestinationChanged(_fundsDestination, newDestination);
    }
    
    function getFundsDestination() public view returns (address) {
        return _fundsDestination;
    }

    
    function claimTokens(address token) public {
        require(_fundsDestination != address(0), "MYST: funds destination can't be zero addreess");
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(_fundsDestination, amount);
    }

    

    function _chainID() private pure returns (uint256) {
        uint256 chainID;
        assembly {
            chainID := chainid()
        }
        return chainID;
    }
}