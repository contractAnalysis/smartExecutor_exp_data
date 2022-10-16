pragma solidity ^0.6.3;



contract SquareQueue_ico {
    
    
    uint public period_1_start; 
    uint public period_1_end; 
    uint public convert_rollUnder; 
    uint public convertDay; 
    uint public totalSQamount; 

    constructor () public {
        owner = msg.sender;
    }
    
    address payable public owner;
    uint public ICO_TotalEtherQuantityAccumulated;
    uint public ICOParticipantsCount;
    uint public ICO_TX_count;

    
    struct icoAccount_db {
        address pioneer; 
        uint etherAmount; 
        uint sqAmount; 
        uint ID; 
    }
    
    mapping(address => icoAccount_db) public ICO_account_DB;
    event Internal_TX_information (uint ID, uint _convertDay, uint _SQratio, uint _ICO_Accumulated, uint _ICOParticipantsCount, uint _totalSQamount);
    
    modifier onlyOwner() {
        require (msg.sender == owner, "This function can only create Tx by the owner of the contract.");
        _;
    }

    function periodSet(uint _period_1_start, uint _period_1_end) external onlyOwner {
        period_1_start = _period_1_start;
        period_1_end = _period_1_end;
    }

    function rollUnderSet(uint _convert_rollUnder) external onlyOwner {
        convert_rollUnder = _convert_rollUnder;
    }

    function withDrawFund(address payable recipient, uint _withDrawAmount) external onlyOwner {
        recipient.transfer(_withDrawAmount);
    }

    function contractDissolution() external onlyOwner {
        selfdestruct(owner);
    }
    
    receive() external payable {
        
        
        
        require (period_1_start > 1 && period_1_end > period_1_start && convert_rollUnder > 1 , " The ICO has not started yet.");
        require (uint(now) < period_1_end, "The ICO period has ended.");
        require (uint(now) > 1 , "There is an error in the Time Stamp. Please try again.");
        require (uint(msg.value) > 0 , "A malicious attack is suspected. Ether amount must be positive.");
        
        uint SQratio; 
        SQratio = 2200; 
        uint uintSQratio;

        if (uint(now) > period_1_start) { 
            
            convertDay = (uint(now) - period_1_start) / convert_rollUnder;
            if (convertDay == 0) {
                convertDay = 1;
            }
            require (convertDay > 0, "There is an error in the Time Stamp. Please try again.");
            require (convertDay < 88, "Blocks potential overflow errors or The ICO period has ended.");
            
            SQratio = 2210 - (10 * convertDay);
            require (SQratio > 0, "There is an error. Please try again.");
        }
        uintSQratio = uint(SQratio);
        
        icoAccount_db storage ico = ICO_account_DB[msg.sender];
        if (ico.pioneer == address(0)) {
            ICOParticipantsCount ++;
            ico.ID = ICOParticipantsCount; 
        } else {}
        ico.etherAmount += msg.value; 
        ico.sqAmount += msg.value * uintSQratio; 
        ico.pioneer = msg.sender; 

        ICO_TotalEtherQuantityAccumulated += msg.value;
        totalSQamount += msg.value * uintSQratio;
        
        
        emit Internal_TX_information (ico.ID, convertDay, uintSQratio, ICO_TotalEtherQuantityAccumulated, ICOParticipantsCount, totalSQamount);
        ICO_TX_count ++; 
    }
    

       
}