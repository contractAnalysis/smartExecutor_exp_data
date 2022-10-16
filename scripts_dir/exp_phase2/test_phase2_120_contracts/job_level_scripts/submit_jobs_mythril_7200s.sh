#!/bin/bash


group_name_prefix='contracts_4_group'

run_script='exp_run_mythril_7200s.sh'
job_1_container_script='exp_1_container_mythril.sh'

base_path='/scratch/06227/'+Constants.user+'/exp_phase2/test_phase2_120_contracts/mythril_data/'
con_work_dir='/home/mythril/'


sif_dir=${base_path}
sif_name='contract_analysis_smartexecutor_1.0_exp.sif'



i=0
 sbatch  -p  normal -n 1 -N 1 -t 8:10:00 -J job_$((i+1))_mythril J30Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name} $

exit



