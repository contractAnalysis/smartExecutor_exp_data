import os


def obtain_results_for_case_studies(**kwargs):
    print('not implement yet')
    pass


"""
collect results for the experiment: case_studies

"""
import pandas as pd

from result_collection.config import base_dir, parameters_for_24_exp_sGuard, \
    parameters_for_case_studies
from result_collection.result_data_extraction.csv_file_handle import \
    combine_multiple_iteration_results_of_the_same_tool, \
    combine_multiple_csv_files
from result_collection.result_data_extraction.extraction import \
    extract_data_from_files
from result_collection.result_data_extraction.utils import find_all_files

root_dir=base_dir
experiment_name="case_studies"
exp_parameters=parameters_for_case_studies
p1_DL=1


def obtain_results_for_case_studies(**kwargs):
    """
    :param kwargs:
    :return:
    """
    collect_results()


def obtain_data_to_be_collected(tool_identifier:str,data_to_be_collected_dict:dict)->list:
    if "mythril" in tool_identifier:
        return data_to_be_collected_dict["mythril"]
    elif "smartExecutor" in tool_identifier:
        return data_to_be_collected_dict["smartExecutor"]
    elif "manticore" in tool_identifier:
        return data_to_be_collected_dict["manticore"]
    elif "smartian" in tool_identifier:
        return data_to_be_collected_dict["smartian"]
    else:
        return []

def collect_results():
    for dataset in exp_parameters['dataset_names']:
        result_data=[]
        for solidity_name, contract_name  in zip( exp_parameters['solidity_names'],exp_parameters['contract_names']):

            for tool_identfier in exp_parameters['tool_identifiers']:
                path_to_result = f'{root_dir}results/{dataset}/{solidity_name}__{contract_name}_{tool_identfier}.txt'
                if os.path.exists(path_to_result):
                    data_to_be_collected = obtain_data_to_be_collected("smartExecutor",
                                                                       exp_parameters['data_to_be_collected'])
                    files_extraction_data = extract_data_from_files(tool_identfier, [path_to_result],
                                                                    data_to_be_collected)

                    if tool_identfier == 'mythril_tx2':
                        tool_name = "Mythril(d=2)"
                    elif tool_identfier == 'mythril_tx3':
                        tool_name = "Mythril(d=3)"
                    elif tool_identfier == 'mythril_tx4':
                        tool_name = "Mythril(d=4)"
                    elif tool_identfier == 'smartExecutor_v3':
                        tool_name = "SmartExecutor*"
                    elif tool_identfier == 'smartExecutor':
                        tool_name = "SmartExecutor"
                    result_data.append([tool_name]+files_extraction_data[0])

        output_csv_file_name=f'{dataset}_case_studies_result_csv.csv'
        df_data=pd.DataFrame(result_data)
        try:
            df_data.columns= ["tool"]+data_to_be_collected
            df_data.to_csv(f'{root_dir}results/{dataset}/{output_csv_file_name}', index=False, sep=',', lineterminator='\n')
        except ValueError as e:
            print(f'ValueError: {e}')

