#!/bin/bash

base_path='/scratch/06227/qiping/23_exp_test/exp_01/contract_groups/'
group_name_prefix='contracts_4_group'


sif_name='contract_analysis_compile.sif' # any sif file that has installed solc-select
install_solc_script='install_solc_container.sh'

for i in {1..30} #30 containers

do

# create the group name
group_name=${group_name_prefix}_$i
echo 'group:' ${group_name}

# prepare the home directory for the group
my_home=${base_path}${group_name}/
echo 'HOME:' ${my_home}

# start a container to run the script to install required solc versions
singularity exec -H ${my_home} ${base_path}${sif_name} ${my_home}${install_solc_script}

done


