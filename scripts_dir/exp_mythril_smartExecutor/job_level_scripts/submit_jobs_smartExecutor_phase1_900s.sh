#!/bin/bash


group_name_prefix='contracts_12_group' # to form the folder name where all files required for the tool to run within a container

run_script='exp_run_smartExecutor_phase1_900s.sh' # the script running within the container
job_1_container_script='exp_1_container_smartExecutor.sh' # the script to start a container 


base_path='/scratch/06227/'+Constants.user+'/exp_mythril_smartExecutor/smartExecutor_data/' # the path where all data required for the experiments are placed

con_work_dir='/home/mythril/' # the work directory  in the container


sif_dir=${base_path}
sif_name='contract_analysis_smartexecutor_1.0_exp.sif'

for i in {0..12}
do
# make sure each job have a different name, so that I can distinguish differnt jobs by names
 sbatch  -p  normal -n 1 -N 1 -t 3:00:00 -J job_$((i+1))_smartExecutor J30Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name} &

done

i=13
 sbatch  -p  normal -n 1 -N 1 -t 3:00:00 -J job_$((i+1))_smartExecutor J27Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name} &

exit



