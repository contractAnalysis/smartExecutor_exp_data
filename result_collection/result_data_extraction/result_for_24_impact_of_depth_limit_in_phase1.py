

"""
collect results for the experiment: 24_impact_of_depth_limit_in_phase1

"""
import pandas as pd

from result_collection.config import base_dir, parameters_for_24_exp_sGuard, \
    parameters_for_24_impact_of_depth_limit_in_phase1
from result_collection.result_data_extraction.csv_file_handle import \
    combine_multiple_iteration_results_of_the_same_tool, \
    combine_multiple_csv_files
from result_collection.result_data_extraction.extraction import \
    extract_data_from_files
from result_collection.result_data_extraction.utils import find_all_files

root_dir=base_dir
experiment_name="24_impact_of_depth_limit_in_phase1"
exp_parameters=parameters_for_24_impact_of_depth_limit_in_phase1


def obtain_results_for_24_impact_of_depth_limit_in_phase1(**kwargs):
    """
    datasets
        timeouts
            tools
                depth limits (combine)
                    iterations (average)
    :param kwargs:
    :return:
    """

    collect_results()
    combine_csv_files_from_multiple_iterations()
    combine_csv_files_from_different_tools()

def obtain_data_to_be_collected(tool_identifier:str,data_to_be_collected_dict:dict)->list:
    if "smartExecutor" in tool_identifier:
        return data_to_be_collected_dict["smartExecutor"]
    else:
        data_to_be_collected_dict["smartExecutor"]

def collect_results():
    for dataset in exp_parameters['datasets']:
        for timeout in exp_parameters['timeouts']:
            for tool_identfier in exp_parameters['tool_identifiers']:
                for p1_DL in exp_parameters['depth_limits']:
                    for run_idx in range(1,exp_parameters['times']+1,1):

                        path_to_result=f'{root_dir}results/{dataset}/{tool_identfier}_results_{p1_DL}_{timeout}s_{run_idx}'

                        files=find_all_files(path_to_result,'txt')
                        data_to_be_collected=obtain_data_to_be_collected(tool_identfier,exp_parameters['data_to_be_collected'])
                        files_extraction_data=extract_data_from_files(tool_identfier,files,data_to_be_collected)

                        # output the extracted data to a csv file
                        output_csv_file_name=f'{tool_identfier}_results_{p1_DL}_{timeout}s_{run_idx}_csv.csv'

                        df_data=pd.DataFrame(files_extraction_data)
                        try:
                            df_data.columns=data_to_be_collected
                            df_data.to_csv(f'{root_dir}results/{dataset}/{output_csv_file_name}', index=False, sep=',', lineterminator='\n')
                        except ValueError as e:
                            print(f'ValueError: {e}')

def combine_csv_files_from_multiple_iterations():
    """
    combine the results in multiple iterations
    :return:
    """
    for dataset in exp_parameters['datasets']:
        for timeout in exp_parameters['timeouts']:
            for tool_identfier in exp_parameters['tool_identifiers']:
                for p1_DL in exp_parameters['depth_limits']:
                    csv_files_to_be_combined=[]
                    for run_idx in range(1,exp_parameters['times']+1,1):

                        output_csv_file_name = f'{tool_identfier}_results_{p1_DL}_{timeout}s_{run_idx}_csv.csv'

                        csv_files_to_be_combined.append(output_csv_file_name)

                    path_to_save = f'{root_dir}results/{dataset}/'
                    data_to_be_collected=obtain_data_to_be_collected(tool_identfier,exp_parameters['data_to_be_collected'])


                    identifier=f'{tool_identfier}_{p1_DL}_{timeout}s'

                    combine_multiple_iteration_results_of_the_same_tool(
                        path_to_save,
                        str(identifier),
                        csv_files_to_be_combined,
                        data_to_be_collected)

def combine_csv_files_from_different_tools():
    for dataset in exp_parameters['datasets']:
        for timeout in exp_parameters['timeouts']:
            for tool_identfier in exp_parameters['tool_identifiers']:
                tool_csv_files_to_be_combined = []
                result_csv_file_name_identifier = tool_identfier+"_"

                for p1_DL in exp_parameters['depth_limits']:
                    csv_file_name=f'{tool_identfier}_{p1_DL}_{timeout}s_average_of_{exp_parameters["times"]}_instances_results.csv'

                    tool_csv_files_to_be_combined.append(csv_file_name)
                    result_csv_file_name_identifier+=f'{p1_DL}_'

                path_to_save=f'{root_dir}results/{dataset}/'
                combine_multiple_csv_files(path_to_save,tool_csv_files_to_be_combined,result_file_name_identifier=result_csv_file_name_identifier)