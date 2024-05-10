#!/bin/bash

# experiment:24_impact_of_depth_limit_in_phase1

dataset_names=( "sGuard_200_random10" "sGuard_200_random50" "sGuard_200_random100" )
depth_limits=( 1 2 3 )
export dataset_names depth_limits

group_size=20
group_start_index=1
group_end_index=10

export group_start_index group_end_index group_size


cli_timeout=1000
tool_timeout=900
solver_timeout=10000
execution_times=3
export cli_timeout tool_timeout solver_timeout execution_times


container_run_script_compile="run_compile_solc_for_a_group.sh"
container_run_script_smartExecutor="run_smartExecutor_v4.0_bin_for_a_group.sh"
 
export container_run_script_compile container_run_script_smartExecutor

