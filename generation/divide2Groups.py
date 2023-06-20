
"""
this script is to generate experiment data for experiments adapted to Singularity containers.
Each container has its own data. So input data are divided into a list of groups.
the first three columns of the csv file must be: 'solidity','solc','contract'

input:
    Solitiy files and a csv file listing all the contracts to be evaluated.
output:
    a list of folders with each containing Solidity files, a csv file listing contract information, [scripts]
"""

import pandas as pd
from utils import Constants
import utils.helper as helper

import math
import os
from shutil import copyfile
from utils import helper
import shutil

csv_first_three_columns=['solidity','solc','contract']

def get_groups(group_number:int,solidity_path,contracts_info_csv_path,scripts_path:str,results_path,group_size:int,random_seed:int,tool="tool"):
    """
    get a list of groups, each of which contains Solidity files, a csv file listing contracts information, and the scripts related to the tool

    :param solidity_path: the path to the Solidity files
    :param contracts_info_csv_path: the full path of a csv file listing contract information (Solidity name, solc version, name,...)
    :param scripts_path:
    :param results_path: the directory to hold the generated gourp folders
    :param group_size: the number of contracts or Solidity files in a group
    :param random_seed: the seed used to randomly select the gorup size contracts at a time (so that the size of contracts in a group are not very close)
    :param tool: for which the group folders are generated. It is snecessary when there are scripts for the tool.
    :return: a list of group folders
    """
    script_folder=tool+"_scripts"
    data_folder=tool+"_data"
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

    # copy job-level scripts to the data folder
    job_script_path = scripts_path + "job_level_scripts/"
    if os.path.exists(job_script_path):
        files = helper.find_all_file(job_script_path, "sh")
        for file in files:
            file_name=file.split("/")[-1]
            if tool in file_name or 'Container.sh' in file_name:
                copyfile(file, dest_data_path + file_name)

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

        # copy scripts to the group folder
        script_path = scripts_path + script_folder+"/"
        if os.path.exists(script_path):
            files = helper.find_all_file(script_path, "sh")
            for file in files:
                copyfile(file, group_path + file.split("/")[-1])

        # create a folder contracts to hold solidity files under the group folder
        contract_path= group_path + "contracts/"
        if not os.path.isdir(contract_path):
            os.mkdir(contract_path)

        # copy solidity files to the folder
        for element in select:
            solidity_file=df_data.iloc[element,0]
            copyfile(solidity_path+solidity_file,contract_path+solidity_file)


        # prepare the csv file for the group
        df_data_select = df_data.iloc[select]
        csv_file_name=output_prefix_csv+str(i)+".csv"
        df_data_select.to_csv(group_path+ csv_file_name, index=False,
                                         header=False,
                                         sep=',', line_terminator='\n')
    df_all_selected=df_data0.iloc[selected_idx]
    df_all_selected.columns=df_data0.columns
    df_all_selected.to_csv(results_path+ "selected_contracts.csv", index=False,
                                         header=True,
                                         sep=',', line_terminator='\n')


