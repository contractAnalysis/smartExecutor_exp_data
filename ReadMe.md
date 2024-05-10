
### SmartExcutor Artifact
SmartExecutor is a guided symbolic execution tool for Ethereum smart contracts. It has a dual-phase process. Phase 1 explores all sequences within the given depth limit. Phase 2 targets the not-fully-covered functions(instruction coverage) by prioritizing states and the functions to be executed on the selected states. 

This repository is for reproducing the experiments for the journal extension of the [SmartExecutor paper](https://ieeexplore.ieee.org/document/10316942).


### Structure
The experiments are set up in a containerized environment. This repository provides the necessary scripts and data to build the Docker-based container environment. Given a set of contracts, we divide them into groups. Each group consists of Solidity files and a csv file listing the information of the contracts in the Solidity files. A contract group is assigned to a Docker container, in which the contracts are evaluated. 



### Requirements
      Ubuntu 20.04
      Docker
      python3
      pandas

### Major steps
    1, Prepare for Docker images
    2, Compile Contracts 
    3, Launch Experiments
    4, Collect Results

### Experiment Preparation
Clone this repository:
```bash
git clone https://github.com/contractAnalysis/smartExecutor_exp_data.git
```
Set up the project root directory to **base_dir** in your_project_root/scripts/**config_global.sh**.

Assume that the current directory is the project root directory.   


#### Step 1: Prepare for Docker images
```shell
./docker_image_preparation/prepare_for_docker_images.sh
```
#### Step 2: Compile Contracts 
Before compiling, set the number of Docker containers to **batch_size** in */config_global.sh
In our experiments, **batch_size** is set to 30 (each container has 4 cpus).

```shell
./scripts/compile_contracts.sh
```

#### Step 3: Launch Experiments
By executing commands below, the experiment results are saved in the directory: your_project_root/results/
```shell
# run experiments for RQ1 and RQ2
./scripts/launch_24_exp_sGuard.sh
# run experiments for RQ3
./scripts/launch_24_impact_of_depth_limit_in_phase1.sh
# run experiments for RQ4
./scripts/launch_case_studies.sh

```

#### Step 4: Collect Results
Set the your project root directory to **base_dir** parameter in your_project_root/result_collection/config.py

```shell
# collect results and save into csv files in to the result folder
./result_collection/collect_results.sh

```

