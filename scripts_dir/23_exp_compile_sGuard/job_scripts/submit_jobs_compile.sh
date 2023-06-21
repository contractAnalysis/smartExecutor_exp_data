#!/bin/bash

# submit 1 job which start 30 containers

base_path='/scratch/06227/user_name/23_exp_compile_sGuard/' # replace with the actual user root
group_name_prefix='contracts_167_group'
start_container_script='exp_start_container.sh'


run_script='compile_contracts_container.sh'

con_work_dir='/home/compile/'


sif_dir=${base_path}
sif_name='contract_analysis_compile1.sif' # replace with the actual sif image name





for i in {0..0}
do

# make sure each job have a different name, so that I can distinguish differnt jobs by names
echo 'start job'$i
 sbatch  -p normal -n 1 -N 1 -t 03:00:00 -J job_$((i+1))_compile J30Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${start_container_script} ${base_path} ${con_work_dir} ${sif_name} &

done
