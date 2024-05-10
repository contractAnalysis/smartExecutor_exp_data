pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

interface MemoryInterface {
    function getUint(uint id) external returns (uint num);
    function setUint(uint id, uint val) external;
}

interface EventInterface {
    function emitEvent(uint connectorType, uint connectorID, bytes32 eventCode, bytes calldata eventData) external;
}

contract Stores {

  
  function getEthAddr() internal pure returns (address) {
    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; 
  }

  
  function getMemoryAddr() internal pure returns (address) {
    return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; 
  }

  
  function getEventAddr() internal pure returns (address) {
    return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97; 
  }

  
  function getUint(uint getId, uint val) internal returns (uint returnVal) {
    returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
  }

  
  function setUint(uint setId, uint val) virtual internal {
    if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
  }

  
  function emitEvent(bytes32 eventCode, bytes memory eventData) virtual internal {
    (uint model, uint id) = connectorID();
    EventInterface(getEventAddr()).emitEvent(model, id, eventCode, eventData);
  }

  
  function connectorID() public view returns(uint model, uint id) {
    (model, id) = (1, 41);
  }

}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract DSMath {
  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function add(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(x, y);
  }

  function sub(uint x, uint y) internal virtual pure returns (uint z) {
    z = SafeMath.sub(x, y);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.mul(x, y);
  }

  function div(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.div(x, y);
  }

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
  }

}

interface IGauge {
  function claim_rewards() external;
  function deposit(uint256 value) external;
  function withdraw(uint256 value) external;
  function lp_token() external view returns(address token);
  function rewarded_token() external view returns(address token);
  function crv_token() external view returns(address token);
  function balanceOf(address user) external view returns(uint256 amt);
}

interface IMintor{
  function mint(address gauge) external;
}

interface ICurveGaugeMapping {

  struct GaugeData {
    address gaugeAddress;
    bool rewardToken;
  }

  function gaugeMapping(bytes32) external view returns(GaugeData memory);
}

contract GaugeHelper is DSMath, Stores{

  function getCurveGaugeMappingAddr() internal virtual view returns (address){
    return 0x1C800eF1bBfE3b458969226A96c56B92a069Cc92;
  }

  function getCurveMintorAddr() internal virtual view returns (address){
    return 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
  }

  
  function stringToBytes32(string memory str) internal pure returns (bytes32 result) {
    require(bytes(str).length != 0, "string-empty");
    
    assembly {
      result := mload(add(str, 32))
    }
  }
}

contract CurveGaugeEvent is GaugeHelper {
  event LogDeposit(
    string indexed gaugePoolName,
    uint amount,
    uint getId,
    uint setId
  );

  event LogWithdraw(
    string indexed gaugePoolName,
    uint amount,
    uint getId,
    uint setId
  );

  event LogClaimedReward(
    string indexed gaugePoolName,
    uint amount,
    uint rewardAmt,
    uint setId,
    uint setIdReward
  );

  function emitLogWithdraw(string memory gaugePoolName, uint _amt, uint getId, uint setId) internal {
    emit LogWithdraw(gaugePoolName, _amt, getId, setId);
    bytes32 _eventCodeWithdraw = keccak256("LogWithdraw(string,uint256,uint256,uint256)");
    bytes memory _eventParamWithdraw = abi.encode(gaugePoolName, _amt, getId, setId);
    emitEvent(_eventCodeWithdraw, _eventParamWithdraw);
  }

  function emitLogClaimedReward(string memory gaugePoolName, uint crvAmt, uint rewardAmt, uint setIdCrv, uint setIdReward) internal {
    emit LogClaimedReward(gaugePoolName, crvAmt, rewardAmt, setIdCrv, setIdReward);
    bytes32 _eventCode = keccak256("LogClaimedReward(string,uint256,uint256,uint256,uint256)");
    bytes memory _eventParam = abi.encode(gaugePoolName, crvAmt, rewardAmt, setIdCrv, setIdReward);
    emitEvent(_eventCode, _eventParam);
  }
}

