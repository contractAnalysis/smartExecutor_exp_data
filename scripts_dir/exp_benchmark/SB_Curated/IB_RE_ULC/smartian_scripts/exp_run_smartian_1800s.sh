#!/bin/bash

# =========================
# run within a container
#=========================

group_index=$1


csv_data_file_prefix='contracts_info_group'
contract_folder='contracts'
con_work_dir='/home/test/tools/Smartian/work_dir/'  # current directory
bin_folder='bin'
abi_folder='abi'

cd ${con_work_dir}
export PATH=/home/test/.local/bin:$PATH  # necessary for solc-select 
export HOME=/home/test/
cd ../
git checkout main
cd ${con_work_dir}

result_folder=smartian_group_${group_index}_results
rm -rf ${result_folder}
mkdir ${result_folder}


exec < ${con_work_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
#read header # read (and ignore) the first line
while IFS="," read solidity_name solc_version contract_name
  do
	 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++" | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt
	
	# prepare for the direcotry for the output
	rm -rf ${solidity_name}__${contract_name}
	mkdir ${solidity_name}__${contract_name}		
	mv  ${solidity_name}__${contract_name} ${result_folder}	

	# the fuzz process
	start=$(date +%s.%N)
	timeout 1900 dotnet ../build/Smartian.dll fuzz -v 0 -p ${con_work_dir}${bin_folder}/${solidity_name}__${contract_name}/${contract_name}.bin -a ${con_work_dir}${abi_folder}/${solidity_name}__${contract_name}/${contract_name}.abi -t 1800 -o ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}/ 

	end=$(date +%s.%N)
	runtime1=$(python -c "print(${end} - ${start})") 

	# the replay process
	dotnet ../build/Smartian.dll replay -p ${con_work_dir}${bin_folder}/${solidity_name}__${contract_name}/${contract_name}.bin -i ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}/testcase | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt	     
	
	# count the number of bugs ( the number of files in bug folder)	
	num=$(ls ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}/bug | wc -l)
	echo "number_of_bugs:"${num} | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt

	
	echo "time_used: "${runtime1}" seconds"  | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt

	echo "#@contract_info_time" | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt  
	echo ${solidity_name}:${solc_version}:${contract_name}:${runtime1}:1900:1800 | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt  


  done
