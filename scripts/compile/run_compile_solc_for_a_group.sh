#!/bin/bash

# =========================
# compile the contracts for each group.
# all groups are in the base_dir direcotry. each group as a folder "contracts" contianing Solidity contracts and a csv file
#=========================


con_work_dir=$1
dataset_name=$2 # the folder name under the folder "contracts"
group_index=$3

csv_data_file_prefix=$4
contract_folder_prefix=$5




tool_name=compile
cli_timeout=200


solidity_folder="solidity_files"
bin_folder="bin_files"
abi_folder="abi_files"


	# prepare the path to the contract group folder
	contract_dir=${con_work_dir}datasets/${dataset_name}/${contract_folder_prefix}_${group_index}/
	cd ${contract_dir}	
	
	rm -rf ${bin_folder}
	mkdir ${bin_folder}
	
	rm -rf ${abi_folder}
	mkdir ${abi_folder}	

	exec < ${contract_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
	#read header # read (and ignore) the first line
	while IFS="," read solidity_name  solc_version contract_name
	  do
		echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++" 	
        	solc-select use ${solc_version} 
		
		# prepare for folder to hod binary and abi files 
		# (as a contract can have multiple binary files, so a folder is required)
		rm -r ${solidity_name}__${contract_name}
		mkdir ${solidity_name}__${contract_name} 
		cp -r ${solidity_name}__${contract_name} ${bin_folder}
		mv  ${solidity_name}__${contract_name} ${abi_folder}	
	
		timeout ${cli_timeout} solc --bin -o ${contract_dir}${bin_folder}/${solidity_name}__${contract_name} ${contract_dir}${solidity_folder}/${solidity_name}
		timeout ${cli_timeout} solc --abi -o ${contract_dir}${abi_folder}/${solidity_name}__${contract_name} ${contract_dir}${solidity_folder}/${solidity_name}

  	done









