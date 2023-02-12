#!/bin/bash

base_path='/scratch/06227/qiping/23_exp_test/exp_01/contract_groups/'
group_name_prefix='contracts_4_group'
start_container_script='exp_start_container.sh'


run_script='exp_run_mythril_3600s_binary.sh'

con_work_dir='/home/mythril/'


sif_dir=${base_path}
sif_name='contract_analysis_mythril_Original_modified.sif'

echo 'before starting containers'

i=0
# make sure each job have a different name, so that I can distinguish differnt jobs by names
./J30Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${start_container_script} ${base_path} ${con_work_dir} ${sif_name}

echo 'exit'
exit
