
from generation import divide2Groups
from utils import Constants
import os


dataset_path=Constants.datasets_dir+'sGuard_contracts/'
contract_info_csv='contracts_have_DF.csv'
exp_subpath='exp_phase2/test_phase2_120_contracts'
scripts_dir=Constants.scripts_dir+exp_subpath+"/"
results_dir=Constants.results_dir
group_size=4
random_seed=100


tools=['mythril','smartExecutor']
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
for tool in tools:
    print(f'Prepare data for {tool}')
    divide2Groups.get_groups(30, \
                             dataset_path,\
                scripts_dir+contract_info_csv,\
                             scripts_dir,\
                             results_dir,group_size,\
                             random_seed,\
                             tool)

