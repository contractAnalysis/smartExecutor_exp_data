"""
prepare for the experiment data that will compile contracts.
"""

from file_handle import divide2Groups
from utils import Constants
import os



#=========================================

# the path to the Solidity of contracts
dataset_path=Constants.datasets_dir+'sGuard_contracts/'

# the path to the csv file that listing the information of the contracts to be compiled.
info_csv_path=dataset_path

# the csv file listing the information of the contracts
contract_info_csv='sGuard_contracts_info.csv'




# experiment name
exp_subpath='23_exp_compile_sGuard'

# the path to the scripts of the experiment
scripts_dir=Constants.scripts_dir+exp_subpath+"/"

# the directory to save the generated experiment data (a list of folders, each corresponding a collection of files for one container)
results_dir=Constants.results_dir

# the number of contracts selected to from a group.
# set 167 so that totally 30 groups will be generated
# as 30 containers is the max number of contaienrs that
# can be launched in a compute ndoe in Lonestar6 compute node.
group_size=167

# the random seed used to select 10 contracts to from a group
random_seed=100

# indicate that the number of groups generated is determined by the group size and the total number of contracts
group_num=-1



# create subdirectories to form the base path
if '/' in exp_subpath:
    nested_folders=exp_subpath.split('/')
    for folder in nested_folders:
        if not os.path.isdir(results_dir+folder):
            os.mkdir(results_dir+folder)
            results_dir+=folder+'/'
        else:
            results_dir += folder + '/'

# # get data groups
divide2Groups.get_groups_general(group_num, \
                                 dataset_path, \
                                 info_csv_path + contract_info_csv, \
                                 scripts_dir, \
                                 results_dir, group_size, \
                                 random_seed, exp_subpath)










