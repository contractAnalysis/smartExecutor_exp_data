#!/bin/bash

source ./scripts/config_global.sh
source ./scripts/config_case_studies.sh


root_dir=${base_dir}
dataset_name=${dataset_name}

mythril_image=${image_mythril}
smartExecutor_image=${image_smartExecutor}
smartExecutor_start_image=${image_smartExecutor_v3}


solidity_names=${solidity_names}
solc_versions=${solc_versions}
contract_names=${contract_names}
tool_identifiers=${tool_identifiers}


# prepare for the directory to hold results
result_dir=${root_dir}results/
cd ${result_dir}

if [ ! -d ${dataset_name} ]; then
  mkdir ${dataset_name}
fi


result_dir=${result_dir}${dataset_name}/
cd ${result_dir}

contract_dir=${root_dir}datasets/${dataset_name}


# Check if the arrays have the same length
if [ ${#solidity_names[@]} -ne ${#contract_names[@]} ]; then
    echo "Error: Arrays have different lengths."
    exit 1
fi


cd  ${root_dir}${dataset_name}/

# Iterate over the indices of array1
for ((i = 0; i < ${#solidity_names[@]}; i++)); do
    
    solidity_name=${solidity_names[i]}
    solc_version=${solc_versions[i]}
    contract_name=${contract_names[i]}
    echo "==== $solidity_name : $contract_name ====="
    

    for tool_name in ${tool_identifiers[@]}
    do	
  
	echo save the result to ${result_dir}${solidity_name}__${contract_name}_${tool_name}.txt
	
	start=$(date +%s.%N)

	if [ "$tool_name" = "mythril_tx2" ]; then		
	    docker run -it --rm -v ${contract_dir}:/home/mythril --name ${tool_name} --entrypoint myth ${mythril_image} analyze /home/mythril/${solidity_name}:${contract_name} -t 2 >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}.txt  2>&1  
	

        fi

	
	if [ "$tool_name" = "mythril_tx3" ]; then
		docker run -it --rm -v ${contract_dir}:/home/mythril --name ${tool_name} --entrypoint myth ${mythril_image} analyze /home/mythril/${solidity_name}:${contract_name} -t 3  >>${result_dir}${solidity_name}__${contract_name}_${tool_name}.txt  2>&1
        	
        fi

	
	if [ "$tool_name" = "mythril_tx4" ]; then
		docker run -it --rm -v ${contract_dir}:/home/mythril --name ${tool_name} --entrypoint myth ${mythril_image} analyze /home/mythril/${solidity_name}:${contract_name} -t 4  >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}.txt  2>&1
        	
        fi


	if [ "$tool_name" = "smartExecutor_v3" ]; then
	    docker run -it --rm -v ${contract_dir}:/home/smartExecutor --name ${tool_name} --entrypoint semyth ${smartExecutor_image} analyze /home/smartExecutor/${solidity_name}:${contract_name} -fdg -fss bfs  >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}.txt  2>&1

        fi


	if [ "$tool_name" = "smartExecutor" ]; then
	     docker run -it --rm -v ${contract_dir}:/home/smartExecutor --name ${tool_name} --entrypoint semyth ${smartExecutor_image} analyze /home/smartExecutor/${solidity_name}:${contract_name}  >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}.txt  2>&1
        	
        fi

	end=$(date +%s.%N) 
	runtime1=$(python3 -c "print(${end} - ${start})")
    echo "#@contract_info_time" >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}.txt  2>&1
    echo ${solidity_name}:${solc_version}:${contract_name}:${runtime1} >> ${result_dir}${solidity_name}__${contract_name}_${tool_name}.txt  2>&1
    

    done # end of running a tool


done  # end of going through solidity files

exit




