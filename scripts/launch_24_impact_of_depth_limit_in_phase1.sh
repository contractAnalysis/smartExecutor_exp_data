#!/bin/bash

source ./scripts/config_24_impact_of_depth_limit_in_phase1.sh

depth_limits=$depth_limits

dataset_names=$dataset_names

for dataset_name in ${dataset_names[@]}
do
	for depth in ${depth_limits[@]}
	do
		echo ./scripts/smartExecutor/launch_run_smartExecutor_v4.0_for_groups_24_impact_of_depth_limit_in_phase1.sh $depth $dataset_name

		./scripts/smartExecutor/launch_run_smartExecutor_v4.0_for_groups_24_impact_of_depth_limit_in_phase1.sh $depth $dataset_name
	done
	
done







