#!/bin/bash

# =========================
# run within a container
#=========================

group_index=$1

csv_data_file_prefix='sGuard_contracts_info_group'
contract_folder='contracts'
con_work_dir='./'  # current directory

export PATH=/usr/local/bin:$PATH  # necessary for solc-select 

result_folder=mythril_group_${group_index}_results
rm -rf ${result_folder}
mkdir ${result_folder}


exec < ${con_work_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
#read header # read (and ignore) the first line
while IFS="," read solidity_name solc_version contract_name
  do
	 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++" 2>&1 ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt
	
         solc-select use ${solc_version} 2>&1  ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt

	
	start=$(date +%s.%N)
	timeout 120 python3 /opt/iccfwnc/iccfwnc.py ${con_work_dir}${contract_folder}/$solidity_name:${contract_name} 2>&1 ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt
	end=$(date +%s.%N)       
	
	runtime1=$(python -c "print(${end} - ${start})")

	
	echo "time_used: "${runtime1}" seconds"  2>&1 ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt

	echo "#@contract_info_time" 2>&1  ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt  
	echo ${solidity_name}:${solc_version}:${contract_name}:${runtime1} 2>&1  ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt  


  done
