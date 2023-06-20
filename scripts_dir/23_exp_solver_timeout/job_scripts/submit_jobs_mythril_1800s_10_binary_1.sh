#!/bin/bash

# submit 1 job which start 30 containers

base_path='/scratch/06227/qiping/23_exp_solver_timeout/'
group_name_prefix='contracts_5_group'
start_container_script='exp_start_container.sh'


run_script='exp_run_mythril_1800s_10_binary_1.sh'

con_work_dir='/home/mythril/'


sif_dir=${base_path}
sif_name='contract_analysis_mythril_Original_modified.sif'




for i in {0..0} # 1 job
do

# make sure each job have a different name, so that I can distinguish differnt jobs by names
echo 'start job'$i
 sbatch  -p normal -n 1 -N 1 -t 3:00:00 -J j$((i+1))m10 J30Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${start_container_script} ${base_path} ${con_work_dir} ${sif_name} &

done
