#!/bin/bash

# submit 1 job which start 6 containers


group_name_prefix='contracts_210_group'

run_script='exp_run_iccfwnc_120s.sh'
job_1_container_script='exp_1_container_iccfwnc.sh'

base_path='/scratch/06227/qiping/exp_iccfwnc/iccfwnc_data/'
con_work_dir='/home/iccfwnc/'


sif_dir=${base_path}
sif_name='contract_analysis_iccfwnc.sif'


# make sure each job have a different name, so that I can distinguish differnt jobs by names
echo sbatch  -p  normal -n 1 -N 1 -t 6:00:00 -J job_0_iccfwnc J06Container_maverick2.sh  $((i*6))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name}




