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





library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

        
    function mul(int256 a, int256 b) internal pure returns (int256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}








interface IModule {
    
    function removeModule() external;
}












library PreciseUnitMath {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    
    uint256 constant internal PRECISE_UNIT = 10 ** 18;
    int256 constant internal PRECISE_UNIT_INT = 10 ** 18;

    
    uint256 constant internal MAX_UINT_256 = type(uint256).max;
    
    int256 constant internal MAX_INT_256 = type(int256).max;
    int256 constant internal MIN_INT_256 = type(int256).min;

    
    function preciseUnit() internal pure returns (uint256) {
        return PRECISE_UNIT;
    }

    
    function preciseUnitInt() internal pure returns (int256) {
        return PRECISE_UNIT_INT;
    }

    
    function maxUint256() internal pure returns (uint256) {
        return MAX_UINT_256;
    }

    
    function maxInt256() internal pure returns (int256) {
        return MAX_INT_256;
    }

    
    function minInt256() internal pure returns (int256) {
        return MIN_INT_256;
    }

    
    function preciseMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(b).div(PRECISE_UNIT);
    }

    
    function preciseMul(int256 a, int256 b) internal pure returns (int256) {
        return a.mul(b).div(PRECISE_UNIT_INT);
    }

    
    function preciseMulCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        return a.mul(b).sub(1).div(PRECISE_UNIT).add(1);
    }

    
    function preciseMulCeil(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0 || b == 0) {
            return 0;
        }

        if ( a > 0 && b > 0 || a < 0 && b < 0) {
            return a.mul(b).sub(1).div(PRECISE_UNIT_INT).add(1);
        } else {
            return a.mul(b).add(1).div(PRECISE_UNIT_INT).sub(1);
        }
    }

    
    function preciseDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(PRECISE_UNIT).div(b);
    }


    
    function preciseDiv(int256 a, int256 b) internal pure returns (int256) {
        return a.mul(PRECISE_UNIT_INT).div(b);
    }

    
    function preciseDivCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(!(a == 0 && b == 0), "Must both not be 0");

        return a > 0 ? a.mul(PRECISE_UNIT).sub(1).div(b).add(1) : 0;
    }

    
    function preciseDivCeil(int256 a, int256 b) internal pure returns (int256) {
        require(!(a == 0 && b == 0), "Must both not be 0");

        if (a == 0 || b == 0) {
            return 0;
        }

        if ( a > 0 && b > 0 || a < 0 && b < 0) {
            return a.mul(PRECISE_UNIT_INT).sub(1).div(b).add(1);
        } else {
            return a.mul(PRECISE_UNIT_INT).add(1).div(b).sub(1);
        }
    }

    
    function conservativePreciseMul(int256 a, int256 b) internal pure returns (int256) {
        if ( a > 0 && b > 0 || a < 0 && b < 0) {
            return preciseMul(a, b);
        } else {
            return preciseMulCeil(a, b);
        }
    }

    
    function conservativePreciseDiv(int256 a, int256 b) internal pure returns (int256) {
        if ( a > 0 && b > 0 || a < 0 && b < 0) {
            return preciseDiv(a, b);
        } else {
            return preciseDivCeil(a, b);
        }
    }
}















