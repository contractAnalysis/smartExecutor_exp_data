#!/bin/bash

# show the jobs submitted as an example

# submit 13 jobs
# each of the first 12 jobs start 6 containers
# the last job starts only one container


group_name_prefix='contracts_5_group'

run_script='exp_run_iccfwnc_200s.sh'
job_1_container_script='exp_1_container_iccfwnc.sh'

base_path='/scratch/06227/qiping/23_exp_150_contracts/'
con_work_dir='/home/iccfwnc/'


sif_dir=${base_path}
sif_name='contract_analysis_iccfwnc.sif'




for i in {0..12}
do
echo ' '
# make sure each job have a different name, so that I can distinguish differnt jobs by names
echo sbatch  -p  normal -n 1 -N 1 -t 3:00:00 -J job_$((i+1))_iccfwnc J06Container_maverick2.sh  $((i*6))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name}

done

echo ' '

i=13
 echo sbatch  -p  normal -n 1 -N 1 -t 3:00:00 -J job_$((i+1))_iccfwnc J01Container_maverick2.sh  $((i*1))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name} $

exit



