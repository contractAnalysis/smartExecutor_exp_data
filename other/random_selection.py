
from generation import divide2Groups
from utils import Constants, helper
import os
from utils.helper import find_all_file
import pandas as pd


import math

from shutil import copyfile

import shutil

#=========================================
# get the binary file paths

random_seed=100
select_number=100
csv_file_path=Constants.project_path+'combine_MT_v0.23.22_SE_bfs_0_p100_5_results_equal_coverage.csv'
csv_first_three_columns=['solidity','solc','contract']
selected_data_csv='selected_100_results.csv'


# read a csv file to get the contract data
df_data= pd.read_csv(csv_file_path)
# df_data= df_data0[csv_first_three_columns]
total_contracts=df_data.shape[0] # get the number of the contracts

indices=list(range(total_contracts))


# select contracts
select = helper.random_select(indices, random_seed, select_number)

# prepare the csv file for the group
df_data_select = df_data.iloc[select]

df_data_select.to_csv(Constants.project_path+ selected_data_csv, index=False,
                      header=False,
                      sep=',', line_terminator='\n')









