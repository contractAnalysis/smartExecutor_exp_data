pragma solidity ^0.6.1;



abstract contract ERC20Token {
   function transferFrom(address sender, address recipient, uint256 amount) virtual external returns (bool);
   function balanceOf(address owner) virtual external view returns (uint256);
   function approve(address spender, uint256 amount) virtual external returns (bool);
}
contract GiveTogether  {
    address payable public currentCharity;
    address public owner;
    mapping (address => Charity) public charities;
    address payable [] public charityAccts;

    uint256 public currentDate;
    uint256 public sendDonationTime;
    uint256 private oneWeek = 1 weeks;
    uint256 public totalDonation;
    uint256 public rDaiBalance;
    bytes32 private N;

    struct Charity  {
        string name;
        string website;
        bool isCharity;
    }

    
    modifier isOwner() {
        if (msg.sender != owner) revert();
        _;
    }

    
    constructor() public {
        
        owner = msg.sender;

        
        addCharity(0xD3F81260a44A1df7A7269CF66Abd9c7e4f8CdcD1, "Heifer", "https://www.heifer.org/"); 
        addCharity(0xc1D5FD1F0D969075040988e37Df3643Af724995D, "Grace Aid", "https://graceaid.org/");
        addCharity(0x6e4C6ADFA15cADa2699Fd2c16290ea1F71D0f9D7, "Breast Cancer Support (UK)", "https://breastcancersupport.org.uk/");
        addCharity(0x50990F09d4f0cb864b8e046e7edC749dE410916b, "350", "https://350.org/");
        addCharity(0xb189f76323678E094D4996d182A792E52369c005, "EFF", "https://www.eff.org/");
        addCharity(0x998F25Be40241CA5D8F5fCaF3591B5ED06EF3Be7, "Freedom of Press", "https://freedom.press/");
        addCharity(0xE000c5E5E74472B3584427c115712Eb325cf3ff5, "Code for America", "https://www.codeforamerica.org/");
        addCharity(0xEF0050248aE8E5559Bdc6357cc2574fcDF434837, "Fight for the Future", "https://www.fightforthefuture.org/");
        addCharity(0xc7464dbcA260A8faF033460622B23467Df5AEA42, "Give Directly", "https://www.givedirectly.org/");
        addCharity(0x7cF2eBb5Ca55A8bd671A020F8BDbAF07f60F26C1, "Give Well", "https://www.givewell.org/");
        addCharity(0x3ea5f030ade93A8D0400dcbDAC259e7348164fc1, "Index of Censorship", "https://www.indexoncensorship.org/");
        addCharity(0x95a647B3d8a3F11176BAdB799b9499C671fa243a, "Khan Academy", "https://www.khanacademy.org/");
        addCharity(0x19DdD94B94D3c68385c897846AB44Ac99DBFAe0f, "Tor Project", "https://www.torproject.org/");
        addCharity(0x3a9f94DE63612f4A117Adf20F745bd420d148ac1, "UNICEF New Zealand", "https://www.unicef.org.nz/");
        addCharity(0xC94BD2b79921DAa2395EB74934D867346C4C71d4, "Rainforest Trust", "https://www.rainforesttrust.org/");
        addCharity(0xe0c83D05DB000393B22F85432F047167a5d650a8, "FreeCodeCamp", "https://www.freecodecamp.org/");
        addCharity(0x682E9f760C5Be1A954A3e0499c5fb43faf4B86fB, "Develop Africa", "https://www.developafrica.org/");
        addCharity(0x0AAD8B37E1f9a2AA3088c5bd3235bB120F40E8aD, "The Lupus Foundation", "https://www.lupus.org/");	
        addCharity(0x6B0d647Af6c9ff7CE6D507849eAbF649D045623e, "Pathways to Education", "https://www.pathwaystoeducation.ca/donate-ethereum/");
        addCharity(0x0a91BC5990ebB27131FF81E97E7e2339433d1671, "Rainforest Foundation", "https://www.rainforestfoundation.org");

        
        
        sendDonationTime = 1 weeks - 1 hours;
        currentDate = now;
        
        
        N = keccak256(abi.encodePacked(owner, now));
        bytes32 hash = keccak256(abi.encodePacked(N, msg.sender));
        currentCharity = charityAccts[uint(hash) % charityAccts.length];
    }   
    
    
    receive() external payable {
        
        
        if (msg.value > 0) {
            
            totalDonation = totalDonation +  msg.value;
            
            if (!currentCharity.send(address(this).balance)) revert();
        }
        
        
        
        if(now >= currentDate + sendDonationTime) {
           currentDate = now;
           currentCharity = generateNewCharity();
        }
    }


    
    function generateNewCharity() public isOwner returns (address payable) {
        
        N = keccak256(abi.encodePacked(owner, now));
        bytes32 hash = keccak256(abi.encodePacked(N, msg.sender));
        currentCharity = charityAccts[uint(hash) % charityAccts.length];
        if (!charities[currentCharity].isCharity) generateNewCharity();
        return currentCharity;
    }

    
    function withdrawRDAI() public {
        ERC20Token tok = ERC20Token(0x261b45D85cCFeAbb11F022eBa346ee8D1cd488c0);
        rDaiBalance = tok.balanceOf(address(this));
        totalDonation = totalDonation + rDaiBalance;
        require(rDaiBalance > 0);
        tok.approve(address(this), rDaiBalance);
        tok.transferFrom(address(this), currentCharity, rDaiBalance);
        rDaiBalance = tok.balanceOf(address(this));

        
        
        
        if(now >= currentDate + sendDonationTime) {
           currentDate = now;
           currentCharity = generateNewCharity();
        }
    }

    
    function addCharity(address payable _addr, string memory _name, string memory _website) public isOwner {
        if (charities[_addr].isCharity) revert();
        charities[_addr] = Charity(_name, _website, true);
        charityAccts.push(_addr);
    }

    
    function removeCharity(address payable _addr) public isOwner {
       for (uint i = 0; i < charityAccts.length; i++) {
           if (charityAccts[i] == _addr) {
               
               delete charityAccts[i];
           }
       }
    }

    
    function setSendDonationTime(uint256 _time) public isOwner {
        sendDonationTime = _time;
    }


    
    function getCharities(address addr) public view returns (address, string memory, string memory, bool) {
        return (addr, charities[addr].name, charities[addr].website, charities[addr].isCharity);
    }

    
    function getNumCharities() public view returns(uint) {
        return charityAccts.length;
    }
    
    
    function transferOwner(address newOwner) public isOwner {
        require(msg.sender == owner);
        owner = newOwner;
    }

}