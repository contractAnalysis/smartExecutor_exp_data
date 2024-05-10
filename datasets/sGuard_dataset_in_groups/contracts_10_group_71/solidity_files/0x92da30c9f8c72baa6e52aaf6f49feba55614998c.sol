pragma solidity ^0.5.0;




library SafeMath {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}





contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}






contract PaySpec  {

   using SafeMath for uint;


   mapping(bytes32 => Invoice) invoices;



  event CreatedInvoice(bytes32 uuid);
  event PaidInvoice(bytes32 uuid, address from);


  struct Invoice {
    bytes32 uuid;
    string description;
    uint256 refNumber;


    address token;
    uint256 amountDue;
    address payTo;
    uint256 ethBlockCreatedAt;


    address paidBy;
    uint256 amountPaid;
    uint256 ethBlockPaidAt;


    uint256 ethBlockExpiresAt;

  }



  constructor(  ) public {


  }


  
  function() external    payable {
      revert();
  }


  function getContractVersion( ) public pure returns (uint)
  {
      return 1;
  }


  function createInvoice(uint256 refNumber, string memory description,  address token, uint256 amountDue, address payTo, uint256 ethBlockExpiresAt ) public returns (bytes32 uuid) {
      return _createInvoiceInternal(msg.sender, refNumber,description,token,amountDue,payTo,ethBlockExpiresAt);
  }

  function createAndPayInvoice(uint256 refNumber, string memory description,  address token, uint256 amountDue, address payTo, uint256 ethBlockExpiresAt ) public returns (bool) {
      bytes32 uuid =  _createInvoiceInternal(msg.sender, refNumber,description,token,amountDue,payTo,ethBlockExpiresAt) ;


      require( payInvoice(uuid) );

      return true;

  }

   function _createInvoiceInternal( address from, uint256 refNumber, string memory description,  address token, uint256 amountDue, address payTo, uint256 ethBlockExpiresAt ) private returns (bytes32 uuid) {

      uint256 ethBlockCreatedAt = block.number;

      bytes32 newuuid = keccak256( abi.encodePacked(from, refNumber, description,  token, amountDue, payTo ) );

      require( invoices[newuuid].uuid == 0 );  

      invoices[newuuid] = Invoice({
       uuid: newuuid,
       description: description,
       refNumber: refNumber,
       token: token,
       amountDue: amountDue,
       payTo: payTo,
       ethBlockCreatedAt: ethBlockCreatedAt,
       paidBy: address(0),
       amountPaid: 0,
       ethBlockPaidAt: 0,
       ethBlockExpiresAt: ethBlockExpiresAt

      });


       emit CreatedInvoice(newuuid);

       return uuid;
   }

   function payInvoice(bytes32 invoiceUUID) public returns (bool)
   {
     
     require( ERC20Interface(  invoices[invoiceUUID].token ).transferFrom(msg.sender, address(this),  invoices[invoiceUUID].amountDue )   );

     return _payInvoiceInternal( invoiceUUID, msg.sender);


   }

   function _payInvoiceInternal( bytes32 invoiceUUID, address from ) private returns (bool) {

       require( invoices[invoiceUUID].uuid == invoiceUUID ); 
       require( invoiceWasPaid(invoiceUUID) == false );
       require( invoiceHasExpired(invoiceUUID) == false);

       
       require( ERC20Interface( invoices[invoiceUUID].token  ).transfer(  invoices[invoiceUUID].payTo, invoices[invoiceUUID].amountDue   ) );

       invoices[invoiceUUID].amountPaid = invoices[invoiceUUID].amountDue;

       invoices[invoiceUUID].paidBy = from;

       invoices[invoiceUUID].ethBlockPaidAt = block.number;



       emit PaidInvoice(invoiceUUID, from);

       return true;


   }

   function getDescription( bytes32 invoiceUUID ) public view returns ( string  memory )
   {
       return invoices[invoiceUUID].description;
   }

   function getRefNumber( bytes32 invoiceUUID ) public view returns (uint)
   {
       return invoices[invoiceUUID].refNumber;
   }

   function getEthBlockExpiredAt( bytes32 invoiceUUID ) public view returns (uint)
   {
       return invoices[invoiceUUID].ethBlockExpiresAt;
   }

   function getTokenAddress( bytes32 invoiceUUID ) public view returns (address)
   {
       return invoices[invoiceUUID].token;
   }

   function getRecipientAddress( bytes32 invoiceUUID ) public view returns (address)
   {
       return invoices[invoiceUUID].payTo;
   }

   function invoiceExists ( bytes32 invoiceUUID ) public view returns (bool)
   {
     return invoices[invoiceUUID].uuid == invoiceUUID;
   }


   function getAmountDue( bytes32 invoiceUUID ) public view returns (uint)
   {
       return invoices[invoiceUUID].amountDue;
   }

   function getAmountPaid( bytes32 invoiceUUID ) public view returns (uint)
   {
       return invoices[invoiceUUID].amountPaid;
   }

   function getEthBlockPaidAt( bytes32 invoiceUUID ) public view returns (uint)
   {
       return invoices[invoiceUUID].ethBlockPaidAt;
   }




   function invoiceWasPaid( bytes32 invoiceUUID ) public view returns (bool)
   {
       return invoices[invoiceUUID].amountPaid >= invoices[invoiceUUID].amountDue;
   }


   function invoiceHasExpired( bytes32 invoiceUUID ) public view returns (bool)
   {
       return (getEthBlockExpiredAt(invoiceUUID) != 0 && block.number >= getEthBlockExpiredAt(invoiceUUID));
   }



   
     function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public returns (bool) {

        
        require(msg.sender == token);

        
        require( ERC20Interface(token).transferFrom(from, address(this), tokens)   );

        require(  _payInvoiceInternal(bytesToBytes32(data,0), from)  );

        return true;

     }

    function bytesToBytes32(bytes memory b, uint offset) private pure returns (bytes32) {
      bytes32 out;

      for (uint i = 0; i < 32; i++) {
        out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
      }
      return out;
    }


}