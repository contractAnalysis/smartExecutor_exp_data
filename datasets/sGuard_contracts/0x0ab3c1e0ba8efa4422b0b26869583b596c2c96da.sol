pragma solidity 0.5.17;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

interface IToken { 
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}


contract OpenCourt is Context { 
    
    address public judgeToken = 0x17A83B1eA24942fb6a913bCB87f38035AB205b68;
    IToken private judge = IToken(judgeToken);
    address public judgmentToken = 0x067b408EDDEea54D61172198Ae5D9077789da2A9;
    IToken private judgment = IToken(judgmentToken);
    string public emoji = "🌐⚖👥️";
    string public procedures = "lawdocs.eth";
    
    
    uint256 public dispute; 
    mapping (uint256 => Dispute) public disp;
    
    struct Dispute {  
        address complainant; 
        address respondent;
        uint256 number;
        string complaint;
        string response;
        string verdict;
        bool resolved;
        bool responded;
    }
    
    event Complaint(address indexed complainant, address indexed respondent, uint256 indexed number, string complaint);
    event ComplaintUpdated(uint256 indexed number, string complaint);
    event Response(uint256 indexed number, string response);
    event Verdict(uint256 indexed number, string verdict);
    
    
    
    function submitComplaint(address respondent, string memory complaint) public {
	uint256 number = dispute + 1; 
	dispute = dispute + 1;
	    
        disp[number] = Dispute( 
            _msgSender(),
            respondent,
            number,
            complaint,
            "PENDING",
            "PENDING",
            false,
            false);
                
        emit Complaint(_msgSender(), respondent, number, complaint);
    }
    
    function updateComplaint(uint256 number, string memory updatedComplaint) public {
        Dispute storage dis = disp[number];
        require(_msgSender() == dis.complainant);
        dis.complaint = updatedComplaint;
        emit ComplaintUpdated(number, updatedComplaint);
    }
    
    
    function submitResponse(uint256 number, string memory response) public {
	Dispute storage dis = disp[number];
        require(_msgSender() == dis.respondent);
        dis.response = response;
        dis.responded = true;
        emit Response(number, response);
    }

    
    function issueVerdict(uint256 number, string memory verdict) public {
        Dispute storage dis = disp[number];
        require(dis.responded == true);
        require(judge.balanceOf(_msgSender()) >= 1, "judgeToken balance insufficient");
        require(_msgSender() != dis.complainant || _msgSender() != dis.respondent);
        dis.verdict = verdict;
        dis.resolved = true;
        judgment.transfer(_msgSender(), 100000);
        emit Verdict(number, verdict);
    }
}