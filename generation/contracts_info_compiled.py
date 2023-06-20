
from generation import divide2Groups
from utils import Constants
import os
import pandas as pd
from utils.helper import find_all_file






#=========================================
# get the contract info
dataset_path=Constants.datasets_dir+'sGuard_contracts/'
info_csv_path=dataset_path
contract_info_csv='sGuard_contracts_info.csv'

contract_info_dict={}
df_data=pd.read_csv(info_csv_path+contract_info_csv,header=None)
for idx, row in df_data.iterrows():
    contract_info_dict[row[0]]=[row[1],row[2]]


#=========================================
# the info of contracts that are compiled
binary_path=Constants.datasets_dir+'sGuard_binary_files/'
group_name_prefix='contracts_167_group'
contract_info_compiled_csv='sGuard_contracts_info_compiled.csv'
start_index=1
end_index=30

contract_info_compiled=[]
for idx in range(start_index,end_index+1):
    path=binary_path+group_name_prefix+"_"+str(idx)+"/contracts_binary/"
    files=find_all_file(path,'bin')
    for file in files:
        f=open(file,'r')
        if len(f.readlines())>0:
            file_name=file.split("/")[-1]
            file_name=file_name[0:-4]
            solidity_name=file_name.split('.sol')[0]+".sol"
            contract_name=file_name.split('.sol')[-1]
            contract_info_compiled.append([solidity_name,contract_info_dict[solidity_name][0],contract_name])
            continue

df_data_compiled=pd.DataFrame(contract_info_compiled )
df_data_compiled.columns=['solidity','solc','contract']
df_data_compiled.to_csv(binary_path+contract_info_compiled_csv,index=False,sep=',', line_terminator='\n')