library PositionLib {
    using SafeCast for uint256;
    using SafeMath for uint256;
    using SafeCast for int256;
    using SignedSafeMath for int256;
    using PreciseUnitMath for uint256;

    

    
    uint8 internal constant DEFAULT = 0;
    uint8 internal constant EXTERNAL = 1;

    

    
    struct PositionData {
        uint256 index;
        ISetToken.Position position;
    }

    

    
    function editDefaultPosition(ISetToken _setToken, address _component, uint256 _newUnit) internal {
        PositionData memory positionSearchResults = findDefaultPosition(_setToken, _component);
        bool positionIsFound = positionSearchResults.index != uint256(-1);

        if (!positionIsFound) {
            
            _setToken.pushPosition(
                createDefaultPosition(_component, _newUnit.toInt256())
            );
        } else if (positionIsFound && _newUnit == 0) {
            removePosition(_setToken, positionSearchResults.index);
        } else {
            
            _setToken.editPositionUnit(
                positionSearchResults.index,
                _newUnit.toInt256()
            );
        }
    }

    
    function removePosition(ISetToken _setToken, uint256 _index) internal {
        ISetToken.Position[] memory positions = _setToken.getPositions();
        require(positions.length > _index, "Index out of range.");

        if (positions.length.sub(1) != _index) {
            _setToken.editPosition(_index, positions[positions.length.sub(1)]);
        }
        _setToken.popPosition();
    }


    
    function findDefaultPosition(ISetToken _setToken, address _component) internal view returns (PositionData memory) {
        return findPosition(_setToken, _component, address(0), DEFAULT, "");
    }

    /**
     * Find a Position that matches the four specified fields: component, module, state, and data.
     *
     * @param _setToken         Address of SetToken being modified
     * @param _component        Address of component
     * @param _module           Address of module associated with position
     * @param _state            State of position being sought (in uint8)
     * @param _data             Arbitrary data of position being sought, seeking module needs to know structure of the
     *                          arbitrary data
     * @return                  Position struct matching defined parameters
     */
    function findPosition(
        ISetToken _setToken,
        address _component,
        address _module,
        uint8 _state,
        bytes memory _data
    )
        internal
        view
        returns (PositionData memory)
    {
        ISetToken.Position[] memory positions = _setToken.getPositions();

        for (uint256 i = 0; i < positions.length; i++) {
            if (
                positions[i].component == _component &&
                positions[i].positionState == _state &&
                positions[i].module == _module &&
                keccak256(positions[i].data) == keccak256(_data)
            ) {
                return PositionData({index: i, position: positions[i]});
            }
        }

        // If no position found, return empty position and index equal to maxUint value
        return PositionData({index: uint256(-1), position: createDefaultPosition(_component, 0)});
    }

    /**
     * Generates a Position in DEFAULT Position state of "component" and "unit"
     */
    function createDefaultPosition(
        address _component,
        int256 _unit
    )
        internal
        pure
        returns(ISetToken.Position memory)
    {
        require(_component != address(0), "Position must have non-zero address.");
        require(_unit >= 0, "Default positions must have positive unit values.");

        return ISetToken.Position({
            component: _component,
            module: address(0),
            unit: _unit,
            positionState: DEFAULT,
            data: ""
        });
    }

    /**
     * Returns whether the Position is in DEFAULT positionState.
     */
    function isPositionDefault(ISetToken.Position memory _position) internal pure returns(bool) {
        return _position.positionState == DEFAULT;
    }

    /**
     * Get total notional amount of Default position
     *
     * @param _setTokenSupply     Supply of SetToken in precise units (10^18)
     * @param _positionUnit       Quantity of Position units
     *
     * @return                    Total notional amount of units
     */
    function getDefaultTotalNotional(uint256 _setTokenSupply, uint256 _positionUnit) internal pure returns (uint256) {
        return _setTokenSupply.preciseMul(_positionUnit);
    }

    /**
     * Get position unit from total notional amount
     *
     * @param _setTokenSupply     Supply of SetToken in precise units (10^18)
     * @param _totalNotional      Total notional amount of component prior to
     */
    function getDefaultPositionUnit(uint256 _setTokenSupply, uint256 _totalNotional) internal pure returns (uint256) {
        return _totalNotional.preciseDiv(_setTokenSupply);
    }

    /**
     * Calculate the new position unit given total notional values pre and post executing an action that changes SetToken state
     *
     * @param _setTokenSupply     Supply of SetToken in precise units (10^18)
     * @param _preTotalNotional   Total notional amount of component prior to executing action
     * @param _postTotalNotional  Total notional amount of component after the executing action
     * @param _prePositionUnit    Position unit of SetToken prior to executing action
     */
    function calculateDefaultEditPositionUnit(
        uint256 _setTokenSupply,
        uint256 _preTotalNotional,
        uint256 _postTotalNotional,
        uint256 _prePositionUnit
    )
        internal
        pure
        returns (uint256)
    {
        // If pre action total notional amount is greater then subtract post action total notional and calculate new position units
        if (_preTotalNotional >= _postTotalNotional) {
            uint256 unitsToSub = _preTotalNotional.sub(_postTotalNotional).preciseDivCeil(_setTokenSupply);
            return _prePositionUnit.sub(unitsToSub);
        } else {
            // Else subtract post action total notional from pre action total notional and calculate new position units
            uint256 unitsToAdd = _postTotalNotional.sub(_preTotalNotional).preciseDiv(_setTokenSupply);
            return _prePositionUnit.add(unitsToAdd);
        }
    }
}

// Dependency file: contracts/protocol/lib/ModuleBase.sol

/*
    Copyright 2020 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http:

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


*/








