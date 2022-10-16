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



contract OneSplitAdapter is ProtocolAdapter {

    bytes32 public constant override adapterType = "Exchange";

    bytes32 public constant override tokenType = "";

    /**
     * @return Amount of Uniswap pool tokens held by the given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address, address) public view override returns (uint256) {
        revert("OSA: no balance!");
    }
}


/**
 * @title Base contract for interactive protocol adapters.
 * @dev deposit() and withdraw() functions MUST be implemented
 * as well as all the functions from ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract InteractiveAdapter is ProtocolAdapter {

    uint256 internal constant RELATIVE_AMOUNT_BASE = 1e18;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @dev The function must deposit assets to the protocol.
     * @return MUST return assets to be sent back to the `msg.sender`.
     */
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

    /**
     * @dev The function must withdraw assets from the protocol.
     * @return MUST return assets to be sent back to the `msg.sender`.
     */
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
                return totalAmount * amount / RELATIVE_AMOUNT_BASE; // TODO overflow check
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
                return getBalance(token, address(this)) * amount / RELATIVE_AMOUNT_BASE; // TODO overflow check
            }
        } else {
            return amount;
        }
    }
}


/**
 * @dev OneSplit contract interface.
 * Only the functions required for OneSplitInteractiveAdapter contract are added.
 * The OneSplit contract is available here
 * github.com/CryptoManiacsZone/1split/blob/master/contracts/OneSplit.sol.
 */
interface OneSplit {
    function swap(
        address,
        address,
        uint256,
        uint256,
        uint256[] calldata,
        uint256
    )
        external
        payable;
    function getExpectedReturn(
        address,
        address,
        uint256,
        uint256,
        uint256
    )
        external
        view
        returns (uint256, uint256[] memory);
}


/**
 * @title Interactive adapter for OneSplit exchange.
 * @dev Implementation of InteractiveAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract OneSplitInteractiveAdapter is InteractiveAdapter, OneSplitAdapter {

    using SafeERC20 for ERC20;

    address internal constant ONE_SPLIT = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;

    /**
     * @notice Exchanges tokens using OneSplit contract.
     * @param tokens Array with one element - `fromToken` address.
     * @param amounts Array with one element - token amount to be exchanged.
     * @param amountTypes Array with one element - amount type.
     * @param data Bytes array with ABI-encoded `toToken` address.
     * @return Asset sent back to the msg.sender.
     * @dev Implementation of InteractiveAdapter function.
     */
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
        require(tokens.length == 1, "OSIA: should be 1 token/amount/type!");

        uint256 amount = getAbsoluteAmountDeposit(tokens[0], amounts[0], amountTypes[0]);

        address fromToken = tokens[0];
        if (fromToken == ETH) {
            fromToken = address(0);
        } else {
            ERC20(fromToken).safeApprove(ONE_SPLIT, amount, "OSIA!");
        }

        address[] memory tokensToBeWithdrawn;

        address toToken = abi.decode(data, (address));
        if (toToken == ETH) {
            tokensToBeWithdrawn = new address[](0);
            toToken = address(0);
        } else {
            tokensToBeWithdrawn = new address[](1);
            tokensToBeWithdrawn[0] = toToken;
        }

        swap(fromToken, toToken, amount);

        return tokensToBeWithdrawn;
    }

    /**
     * @notice This function is unavailable in Exchange type adapters.
     * @dev Implementation of InteractiveAdapter function.
     */
    function withdraw(
        address[] memory,
        uint256[] memory,
        AmountType[] memory,
        bytes memory
    )
        public
        payable
        override
        returns (address[] memory)
    {
        revert("OSIA: no withdraw!");
    }

    function swap(address fromToken, address toToken, uint256 amount) internal {
        uint256[] memory distribution;

        try OneSplit(ONE_SPLIT).getExpectedReturn(
            fromToken,
            toToken,
            amount,
            uint256(1),
            uint256(0x040df0) // 0x040dfc to enable curve; 0x04fdf0 to enable base exchanges;
        ) returns (uint256, uint256[] memory result) {
            distribution = result;
        } catch Error(string memory reason) {
            revert(reason);
        } catch (bytes memory) {
            revert("OSIA: 1split fail![1]");
        }

        uint256 value = fromToken == address(0) ? amount : 0;
        try OneSplit(ONE_SPLIT).swap.value(value)(
            fromToken,
            toToken,
            amount,
            uint256(1),
            distribution,
            uint256(0x040df0) // 0x040dfc to enable curve; 0x04fdf0 to enable base exchanges;
        ) {} catch Error(string memory reason) {
            revert(reason);
        } catch (bytes memory) {
            revert("OSIA: 1split fail![2]");
        }
    }
}