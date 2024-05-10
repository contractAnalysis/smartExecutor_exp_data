pragma solidity 0.5.2;
pragma experimental ABIEncoderV2;


interface IColony {

  struct Payment {
    address payable recipient;
    bool finalized;
    uint256 fundingPotId;
    uint256 domainId;
    uint256[] skills;
  }

  
  
  
  
  
  
  
  
  
  
  
  function addPayment(
    uint256 _permissionDomainId,
    uint256 _childSkillIndex,
    address payable _recipient,
    address _token,
    uint256 _amount,
    uint256 _domainId,
    uint256 _skillId)
    external returns (uint256 paymentId);

  
  
  
  function getPayment(uint256 _id) external view returns (Payment memory payment);

  
  
  
  
  
  
  
  
  function moveFundsBetweenPots(
    uint256 _permissionDomainId,
    uint256 _fromChildSkillIndex,
    uint256 _toChildSkillIndex,
    uint256 _fromPot,
    uint256 _toPot,
    uint256 _amount,
    address _token
    ) external;

  
  
  
  
  
  function finalizePayment(uint256 _permissionDomainId, uint256 _childSkillIndex, uint256 _id) external;

  
  
  
  
  function claimPayment(uint256 _id, address _token) external;
}


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BountyPayout {

  uint256 constant PERMISSION_DOMAIN_ID = 1;
  uint256 constant CHILD_SKILL_INDEX = 0;
  uint256 constant DOMAIN_ID = 1;
  uint256 constant SKILL_ID = 0;

  address public payerAddr;
  address public colonyAddr;
  address public daiAddr;
  address public leapAddr;

  enum PayoutType { Gardener, Worker, Reviewer }
  event Payout(
    bytes32 indexed bountyId,
    PayoutType indexed payoutType,
    address indexed recipient,
    uint256 amount,
    uint256 paymentId
  );

  constructor(
    address _payerAddr,
    address _colonyAddr,
    address _daiAddr,
    address _leapAddr) public {
    payerAddr = _payerAddr;
    colonyAddr = _colonyAddr;
    daiAddr = _daiAddr;
    leapAddr = _leapAddr;
  }

  modifier onlyPayer() {
    require(msg.sender == payerAddr, "Only payer can call");
    _;
  }

  function _makeColonyPayment(address payable _worker, uint256 _amount) internal returns (uint256) {

    IColony colony = IColony(colonyAddr);
    
    uint256 paymentId = colony.addPayment(
      PERMISSION_DOMAIN_ID,
      CHILD_SKILL_INDEX,
      _worker,
      leapAddr,
      _amount,
      DOMAIN_ID,
      SKILL_ID
    );
    IColony.Payment memory payment = colony.getPayment(paymentId);

    
    colony.moveFundsBetweenPots(
      1, 
      0, 
      CHILD_SKILL_INDEX,
      1, 
      payment.fundingPotId,
      _amount,
      leapAddr
    );
    colony.finalizePayment(PERMISSION_DOMAIN_ID, CHILD_SKILL_INDEX, paymentId);

    
    colony.claimPayment(paymentId, leapAddr);
    return paymentId;
  }

  function _payout(
    address payable _gardenerAddr,
    uint256 _gardenerDaiAmount,
    address payable _workerAddr,
    uint256 _workerDaiAmount,
    address payable _reviewerAddr,
    uint256 _reviewerDaiAmount,
    bytes32 _bountyId
  ) internal  {

    IERC20 dai = IERC20(daiAddr);

    
    uint256 paymentId = _makeColonyPayment(_gardenerAddr, _gardenerDaiAmount);
    dai.transferFrom(payerAddr, _gardenerAddr, _gardenerDaiAmount);
    emit Payout(_bountyId, PayoutType.Gardener, _gardenerAddr, _gardenerDaiAmount, paymentId);

    
    if (_workerDaiAmount > 0) {
      paymentId = _makeColonyPayment(_workerAddr, _workerDaiAmount);
      dai.transferFrom(payerAddr, _workerAddr, _workerDaiAmount);
      emit Payout(_bountyId, PayoutType.Worker, _workerAddr, _workerDaiAmount, paymentId);
    }

    
    if (_reviewerDaiAmount > 0) {
      paymentId = _makeColonyPayment(_reviewerAddr, _reviewerDaiAmount);
      dai.transferFrom(payerAddr, _reviewerAddr, _reviewerDaiAmount);
      emit Payout(_bountyId, PayoutType.Reviewer, _reviewerAddr, _reviewerDaiAmount, paymentId);
    }
  }

 
  function payout(
    address payable _gardenerAddr,
    uint256 _gardenerDaiAmount,
    address payable _workerAddr,
    uint256 _workerDaiAmount,
    address payable _reviewerAddr,
    uint256 _reviewerDaiAmount,
    bytes32 _bountyId
  ) public onlyPayer {
    _payout(
      _gardenerAddr,
      _gardenerDaiAmount,
      _workerAddr,
      _workerDaiAmount,
      _reviewerAddr,
      _reviewerDaiAmount,
      _bountyId
    );
  }

  function payoutNoWorker(
    address payable _gardenerAddr,
    uint256 _gardenerDaiAmount,
    address payable _reviewerAddr,
    uint256 _reviewerDaiAmount,
    bytes32 _bountyId
  ) public onlyPayer {
    _payout(
      _gardenerAddr,
      _gardenerDaiAmount,
      _reviewerAddr,
      0,
      _reviewerAddr,
      _reviewerDaiAmount,
      _bountyId
    );
  }

  function payoutNoReviewer(
    address payable _gardenerAddr,
    uint256 _gardenerDaiAmount,
    address payable _workerAddr,
    uint256 _workerDaiAmount,
    bytes32 _bountyId
  ) public onlyPayer {
    _payout(
      _gardenerAddr,
      _gardenerDaiAmount,
      _workerAddr,
      _workerDaiAmount,
      _workerAddr,
      0,
      _bountyId
    );
  }
}