abstract contract ModuleBase is IModule {

    

    
    IController public controller;

    

    modifier onlySetManager(ISetToken _setToken, address _caller) {
        require(isSetManager(_setToken, _caller), "Must be the SetToken manager");
        _;
    }

    modifier onlyValidAndInitializedSet(ISetToken _setToken) {
        require(isSetValidAndInitialized(_setToken), "Must be a valid and initialized SetToken");
        _;
    }

    
    modifier onlyValidInitialization(ISetToken _setToken) {
        require(controller.isSet(address(_setToken)), "Must be controller-enabled SetToken");
        require(isSetPendingInitialization(_setToken), "Must be pending initialization");        
        _;
    }

    

    
    constructor(IController _controller) public {
        controller = _controller;
    }

    

    
    function isSetPendingInitialization(ISetToken _setToken) internal view returns(bool) {
        return _setToken.isPendingModule(address(this));
    }

    
    function isSetManager(ISetToken _setToken, address _toCheck) internal view returns(bool) {
        return _setToken.manager() == _toCheck;
    }

    
    function isSetValidAndInitialized(ISetToken _setToken) internal view returns(bool) {
        return controller.isSet(address(_setToken)) &&
            _setToken.isModule(address(this));
    }
}










interface ISetToken is IERC20 {

    

    enum ModuleState {
        NONE,
        PENDING,
        INITIALIZED
    }

    
    
    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    

    function invoke(address _target, uint256 _value, bytes calldata _data) external returns(bytes memory);

    function pushPosition(Position memory _position) external;
    function popPosition() external;
    function editPosition(uint256 _index, Position memory _position) external;
    function batchEditPositions(uint256[] memory _indices, ISetToken.Position[] memory _positions) external;

    function editPositionMultiplier(int256 _newMultiplier) external;
    function editPositionUnit(uint256 _index, int256 _newUnit) external;
    function batchEditPositionUnits(uint256[] memory _indices, int256[] memory _newUnits) external;

    function mint(address _account, uint256 _quantity) external;
    function burn(address _account, uint256 _quantity) external;

    function lock() external;
    function unlock() external;

    function addModule(address _module) external;
    function removeModule(address _module) external;
    function initializeModule() external;

    function setManager(address _manager) external;

    function manager() external view returns (address);
    function moduleStates(address _module) external view returns (ModuleState);
    function getModules() external view returns (address[] memory);
    
    function positionMultiplier() external view returns (int256);
    function getPositions() external view returns (Position[] memory);
    function positions(uint256 _index) external view returns (ISetToken.Position memory);
    function getPositionsArray()
        external
        view
        returns (address[] memory, address[] memory, int256[] memory, uint8[] memory, bytes[] memory);

    function isModule(address _module) external view returns(bool);
    function isPendingModule(address _module) external view returns(bool);
    function isLocked() external view returns (bool);
}












library InvokeLib {
    using SafeMath for uint256;

    

    
    function invokeApprove(
        ISetToken _setToken,
        address _token,
        address _spender,
        uint256 _quantity
    )
        internal
    {
        bytes memory callData = abi.encodeWithSignature("approve(address,uint256)", _spender, _quantity);
        _setToken.invoke(_token, 0, callData);
    }

    
    function invokeTransfer(
        ISetToken _setToken,
        address _token,
        address _to,
        uint256 _quantity
    )
        internal
    {
        if (_quantity > 0) {
            bytes memory callData = abi.encodeWithSignature("transfer(address,uint256)", _to, _quantity);
            _setToken.invoke(_token, 0, callData);
        }
    }

    
    function strictInvokeTransfer(
        ISetToken _setToken,
        address _token,
        address _to,
        uint256 _quantity
    )
        internal
    {
        if (_quantity > 0) {
            
            uint256 existingBalance = IERC20(_token).balanceOf(address(_setToken));

            InvokeLib.invokeTransfer(_setToken, _token, _to, _quantity);

            
            uint256 newBalance = IERC20(_token).balanceOf(address(_setToken));

            
            require(
                newBalance == existingBalance.sub(_quantity),
                "Invalid post transfer balance"
            );
        }
    }
}







interface IManagerIssuanceHook {
    function invokePreIssueHook(ISetToken _setToken, uint256 _issueQuantity, address _sender, address _to) external;
}





