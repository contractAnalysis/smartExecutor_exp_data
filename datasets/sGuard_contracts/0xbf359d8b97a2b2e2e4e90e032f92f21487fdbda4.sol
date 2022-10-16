pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


interface TestyInterface {
  event CallSuccess(
    bytes32 actionID,
    bool rolledBack,
    uint256 nonce,
    address to,
    bytes data,
    bytes returnData
  );

  event CallFailure(
    bytes32 actionID,
    uint256 nonce,
    address to,
    bytes data,
    string revertReason
  );

  
  struct Call {
    address to;
    bytes data;
  }

  
  struct CallReturn {
    bool ok;
    bytes returnData;
  }

  function executeAction(
    address to,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData);

  function executeActionWithAtomicBatchCalls(
    Call[] calldata calls,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool[] memory ok, bytes[] memory returnData);
}



contract Testy is TestyInterface {
  function executeAction(
    address to,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData) {
    (ok, returnData) = to.call(data);
    
    
    if (ok) {
      
      
      emit CallSuccess(bytes32("actionID"), false, 1, to, data, returnData);
    } else {
      
      
      emit CallFailure(bytes32("actionID"), 1, to, data, string(returnData));
    }
  }

  function executeActionWithAtomicBatchCalls(
    Call[] memory calls,
    uint256 minimumActionGas,
    bytes memory userSignature,
    bytes memory dharmaSignature
  ) public returns (bool[] memory ok, bytes[] memory returnData) {
    ok = new bool[](calls.length);
    returnData = new bytes[](calls.length);

    
    
    (bool externalOk, bytes memory rawCallResults) = address(this).call(
      abi.encodeWithSelector(
        this._executeActionWithAtomicBatchCallsAtomic.selector, calls
      )
    );

    
    CallReturn[] memory callResults = abi.decode(rawCallResults, (CallReturn[]));
    for (uint256 i = 0; i < callResults.length; i++) {
      Call memory currentCall = calls[i];

      
      ok[i] = callResults[i].ok;
      returnData[i] = callResults[i].returnData;

      
      if (callResults[i].ok) {
        
        emit CallSuccess(
          bytes32("actionID"),
          !externalOk, 
          1,
          currentCall.to,
          currentCall.data,
          callResults[i].returnData
        );
      } else {
        
        
        emit CallFailure(
          bytes32("actionID"),
          1,
          currentCall.to,
          currentCall.data,
          string(callResults[i].returnData)
        );

        
        break;
      }
    }
  }

  function _executeActionWithAtomicBatchCallsAtomic(
    Call[] memory calls
  ) public returns (CallReturn[] memory callResults) {
    bool rollBack = false;
    callResults = new CallReturn[](calls.length);

    for (uint256 i = 0; i < calls.length; i++) {
      
      (bool ok, bytes memory returnData) = calls[i].to.call(calls[i].data);
      callResults[i] = CallReturn({ok: ok, returnData: returnData});
      if (!ok) {
        
        rollBack = true;
        break;
      }
    }

    if (rollBack) {
      
      bytes memory callResultsBytes = abi.encode(callResults);
      assembly { revert(add(32, callResultsBytes), mload(callResultsBytes)) }
    }
  }
}