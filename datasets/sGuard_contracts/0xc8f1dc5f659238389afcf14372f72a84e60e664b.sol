pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;




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




interface ICurve {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    )
        external;

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    )
        external;
}




interface ExchangeWrapper {

    

    
    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256);

    
    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256);
}




interface GeneralERC20 {
    function totalSupply(
    )
        external
        view
        returns (uint256);

    function balanceOf(
        address who
    )
        external
        view
        returns (uint256);

    function allowance(
        address owner,
        address spender
    )
        external
        view
        returns (uint256);

    function transfer(
        address to,
        uint256 value
    )
        external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external;

    function approve(
        address spender,
        uint256 value
    )
        external;
}




library TokenInteract {
    function balanceOf(
        address token,
        address owner
    )
        internal
        view
        returns (uint256)
    {
        return GeneralERC20(token).balanceOf(owner);
    }

    function allowance(
        address token,
        address owner,
        address spender
    )
        internal
        view
        returns (uint256)
    {
        return GeneralERC20(token).allowance(owner, spender);
    }

    function approve(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {
        GeneralERC20(token).approve(spender, amount);

        require(
            checkSuccess(),
            "TokenInteract#approve: Approval failed"
        );
    }

    function transfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {
        address from = address(this);
        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transfer(to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transfer: Transfer failed"
        );
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transferFrom(from, to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transferFrom: TransferFrom failed"
        );
    }

    

    
    function checkSuccess(
    )
        private
        pure
        returns (bool)
    {
        uint256 returnValue = 0;

        
        assembly {
            
            switch returndatasize

            
            case 0x0 {
                returnValue := 1
            }

            
            case 0x20 {
                
                returndatacopy(0x0, 0x0, 0x20)

                
                returnValue := mload(0x0)
            }

            
            default { }
        }

        return returnValue != 0;
    }
}




contract CurveExchangeWrapper is
    ExchangeWrapper
{
    using SafeMath for uint256;
    using TokenInteract for address;

    struct Trade {
        address curveAddress;
        int128 fromId;
        int128 toId;
        uint256 fromAmount;
        bool exchangeUnderlying;
    }

    

    function exchange(
        address ,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256)
    {
        (
            uint256 minToAmount,
            Trade[] memory trades
        ) = abi.decode(orderData, (uint256, Trade[]));

        uint256 totalFromAmount = 0;

        for (uint256 i = 0; i < trades.length; i++) {
            Trade memory trade = trades[i];
            takerToken.approve(trade.curveAddress, trade.fromAmount);
            totalFromAmount = totalFromAmount.add(trade.fromAmount);

            if (trade.exchangeUnderlying) {
                ICurve(trade.curveAddress).exchange_underlying(
                    trade.fromId,
                    trade.toId,
                    trade.fromAmount,
                    0
                );
            } else {
                ICurve(trade.curveAddress).exchange(
                    trade.fromId,
                    trade.toId,
                    trade.fromAmount,
                    0
                );
            }
        }

        uint256 toAmount = makerToken.balanceOf(address(this));

        require(
             toAmount >= minToAmount,
            "minToAmount not satisfied"
        );
        require(
             totalFromAmount == requestedFillAmount,
            "totalFromAmount does not equal requestedFillAmount"
        );

        makerToken.approve(receiver, toAmount);

        return toAmount;
    }

    function getExchangeCost(
        address ,
        address ,
        uint256 ,
        bytes calldata 
    )
        external
        view
        returns (uint256)
    {
        revert("getExchangeCost not implemented");
    }
}