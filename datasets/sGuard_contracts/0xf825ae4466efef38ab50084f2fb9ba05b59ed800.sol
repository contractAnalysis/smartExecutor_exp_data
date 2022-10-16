pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;


interface ERC20 {
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
}



library SafeERC20 {

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 value,
        string memory location
    )
        internal
    {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.transfer.selector,
                to,
                value
            ),
            "transfer",
            location
        );
    }

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 value,
        string memory location
    )
        internal
    {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.transferFrom.selector,
                from,
                to,
                value
            ),
            "transferFrom",
            location
        );
    }

    function safeApprove(
        ERC20 token,
        address spender,
        uint256 value,
        string memory location
    )
        internal
    {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: wrong approve call"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                value
            ),
            "approve",
            location
        );
    }

    
    function callOptionalReturn(
        ERC20 token,
        bytes memory data,
        string memory functionName,
        string memory location
    )
        private
    {
        
        

        
        
        

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(
            success,
            string(
                abi.encodePacked(
                    "SafeERC20: ",
                    functionName,
                    " failed in ",
                    location
                )
            )
        );

        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: false returned");
        }
    }
}


struct Action {
    ActionType actionType;
    bytes32 protocolName;
    uint256 adapterIndex;
    address[] tokens;
    uint256[] amounts;
    AmountType[] amountTypes;
    bytes data;
}

enum ActionType { None, Deposit, Withdraw }


enum AmountType { None, Relative, Absolute }



abstract contract ProtocolAdapter {

    
    function adapterType() external pure virtual returns (bytes32);

    
    function tokenType() external pure virtual returns (bytes32);

    
    function getBalance(address token, address account) public view virtual returns (uint256);
}



contract TokenSetsAdapter is ProtocolAdapter {

    bytes32 public constant override adapterType = "Asset";

    bytes32 public constant override tokenType = "SetToken";

    
    function getBalance(address token, address account) public view override returns (uint256) {
        return ERC20(token).balanceOf(account);
    }
}



abstract contract InteractiveAdapter is ProtocolAdapter {

    uint256 internal constant RELATIVE_AMOUNT_BASE = 1e18;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    
    function deposit(
        address[] memory tokens,
        uint256[] memory amounts,
        AmountType[] memory amountTypes,
        bytes memory data
    )
        public
        payable
        virtual
        returns (address[] memory);

    
    function withdraw(
        address[] memory tokens,
        uint256[] memory amounts,
        AmountType[] memory amountTypes,
        bytes memory data
    )
        public
        payable
        virtual
        returns (address[] memory);

    function getAbsoluteAmountDeposit(
        address token,
        uint256 amount,
        AmountType amountType
    )
        internal
        view
        virtual
        returns (uint256)
    {
        if (amountType == AmountType.Relative) {
            require(amount <= RELATIVE_AMOUNT_BASE, "L: wrong relative value!");

            uint256 totalAmount;
            if (token == ETH) {
                totalAmount = address(this).balance;
            } else {
                totalAmount = ERC20(token).balanceOf(address(this));
            }

            if (amount == RELATIVE_AMOUNT_BASE) {
                return totalAmount;
            } else {
                return totalAmount * amount / RELATIVE_AMOUNT_BASE; 
            }
        } else {
            return amount;
        }
    }

    function getAbsoluteAmountWithdraw(
        address token,
        uint256 amount,
        AmountType amountType
    )
        internal
        view
        virtual
        returns (uint256)
    {
        if (amountType == AmountType.Relative) {
            require(amount <= RELATIVE_AMOUNT_BASE, "L: wrong relative value!");

            if (amount == RELATIVE_AMOUNT_BASE) {
                return getBalance(token, address(this));
            } else {
                return getBalance(token, address(this)) * amount / RELATIVE_AMOUNT_BASE; 
            }
        } else {
            return amount;
        }
    }
}



interface RebalancingSetIssuanceModule {
    function issueRebalancingSet(address, uint256, bool) external;
    function issueRebalancingSetWrappingEther(address, uint256, bool) external payable;
    function redeemRebalancingSet(address, uint256, bool) external;
    function redeemRebalancingSetUnwrappingEther(address, uint256, bool) external;
}



interface SetToken {
    function getComponents() external view returns(address[] memory);
}



interface RebalancingSetToken {
    function currentSet() external view returns (SetToken);
}



contract TokenSetsInteractiveAdapter is InteractiveAdapter, TokenSetsAdapter {

    using SafeERC20 for ERC20;

    address internal constant TRANSFER_PROXY = 0x882d80D3a191859d64477eb78Cca46599307ec1C;
    address internal constant ISSUANCE_MODULE = 0xDA6786379FF88729264d31d472FA917f5E561443;

    
    function deposit(
        address[] memory tokens,
        uint256[] memory amounts,
        AmountType[] memory amountTypes,
        bytes memory data
    )
        public
        payable
        override
        returns (address[] memory)
    {
        uint256 absoluteAmount;
        for (uint256 i = 0; i < tokens.length; i++) {
            absoluteAmount = getAbsoluteAmountDeposit(tokens[i], amounts[i], amountTypes[i]);
            ERC20(tokens[i]).safeApprove(TRANSFER_PROXY, absoluteAmount, "TSIA![1]");
        }

        (address setAddress, uint256 setQuantity) = abi.decode(data, (address, uint256));

        address[] memory tokensToBeWithdrawn = new address[](1);
        tokensToBeWithdrawn[0] = setAddress;

        try RebalancingSetIssuanceModule(ISSUANCE_MODULE).issueRebalancingSet(
            setAddress,
            setQuantity,
            false
        ) {} catch Error(string memory reason) {
            revert(reason);
        } catch (bytes memory) {
            revert("TSIA: tokenSet fail!");
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            ERC20(tokens[i]).safeApprove(TRANSFER_PROXY, 0, "TSIA![2]");
        }

        return tokensToBeWithdrawn;
    }

    
    function withdraw(
        address[] memory tokens,
        uint256[] memory amounts,
        AmountType[] memory amountTypes,
        bytes memory
    )
        public
        payable
        override
        returns (address[] memory)
    {
        require(tokens.length == 1, "TSIA: should be 1 token/amount/type!");

        uint256 amount = getAbsoluteAmountWithdraw(tokens[0], amounts[0], amountTypes[0]);
        RebalancingSetIssuanceModule issuanceModule = RebalancingSetIssuanceModule(ISSUANCE_MODULE);
        RebalancingSetToken rebalancingSetToken = RebalancingSetToken(tokens[0]);
        SetToken setToken = rebalancingSetToken.currentSet();
        address[] memory tokensToBeWithdrawn = setToken.getComponents();

        try issuanceModule.redeemRebalancingSet(
            tokens[0],
            amount,
            false
        ) {} catch Error(string memory reason) {
            revert(reason);
        } catch (bytes memory) {
            revert("TSIA: tokenSet fail!");
        }

        return tokensToBeWithdrawn;
    }
}