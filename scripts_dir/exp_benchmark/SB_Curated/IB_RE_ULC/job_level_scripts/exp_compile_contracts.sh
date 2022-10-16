#!/bin/bash

# =========================
# compile the contracts for each group.
# all groups are in the base_dir direcotry. each group as a folder "contracts" contianing Solidity contracts and a csv file
#=========================

group_name_prefix='contracts_4_group'
csv_data_file_prefix='contracts_info_group'
contract_folder='contracts'
base_dir='/media/sf___share_vms/2022_exp_data_preparation/exp_benchmark/SB/IB_RE_ULC/smartian_data/'

for group_index in {1..26}
do
	work_dir=${base_dir}${group_name_prefix}_${group_index}/
	cd ${work_dir}
	bin_folder='bin'
	rm -rf ${bin_folder}
	mkdir ${bin_folder}

	abi_folder='abi'
	rm -rf ${abi_folder}
	mkdir ${abi_folder}	
	

	exec < ${work_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
	#read header # read (and ignore) the first line
	while IFS="," read solidity_name solc_version contract_name
	  do
		 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++" 	
        		solc use ${solc_version} 
		rm -r ${solidity_name}__${contract_name}
		mkdir ${solidity_name}__${contract_name} 
		cp -r ${solidity_name}__${contract_name} ${bin_folder}
		mv  ${solidity_name}__${contract_name} ${abi_folder}	
	
		solc --bin -o ${work_dir}${bin_folder}/${solidity_name}__${contract_name} ${work_dir}${contract_folder}/${solidity_name}
		solc --abi -o ${work_dir}${abi_folder}/${solidity_name}__${contract_name} ${work_dir}${contract_folder}/${solidity_name}
  	done


done




