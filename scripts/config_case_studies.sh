#!/bin/bash
# experiment: case studies

dataset_name="case_studies"
export dataset_name


solidity_names=( HoloToken_test_01.sol Crowdsale.sol HoloToken.sol )
solc_versions=(0.4.18 0.4.25 0.4.18 )
contract_names=( HoloToken_test_01 Crowdsale HoloToken )
tool_identifiers=( mythril_tx2 mythril_tx3 mythril_tx4 smartExecutor_v3 smartExecutor ) # identifiers of tools with different versions

export solidity_names contract_names solc_versions tool_identifiers
