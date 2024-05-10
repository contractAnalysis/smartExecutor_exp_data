"""
configuration for experiments
"""

#base_dir="C:\\Users\\18178\\PycharmProjects\\smartExecutor_artifact_result_collection\\"
base_dir="/mnt/d/wei_space/24_experiments/smartExecutor_artifact/"
expriments=['24_exp_sGuard','24_impact_of_depth_limit_in_phase1','24_exp_tie_breaking_rules','case_studies']


#=============================
# set parameters for experiment: 24_exp_sGuard
#=============================
parameters_for_24_exp_sGuard={
    "datasets":['sGuard_dataset_in_groups'],
    "tools":["mythril","smartExecutor",'smartian'],
    "data_to_be_collected":{
        "mythril": ['solidity','solc','contract','time','total_states','cov_1','cov_2','cov_3','vulnerability'],
        "smartExecutor": ['solidity','solc','contract','time','total_states','cov_1','cov_2','cov_3','vulnerability','total_runtime_instructions'],
        "smartian":['solidity', 'solc', 'contract', 'time','coverage', 'covered_runtime_instructions', 'vulnerability', 'statistics'],

    },

    'timeouts':[900],
    "times":3,
    "tool_identifiers":{
        'mythril_v0.23.22_bin',
        'smartExecutor_v4.0_bin',
        'smartian',
    }
}

# "tool_identifiers": {
#     'mythril': 'mythril_v0.23.22_bin',
#     "smartExecutor": 'smartExecutor_v4.0_bin',
#     "smartian": 'smartian',
#     "manticore": "manticore"
# }

#=============================
# set parameters for experiment: '24_impact_of_depth_limit_in_phase1'
#=============================
parameters_for_24_impact_of_depth_limit_in_phase1={
    "datasets":["sGuard_200_random10","sGuard_200_random50","sGuard_200_random100"],
    "tools":['smartExecutor'],
    "data_to_be_collected":{
        "smartExecutor": ['solidity', 'solc', 'contract', 'time',
                          'total_states', 'cov_1', 'cov_2', 'cov_3',
                          'vulnerability'],

    },
    "depth_limits":[1,2,3],
    "timeouts":[900],
    "times":3,
    "tool_identifiers":{
        "smartExecutor_v4.0_bin"
    }
}

# #=============================
# # set parameters for experiment: 24_exp_tie_breaking_rules
# #=============================
# parameters_for_24_exp_tie_breaking_rules = {
#     "datasets": ["sGuard_using_tie_breaking_rules"],
#     "tools": ['smartExecutor'],
#     "data_to_be_collected": {
#         "smartExecutor":['solidity','solc','contract','time','total_states','cov_1','cov_2','cov_3','vulnerability'],
#        },
#     "timeouts": [900],
#     "times": 3,
#     "tool_identifiers": {
#         "smartExecutor_v3.0", "smartExecutor_v3.01"
#     }
# }

#=============================
# set parameters for experiment: '24_impact_of_depth_limit_in_phase1'
#=============================


parameters_for_case_studies={

    "dataset_names":["case_studies"],
    "solidity_names":['HoloToken_test_01.sol','Crowdsale.sol','HoloToken.sol'],
    "contract_names":['HoloToken_test_01','Crowdsale','HoloToken'],
    "tools":['smartExecutor'],

    "data_to_be_collected":{
        "smartExecutor": ['solidity', 'solc', 'contract', 'time',
                          'total_states', 'cov_1', 'cov_2', 'cov_3',
                          'vulnerability'],

    },

    "tool_identifiers":['mythril_tx2','mythril_tx3','mythril_tx4','smartExecutor_v3','smartExecutor']
}
