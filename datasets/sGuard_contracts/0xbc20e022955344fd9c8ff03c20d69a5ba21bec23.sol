pragma solidity ^0.5.12;

interface IERC20 {
    function balanceOf   (address)                external view returns (uint256);
    function approve     (address, uint256)       external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function transfer    (address, uint256)       external returns (bool);
}

contract GemJoin {
    function join(address, uint) public;
    function exit(address, uint) public;
}

contract CdpManager {
    function open(bytes32, address) external returns (uint);
    function frob(uint, int, int) external;
    function move(uint, address, uint) external;
    function flux(uint, address, uint) external;
    function urns(uint) view external returns (address);
}

contract Vat {
    function hope(address usr) external;
}

contract DirectBTCProxy {

    uint256 constant RAY  = 10 ** 27; 
    uint256 constant NORM = 10 ** 10; 
                                      
                                      

    IERC20 public btc; 
    IERC20 public dai;  

    bytes32    public ilk;
    CdpManager public manager;
    GemJoin    public daiGemJoin;
    GemJoin    public btcGemJoin;
    Vat        public daiVat;

    mapping (address => mapping(address => uint256)) cdpids;

    constructor(
        address _btc,
        address _dai,

        bytes32 _ilk,
        address _manager,
        address _daiGemJoin,
        address _btcGemJoin,
        address _daiVat
    ) public {
        btc = IERC20(_btc);  
        dai  = IERC20(_dai);

        ilk         = _ilk;
        manager     = CdpManager(_manager);
        daiGemJoin  = GemJoin(_daiGemJoin);
        btcGemJoin = GemJoin(_btcGemJoin);
        daiVat      = Vat(_daiVat);

        daiVat.hope(address(daiGemJoin));
        require(btc.approve(_btcGemJoin, uint(-1)), "err: approve BTC token");
        require(dai.approve(_daiGemJoin, uint(-1)), "err approve: dai");
    }

    function borrow(
        address _owner, 
        int     _dink,  
        int     _dart   
    ) external {
        require(_owner != address(this), "err: self-reference");
        require(_dink >= 0, "err: negative dink");
        require(_dart >= 0, "err: negative dart");

        
        uint256 cdpid = cdpids[msg.sender][_owner];
        if (cdpid == 0) {
            cdpid = manager.open(ilk, address(this));
            cdpids[msg.sender][_owner] = cdpid;
        }

        btcGemJoin.join(manager.urns(cdpid), uint(_dink)/NORM);

        manager.frob(cdpid, _dink, _dart);
        manager.move(cdpid, address(this), uint(_dart) * RAY);
        daiGemJoin.exit(_owner, uint(_dart));
    }

    function repay(
        address _owner, 
        int     _dink,  
        int     _dart   
    ) external {
        require(_owner != address(this), "err: self-reference");
        require(_dink >= 0, "err: negative dink");
        require(_dart >= 0, "err: negative dart");

        uint256 cdpid = cdpids[msg.sender][_owner];
        require(cdpid != 0, "err: vault not found");

        
        daiGemJoin.join(manager.urns(cdpid), uint(_dart));

        
        manager.frob(cdpid, -_dink, -_dart);
        manager.flux(cdpid, address(this), uint(_dink));
        btcGemJoin.exit(address(this), uint(_dink)/NORM);

        
        btc.transfer(msg.sender, uint(_dink)/NORM);
    }
}