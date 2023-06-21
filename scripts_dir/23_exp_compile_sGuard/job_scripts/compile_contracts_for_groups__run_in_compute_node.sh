#!/bin/bash


base_path='/scratch/06227/user_name/23_exp_compile_sGuard/'# replace with the actual user root
group_name_prefix='contracts_167_group'


sif_name='contract_analysis_compile1.sif' # replace with the actual sif image name

for i in {1..30}

do

# create the group name
group_name=${group_name_prefix}_$i
echo 'group:' ${group_name}

# prepare the home directory for the group
my_home=${base_path}${group_name}/
echo 'HOME:' ${my_home}

# start a container to run the script to install required solc versions
apptainer exec -H ${my_home} ${base_path}${sif_name} ${my_home}${compile_script} $i

done


