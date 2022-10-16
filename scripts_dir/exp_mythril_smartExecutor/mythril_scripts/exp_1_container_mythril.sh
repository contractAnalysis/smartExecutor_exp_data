#!/bin/bash

group_index=$1
run_script=$2

work_dir=$3
con_work_dir=$4

sif_dir=$5
sif_name=$6


cd ${work_dir}


singularity exec -H ${work_dir}  --bind ${work_dir}:${con_work_dir} ${sif_dir}${sif_name} ${work_dir}${run_script} ${group_index}




