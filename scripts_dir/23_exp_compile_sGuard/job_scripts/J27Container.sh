#!/bin/bash
module load tacc-apptainer

group_index_start=$1 # determine the group index
group_name_prefix=$2

run_script=$3
job_1_container_script=$4

base_dir=$5
con_work_dir=$6


sif_dir=${base_dir} # 
sif_name=$7



start=0
end=0
for i in {1..15}
do
 start=$(((i-1)*4))
 end=$(( start+3 ))
 group_index=$((group_index_start+i))
 work_dir=${base_dir}${group_name_prefix}_${group_index}/
 chmod +x ${work_dir}*.sh
 numactl --cpubind=0 --physcpubind=${start}-${end} --membind=0 ${work_dir}${job_1_container_script} ${group_index} ${run_script} ${work_dir} ${con_work_dir} ${sif_dir} ${sif_name} &
done

start=0
end=0
for i in {16..27}
do
 start=$((i*4))
 end=$(( start+3 ))
 group_index=$((group_index_start+i))
 work_dir=${base_dir}${group_name_prefix}_${group_index}/
chmod +x ${work_dir}*.sh 
numactl --cpubind=1 --physcpubind=${start}-${end} --membind=1 ${work_dir}${job_1_container_script} ${group_index} ${run_script} ${work_dir} ${con_work_dir} ${sif_dir} ${sif_name} &
done
wait
exit



