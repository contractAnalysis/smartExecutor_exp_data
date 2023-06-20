#!/bin/bash

group_index=$1

csv_data_file_prefix='contracts_info_group'

contract_folder='contracts_binary'

#con_work_dir='/home/mythril/'
con_work_dir='./' # current directory

tool_name=smartExecutor_1.3_10

result_folder=smartExecutor_binary_group_${group_index}_results_bfs_1
rm -rf ${result_folder}
mkdir ${result_folder}


exec < ${con_work_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
#read header # read (and ignore) the first line
while IFS="," read solidity_name solc_version contract_name
  do
 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++"  | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}_${tool_name}.txt
	
	 	
	start=$(date +%s.%N)
	 timeout 1900 myth analyze --codefile ${con_work_dir}${contract_folder}/${solidity_name}${contract_name}.bin  --create-timeout 60 --execution-timeout 1800 -fdg -fss bfs --solver-timeout 10000  | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}_${tool_name}.txt
	
	end=$(date +%s.%N) 
	runtime1=$(python -c "print(${end} - ${start})")
	
        echo "time_used: "${runtime1}" seconds"  | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}_${tool_name}.txt

	echo "#@contract_info_time" | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}_${tool_name}.txt  
	echo ${solidity_name}:${solc_version}:${contract_name}:${runtime1}:1900:60:1800 | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}_${tool_name}.txt  


  done

