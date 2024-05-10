#!/bin/bash

# =========================
# run within a container
#=========================

echo ""
echo ==== inside the container =====

con_work_dir=${1}
dataset_name=${2} # the folder name under the folder "contracts"
group_index=${3}

csv_data_file_prefix=${4}
contract_folder_prefix=${5}

cli_timeout=${6}
tool_timeout=${7}

run_idx=${8}
solver_timeout=10000 # default timeout for this version of SmartExecutor

echo received the parameters and their values
echo con_work_dir=$con_work_dir
echo dataset_name=$dataset_name # the folder name under the folder "contracts"
echo group_index=$group_index

echo csv_data_file_prefix=$csv_data_file_prefix
echo contract_folder_prefix=$contract_folder_prefix

echo cli_timeout=$cli_timeout
echo tool_timeout=$tool_timeout
echo solver_timeout=10000 # default timeout for this version of SmartExecutor
echo run_idx=$run_idx




smartian_work_dir='/home/smartian/Smartian/work_dir/'
tool_name=smartian
bin_folder="bin_files"
abi_folder='abi_files'


# prepare for the folder to save results
result_folder=${tool_name}_results_${tool_timeout}s_${run_idx}
result_dir=${con_work_dir}results/

cd ${result_dir}

if [ ! -d ${dataset_name} ]; then
  mkdir ${dataset_name}
fi

cd ${dataset_name}

if [ -d ${result_folder} ]; then
	rm -rf ${result_folder} 
fi
mkdir ${result_folder}

# update result_dir where the result data will be held
result_dir=${con_work_dir}results/${dataset_name}/${result_folder}/

# the path where solidity files, binary files, and abi files are held
contract_dir=${con_work_dir}datasets/${dataset_name}/${contract_folder_prefix}_${group_index}/


exec < ${contract_dir}${csv_data_file_prefix}_${group_index}.csv  || exit 1
#read header # read (and ignore) the first line
while IFS="," read solidity_name solc_version contract_name
  do

	# prepare for the direcotry for bug and testcase data
	cd ${result_dir}	
	touch ${solidity_name}__${contract_name}_${tool_name}_${tool_timeout}_${run_idx}.txt
	mkdir ${solidity_name}__${contract_name}
	cd ${solidity_name}__${contract_name}
	mkdir bug
	mkdir testcase
 	
	 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++" >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${tool_timeout}_${run_idx}.txt 2>&1
	
		
	
	start=$(date +%s.%N)

	# the fuzz process
	cd ${con_work_dir}	
	timeout ${cli_timeout} dotnet ../build/Smartian.dll fuzz -v 0 -p  ${contract_dir}${bin_folder}/${solidity_name}__${contract_name}/${contract_name}.bin -a  ${contract_dir}${abi_folder}/${solidity_name}__${contract_name}/${contract_name}.abi -t ${tool_timeout} -o ${result_dir}${solidity_name}__${contract_name}/ >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${tool_timeout}_${run_idx}.txt 2>&1


	end=$(date +%s.%N)
	runtime1=$(python -c "print(${end} - ${start})") 

	# the replay process
	dotnet ../build/Smartian.dll replay -p  ${contract_dir}/${bin_folder}/${solidity_name}__${contract_name}/${contract_name}.bin -i ${result_dir}${solidity_name}__${contract_name}/testcase >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${tool_timeout}_${run_idx}.txt 2>&1
	
	
	# count the number of bugs ( the number of files in bug folder)	
	num=$(ls ${result_dir}${solidity_name}__${contract_name}/bug | wc -l)
	echo "number_of_bugs:"${num} >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${tool_timeout}_${run_idx}.txt 2>&1

	
	echo "time_used: "${runtime1}" seconds" >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${tool_timeout}_${run_idx}.txt 2>&1

	echo "#@contract_info_time" >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${tool_timeout}_${run_idx}.txt 2>&1
	echo ${solidity_name}:${solc_version}:${contract_name}:${runtime1} >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${tool_timeout}_${run_idx}.txt 2>&1


  done
