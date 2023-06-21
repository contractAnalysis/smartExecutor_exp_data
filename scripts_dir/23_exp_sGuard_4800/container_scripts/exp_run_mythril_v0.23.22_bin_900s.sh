#!/bin/bash

# =========================
# run within a container
#=========================

group_index=$1
times_id=$2

csv_data_file_prefix='contracts_info_group'
contract_folder='contracts_binary'
con_work_dir='./'  # current directory

tool_name=MT_v0.23.22_${times_id} # used to create result file name
result_folder=MT_v0.23.22_bin_group_${group_index}_results_${times_id}

rm -rf ${result_folder}
mkdir ${result_folder}


exec < ${con_work_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
#read header # read (and ignore) the first line
while IFS="," read solidity_name solc_version contract_name
  do
	 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++" | tee -a ${con_work_dir}${result_folder}/${solidity_name}_${contract_name}_${tool_name}.txt
	
       #solc-select use ${solc_version} | tee -a ${con_work_dir}${result_folder}/${solidity_name}_${contract_name}_${tool_name}.txt

	
	start=$(date +%s.%N)
	timeout 1000 myth analyze --codefile ${con_work_dir}${contract_folder}/${solidity_name}${contract_name}.bin  --create-timeout 60 --execution-timeout 900 --solver-timeout 10000 --pruning-factor 1.0| tee -a ${con_work_dir}${result_folder}/${solidity_name}_${contract_name}_${tool_name}.txt
	end=$(date +%s.%N)       
	
	runtime1=$(python -c "print(${end} - ${start})")
	
	echo "time_used: "${runtime1}" seconds"  | tee -a ${con_work_dir}${result_folder}/${solidity_name}_${contract_name}_${tool_name}.txt

	echo "#@contract_info_time" | tee -a ${con_work_dir}${result_folder}/${solidity_name}_${contract_name}_${tool_name}.txt  
	
echo ${solidity_name}:${solc_version}:${contract_name}:${runtime1}:1000:60:900 | tee -a ${con_work_dir}${result_folder}/${solidity_name}_${contract_name}_${tool_name}.txt  


  done
