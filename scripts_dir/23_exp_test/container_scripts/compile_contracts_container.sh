#!/bin/bash

# =========================
# run within a container
#=========================

group_index=$1

csv_data_file_prefix='contracts_info_group'
contract_folder='contracts_solidity'
con_work_dir=$HOME
 

result_folder='contracts_binary'
rm -rf ${result_folder}
mkdir ${result_folder}



exec < ${con_work_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
#read header # read (and ignore) the first line
while IFS="," read solidity_name solc_version contract_name
  do
	 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++"
	 solc-select use ${solc_version}
	 compile ${con_work_dir}${contract_folder}/${solidity_name} ${con_work_dir}${result_folder}/${solidity_name}

  done
