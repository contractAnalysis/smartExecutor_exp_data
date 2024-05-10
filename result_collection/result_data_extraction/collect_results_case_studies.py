"""
collect the data for case studies
"""

result_dir="C:\\Users\\18178\\PycharmProjects\\smartExecutor_artifact_result_collection\\results\\"
solidity_names=['HoloToken_test_01.sol','Crowdsale.sol','HoloToken.sol']
contract_names=['HoloToken_test_01','Crowdsale','HoloToken']
tool_identifers=['mythril_tx2','mythril_tx3','mythril_tx4','smartExecutor_v3','smartExecutor']

for tool_name in tool_identifers:
    for solidity_name, contract_name in zip(solidity_names,contract_names):
        result_file_name=f'{solidity_name}__{contract_name}_{tool_name}.txt'
