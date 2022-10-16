pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;

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


contract Initializable {

  
  bool private initialized;

  
  bool private initializing;

  
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
    
    
    
    
    
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  
  uint256[50] private ______gap;
}


contract ContextUpgradeable is Initializable {
    
    
    function initialize() virtual public initializer { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract OwnableUpgradeable is ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function initialize() override virtual public initializer {
        ContextUpgradeable.initialize();

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

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library Account {
    struct Info {
        address owner; 
        uint256 number; 
    }
}

library Actions {
    enum ActionType {
        Deposit, 
        Withdraw, 
        Transfer, 
        Buy, 
        Sell, 
        Trade, 
        Liquidate, 
        Vaporize, 
        Call 
    }
    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }
}

library Types {
    enum AssetDenomination {
        Wei, 
        Par 
    }

    enum AssetReference {
        Delta, 
        Target 
    }

    struct AssetAmount {
        bool sign; 
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }
 
    struct Par {
        bool sign; 
        uint128 value;
    }

    struct Wei {
        bool sign; 
        uint256 value;
    }
}

interface ISoloMargin {
    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    ) external;

    function getAccountBalances(Account.Info memory account)
        external view
        returns (
            address[] memory,
            Types.Par[] memory,
            Types.Wei[] memory
        );
}

contract dYdXWrapper is OwnableUpgradeable {
    IERC20 public constant DAI = IERC20(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    ISoloMargin public constant soloMargin = ISoloMargin(
        0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e
    );

    function initialize() public override initializer {
        OwnableUpgradeable.initialize();
        DAI.approve(address(soloMargin), 100000e18);
    }

    function deposit(uint256 value) external onlyOwner {
        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = Account.Info(address(this), 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](1);
        actions[0] = Actions.ActionArgs(
            Actions.ActionType.Deposit,
            0,
            Types.AssetAmount(
                true,
                Types.AssetDenomination.Wei,
                Types.AssetReference.Delta,
                value
            ),
            3,
            0,
            address(this),
            0,
            bytes("")
        );
        soloMargin.operate(accounts, actions);
    }

    function withdraw(uint256 value) external onlyOwner {
        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = Account.Info(address(this), 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](1);

        actions[0] = Actions.ActionArgs({
            actionType: Actions.ActionType.Withdraw,
            accountId: 0,
            amount: Types.AssetAmount({
                sign: false,
                denomination: Types.AssetDenomination.Wei,
                ref: Types.AssetReference.Delta,
                value: value
            }),
            primaryMarketId: 3,
            secondaryMarketId: 0,
            otherAddress: address(this),
            otherAccountId: 0,
            data: ""
        });
        soloMargin.operate(accounts, actions);
    }

    function me() public view returns (address) {
        return address(this);
    }

    function balance()
        external
        view
        returns (
            address[] memory,
            Types.Par[] memory,
            Types.Wei[] memory
        )
    {
        Account.Info memory account = Account.Info(address(this), 0);
        return soloMargin.getAccountBalances(account);
    }
}