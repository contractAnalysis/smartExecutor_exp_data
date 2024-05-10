#!/bin/bash

# experiment:24_impact_of_depth_limit_in_phase1
exp_name="24_impact_of_depth_limit_in_phase1"

source ./scripts/config_global.sh
source ./scripts/config_24_impact_of_depth_limit_in_phase1.sh

p1_depth=$1
dataset_name=$2


root_dir=${base_dir}
container_work_dir=${container_work_dir_smartExecutor}    
run_script=${container_work_dir}scripts/smartExecutor/${container_run_script_smartExecutor}
group_size=${group_size}

contract_info_csv_name_prefix=${dataset_name}_contrarct_info
contract_group_name_prefix=${dataset_name}_${group_size}



group_start_idx=${group_start_index}
group_end_idx=${group_end_index}

batch_size=${batch_size}
cli_timeout=${cli_timeout}
tool_timeout=${tool_timeout}
solver_timeout=${solver_timeout} # default timeout for this version of SmartExecutor

execution_times=${execution_times}

image_id=${image_smartExecutor}


echo ""
echo ==============================================================
echo experiment:${exp_name}

echo "      the dataset to be evaluated:" $dataset_name
echo "  the root folder of this project:" $root_dir
echo "the work directory in a container:" $container_work_dir
echo "the script running in a container:" $run_script
echo "prefix of file with contract info:" $contract_info_csv_name_prefix
echo "contract group folder name prefix:" $contract_group_name_prefix
echo "   start index of contract groups:" $group_start_idx
echo "     end index of contract groups:" $group_end_idx
echo "       the depth limit of Phase 1:" $p1_depth  # the depth limit of Phase 1
echo "    # of containers to be started:" $batch_size
echo "  the timeout set to command line:" ${tool_timeout}s
echo " the timeout the tool can execute:" ${execution_times}
echo "     the Docker image of the tool:" $image_id
echo ---------------------------------------------------------------


# as there are only 10 groups. Needing to schedule based on all the groups in multiple iterations
# find the total groups from all the datasets
run_idx_list=()
group_idx_list=()
for ((run_idx = 1; run_idx <=execution_times; run_idx ++));
do
	for ((group_idx=group_start_idx; group_idx<=group_end_idx; group_idx++)); do
		run_idx_list+=($run_idx)		
		group_idx_list+=($group_idx)
	done 
done

# Calculate the number of batches needed
total_groups=${#group_idx_list[@]}
total_batches=$(( total_groups / batch_size ))
if [ $(( total_groups % batch_size )) -ne 0 ]; then
    	total_batches=$(( total_batches + 1))
fi


# Loop through each batch
for ((batch=1; batch<=total_batches; batch++)); do
	
	# Calculate the start and end group indices for the current batch
   	start_group=$(( (batch - 1) * batch_size ))
   	end_group=$(( batch * batch_size ))
   	if [ $end_group -gt $total_groups ]; then
        	end_group=$total_groups
    	fi

	# Start containers for the current batch
    	for ((group_index=start_group; group_index<end_group; group_index++)); do
		actual_group_index=${group_idx_list[group_index]}
		run_idx=${run_idx_list[group_index]}
		

		#======= smartExecutor v4.0 ==============

		# arguments:work dir, dataset name, group index, prefix of the csv file, prefix of the contract group folder
		# command line timeout, tool timeout, depth limit of Phase 1, run index (iteration index)
		echo ""
		echo "start Docker container smartExecutor_v4.0_${group_index}_${run_idx} for contract group ${contract_group_name_prefix}_${actual_group_index}" 
	
	
		docker run --rm --cpus 4 -v ${root_dir}:${container_work_dir} --name smartexecutor_v4.0_${group_index}_${run_idx}  --entrypoint ${run_script} ${image_id} ${container_work_dir} ${dataset_name} ${actual_group_index} ${contract_info_csv_name_prefix} ${contract_group_name_prefix} ${cli_timeout} ${tool_timeout} ${p1_depth} ${run_idx} &



			

		#random_number=$(( RANDOM % 6 ))
		##random_number=$(( random_number + 10 ))
		#echo random_number is $random_number	
		#sleep $random_number &




	done # end of a batch
    	
    	echo "Waiting for containers in batch $batch to finish..."
    	wait
	echo "Containers in batch $batch have finished."

done











