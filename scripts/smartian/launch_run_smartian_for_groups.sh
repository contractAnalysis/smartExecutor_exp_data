#!/bin/bash

# experiment:24_exp_sGuard
exp_name="24_exp_sGuard"

source ./scripts/config_global.sh
source ./scripts/config_24_exp_sguard.sh


dataset_name=${dataset_name_exp_sGuard}
root_dir=${base_dir}
container_work_dir=${container_work_dir_smartian}    
run_script=${container_work_dir}scripts/smartian/${container_run_script_smartian}

contract_info_csv_name_prefix=${contract_info_csv_name_prefix}
contract_group_name_prefix=${contract_group_name_prefix}

group_start_idx=${group_start_index}
group_end_idx=${group_end_index}
batch_size=${batch_size}

cli_timeout=${cli_timeout}
tool_timeout=${tool_timeout}
solver_timeout=${solver_timeout} # not used in Smartian

execution_times=${execution_times}

image_id=${image_smartian}
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
echo "  the timeout set to command line:" ${tool_timeout}s
echo " the timeout the tool can execute:" ${execution_times}
echo "     the Docker image of the tool:" $image_id
echo ---------------------------------------------------------------



# iterate three times
for ((run_idx = 1; run_idx <=execution_times; run_idx ++));
do


	# Calculate the number of batches needed
	total_batches=$(( group_end_idx / batch_size ))
	if [ $(( group_end_idx % batch_size )) -ne 0 ]; then
    		total_batches=$(( total_batches + 1))
	fi


	# Loop through each batch
	for ((batch=1; batch<=total_batches; batch++)); do
	
		# Calculate the start and end group indices for the current batch
   		start_group=$(( (batch - 1) * batch_size + 1 ))
   		end_group=$(( batch * batch_size ))
   		if [ $end_group -gt $group_end_idx ]; then
        		end_group=$group_end_idx
    		fi

		# Start containers for the current batch
    		for ((group_index=start_group; group_index<=end_group; group_index++)); do

			#======= smartian ==============

			# arguments:work dir, dataset name, group index, prefix of the csv file, prefix of the contract group folder
			# command line timeout, tool timeout, run index (iteration index)
	
			echo ""
			echo "start Docker container smartian_${group_index}_#{run_idx} for contract group ${contract_group_name_prefix}_${group_index}" &
	

			docker run --rm --cpus 4 -v ${root_dir}:${container_work_dir} --name smartian_${group_index}_${run_idx}  --entrypoint ${run_script} ${image_id} ${container_work_dir} ${dataset_name} ${group_index} ${contract_info_csv_name_prefix} ${contract_group_name_prefix} ${cli_timeout} ${tool_timeout} ${run_idx} &





			random_number=$(( RANDOM % 6 ))
			#random_number=$(( random_number + 10 ))
			echo random_number is $random_number	
			sleep $random_number &




		done # end of a batch
    	
    		echo "Waiting for containers in batch $batch to finish..."
    		wait
		echo "Containers in batch $batch have finished."

	done # end of all batches for a dataset

done # end of iterations

exit

# iterate three times
for ((run_idx = 1; run_idx <=3; run_idx ++));
do

# Iterate from start to end
for ((group_index = group_start_idx; group_index <= group_end_idx; group_index++)); 
do
#------------
	
	#======= smartian ==============

	# arguments:work dir, dataset name, group index, prefix of the csv file, prefix of the contract group folder
	# command line timeout, tool timeout, run index (iteration index)
	
	echo
	echo "start Docker container smartian_${group_index}_#{run_idx} for contract group ${contract_group_name_prefix}_${group_index}" &
	

	docker run --rm --cpus 4 -v ${root_dir}:${container_work_dir} --name smartian_${group_index}_${run_idx}  --entrypoint ${run_script} ${image_id} ${container_work_dir} ${dataset_name} ${group_index} ${contract_info_csv_name_prefix} ${contract_group_name_prefix} ${cli_timeout} ${tool_timeout} ${run_idx} &

pids+=($!) # $! is the id 


#------------
done



done # end of iteration

# Wait for all instances to finish
for pid in "${pids[@]}"; do
    wait "$pid"
done

exit








