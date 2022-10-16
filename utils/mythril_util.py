# -*- coding: utf-8 -*-
"""
Created on Mon Jul 25 11:02:11 2022

@author: 18178
"""

import sys
import os
import csv
import pandas as pd
import numpy as np
import json
import ast
def find_all_file(dir,extension:str):
    """
    Given a parent directory, find all files with extension of extension
    Args:
        dir: parent directory, e.g. "/usr/admin/HoloToken/"

    Returns:
        list of file directories. e.g. ["/usr/admin/HoloToken/user0001.extension"......]
    """
    res = []
    for file in os.listdir(dir):
        if file.endswith("."+extension):
            res.append(os.path.join(dir, file))
    return res


def iterate_files(dir_list):
    """
    """
    result_dict = {}
    # dir_list.sort()
    for dir in dir_list:
        result_dict[str(dir).split("/")[-1]]= file_read(dir)
    return result_dict

def file_read_smartian(file_path)->list:
    contract_info = []
    flag_info = False
    num_bugs=0
    covered_instructions=0
    covered_edges = 0

    read_file = open(file_path, 'r', encoding='utf8')
    for line in read_file.readlines():
        line = line.strip('\n').strip()
        if len(line) == 0:
            continue
        if line.startswith('number_of_bugs'):
            num_bugs=line.split('number_of_bugs:')[-1]
            continue
        elif "Covered Edges :" in line:
            covered_edges=line.split(':')[-1]
            continue
        elif "Covered Instructions" in line:
            covered_instructions = line.split(':')[-1]

        elif line == "#@contract_info_time":
            flag_info=True
            continue

        if flag_info:
            flag_info = False
            contract_info = line.split(':')

    return [contract_info,covered_edges,covered_instructions,num_bugs]

keywords=['#@statespace',"#@coverage","====","#@contract_info_time","@@WEI:go_through_sequence_generation","@@total_instruction"]

def file_read(file_path)->list:
    statespace=[]
    flag_state=False
    
    coverage=[]
    flag_cov=False
    
    bugs={}
    flag_bug=False
    
    contract_info=[]
    flag_info=False
    
    bug_name=''
    bug_index=0
    
    flag_go_through_sequence_generation=False
    total_instructions=0
    
    read_file= open(file_path,'r', encoding='utf8')
    for line in read_file.readlines():
        line=line.strip('\n').strip()
        if len(line)==0:
            continue
        if line=='#@statespace':
            flag_state=True
            continue
        elif line=="#@coverage":
            flag_cov=True
            continue
        elif line[0:4] == "====":
            if line[0:5]=="=====":continue
            bug_index += 1
            bugs['bug' + str(bug_index)]={}
            bug_name=line.split('====')[1]
            bugs['bug'+str(bug_index)]['name']=bug_name
            flag_bug=True
            continue
        
        elif line == "#@contract_info_time":
            flag_bug=False # if contract_info_time is reached, definitely flag_bug should  be false
            flag_info=True
            continue
        elif line=="@@WEI:go_through_sequence_generation":
            flag_go_through_sequence_generation=True
            continue            
        elif line.startswith("@@total_instruction:"):
            total_instructions=line.split("@@total_instruction:")[-1]           
            continue           

        if flag_bug:
            line_eles=line.split(":")
            if line_eles[0].strip()=="SWC ID":
                bugs['bug'+str(bug_index)]['SWC_ID']=line_eles[1]
            elif line_eles[0].strip()=='Severity':
                bugs['bug'+str(bug_index)]['Severity']=line_eles[1]
            elif line_eles[0].strip() == 'Contract':
                bugs['bug' + str(bug_index)]['Contract'] = line_eles[1]
            elif line_eles[0].strip() == 'Function name':
                bugs['bug' + str(bug_index)]['Function_name'] = line_eles[1]
            elif line_eles[0].strip() == 'PC address':
                bugs['bug' + str(bug_index)]['PC_address'] = line_eles[1]
            elif line_eles[0].strip() == 'Estimated Gas Usage':
                bugs['bug' + str(bug_index)]['Estimated_Gas_Usage'] = line_eles[1]

        elif flag_state:
            flag_state=False
            # line format: 25 nodes, 24 edges, 363 total states
            line_eles=line.split(',')
            for ele in line_eles:
                statespace.append(ele.strip().split(' ')[0])
        elif flag_cov:
            flag_cov=False            
            #line format:Achieved 5.50% coverage for code: 6060604052341561000f576
            # in case of timeout, no coverage is obtained
            if "coverage" in line:
                coverage.append(line.split(' ')[1])
            
        elif flag_info:
            flag_info=False
            contract_info=line.split(':')
        else:
            pass
    return  [contract_info,statespace,coverage,bugs,flag_go_through_sequence_generation,total_instructions]


