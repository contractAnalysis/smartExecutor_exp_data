#!/bin/bash


group_name_prefix='contracts_12_group'

run_script='exp_run_mythril_900s.sh'
job_1_container_script='exp_1_container_mythril.sh'

base_path='/scratch/06227/qiping/exp_mythril_smartExecutor/mythril_data/'
con_work_dir='/home/mythril/'


sif_dir=${base_path}
sif_name='contract_analysis_mythril_Original_modified.sif'

for i in {0..12}
do
# make sure each job have a different name, so that I can distinguish differnt jobs by names
 sbatch  -p  normal -n 1 -N 1 -t 3:00:00 -J job_$((i+1))_mythril J30Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name}

done

i=13
 sbatch  -p  normal -n 1 -N 1 -t 3:00:00 -J job_$((i+1))_mythril J27Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name} $

exit



