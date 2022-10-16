pragma solidity ^0.6.4;

contract brightIDsponsor {

 event Sponsor(address);

 
 fallback() external payable {
  sponsor(msg.sender);
 }

 
 receive() external payable {
   sponsor(msg.sender);
 }

 
 function sponsor(address add) public {
   emit Sponsor(add);
 }
}