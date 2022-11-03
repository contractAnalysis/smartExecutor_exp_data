#### 
<p>
As the experiments are conducted through Singularity containers, the experiments are thus converted into smaller groups. Each group contains all the needed data to run in a container.

</p>

A generated group has the following:
1. contracts: contains the contracts to be evaluated within one container.
2. *.csv: list the Solidity name, solc version, and contract name for each contract in 'contracts' to be evaluated.
3. exp_run_tool_*.sh: run a tool within in a container to execute the contracts in the 'contracts'.
4. exp_1_container_*.sh: launch a Singularity container to run the tool script exp_run_tool\_\*.sh.

#### Preparation
1. SGUARD dataset. 
2. Docker images of the tools involved in experiments.
3. Scripts to run each tool using Singularity containers.
4. scripts organized  based on experiments, like the directories in 'scripts_dir' folder.


### Steps to Generate
##### Get the contract lists for each dataset with information: solidity name, solc version, and contract name.<br>
<br>
Get the contract list for the SGUARD dataset:

```
execute sGuard_DP.py in Pycharm IDE
```

##### Generate data for experiments.<br>

Generate data on SGUARD dataset (exp_mythril_smartExecutor):
```
execute generate_exp_data.py in Pycharm IDE
```

Generate data on randomly selected contracts (exp_phase2):
```
execute generate_exp_phase2.py in Pycharm IDE
```

#### Job level scripts
The job-level scripts are the scripts that can launch a specified number of Singularity containers in parallel. They have important parameters needed to be set up. 