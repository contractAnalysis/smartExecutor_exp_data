pragma solidity ^0.5.0;

contract SurveyResultValidator {
    function checkSurveyResult(address survey) public view returns(bool) {
        (uint256 accept, uint256 refuse) = IMVDFunctionalityProposal(survey).getVotes();
        
        
        return accept > refuse;
    }
}

interface IMVDFunctionalityProposal {
    function getVotes() external view returns(uint256, uint256);
}