pragma solidity ^0.5.0;

contract BlockLengthProvider {
    uint256 private _surveyDurationInBlocks;

    
    constructor(uint256 surveyDurationInBlocks) public {
        _surveyDurationInBlocks = surveyDurationInBlocks;
    }

    function getMinimumBlockNumberForSurvey() public view returns(uint256) {
        return _surveyDurationInBlocks;
    }
}