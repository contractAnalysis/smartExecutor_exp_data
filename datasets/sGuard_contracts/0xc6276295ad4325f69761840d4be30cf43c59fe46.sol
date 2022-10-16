pragma solidity ^0.5.0;


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


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}



pragma solidity ^0.5.0;





library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.5.0;






contract MultisigVaultERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Approval {
        uint32 nonce;
        uint8  coincieded;
        bool   skipFee;
        address[] coinciedeParties;
    }

    uint8 private participantsAmount;
    uint8 private signatureMinThreshold;
    uint32 private nonce;
    address public currencyAddress;
    uint16 private serviceFeeMicro;
    address private _owner;

    mapping(address => bool) public parties;

    mapping(
        
        address => mapping(
            
            uint256 => Approval
        )
    ) public approvals;

    mapping(uint256 => bool) public finished;

    event ConfirmationReceived(address indexed from, address indexed destination, address currency, uint256 amount);
    event ConsensusAchived(address indexed destination, address currency, uint256 amount);

    
    constructor(
        uint8 _signatureMinThreshold,
        address[] memory _parties,
        address _currencyAddress
    ) public {
        require(_parties.length > 0 && _parties.length <= 10);
        require(_signatureMinThreshold > 0 && _signatureMinThreshold <= _parties.length);

        _owner = msg.sender;

        signatureMinThreshold = _signatureMinThreshold;
        currencyAddress = _currencyAddress;

        for (uint256 i = 0; i < _parties.length; i++) parties[_parties[i]] = true;

        serviceFeeMicro = 5000; 
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

    
    function getNonce(
        address _destination,
        uint256 _amount
    ) public view returns (uint256) {
        Approval storage approval = approvals[_destination][_amount];

        return approval.nonce;
    }


    
    function partyCoincieded(
        address _destination,
        uint256 _amount,
        uint256 _nonce,
        address _partyAddress
    ) public view returns (bool) {
        if ( finished[_nonce] ) {
          return true;
        } else {
          Approval storage approval = approvals[_destination][_amount];

          for (uint i=0; i<approval.coinciedeParties.length; i++) {
             if (approval.coinciedeParties[i] == _partyAddress) return true;
          }

          return false;
        }
    }

    function approve(
        address _destination,
        uint256 _amount
    ) public returns (bool) {
        approveAndRelease( _destination, _amount, false);
    }


    function regress(
        address _destination,
        uint256 _amount
    ) public onlyOwner() returns (bool) {
        approveAndRelease( _destination, _amount, true);
    }


    function approveAndRelease(
        address _destination,
        uint256 _amount,
        bool    _skipServiceFee
    ) internal returns (bool) {
       require(parties[msg.sender], "Release: not a member");
       require(token().balanceOf(address(this)) >= _amount, "Release:  insufficient balance");

       Approval storage approval = approvals[_destination][_amount]; 

       bool coinciedeParties = false;
       for (uint i=0; i<approval.coinciedeParties.length; i++) {
          if (approval.coinciedeParties[i] == msg.sender) coinciedeParties = true;
       }

       require(!coinciedeParties, "Release: party already approved");

       if (approval.coincieded == 0) {
           nonce += 1;
           approval.nonce = nonce;
       }

       approval.coinciedeParties.push(msg.sender);
       approval.coincieded += 1;

       if (_skipServiceFee) {
           approval.skipFee = true;
       }

       emit ConfirmationReceived(msg.sender, _destination, currencyAddress, _amount);

       if ( approval.coincieded >= signatureMinThreshold ) {
           releaseFunds(_destination, _amount, approval.skipFee);
           finished[approval.nonce] = true;
           delete approvals[_destination][_amount];

           emit ConsensusAchived(_destination, currencyAddress, _amount);
       }

      return false;
    }

    function releaseFunds(
      address _destination,
      uint256 _amount,
      bool    _skipServiceFee
    ) internal {
        if (_skipServiceFee) {
            token().safeTransfer(_destination, _amount); 
        } else {
            uint256 _amountToWithhold = _amount.mul(serviceFeeMicro).div(1000000);
            uint256 _amountToRelease = _amount.sub(_amountToWithhold);

            token().safeTransfer(_destination, _amountToRelease); 
            token().safeTransfer(serviceAddress(), _amountToWithhold);   
        }
    }

    function token() public view returns (IERC20) {
        return IERC20(currencyAddress);
    }

    function serviceAddress() public pure returns (address) {
        return address(0x0A67A2cdC35D7Db352CfBd84fFF5e5F531dF62d1);
    }
}