def get_groups_general(group_number:int,solidity_path,contracts_info_csv_path,scripts_path:str,results_path,group_size:int,random_seed:int,data_result_folder:str='contract_groups'):
    """
    get a list of groups, each of which contains Solidity files, a csv file listing contracts information, and the scripts related to the tool

    :param solidity_path: the path to the Solidity files
    :param contracts_info_csv_path: the full path of a csv file listing contract information (Solidity name, solc version, name,...)
    :param scripts_path:
    :param results_path: the directory to hold the generated gourp folders
    :param group_size: the number of contracts or Solidity files in a group
    :param random_seed: the seed used to randomly select the gorup size contracts at a time (so that the size of contracts in a group are not very close)
    :param tool: for which the group folders are generated. It is snecessary when there are scripts for the tool.
    :return: a list of group folders
    """
    job_scripts_folder='job_scripts'
    container_scripts_folder='container_scripts'
    data_folder=data_result_folder
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

    # copy job-level scripts to the data folder
    job_script_path = scripts_path + job_scripts_folder+"/"
    if os.path.exists(job_script_path):
        files = helper.find_all_file(job_script_path, "sh")
        for file in files:
            file_name=file.split("/")[-1]
            copyfile(file, dest_data_path + file_name)

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

        # copy scripts to the group folder
        script_path = scripts_path + container_scripts_folder+"/"
        if os.path.exists(script_path):
            files = helper.find_all_file(script_path, "sh")
            for file in files:
                copyfile(file, group_path + file.split("/")[-1])

        # create a folder contracts to hold solidity files under the group folder
        contract_path= group_path + "contracts/"
        if not os.path.isdir(contract_path):
            os.mkdir(contract_path)

        # copy solidity files to the folder
        solc_versions = []
        for element in select:
            solidity_file=df_data.iloc[element,0]
            copyfile(solidity_path+solidity_file,contract_path+solidity_file)
            solc = df_data.iloc[element, 1]
            if solc not in solc_versions:
                solc_versions.append(solc)


        # prepare the csv file for the group
        df_data_select = df_data.iloc[select]
        csv_file_name=output_prefix_csv+str(i)+".csv"
        df_data_select.to_csv(group_path+ csv_file_name, index=False,
                                         header=False,
                                         sep=',', line_terminator='\n')

        # output the solc versions used in the container
        df_solc = pd.DataFrame(solc_versions)
        csv_file_name = 'solc_versions.csv'
        df_solc.to_csv(group_path + csv_file_name, index=False,
                       header=False,
                       sep=',', line_terminator='\n')

    df_all_selected=df_data0.iloc[selected_idx]
    df_all_selected.columns=df_data0.columns
    df_all_selected.to_csv(results_path+ "selected_contracts.csv", index=False,
                                         header=True,
                                         sep=',', line_terminator='\n')

def get_groups_general_include_binary(group_number:int,solidity_path,contracts_info_csv_path,scripts_path:str,results_path,group_size:int,random_seed:int,data_result_folder:str='contract_groups',binary_path_dict:dict={}):
    """
    get a list of groups, each of which contains Solidity files, a csv file listing contracts information, and the scripts related to the tool

    :param solidity_path: the path to the Solidity files
    :param contracts_info_csv_path: the full path of a csv file listing contract information (Solidity name, solc version, name,...)
    :param scripts_path:
    :param results_path: the directory to hold the generated gourp folders
    :param group_size: the number of contracts or Solidity files in a group
    :param random_seed: the seed used to randomly select the gorup size contracts at a time (so that the size of contracts in a group are not very close)
    :param tool: for which the group folders are generated. It is snecessary when there are scripts for the tool.
    :param binary_path_dict: contains a path for each binary file
    :return: a list of group folders
    """
    job_scripts_folder='job_scripts'
    container_scripts_folder='container_scripts'
    data_folder=data_result_folder
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

    # copy job-level scripts to the data folder
    job_script_path = scripts_path + job_scripts_folder+"/"
    if os.path.exists(job_script_path):
        files = helper.find_all_file(job_script_path, "sh")
        for file in files:
            file_name=file.split("/")[-1]
            copyfile(file, dest_data_path + file_name)

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

        # copy scripts to the group folder
        script_path = scripts_path + container_scripts_folder+"/"
        if os.path.exists(script_path):
            files = helper.find_all_file(script_path, "sh")
            for file in files:
                copyfile(file, group_path + file.split("/")[-1])

        # create a folder contracts to hold solidity files under the group folder
        contract_path= group_path + "contracts/"
        if not os.path.isdir(contract_path):
            os.mkdir(contract_path)


        # copy solidity files to the folder
        solc_versions = []
        for element in select:
            solidity_file=df_data.iloc[element,0]
            copyfile(solidity_path+solidity_file,contract_path+solidity_file)
            solc = df_data.iloc[element, 1]
            if solc not in solc_versions:
                solc_versions.append(solc)

        # create a folder for binary contracts to hold binary files under the group folder
        contract_binary_path = group_path + "contracts_binary/"
        if not os.path.isdir(contract_binary_path):
            os.mkdir(contract_binary_path)

        # copy binary files
        for element in select:
            solidity_file=df_data.iloc[element,0]
            contract_name=df_data.iloc[element,2]
            bin_file_key=solidity_file+contract_name+".bin"
            bin_file_path=binary_path_dict[bin_file_key] if bin_file_key in binary_path_dict.keys() else ''
            if len(bin_file_path)>0:
                copyfile(bin_file_path,contract_binary_path+bin_file_key)

            else:
                print(f'{bin_file_key} is not found')

        # prepare the csv file for the group
        df_data_select = df_data.iloc[select]
        csv_file_name=output_prefix_csv+str(i)+".csv"
        df_data_select.to_csv(group_path+ csv_file_name, index=False,
                                         header=False,
                                         sep=',', line_terminator='\n')

        # output the solc versions used in the container
        df_solc = pd.DataFrame(solc_versions)
        csv_file_name = 'solc_versions.csv'
        df_solc.to_csv(group_path + csv_file_name, index=False,
                       header=False,
                       sep=',', line_terminator='\n')

    df_all_selected=df_data0.iloc[selected_idx]
    df_all_selected.columns=df_data0.columns
    df_all_selected.to_csv(results_path+ "selected_contracts.csv", index=False,
                                         header=True,
                                         sep=',', line_terminator='\n')




