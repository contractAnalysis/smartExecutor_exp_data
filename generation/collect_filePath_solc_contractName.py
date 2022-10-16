# -*- coding: utf-8 -*-

import re
import pandas as pd
from pandas import DataFrame
import utils.mythril_util as m_util



def collect_solc_from_solidity_files(directory:str)->DataFrame:
    #collect the solc version
    file_solc = []
    files = m_util.find_all_file(directory, 'sol')
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




def collect_contract_solc_vul(file_path)->list:
    not_consider_solc=['0.4.0','0.4.1','0.4.2','0.4.9','0.4.11','0.4.13','0.4.15','0.4.16','0.4.21','0.4.23']
    contracts=[]
    solidity_name = file_path.split("/")[-1]
    solc_version = '0.4.25'  # default version if no solc version is found

    vul_points=''
    bugs=[]
    read_file = open(file_path, 'r', encoding='utf8')
    line_index=0
    final_results=[]
    for line in read_file.readlines():
        line=line.strip()
        line_index+=1
        if line.startswith("pragma") and "solidity" in line:
            # print(f'line {line}')
            if ";" in line:
                line = line.split(";")[0]
                res = re.search("(\d+).(\d+).(\d+)", line)
                if res:
                    solc_version = res.group(0)
                else:
                    res1 = re.search("(\d+).(\d+)", line)
                    if res1:
                        solc_version= res1.group(0) + ".0"
            else:
                print("broken pragma statement")
            if solc_version in not_consider_solc:
                solc_version = '0.4.25'
            continue
        if "@vulnerable_at_lines" in line:

            # print(f'line {line}')
            vul_points=line.split("@vulnerable_at_lines:")[-1]
            vul_points=vul_points.split(",")
            continue
        if line.startswith('contract '):
            # print(f'line={line}')

            if '{' in line:
                contract = line.split('{')[0].strip().split(" ")[1:]
            else:
                contract = line.strip().split(' ')[1:]
            contracts.append(contract)
            continue

        if "<report>" in line:
            bug_name=line.split("<report>")[-1].strip()
            bugs.append([bug_name,line_index+1])


    prt_contracts=[]
    for contract_items in contracts:
        if len(contract_items)>=3:
            prt_contracts+=contract_items[2:]
    for contract_items in contracts:
        if contract_items[0] not in prt_contracts:
            final_results.append([solidity_name, solc_version, contract_items[0], vul_points, bugs])
    return final_results




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














