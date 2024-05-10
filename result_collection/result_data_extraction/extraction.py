from result_collection.result_data_extraction.file_data_extraction.extract_manticore import \
    extract_a_result_file_from_manticore
from result_collection.result_data_extraction.file_data_extraction.extract_mythril import \
    extract_a_result_file_from_mythril
from result_collection.result_data_extraction.file_data_extraction.extract_smartExecutor import \
    extract_a_result_file_from_smartExecutor
from result_collection.result_data_extraction.file_data_extraction.extract_smartian import \
    extract_a_result_file_from_smartian


def extract_data_from_a_file(tool_identifier:str, file_path_and_name:str,data_to_be_collected:list)->dict:
    results={}
    if "mythril" in tool_identifier:
        results=extract_a_result_file_from_mythril(file_path_and_name,data_to_be_collected)
    elif 'smartExecutor' in tool_identifier:
        results = extract_a_result_file_from_smartExecutor(file_path_and_name,data_to_be_collected)
    elif 'smartian' in tool_identifier:
        results = extract_a_result_file_from_smartian(file_path_and_name,data_to_be_collected)
    elif 'manticore' in tool_identifier:
        results = extract_a_result_file_from_manticore(file_path_and_name,data_to_be_collected)
    else:
        print(f'No file data extraction for tool identifier {tool_identifier}')
    return results

def extract_data_from_files(tool_identifier:str, file_path_and_names:list,data_to_be_collected:list)->list:
    results=[]
    for file_path_and_name in file_path_and_names:
        result=extract_data_from_a_file(tool_identifier, file_path_and_name,data_to_be_collected)
        results.append(result)
    return results