def get_groups_SB_Curated(contracts_info_csv_path,scripts_path:str,results_path:str, group_size: int, random_seed: int, tool="tool"):
    """
    used in the case that the Solidity files are grouped in different folders
    :param base_path:
    :param contracts_info_csv_path:
    :param scripts_path:
    :param results_path:
    :param group_size:
    :param random_seed:
    :param tool:
    :return:
    """
    script_folder = tool + "_scripts"
    data_folder = tool + "_data"
    output_prefix_csv = 'contracts_info_group_'

    # read a csv file to get the contract data
    df_data= pd.read_csv(contracts_info_csv_path, header=0)
    total_contracts = df_data.shape[0]  # get the number of the contracts
    num_groups = math.ceil(total_contracts / group_size)
    print(f'number of contracts:{total_contracts}')
    print(f'number of groups:{num_groups}')

    # index each contract for selection
    indices = list(range(total_contracts))


    # prepare the directory to hold all groups
    dest_data_path=results_path+data_folder+"/"
    if os.path.isdir(dest_data_path):
        os.rmdir(dest_data_path)
    os.mkdir(dest_data_path)

    # copy job-level scripts to the data folder
    job_script_path = scripts_path + "job_level_scripts/"
    if os.path.exists(job_script_path):
        files = helper.find_all_file(job_script_path, "sh")
        for file in files:
            file_name=file.split("/")[-1]
            if tool in file_name or 'Container.sh' in file_name:
                copyfile(file, dest_data_path + file_name)

    # generate groups
    for i in range(1, num_groups + 1):
        # select group_size contracts
        select = helper.random_select(indices, random_seed, group_size)
        indices = helper.remove_B_from_A(indices, select)

        # create a group folder
        group_folder_name = 'contracts_' + str(group_size) + "_group_" + str(i)
        group_path = dest_data_path + group_folder_name + "/"
        if not os.path.isdir(group_path):
            os.mkdir(group_path)

        # copy scripts to the group folder
        script_path = scripts_path + script_folder+"/"
        if os.path.exists(script_path):
            files = helper.find_all_file(script_path, "sh")
            for file in files:
                copyfile(file, group_path + file.split("/")[-1])

        # create a folder contracts to hold solidity files under the group folder
        contract_path = group_path + "contracts/"
        if not os.path.isdir(contract_path):
            os.mkdir(contract_path)

        # copy solidity files to the folder
        for element in select:
            solidity_file_path=df_data.iloc[element, -1]
            solidity_file=str(solidity_file_path).split("/")[-1]
            copyfile(solidity_file_path, contract_path + solidity_file)

        # prepare the csv file for the group
        df_data_select = df_data.iloc[select]
        df_data_select= df_data_select[df_data_select.columns[0:3]]
        csv_file_name = 'contracts_info_group_' + str(i) + ".csv"
        df_data_select.to_csv(group_path + csv_file_name, index=False,
                              header=False,
                              sep=',', line_terminator='\n')





def test_random_select():
    """
    randomly select n elements from a list to form a group until all elements are selected.
     :return:
    """
    group_size = 2
    randome_seed = 20
    total_contracts=11
    num_groups=math.ceil(total_contracts/group_size)
    re=[]
    indices=list(range(total_contracts))
    for i in range(1, num_groups+1):
        select=helper.random_select(indices,randome_seed,group_size)
        re+=select
        print(f'select {i}: {select}')
        helper.remove_B_from_A(indices,select)

    re.sort()
    if re.__eq__(list(range(total_contracts))):
        print(f're={re}')
        print('succeed')
    else:
        print('failure')

# test_random_select()