interface IController {
    function addSet(address _setToken) external;
    function getModuleFee(address _module, uint256 _feeType) external view returns(uint256);
    function feeRecipient() external view returns(address);
    function isModule(address _module) external view returns(bool);
    function isSet(address _setToken) external view returns(bool);
    function isSystemContract(address _contractAddress) external view returns (bool);
    function transferFrom(address _token, address _from, address _to, uint256 _quantity) external;
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









library SafeCast {

    
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}













contract ReentrancyGuard {
    
    
    
    
    

    
    
    
    
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    
    modifier nonReentrant() {
        
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        
        _status = _ENTERED;

        _;

        
        
        _status = _NOT_ENTERED;
    }
}



pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";















contract BasicIssuanceModule is ModuleBase, ReentrancyGuard {
    using InvokeLib for ISetToken;
    using PositionLib for ISetToken.Position;
    using PreciseUnitMath for uint256;
    using SafeMath for uint256;
    using SafeCast for int256;

    

    event SetTokenIssued(address indexed _setToken, address _issuer, address _to, address _hookContract, uint256 _quantity);
    event SetTokenRedeemed(address indexed _setToken, address _redeemer, uint256 _quantity);

    

    
    mapping(ISetToken => IManagerIssuanceHook) public managerIssuanceHook;

    

    
    constructor(IController _controller) public ModuleBase(_controller) {}

    

    
    function issue(
        ISetToken _setToken,
        uint256 _quantity,
        address _to
    ) 
        external
        nonReentrant
        onlyValidAndInitializedSet(_setToken)
    {
        require(_quantity > 0, "Issue quantity must be > 0");

        _callPreIssueHooks(_setToken, _quantity, msg.sender, _to);

        (
            address[] memory components,
            uint256[] memory componentQuantities
        ) = getRequiredComponentUnitsForIssue(_setToken, _quantity);

        
        for (uint256 i = 0; i < components.length; i++) {
            
            controller.transferFrom(
                components[i],
                msg.sender,
                address(_setToken),
                componentQuantities[i]
            );
        }

        
        _setToken.mint(_to, _quantity);

        emit SetTokenIssued(address(_setToken), msg.sender, _to, address(0), _quantity);
    }

    
    function redeem(
        ISetToken _setToken,
        uint256 _quantity
    )
        external
        nonReentrant
        onlyValidAndInitializedSet(_setToken)
    {
        require(_quantity > 0, "Redeem quantity must be > 0");

        
        _setToken.burn(msg.sender, _quantity);

        
        ISetToken.Position[] memory positions = _setToken.getPositions();
        for (uint256 i = 0; i < positions.length; i++) {
            ISetToken.Position memory currentPosition = positions[i];

            require(currentPosition.isPositionDefault(), "Only default positions are supported");

            uint256 unit = currentPosition.unit.toUint256();

            
            uint256 componentQuantity = _quantity.preciseMul(unit);

            
            _setToken.strictInvokeTransfer(
                currentPosition.component,
                msg.sender,
                componentQuantity
            );
        }

        emit SetTokenRedeemed(address(_setToken), msg.sender, _quantity);
    }

    
    function initialize(
        ISetToken _setToken,
        IManagerIssuanceHook _preIssueHook
    )
        external
        onlySetManager(_setToken, msg.sender)
        onlyValidInitialization(_setToken)
    {
        managerIssuanceHook[_setToken] = _preIssueHook;

        _setToken.initializeModule();
    }

    
    function removeModule() external override {
        revert("The BasicIssuanceModule module cannot be removed");
    }

    

    
    function getRequiredComponentUnitsForIssue(
        ISetToken _setToken,
        uint256 _quantity
    )
        public
        view
        onlyValidAndInitializedSet(_setToken)
        returns (address[] memory, uint256[] memory)
    {
        ISetToken.Position[] memory positions = _setToken.getPositions();

        address[] memory components = new address[](positions.length);
        uint256[] memory notionalUnits = new uint256[](positions.length);

        for (uint256 i = 0; i < positions.length; i++) {
            ISetToken.Position memory currentPosition = positions[i];

            require(currentPosition.isPositionDefault(), "Only default positions are supported");

            components[i] = currentPosition.component;
            notionalUnits[i] = getTotalNotionalIssueQuantity(currentPosition, _quantity);
        }

        return (components, notionalUnits);
    }

    

    
    function _callPreIssueHooks(ISetToken _setToken, uint256 _quantity, address _caller, address _to) internal {
        IManagerIssuanceHook preIssueHook = managerIssuanceHook[_setToken];
        if (address(preIssueHook) != address(0)) {
            preIssueHook.invokePreIssueHook(_setToken, _quantity, _caller, _to);
        }
    }

    
    function getTotalNotionalIssueQuantity(
        ISetToken.Position memory _position,
        uint256 _issueQuantity
    ) 
        internal
        pure
        returns(uint256)
    {
        return _position.unit.toUint256().preciseMulCeil(_issueQuantity);
    }
}