pragma solidity ^0.6.7;

interface JoinLike {
  function vat()          external view returns (address);
  function ilk()          external view returns (bytes32);
  function gem()          external view returns (address);
  function dec()          external view returns (uint256);
  function live()         external view returns (uint256);
}

interface VatLike {
  function wards(address) external view returns (uint256);
  function live()         external view returns (uint256);
}

interface CatLike {
  function vat()          external view returns (address);
  function live()         external view returns (uint256);
  function ilks(bytes32)  external view returns (address, uint256, uint256);
}

interface FlipLike {
  function vat()          external view returns (address);
}

interface SpotLike {
  function live()         external view returns (uint256);
  function vat()          external view returns (address);
  function ilks(bytes32)  external view returns (address, uint256);
}

interface EndLike {
    function vat()        external view returns (address);
    function cat()        external view returns (address);
    function spot()       external view returns (address);
}

interface OptionalTokenLike {
    function name()       external view returns (string memory);
    function symbol()     external view returns (string memory);
}

contract GemInfo {
    function name(address token) external view returns (string memory) {
        return OptionalTokenLike(token).name();
    }

    function symbol(address token) external view returns (string memory) {
        return OptionalTokenLike(token).symbol();
    }
}

contract IlkRegistry {

    event Rely(address usr);
    event Deny(address usr);
    event AddIlk(bytes32 ilk);
    event RemoveIlk(bytes32 ilk);
    event NameError(bytes32 ilk);
    event SymbolError(bytes32 ilk);

    
    mapping (address => uint) public wards;
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    modifier auth {
        require(wards[msg.sender] == 1, "IlkRegistry/not-authorized");
        _;
    }

    VatLike  public vat;
    CatLike  public cat;
    SpotLike public spot;
    GemInfo  private gemInfo;

    struct Ilk {
        uint256 pos;   
        address gem;   
        address pip;   
        address join;  
        address flip;  
        uint256 dec;   
        string name;   
        string symbol; 
    }

    mapping (bytes32 => Ilk) public ilkData;
    bytes32[] ilks;

    
    constructor(address end) public {

        vat = VatLike(EndLike(end).vat());
        cat = CatLike(EndLike(end).cat());
        spot = SpotLike(EndLike(end).spot());

        gemInfo = new GemInfo();

        require(cat.vat() == address(vat), "IlkRegistry/invalid-cat-vat");
        require(spot.vat() == address(vat), "IlkRegistry/invalid-spotter-vat");
        require(vat.wards(address(cat)) == 1, "IlkRegistry/cat-not-authorized");
        require(vat.wards(address(spot)) == 1, "IlkRegistry/spot-not-authorized");
        require(vat.live() == 1, "IlkRegistry/vat-not-live");
        require(cat.live() == 1, "IlkRegistry/cat-not-live");
        require(spot.live() == 1, "IlkRegistry/spot-not-live");
        wards[msg.sender] = 1;
    }

    
    function add(address adapter) external {
        JoinLike join = JoinLike(adapter);

        
        require(join.vat() == address(vat), "IlkRegistry/invalid-join-adapter-vat");
        require(vat.wards(address(join)) == 1, "IlkRegistry/adapter-not-authorized");

        
        bytes32 _ilk = join.ilk();
        require(_ilk != 0, "IlkRegistry/ilk-adapter-invalid");
        require(ilkData[_ilk].join == address(0), "IlkRegistry/ilk-already-exists");

        (address _pip,) = spot.ilks(_ilk);
        require(_pip != address(0), "IlkRegistry/pip-invalid");

        (address _flip,,) = cat.ilks(_ilk);
        require(_flip != address(0), "IlkRegistry/flip-invalid");
        require(FlipLike(_flip).vat() == address(vat), "IlkRegistry/flip-wrong-vat");

        string memory name = bytes32ToStr(_ilk);
        try gemInfo.name(join.gem()) returns (string memory _name) {
            if (bytes(_name).length != 0) {
                name = _name;
            }
        } catch {
            emit NameError(_ilk);
        }

        string memory symbol = bytes32ToStr(_ilk);
        try gemInfo.symbol(join.gem()) returns (string memory _symbol) {
            if (bytes(_symbol).length != 0) {
                symbol = _symbol;
            }
        } catch {
            emit SymbolError(_ilk);
        }

        ilks.push(_ilk);
        ilkData[ilks[ilks.length - 1]] = Ilk(
            ilks.length - 1,
            join.gem(),
            _pip,
            address(join),
            _flip,
            join.dec(),
            name,
            symbol
        );

        emit AddIlk(_ilk);
    }

    
    function remove(bytes32 ilk) external {
        JoinLike join = JoinLike(ilkData[ilk].join);
        require(address(join) != address(0), "IlkRegistry/invalid-ilk");
        require(join.live() == 0, "IlkRegistry/ilk-live");
        _remove(ilk);
        emit RemoveIlk(ilk);
    }

    
    function removeAuth(bytes32 ilk) external auth {
        _remove(ilk);
        emit RemoveIlk(ilk);
    }

    
    function file(bytes32 ilk, bytes32 what, address data) external auth {
        if (what == "gem")       ilkData[ilk].gem  = data;
        else if (what == "pip")  ilkData[ilk].pip  = data;
        else if (what == "join") ilkData[ilk].join = data;
        else if (what == "flip") ilkData[ilk].flip = data;
        else revert("IlkRegistry/file-unrecognized-param-address");
    }

    
    function file(bytes32 ilk, bytes32 what, uint256 data) external auth {
        if (what == "dec")       ilkData[ilk].dec  = data;
        else revert("IlkRegistry/file-unrecognized-param-uint256");
    }

    
    function file(bytes32 ilk, bytes32 what, string calldata data) external auth {
        if (what == "name")        ilkData[ilk].name   = data;
        else if (what == "symbol") ilkData[ilk].symbol = data;
        else revert("IlkRegistry/file-unrecognized-param-string");
    }

    
    
    function _remove(bytes32 ilk) internal {
        
        uint256 _index = ilkData[ilk].pos;
        
        bytes32 _moveIlk = ilks[ilks.length - 1];
        
        ilks[_index] = _moveIlk;
        
        ilkData[_moveIlk].pos = _index;
        
        ilks.pop();
        
        delete ilkData[ilk];
    }

    
    function count() external view returns (uint256) {
        return ilks.length;
    }

    
    function list() external view returns (bytes32[] memory) {
        return ilks;
    }

    
    function list(uint256 start, uint256 end) external view returns (bytes32[] memory) {
        require(start <= end && end < ilks.length, "IlkRegistry/invalid-input");
        bytes32[] memory _ilks = new bytes32[]((end - start) + 1);
        uint256 _count = 0;
        for (uint256 i = start; i <= end; i++) {
            _ilks[_count] = ilks[i];
            _count++;
        }
        return _ilks;
    }

    
    function get(uint256 pos) external view returns (bytes32) {
        require(pos < ilks.length);
        return ilks[pos];
    }

    
    function info(bytes32 ilk) external view returns (
        string memory name,
        string memory symbol,
        uint256 dec,
        address gem,
        address pip,
        address join,
        address flip
    ) {
        return (this.name(ilk), this.symbol(ilk), this.dec(ilk),
        this.gem(ilk), this.pip(ilk), this.join(ilk), this.flip(ilk));
    }

    
    function pos(bytes32 ilk) external view returns (uint256) {
        return ilkData[ilk].pos;
    }

    
    function gem(bytes32 ilk) external view returns (address) {
        return ilkData[ilk].gem;
    }

    
    function pip(bytes32 ilk) external view returns (address) {
        return ilkData[ilk].pip;
    }

    
    function join(bytes32 ilk) external view returns (address) {
        return ilkData[ilk].join;
    }

    
    function flip(bytes32 ilk) external view returns (address) {
        return ilkData[ilk].flip;
    }

    
    function dec(bytes32 ilk) external view returns (uint256) {
        return ilkData[ilk].dec;
    }

    
    function symbol(bytes32 ilk) external view returns (string memory) {
        return ilkData[ilk].symbol;
    }

    
    function name(bytes32 ilk) external view returns (string memory) {
        return ilkData[ilk].name;
    }

    function bytes32ToStr(bytes32 _bytes32) internal pure returns (string memory) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}