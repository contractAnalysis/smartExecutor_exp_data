"""
get a list of contracts to be evaluated with eah having: Solidity name, solc,  contract name

the contracts are from the given list coming along with the dataset.(we did not choose contracts)

output: a csv file
"""

from file_handle.collect_filePath_solc_contractName import collect_solc_from_solidity_files, merge_contract_info

from utils import Constants


sGuard_path=Constants.datasets_dir+'sGuard_contracts/'
original_csv_name= 'all_updated.csv'
output_csv_name = 'sGuard_contracts_info.csv'


# 1, collect the solc version from Solidity files
df_file_solc = collect_solc_from_solidity_files(sGuard_path)

# 2, get the csv file listing the contracts to be evaluated (solidity file names and contract names)
old_csv_path = sGuard_path + original_csv_name

# 3, get the csv file containing the list contracts each has: Solidty file name, solc version, and contract name)
df_contract_info = merge_contract_info(sGuard_path,old_csv_path, df_file_solc,output_csv_name)

