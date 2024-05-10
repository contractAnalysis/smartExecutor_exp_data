pragma solidity ^0.5.16;
    
    
    

contract ChainFaces{
    
    function createFace(uint256 seed) public payable {}
}

contract IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4);
}

contract HappyFacePlace is IERC721Receiver{
    
    address natealex;
    
    uint previousBlockNumber;
    
    uint totalAscended = 0;
    
    ChainFaces chainFaces;
    
    modifier ZomaNotAllowed {
        require(msg.sender == natealex);
        _;
    }
    
    constructor () public{
        natealex = msg.sender;
        chainFaces = ChainFaces(0x91047Abf3cAb8da5A9515c8750Ab33B4f1560a7A);
    }
    
    function MintAFaceForTheHappyPlace() public ZomaNotAllowed{
        
        require(previousBlockNumber < block.number,"Each block deserves a Face in the Happy Face Place.");
        require(address(this).balance > 20 finney, "Any amount of Eth is worth eternal pleasure.");
        previousBlockNumber = block.number-10; 
        
        
        chainFaces.createFace.value(14 finney)(4206969);
        
        totalAscended++;
    }
    
    function UseDifferentAddress(address addr) public ZomaNotAllowed{
        natealex = addr;
    }
    
    function AddEth() public payable{
        
        require(msg.value > 0 wei);
    }
    
    function SubWei(uint weiAmt) public ZomaNotAllowed{
        msg.sender.transfer(weiAmt);
    }
    function EmptyEth() public ZomaNotAllowed{
        msg.sender.transfer(address(this).balance);
    }
    function GetTotalAscended() external view returns(uint){
        return totalAscended;
    }
    
    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
}