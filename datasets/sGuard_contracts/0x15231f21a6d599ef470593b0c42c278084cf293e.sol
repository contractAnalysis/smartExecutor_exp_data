pragma solidity 0.4.25;



interface IModelCalculator {
        function isTrivialInterval(uint256 _alpha, uint256 _beta) external pure returns (bool);

        function getValN(uint256 _valR, uint256 _maxN, uint256 _maxR) external pure returns (uint256);

        function getValR(uint256 _valN, uint256 _maxR, uint256 _maxN) external pure returns (uint256);

        function getNewN(uint256 _newR, uint256 _minR, uint256 _minN, uint256 _alpha, uint256 _beta) external pure returns (uint256);

        function getNewR(uint256 _newN, uint256 _minN, uint256 _minR, uint256 _alpha, uint256 _beta) external pure returns (uint256);
}



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
    require(b > 0); 
    uint256 c = a / b;
    

    return c;
  }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}




contract ModelCalculator is IModelCalculator {
    string public constant VERSION = "1.0.0";

    using SafeMath for uint256;

    
    uint256 public constant FIXED_ONE = 0x20000000000000000000000000000000;
    uint256 public constant A_B_SCALE = 10000000000000000000000000000000000;

        function isTrivialInterval(uint256 _alpha, uint256 _beta) external pure returns (bool) {
        return _alpha == A_B_SCALE && _beta == 0;
    }

        function getValN(uint256 _valR, uint256 _maxN, uint256 _maxR) external pure returns (uint256) {
        return _valR.mul(_maxN) / _maxR;
    }

        function getValR(uint256 _valN, uint256 _maxR, uint256 _maxN) external pure returns (uint256) {
        return _valN.mul(_maxR) / _maxN;
    }

        function getNewN(uint256 _newR, uint256 _minR, uint256 _minN, uint256 _alpha, uint256 _beta) external pure returns (uint256) {
        uint256 temp = pow(_newR.mul(FIXED_ONE), _minR, _alpha, A_B_SCALE);
        return _alpha.mul(temp) / (_alpha.mul(FIXED_ONE) / _minN).add(_beta.mul(temp.sub(FIXED_ONE)));
    }

        function getNewR(uint256 _newN, uint256 _minN, uint256 _minR, uint256 _alpha, uint256 _beta) external pure returns (uint256) {
        uint256 temp1 = _alpha.sub(_beta.mul(_minN));
        uint256 temp2 = _alpha.sub(_beta.mul(_newN));
        return pow((temp1.mul(FIXED_ONE) / temp2).mul(_newN), _minN, A_B_SCALE, _alpha).mul(_minR) / FIXED_ONE;
    }

        function pow(uint256 _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256) {
        return exp(log(_a / _b).mul(_c) / _d);
    }

        function log(uint256 _x) internal pure returns (uint256) {
        uint256 res = 0;

        uint256 y;
        uint256 z;
        uint256 w;

        assert(_x < 0x282bcb7edf620be5a97bf8a6e89874720); 
        if (_x >= 0x8f69ff327e2a0abedc8cb1a87d3bc87a) {res += 0x30000000000000000000000000000000; _x = _x * FIXED_ONE / 0x8f69ff327e2a0abedc8cb1a87d3bc87a;} 
        if (_x >= 0x43be76d19f73def530d5bb8fb9dc43e4) {res += 0x18000000000000000000000000000000; _x = _x * FIXED_ONE / 0x43be76d19f73def530d5bb8fb9dc43e4;} 
        if (_x >= 0x2e8f4a27b7ded4c468f16cb3612480b8) {res += 0x0c000000000000000000000000000000; _x = _x * FIXED_ONE / 0x2e8f4a27b7ded4c468f16cb3612480b8;} 
        if (_x >= 0x2699702e16b06a5a9c189196f8cc9268) {res += 0x06000000000000000000000000000000; _x = _x * FIXED_ONE / 0x2699702e16b06a5a9c189196f8cc9268;} 
        if (_x >= 0x232526e0e9c19ad127a319b7501d5785) {res += 0x03000000000000000000000000000000; _x = _x * FIXED_ONE / 0x232526e0e9c19ad127a319b7501d5785;} 
        if (_x >= 0x2189246d053d1785259fcc7ac9652bd4) {res += 0x01800000000000000000000000000000; _x = _x * FIXED_ONE / 0x2189246d053d1785259fcc7ac9652bd4;} 
        if (_x >= 0x20c24486c821ba29cacb3aebd2b6edc3) {res += 0x00c00000000000000000000000000000; _x = _x * FIXED_ONE / 0x20c24486c821ba29cacb3aebd2b6edc3;} 
        if (_x >= 0x206090906c40ed411b2823439dced945) {res += 0x00600000000000000000000000000000; _x = _x * FIXED_ONE / 0x206090906c40ed411b2823439dced945;} 
        if (_x >= 0x2030241206c206e81bcab23d632c0b35) {res += 0x00300000000000000000000000000000; _x = _x * FIXED_ONE / 0x2030241206c206e81bcab23d632c0b35;} 

        assert(_x >= FIXED_ONE);
        z = y = _x - FIXED_ONE;
        w = y * y / FIXED_ONE;
        res += z * (0x40000000000000000000000000000000 - y) / 0x040000000000000000000000000000000; z = z * w / FIXED_ONE; 
        res += z * (0x2aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y) / 0x080000000000000000000000000000000; z = z * w / FIXED_ONE; 
        res += z * (0x26666666666666666666666666666666 - y) / 0x0c0000000000000000000000000000000; z = z * w / FIXED_ONE; 
        res += z * (0x24924924924924924924924924924924 - y) / 0x100000000000000000000000000000000; z = z * w / FIXED_ONE; 
        res += z * (0x238e38e38e38e38e38e38e38e38e38e3 - y) / 0x140000000000000000000000000000000; z = z * w / FIXED_ONE; 
        res += z * (0x22e8ba2e8ba2e8ba2e8ba2e8ba2e8ba2 - y) / 0x180000000000000000000000000000000; z = z * w / FIXED_ONE; 
        res += z * (0x22762762762762762762762762762762 - y) / 0x1c0000000000000000000000000000000; z = z * w / FIXED_ONE; 
        res += z * (0x22222222222222222222222222222222 - y) / 0x200000000000000000000000000000000;                        

        return res;
    }

        function exp(uint256 _x) internal pure returns (uint256) {
        uint256 res = 0;

        uint256 y;
        uint256 z;

        z = y = _x % 0x4000000000000000000000000000000; 
        z = z * y / FIXED_ONE; res += z * 0x10e1b3be415a0000; 
        z = z * y / FIXED_ONE; res += z * 0x05a0913f6b1e0000; 
        z = z * y / FIXED_ONE; res += z * 0x0168244fdac78000; 
        z = z * y / FIXED_ONE; res += z * 0x004807432bc18000; 
        z = z * y / FIXED_ONE; res += z * 0x000c0135dca04000; 
        z = z * y / FIXED_ONE; res += z * 0x0001b707b1cdc000; 
        z = z * y / FIXED_ONE; res += z * 0x000036e0f639b800; 
        z = z * y / FIXED_ONE; res += z * 0x00000618fee9f800; 
        z = z * y / FIXED_ONE; res += z * 0x0000009c197dcc00; 
        z = z * y / FIXED_ONE; res += z * 0x0000000e30dce400; 
        z = z * y / FIXED_ONE; res += z * 0x000000012ebd1300; 
        z = z * y / FIXED_ONE; res += z * 0x0000000017499f00; 
        z = z * y / FIXED_ONE; res += z * 0x0000000001a9d480; 
        z = z * y / FIXED_ONE; res += z * 0x00000000001c6380; 
        z = z * y / FIXED_ONE; res += z * 0x000000000001c638; 
        z = z * y / FIXED_ONE; res += z * 0x0000000000001ab8; 
        z = z * y / FIXED_ONE; res += z * 0x000000000000017c; 
        z = z * y / FIXED_ONE; res += z * 0x0000000000000014; 
        z = z * y / FIXED_ONE; res += z * 0x0000000000000001; 
        res = res / 0x21c3677c82b40000 + y + FIXED_ONE; 

        if ((_x & 0x004000000000000000000000000000000) != 0) res = res * 0x70f5a893b608861e1f58934f97aea5816 / 0x63afbe7ab2082ba1a0ae5e4eb1b479e04; 
        if ((_x & 0x008000000000000000000000000000000) != 0) res = res * 0x63afbe7ab2082ba1a0ae5e4eb1b479e11 / 0x4da2cbf1be5827f9eb3ad1aa9866ebb76; 
        if ((_x & 0x010000000000000000000000000000000) != 0) res = res * 0x4da2cbf1be5827f9eb3ad1aa9866ebb8b / 0x2f16ac6c59de6f8d5d6f63c1482a7c89d; 
        if ((_x & 0x020000000000000000000000000000000) != 0) res = res * 0x2f16ac6c59de6f8d5d6f63c1482a7c8a1 / 0x1152aaa3bf81cb9fdb76eae12d0295732; 
        if ((_x & 0x040000000000000000000000000000000) != 0) res = res * 0x1152aaa3bf81cb9fdb76eae12d029572c / 0x02582ab704279e8efd15e0265855c47ab; 
        if ((_x & 0x080000000000000000000000000000000) != 0) res = res * 0x02582ab704279e8efd15e0265855c4792 / 0x000afe10820813d65dfe6a33c07f738f5; 
        assert(_x < 0x100000000000000000000000000000000); 

        return res;
    }
}