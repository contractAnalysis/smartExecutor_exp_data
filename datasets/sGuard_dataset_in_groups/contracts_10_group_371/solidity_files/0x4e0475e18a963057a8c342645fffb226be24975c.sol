pragma solidity ^0.5.0;

contract AOQUtil {

    using SafeMath for *;

    uint ethWei = 1 ether;

    function getLevel(uint value) public view returns (uint) {
        if (value >= 1 * ethWei && value <= 5 * ethWei) {
            return 1;
        }
        if (value >= 6 * ethWei && value <= 10 * ethWei) {
            return 2;
        }
        if (value >= 11 * ethWei && value <= 20 * ethWei) {
            return 3;
        }
        if (value >= 21 * ethWei && value <= 31 * ethWei) {
            return 4;
        }
        return 0;
    }

    function getStaticCoefficient(uint level) public pure returns (uint) {
        if (level == 1) {
            return 3;
        }
        if (level == 2) {
            return 6;
        }
        if (level == 3) {
            return 10;
        }
        if (level == 4) {
            return 12;
        }
        return 0;
    }

    function getRecommendCoefficient(uint times) public pure returns (uint){
        uint level = times.mod(5);

        if(level == 1){
            return 50;
        }
        if(level == 2){
            return 100;
        }
        if(level==3){
            return 200;
        }
        if(level==4){
            return 300;
        }
        if(level ==0){
            return 350;
        }

        return 0;
    }

    function compareStr(string memory _str, string memory str) public pure returns (bool) {
        if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {
            return true;
        }
        return false;
    }
}


library SafeMath {

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "div zero");
        
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "lower sub bigger");
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "overflow");

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "mod zero");
        return a % b;
    }
}