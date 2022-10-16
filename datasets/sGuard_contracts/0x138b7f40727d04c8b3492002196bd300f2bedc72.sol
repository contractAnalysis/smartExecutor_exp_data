pragma solidity ^0.6.0;

contract Vat {
    struct Ilk {
        uint256 Art;   
        uint256 rate;  
        uint256 spot;  
        uint256 line;  
        uint256 dust;  
    }
    
    mapping (bytes32 => Ilk) public ilks;
}

contract McdInfo {
    address public constant VAT_ADDRESS = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    
    function getCeiling(bytes32[] memory _ilks) public view returns (uint[] memory ceilings) {
        ceilings = new uint[](_ilks.length);
        
        
        for(uint i = 0; i < _ilks.length; ++i) {
            (,,, ceilings[i],) = Vat(VAT_ADDRESS).ilks(_ilks[i]);
        }
    }
}