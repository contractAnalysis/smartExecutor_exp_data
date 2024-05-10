#!/bin/bash

# experiment:24_impact_of_depth_limit_in_phase1

exp_name="24_impact_of_depth_limit_in_phase1"
source ./scripts/config_global.sh
source ./scripts/config_24_impact_of_depth_limit_in_phase1.sh

dataset_names=${dataset_names}


exp_root_dir=${base_dir}
container_work_dir=${container_work_dir_compile}    
run_script=${container_work_dir}scripts/compile/${container_run_script_compile}

group_size=${group_size}
group_start_idx=${group_start_index}
group_end_idx=${group_end_index}
batch_size=${batch_size}

image_id=${image_compile}


echo ""
echo ==============================================================
echo experiment:${exp_name}
echo "     the datasets to be evaluated:" $dataset_names
echo "  the root folder of this project:" $exp_root_dir
echo "the work directory in a container:" $container_work_dir
echo "the script running in a container:" $run_script
#echo "prefix of file with contract info:" $contract_info_csv_name_prefix
#echo "contract group folder name prefix:" $contract_group_name_prefix
echo "   start index of contract groups:" $group_start_idx
echo "     end index of contract groups:" $group_end_idx
echo "   number of contracts in a group:" $group_size
echo "    # of containers to be started:" $batch_size
echo "     the Docker image of the tool:" $image_id
echo ----------------------------------------------------------------

# find the total groups from all the datasets
dataset_name_list=()
group_idx_list=()
for dataset_name in ${dataset_names[@]}
do
	for ((group_idx=group_start_idx; group_idx<=group_end_idx; group_idx++)); do

		dataset_name_list+=($dataset_name) 
		group_idx_list+=($group_idx)
	done 

done



# Calculate the number of batches needed
total_groups=${#dataset_name_list[@]}
total_batches=$(( total_groups / batch_size ))
if [ $(( total_groups % batch_size )) -ne 0 ]; then
    	total_batches=$(( total_batches + 1))
fi
echo total_groups=$total_groups
echo total_batches=$total_batches

# Loop through each batch
for ((batch=1; batch<=total_batches; batch++)); do

	# Calculate the start and end group indices for the current batch
   	start_group=$(( (batch - 1) * batch_size ))
   	end_group=$(( batch * batch_size ))
   	if [ $end_group -gt $total_groups ]; then
        end_group=$total_groups
    	fi
	
	# Start containers for the current batch
    	for ((group_index=start_group; group_index<=end_group; group_index++)); do
		dataset_name=${dataset_name_list[group_index]}		
		contract_info_csv_name_prefix=${dataset_name}_contrarct_info
		contract_group_name_prefix=${dataset_name}_${group_size}
		actual_group_index=${group_idx_list[group_index]}
		

		#======= compile ==============

		# arguments:work dir, dataset name, group index, prefix of the csv file, prefix of the contract group folder
		echo ""
		echo "start Docker container compile_${actual_group_index} for contract group ${contract_group_name_prefix}_${actual_group_index}" 
	

		docker run --rm --cpus 4 -v ${exp_root_dir}:${container_work_dir} --name compile_${group_index}  --entrypoint ${run_script} ${image_id} ${container_work_dir} ${dataset_name} ${actual_group_index} ${contract_info_csv_name_prefix} ${contract_group_name_prefix} &





		#random_number=$(( RANDOM % 6 ))
		##random_number=$(( random_number + 10 ))
		#echo random_number is $random_number	
		#sleep $random_number &




	done # end of a batch
    	
    	echo "Waiting for containers in batch $batch to finish..."
    	wait
	echo "Containers in batch $batch have finished."

done

exit




