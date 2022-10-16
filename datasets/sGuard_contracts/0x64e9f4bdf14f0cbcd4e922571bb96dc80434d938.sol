pragma solidity ^0.5.12;


contract electionList{
	string public hashHead = "2019localelection";
	address payable public owner;
    
    
	string[] public councilList = ["中環","半山東","衛城","山頂","大學","觀龍","堅摩","西環",
	"寶翠","石塘咀","西營盤","上環","東華","正街","水街"
	];
	uint256 public councilNumber;
	
	mapping(string => string[]) public cadidateList;
	mapping(string => uint256) public candidateNumber;
	
	
	
	
	
	constructor() public{
	    owner = msg.sender;
	    councilNumber = councilList.length;
	    
	    cadidateList["中環"] = ["許智峯","黃鐘蔚"];
	    cadidateList["半山東"] = ["莫淦森","吳兆康"];
	    cadidateList["衛城"] = ["鄭麗琼","馮家亮"];
	    cadidateList["山頂"] = ["賣間囯信","楊哲安"];
	    cadidateList["大學"] = ["歐頌賢","任嘉兒"];
	    cadidateList["觀龍"] = ["楊開永","周世傑","梁晃維"];
	    cadidateList["堅摩"] = ["黃健菁","林雪迎","陳學鋒"];
	    cadidateList["西環"] = ["張國鈞","黃美𡖖","彭家浩"];
	    cadidateList["寶翠"] = ["楊浩然","馮敬彥","葉永成"];
	    cadidateList["石塘咀"] = ["陳財喜","葉錦龍"];
	    cadidateList["西營盤"] = ["黃永志","劉天正"];
	    cadidateList["上環"] = ["呂鴻賓","甘乃威"];
	    cadidateList["東華"] = ["張嘉恩","伍凱欣"];
	    cadidateList["正街"] = ["張啟昕","李志恒"];
	    cadidateList["水街"] = ["楊學明","何致宏"];
	    
	    for(uint i=0;i<councilNumber;i++){
	        candidateNumber[councilList[i]] = cadidateList[councilList[i]].length;
		}
	}
}