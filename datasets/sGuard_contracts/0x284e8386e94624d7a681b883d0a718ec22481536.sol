pragma solidity ^0.5.0;


contract Ownable {
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  
  constructor() public {
    _owner = msg.sender;
  }

  
  function owner() public view returns(address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


library utils {
    uint constant UINT256MAX = ~uint(0);

    
    function byte2Uint(byte b) internal pure returns(uint8) {
        if (b >= '0' && b <= '9') {
            return uint8(b) - 48;  
        }
        
        return 10;
    }
    
    function hexByte2Uint(byte b) internal pure returns(uint8) {
        if (b >= '0' && b <= '9') {
            return uint8(b) - 48;  
        } else if (b >= 'A' && b <= 'F') {
            return uint8(b) - 55;
        } else if (b >= 'a' && b <= 'f') {
            return uint8(b) - 87;
        }
        
        return 16;
    }

    

    
    
    
    function str2Uint(string memory a) internal pure returns(uint) {
        bytes memory b = bytes(a);
        uint res = 0;
        for (uint i = 0; i < b.length; i++) {
            uint8 tmp = byte2Uint(b[i]);
            if (tmp >= 10) {
                return res;
            } else {
                
                if (res >= UINT256MAX / 10) {
                    return UINT256MAX;
                }
                res = res * 10 + tmp;
            }
        }
        return res;
    }

    
    
    
    function hexStr2Uint(string memory a) internal pure returns(uint) {
        bytes memory b = bytes(a);
        uint res = 0;
        uint i = 0;
        if (b.length >= 2 && b[0] == '0' && (b[1] == 'x' || b[1] == 'X')) {
            i += 2;
        }
        for (; i < b.length; i++) {
            uint tmp = hexByte2Uint(b[i]);
            if (tmp >= 16) {
                return res;
            } else {
                
                if (res >= UINT256MAX / 16) {
                    return UINT256MAX;
                }
                res = res * 16 + tmp;
            }
        }
        return res;
    }

    
    
    
    function str2Addr(string memory a) internal pure returns(address) {
        bytes memory b = bytes(a);
        require(b.length == 40 || b.length == 42, "Invalid input, should be 20-byte hex string");
        uint i = 0;
        if (b.length == 42) {
            i += 2;
        }

        uint160 res = 0;
        for (; i < b.length; i += 2) {
            res *= 256;

            uint160 b1 = uint160(hexByte2Uint(b[i]));
            uint160 b2 = uint160(hexByte2Uint(b[i+1]));
            require(b1 < 16 && b2 < 16, "address string with invalid character");

            res += b1 * 16 + b2;
        }
        return address(res);
    }

    

    
    function uint2HexStr(uint x) internal pure returns(string memory) {
        if (x == 0) return '0';

        uint j = x;
        uint len;
        while (j != 0) {
            len++;
            j /= 16;
        }

        bytes memory b = new bytes(len);
        uint k = len - 1;
        while (x != 0) {
            uint8 curr = uint8(x & 0xf);
            b[k--] = curr > 9 ? byte(55 + curr) : byte(48 + curr);
            x /= 16;
        }
        return string(b);
    }

    
    function uint2Str(uint x) internal pure returns(string memory) {
        if (x == 0) return '0';

        uint j = x;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory b = new bytes(len);
        uint k = len - 1;
        while (x != 0) {
            b[k--] = byte(uint8(48 + x % 10));
            x /= 10;
        }
        return string(b);
    }

    
    function addr2Str(address _addr) internal pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory charset = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = charset[uint8(value[i + 12] >> 4)];
            str[3+i*2] = charset[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    

    function bytesConcat(bytes memory a, bytes memory b) internal pure returns(bytes memory) {
        bytes memory concated = new bytes(a.length + b.length);
        uint i = 0;
        uint k = 0;
        while (i < a.length) { concated[k++] = a[i++]; }
        i = 0;
        while(i < b.length) { concated[k++] = b[i++]; }
        return concated;
    }

    function strConcat(string memory a, string memory b) internal pure returns(string memory) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        return string(bytesConcat(aa, bb));
    }

    function bytesCompare(bytes memory a, bytes memory b) internal pure returns(int) {
        uint len = a.length < b.length ? a.length : b.length;
        for (uint i = 0; i < len; i++) {
            if (a[i] < b[i]) {
                return -1;
            } else if (a[i] > b[i]) {
                return 1;
            }
        }
        if (a.length < b.length) {
            return -1;
        } else if (a.length > b.length) {
            return 1;
        } else {
            return 0;
        }
    }

    
    function strCompare(string memory a, string memory b) internal pure returns(int) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        return bytesCompare(aa, bb);
    }

    function bytesEqual(bytes memory a, bytes memory b) internal pure returns(bool) {
        return (a.length == b.length) && (bytesCompare(a, b) == 0);
    }

    function strEqual(string memory a, string memory b) internal pure returns(bool) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        return bytesEqual(aa, bb);
    }

    
    
    
    
    
    
    
    
    function indexOf(string memory haystack, string memory needle) internal pure returns(int) {
        bytes memory b_haystack = bytes(haystack);
        bytes memory b_needle = bytes(needle);
        return indexOf(b_haystack, b_needle);
    }

    function indexOf(bytes memory haystack, bytes memory needle) internal pure returns(int) {
        if (needle.length == 0) {
            return 0;
        } else if (haystack.length < needle.length) {
            return -1;
        }
        
        
        uint[] memory pi = new uint[](needle.length + 1);
        pi[1] = 0;
        uint k = 0;
        uint q = 0;
        
        for(q = 2; q <= needle.length; q++) {
            while(k > 0 && needle[k] != needle[q-1]) {
                k = pi[k];
            }
            if(needle[k] == needle[q-1]) {
                k++;
            }
            pi[q] = k;
        }
        
        q = 0;
        for(uint i = 0; i < haystack.length; i++) {
            while(q > 0 && needle[q] != haystack[i]) {
                q = pi[q];
            }
            if(needle[q] == haystack[i]) {
                q++;
            }
            
            if(q == needle.length) {
                return int(i - q + 1);
            }
        }
        
        return -1;
    }

    
    
    function subStr(bytes memory a, uint start, uint len) internal pure returns(bytes memory) {
        require(start < a.length && start + len > start && start + len <= a.length,
                "Invalid start index or length out of range");
        bytes memory res = new bytes(len);
        for (uint i = 0; i < len; i++) {
            res[i] = a[start + i];
        }
        return res;
    }

    
    
    function subStr(bytes memory a, uint start) internal pure returns(bytes memory) {
        require(start < a.length, "Invalid start index out of range");
        return subStr(a, start, a.length - start);
    }

    function subStr(string memory a, uint start, uint len) internal pure returns(string memory) {
        bytes memory aa = bytes(a);
        return string(subStr(aa, start, len));
    }

    function subStr(string memory a, uint start) internal pure returns(string memory) {
        bytes memory aa = bytes(a);
        return string(subStr(aa, start));
    }
}

