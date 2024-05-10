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
p1_dl=${8}
run_idx=${9}
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
echo p1_dl=$p1_dl
echo run_idx=$run_idx




tool_name=smartExecutor_v4.0
bin_folder="bin_files"


# prepare for the folder to save results
result_folder=${tool_name}_bin_results_${p1_dl}_${tool_timeout}s_${run_idx}
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


echo "save results in ${result_folder}"

# the path where solidity files, binary files, and abi files are held
contract_dir=${con_work_dir}datasets/${dataset_name}/${contract_folder_prefix}_${group_index}/

exec < ${contract_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
#read header # read (and ignore) the first line
while IFS="," read solidity_name solc_version contract_name 
  do
 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++"  | tee -a ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${p1_dl}_${tool_timeout}_${run_idx}.txt
	
	 	
	start=$(date +%s.%N)
	timeout ${cli_timeout} semyth analyze --codefile ${contract_dir}${bin_folder}/${solidity_name}__${contract_name}/${contract_name}.bin  --create-timeout 60 --execution-timeout ${tool_timeout} --solver-timeout ${solver_timeout} --pruning-factor 1.0 -fdg -fss mine --consider-all-reads 0 --preprocess-timeout 100 --execution-times-limit 5 --optimization 1 | tee -a ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${p1_dl}_${tool_timeout}_${run_idx}.txt

	
	end=$(date +%s.%N) 
	runtime1=$(python -c "print(${end} - ${start})")
	
        echo "time_used: "${runtime1}" seconds"  | tee -a ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${p1_dl}_${tool_timeout}_${run_idx}.txt


	echo "#@contract_info_time" | tee -a ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${p1_dl}_${tool_timeout}_${run_idx}.txt
 
	echo ${solidity_name}:${solc_version}:${contract_name}:${runtime1} | tee -a ${result_dir}${solidity_name}__${contract_name}_${tool_name}_${p1_dl}_${tool_timeout}_${run_idx}.txt



  done