# line number is added when reading information regarding the detected vulnerabilities
def file_read__vul_line(file_path)->list:
    statespace=[]
    flag_state=False
    
    coverage=[]
    flag_cov=False
    
    bugs={}
    flag_bug=False
    
    contract_info=[]
    flag_info=False
    
    bug_name=''
    bug_index=0
    
    flag_go_through_sequence_generation=False
    
    read_file= open(file_path,'r', encoding='utf8')
    for line in read_file.readlines():
        line=line.strip('\n').strip()
        if len(line)==0:
            continue
        if line=='#@statespace':
            flag_state=True
            continue
        elif line=="#@coverage":
            flag_cov=True
            continue
        elif line[0:4] == "====":
            bug_index += 1
            bugs['bug' + str(bug_index)]={}
            bug_name=line.split('====')[1]
            bugs['bug'+str(bug_index)]['name']=bug_name
            flag_bug=True
            continue
        
        elif line == "#@contract_info_time":
            flag_bug=False # if contract_info_time is reached, definitely flag_bug should  be false
            flag_info=True
            continue
        elif line=="@@WEI:go_through_sequence_generation":
            flag_go_through_sequence_generation=True
            continue
            
        

        if flag_bug:
            line_eles=line.split(":")
            if line_eles[0].strip()=="SWC ID":
                bugs['bug'+str(bug_index)]['SWC_ID']=line_eles[1]
            elif line_eles[0].strip()=='Severity':
                bugs['bug'+str(bug_index)]['Severity']=line_eles[1]
            elif line_eles[0].strip() == 'Contract':
                bugs['bug' + str(bug_index)]['Contract'] = line_eles[1]
            elif line_eles[0].strip() == 'Function name':
                bugs['bug' + str(bug_index)]['Function_name'] = line_eles[1]
            elif line_eles[0].strip() == 'PC address':
                bugs['bug' + str(bug_index)]['PC_address'] = line_eles[1]
            elif line_eles[0].strip() == 'Estimated Gas Usage':
                bugs['bug' + str(bug_index)]['Estimated_Gas_Usage'] = line_eles[1]
            elif line_eles[0].strip()=='In file':
                bugs['bug'+ str(bug_index)]['line']=line_eles[2]

        elif flag_state:
            flag_state=False
            # line format: 25 nodes, 24 edges, 363 total states
            line_eles=line.split(',')
            for ele in line_eles:
                statespace.append(ele.strip().split(' ')[0])
        elif flag_cov:
            flag_cov=False
            #line format:Achieved 5.50% coverage for code: 6060604052341561000f576
            coverage.append(line.split(' ')[1])
        elif flag_info:
            flag_info=False
            contract_info=line.split(':')
        else:
            pass
    return  [contract_info,statespace,coverage,bugs,flag_go_through_sequence_generation]


