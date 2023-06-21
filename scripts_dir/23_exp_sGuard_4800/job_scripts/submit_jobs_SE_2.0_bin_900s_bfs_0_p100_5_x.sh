#!/bin/bash

# submit 16 jobs, each of which starts 30 containers
times_id=$1

base_path='/scratch/06227/user_name/23_exp_sGuard_4800/' # replace with the actual user root
group_name_prefix='contracts_10_group'
start_container_script='exp_start_container1.sh'


run_script='exp_run_SE_2.0_bin_900s_bfs_0_p100_5.sh'

con_work_dir='/home/mythril/'


sif_dir=${base_path}
sif_name='xxx_smartexecutor_2.0_exp.sif' # replace with the actual sif image name



for i in {0..15} # 16 job
do

# make sure each job have a different name, so that I can distinguish differnt jobs by names
echo 'start job'$i
 sbatch  -p normal -n 1 -N 1 -t 3:00:00 -J j$((i+1))s$id J30Container1.sh  $((i*30))  ${group_name_prefix} ${run_script} ${start_container_script} ${base_path} ${con_work_dir} ${sif_name} ${times_id} &

done

