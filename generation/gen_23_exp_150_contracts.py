
from generation import divide2Groups
from utils import Constants
import os
from utils.helper import find_all_file


#=========================================
# get the binary file paths
binary_path=Constants.datasets_dir+'sGuard_binary_files/'
group_name_prefix='contracts_167_group'
start_index=1
end_index=30

contract_info_binary_files_path={}
for idx in range(start_index,end_index+1):
    path=binary_path+group_name_prefix+"_"+str(idx)+"/contracts_binary/"
    files=find_all_file(path,'bin')
    for file in files:
        f=open(file,'r')
        if len(f.readlines())>0:
            file_name = file.split("/")[-1]
            contract_info_binary_files_path[file_name]=file
            continue


#=========================================
dataset_path=Constants.datasets_dir+'sGuard_contracts/'
# consider the contracts that can be compiled
compiled_csv_path=Constants.datasets_dir+'sGuard_binary_files/'
contract_info_compiled_csv='sGuard_contracts_info_compiled.csv'


exp_subpath='23_exp_150_contracts'
scripts_dir=Constants.scripts_dir+exp_subpath+"/"
results_dir=Constants.results_dir
group_size=5
random_seed=100
group_num=30


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

divide2Groups.get_groups_general_include_binary(group_num, \
                         dataset_path,\
            compiled_csv_path+contract_info_compiled_csv,\
                         scripts_dir,\
                         results_dir,group_size,\
                         random_seed,data_result_folder=exp_subpath,binary_path_dict=contract_info_binary_files_path)










