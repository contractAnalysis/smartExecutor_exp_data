#!/bin/bash


group_name_prefix='contracts_12_group'

run_script='exp_run_mythril_1800s.sh'
job_1_container_script='exp_1_container_mythril.sh'

base_path='/scratch/06227/qiping/exp_mythril_smartExecutor/mythril_data/'
con_work_dir='/home/mythril/'


sif_dir=${base_path}
sif_name='contract_analysis_mythril_Original_modified.sif'


i=0
# make sure each job have a different name, so that I can distinguish differnt jobs by names
./J01Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name}

exit
