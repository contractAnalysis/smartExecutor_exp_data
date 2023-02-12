import math
import shutil
from shutil import copyfile

from generation import divide2Groups
from utils import Constants, helper
import os
import pandas as pd



dataset_path=Constants.datasets_dir+'sGuard_contracts/'
contract_info_csv='contracts_iccfwnc_target.csv'
contract_info_path=Constants.datasets_dir+contract_info_csv

results_dir=Constants.results_dir
group_size=27
random_seed=20



csv_first_three_columns=['solidity','solc','contract']

def get_groups(group_number:int,solidity_path,contracts_info_csv_path,results_path,group_size:int,random_seed:int):
    """
    get a list of groups, each of which contains Solidity files, a csv file listing contracts information, and the scripts related to the tool

    :param solidity_path: the path to the Solidity files
    :param contracts_info_csv_path: the full path of a csv file listing contract information (Solidity name, solc version, name,...)
    :param results_path: the directory to hold the generated gourp folders
    :param group_size: the number of contracts or Solidity files in a group
    :param random_seed: the seed used to randomly select the gorup size contracts at a time (so that the size of contracts in a group are not very close)
    :return: a list of group folders
    """

    data_folder="contract_groups"
    output_prefix_csv='contracts_info_group_'

    selected_idx=[]
    #------------------------------------------
    # read a csv file to get the contract data
    df_data0= pd.read_csv(contracts_info_csv_path)
    df_data= df_data0[csv_first_three_columns] # only consider these data
    total_contracts=df_data.shape[0] # get the number of the contracts
    num_groups=math.ceil(total_contracts/group_size)
    print(f'number of contracts:{total_contracts}')
    print(f'Total number of groups:{num_groups}')
    if group_number!=-1:
        num_groups=group_number
        print(f'only generate {group_number} groups.')
    # index each contract for selection
    indices=list(range(total_contracts))

    # prepare the directory to hold all groups
    dest_data_path=results_path+data_folder+"/"
    if os.path.isdir(dest_data_path):
        shutil.rmtree(dest_data_path)
    os.mkdir(dest_data_path)


    for i in range(1, num_groups+1):
        # select group_size contracts
        select=helper.random_select(indices, random_seed, group_size)
        indices=helper.remove_B_from_A(indices, select)
        selected_idx+=select

        # create a group folder
        group_folder_name= 'contracts_' + str(group_size) + "_group_" + str(i)
        group_path =dest_data_path + group_folder_name+"/"
        if not os.path.isdir(group_path):
            os.mkdir(group_path)



        # create a folder to hold solidity files under the group folder
        contract_path= group_path + "contracts_solidity/"
        if not os.path.isdir(contract_path):
            os.mkdir(contract_path)

        # copy solidity files to the folder
        solc_versions=[]
        for idx in select:
            solidity_file=df_data.iloc[idx,0]
            # copy the Solidity file
            copyfile(solidity_path+solidity_file,contract_path+solidity_file)
            solc=df_data.iloc[idx,1]
            if solc not in solc_versions:
                solc_versions.append(solc)

        # prepare the csv file for the group
        df_group = df_data.iloc[select]
        csv_file_name=output_prefix_csv+str(i)+".csv"
        df_group.to_csv(group_path+ csv_file_name, index=False,
                                         header=False,
                                         sep=',', line_terminator='\n')
        df_solc=pd.DataFrame(solc_versions)
        csv_file_name='solc_versions.csv'
        df_solc.to_csv(group_path + csv_file_name, index=False,
                        header=False,
                        sep=',', line_terminator='\n')

    df_all_selected=df_data0.iloc[selected_idx]
    df_all_selected.columns=df_data0.columns
    df_all_selected.to_csv(results_path+ "selected_contracts.csv", index=False,
                                         header=True,
                                         sep=',', line_terminator='\n')


#================================================
get_groups(-1,dataset_path,contract_info_path,\
           results_dir,group_size,\
           random_seed )










