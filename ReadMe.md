#### 
<p>
As the experiments are conducted through Singularity containers, the experiments are thus converted into smaller groups. Each group contains all the needed data to run in a container.

</p>

#### Preparation
1. datasets 
2. Docker images of the tools involved in experiments.
3. Scripts to run each tool using Singularity containers.
4. Organize scripts based on experiments, like the directories in 'scripts_dir' folder.

#### Results of Data Generation
A generated group has the following:
1. a 'contracts' folder containing the contracts to be evaluated within one container.
2. a '*.csv' file listing the Solidity name, solc version, and contract name for each contract to be evaluated.
3. a 'exp_run_tool_*.sh' file running a tool within in a container to execute the contracts in the 'contracts' folder.
4. a 'exp_1_container_*.sh' file launching a Singularity container to run the tool script 'exp_run_tool\_\*.sh'.

Notes: for some tools, more files are required. They are added by manually executing the necessary commands.


### Steps to Generate
##### Get the contract lists for each dataset with information: solidity name, solc version, and contract name.<br>
<br>
get the contract list for sGuard dataset:

```
execute sGuard_DP.py in Pycharm IDE
```

get the contract list for SB Curated dataset:
```
execute SB_Curated.py in Pycharm IDE
```

##### Generate data for experiments.<br>

generate data for RQ1.experiment 1:
```
execute generate_exp_data.py in Pycharm IDE
```
generate data for RQ1.experiment 2:
```
execute generate_exp_phase2.py in Pycharm IDE
```

generate data for RQ2:
```
execute generate_exp_benchmark.py in Pycharm IDE
```