contract DOSProxyInterface {
    function query(address, uint, string memory, string memory) public returns (uint);
    function requestRandom(address, uint) public returns (uint);
}

contract DOSPaymentInterface {
    function setPaymentMethod(address payer, address tokenAddr) public;
    function defaultTokenAddr() public returns(address);
}

contract DOSAddressBridgeInterface {
    function getProxyAddress() public view returns (address);
    function getPaymentAddress() public view returns (address);
}

contract ERC20I {
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
}

contract DOSOnChainSDK is Ownable {
    
    

    DOSProxyInterface dosProxy;
    DOSAddressBridgeInterface dosAddrBridge =
        DOSAddressBridgeInterface(0x98A0E7026778840Aacd28B9c03137D32e06F5ff1);

    modifier resolveAddress {
        dosProxy = DOSProxyInterface(dosAddrBridge.getProxyAddress());
        _;
    }

    modifier auth {
        
        require(msg.sender == dosAddrBridge.getProxyAddress(), "Unauthenticated response");
        _;
    }

    
    function DOSSetup() public onlyOwner {
        address paymentAddr = dosAddrBridge.getPaymentAddress();
        address defaultToken = DOSPaymentInterface(dosAddrBridge.getPaymentAddress()).defaultTokenAddr();
        ERC20I(defaultToken).approve(paymentAddr, uint(-1));
        DOSPaymentInterface(dosAddrBridge.getPaymentAddress()).setPaymentMethod(address(this), defaultToken);
    }

    
    function DOSRefund() public onlyOwner {
        address token = DOSPaymentInterface(dosAddrBridge.getPaymentAddress()).defaultTokenAddr();
        uint amount = ERC20I(token).balanceOf(address(this));
        ERC20I(token).transfer(msg.sender, amount);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function DOSQuery(uint timeout, string memory dataSource, string memory selector)
        internal
        resolveAddress
        returns (uint)
    {
        return dosProxy.query(address(this), timeout, dataSource, selector);
    }

    
    
    
    
    
    
    function __callback__(uint queryId, bytes calldata result) external {
        
    }

    
    
    
    
    
    
    function DOSRandom(uint seed)
        internal
        resolveAddress
        returns (uint)
    {
        return dosProxy.requestRandom(address(this), seed);
    }

    
    
    
    
    
    
    
    function __callback__(uint requestId, uint generatedRandom) external auth {
        
    }
}



contract CoinbaseEthPriceFeed is DOSOnChainSDK {
    using utils for *;

    
    struct ethusd {
        uint integral;
        uint fractional;
    }
    uint queryId;
    string public price_str;
    ethusd public price;

    event GetPrice(uint integral, uint fractional);

    constructor() public {
        
        
        
        super.DOSSetup();
    }

    function getEthUsdPrice() public {
        queryId = DOSQuery(30, "https://api.coinbase.com/v2/prices/ETH-USD/spot", "$.data.amount");
    }

    function __callback__(uint id, bytes calldata result) external auth {
        require(queryId == id, "Unmatched response");

        price_str = string(result);
        price.integral = price_str.subStr(1).str2Uint();
        int delimit_idx = price_str.indexOf('.');
        if (delimit_idx != -1) {
            price.fractional = price_str.subStr(uint(delimit_idx + 1)).str2Uint();
        }
        emit GetPrice(price.integral, price.fractional);
    }
}