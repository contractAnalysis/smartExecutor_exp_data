#!/bin/bash


group_name_prefix='contracts_4_group'

run_script='exp_run_batin.sh'
job_1_container_script='exp_1_container_batin.sh'

base_path='/scratch/06227/qiping/exp_benchmark/SB_Curated/IB_RE_ULC/batin_data/'
con_work_dir='/home/batin/'


sif_dir=${base_path}
sif_name='contract_analysis_batin_1.0.sif'

for i in {0..0}
do
# make sure each job have a different name, so that I can distinguish differnt jobs by names
 sbatch  -p  normal -n 1 -N 1 -t 0:30:00 -J job_$((i+1))_batin J28Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name}

done

exit