keywords=['#@statespace',"#@coverage","====","#@contract_info_time","@@WEI:go_through_sequence_generation","@@function_coverage","@@generated_sequences","@@valid_sequences"]
# function coverage, generated sequences, valid sequences are extracted
def file_read_1(file_path)->list:
    statespace=[]
    flag_state=False
    
    coverage=[]
    flag_cov=False
    
    bugs={}
    flag_bug=False  

    
    contract_info=[]
    flag_info=False
    
    bug_name=''
    bug_index=0
    
    flag_go_through_sequence_generation=False
    
    ftn_coverage={}
    flag_ftn_coverage=False
    
    generated_sequences={}
    flag_generated_sequences=False    
      
    valid_sequences={}
    flag_valid_sequences=False 
    
    read_file= open(file_path,'r', encoding='utf8')
    for line in read_file.readlines():

        line=line.strip('\n').strip()        
        if len(line)==0:
            continue
        if line=='#@statespace':
            flag_state=True
            continue
        elif line=="#@coverage":
            flag_cov=True
            continue
        elif line[0:4] == "====":
            if line[0:5]=="=====":continue
            bug_index += 1
            bugs['bug' + str(bug_index)]={}
            bug_name=line.split('====')[1]
            bugs['bug'+str(bug_index)]['name']=bug_name
            flag_bug=True
            continue
        
        elif line == "#@contract_info_time":
            flag_bug=False # if contract_info_time is reached, definitely flag_bug should  be false
            flag_info=True
            continue
        elif line=="@@WEI:go_through_sequence_generation":
            flag_go_through_sequence_generation=True
            continue
        elif line=="@@function_coverage":
            flag_ftn_coverage=True
            flag_generated_sequences=False
            flag_valid_sequences=False
            continue
        elif line=="@@generated_sequences":
            flag_generated_sequences=True
            flag_ftn_coverage=False
            flag_valid_sequences=False
            continue
        elif line=="@@valid_sequences":
            flag_valid_sequences=True
            flag_ftn_coverage=False
            flag_generated_sequences=False
            continue
        
            
        

        if flag_bug:
            line_eles=line.split(":")
            if line_eles[0].strip()=="SWC ID":
                bugs['bug'+str(bug_index)]['SWC_ID']=line_eles[1]
            elif line_eles[0].strip()=='Severity':
                bugs['bug'+str(bug_index)]['Severity']=line_eles[1]
            elif line_eles[0].strip() == 'Contract':
                bugs['bug' + str(bug_index)]['Contract'] = line_eles[1]
            elif line_eles[0].strip() == 'Function name':
                bugs['bug' + str(bug_index)]['Function_name'] = line_eles[1]
            elif line_eles[0].strip() == 'PC address':
                bugs['bug' + str(bug_index)]['PC_address'] = line_eles[1]
            elif line_eles[0].strip() == 'Estimated Gas Usage':
                bugs['bug' + str(bug_index)]['Estimated_Gas_Usage'] = line_eles[1]

        elif flag_state:
            flag_state=False
            # line format: 25 nodes, 24 edges, 363 total states
            line_eles=line.split(',')
            for ele in line_eles:
                statespace.append(ele.strip().split(' ')[0])
        elif flag_cov:
            flag_cov=False
            #line format:Achieved 5.50% coverage for code: 6060604052341561000f576
            coverage.append(line.split(' ')[1])
        elif flag_info:
            flag_info=False
            contract_info=line.split(':')
            
        elif flag_ftn_coverage:
            items=line.split(":")
            if len(items)==2:
                if items[0] not in ftn_coverage.keys():
                    ftn_coverage[items[0]]=items[1]
            
            
        elif flag_generated_sequences:
            print("--------------")                
            print(line)
            continue
            
            
        elif flag_valid_sequences:
            if ":" in line and '[' in line:
                if "mythril.interfaces.cli [ERROR]" in line:
                    line=line.split("mythril.interfaces.cli [ERROR]")[0]         
                line_items=line.split(":")
                key=line_items[0]  
                res = ast.literal_eval(line_items[1])  
                if key not in valid_sequences.keys():
                    valid_sequences[key]=res   
            
    return  [contract_info,statespace,coverage,bugs,flag_go_through_sequence_generation,ftn_coverage,generated_sequences,valid_sequences]





