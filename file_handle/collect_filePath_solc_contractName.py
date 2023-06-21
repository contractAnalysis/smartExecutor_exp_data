# -*- coding: utf-8 -*-

import re
import pandas as pd
from pandas import DataFrame
import utils.helper as help


def collect_solc_from_solidity_files(directory:str)->DataFrame:
    #collect the solc version
    file_solc = []
    files =help.find_all_file(directory, 'sol')
    for file in files:
        with open(file, 'r', encoding='utf8') as fp:
            line = fp.readline()
            while line:
                if line.startswith("pragma") and "solidity" in line:
                    file_name = file.split('/')[-1]  # on linux virtual machine
                    solc_version = '0.4.25'
                    if ";" in line:
                        line = line.split(";")[0]
                        res = re.search("(\d+).(\d+).(\d+)", line)
                        if res:
                            solc_version = res.group(0)
                        else:
                            res1 = re.search("(\d+).(\d+)", line)
                            if res1:
                                solc_version = res1.group(0) + ".0"
                    else:
                        print("broken pragma statement")
                    file_solc.append([file_name, solc_version.strip()])
                    break
                line = fp.readline()
    df_file_solc = pd.DataFrame(file_solc)
    return df_file_solc




def merge_contract_info(contract_path:str,old_csv_path:str,df_file_solc:DataFrame,output_csv_name:str)->DataFrame:
    # =================================
    # clean the given all.csv file by removing "contracts/" from the file names
    # remove rows contains nan value or contracts with name 'SafeMath'
    df_csv = pd.read_csv(old_csv_path, header=None)
    df_csv[1] = df_csv[1].map(lambda x: x.split("/")[-1])  # remove "contracts/"
    # df_csv_filtered= df_csv[(df_csv[0]!="NaN") & (df_csv[0]!="SafeMath")]
    # df_csv_filtered= df_csv[df_csv[0]!="SafeMath"]
    df_csv_filtered = df_csv.dropna()

    # =================================
    # get contract info: solidity file name, solc version, contract
    df_file_solc.columns = ['solidity_file', 'solc_version']
    df_csv_filtered.columns = ['contract_name', 'solidity_file']
    
    # df_contracts_info=pd.concat([df_csv_filtered, df_file_solc],axis=1).reindex(df_csv_filtered.index)
    # df_csv_filtered.columns = ['contract_name', 'solidity_file', 'solidity_file1', 'solc_version']

    # df_contracts_info.drop(['solidity_file1'],axis=1)

    df_contracts_info=pd.merge(df_csv_filtered, df_file_solc, how="left", on=["solidity_file"])
   
    columns_titles = ['solidity_file', 'solc_version', 'contract_name']
    df_contracts_info = df_contracts_info.reindex(columns=columns_titles)  # swap columns by giving a list of columns
    df_contracts_info.columns=['solidity','solc','contract']
    df_contracts_info.to_csv(contract_path + output_csv_name, index=False, sep=',')  # output to a csv file

    return df_contracts_info














