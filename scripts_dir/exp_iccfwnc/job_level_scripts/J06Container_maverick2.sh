#!/bin/bash

# load singularity and start multiple containers

module load tacc-singularity

group_index_start=$1 # determine the group index
group_name_prefix=$2

run_script=$3
job_1_container_script=$4

base_dir=$5
con_work_dir=$6


sif_dir=${base_dir} # 
sif_name=$7


# assignment cpus on numa node 0 (0-7) leave cpus 6,7 free
start=0
end=0
for i in {1..3}
do
 start=$(((i-1)*2))
 end=$(( start+1 ))
 group_index=$((group_index_start+i))
 work_dir=${base_dir}${group_name_prefix}_${group_index}/
 chmod +x ${work_dir}*.sh
 numactl --cpubind=0 --physcpubind=${start}-${end} --membind=0 ${work_dir}${job_1_container_script} ${group_index} ${run_script} ${work_dir} ${con_work_dir} ${sif_dir} ${sif_name} &
done

# assign cpus on nuuma node 1 (8-15)leave cpus 14,15 free
start=0
start=0
end=0
for i in {4..6}
do
 start=$((i*2))
 end=$(( start+1 ))
 group_index=$((group_index_start+i))
 work_dir=${base_dir}${group_name_prefix}_${group_index}/
chmod +x ${work_dir}*.sh 
numactl --cpubind=1 --physcpubind=${start}-${end} --membind=1 ${work_dir}${job_1_container_script} ${group_index} ${run_script} ${work_dir} ${con_work_dir} ${sif_dir} ${sif_name} &
done
wait
exit



