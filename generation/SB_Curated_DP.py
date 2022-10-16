"""
obtain a list of contracts. Each contract has: Solidity name, solc version, contract name, vulnerable points, vulnerability type, Solidity path
output: a csv file
"""

from generation import collect_filePath_solc_contractName, divide2Groups
import pandas as pd
from utils import helper
from utils import Constants


SB_Curated_path=Constants.datasets_dir+'SB_Curated/'
output_all_csv_name='SB_Curated_contract_info_all.csv'
output_IB_RE_ULC_csv_name='SB_Curated_contract_info_IB_RE_ULC.csv'
# vulnerabilities to be considered
target_vulnerabilities=['ARITHMETIC','REENTRANCY','UNCHECKED_LL_CALLS']




def get_metadata_all(base_path:str,output_name:str):
    results=[]
    sub_dirs=helper.find_all_folders(base_path)
    for dir in sub_dirs:
        files=helper.find_all_file(dir,'sol')
        for file in files:
            re = collect_filePath_solc_contractName.collect_contract_solc_vul(file)
            for item in re:
                results.append(item+[file]) # save the file path
    df_results=pd.DataFrame(results)
    df_results.columns=['solidity','solc','contract','vul_points','vul_type','solidity_file_path']
    df_results.to_csv(base_path+output_name,index=False, sep=',')
    return df_results

def filter_contracts(base_path:str,output_name:str,df_data:pd.DataFrame,target_vulnerabilities:list):
    select_indices=[]
    for index in range(len(df_data)):
        vul_types=df_data.loc[index,'vul_type']
        contract=df_data.loc[index,'contract']
        for item in vul_types:
            if len(item)==2:
                if item[0] in target_vulnerabilities:
                    select_indices.append(index)
                    break
    df_left=df_data.iloc[select_indices]
    df_left.columns=['solidity','solc','contract','vul_points','vul_type','solidity_file_path']
    df_left.to_csv(base_path + output_name, index=False, sep=',')


#1, get the necessary information for each contract
df_data=get_metadata_all(SB_Curated_path,output_all_csv_name)

#2, filter contracts
target_vulnerabilities=['ARITHMETIC','REENTRANCY','UNCHECKED_LL_CALLS']
filter_contracts(SB_Curated_path,output_IB_RE_ULC_csv_name,df_data,target_vulnerabilities)

#3, manually remove contracts that are interfaces, libraries, or not relevant contracts

