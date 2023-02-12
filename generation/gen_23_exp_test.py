
from generation import divide2Groups
from utils import Constants
import os


dataset_path=Constants.datasets_dir+'sGuard_contracts/'
info_csv_path='/home/wei/PycharmProjects/smartExecutor_data_preparation/scripts_dir/23_exp_test/'
contract_info_csv='test_contract_info.csv'
exp_subpath='23_exp_test'
scripts_dir=Constants.scripts_dir+exp_subpath+"/"
results_dir=Constants.results_dir

group_size=4
random_seed=20



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

divide2Groups.get_groups_general(-1, \
                         dataset_path,\
            info_csv_path+contract_info_csv,\
                         scripts_dir,\
                         results_dir,group_size,\
                         random_seed)