def output_csv(result_dict,csv_path):
    contracts_data_cut_down={}
    
    with open(csv_path, mode='w') as writefile:
        # with open(sys.argv[2], mode='w') as writefile:
        writefile = csv.writer(writefile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        for key,value in result_dict.items():
            line_csv = []
            if isinstance(value,list):
                for item in value:
                    if isinstance(item,list):
                        if len(item)==0:# for state space
                            temp = ['-'] * 3
                            line_csv += temp
                        elif str(item[0]).__contains__('.sol'): # for contract info and time
                            line_csv += item
                        elif str(item[0]).__contains__('%'): # get coverage data
                            temp = ['-'] * 6 #
                            for i,it in enumerate(item):
                                if i<=5:
                                    temp[i] = it
                                else:
                                    # print(f'Warning: {item[i]} in {line_csv[0:3]} is cut down!')
                                    contracts_data_cut_down[line_csv[0]+":"+line_csv[2]]=line_csv[0:3]+item
                                    break   
                                
                            line_csv += temp
                        elif str(item[0]).__len__()>0:
                            line_csv += item


                    # extract bug names and group them and count frequency
                    if isinstance(item,dict):
                        bug_for_output=[]
                        bug_names=[]
                        for bug in item.values():
                            if isinstance(bug,dict):
                                bug_names.append(bug['name'])
                        unique_names=set(bug_names)
                        for name in unique_names:
                            num=bug_names.count(name)
                            bug_for_output.append(f'{name}:{num}')
                        line_csv+=bug_for_output 
                        
                    if isinstance(item,bool):                   
                        line_csv=[item]+line_csv # for flag_go_through_sequence_generation
            writefile.writerow(line_csv)
    return contracts_data_cut_down


def output_csv__vul_line(result_dict,csv_path):
    contracts_data_cut_down={}
    
    with open(csv_path, mode='w') as writefile:
        # with open(sys.argv[2], mode='w') as writefile:
        writefile = csv.writer(writefile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        for key,value in result_dict.items():
            line_csv = []
            if isinstance(value,list):
                for item in value:
                    if isinstance(item,list):
                        if len(item)==0:# for state space
                            temp = ['-'] * 3
                            line_csv += temp
                        elif str(item[0]).__contains__('.sol'): # for contract info and time
                            line_csv += item
                        elif str(item[0]).__contains__('%'): # get coverage data
                            temp = ['-'] * 6 #
                            for i,it in enumerate(item):
                                if i<=5:
                                    temp[i] = it
                                else:
                                    # print(f'Warning: {item[i]} in {line_csv[0:3]} is cut down!')
                                    contracts_data_cut_down[line_csv[0]+":"+line_csv[2]]=line_csv[0:3]+item
                                    break   
                                
                            line_csv += temp
                        elif str(item[0]).__len__()>0:
                            line_csv += item


                    # extract bug names and group them and count frequency
                    if isinstance(item,dict):
                        bug_for_output=[]
                      
                        for bug in item.values():
                            if isinstance(bug,dict):
                                name=bug['name']
                                if 'line' in bug.keys():
                                    line_no=bug['line']
                                else:
                                    line_no='unknown'
                                bug_for_output.append(f'{name}:line {line_no}')
                       
                        line_csv+=bug_for_output 
                        
                    if isinstance(item,bool):                   
                        line_csv=[item]+line_csv # for flag_go_through_sequence_generation
            writefile.writerow(line_csv)
    return contracts_data_cut_down




# #====================================
 # read csv file and convert data into ndarray
def convert_csv_to_ndarray_0(csv_file):
    with open(csv_file,'r') as dest_f:
        
        data_iter = csv.reader(dest_f,
                            delimiter = ',',
                            quotechar = '"')
     
        data_list = [data for data in data_iter if len(data)>1] # make sure the second column is solidity file name
        data_len=[len(item) for item in data_list]
         
    max_len=max(data_len)
     
    data_list_equal_size=[]
    for data in data_list:
        if ".sol" in data[1]:
            data_array=['-']*max_len
            for i in range(len(data)):
                data_array[i]=data[i]
            data_list_equal_size.append(data_array)
    return np.array(data_list_equal_size,dtype=None),max_len
   
    
# make sure the length of each row is of the same size
def convert_csv_to_ndarray(csv_file,column_size):
    with open(csv_file,'r') as dest_f:
        data_iter = csv.reader(dest_f,
                           delimiter = ',',
                           quotechar = '"')
    
        data_list = [data for data in data_iter if len(data)>1] # make sure the second column is solidity file name

        
    
    data_list_equal_size=[]
    for data in data_list: 
        if ".sol" in data[1]:
            data_array=['-']*column_size
            for i in range(len(data)):
                data_array[i]=data[i]
            data_list_equal_size.append(data_array)
    return np.array(data_list_equal_size,dtype=None),column_size


if __name__ == "__main__":
    
    path='C:\\22_summer_exp\\exp_mythril_smartExecutor\\results\\1st\\smartExecutor_v1_update_results\\contracts_12_group_378\\smartExecutor_group_378_results\\0x217cbe76b78a81d0a4afd271fb1c3b7178b8f513.sol__SwapToken.txt'
    
    print(file_read(path))
    
    