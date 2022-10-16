pragma solidity ^0.5.15;


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



pragma solidity ^0.5.15;


contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}



pragma solidity ^0.5.15;


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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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





pragma solidity 0.5.15;



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





pragma solidity 0.5.15;




library MathHelpers {
    using SafeMath for uint256;

    
    function getPartialAmount(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {
        return numerator.mul(target).div(denominator);
    }

    
    function getPartialAmountRoundedUp(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {
        return divisionRoundedUp(numerator.mul(target), denominator);
    }

    
    function divisionRoundedUp(
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {
        assert(denominator != 0); 
        if (numerator == 0) {
            return 0;
        }
        return numerator.sub(1).div(denominator).add(1);
    }

    
    function maxUint256(
    )
        internal
        pure
        returns (uint256)
    {
        return 2 ** 256 - 1;
    }

    
    function maxUint32(
    )
        internal
        pure
        returns (uint32)
    {
        return 2 ** 32 - 1;
    }

    
    function getNumBits(
        uint256 n
    )
        internal
        pure
        returns (uint256)
    {
        uint256 first = 0;
        uint256 last = 256;
        while (first < last) {
            uint256 check = (first + last) / 2;
            if ((n >> check) == 0) {
                last = check;
            } else {
                first = check + 1;
            }
        }
        assert(first <= 256);
        return first;
    }
}





pragma solidity 0.5.15;



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





pragma solidity 0.5.15;




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





pragma solidity 0.5.15;





library AdvancedTokenInteract {
    using TokenInteract for address;

    
    function ensureAllowance(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {
        if (token.allowance(address(this), spender) < amount) {
            token.approve(spender, MathHelpers.maxUint256());
        }
    }
}



pragma solidity 0.5.15;

interface IUniFactory {
    
    function createExchange(
        address token
    )
        external
        returns (address exchange);
    
    function getExchange(
        address token
    )
        external
        view
        returns (address exchange);
    function getToken(
        address exchange
    )
        external
        view
        returns (address token);
    function getTokenWithId(
        uint256 tokenId
    )
        external
        view
        returns (address token);
    
    function initializeFactory(
        address template
    )
        external;
}



pragma solidity 0.5.15;

interface IUni {
    
    function tokenAddress()
        external
        view
        returns (address token);

    
    function factoryAddress()
        external
        view
        returns (address factory);

    
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 deadline
    )
        external
        payable
        returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256 min_eth,
        uint256 min_tokens,
        uint256 deadline
    )
        external
        returns (uint256, uint256);

    
    function getEthToTokenInputPrice(
        uint256 eth_sold
    )
        external
        view
        returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(
        uint256 tokens_bought
    )
        external
        view
        returns (uint256 eth_sold);

    function getTokenToEthInputPrice(
        uint256 tokens_sold
    )
        external
        view
        returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(
        uint256 eth_bought
    )
        external
        view
        returns (uint256 tokens_sold);

    
    function ethToTokenSwapInput(
        uint256 min_tokens,
        uint256 deadline
    )
        external
        payable
        returns (uint256  tokens_bought);

    function ethToTokenTransferInput(
        uint256 min_tokens,
        uint256 deadline,
        address recipient
    )
        external
        payable
        returns (uint256  tokens_bought);

    function ethToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 deadline
    )
        external
        payable
        returns (uint256  eth_sold);

    function ethToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 deadline,
        address recipient
    )
        external
        payable
        returns (uint256  eth_sold);

    
    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    )
        external
        returns (uint256  eth_bought);

    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline, address recipient
    )
        external
        returns (uint256  eth_bought);

    function tokenToEthSwapOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline
    )
        external
        returns (uint256  tokens_sold);

    function tokenToEthTransferOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline,
        address recipient
    )
        external
        returns (uint256  tokens_sold);

    
    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    )
        external
        returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    )
        external
        returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address token_addr
    )
        external
        returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address token_addr
    )
        external returns (uint256  tokens_sold);

    
    function tokenToExchangeSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address exchange_addr
    )
        external
        returns (uint256  tokens_bought);

    function tokenToExchangeTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address exchange_addr
    )
        external
        returns (uint256  tokens_bought);

    function tokenToExchangeSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address exchange_addr
    )
        external
        returns (uint256  tokens_sold);

    function tokenToExchangeTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address exchange_addr
    )
        external
        returns (uint256  tokens_sold);
}





pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;



library Require {

    

    uint256 constant ASCII_ZERO = 48; 
    uint256 constant ASCII_RELATIVE_ZERO = 87; 
    uint256 constant ASCII_LOWER_EX = 120; 
    bytes2 constant COLON = 0x3a20; 
    bytes2 constant COMMA = 0x2c20; 
    bytes2 constant LPAREN = 0x203c; 
    byte constant RPAREN = 0x3e; 
    uint256 constant FOUR_BIT_MASK = 0xf;

    

    function checkSuccess(
    )
        internal
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

    function that(
        bool must,
        bytes32 file,
        bytes32 reason
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason)
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        address payloadB
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA,
        bytes32 payloadB
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA,
        uint256 payloadB
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bool payloadA,
        uint256 payloadB
    )
        internal
        pure
    {
        uint256 num;
        if (payloadA) {
          num = 1;
        } else {
          num = 0;
        }
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(num),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bool payloadA,
        bool payloadB,
        bool payloadC
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bool payloadA,
        bool payloadB,
        bool payloadC,
        bool payloadD
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        COMMA,
                        stringify(payloadD),
                        RPAREN
                    )
                )
            );
        }
    }
    


    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bool payloadA,
        uint256 payloadB,
        uint256 payloadC
    )
        internal
        pure
    {
        uint256 num;
        if (payloadA) {
          num = 1;
        } else {
          num = 0;
        }
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(num),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }
    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bool payloadA,
        uint256 payloadB,
        bool payloadC,
        uint256 payloadD
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        COMMA,
                        stringify(payloadD),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bool payloadA,
        uint256 payloadB,
        uint256 payloadC,
        uint256 payloadD
    )
        internal
        pure
    {
        uint256 num;
        if (payloadA) {
          num = 1;
        } else {
          num = 0;
        }
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(num),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        COMMA,
                        stringify(payloadD),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bool payloadA
    )
        internal
        pure
    {
        uint256 num;
        if (payloadA) {
          num = 1;
        } else {
          num = 0;
        }
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(num),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB,
        uint256 payloadC
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        address payloadB,
        uint256 payloadC
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA,
        uint256 payloadB,
        uint256 payloadC
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA,
        uint256 payloadB,
        uint256 payloadC
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB,
        uint256 payloadC,
        uint256 payloadD
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        COMMA,
                        stringify(payloadD),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        address payloadB,
        uint256 payloadC,
        uint256 payloadD
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        COMMA,
                        stringify(payloadD),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA,
        uint256 payloadB,
        uint256 payloadC,
        uint256 payloadD
    )
        internal
        pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        COMMA,
                        stringify(payloadD),
                        RPAREN
                    )
                )
            );
        }
    }

    

    function stringifyTruncated(
        bytes32 input
    )
        private
        pure
        returns (bytes memory)
    {
        
        bytes memory result = abi.encodePacked(input);

        
        for (uint256 i = 32; i > 0; ) {
            
            
            i--;

            
            if (result[i] != 0) {
                uint256 length = i + 1;

                
                assembly {
                    mstore(result, length) 
                }

                return result;
            }
        }

        
        return new bytes(0);
    }

    function stringify(
        uint256 input
    )
        private
        pure
        returns (bytes memory)
    {
        if (input == 0) {
            return "0";
        }

        
        uint256 j = input;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

        
        bytes memory bstr = new bytes(length);

        
        j = input;
        for (uint256 i = length; i > 0; ) {
            
            
            i--;

            
            bstr[i] = byte(uint8(ASCII_ZERO + (j % 10)));

            
            j /= 10;
        }

        return bstr;
    }

    function stringify(
        bool input
    )
        private
        pure
        returns (bytes memory)
    {
        uint256 num;
        if (input) {
          num = 1;
        } else{
          num = 0;
        }
        return stringify(num);
    }

    

    function stringify(
        address input
    )
        private
        pure
        returns (bytes memory)
    {
        uint256 z = uint256(input);

        
        bytes memory result = new bytes(42);

        
        result[0] = byte(uint8(ASCII_ZERO));
        result[1] = byte(uint8(ASCII_LOWER_EX));

        
        for (uint256 i = 0; i < 20; i++) {
            
            uint256 shift = i * 2;

            
            result[41 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;

            
            result[40 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;
        }

        return result;
    }

    function stringify(
        bytes32 input
    )
        private
        pure
        returns (bytes memory)
    {
        uint256 z = uint256(input);

        
        bytes memory result = new bytes(66);

        
        result[0] = byte(uint8(ASCII_ZERO));
        result[1] = byte(uint8(ASCII_LOWER_EX));

        
        for (uint256 i = 0; i < 32; i++) {
            
            uint256 shift = i * 2;

            
            result[65 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;

            
            result[64 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;
        }

        return result;
    }

    function char(
        uint256 input
    )
        private
        pure
        returns (byte)
    {
        
        if (input < 10) {
            return byte(uint8(input + ASCII_ZERO));
        }

        
        return byte(uint8(input + ASCII_RELATIVE_ZERO));
    }
}



pragma solidity 0.5.15;



interface IErc20 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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

    function name()
        external
        view
        returns (string memory);

    function symbol()
        external
        view
        returns (string memory);

    function decimals()
        external
        view
        returns (uint8);
}



pragma solidity 0.5.15;




library Token {

    

    bytes32 constant FILE = "";

    // ============ Library Functions ============

    function balanceOf(
        address token,
        address owner
    )
        internal
        view
        returns (uint256)
    {
        return IErc20(token).balanceOf(owner);
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
        return IErc20(token).allowance(owner, spender);
    }

    function approve(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {
        IErc20(token).approve(spender, amount);

        Require.that(
            Require.checkSuccess(),
            FILE,
            "0"
        );
    }

    function approveMax(
        address token,
        address spender
    )
        internal
    {
        approve(
            token,
            spender,
            uint256(-1)
        );
    }

    function transfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {
        IErc20(token).transfer(to, amount);

        Require.that(
            Require.checkSuccess(),
            FILE,
            "1"
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
        IErc20(token).transferFrom(from, to, amount);

        Require.that(
            Require.checkSuccess(),
            FILE,
            "2"
        );
    }

}



pragma solidity 0.5.15;










interface WETH9 {
  function deposit() external payable;
  function withdraw(uint wad) external;
}

contract UniswapDydxExchangeWrapper is
    Ownable,
    ExchangeWrapper
{
    using SafeMath for uint256;
    using AdvancedTokenInteract for address;


    

    address public UNISWAP_FACTORY;
    address public WETH;


    
    constructor(address _uniswapFactory, address _wethToken) public {
        UNISWAP_FACTORY = _uniswapFactory;
        WETH = _wethToken;
    }

    
    function ()
      external
      payable
    {
      
    }

    

    struct SwapInput {
        address mainToken;
        uint256 tokensSold;
        uint256 minTokensBought;
        address outToken;
    }

    

    
    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256)
    {
        
        uint256 deadline = now + (60 * 15);

        if (takerToken == WETH) {

            
            WETH9(WETH).withdraw(requestedFillAmount);

            
            address exchangeAddress = IUniFactory(UNISWAP_FACTORY).getExchange(makerToken);

            
            uint256 boughtTokens = IUni(exchangeAddress).ethToTokenSwapInput.value(requestedFillAmount)(0, deadline);

            
            AdvancedTokenInteract.ensureAllowance(makerToken, receiver, boughtTokens);

            
            return boughtTokens;
        } else if (makerToken == WETH) {

            
            address exchangeAddress = IUniFactory(UNISWAP_FACTORY).getExchange(takerToken);
            
            AdvancedTokenInteract.ensureAllowance(takerToken, exchangeAddress, requestedFillAmount);

            
            uint256 eth_bought = IUni(exchangeAddress).tokenToEthSwapInput(requestedFillAmount, 0, deadline);

            
            WETH9(WETH).deposit.value(eth_bought)();

            
            AdvancedTokenInteract.ensureAllowance(makerToken, receiver, eth_bought);

            
            return eth_bought;
        } else {
            
            

            SwapInput memory inputs = SwapInput({
              mainToken: takerToken,
              tokensSold: requestedFillAmount,
              minTokensBought: 1,
              outToken: makerToken
            });

            
            address exchangeAddress = IUniFactory(UNISWAP_FACTORY).getExchange(inputs.mainToken);
            
            AdvancedTokenInteract.ensureAllowance(inputs.mainToken, exchangeAddress, requestedFillAmount);

            uint256 minEthBought = 1; 

            
            uint256 boughtTokens = IUni(exchangeAddress).tokenToTokenSwapInput(
                inputs.tokensSold,
                inputs.minTokensBought,
                minEthBought,
                deadline,
                inputs.outToken
            );

            
            AdvancedTokenInteract.ensureAllowance(makerToken, receiver, boughtTokens);

            
            return boughtTokens;
        }
    }

    
    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256)
    {
        if (takerToken == WETH){
          
          
          address out_exchange = IUniFactory(UNISWAP_FACTORY).getExchange(makerToken);
          
          return IUni(out_exchange).getEthToTokenOutputPrice(desiredMakerToken);
        } else if (makerToken == WETH) {
          
          address in_exchange = IUniFactory(UNISWAP_FACTORY).getExchange(takerToken);
          
          return IUni(in_exchange).getTokenToEthOutputPrice(desiredMakerToken);
        } else {
          
          
          
          
          
          
          
          
          address in_exchange = IUniFactory(UNISWAP_FACTORY).getExchange(takerToken);
          address out_exchange = IUniFactory(UNISWAP_FACTORY).getExchange(makerToken);
          

          uint256 eth_bought = IUni(out_exchange).getEthToTokenOutputPrice(desiredMakerToken);
          

          uint256 taker_token_reserve = Token.balanceOf(takerToken, in_exchange);
          
          uint256 taker_eth_reserve = in_exchange.balance;

          
          
          
          
          
          uint256 numerator = taker_token_reserve * eth_bought * 1000;
          uint256 denominator = (taker_eth_reserve - eth_bought) * 997;
          return numerator / denominator + 1;
        }
    }

     

    function getExchangeCostSell(
        address makerToken,
        address takerToken,
        uint256 desiredTakerAmount,
        bytes calldata orderData
    )
        external
        view
        returns (uint256)
    {
        
        
        

        
        if (takerToken == WETH){
          
          
          address out_exchange = IUniFactory(UNISWAP_FACTORY).getExchange(makerToken);
          return IUni(out_exchange).getEthToTokenInputPrice(desiredTakerAmount);
        } else if (makerToken == WETH) {
          
          address in_exchange = IUniFactory(UNISWAP_FACTORY).getExchange(takerToken);
          return IUni(in_exchange).getTokenToEthInputPrice(desiredTakerAmount);
        } else {
          
          
          address in_exchange = IUniFactory(UNISWAP_FACTORY).getExchange(takerToken);
          address out_exchange = IUniFactory(UNISWAP_FACTORY).getExchange(makerToken);
          uint256 eth_bought = IUni(in_exchange).getTokenToEthInputPrice(desiredTakerAmount);
          uint256 maker_token_reserve = Token.balanceOf(makerToken, out_exchange);
          uint256 maker_eth_reserve = out_exchange.balance;
          uint256 numerator = maker_token_reserve * eth_bought * 1000;
          uint256 denominator = (maker_eth_reserve - eth_bought) * 997;
          return  numerator / denominator + 1;
        }
    }

    function suicideMe()
      public
      onlyOwner
    {
      uint256 wethBalance = Token.balanceOf(WETH, address(this));
      if (wethBalance > 0) {
        WETH9(WETH).withdraw(wethBalance);
      }
      selfdestruct(address(uint160(owner())));
    }

}