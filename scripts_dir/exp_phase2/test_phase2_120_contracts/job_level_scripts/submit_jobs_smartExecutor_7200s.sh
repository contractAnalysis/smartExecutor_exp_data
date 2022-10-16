#!/bin/bash


group_name_prefix='contracts_4_group' # to form the folder name where all files required for the tool to run within a container

run_script='exp_run_smartExecutor_7200s.sh' # the script running within the container
job_1_container_script='exp_1_container_smartExecutor.sh' # the script to start a container 


base_path='/scratch/06227/qiping/exp_phase2/test_phase2_120_contracts/smartExecutor_data/' # the path where all data required for the experiments are placed

con_work_dir='/home/mythril/' # the work directory  in the container


sif_dir=${base_path}
sif_name='contract_analysis_smartexecutor_1.0_exp.sif'


i=0
 sbatch  -p  normal -n 1 -N 1 -t 8:10:00 -J job_$((i+1))_smartExecutor J30Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name} 

exit



