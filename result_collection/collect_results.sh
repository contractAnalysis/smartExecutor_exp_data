#!/bin/bash

source ./scripts/config_global.sh
root_dir=${base_dir} 


export PYTHONPATH=${root_dir}result_collection/:$PYTHONPATH
# require pandas
# pip3 install pandas

python3 ${root_dir}result_collection/cli.py --experiment case_studies
python3 ${root_dir}result_collection/cli.py --experiment 24_exp_sGuard
python3 ${root_dir}result_collection/cli.py --experiment 24_impact_of_depth_limit_in_phase1