contract CurveGauge is CurveGaugeEvent {
  struct Balances{
    uint intialCRVBal;
    uint intialRewardBal;
    uint finalCRVBal;
    uint finalRewardBal;
    uint crvRewardAmt;
    uint rewardAmt;
  }

  
  function deposit(
    string calldata gaugePoolName,
    uint amt,
    uint getId,
    uint setId
  ) external payable {
    uint _amt = getUint(getId, amt);
    ICurveGaugeMapping curveGaugeMapping = ICurveGaugeMapping(getCurveGaugeMappingAddr());
    ICurveGaugeMapping.GaugeData memory curveGaugeData = curveGaugeMapping.gaugeMapping(
        bytes32(stringToBytes32(gaugePoolName)
    ));
    require(curveGaugeData.gaugeAddress != address(0), "wrong-gauge-pool-name");
    IGauge gauge = IGauge(curveGaugeData.gaugeAddress);
    TokenInterface lp_token = TokenInterface(address(gauge.lp_token()));

    _amt = _amt == uint(-1) ? lp_token.balanceOf(address(this)) : _amt;
    lp_token.approve(address(curveGaugeData.gaugeAddress), _amt);

    gauge.deposit(_amt);

    setUint(setId, _amt);

    emit LogDeposit(gaugePoolName, _amt, getId, setId);
    bytes32 _eventCode = keccak256("LogDeposit(string,uint256,uint256,uint256)");
    bytes memory _eventParam = abi.encode(gaugePoolName, _amt, getId, setId);
    emitEvent(_eventCode, _eventParam);
  }

  
  function withdraw(
    string calldata gaugePoolName,
    uint amt,
    uint getId,
    uint setId,
    uint setIdCrv,
    uint setIdReward
  ) external payable {
    uint _amt = getUint(getId, amt);
    ICurveGaugeMapping curveGaugeMapping = ICurveGaugeMapping(getCurveGaugeMappingAddr());
    ICurveGaugeMapping.GaugeData memory curveGaugeData = curveGaugeMapping.gaugeMapping(
      bytes32(stringToBytes32(gaugePoolName))
    );
    require(curveGaugeData.gaugeAddress != address(0), "wrong-gauge-pool-name");
    IGauge gauge = IGauge(curveGaugeData.gaugeAddress);
    TokenInterface crv_token = TokenInterface(address(gauge.crv_token()));
    TokenInterface rewarded_token;
    Balances memory balances;

    _amt = _amt == uint(-1) ? gauge.balanceOf(address(this)) : _amt;
    balances.intialCRVBal = crv_token.balanceOf(address(this));

    if (curveGaugeData.rewardToken) {
      rewarded_token = TokenInterface(address(gauge.rewarded_token()));
      balances.intialRewardBal = rewarded_token.balanceOf(address(this));
    }

    IMintor(getCurveMintorAddr()).mint(curveGaugeData.gaugeAddress);
    gauge.withdraw(_amt);

    balances.finalCRVBal = crv_token.balanceOf(address(this));
    balances.crvRewardAmt = sub(balances.finalCRVBal, balances.intialCRVBal);

    setUint(setId, _amt);
    setUint(setIdCrv, balances.crvRewardAmt);

    if (curveGaugeData.rewardToken) {
      balances.finalRewardBal = rewarded_token.balanceOf(address(this));
      balances.rewardAmt = sub(balances.finalRewardBal, balances.intialRewardBal);
      setUint(setIdReward, balances.rewardAmt);
    }

    emitLogWithdraw(gaugePoolName, _amt, getId, setId);
    emitLogClaimedReward(gaugePoolName, balances.crvRewardAmt, balances.rewardAmt, setIdCrv, setIdReward);
  }

  
  function claimReward(
    string calldata gaugePoolName,
    uint setId,
    uint setIdReward
  ) external payable {
    ICurveGaugeMapping curveGaugeMapping = ICurveGaugeMapping(getCurveGaugeMappingAddr());
    ICurveGaugeMapping.GaugeData memory curveGaugeData = curveGaugeMapping.gaugeMapping(
      bytes32(stringToBytes32(gaugePoolName))
    );
    require(curveGaugeData.gaugeAddress != address(0), "wrong-gauge-pool-name");
    IMintor mintor = IMintor(getCurveMintorAddr());
    IGauge gauge = IGauge(curveGaugeData.gaugeAddress);
    TokenInterface crv_token = TokenInterface(address(gauge.crv_token()));
    TokenInterface rewarded_token;
    Balances memory balances;

    if (curveGaugeData.rewardToken) {
      rewarded_token = TokenInterface(address(gauge.rewarded_token()));
      balances.intialRewardBal = rewarded_token.balanceOf(address(this));
    }

    balances.intialCRVBal = crv_token.balanceOf(address(this));

    mintor.mint(curveGaugeData.gaugeAddress);

    balances.finalCRVBal = crv_token.balanceOf(address(this));
    balances.crvRewardAmt = sub(balances.finalCRVBal, balances.intialCRVBal);

    setUint(setId, balances.crvRewardAmt);

    if(curveGaugeData.rewardToken){
      balances.finalRewardBal = rewarded_token.balanceOf(address(this));
      balances.rewardAmt = sub(balances.finalRewardBal, balances.intialRewardBal);
      setUint(setIdReward, balances.rewardAmt);
    }

    emitLogClaimedReward(gaugePoolName, balances.crvRewardAmt, balances.rewardAmt, setId, setIdReward);
  }
}

contract ConnectCurveGauge is CurveGauge {
  string public name = "Curve-Gauge-v1.0";
}